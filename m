Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 710776B025F
	for <linux-mm@kvack.org>; Sun, 29 May 2016 11:00:12 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id di3so122722990pab.0
        for <linux-mm@kvack.org>; Sun, 29 May 2016 08:00:12 -0700 (PDT)
Received: from g2t2355.austin.hpe.com (g2t2355.austin.hpe.com. [15.233.44.28])
        by mx.google.com with ESMTPS id vx8si43750850pac.107.2016.05.29.08.00.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 May 2016 08:00:11 -0700 (PDT)
From: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Subject: RE: [PATCH v3 1/2] mm, kasan: improve double-free detection
Date: Sun, 29 May 2016 15:00:05 +0000
Message-ID: <20E775CA4D599049A25800DE5799F6DD1F635924@G9W0759.americas.hpqcorp.net>
References: <20160524183018.GA4769@cherokee.in.rdlabs.hpecorp.net>
 <CACT4Y+ZBSEpqi+aUFdKZk9ncRzAxPpBRLV8DGrEuSWSBNbdpAQ@mail.gmail.com>
 <20E775CA4D599049A25800DE5799F6DD1F635901@G9W0759.americas.hpqcorp.net>
 <CACT4Y+Yd4kvqg90NsOWPpAc7ijGLfFn2Bn6CTVVDSm07k8eX9w@mail.gmail.com>
In-Reply-To: <CACT4Y+Yd4kvqg90NsOWPpAc7ijGLfFn2Bn6CTVVDSm07k8eX9w@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Yury Norov <ynorov@caviumnetworks.com>

