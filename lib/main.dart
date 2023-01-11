import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry Printer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Laundry Printer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final bluetooth = BlueThermalPrinter.instance;
  var _state = '';

  var _devices = <BluetoothDevice>[];
  Uri? _initialUri;

  @override
  void initState() {
    _handleInit();

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _state = 'Connected';
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _state = 'Disconnected';
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _state = 'Disconnect requested';
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _state = 'Turning off';
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _state = 'Off';
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _state = 'On';
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _state = 'Turning On';
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _state = 'Error';
          });
          break;
        default:
          print(state);
          break;
      }
    });

    super.initState();
  }

  Future _handleInit() async {
    final uri = await getInitialUri();
    try {
      _devices = await bluetooth.getBondedDevices();
    } catch (e) {}

    setState(() {
      _initialUri = uri;
    });
  }

  Future _handlePrint(BluetoothDevice d) async {
    try {
      await bluetooth.connect(d);

      bluetooth.printCustom('Hello', 2, 0);
      bluetooth.printQRcode(
        "00020101021126570011ID.DANA.WWW011893600915312913148402091291314840303UMI51440014ID.CO.QRIS.WWW0215ID10210681486540303UMI5204721053033605802ID5913Cinta Laundry6014Kab. Tangerang6105155606304CC53",
        300,
        300,
        1,
      );
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();

      await bluetooth.disconnect();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(_initialUri.toString()),
            Text(_initialUri?.queryParameters["uuid"] ??
                'No uuid detected. Cannot print.'),
            Text('Bluetooth : $_state'),

            Column(
              children: _devices
                  .map((d) => Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Column(children: [
                                      Container(
                                        child: Text(d?.name ?? ''),
                                      ),
                                      Container(
                                        child: Text(d.address ?? ''),
                                      )
                                    ]),
                                  ),
                                ),
                                Container(
                                  child: MaterialButton(
                                    onPressed: () async {
                                      _handlePrint(d);
                                    },
                                    color: Theme.of(context).primaryColor,
                                    child: Text(
                                      'Print',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Divider()
                          ],
                        ),
                      ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
