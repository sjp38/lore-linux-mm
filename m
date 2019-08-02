Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65980C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 04:16:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EB842073D
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 04:16:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EB842073D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 995EA6B0266; Fri,  2 Aug 2019 00:16:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9451F6B026B; Fri,  2 Aug 2019 00:16:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85B326B026D; Fri,  2 Aug 2019 00:16:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DDA76B0266
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 00:16:36 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id r7so40884771plo.6
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 21:16:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=02zIVBedhxNNCP2upK1zwemWX44mmpxddNoiRLuzFXk=;
        b=fImUYVagunLjWz9SGzsjMwL6UpfJ/20Bcnr0zyo9XyRzbmSGcxFtmAH0xl9xhIWKmp
         ibleGyw6h/JtbhnKsGPX9rAJymIWuhIq9fpxO6OcCeZRUsSE+Ulol46GwNJZhdRkPCsN
         trAXxLVafhS5hw+V0FTUMyqMwtOs3U3VjLXbQ7oBUa38VP8wr80Vwm17Ci1GO5GHcAGU
         AJYbp0Yr/yCGcZ15BaxgSiYqDn1J1MhNoYG230x1gulWeYr7vwEZkTM5O1A1HJerdtYp
         Sm/Y/FRdhM6JF4z7n7OXBaL6Hb6D7tvDGaS8snmE3d9cXqm2YlaEOcoMIt2GSuhHK41x
         4Gug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAUic7LYhMDltsMcDRQxomKX4WJuyFQqVwuEUHE9/Yu/miaJlXrS
	RIX7ag4CVroPkvgXuswCEVRvepSGtpy2CReJaDKol2c+0eFIC/MK4iC/8uc/0iI0gzNmlidBhEw
	OV0P59ykaazwhtB/+gc7POUim5UPqp1awcJabjkrWkHf8fKq+ENt0x3RPLgPdWHA0Eg==
X-Received: by 2002:a63:9e56:: with SMTP id r22mr65574802pgo.221.1564719395874;
        Thu, 01 Aug 2019 21:16:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/MFqNQvhPP55/KwzPzMJhezVQH07WxiIAWqWvN6M+y0H3xI32PTP+8MU7mrAoWWobEQTi
X-Received: by 2002:a63:9e56:: with SMTP id r22mr65574764pgo.221.1564719394958;
        Thu, 01 Aug 2019 21:16:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564719394; cv=none;
        d=google.com; s=arc-20160816;
        b=YvpMpxpWaHd1f5BaCvy383dKUAcdDjKWJclIxm/tzy50lPvKh+ec82USIkRUkfP2Er
         8zbVEN+cJQStLkOu2/CZl2hI25mZk+I0EasUWfZlZb+6i3k/4rROQsbsnnYBbjg8Tczg
         mKnU7iWrT8uOTKQPEqHubXs0XW26JngkvCeOWFiJet3acqY0OXiulpzfScyqIo/eBlMg
         LrSgMoZXXjK0T5MbobY4yL28kmNsE2TBXv76P5Yza4xGcN8Lv3Npb+z0jRU+h+4DVToi
         jocoztt9tu2wsEN40gevr2qCn5QES1HqwAWpyk92gOH6k8b0/KCB57xQjxHXgTB0WKan
         nGEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=02zIVBedhxNNCP2upK1zwemWX44mmpxddNoiRLuzFXk=;
        b=JEmlLVwkQX6z4+u+W1d/sSDaT/T5rB0dbQ24xO3J5gBG7D8sNgAfDLn6eaAyRkLytK
         NZW7F6zzs3JoBS5kV5kvri42s+ZVdh4MUVlUXNk1FMd6yrCq9A9RL4TANitXDQcD4Tc6
         SAyzcRDixfdFxiTvPRM/pS9oiJawOBFg5m9EWv4zOvVE2U3IaDd25qJGEUBp7qt5E61Q
         +s1wQPLyQD4p8l3Hv/TJo0ZCr9gxnFYDU1qD0XM3MCraZstsVeBz4UPDrKQyP28XW1pc
         B1zRYOhY/S4HtqpAGQYaiPRkIwv7k0XJglrixJaoRAVOOPQrafWGXq15yaB/yVYlsJCP
         PT0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 189si9579559pgj.416.2019.08.01.21.16.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 21:16:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x724GSWF011582
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Fri, 2 Aug 2019 13:16:28 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x724GS2O028837;
	Fri, 2 Aug 2019 13:16:28 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x724F8vc002261;
	Fri, 2 Aug 2019 13:16:28 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.150] [10.38.151.150]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-7342834; Fri, 2 Aug 2019 13:15:59 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC22GP.gisp.nec.co.jp ([10.38.151.150]) with mapi id 14.03.0439.000; Fri, 2
 Aug 2019 13:15:58 +0900
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
Thread-Index: AQHVRc0JEN0QZXp8lkC2QA8h/0i/bKbhXVuAgADAW4CAATIAAIADHcSAgABCA4A=
Date: Fri, 2 Aug 2019 04:15:57 +0000
Message-ID: <20190802041557.GA16274@hori.linux.bs1.fc.nec.co.jp>
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
 <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
 <a65e748b-7297-8547-c18d-9fb07202d5a0@oracle.com>
 <27a48931-aff6-d001-de78-4f7bef584c32@oracle.com>
