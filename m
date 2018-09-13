Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25BE78E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:11:02 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id w19-v6so5349085ioa.10
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 11:11:02 -0700 (PDT)
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680121.outbound.protection.outlook.com. [40.107.68.121])
        by mx.google.com with ESMTPS id q200-v6si3148680itq.62.2018.09.13.11.11.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Sep 2018 11:11:00 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
Date: Thu, 13 Sep 2018 18:10:58 +0000
Message-ID: <d0695f2b-5db3-cc1d-b069-4511e4e06887@microsoft.com>
References: 
 <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
 <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
 <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
 <20180527130325.GB4522@rapoport-lnx>
 <CAGM2rea2GBvOAiKcSpHkQ9F+jgvy3sCsBw7hFz26DvQ+c_677A@mail.gmail.com>
 <CAGqmi74G-7bM5mbbaHjzOkTvuEpCcAbZ8Q0PVCMkyP09XaVSkA@mail.gmail.com>
 <20180607115232.GA8245@rapoport-lnx>
 <CAGM2rebK=gNbcAwkmt7W9kwtd=QWoPRogQMaoXOv=bmX+_d+yw@mail.gmail.com>
 <20180625084806.GB13791@rapoport-lnx>
 <CAGqmi75emzhU_coNv_8qaf1LkdG7gsFWNAFTwUC+1FikH7h1WQ@mail.gmail.com>
 <20180913180132.GB15191@rapoport-lnx>
In-Reply-To: <20180913180132.GB15191@rapoport-lnx>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A2F04108D4AE8448B8C5D1AED7D5494F@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Timofey Titovets <nefelim4ag@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Sioh Lee <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>

