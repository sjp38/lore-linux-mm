Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24C86C282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 15:37:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39CDB20815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 15:37:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39CDB20815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kwiboo.se
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCA256B000A; Sun, 26 May 2019 11:36:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C51A36B000C; Sun, 26 May 2019 11:36:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF36B6B000D; Sun, 26 May 2019 11:36:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A72F6B000A
	for <linux-mm@kvack.org>; Sun, 26 May 2019 11:36:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f41so23641836ede.1
        for <linux-mm@kvack.org>; Sun, 26 May 2019 08:36:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=K2SHzUJ80/EZQ+mt+F6FQYuA8rzXIUa0pFdEezA72K0=;
        b=QO+ZjPu8bDVnSihSMPyqC4G6zdYxtlsm6kw7/SMvDhAnWfjRO6L3nhdBjXCc3Zix+A
         VSr+I8qbZl8a0beEETgpQhVwaZJEl2qXFQpwLUNfh07x3msUA5FoFYITcgHH2hAHRRfS
         Sa4J3wj8EOSt/AZ8y8ccMOfo4xyHIoHaeAyZn9Gyn/l1wOJDjDB9uRLP1eY55EMJMv4b
         t3CUl4B99V3pCDvdlfBwU6RlopgV49puWobKVH2LBaEdOkdDLbnoj1Kbxsruq5Cse2PF
         2IW2Qbui8t+jQWXmytN7wYWJN72IXaif3GxrWlXe9KpSZYwzbPe9jh6JCrZ3VgrH19il
         Jy9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonas@kwiboo.se designates 40.92.72.54 as permitted sender) smtp.mailfrom=jonas@kwiboo.se
X-Gm-Message-State: APjAAAXi3/jvf6K0tQzfXZzJb6C9NvO18fk7IdVhhQjpV4+YwUvRy2qJ
	AhrazXORSAXjOw9ew4qj3tndFRq8vLTvFiY4CXfY1Taik0p4fSQ8BSwp0vNDjIw6vi8Got+zlEg
	ivvzCrUNJ59nkZmdgtfUp7lzoekx0KrnBp9RkF82FTsdIXYx40nkHOOfmlGUhmEHy/A==
X-Received: by 2002:a05:6402:1644:: with SMTP id s4mr72804296edx.182.1558885018924;
        Sun, 26 May 2019 08:36:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygaoDkfoNEr5/RNhWj3tFwTg3h+CBwjFOXDm6KWBe+QOCIvQVXFQ+nrwsRq5AtEeEiLjf5
X-Received: by 2002:a05:6402:1644:: with SMTP id s4mr72804232edx.182.1558885018149;
        Sun, 26 May 2019 08:36:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558885018; cv=none;
        d=google.com; s=arc-20160816;
        b=0vFoWMzqg6Ex8VUoU6KxsmzLjAkBYS68cmbhesGOFCX46su1/R4I8hLvfc4mH+fLga
         SC8YjQstSbRibZsYCU9zvWsqb0JGjY5mKg7/BJka1Q0EeBVw2qt9qfwnACNmZrCz19uo
         gC43TXCt9fTk0nNfsXNMwDYyfRJdYBWgPil0OE2d8f8l2yaWydsuKK5Q1ExSNheXePrY
         UZY+j63HTCfXcPsCzEhLQJ+dqwzRWTxQaEJ7JVo5Pqc/a2INgXnsGtkfCY5IeDjQhvuQ
         wKh1O8CSh450D+Xs9uTo8sjCvRePkn9fzQpp4zpzZ0D9JwX7j0TAWN5LOc2Z3yONMZP5
         lYIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=K2SHzUJ80/EZQ+mt+F6FQYuA8rzXIUa0pFdEezA72K0=;
        b=Lur/uAl7adTdxXqb0CcKoCd4RzqIzTsvXKlbqZglh7GrlE+V8P544sUkP9MWP8nX7I
         ROdHWmjSm8SViqq2GG7ZSuWY8xWXdhWN0c7MOwUc7BGd+EgKvET4GkHB9+kADkEp9e56
         u9NCsTCYMzBpSkNeEute+lvIWaP3suWPK+9LaykzfaZEZgH/elmqhWXFuccGeN7KJ1If
         How2wREsSTg9LR4pLHsT/L2yEidvXpGnVmLJ5NSDYjgwpBo5ucgOG7Z22DOkSZUCouJ+
         94iwbKQUce5k2hf5jYIuZ9KiYloY9tFyBVgwZhlF/zKsNbNzAtIVuOCrIYKtAYDPh8/p
         wu7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonas@kwiboo.se designates 40.92.72.54 as permitted sender) smtp.mailfrom=jonas@kwiboo.se
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-oln040092072054.outbound.protection.outlook.com. [40.92.72.54])
        by mx.google.com with ESMTPS id d14si1372550edp.306.2019.05.26.08.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 26 May 2019 08:36:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonas@kwiboo.se designates 40.92.72.54 as permitted sender) client-ip=40.92.72.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonas@kwiboo.se designates 40.92.72.54 as permitted sender) smtp.mailfrom=jonas@kwiboo.se