PiA+PiA+ICsvKiBmbGFncyBzaGFkb3cgZm9yIG9iamVjdCBoZWFkZXIgaWYgaXQgaGFzIGJlZW4g
b3ZlcndyaXR0ZW4uICovDQo+ID4+ID4gK3ZvaWQga2FzYW5fbWFya19iYWRfbWV0YShzdHJ1Y3Qg
a2FzYW5fYWxsb2NfbWV0YSAqYWxsb2NfaW5mbywNCj4gPj4gPiArICAgICAgICAgICAgICAgc3Ry
dWN0IGthc2FuX2FjY2Vzc19pbmZvICppbmZvKQ0KPiA+PiA+ICt7DQo+ID4+ID4gKyAgICAgICB1
OCAqZGF0YXAgPSAodTggKikmYWxsb2NfaW5mby0+ZGF0YTsNCj4gPj4gPiArDQo+ID4+ID4gKyAg
ICAgICBpZiAoKCgodTggKilpbmZvLT5hY2Nlc3NfYWRkciArIGluZm8tPmFjY2Vzc19zaXplKSA+
IGRhdGFwKSAmJg0KPiA+PiA+ICsgICAgICAgICAgICAgICAgICAgICAgICgodTggKilpbmZvLT5m
aXJzdF9iYWRfYWRkciA8PSBkYXRhcCkgJiYNCj4gPj4gPiArICAgICAgICAgICAgICAgICAgICAg
ICBpbmZvLT5pc193cml0ZSkNCj4gPj4gPiArICAgICAgICAgICAgICAga2FzYW5fcG9pc29uX3No
YWRvdygodm9pZCAqKWRhdGFwLA0KPiBLQVNBTl9TSEFET1dfU0NBTEVfU0laRSwNCj4gPj4gPiAr
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIEtBU0FOX0tNQUxMT0NfQkFEX01FVEEpOw0K
PiA+Pg0KPiA+Pg0KPiA+PiBJcyBpdCBvbmx5IHRvIHByZXZlbnQgZGVhZGxvY2tzIGluIGthc2Fu
X21ldGFfbG9jaz8NCj4gPj4NCj4gPj4gSWYgc28sIGl0IGlzIHN0aWxsIHVucmVsYWJsZSBiZWNh
dXNlIGFuIE9PQiB3cml0ZSBjYW4gaGFwcGVuIGluDQo+ID4+IG5vbi1pbnN0cnVtZW50ZWQgY29k
ZS4gT3IsIGthc2FuX21ldGFfbG9jayBjYW4gc3VjY2Vzc2Z1bGx5IGxvY2sNCj4gPj4gb3Zlcndy
aXR0ZW4gZ2FyYmFnZSBiZWZvcmUgbm90aWNpbmcgS0FTQU5fS01BTExPQ19CQURfTUVUQS4gT3Is
IHR3bw0KPiA+PiB0aHJlYWRzIGNhbiBhc3N1bWUgbG9jayBvd25lcnNoaXAgYWZ0ZXIgbm90aWNp
bmcNCj4gPj4gS0FTQU5fS01BTExPQ19CQURfTUVUQS4NCj4gPj4NCj4gPj4gQWZ0ZXIgdGhlIGZp
cnN0IHJlcG9ydCB3ZSBjb250aW51ZSB3b3JraW5nIGluIGtpbmQgb2YgYmVzdCBlZmZvcnQNCj4g
Pj4gbW9kZTogd2UgY2FuIHRyeSB0byBtaXRpZ2F0ZSBzb21lIHRoaW5ncywgYnV0IGdlbmVyYWxs
eSBhbGwgYmV0cyBhcmUNCj4gPj4gb2ZmLiBCZWNhdXNlIG9mIHRoYXQgdGhlcmUgaXMgbm8gbmVl
ZCB0byBidWlsZCBzb21ldGhpbmcgY29tcGxleCwNCj4gPj4gZ2xvYmFsIChhbmQgc3RpbGwgdW5y
ZWxhYmxlKS4gSSB3b3VsZCBqdXN0IHdhaXQgZm9yIGF0IG1vc3QsIHNheSwgMTANCj4gPj4gc2Vj
b25kcyBpbiBrYXNhbl9tZXRhX2xvY2ssIGlmIHdlIGNhbid0IGdldCB0aGUgbG9jayAtLSBwcmlu
dCBhbiBlcnJvcg0KPiA+PiBhbmQgcmV0dXJuLiBUaGF0J3Mgc2ltcGxlLCBsb2NhbCBhbmQgd29u
J3QgZGVhZGxvY2sgdW5kZXIgYW55DQo+ID4+IGNpcmN1bXN0YW5jZXMuDQo+ID4+IFRoZSBlcnJv
ciBtZXNzYWdlIHdpbGwgYmUgaGVscGZ1bCwgYmVjYXVzZSB0aGVyZSBhcmUgY2hhbmNlcyB3ZSB3
aWxsDQo+ID4+IHJlcG9ydCBhIGRvdWJsZS1mcmVlIG9uIGZyZWUgb2YgdGhlIGNvcnJ1cHRlZCBv
YmplY3QuDQo+ID4+ICBlDQo+ID4+IFRlc3RzIGNhbiBiZSBhcnJhbmdlZCBzbyB0aGF0IHRoZXkg
d3JpdGUgMCAodW5sb2NrZWQpIGludG8gdGhlIG1ldGENCj4gPj4gKGlmIG5lY2Vzc2FyeSkuDQo+
ID4NCj4gPiBEbWl0cnksDQo+ID4NCj4gPiBUaGFua3MgdmVyeSBtdWNoIGZvciByZXZpZXcgJiBj
b21tZW50cy4gWWVzLCB0aGUgbG9ja2luZyBzY2hlbWUgaW4gdjMNCj4gPiBpcyBmbGF3ZWQgaW4g
dGhlIHByZXNlbmNlIG9mIE9PQiB3cml0ZXMgb24gaGVhZGVyLCBzYWZldHkgdmFsdmUNCj4gPiBu
b3R3aXRoc3RhbmRpbmcuIFRoZSBjb3JlIGlzc3VlIGlzIHRoYXQgd2hlbiB0aHJlYWQgZmluZHMg
bG9jayBoZWxkLCBpdCBpcw0KPiA+IGRpZmZpY3VsdCB0byB0ZWxsIHdoZXRoZXIgYSBsZWdpdCBs
b2NrIGhvbGRlciBleGlzdHMgb3IgbG9jayBiaXQgZ290IGZsaXBwZWQNCj4gPiBmcm9tIE9PQi4g
RWFybGllciwgSSBkaWQgY29uc2lkZXIgYSBsb2NrIHRpbWVvdXQgYnV0IGZlbHQgaXQgdG8gYmUg
YSBiaXQgdWdseS4uLg0KPiA+DQo+ID4gSG93ZXZlciwgSSBiZWxpZXZlIEkndmUgZm91bmQgYSBz
b2x1dGlvbiBhbmQgd2FzIGFib3V0IHRvIHB1c2ggb3V0IHY0DQo+ID4gd2hlbiB5b3VyIGNvbW1l
bnRzIGNhbWUgaW4uIEl0IHRha2VzIGNvbmNlcHQgZnJvbSB2MyAtIGV4cGxvaXRpbmcNCj4gPiBz
aGFkb3cgbWVtb3J5IC0gdG8gbWFrZSBsb2NrIG11Y2ggbW9yZSByZWxpYWJsZS9yZXNpbGllbnQg
ZXZlbiBpbiB0aGUNCj4gPiBwcmVzZW5jZSBvZiBPT0Igd3JpdGVzLiBJJ2xsIHB1c2ggb3V0IHY0
IHdpdGhpbiB0aGUgaG91ci4uLg0KPiANCj4gDQo+IExvY2tpbmcgc2hhZG93IHdpbGwgcHJvYmFi
bHkgd29yay4NCg0KSXQgZG9lczsgdjQgZG9lcyB0aGlzIDstKQ0KDQo+IE5lZWQgdG8gdGhpbmsg
bW9yZS4NCj4gDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
