Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F69DC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 16:37:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA359208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 16:37:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="jpcYyBpR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA359208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FA916B0008; Wed, 12 Jun 2019 12:37:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AB046B000A; Wed, 12 Jun 2019 12:37:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 372916B000D; Wed, 12 Jun 2019 12:37:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id C01366B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 12:37:25 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id a1so2796034lfi.16
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 09:37:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:nodisclaimer:content-id
         :content-transfer-encoding:mime-version;
        bh=VQbqrJiISLa4uI+tR3Az4GTEGy3aPlGznHpcP/BLjOw=;
        b=Ia1jrJbaK5FrJ9JjQz82xykt0YZCTi8oWgPu7WM/ofOuILdPhAS5dg+J8+ivX0VR5t
         rjFNXgXoPdy9bOrcS0PprLhoudsuHCYTcuWtrh1LU7cX1S8PhCiX62BM2y1xT0jj1dEy
         KtPMeZe+zil4om0jfgnCNSw/I5Ak3p4g/nUpA+UF7CsDf/88MSLysLpFQtSelZYXTLeo
         O0gyEc662bG2kwa5ZdYxZRmn+3zWBBx4VS1/f9XSeoGrnB7Dq75IwJjmpy8RXU+ENZ2z
         SDNo7a+vXI3+4+qKpPcE6Z3qN7Miiia9J9y2SnDn3IvP76e3d8eLusRbpDA5vf57h1fX
         ZCsQ==
X-Gm-Message-State: APjAAAVgtikDFrFz6BmziN+KWYqaALhe9N7bjxLwraTLRZsa2lAw/EUr
	lCkwIz8tgEGjjxnj2RdATZFaARhNHcDujXSGwfEyzwRTK5DRUBwJT/5Z0vQca4DbVU6j/tubsZs
	xXitRTVRBpsE61Rfhz1w4YQdFANO3t9KMh9/lwWuD//mzwJuEPfNZQ1ukjUXNu86Ukw==
X-Received: by 2002:ac2:5324:: with SMTP id f4mr1139658lfh.156.1560357445053;
        Wed, 12 Jun 2019 09:37:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtuLFDl1x/lSxGyuECl9afm1eaMm6ivsTAFKKDVPVNO2WUnDpZuYjZhp7T9ms9NMcgZ0Gi
X-Received: by 2002:ac2:5324:: with SMTP id f4mr1139622lfh.156.1560357444260;
        Wed, 12 Jun 2019 09:37:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560357444; cv=none;
        d=google.com; s=arc-20160816;
        b=LDpmD2sQKHSbQ7xtj0kGsCxZB/G66h0Vhxfi3p2YwQ2g0VEpdOeYKCnyWN7MnEKJdb
         2qeoL7pEJ9ZteUJcGyX7blPxdjwVyA1z9DLDK+k1Wc7w974RiCi2hcPlc6CSDlY+YnvP
         ATPFodRzfVlWufbtq97BLxXHwQJxYhyxD6/ggMsGmD9ft/xXm8Iny5dPIZkYZjgi7dAs
         kXAJ2N12lDHm1fygV5zfRWuiiYCwsh4X5dxbArvbwxue6pQ0MJvoj/ldhxv9e/0lA+8U
         IsWigKUK8s+0WK5Jva6cwskPsnTH6z0LmSO6nEi4N7zN8KTdQ1sCTk07F4LMvF3Nd7ts
         XDyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:nodisclaimer
         :user-agent:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from
         :dkim-signature;
        bh=VQbqrJiISLa4uI+tR3Az4GTEGy3aPlGznHpcP/BLjOw=;
        b=Fr9NT5YX+W91rcT8s4klQ9pE071VG/FFk6eFuDKFo/K9eGWdZHvSW2WxT/rb8RVg5r
         eBAakcyJ4udvm1AjV99Hlp/smps68GGlLlMUGwqSmXAC6vQLH0mXLaP+YtlLxqql+oie
         mAtEOJ2xR1Pm8kvbYHxeGfFvsOJOYG9BFB8UdAXfh2ZjqvgrCG6ACPZ+koVMPxQI9tKY
         gX1vs3650exjmqjXvXyZ6QPybB2RTCrx2VUx9KHO8A3zsF1q7I+yOjOALOmHOiYSB5Jt
         NPP5+ElFEo36iXXVSN+W7HZvgALDGtCKgqh6J+068eeWgn3asfVwYRClUiXU5lnz5jmU
         2ySw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector2-armh-onmicrosoft-com header.b=jpcYyBpR;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.7.74 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70074.outbound.protection.outlook.com. [40.107.7.74])
        by mx.google.com with ESMTPS id g8si13803114lfh.119.2019.06.12.09.37.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 09:37:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.7.74 as permitted sender) client-ip=40.107.7.74;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector2-armh-onmicrosoft-com header.b=jpcYyBpR;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.7.74 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VQbqrJiISLa4uI+tR3Az4GTEGy3aPlGznHpcP/BLjOw=;
 b=jpcYyBpRvXHXGJW+ds2BHG3uEO6ViklqATgjygElrZZQVfNMmzW5f33jWollfbLypTF2YbxuH3pQ4gqTMoYCFSKKMDwOlNSvtYgdJo/tbbmqXalCT7NmQelg6T6M6qlpFQJ6RKYNwvh0Sk8e6mzQbzgvgYmGWeTAvXXwRR3FOAE=
