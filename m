Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 429806B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 02:04:43 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f63so333873625oig.1
        for <linux-mm@kvack.org>; Sun, 08 May 2016 23:04:43 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id 10si6607847iog.122.2016.05.08.23.04.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 May 2016 23:04:42 -0700 (PDT)
From: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Subject: RE: [PATCH v2 1/2] mm, kasan: improve double-free detection
Date: Mon, 9 May 2016 06:04:28 +0000
Message-ID: <20E775CA4D599049A25800DE5799F6DD1F6276ED@G4W3225.americas.hpqcorp.net>
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
 <20160507102505.GA27794@yury-N73SV>
 <20E775CA4D599049A25800DE5799F6DD1F62744C@G4W3225.americas.hpqcorp.net>
 <20160508085045.GA27394@yury-N73SV>
 <CACT4Y+Zdy+cyfZ2dqnbZMn3edVteuQTyTswjL83JquFbhcPpTA@mail.gmail.com>
In-Reply-To: <CACT4Y+Zdy+cyfZ2dqnbZMn3edVteuQTyTswjL83JquFbhcPpTA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Yury Norov <ynorov@caviumnetworks.com>
Cc: "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "glider@google.com" <glider@google.com>, "cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "klimov.linux@gmail.com" <klimov.linux@gmail.com>

PiA+PiBUaGFuayB5b3UgZm9yIHRoZSByZXZpZXchDQo+ID4+DQo+ID4+ID4gPiArIHN3aXRjaCAo
YWxsb2NfZGF0YS5zdGF0ZSkgew0KPiA+PiA+ID4gKyBjYXNlIEtBU0FOX1NUQVRFX1FVQVJBTlRJ
TkU6DQo+ID4+ID4gPiArIGNhc2UgS0FTQU5fU1RBVEVfRlJFRToNCj4gPj4gPiA+ICsgICAgICAg
ICBrYXNhbl9yZXBvcnQoKHVuc2lnbmVkIGxvbmcpb2JqZWN0LCAwLCBmYWxzZSwNCj4gPj4gPiA+
ICsgICAgICAgICAgICAgICAgICAgICAgICAgKHVuc2lnbmVkIGxvbmcpX19idWlsdGluX3JldHVy
bl9hZGRyZXNzKDEpKTsNCj4gPj4gPg0KPiA+PiA+IF9fYnVpbHRpbl9yZXR1cm5fYWRkcmVzcygp
IGlzIHVuc2FmZSBpZiBhcmd1bWVudCBpcyBub24temVyby4gVXNlDQo+ID4+ID4gcmV0dXJuX2Fk
ZHJlc3MoKSBpbnN0ZWFkLg0KPiA+Pg0KPiA+PiBobW0sIEkvY3Njb3BlIGNhbid0IHNlZW0gdG8g
ZmluZCBhbiB4ODYgaW1wbGVtZW50YXRpb24gZm9yDQo+IHJldHVybl9hZGRyZXNzKCkuDQo+ID4+
IFdpbGwgZGlnIGZ1cnRoZXI7IHRoYW5rcy4NCj4gPj4NCj4gPg0KPiA+IEl0IHNlZW1zIHRoZXJl
J3Mgbm8gZ2VuZXJpYyBpbnRlcmZhY2UgdG8gb2J0YWluIHJldHVybiBhZGRyZXNzLiB4ODYNCj4g
PiBoYXMgIHdvcmtpbmcgX19idWlsdGluX3JldHVybl9hZGRyZXNzKCkgYW5kIGl0J3Mgb2sgd2l0
aCBpdCwgb3RoZXJzDQo+ID4gdXNlIHRoZWlyIG93biByZXR1cm5fYWRkZXJzcygpLCBhbmQgb2sg
YXMgd2VsbC4NCj4gPg0KPiA+IEkgdGhpbmsgdW5pZmljYXRpb24gaXMgbmVlZGVkIGhlcmUuDQo+
IA0KPiANCj4gV2UgdXNlIF9SRVRfSVBfIGluIG90aGVyIHBsYWNlcyBpbiBwb3J0YWJsZSBwYXJ0
IG9mIGthc2FuLg0KDQpZZWFoLCBfUkVUX0lQXyBpcyB0aGUgd2F5IHRvIGdvIGhlcmUuDQoNCk5v
dCBkaXJlY3RseSByZWxhdGVkIGJ1dDogd2hpbGUgbG9va2luZyBpbnRvIGthc2FuX3NsYWJfZnJl
ZSgpIGNhbGxlcnMsIGl0IHNlZW1zDQp0byBtZSB0aGF0LCB3aXRoIFNMQUIgKyBxdWFyYW50aW5l
LCBrYXNhbl9wb2lzb25fa2ZyZWUoKSBzaG91bGQgX25vdF8gYmUNCmNhbGxpbmcgaW50byBrYXNh
bl9zbGFiX2ZyZWUoKS4gVGhlIGludGVudCBpbiB0aGUgY2FsbC1jaGFpbiB0aHJ1DQprYXNhbl9w
b2lzb25fa3JlZSgpIHNlZW1zIHRvIGJlIG9ubHkgdG8gcG9pc29uIG9iamVjdCBzaGFkb3csIG5v
dCBhY3R1YWxseQ0KZnJlZSBpdC4NCg0KQWxleGFuZGVyLCBjYW4geW91IHBsZWFzZSBjb21tZW50
L2NvbmZpcm0/IFRoYW5rcy4NCg0KS3V0aG9udXpvDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