In-Reply-To: <27a48931-aff6-d001-de78-4f7bef584c32@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="utf-8"
Content-ID: <976644284DBF884BBF6BD709A3EA8805@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCBBdWcgMDEsIDIwMTkgYXQgMDU6MTk6NDFQTSAtMDcwMCwgTWlrZSBLcmF2ZXR6IHdy
b3RlOg0KPiBPbiA3LzMwLzE5IDU6NDQgUE0sIE1pa2UgS3JhdmV0eiB3cm90ZToNCj4gPiBBIFNJ
R0JVUyBpcyB0aGUgbm9ybWFsIGJlaGF2aW9yIGZvciBhIGh1Z2V0bGIgcGFnZSBmYXVsdCBmYWls
dXJlIGR1ZSB0bw0KPiA+IGxhY2sgb2YgaHVnZSBwYWdlcy4gIFVnbHksIGJ1dCB0aGF0IGlzIHRo
ZSBkZXNpZ24uICBJIGRvIG5vdCBiZWxpZXZlIHRoaXMNCj4gPiB0ZXN0IHNob3VsZCBub3QgYmUg
ZXhwZXJpZW5jaW5nIHRoaXMgZHVlIHRvIHJlc2VydmF0aW9ucyB0YWtlbiBhdCBtbWFwDQo+ID4g
dGltZS4gIEhvd2V2ZXIsIHRoZSB0ZXN0IGlzIGNvbWJpbmluZyBmYXVsdHMsIHNvZnQgb2ZmbGlu
ZSBhbmQgcGFnZQ0KPiA+IG1pZ3JhdGlvbnMsIHNvIHRoZSB0aGVyZSBhcmUgbG90cyBvZiBtb3Zp
bmcgcGFydHMuDQo+ID4gDQo+ID4gSSdsbCBjb250aW51ZSB0byBpbnZlc3RpZ2F0ZS4NCj4gDQo+
IFRoZXJlIGFwcGVhcnMgdG8gYmUgYSByYWNlIHdpdGggaHVnZXRsYl9mYXVsdCBhbmQgdHJ5X3Rv
X3VubWFwX29uZSBvZg0KPiB0aGUgbWlncmF0aW9uIHBhdGguDQo+IA0KPiBDYW4geW91IHRyeSB0
aGlzIHBhdGNoIGluIHlvdXIgZW52aXJvbm1lbnQ/ICBJIGFtIG5vdCBzdXJlIGlmIGl0IHdpbGwN
Cj4gYmUgdGhlIGZpbmFsIGZpeCwgYnV0IGp1c3Qgd2FudGVkIHRvIHNlZSBpZiBpdCBhZGRyZXNz
ZXMgaXNzdWUgZm9yIHlvdS4NCj4gDQo+IGRpZmYgLS1naXQgYS9tbS9odWdldGxiLmMgYi9tbS9o
dWdldGxiLmMNCj4gaW5kZXggZWRlN2U3ZjVkMWFiLi5mMzE1NmM1NDMyZTMgMTAwNjQ0DQo+IC0t
LSBhL21tL2h1Z2V0bGIuYw0KPiArKysgYi9tbS9odWdldGxiLmMNCj4gQEAgLTM4NTYsNiArMzg1
NiwyMCBAQCBzdGF0aWMgdm1fZmF1bHRfdCBodWdldGxiX25vX3BhZ2Uoc3RydWN0IG1tX3N0cnVj
dCAqbW0sDQo+ICANCj4gIAkJcGFnZSA9IGFsbG9jX2h1Z2VfcGFnZSh2bWEsIGhhZGRyLCAwKTsN
Cj4gIAkJaWYgKElTX0VSUihwYWdlKSkgew0KPiArCQkJLyoNCj4gKwkJCSAqIFdlIGNvdWxkIHJh
Y2Ugd2l0aCBwYWdlIG1pZ3JhdGlvbiAodHJ5X3RvX3VubWFwX29uZSkNCj4gKwkJCSAqIHdoaWNo
IGlzIG1vZGlmeWluZyBwYWdlIHRhYmxlIHdpdGggbG9jay4gIEhvd2V2ZXIsDQo+ICsJCQkgKiB3
ZSBhcmUgbm90IGhvbGRpbmcgbG9jayBoZXJlLiAgQmVmb3JlIHJldHVybmluZw0KPiArCQkJICog
ZXJyb3IgdGhhdCB3aWxsIFNJR0JVUyBjYWxsZXIsIGdldCBwdGwgYW5kIG1ha2UNCj4gKwkJCSAq
IHN1cmUgdGhlcmUgcmVhbGx5IGlzIG5vIGVudHJ5Lg0KPiArCQkJICovDQo+ICsJCQlwdGwgPSBo
dWdlX3B0ZV9sb2NrKGgsIG1tLCBwdGVwKTsNCj4gKwkJCWlmICghaHVnZV9wdGVfbm9uZShodWdl
X3B0ZXBfZ2V0KHB0ZXApKSkgew0KPiArCQkJCXJldCA9IDA7DQo+ICsJCQkJc3Bpbl91bmxvY2so
cHRsKTsNCj4gKwkJCQlnb3RvIG91dDsNCj4gKwkJCX0NCj4gKwkJCXNwaW5fdW5sb2NrKHB0bCk7
DQoNClRoYW5rcyB5b3UgZm9yIGludmVzdGlnYXRpb24sIE1pa2UuDQpJIHRyaWVkIHRoaXMgY2hh
bmdlIGFuZCBmb3VuZCBubyBTSUdCVVMsIHNvIGl0IHdvcmtzIHdlbGwuDQoNCkknbSBzdGlsbCBu
b3QgY2xlYXIgYWJvdXQgaG93ICFodWdlX3B0ZV9ub25lKCkgYmVjb21lcyB0cnVlIGhlcmUsDQpi
ZWNhdXNlIHdlIGVudGVyIGh1Z2V0bGJfbm9fcGFnZSgpIG9ubHkgd2hlbiBodWdlX3B0ZV9ub25l
KCkgaXMgbm9uLW51bGwNCmFuZCAocmFjeSkgdHJ5X3RvX3VubWFwX29uZSgpIGZyb20gcGFnZSBt
aWdyYXRpb24gc2hvdWxkIGNvbnZlcnQgdGhlDQpodWdlX3B0ZSBpbnRvIGEgbWlncmF0aW9uIGVu
dHJ5LCBub3QgbnVsbC4NCg0KVGhhbmtzLA0KTmFveWEgSG9yaWd1Y2hp