Received: from VE1PR08MB4637.eurprd08.prod.outlook.com (10.255.27.14) by
 VE1PR08MB4895.eurprd08.prod.outlook.com (10.255.113.212) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.15; Wed, 12 Jun 2019 16:37:20 +0000
Received: from VE1PR08MB4637.eurprd08.prod.outlook.com
 ([fe80::6574:1efb:6972:2b37]) by VE1PR08MB4637.eurprd08.prod.outlook.com
 ([fe80::6574:1efb:6972:2b37%6]) with mapi id 15.20.1965.017; Wed, 12 Jun 2019
 16:37:20 +0000
From: Szabolcs Nagy <Szabolcs.Nagy@arm.com>
To: Vincenzo Frascino <Vincenzo.Frascino@arm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-doc@vger.kernel.org"
	<linux-doc@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: nd <nd@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon
	<Will.Deacon@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Alexander
 Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v4 2/2] arm64: Relax
 Documentation/arm64/tagged-pointers.txt
Thread-Topic: [PATCH v4 2/2] arm64: Relax
 Documentation/arm64/tagged-pointers.txt
Thread-Index: AQHVIS/qgxSPAZqYS0apbOMTIFAdLaaYN9IA
Date: Wed, 12 Jun 2019 16:37:20 +0000
Message-ID: <ebe4fffd-c8a5-35d4-9370-a6573b2a7c87@arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-3-vincenzo.frascino@arm.com>
In-Reply-To: <20190612142111.28161-3-vincenzo.frascino@arm.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
x-originating-ip: [217.140.106.51]
x-clientproxiedby: LO2P265CA0101.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:c::17) To VE1PR08MB4637.eurprd08.prod.outlook.com
 (2603:10a6:802:b1::14)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Szabolcs.Nagy@arm.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3fbc98d2-bb72-4fbf-3bbe-08d6ef543d41
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VE1PR08MB4895;
x-ms-traffictypediagnostic: VE1PR08MB4895:
nodisclaimer: True
x-microsoft-antispam-prvs:
 <VE1PR08MB4895AD6CA6AB833ECD306246EDEC0@VE1PR08MB4895.eurprd08.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0066D63CE6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(39860400002)(396003)(346002)(376002)(136003)(189003)(199004)(99286004)(64126003)(6486002)(81166006)(65826007)(7736002)(53936002)(2906002)(66446008)(14444005)(6512007)(256004)(8676002)(66946007)(2201001)(64756008)(229853002)(478600001)(66556008)(14454004)(66476007)(6436002)(305945005)(8936002)(2501003)(5660300002)(72206003)(81156014)(71190400001)(6506007)(58126008)(186003)(11346002)(316002)(2616005)(102836004)(386003)(110136005)(44832011)(54906003)(73956011)(52116002)(4326008)(486006)(71200400001)(65956001)(25786009)(446003)(476003)(53546011)(31696002)(36756003)(6246003)(66066001)(68736007)(31686004)(65806001)(26005)(6116002)(3846002)(86362001)(76176011);DIR:OUT;SFP:1101;SCL:1;SRVR:VE1PR08MB4895;H:VE1PR08MB4637.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 ArZcTyYDkh4Z7xUs60YEzHWJP6LZxH/M83BeKyobfcMkD0rM0j0OXX38PHpnekSqaNpVHu1m0FnQTPiHp83NqC7kqJyimE1E3LerE5teGYkqeCW6d6q/EhbG11Ugfu+fobIML+DQKY+2ETWI2x36APPL6dI91zs3D1o7GZCtAWI+BXupLe6cLLNbC8v8ZMgYt3E5HYzoGSxdHGgAFRlo02PZaJOPH8UT7Lf7eG5oQQOHV/NHdGyb9l64oGqYqjqEX9nQ7al00lDw0cm0aRvGr4kNr7HToGH/HwA1X1RHtRMFVfA1spzf2jV+Oq8z73p6wndUHbXsm4ZAYyxU65Kmb7ch9J8Eld5eALaR+i/1foPVNnp+MWJedToB/ixFM7nI5QQt4qc8uOn/l+1y5mnVa7TZChVe8r8zZdbNSrvHajo=