Received: from VE1EUR03FT064.eop-EUR03.prod.protection.outlook.com
 (10.152.18.56) by VE1EUR03HT032.eop-EUR03.prod.protection.outlook.com
 (10.152.19.67) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1922.16; Sun, 26 May
 2019 15:36:57 +0000
Received: from VI1PR03MB4206.eurprd03.prod.outlook.com (10.152.18.54) by
 VE1EUR03FT064.mail.protection.outlook.com (10.152.19.210) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.20.1922.16 via Frontend Transport; Sun, 26 May 2019 15:36:57 +0000
Received: from VI1PR03MB4206.eurprd03.prod.outlook.com
 ([fe80::883e:1bd6:cd36:5fb0]) by VI1PR03MB4206.eurprd03.prod.outlook.com
 ([fe80::883e:1bd6:cd36:5fb0%4]) with mapi id 15.20.1922.021; Sun, 26 May 2019
 15:36:57 +0000
From: Jonas Karlman <jonas@kwiboo.se>
To: Souptick Joarder <jrdr.linux@gmail.com>, kbuild test robot <lkp@intel.com>
CC: "kbuild-all@01.org" <kbuild-all@01.org>, Andrew Morton
	<akpm@linux-foundation.org>, Linux Memory Management List
	<linux-mm@kvack.org>
Subject: Re: [kwiboo-linux-rockchip:rockchip-5.1-patches-from-5.3-v5.1.5
 83/106] drivers/gpu//drm/rockchip/rockchip_drm_gem.c:230:9: error: implicit
 declaration of function 'vm_map_pages'; did you mean 'vma_pages'?
Thread-Topic: [kwiboo-linux-rockchip:rockchip-5.1-patches-from-5.3-v5.1.5
 83/106] drivers/gpu//drm/rockchip/rockchip_drm_gem.c:230:9: error: implicit
 declaration of function 'vm_map_pages'; did you mean 'vma_pages'?
Thread-Index: AQHVE7K5gPswkPR5NEWrudXYjhX7GKZ9hyuAgAADIYA=
Date: Sun, 26 May 2019 15:36:56 +0000
Message-ID: <VI1PR03MB4206678FD979F4855AE26BA5AC1C0@VI1PR03MB4206.eurprd03.prod.outlook.com>
References: <201905261855.ag29CM2I%lkp@intel.com>
 <CAFqt6zYC0vGozczTTtU0YiM-PiREj-VYuq1PexQCPCpn0OwKVA@mail.gmail.com>
In-Reply-To: <CAFqt6zYC0vGozczTTtU0YiM-PiREj-VYuq1PexQCPCpn0OwKVA@mail.gmail.com>
Accept-Language: sv-SE, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: AM5PR0602CA0019.eurprd06.prod.outlook.com
 (2603:10a6:203:a3::29) To VI1PR03MB4206.eurprd03.prod.outlook.com
 (2603:10a6:803:51::23)
