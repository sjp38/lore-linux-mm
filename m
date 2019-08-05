Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77662C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 00:42:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E4042075C
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 00:42:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E4042075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6FCF6B026F; Sun,  4 Aug 2019 20:42:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF9E66B0270; Sun,  4 Aug 2019 20:42:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 972FE6B0271; Sun,  4 Aug 2019 20:42:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC866B026F
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 20:42:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d2so45200121pla.18
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 17:42:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=855I/seObYuUDpzQikhPL7R44O4YkmS7t2Xd0AeLlUU=;
        b=h5n4zrQvn66te0QoxvLWoC9QhxfZHOUCB2snDy37h9PqzlpOYM3X+fzgs/hxnkDSN9
         pshpCiDRPVB4+mmeZdLLtuSuQHy68uGstmBTRu6NakHrOASlswJ9PsUM9ze0eyNL7PtW
         bMsvUZLhZL5pF10XduoWIc2KMhp0ckxHT9b0Haul7GnsTWlUYe/f1c6H3IDviYwkR0Vf
         M3veX6MK3z4yg7jSO7x4tlXD6SdJd2rhM7alj4I+sgvhZ6hbVTQi42fvhdbR21JFKZr4
         Y+MR+eELEY0jJeopR+3J/LPtX52XPCvRfU8m9jrZZMDByiToGlBDeJ/uqsq0LHtcrby/
         V5Kw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAUtHTSjZ0OaYoXhZ4eJkYqx8xzrIKXiIZ5d2HsQIXmLnQ8/t/QQ
	qWcAEGh4UNEdHVsYqw++cKNqSmKylikCUICiCTvVsTHmhQFrLSEiH3L6lO1m1ZuOcCobFhGzED1
	SZOKyLgErPGQcXK8rsLEGNvym8ynvIt0CFBBwTcs+lOAEvRWNvLBDRWMb3ov9puxm+Q==
X-Received: by 2002:a17:902:f082:: with SMTP id go2mr148816665plb.25.1564965730969;
        Sun, 04 Aug 2019 17:42:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxWj3Sj5vGvvEbya7g9URPdJJ62oBy6w1wuh1XTtlvD3921VBftc+xP72H0pIQEDsslFI9
X-Received: by 2002:a17:902:f082:: with SMTP id go2mr148816602plb.25.1564965730094;
        Sun, 04 Aug 2019 17:42:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564965730; cv=none;
        d=google.com; s=arc-20160816;
        b=CP4Z3sAJQSRYu7iYtplE6asNIFMAfTyrushyNgqJChGQ0WaTKB34++l8m8cFcvl1hT
         0HYIstSmJZciUMsKlqEkft4Sdqtc2chqzYnwJH8UXjhOnXfz49ntmazNl9zVyxq6nLw1
         EEPl9R+ycc8o/lLjt4XeHVgTDPwmwSMYg5EGXXm0dtfPdlkTLQNfFdaKDlcnuqKM239S
         ft3L52RZZ1FxA9wAh6NN0h+l/1R0RGb4PA02v0OfhOwse/f4W2tufMR5LekkNJ6m4BmJ
         FBoIWUVTqIWTfCXhbgA8HTlrpWvapujBaswLLs1WQTw/YQtgIqSLnaTKtDYiO74DdubG
         1QPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=855I/seObYuUDpzQikhPL7R44O4YkmS7t2Xd0AeLlUU=;
        b=w6mwokYZGEj8bjbnzPxu4WPulMZyPJ803r59cl9WdV/1MReEvB3QKbQnjX48rK7S/f
         lAciebV/sAuLryuo8HdkIJQquGkn1FvKzJBpNBBBovtvwyVOs51DEqhi1r3ZyFeC2xVD
         Ky+Tmcj9CygV9UXrAglbsKOZg+yEUHkXHVHKk+KxxhNpCArRpwstkxTHNgcm89feAhwa
         MBiVEOKtz+iqC2srMJnwUoV6MrIXrJjo39KuLeFYoskAo14xuGGskfMK8p235K6s9Xfb
         aI8Rn4chjTHp1N/B97CIoXbYQwmD9dAe5Y+UW/dAVXwgk3B6nX00CuxpgpNzLhnV/W3i
         TUZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id c10si43052252pgw.174.2019.08.04.17.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 17:42:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x750g0v8026935
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Mon, 5 Aug 2019 09:42:00 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x750g0MQ026221;
	Mon, 5 Aug 2019 09:42:00 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x750eAEq025447;
	Mon, 5 Aug 2019 09:42:00 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-7382076; Mon, 5 Aug 2019 09:40:43 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0439.000; Mon, 5
 Aug 2019 09:40:43 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: Li Wang <liwang@redhat.com>, Linux-MM <linux-mm@kvack.org>,
        LTP List <ltp@lists.linux.it>,
        "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        Cyril Hrubis <chrubis@suse.cz>