Content-Type: text/plain; charset="utf-8"
Content-ID: <BA99E85AC8B5C34B87124BD326392332@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3fbc98d2-bb72-4fbf-3bbe-08d6ef543d41
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Jun 2019 16:37:20.6828
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Szabolcs.Nagy@arm.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VE1PR08MB4895
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMTIvMDYvMjAxOSAxNToyMSwgVmluY2Vuem8gRnJhc2Npbm8gd3JvdGU6DQo+IE9uIGFybTY0
IHRoZSBUQ1JfRUwxLlRCSTAgYml0IGhhcyBiZWVuIGFsd2F5cyBlbmFibGVkIGhlbmNlDQo+IHRo
ZSB1c2Vyc3BhY2UgKEVMMCkgaXMgYWxsb3dlZCB0byBzZXQgYSBub24temVybyB2YWx1ZSBpbiB0
aGUNCj4gdG9wIGJ5dGUgYnV0IHRoZSByZXN1bHRpbmcgcG9pbnRlcnMgYXJlIG5vdCBhbGxvd2Vk
IGF0IHRoZQ0KPiB1c2VyLWtlcm5lbCBzeXNjYWxsIEFCSSBib3VuZGFyeS4NCj4gDQo+IFdpdGgg
dGhlIHJlbGF4ZWQgQUJJIHByb3Bvc2VkIGluIHRoaXMgc2V0LCBpdCBpcyBub3cgcG9zc2libGUg
dG8gcGFzcw0KPiB0YWdnZWQgcG9pbnRlcnMgdG8gdGhlIHN5c2NhbGxzLCB3aGVuIHRoZXNlIHBv
aW50ZXJzIGFyZSBpbiBtZW1vcnkNCj4gcmFuZ2VzIG9idGFpbmVkIGJ5IGFuIGFub255bW91cyAo
TUFQX0FOT05ZTU9VUykgbW1hcCgpLg0KPiANCj4gUmVsYXggdGhlIHJlcXVpcmVtZW50cyBkZXNj
cmliZWQgaW4gdGFnZ2VkLXBvaW50ZXJzLnR4dCB0byBiZSBjb21wbGlhbnQNCj4gd2l0aCB0aGUg
YmVoYXZpb3VycyBndWFyYW50ZWVkIGJ5IHRoZSBBUk02NCBUYWdnZWQgQWRkcmVzcyBBQkkuDQo+
IA0KPiBDYzogQ2F0YWxpbiBNYXJpbmFzIDxjYXRhbGluLm1hcmluYXNAYXJtLmNvbT4NCj4gQ2M6
IFdpbGwgRGVhY29uIDx3aWxsLmRlYWNvbkBhcm0uY29tPg0KPiBDQzogQW5kcmV5IEtvbm92YWxv
diA8YW5kcmV5a252bEBnb29nbGUuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBWaW5jZW56byBGcmFz
Y2lubyA8dmluY2Vuem8uZnJhc2Npbm9AYXJtLmNvbT4NCj4gLS0tDQo+ICBEb2N1bWVudGF0aW9u
L2FybTY0L3RhZ2dlZC1wb2ludGVycy50eHQgfCAyMyArKysrKysrKysrKysrKysrLS0tLS0tLQ0K
PiAgMSBmaWxlIGNoYW5nZWQsIDE2IGluc2VydGlvbnMoKyksIDcgZGVsZXRpb25zKC0pDQo+IA0K
PiBkaWZmIC0tZ2l0IGEvRG9jdW1lbnRhdGlvbi9hcm02NC90YWdnZWQtcG9pbnRlcnMudHh0IGIv
RG9jdW1lbnRhdGlvbi9hcm02NC90YWdnZWQtcG9pbnRlcnMudHh0DQo+IGluZGV4IGEyNWE5OWU4
MmJiMS4uZGI1OGE3ZTk1ODA1IDEwMDY0NA0KPiAtLS0gYS9Eb2N1bWVudGF0aW9uL2FybTY0L3Rh
Z2dlZC1wb2ludGVycy50eHQNCj4gKysrIGIvRG9jdW1lbnRhdGlvbi9hcm02NC90YWdnZWQtcG9p
bnRlcnMudHh0DQo+IEBAIC0xOCw3ICsxOCw4IEBAIFBhc3NpbmcgdGFnZ2VkIGFkZHJlc3NlcyB0
byB0aGUga2VybmVsDQo+ICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0K
PiAgDQo+ICBBbGwgaW50ZXJwcmV0YXRpb24gb2YgdXNlcnNwYWNlIG1lbW9yeSBhZGRyZXNzZXMg
YnkgdGhlIGtlcm5lbCBhc3N1bWVzDQo+IC1hbiBhZGRyZXNzIHRhZyBvZiAweDAwLg0KPiArYW4g
YWRkcmVzcyB0YWcgb2YgMHgwMCwgdW5sZXNzIHRoZSB1c2Vyc3BhY2Ugb3B0cy1pbiB0aGUgQVJN
NjQgVGFnZ2VkDQo+ICtBZGRyZXNzIEFCSSB2aWEgdGhlIFBSX1NFVF9UQUdHRURfQUREUl9DVFJM
IHByY3RsKCkuDQo+ICANCj4gIFRoaXMgaW5jbHVkZXMsIGJ1dCBpcyBub3QgbGltaXRlZCB0bywg
YWRkcmVzc2VzIGZvdW5kIGluOg0KPiAgDQo+IEBAIC0zMSwxOCArMzIsMjMgQEAgVGhpcyBpbmNs
dWRlcywgYnV0IGlzIG5vdCBsaW1pdGVkIHRvLCBhZGRyZXNzZXMgZm91bmQgaW46DQo+ICAgLSB0
aGUgZnJhbWUgcG9pbnRlciAoeDI5KSBhbmQgZnJhbWUgcmVjb3JkcywgZS5nLiB3aGVuIGludGVy
cHJldGluZw0KPiAgICAgdGhlbSB0byBnZW5lcmF0ZSBhIGJhY2t0cmFjZSBvciBjYWxsIGdyYXBo
Lg0KPiAgDQo+IC1Vc2luZyBub24temVybyBhZGRyZXNzIHRhZ3MgaW4gYW55IG9mIHRoZXNlIGxv
Y2F0aW9ucyBtYXkgcmVzdWx0IGluIGFuDQo+IC1lcnJvciBjb2RlIGJlaW5nIHJldHVybmVkLCBh
IChmYXRhbCkgc2lnbmFsIGJlaW5nIHJhaXNlZCwgb3Igb3RoZXIgbW9kZXMNCj4gLW9mIGZhaWx1
cmUuDQo+ICtVc2luZyBub24temVybyBhZGRyZXNzIHRhZ3MgaW4gYW55IG9mIHRoZXNlIGxvY2F0
aW9ucyB3aGVuIHRoZQ0KPiArdXNlcnNwYWNlIGFwcGxpY2F0aW9uIGRpZCBub3Qgb3B0LWluIHRv
IHRoZSBBUk02NCBUYWdnZWQgQWRkcmVzcyBBQkksDQo+ICttYXkgcmVzdWx0IGluIGFuIGVycm9y
IGNvZGUgYmVpbmcgcmV0dXJuZWQsIGEgKGZhdGFsKSBzaWduYWwgYmVpbmcgcmFpc2VkLA0KPiAr
b3Igb3RoZXIgbW9kZXMgb2YgZmFpbHVyZS4NCj4gIA0KPiAtRm9yIHRoZXNlIHJlYXNvbnMsIHBh
c3Npbmcgbm9uLXplcm8gYWRkcmVzcyB0YWdzIHRvIHRoZSBrZXJuZWwgdmlhDQo+IC1zeXN0ZW0g
Y2FsbHMgaXMgZm9yYmlkZGVuLCBhbmQgdXNpbmcgYSBub24temVybyBhZGRyZXNzIHRhZyBmb3Ig
c3AgaXMNCj4gLXN0cm9uZ2x5IGRpc2NvdXJhZ2VkLg0KPiArRm9yIHRoZXNlIHJlYXNvbnMsIHdo
ZW4gdGhlIHVzZXJzcGFjZSBhcHBsaWNhdGlvbiBkaWQgbm90IG9wdC1pbiwgcGFzc2luZw0KPiAr
bm9uLXplcm8gYWRkcmVzcyB0YWdzIHRvIHRoZSBrZXJuZWwgdmlhIHN5c3RlbSBjYWxscyBpcyBm
b3JiaWRkZW4sIGFuZCB1c2luZw0KPiArYSBub24temVybyBhZGRyZXNzIHRhZyBmb3Igc3AgaXMg
c3Ryb25nbHkgZGlzY291cmFnZWQuDQo+ICANCj4gIFByb2dyYW1zIG1haW50YWluaW5nIGEgZnJh
bWUgcG9pbnRlciBhbmQgZnJhbWUgcmVjb3JkcyB0aGF0IHVzZSBub24temVybw0KPiAgYWRkcmVz
cyB0YWdzIG1heSBzdWZmZXIgaW1wYWlyZWQgb3IgaW5hY2N1cmF0ZSBkZWJ1ZyBhbmQgcHJvZmls
aW5nDQo+ICB2aXNpYmlsaXR5Lg0KPiAgDQo+ICtBIGRlZmluaXRpb24gb2YgdGhlIG1lYW5pbmcg
b2YgQVJNNjQgVGFnZ2VkIEFkZHJlc3MgQUJJIGFuZCBvZiB0aGUNCj4gK2d1YXJhbnRlZXMgdGhh
dCB0aGUgQUJJIHByb3ZpZGVzIHdoZW4gdGhlIHVzZXJzcGFjZSBvcHRzLWluIHZpYSBwcmN0bCgp
DQo+ICtjYW4gYmUgZm91bmQgaW46IERvY3VtZW50YXRpb24vYXJtNjQvdGFnZ2VkLWFkZHJlc3Mt
YWJpLnR4dC4NCj4gKw0KDQpPSy4NCg0KPiAgDQo+ICBQcmVzZXJ2aW5nIHRhZ3MNCj4gIC0tLS0t
LS0tLS0tLS0tLQ0KPiBAQCAtNTcsNiArNjMsOSBAQCBiZSBwcmVzZXJ2ZWQuDQo+ICBUaGUgYXJj
aGl0ZWN0dXJlIHByZXZlbnRzIHRoZSB1c2Ugb2YgYSB0YWdnZWQgUEMsIHNvIHRoZSB1cHBlciBi
eXRlIHdpbGwNCj4gIGJlIHNldCB0byBhIHNpZ24tZXh0ZW5zaW9uIG9mIGJpdCA1NSBvbiBleGNl
cHRpb24gcmV0dXJuLg0KPiAgDQo+ICtUaGlzIGJlaGF2aW91cnMgYXJlIHByZXNlcnZlZCBldmVu
IHdoZW4gdGhlIHRoZSB1c2Vyc3BhY2Ugb3B0cy1pbiB0aGUgQVJNNjQNCg0KdGhlc2UgYmVoYXZp
b3Vycy4NCg0KPiArVGFnZ2VkIEFkZHJlc3MgQUJJIHZpYSB0aGUgUFJfU0VUX1RBR0dFRF9BRERS
X0NUUkwgcHJjdGwoKS4NCj4gKw0KPiAgDQo+ICBPdGhlciBjb25zaWRlcmF0aW9ucw0KPiAgLS0t
LS0tLS0tLS0tLS0tLS0tLS0NCj4gDQoNCg==