x-incomingtopheadermarker: OriginalChecksum:4EFF5F4C2A553F483FD29FED2C94C8BC3EAA388015477BC8D6738E1EEE61EC50;UpperCasedChecksum:A2FEFB9B7B8A18C911C695D848FF761F6A62DCAE408D14F6B147887F13AB7312;SizeAsReceived:7922;Count:49
x-ms-exchange-messagesentrepresentingtype: 1
x-tmn: [8pqJxA53NPd9ArOPZlgo86wxWU3sOmLB]
x-microsoft-original-message-id: <2d72c1bf-879f-db71-9a3d-1926d3509e42@kwiboo.se>
x-ms-publictraffictype: Email
x-incomingheadercount: 49
x-eopattributedmessage: 0
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(5050001)(7020095)(20181119110)(201702061078)(5061506573)(5061507331)(1603103135)(2017031320274)(2017031323274)(2017031324274)(2017031322404)(1601125500)(1603101475)(1701031045);SRVR:VE1EUR03HT032;
x-ms-traffictypediagnostic: VE1EUR03HT032:
x-ms-exchange-purlcount: 5
x-microsoft-antispam-message-info: a9cIrSOlFWL4IlWF16qBeLDIvTSMeDTgv+gTnqqCaVdsfqwiXYLIkmkgD4E5uRHTiZEuBBkLXLFVBA6qNzT0jBf0y2iTGFoXYRPrCeG3BFe/E4RNI+cTX9kr8Au9A7jiwFqI4BGZ/GoR2qCYWFOa5TPit/qctPANYT+TsXmlW1Oc2M2vh2g0Zeaw1k7c+DsY
Content-Type: text/plain; charset="utf-8"
Content-ID: <E584A609471E7C4EA2A0C81B3F342396@eurprd03.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: outlook.com
X-MS-Exchange-CrossTenant-RMS-PersistedConsumerOrg: 00000000-0000-0000-0000-000000000000
X-MS-Exchange-CrossTenant-Network-Message-Id: b9a236c7-290a-452e-b78e-08d6e1effc46
X-MS-Exchange-CrossTenant-rms-persistedconsumerorg: 00000000-0000-0000-0000-000000000000
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 May 2019 15:36:56.9597
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Internet
X-MS-Exchange-CrossTenant-id: 84df9e7f-e9f6-40af-b435-aaaaaaaaaaaa
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VE1EUR03HT032
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wNS0yNiAxNzoyNSwgU291cHRpY2sgSm9hcmRlciB3cm90ZToNCj4gSGkgSm9uYXMs
DQo+DQo+IE9uIFN1biwgTWF5IDI2LCAyMDE5IGF0IDQ6MjkgUE0ga2J1aWxkIHRlc3Qgcm9ib3Qg
PGxrcEBpbnRlbC5jb20+IHdyb3RlOg0KPj4gdHJlZTogICBodHRwczovL2dpdGh1Yi5jb20vS3dp
Ym9vL2xpbnV4LXJvY2tjaGlwIHJvY2tjaGlwLTUuMS1wYXRjaGVzLWZyb20tNS4zLXY1LjEuNQ0K
Pj4gaGVhZDogICA2MjJkYWQyMDZlM2I4MmM1M2FjYWMxODU3ZjhhNmZmOTcwYzBkMDFiDQo+PiBj
b21taXQ6IDQwMDQ5NjRiMDg1NGYzMjU4MDMyYTcyMzYyN2Q0ODc4ODJhNzQzODAgWzgzLzEwNl0g
ZHJtL3JvY2tjaGlwL3JvY2tjaGlwX2RybV9nZW0uYzogY29udmVydCB0byB1c2Ugdm1fbWFwX3Bh
Z2VzKCkNCj4+IGNvbmZpZzogYXJtNjQtYWxseWVzY29uZmlnIChhdHRhY2hlZCBhcyAuY29uZmln
KQ0KPj4gY29tcGlsZXI6IGFhcmNoNjQtbGludXgtZ2NjIChHQ0MpIDcuNC4wDQo+PiByZXByb2R1
Y2U6DQo+PiAgICAgICAgIHdnZXQgaHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2lu
dGVsL2xrcC10ZXN0cy9tYXN0ZXIvc2Jpbi9tYWtlLmNyb3NzIC1PIH4vYmluL21ha2UuY3Jvc3MN
Cj4+ICAgICAgICAgY2htb2QgK3ggfi9iaW4vbWFrZS5jcm9zcw0KPj4gICAgICAgICBnaXQgY2hl
Y2tvdXQgNDAwNDk2NGIwODU0ZjMyNTgwMzJhNzIzNjI3ZDQ4Nzg4MmE3NDM4MA0KPj4gICAgICAg
ICAjIHNhdmUgdGhlIGF0dGFjaGVkIC5jb25maWcgdG8gbGludXggYnVpbGQgdHJlZQ0KPj4gICAg
ICAgICBHQ0NfVkVSU0lPTj03LjQuMCBtYWtlLmNyb3NzIEFSQ0g9YXJtNjQNCj4+DQo+PiBJZiB5
b3UgZml4IHRoZSBpc3N1ZSwga2luZGx5IGFkZCBmb2xsb3dpbmcgdGFnDQo+PiBSZXBvcnRlZC1i
eToga2J1aWxkIHRlc3Qgcm9ib3QgPGxrcEBpbnRlbC5jb20+DQo+Pg0KPj4gQWxsIGVycm9ycyAo
bmV3IG9uZXMgcHJlZml4ZWQgYnkgPj4pOg0KPj4NCj4+ICAgIGRyaXZlcnMvZ3B1Ly9kcm0vcm9j
a2NoaXAvcm9ja2NoaXBfZHJtX2dlbS5jOiBJbiBmdW5jdGlvbiAncm9ja2NoaXBfZHJtX2dlbV9v
YmplY3RfbW1hcF9pb21tdSc6DQo+Pj4+IGRyaXZlcnMvZ3B1Ly9kcm0vcm9ja2NoaXAvcm9ja2No
aXBfZHJtX2dlbS5jOjIzMDo5OiBlcnJvcjogaW1wbGljaXQgZGVjbGFyYXRpb24gb2YgZnVuY3Rp
b24gJ3ZtX21hcF9wYWdlcyc7IGRpZCB5b3UgbWVhbiAndm1hX3BhZ2VzJz8gWy1XZXJyb3I9aW1w
bGljaXQtZnVuY3Rpb24tZGVjbGFyYXRpb25dDQo+PiAgICAgIHJldHVybiB2bV9tYXBfcGFnZXMo
dm1hLCBya19vYmotPnBhZ2VzLCBjb3VudCk7DQo+PiAgICAgICAgICAgICBefn5+fn5+fn5+fn4N
Cj4+ICAgICAgICAgICAgIHZtYV9wYWdlcw0KPj4gICAgY2MxOiBzb21lIHdhcm5pbmdzIGJlaW5n
IHRyZWF0ZWQgYXMgZXJyb3JzDQo+IExvb2tpbmcgaW50byBodHRwczovL2dpdGh1Yi5jb20vS3dp
Ym9vL2xpbnV4LXJvY2tjaGlwL2Jsb2Ivcm9ja2NoaXAtNS4xLXBhdGNoZXMtZnJvbS01LjMtdjUu
MS41L21tL21lbW9yeS5jDQo+IHZtX21hcF9wYWdlcygpIEFQSSBpcyBtaXNzaW5nLiB2bV9tYXBf
cGFnZXMoKSBtZXJnZWQgaW50byA1LjItcmMxLg0KPiBJcyB0aGUgYmVsb3cgbWF0Y2ggbWVyZ2Vk
IGludG8gIGh0dHBzOi8vZ2l0aHViLmNvbS9Ld2lib28vbGludXgtcm9ja2NoaXAgPw0KPg0KPiBo
dHRwczovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC90b3J2YWxkcy9s
aW51eC5naXQvY29tbWl0Lz9oPXY1LjItcmMxJmlkPWE2NjdkNzQ1NmYxODllMzQyMjcyNWRkZGNk
MDY3NTM3ZmVhYzQ5YzANCg0KVGhhbmtzIGZvciBsb29raW5nLCBJIGRvIG5vdCBrbm93IHdoeSBr
YnVpbGQgdGVzdCByb2JvdCBoYXZlIHN0YXJ0ZWQgYnVpbGRpbmcgZnJvbSBteSBnaXRodWIgdHJl
ZSwNCkkgcHVzaGVkIGEgdjUuMSBicmFuY2ggd2l0aCBjaGVycnktcGlja2VkIGNvbW1pdHMgZnJv
bSB2NS4yK25leHQgYmVmb3JlIEkgZGlkIGEgbG9jYWwgYnVpbGQgdGVzdCBhbmQga2J1aWxkIHRl
c3Qgcm9ib3Qgc3RhcnRlZCBtYWtpbmcgc29tZSB1bm5lY2Vzc2FyeSBub2lzZS4NCldpbGwgYmUg
bW9yZSBjYXJlZnVsIG5vdCB0byBwdXNoIGNvZGUgYmVmb3JlIG1ha2luZyBhIGxvY2FsIHRlc3Qg
YnVpbGQuDQoNClJlZ2FyZHMsDQpKb25hcw0KDQo+PiB2aW0gKzIzMCBkcml2ZXJzL2dwdS8vZHJt
L3JvY2tjaGlwL3JvY2tjaGlwX2RybV9nZW0uYw0KPj4NCj4+ICAgIDIxOQ0KPj4gICAgMjIwICBz
dGF0aWMgaW50IHJvY2tjaGlwX2RybV9nZW1fb2JqZWN0X21tYXBfaW9tbXUoc3RydWN0IGRybV9n
ZW1fb2JqZWN0ICpvYmosDQo+PiAgICAyMjEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSkNCj4+ICAgIDIyMiAg
ew0KPj4gICAgMjIzICAgICAgICAgIHN0cnVjdCByb2NrY2hpcF9nZW1fb2JqZWN0ICpya19vYmog
PSB0b19yb2NrY2hpcF9vYmoob2JqKTsNCj4+ICAgIDIyNCAgICAgICAgICB1bnNpZ25lZCBpbnQg
Y291bnQgPSBvYmotPnNpemUgPj4gUEFHRV9TSElGVDsNCj4+ICAgIDIyNSAgICAgICAgICB1bnNp
Z25lZCBsb25nIHVzZXJfY291bnQgPSB2bWFfcGFnZXModm1hKTsNCj4+ICAgIDIyNg0KPj4gICAg
MjI3ICAgICAgICAgIGlmICh1c2VyX2NvdW50ID09IDApDQo+PiAgICAyMjggICAgICAgICAgICAg
ICAgICByZXR1cm4gLUVOWElPOw0KPj4gICAgMjI5DQo+PiAgPiAyMzAgICAgICAgICAgcmV0dXJu
IHZtX21hcF9wYWdlcyh2bWEsIHJrX29iai0+cGFnZXMsIGNvdW50KTsNCj4+ICAgIDIzMSAgfQ0K
Pj4gICAgMjMyDQo+Pg0KPj4gLS0tDQo+PiAwLURBWSBrZXJuZWwgdGVzdCBpbmZyYXN0cnVjdHVy
ZSAgICAgICAgICAgICAgICBPcGVuIFNvdXJjZSBUZWNobm9sb2d5IENlbnRlcg0KPj4gaHR0cHM6
Ly9saXN0cy4wMS5vcmcvcGlwZXJtYWlsL2tidWlsZC1hbGwgICAgICAgICAgICAgICAgICAgSW50
ZWwgQ29ycG9yYXRpb24NCg0K