DQoNCk9uIDkvMTMvMTggMjowMSBQTSwgTWlrZSBSYXBvcG9ydCB3cm90ZToNCj4gKHVwZGF0ZWQg
UGFzaGEncyBlLW1haWwpDQo+IA0KPiBUaHUsIFNlcCAxMywgMjAxOCBhdCAwMTozNToyMFBNICsw
MzAwLCBUaW1vZmV5IFRpdG92ZXRzIHdyb3RlOg0KPj4g0L/QvSwgMjUg0LjRjtC9LiAyMDE4INCz
LiDQsiAxMTo0OCwgTWlrZSBSYXBvcG9ydCA8cnBwdEBsaW51eC52bmV0LmlibS5jb20+Og0KPj4+
DQo+Pj4gT24gVGh1LCBKdW4gMDcsIDIwMTggYXQgMDk6Mjk6NDlQTSAtMDQwMCwgUGF2ZWwgVGF0
YXNoaW4gd3JvdGU6DQo+Pj4+PiBXaXRoIENPTkZJR19TWVNGUz1uIHRoZXJlIGlzIG5vdGhpbmcg
dGhhdCB3aWxsIHNldCBrc21fcnVuIHRvIGFueXRoaW5nIGJ1dA0KPj4+Pj4gemVybyBhbmQga3Nt
X2RvX3NjYW4gd2lsbCBuZXZlciBiZSBjYWxsZWQuDQo+Pj4+Pg0KPj4+Pg0KPj4+PiBVbmZvcnR1
bmF0bHksIHRoaXMgaXMgbm90IHNvOg0KPj4+Pg0KPj4+PiBJbjogL2xpbnV4LW1hc3Rlci9tbS9r
c20uYw0KPj4+Pg0KPj4+PiAzMTQzI2Vsc2UNCj4+Pj4gMzE0NCBrc21fcnVuID0gS1NNX1JVTl9N
RVJHRTsgLyogbm8gd2F5IGZvciB1c2VyIHRvIHN0YXJ0IGl0ICovDQo+Pj4+IDMxNDUNCj4+Pj4g
MzE0NiNlbmRpZiAvKiBDT05GSUdfU1lTRlMgKi8NCj4+Pj4NCj4+Pj4gU28sIHdlIGRvIHNldCBr
c21fcnVuIHRvIHJ1biByaWdodCBmcm9tIGtzbV9pbml0KCkgd2hlbiBDT05GSUdfU1lTRlM9bi4N
Cj4+Pj4NCj4+Pj4gSSB3b25kZXIgaWYgdGhpcyBpcyBhY2NlcHRpYmxlIHRvIG9ubHkgdXNlIHh4
aGFzaCB3aGVuIENPTkZJR19TWVNGUz1uID8NCj4+Pg0KPj4+IEJUVywgd2l0aCBDT05GSUdfU1lT
RlM9biBLU00gbWF5IHN0YXJ0IHJ1bm5pbmcgYmVmb3JlIGhhcmR3YXJlIGFjY2VsZXJhdGlvbg0K
Pj4+IGZvciBjcmMzMmMgaXMgaW5pdGlhbGl6ZWQuLi4NCj4+Pg0KPj4+PiBUaGFuayB5b3UsDQo+
Pj4+IFBhdmVsDQo+Pj4+DQo+Pj4NCj4+PiAtLQ0KPj4+IFNpbmNlcmVseSB5b3VycywNCj4+PiBN
aWtlLg0KPj4+DQo+Pg0KPj4gTGl0dGxlIHRocmVhZCBidW1wLg0KPj4gVGhhdCBwYXRjaHNldCBj
YW4ndCBtb3ZlIGZvcndhcmQgYWxyZWFkeSBmb3IgYWJvdXQgfjggbW9udGguDQo+PiBBcyBpIHNl
ZSBtYWluIHF1ZXN0aW9uIGluIHRocmVhZDogdGhhdCB3ZSBoYXZlIGEgcmFjZSB3aXRoIGtzbQ0K
Pj4gaW5pdGlhbGl6YXRpb24gYW5kIGF2YWlsYWJpbGl0eSBvZiBjcnlwdG8gYXBpLg0KPj4gTWF5
YmUgd2UgdGhlbiBjYW4gZmFsbCBiYWNrIHRvIHNpbXBsZSBwbGFuLCBhbmQganVzdCByZXBsYWNl
IG9sZCBnb29kDQo+PiBidWRkeSBqaGFzaCBieSBqdXN0IG1vcmUgZmFzdCB4eGhhc2g/DQo+PiBU
aGF0IGFsbG93IG1vdmUgcXVlc3Rpb24gd2l0aCBjcnlwdG8gYXBpICYgY3JjMzIgdG8gYmFja2dy
b3VuZCwgYW5kDQo+PiBtYWtlIHRoaW5ncyBiZXR0ZXIgZm9yIG5vdywgaW4gMi0zIHRpbWVzLg0K
Pj4NCj4+IFdoYXQgeW91IGFsbCB0aGluayBhYm91dCB0aGF0Pw0KPiANCj4gU291bmRzIHJlYXNv
bmFibGUgdG8gbWUNCg0KU2FtZSBoZXJlLCBwbGVhc2Ugc2VuZCBhIG5ldyBwYXRjaCB3aXRoIHh4
aGFzaCwgYW5kIGFmdGVyIHRoYXQgd2UgY2FuDQp3b3JrIG9uIGEgZmFzdGVyIGNyYzMyLg0KDQpU
aGFuayB5b3UsDQpQYXZlbA0KDQo+IA0KPj4+IGNyYzMyY19pbnRlbDogMTA4NC4xMG5zDQo+Pj4g
Y3JjMzJjIChubyBoYXJkd2FyZSBhY2NlbGVyYXRpb24pOiA3MDEyLjUxbnMNCj4+PiB4eGhhc2gz
MjogMjIyNy43NW5zDQo+Pj4geHhoYXNoNjQ6IDE0MTMuMTZucw0KPj4+IGpoYXNoMjogNTEyOC4z
MG5zDQo+Pg0KPj4gLS0gDQo+PiBIYXZlIGEgbmljZSBkYXksDQo+PiBUaW1vZmV5Lg0KPj4NCj4g