Subject: =?utf-8?B?UmU6IFtNTSBCdWc/XSBtbWFwKCkgdHJpZ2dlcnMgU0lHQlVTIHdoaWxlIGRv?=
 =?utf-8?B?aW5nIHRoZeKAiyDigItudW1hX21vdmVfcGFnZXMoKSBmb3Igb2ZmbGluZWQg?=
 =?utf-8?Q?hugepage_in_background?=
Thread-Topic: =?utf-8?B?W01NIEJ1Zz9dIG1tYXAoKSB0cmlnZ2VycyBTSUdCVVMgd2hpbGUgZG9pbmcg?=
 =?utf-8?B?dGhl4oCLIOKAi251bWFfbW92ZV9wYWdlcygpIGZvciBvZmZsaW5lZCBodWdl?=
 =?utf-8?Q?page_in_background?=
Thread-Index: AQHVRc0JEN0QZXp8lkC2QA8h/0i/bKbhXVuAgADAW4CAATIAAIADHcSAgABCA4CAAOFdgIADmX4A
Date: Mon, 5 Aug 2019 00:40:42 +0000
Message-ID: <20190805004042.GA16862@hori.linux.bs1.fc.nec.co.jp>
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
 <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
 <a65e748b-7297-8547-c18d-9fb07202d5a0@oracle.com>
 <27a48931-aff6-d001-de78-4f7bef584c32@oracle.com>
 <20190802041557.GA16274@hori.linux.bs1.fc.nec.co.jp>
 <54a5c9f5-eade-0d8f-24f9-bff6f19d4905@oracle.com>
