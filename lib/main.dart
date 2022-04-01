import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Swiftで使える画像処理ライブラリ(OpenCV)をFlutterに読み込んでみた。
// MethodChannel(ネイティブ(iOS/Android)のメソッドを非同期で呼び出す)を使用

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Open CV with Method Channel',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Open CV with Method Channel'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('samples.flutter.dev/image');
  Image image = Image.asset("images/icon.png");

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
            image,
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  image = Image.asset("images/icon.png");
                });
              },
              child: const Text('元に戻す'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final opencv = await _processOpenCVWithMethodChannel();
                  setState(() {
                    image = Image.memory(base64Decode(opencv));
                  });
                } catch (e) {
                  print(e);
                }
              },
              child: const Text('OpenCV を実行する'),
            )
          ],
        ),
      ),
    );
  }

  // 画像データを文字型に変換し処理します。
  // なぜなら、画像データを直接MethodChannelで取り扱うことができないから。
  Future<String> _processOpenCVWithMethodChannel() async {
    ByteData imageData = await rootBundle.load('images/icon.png');
    String base64 = base64Encode(Uint8List.view(imageData.buffer));
    String result = await platform.invokeMethod('getBase64', base64);
    return result; // getBase64をSwift側に渡す
  }
}