In-Reply-To: <54a5c9f5-eade-0d8f-24f9-bff6f19d4905@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="utf-8"
Content-ID: <9C96D525978644469080C167ED48F070@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gRnJpLCBBdWcgMDIsIDIwMTkgYXQgMTA6NDI6MzNBTSAtMDcwMCwgTWlrZSBLcmF2ZXR6IHdy
b3RlOg0KPiBPbiA4LzEvMTkgOToxNSBQTSwgTmFveWEgSG9yaWd1Y2hpIHdyb3RlOg0KPiA+IE9u
IFRodSwgQXVnIDAxLCAyMDE5IGF0IDA1OjE5OjQxUE0gLTA3MDAsIE1pa2UgS3JhdmV0eiB3cm90
ZToNCj4gPj4gVGhlcmUgYXBwZWFycyB0byBiZSBhIHJhY2Ugd2l0aCBodWdldGxiX2ZhdWx0IGFu
ZCB0cnlfdG9fdW5tYXBfb25lIG9mDQo+ID4+IHRoZSBtaWdyYXRpb24gcGF0aC4NCj4gPj4NCj4g
Pj4gQ2FuIHlvdSB0cnkgdGhpcyBwYXRjaCBpbiB5b3VyIGVudmlyb25tZW50PyAgSSBhbSBub3Qg
c3VyZSBpZiBpdCB3aWxsDQo+ID4+IGJlIHRoZSBmaW5hbCBmaXgsIGJ1dCBqdXN0IHdhbnRlZCB0
byBzZWUgaWYgaXQgYWRkcmVzc2VzIGlzc3VlIGZvciB5b3UuDQo+ID4+DQo+ID4+IGRpZmYgLS1n
aXQgYS9tbS9odWdldGxiLmMgYi9tbS9odWdldGxiLmMNCj4gPj4gaW5kZXggZWRlN2U3ZjVkMWFi
Li5mMzE1NmM1NDMyZTMgMTAwNjQ0DQo+ID4+IC0tLSBhL21tL2h1Z2V0bGIuYw0KPiA+PiArKysg
Yi9tbS9odWdldGxiLmMNCj4gPj4gQEAgLTM4NTYsNiArMzg1NiwyMCBAQCBzdGF0aWMgdm1fZmF1
bHRfdCBodWdldGxiX25vX3BhZ2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sDQo+ID4+ICANCj4gPj4g
IAkJcGFnZSA9IGFsbG9jX2h1Z2VfcGFnZSh2bWEsIGhhZGRyLCAwKTsNCj4gPj4gIAkJaWYgKElT
X0VSUihwYWdlKSkgew0KPiA+PiArCQkJLyoNCj4gPj4gKwkJCSAqIFdlIGNvdWxkIHJhY2Ugd2l0
aCBwYWdlIG1pZ3JhdGlvbiAodHJ5X3RvX3VubWFwX29uZSkNCj4gPj4gKwkJCSAqIHdoaWNoIGlz
IG1vZGlmeWluZyBwYWdlIHRhYmxlIHdpdGggbG9jay4gIEhvd2V2ZXIsDQo+ID4+ICsJCQkgKiB3
ZSBhcmUgbm90IGhvbGRpbmcgbG9jayBoZXJlLiAgQmVmb3JlIHJldHVybmluZw0KPiA+PiArCQkJ
ICogZXJyb3IgdGhhdCB3aWxsIFNJR0JVUyBjYWxsZXIsIGdldCBwdGwgYW5kIG1ha2UNCj4gPj4g
KwkJCSAqIHN1cmUgdGhlcmUgcmVhbGx5IGlzIG5vIGVudHJ5Lg0KPiA+PiArCQkJICovDQo+ID4+
ICsJCQlwdGwgPSBodWdlX3B0ZV9sb2NrKGgsIG1tLCBwdGVwKTsNCj4gPj4gKwkJCWlmICghaHVn
ZV9wdGVfbm9uZShodWdlX3B0ZXBfZ2V0KHB0ZXApKSkgew0KPiA+PiArCQkJCXJldCA9IDA7DQo+
ID4+ICsJCQkJc3Bpbl91bmxvY2socHRsKTsNCj4gPj4gKwkJCQlnb3RvIG91dDsNCj4gPj4gKwkJ
CX0NCj4gPj4gKwkJCXNwaW5fdW5sb2NrKHB0bCk7DQo+ID4gDQo+ID4gVGhhbmtzIHlvdSBmb3Ig
aW52ZXN0aWdhdGlvbiwgTWlrZS4NCj4gPiBJIHRyaWVkIHRoaXMgY2hhbmdlIGFuZCBmb3VuZCBu
byBTSUdCVVMsIHNvIGl0IHdvcmtzIHdlbGwuDQo+ID4gDQo+ID4gSSdtIHN0aWxsIG5vdCBjbGVh
ciBhYm91dCBob3cgIWh1Z2VfcHRlX25vbmUoKSBiZWNvbWVzIHRydWUgaGVyZSwNCj4gPiBiZWNh
dXNlIHdlIGVudGVyIGh1Z2V0bGJfbm9fcGFnZSgpIG9ubHkgd2hlbiBodWdlX3B0ZV9ub25lKCkg
aXMgbm9uLW51bGwNCj4gPiBhbmQgKHJhY3kpIHRyeV90b191bm1hcF9vbmUoKSBmcm9tIHBhZ2Ug
bWlncmF0aW9uIHNob3VsZCBjb252ZXJ0IHRoZQ0KPiA+IGh1Z2VfcHRlIGludG8gYSBtaWdyYXRp
b24gZW50cnksIG5vdCBudWxsLg0KPiANCj4gVGhhbmtzIGZvciB0YWtpbmcgYSBsb29rIE5hb3lh
Lg0KPiANCj4gSW4gdHJ5X3RvX3VubWFwX29uZSgpLCB0aGVyZSBpcyB0aGlzIGNvZGUgYmxvY2s6
DQo+IA0KPiAJCS8qIE51a2UgdGhlIHBhZ2UgdGFibGUgZW50cnkuICovDQo+IAkJZmx1c2hfY2Fj
aGVfcGFnZSh2bWEsIGFkZHJlc3MsIHB0ZV9wZm4oKnB2bXcucHRlKSk7DQo+IAkJaWYgKHNob3Vs
ZF9kZWZlcl9mbHVzaChtbSwgZmxhZ3MpKSB7DQo+IAkJCS8qDQo+IAkJCSAqIFdlIGNsZWFyIHRo
ZSBQVEUgYnV0IGRvIG5vdCBmbHVzaCBzbyBwb3RlbnRpYWxseQ0KPiAJCQkgKiBhIHJlbW90ZSBD
UFUgY291bGQgc3RpbGwgYmUgd3JpdGluZyB0byB0aGUgcGFnZS4NCj4gCQkJICogSWYgdGhlIGVu
dHJ5IHdhcyBwcmV2aW91c2x5IGNsZWFuIHRoZW4gdGhlDQo+IAkJCSAqIGFyY2hpdGVjdHVyZSBt
dXN0IGd1YXJhbnRlZSB0aGF0IGEgY2xlYXItPmRpcnR5DQo+IAkJCSAqIHRyYW5zaXRpb24gb24g
YSBjYWNoZWQgVExCIGVudHJ5IGlzIHdyaXR0ZW4gdGhyb3VnaA0KPiAJCQkgKiBhbmQgdHJhcHMg
aWYgdGhlIFBURSBpcyB1bm1hcHBlZC4NCj4gCQkJICovDQo+IAkJCXB0ZXZhbCA9IHB0ZXBfZ2V0
X2FuZF9jbGVhcihtbSwgYWRkcmVzcywgcHZtdy5wdGUpOw0KPiANCj4gCQkJc2V0X3RsYl91YmNf
Zmx1c2hfcGVuZGluZyhtbSwgcHRlX2RpcnR5KHB0ZXZhbCkpOw0KPiAJCX0gZWxzZSB7DQo+IAkJ
CXB0ZXZhbCA9IHB0ZXBfY2xlYXJfZmx1c2godm1hLCBhZGRyZXNzLCBwdm13LnB0ZSk7DQo+IAkJ
fQ0KPiANCj4gVGhhdCBoYXBwZW5zIGJlZm9yZSBzZXR0aW5nIHRoZSBtaWdyYXRpb24gZW50cnku
ICBUaGVyZWZvcmUsIGZvciBhIHBlcmlvZA0KPiBvZiB0aW1lIHRoZSBwdGUgaXMgTlVMTCAoaHVn
ZV9wdGVfbm9uZSgpIHJldHVybnMgdHJ1ZSkuDQo+IA0KPiB0cnlfdG9fdW5tYXBfb25lIGhvbGRz
IHRoZSBwYWdlIHRhYmxlIGxvY2ssIGJ1dCBodWdldGxiX2ZhdWx0IGRvZXMgbm90IHRha2UNCj4g
dGhlIGxvY2sgdG8gJ29wdGltaXN0aWNhbGx5JyBjaGVjayBodWdlX3B0ZV9ub25lKCkuICBXaGVu
IGh1Z2VfcHRlX25vbmUNCj4gcmV0dXJucyB0cnVlLCBpdCBjYWxscyBodWdldGxiX25vX3BhZ2Ug
d2hpY2ggaXMgd2hlcmUgd2UgdHJ5IHRvIGFsbG9jYXRlDQo+IGEgcGFnZSBhbmQgZmFpbHMuDQo+
IA0KPiBEb2VzIHRoYXQgbWFrZSBzZW5zZSwgb3IgYW0gSSBtaXNzaW5nIHNvbWV0aGluZz8NCg0K
TWFrZSBzZW5zZSB0byBtZSwgdGhhbmtzLg0KDQo+IA0KPiBUaGUgcGF0Y2ggY2hlY2tzIGZvciB0
aGlzIHNwZWNpZmljIGNvbmRpdGlvbjogc29tZW9uZSBjaGFuZ2luZyB0aGUgcHRlDQo+IGZyb20g
TlVMTCB0byBub24tTlVMTCB3aGlsZSBob2xkaW5nIHRoZSBsb2NrLiAgSSBhbSBub3Qgc3VyZSBp
ZiB0aGlzIGlzDQo+IHRoZSBiZXN0IHdheSB0byBmaXguICBCdXQsIGl0IG1heSBiZSB0aGUgZWFz
aWVzdC4NCg0KWWVzLCBJIHRoaW5rIHNvLg0KDQotIE5hb3lh

