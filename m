Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C044C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 19:59:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DA002175B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 19:59:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="MzjrPkRa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DA002175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E27B26B0003; Thu, 21 Mar 2019 15:59:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD4DE6B0006; Thu, 21 Mar 2019 15:59:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC5E96B0007; Thu, 21 Mar 2019 15:59:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDD66B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 15:59:46 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id 9so70358ita.8
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 12:59:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Oymc+c3375KrBDt3E/oDYcoTNuchjDcsZdrqKVZkSuU=;
        b=ha+MHtoOQRy2Rkoo/d9Nc0TYx0IsS7F7SDaiNsbprzdpk1I5ctJ9OCoWq5mIGGMbVZ
         pRtcU0ZcOqwGvFCvXGMXVg6tb7ewHXm5ThmbM4O8j5jgdz6NaLGwBYgfkqRdRPPZSSIk
         tE4Iuql9B19bZlc9ND29ePap0I3P3nFZr7cthNavjlc8rfo3htR/1WFM1nzL/RoWxzHq
         UWeNaEJbTdn7DHbbWEm+s8ROy4VWTfFpehw+nfX4kdVKT6vDgcUSxGGx895lM0eg3PrF
         myCmuRdgpogfN7POSsYdn5RCdmz6dT5+e/d8yLrWYhdts9tzHMurjByUj3BdfGF+FIGK
         bxZw==
X-Gm-Message-State: APjAAAWAzzGUsQgWpH+jeC5y7eEhefnRfjCcf2L0e4bZ/GxqSvpVJJhU
	HMsZK8HOYmBhw3LFPmDPC6f9M9MVBWhM9gih41QWcrBu55CdGClmY43BygX4eKsvTXkJIVCXyGH
	v+BNlWN/HP9cA+6Qk9sEre0ILZfTAtfw9ArCIhOSHNCdjpFOpzg9ICFx/EyDt/JZdTQ==
X-Received: by 2002:a24:9dca:: with SMTP id f193mr161268itd.72.1553198386337;
        Thu, 21 Mar 2019 12:59:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcwvSS6dGegbZCzkKmRYZVFTMJ4usajSoR2ejV2ENGOUZudoNW+ZbBi//dc6jPwR7HB3lD
X-Received: by 2002:a24:9dca:: with SMTP id f193mr161227itd.72.1553198385452;
        Thu, 21 Mar 2019 12:59:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553198385; cv=none;
        d=google.com; s=arc-20160816;
        b=TO9j4iE/miCSqmVQIt5NsSMunEG0eZbAF/s8Zwle5jupRydVjUDojFMxYENpDTQx++
         uWgwHZGw1GoMdnX/qe+Kt0B+iWycznqfOXEQt6LO1Pi7mepRzCd6NZBcLB8FJjLb8cNi
         uMsQqX2TQG1UV+KOmpm1P/+oPV7j+WYXcab8hadyZ9QgXjw0ECew7X68pLBKnZ3j0DJw
         F20kDHODaUzvUdqjre9MUbnKswqY7AHAA4lPLd93w87HbCQH7O/M3a8uF9OWHOFWkL1Y
         w4CNRkCCVh+hXGy6yAjxL/Ta3Rkdu45QQ2qrpNFNNlIT/ofINffHjvGEZUmtMS3hoUiC
         gvkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Oymc+c3375KrBDt3E/oDYcoTNuchjDcsZdrqKVZkSuU=;
        b=mf7fGJVkGE7aCfr7wQC/MIPnn2oYGwyUM6MrM1q/zQ1Os/LJazmmXVk+rhb48hodjc
         u+FbjNYiw74Bs14qxWs7+SZKzDGUzXcZsUzctojRDypa8SqRLe5gP8dec4DNOF3AMEj5
         LMD/nMg1ba3bUA1GSVW9nKbsybF7VukT5eiyfMs7rxYNT293BC+IGuc4OPr/kUI4TD1U
         wbWnjYLOgsnpK7ZbHNqjW0xRqCmq6V1RRT1feWTkyb3UTfz7HmAMOWYlAGSjIqSVLHx5
         3ywber33QxAGkF3o8pkXEJZhrDSyzLsX3Ia4fuiWYe/MuNu/6EDzbLfZM9YO9e1wvLFp
         1h/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=MzjrPkRa;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.75.81 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-eopbgr750081.outbound.protection.outlook.com. [40.107.75.81])
        by mx.google.com with ESMTPS id z14si2740483ioj.131.2019.03.21.12.59.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Mar 2019 12:59:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.75.81 as permitted sender) client-ip=40.107.75.81;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=MzjrPkRa;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.75.81 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Oymc+c3375KrBDt3E/oDYcoTNuchjDcsZdrqKVZkSuU=;
 b=MzjrPkRaqGjt/s11Bd/B3OIa/vy4VejrmY4LRTnab4+HBrdSVEEwrzYT230xquigpgMt9GTE95oKnrv6p76pw58PF5kHvuVZmYPBv3TBnI1ygMA/fXERHoAHzMKxGiXHCV8jo4iJmwm+lL0EZEoR/O4y+rCpK9sAB3V6AQmQiNs=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6607.namprd05.prod.outlook.com (20.178.248.157) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.13; Thu, 21 Mar 2019 19:59:35 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad%6]) with mapi id 15.20.1750.010; Thu, 21 Mar 2019
 19:59:35 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: "jglisse@redhat.com" <jglisse@redhat.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>, "willy@infradead.org"
	<willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"jrdr.linux@gmail.com" <jrdr.linux@gmail.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>, Linux-graphics-maintainer
	<Linux-graphics-maintainer@vmware.com>, "mhocko@suse.com" <mhocko@suse.com>,
	"ying.huang@intel.com" <ying.huang@intel.com>, "riel@surriel.com"
	<riel@surriel.com>
Subject: Re: [RFC PATCH RESEND 2/3] mm: Add an apply_to_pfn_range interface
Thread-Topic: [RFC PATCH RESEND 2/3] mm: Add an apply_to_pfn_range interface
Thread-Index: AQHU3+kl9xNhc0w2DU+KAotZ5mJTV6YWGrMAgABmroA=
Date: Thu, 21 Mar 2019 19:59:35 +0000
Message-ID: <c9d05087a0fb9002145aa2f7c58552615a694e9e.camel@vmware.com>
References: <20190321132140.114878-1-thellstrom@vmware.com>
	 <20190321132140.114878-3-thellstrom@vmware.com>
	 <20190321135202.GC2904@redhat.com>
In-Reply-To: <20190321135202.GC2904@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-originating-ip: [155.4.205.56]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bc5ef6d6-6853-4e25-5e7d-08d6ae37bdf1
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:MN2PR05MB6607;
x-ms-traffictypediagnostic: MN2PR05MB6607:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB6607730484E46F383140E00EA1420@MN2PR05MB6607.namprd05.prod.outlook.com>
x-forefront-prvs: 0983EAD6B2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(376002)(396003)(346002)(366004)(39860400002)(189003)(199004)(186003)(14454004)(8936002)(71200400001)(71190400001)(6486002)(229853002)(11346002)(7416002)(2616005)(476003)(26005)(486006)(36756003)(316002)(118296001)(478600001)(6436002)(8676002)(6512007)(81156014)(81166006)(53936002)(14444005)(256004)(105586002)(5640700003)(54906003)(1730700003)(4326008)(6116002)(66574012)(6246003)(66066001)(5660300002)(2351001)(3846002)(106356001)(6916009)(25786009)(305945005)(7736002)(102836004)(99286004)(2906002)(76176011)(446003)(68736007)(97736004)(2501003)(6506007)(86362001);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6607;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 8EIANF2hfm49t+FhHSNJl9RIoAUBEMxDMDPS+Ryv8AYLuJtZe9bYbaP+HgvQIMSC7yNCEdRgR82Gwsg0L+z7w4UACSwtbxh0qfMFUtAxz5T/1vwfNcFpfbLT7SRqV3FeY59+BtuCGDSzyhdN0odAxtyS52/mIWAVSQqVNH0HazAV3/Vb5IomHEaVby8WIiUuxCMTRwi75RNfXPK2hPTnyH7xj4VvnfcV+wn8AD2JVWYTzp/ELU6v6TBODXdLyriclhfwyX6ajFBOQcO1nKk0YmPjl5RSlXiyMasVScdyiT89HXiIKIv+tR3nllpYGFQC+uV90+7u+qnCQeyU5q6qFmqEtclrZ/3XdjA1Khc+KC6397HSEch0cVtCRXrUhePxeUaUluEkDeEm2kwle9TPIaAhrganGmTJIl8szWR7mEo=
Content-Type: text/plain; charset="utf-8"
Content-ID: <AEFDAD13C097844EA7831CD878FD3FBB@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bc5ef6d6-6853-4e25-5e7d-08d6ae37bdf1
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Mar 2019 19:59:35.1939
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6607
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCAyMDE5LTAzLTIxIGF0IDA5OjUyIC0wNDAwLCBKZXJvbWUgR2xpc3NlIHdyb3RlOg0K
PiBPbiBUaHUsIE1hciAyMSwgMjAxOSBhdCAwMToyMjozNVBNICswMDAwLCBUaG9tYXMgSGVsbHN0
cm9tIHdyb3RlOg0KPiA+IFRoaXMgaXMgYmFzaWNhbGx5IGFwcGx5X3RvX3BhZ2VfcmFuZ2Ugd2l0
aCBhZGRlZCBmdW5jdGlvbmFsaXR5Og0KPiA+IEFsbG9jYXRpbmcgbWlzc2luZyBwYXJ0cyBvZiB0
aGUgcGFnZSB0YWJsZSBiZWNvbWVzIG9wdGlvbmFsLCB3aGljaA0KPiA+IG1lYW5zIHRoYXQgdGhl
IGZ1bmN0aW9uIGNhbiBiZSBndWFyYW50ZWVkIG5vdCB0byBlcnJvciBpZg0KPiA+IGFsbG9jYXRp
b24NCj4gPiBpcyBkaXNhYmxlZC4gQWxzbyBwYXNzaW5nIG9mIHRoZSBjbG9zdXJlIHN0cnVjdCBh
bmQgY2FsbGJhY2sNCj4gPiBmdW5jdGlvbg0KPiA+IGJlY29tZXMgZGlmZmVyZW50IGFuZCBtb3Jl
IGluIGxpbmUgd2l0aCBob3cgdGhpbmdzIGFyZSBkb25lDQo+ID4gZWxzZXdoZXJlLg0KPiA+IA0K
PiA+IEZpbmFsbHkgd2Uga2VlcCBhcHBseV90b19wYWdlX3JhbmdlIGFzIGEgd3JhcHBlciBhcm91
bmQNCj4gPiBhcHBseV90b19wZm5fcmFuZ2UNCj4gDQo+IFRoZSBhcHBseV90b19wYWdlX3Jhbmdl
KCkgaXMgZGFuZ2Vyb3VzIEFQSSBpdCBkb2VzIG5vdCBmb2xsb3cgb3RoZXINCj4gbW0gcGF0dGVy
bnMgbGlrZSBtbXUgbm90aWZpZXIuIEl0IGlzIHN1cHBvc2UgdG8gYmUgdXNlIGluIGFyY2ggY29k
ZQ0KPiBvciB2bWFsbG9jIG9yIHNpbWlsYXIgdGhpbmcgYnV0IG5vdCBpbiByZWd1bGFyIGRyaXZl
ciBjb2RlLiBJIHNlZQ0KPiBpdCBoYXMgY3JlcHQgb3V0IG9mIHRoaXMgYW5kIGlzIGJlaW5nIHVz
ZSBieSBmZXcgZGV2aWNlIGRyaXZlci4gSSBhbQ0KPiBub3Qgc3VyZSB3ZSBzaG91bGQgZW5jb3Vy
YWdlIHRoYXQuDQoNCkkgY2FuIGNlcnRhaW5seSByZW1vdmUgdGhlIEVYUE9SVCBvZiB0aGUgbmV3
IGFwcGx5X3RvX3Bmbl9yYW5nZSgpIHdoaWNoDQp3aWxsIG1ha2Ugc3VyZSBpdHMgdXNlIHN0YXlz
IHdpdGhpbiB0aGUgbW0gY29kZS4gSSBkb24ndCBleHBlY3QgYW55DQphZGRpdGlvbmFsIHVzYWdl
IGV4Y2VwdCBmb3IgdGhlIHR3byBhZGRyZXNzLXNwYWNlIHV0aWxpdGllcy4NCg0KSSdtIGxvb2tp
bmcgZm9yIGV4YW1wbGVzIHRvIHNlZSBob3cgaXQgY291bGQgYmUgbW9yZSBpbiBsaW5lIHdpdGgg
dGhlDQpyZXN0IG9mIHRoZSBtbSBjb2RlLiBUaGUgbWFpbiBkaWZmZXJlbmNlIGZyb20gdGhlIHBh
dHRlcm4gaW4sIGZvcg0KZXhhbXBsZSwgcGFnZV9ta2NsZWFuKCkgc2VlbXMgdG8gYmUgdGhhdCBp
dCdzIGxhY2tpbmcgdGhlDQptbXVfbm90aWZpZXJfaW52YWxpZGF0ZV9zdGFydCgpIGFuZCBtbXVf
bm90aWZpZXJfaW52YWxpZGF0ZV9lbmQoKT8NClBlcmhhcHMgdGhlIGludGVudGlvbiBpcyB0byBo
YXZlIHRoZSBwdGUgbGVhZiBmdW5jdGlvbnMgbm90aWZ5IG9uIHB0ZQ0KdXBkYXRlcz8gSG93IGRv
ZXMgdGhpcyByZWxhdGUgdG8gYXJjaF9lbnRlcl9sYXp5X21tdSgpIHdoaWNoIGlzIGNhbGxlZA0K
b3V0c2lkZSBvZiB0aGUgcGFnZSB0YWJsZSBsb2Nrcz8gVGhlIGRvY3VtZW50YXRpb24gYXBwZWFy
cyBhIGJpdA0Kc2NhcmNlLi4uDQoNCj4gDQo+ID4gQ2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGlu
dXgtZm91bmRhdGlvbi5vcmc+DQo+ID4gQ2M6IE1hdHRoZXcgV2lsY294IDx3aWxseUBpbmZyYWRl
YWQub3JnPg0KPiA+IENjOiBXaWxsIERlYWNvbiA8d2lsbC5kZWFjb25AYXJtLmNvbT4NCj4gPiBD
YzogUGV0ZXIgWmlqbHN0cmEgPHBldGVyekBpbmZyYWRlYWQub3JnPg0KPiA+IENjOiBSaWsgdmFu
IFJpZWwgPHJpZWxAc3VycmllbC5jb20+DQo+ID4gQ2M6IE1pbmNoYW4gS2ltIDxtaW5jaGFuQGtl
cm5lbC5vcmc+DQo+ID4gQ2M6IE1pY2hhbCBIb2NrbyA8bWhvY2tvQHN1c2UuY29tPg0KPiA+IENj
OiBIdWFuZyBZaW5nIDx5aW5nLmh1YW5nQGludGVsLmNvbT4NCj4gPiBDYzogU291cHRpY2sgSm9h
cmRlciA8anJkci5saW51eEBnbWFpbC5jb20+DQo+ID4gQ2M6ICJKw6lyw7RtZSBHbGlzc2UiIDxq
Z2xpc3NlQHJlZGhhdC5jb20+DQo+ID4gQ2M6IGxpbnV4LW1tQGt2YWNrLm9yZw0KPiA+IENjOiBs
aW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+ID4gU2lnbmVkLW9mZi1ieTogVGhvbWFzIEhl
bGxzdHJvbSA8dGhlbGxzdHJvbUB2bXdhcmUuY29tPg0KPiA+IC0tLQ0KPiA+ICBpbmNsdWRlL2xp
bnV4L21tLmggfCAgMTAgKysrKw0KPiA+ICBtbS9tZW1vcnkuYyAgICAgICAgfCAxMjEgKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrLS0tLS0tDQo+ID4gLS0tLS0tDQo+ID4gIDIgZmls
ZXMgY2hhbmdlZCwgOTkgaW5zZXJ0aW9ucygrKSwgMzIgZGVsZXRpb25zKC0pDQo+ID4gDQo+ID4g
ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvbW0uaCBiL2luY2x1ZGUvbGludXgvbW0uaA0KPiA+
IGluZGV4IDgwYmI2NDA4ZmU3My4uYjdkZDRkZGQ2ZWZiIDEwMDY0NA0KPiA+IC0tLSBhL2luY2x1
ZGUvbGludXgvbW0uaA0KPiA+ICsrKyBiL2luY2x1ZGUvbGludXgvbW0uaA0KPiA+IEBAIC0yNjMy
LDYgKzI2MzIsMTYgQEAgdHlwZWRlZiBpbnQgKCpwdGVfZm5fdCkocHRlX3QgKnB0ZSwNCj4gPiBw
Z3RhYmxlX3QgdG9rZW4sIHVuc2lnbmVkIGxvbmcgYWRkciwNCj4gPiAgZXh0ZXJuIGludCBhcHBs
eV90b19wYWdlX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCB1bnNpZ25lZCBsb25nDQo+ID4g
YWRkcmVzcywNCj4gPiAgCQkJICAgICAgIHVuc2lnbmVkIGxvbmcgc2l6ZSwgcHRlX2ZuX3QgZm4s
IHZvaWQNCj4gPiAqZGF0YSk7DQo+ID4gIA0KPiA+ICtzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5Ow0K
PiA+ICt0eXBlZGVmIGludCAoKnB0ZXJfZm5fdCkocHRlX3QgKnB0ZSwgcGd0YWJsZV90IHRva2Vu
LCB1bnNpZ25lZA0KPiA+IGxvbmcgYWRkciwNCj4gPiArCQkJIHN0cnVjdCBwZm5fcmFuZ2VfYXBw
bHkgKmNsb3N1cmUpOw0KPiA+ICtzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5IHsNCj4gPiArCXN0cnVj
dCBtbV9zdHJ1Y3QgKm1tOw0KPiA+ICsJcHRlcl9mbl90IHB0ZWZuOw0KPiA+ICsJdW5zaWduZWQg
aW50IGFsbG9jOw0KPiA+ICt9Ow0KPiA+ICtleHRlcm4gaW50IGFwcGx5X3RvX3Bmbl9yYW5nZShz
dHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpjbG9zdXJlLA0KPiA+ICsJCQkgICAgICB1bnNpZ25lZCBs
b25nIGFkZHJlc3MsIHVuc2lnbmVkIGxvbmcNCj4gPiBzaXplKTsNCj4gPiAgDQo+ID4gICNpZmRl
ZiBDT05GSUdfUEFHRV9QT0lTT05JTkcNCj4gPiAgZXh0ZXJuIGJvb2wgcGFnZV9wb2lzb25pbmdf
ZW5hYmxlZCh2b2lkKTsNCj4gPiBkaWZmIC0tZ2l0IGEvbW0vbWVtb3J5LmMgYi9tbS9tZW1vcnku
Yw0KPiA+IGluZGV4IGRjZDgwMzEzY2YxMC4uMGZlYjcxOTFjMmQyIDEwMDY0NA0KPiA+IC0tLSBh
L21tL21lbW9yeS5jDQo+ID4gKysrIGIvbW0vbWVtb3J5LmMNCj4gPiBAQCAtMTkzOCwxOCArMTkz
OCwxNyBAQCBpbnQgdm1faW9tYXBfbWVtb3J5KHN0cnVjdCB2bV9hcmVhX3N0cnVjdA0KPiA+ICp2
bWEsIHBoeXNfYWRkcl90IHN0YXJ0LCB1bnNpZ25lZCBsb25nDQo+ID4gIH0NCj4gPiAgRVhQT1JU
X1NZTUJPTCh2bV9pb21hcF9tZW1vcnkpOw0KPiA+ICANCj4gPiAtc3RhdGljIGludCBhcHBseV90
b19wdGVfcmFuZ2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHBtZF90ICpwbWQsDQo+ID4gLQkJCQkg
ICAgIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWduZWQgbG9uZw0KPiA+IGVuZCwNCj4gPiAtCQkJ
CSAgICAgcHRlX2ZuX3QgZm4sIHZvaWQgKmRhdGEpDQo+ID4gK3N0YXRpYyBpbnQgYXBwbHlfdG9f
cHRlX3JhbmdlKHN0cnVjdCBwZm5fcmFuZ2VfYXBwbHkgKmNsb3N1cmUsDQo+ID4gcG1kX3QgKnBt
ZCwNCj4gPiArCQkJICAgICAgdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGVuZCkN
Cj4gPiAgew0KPiA+ICAJcHRlX3QgKnB0ZTsNCj4gPiAgCWludCBlcnI7DQo+ID4gIAlwZ3RhYmxl
X3QgdG9rZW47DQo+ID4gIAlzcGlubG9ja190ICp1bmluaXRpYWxpemVkX3ZhcihwdGwpOw0KPiA+
ICANCj4gPiAtCXB0ZSA9IChtbSA9PSAmaW5pdF9tbSkgPw0KPiA+ICsJcHRlID0gKGNsb3N1cmUt
Pm1tID09ICZpbml0X21tKSA/DQo+ID4gIAkJcHRlX2FsbG9jX2tlcm5lbChwbWQsIGFkZHIpIDoN
Cj4gPiAtCQlwdGVfYWxsb2NfbWFwX2xvY2sobW0sIHBtZCwgYWRkciwgJnB0bCk7DQo+ID4gKwkJ
cHRlX2FsbG9jX21hcF9sb2NrKGNsb3N1cmUtPm1tLCBwbWQsIGFkZHIsICZwdGwpOw0KPiA+ICAJ
aWYgKCFwdGUpDQo+ID4gIAkJcmV0dXJuIC1FTk9NRU07DQo+ID4gIA0KPiA+IEBAIC0xOTYwLDg2
ICsxOTU5LDEwMyBAQCBzdGF0aWMgaW50IGFwcGx5X3RvX3B0ZV9yYW5nZShzdHJ1Y3QNCj4gPiBt
bV9zdHJ1Y3QgKm1tLCBwbWRfdCAqcG1kLA0KPiA+ICAJdG9rZW4gPSBwbWRfcGd0YWJsZSgqcG1k
KTsNCj4gPiAgDQo+ID4gIAlkbyB7DQo+ID4gLQkJZXJyID0gZm4ocHRlKyssIHRva2VuLCBhZGRy
LCBkYXRhKTsNCj4gPiArCQllcnIgPSBjbG9zdXJlLT5wdGVmbihwdGUrKywgdG9rZW4sIGFkZHIs
IGNsb3N1cmUpOw0KPiA+ICAJCWlmIChlcnIpDQo+ID4gIAkJCWJyZWFrOw0KPiA+ICAJfSB3aGls
ZSAoYWRkciArPSBQQUdFX1NJWkUsIGFkZHIgIT0gZW5kKTsNCj4gPiAgDQo+ID4gIAlhcmNoX2xl
YXZlX2xhenlfbW11X21vZGUoKTsNCj4gPiAgDQo+ID4gLQlpZiAobW0gIT0gJmluaXRfbW0pDQo+
ID4gKwlpZiAoY2xvc3VyZS0+bW0gIT0gJmluaXRfbW0pDQo+ID4gIAkJcHRlX3VubWFwX3VubG9j
ayhwdGUtMSwgcHRsKTsNCj4gPiAgCXJldHVybiBlcnI7DQo+ID4gIH0NCj4gPiAgDQo+ID4gLXN0
YXRpYyBpbnQgYXBwbHlfdG9fcG1kX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCBwdWRfdCAq
cHVkLA0KPiA+IC0JCQkJICAgICB1bnNpZ25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcNCj4g
PiBlbmQsDQo+ID4gLQkJCQkgICAgIHB0ZV9mbl90IGZuLCB2b2lkICpkYXRhKQ0KPiA+ICtzdGF0
aWMgaW50IGFwcGx5X3RvX3BtZF9yYW5nZShzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpjbG9zdXJl
LA0KPiA+IHB1ZF90ICpwdWQsDQo+ID4gKwkJCSAgICAgIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5z
aWduZWQgbG9uZyBlbmQpDQo+ID4gIHsNCj4gPiAgCXBtZF90ICpwbWQ7DQo+ID4gIAl1bnNpZ25l
ZCBsb25nIG5leHQ7DQo+ID4gLQlpbnQgZXJyOw0KPiA+ICsJaW50IGVyciA9IDA7DQo+ID4gIA0K
PiA+ICAJQlVHX09OKHB1ZF9odWdlKCpwdWQpKTsNCj4gPiAgDQo+ID4gLQlwbWQgPSBwbWRfYWxs
b2MobW0sIHB1ZCwgYWRkcik7DQo+ID4gKwlwbWQgPSBwbWRfYWxsb2MoY2xvc3VyZS0+bW0sIHB1
ZCwgYWRkcik7DQo+ID4gIAlpZiAoIXBtZCkNCj4gPiAgCQlyZXR1cm4gLUVOT01FTTsNCj4gPiAr
DQo+ID4gIAlkbyB7DQo+ID4gIAkJbmV4dCA9IHBtZF9hZGRyX2VuZChhZGRyLCBlbmQpOw0KPiA+
IC0JCWVyciA9IGFwcGx5X3RvX3B0ZV9yYW5nZShtbSwgcG1kLCBhZGRyLCBuZXh0LCBmbiwNCj4g
PiBkYXRhKTsNCj4gPiArCQlpZiAoIWNsb3N1cmUtPmFsbG9jICYmIHBtZF9ub25lX29yX2NsZWFy
X2JhZChwbWQpKQ0KPiA+ICsJCQljb250aW51ZTsNCj4gPiArCQllcnIgPSBhcHBseV90b19wdGVf
cmFuZ2UoY2xvc3VyZSwgcG1kLCBhZGRyLCBuZXh0KTsNCj4gPiAgCQlpZiAoZXJyKQ0KPiA+ICAJ
CQlicmVhazsNCj4gPiAgCX0gd2hpbGUgKHBtZCsrLCBhZGRyID0gbmV4dCwgYWRkciAhPSBlbmQp
Ow0KPiA+ICAJcmV0dXJuIGVycjsNCj4gPiAgfQ0KPiA+ICANCj4gPiAtc3RhdGljIGludCBhcHBs
eV90b19wdWRfcmFuZ2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHA0ZF90ICpwNGQsDQo+ID4gLQkJ
CQkgICAgIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWduZWQgbG9uZw0KPiA+IGVuZCwNCj4gPiAt
CQkJCSAgICAgcHRlX2ZuX3QgZm4sIHZvaWQgKmRhdGEpDQo+ID4gK3N0YXRpYyBpbnQgYXBwbHlf
dG9fcHVkX3JhbmdlKHN0cnVjdCBwZm5fcmFuZ2VfYXBwbHkgKmNsb3N1cmUsDQo+ID4gcDRkX3Qg
KnA0ZCwNCj4gPiArCQkJICAgICAgdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGVu
ZCkNCj4gPiAgew0KPiA+ICAJcHVkX3QgKnB1ZDsNCj4gPiAgCXVuc2lnbmVkIGxvbmcgbmV4dDsN
Cj4gPiAtCWludCBlcnI7DQo+ID4gKwlpbnQgZXJyID0gMDsNCj4gPiAgDQo+ID4gLQlwdWQgPSBw
dWRfYWxsb2MobW0sIHA0ZCwgYWRkcik7DQo+ID4gKwlwdWQgPSBwdWRfYWxsb2MoY2xvc3VyZS0+
bW0sIHA0ZCwgYWRkcik7DQo+ID4gIAlpZiAoIXB1ZCkNCj4gPiAgCQlyZXR1cm4gLUVOT01FTTsN
Cj4gPiArDQo+ID4gIAlkbyB7DQo+ID4gIAkJbmV4dCA9IHB1ZF9hZGRyX2VuZChhZGRyLCBlbmQp
Ow0KPiA+IC0JCWVyciA9IGFwcGx5X3RvX3BtZF9yYW5nZShtbSwgcHVkLCBhZGRyLCBuZXh0LCBm
biwNCj4gPiBkYXRhKTsNCj4gPiArCQlpZiAoIWNsb3N1cmUtPmFsbG9jICYmIHB1ZF9ub25lX29y
X2NsZWFyX2JhZChwdWQpKQ0KPiA+ICsJCQljb250aW51ZTsNCj4gPiArCQllcnIgPSBhcHBseV90
b19wbWRfcmFuZ2UoY2xvc3VyZSwgcHVkLCBhZGRyLCBuZXh0KTsNCj4gPiAgCQlpZiAoZXJyKQ0K
PiA+ICAJCQlicmVhazsNCj4gPiAgCX0gd2hpbGUgKHB1ZCsrLCBhZGRyID0gbmV4dCwgYWRkciAh
PSBlbmQpOw0KPiA+ICAJcmV0dXJuIGVycjsNCj4gPiAgfQ0KPiA+ICANCj4gPiAtc3RhdGljIGlu
dCBhcHBseV90b19wNGRfcmFuZ2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHBnZF90ICpwZ2QsDQo+
ID4gLQkJCQkgICAgIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWduZWQgbG9uZw0KPiA+IGVuZCwN
Cj4gPiAtCQkJCSAgICAgcHRlX2ZuX3QgZm4sIHZvaWQgKmRhdGEpDQo+ID4gK3N0YXRpYyBpbnQg
YXBwbHlfdG9fcDRkX3JhbmdlKHN0cnVjdCBwZm5fcmFuZ2VfYXBwbHkgKmNsb3N1cmUsDQo+ID4g
cGdkX3QgKnBnZCwNCj4gPiArCQkJICAgICAgdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBs
b25nIGVuZCkNCj4gPiAgew0KPiA+ICAJcDRkX3QgKnA0ZDsNCj4gPiAgCXVuc2lnbmVkIGxvbmcg
bmV4dDsNCj4gPiAtCWludCBlcnI7DQo+ID4gKwlpbnQgZXJyID0gMDsNCj4gPiAgDQo+ID4gLQlw
NGQgPSBwNGRfYWxsb2MobW0sIHBnZCwgYWRkcik7DQo+ID4gKwlwNGQgPSBwNGRfYWxsb2MoY2xv
c3VyZS0+bW0sIHBnZCwgYWRkcik7DQo+ID4gIAlpZiAoIXA0ZCkNCj4gPiAgCQlyZXR1cm4gLUVO
T01FTTsNCj4gPiArDQo+ID4gIAlkbyB7DQo+ID4gIAkJbmV4dCA9IHA0ZF9hZGRyX2VuZChhZGRy
LCBlbmQpOw0KPiA+IC0JCWVyciA9IGFwcGx5X3RvX3B1ZF9yYW5nZShtbSwgcDRkLCBhZGRyLCBu
ZXh0LCBmbiwNCj4gPiBkYXRhKTsNCj4gPiArCQlpZiAoIWNsb3N1cmUtPmFsbG9jICYmIHA0ZF9u
b25lX29yX2NsZWFyX2JhZChwNGQpKQ0KPiA+ICsJCQljb250aW51ZTsNCj4gPiArCQllcnIgPSBh
cHBseV90b19wdWRfcmFuZ2UoY2xvc3VyZSwgcDRkLCBhZGRyLCBuZXh0KTsNCj4gPiAgCQlpZiAo
ZXJyKQ0KPiA+ICAJCQlicmVhazsNCj4gPiAgCX0gd2hpbGUgKHA0ZCsrLCBhZGRyID0gbmV4dCwg
YWRkciAhPSBlbmQpOw0KPiA+ICAJcmV0dXJuIGVycjsNCj4gPiAgfQ0KPiA+ICANCj4gPiAtLyoN
Cj4gPiAtICogU2NhbiBhIHJlZ2lvbiBvZiB2aXJ0dWFsIG1lbW9yeSwgZmlsbGluZyBpbiBwYWdl
IHRhYmxlcyBhcw0KPiA+IG5lY2Vzc2FyeQ0KPiA+IC0gKiBhbmQgY2FsbGluZyBhIHByb3ZpZGVk
IGZ1bmN0aW9uIG9uIGVhY2ggbGVhZiBwYWdlIHRhYmxlLg0KPiA+ICsvKioNCj4gPiArICogYXBw
bHlfdG9fcGZuX3JhbmdlIC0gU2NhbiBhIHJlZ2lvbiBvZiB2aXJ0dWFsIG1lbW9yeSwgY2FsbGlu
ZyBhDQo+ID4gcHJvdmlkZWQNCj4gPiArICogZnVuY3Rpb24gb24gZWFjaCBsZWFmIHBhZ2UgdGFi
bGUgZW50cnkNCj4gPiArICogQGNsb3N1cmU6IERldGFpbHMgYWJvdXQgaG93IHRvIHNjYW4gYW5k
IHdoYXQgZnVuY3Rpb24gdG8gYXBwbHkNCj4gPiArICogQGFkZHI6IFN0YXJ0IHZpcnR1YWwgYWRk
cmVzcw0KPiA+ICsgKiBAc2l6ZTogU2l6ZSBvZiB0aGUgcmVnaW9uDQo+ID4gKyAqDQo+ID4gKyAq
IElmIEBjbG9zdXJlLT5hbGxvYyBpcyBzZXQgdG8gMSwgdGhlIGZ1bmN0aW9uIHdpbGwgZmlsbCBp
biB0aGUNCj4gPiBwYWdlIHRhYmxlDQo+ID4gKyAqIGFzIG5lY2Vzc2FyeS4gT3RoZXJ3aXNlIGl0
IHdpbGwgc2tpcCBub24tcHJlc2VudCBwYXJ0cy4NCj4gPiArICoNCj4gPiArICogUmV0dXJuczog
WmVybyBvbiBzdWNjZXNzLiBJZiB0aGUgcHJvdmlkZWQgZnVuY3Rpb24gcmV0dXJucyBhDQo+ID4g
bm9uLXplcm8gc3RhdHVzLA0KPiA+ICsgKiB0aGUgcGFnZSB0YWJsZSB3YWxrIHdpbGwgdGVybWlu
YXRlIGFuZCB0aGF0IHN0YXR1cyB3aWxsIGJlDQo+ID4gcmV0dXJuZWQuDQo+ID4gKyAqIElmIEBj
bG9zdXJlLT5hbGxvYyBpcyBzZXQgdG8gMSwgdGhlbiB0aGlzIGZ1bmN0aW9uIG1heSBhbHNvDQo+
ID4gcmV0dXJuIG1lbW9yeQ0KPiA+ICsgKiBhbGxvY2F0aW9uIGVycm9ycyBhcmlzaW5nIGZyb20g
YWxsb2NhdGluZyBwYWdlIHRhYmxlIG1lbW9yeS4NCj4gPiAgICovDQo+ID4gLWludCBhcHBseV90
b19wYWdlX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCB1bnNpZ25lZCBsb25nIGFkZHIsDQo+
ID4gLQkJCXVuc2lnbmVkIGxvbmcgc2l6ZSwgcHRlX2ZuX3QgZm4sIHZvaWQgKmRhdGEpDQo+ID4g
K2ludCBhcHBseV90b19wZm5fcmFuZ2Uoc3RydWN0IHBmbl9yYW5nZV9hcHBseSAqY2xvc3VyZSwN
Cj4gPiArCQkgICAgICAgdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIHNpemUpDQo+
ID4gIHsNCj4gPiAgCXBnZF90ICpwZ2Q7DQo+ID4gIAl1bnNpZ25lZCBsb25nIG5leHQ7DQo+ID4g
QEAgLTIwNDksMTYgKzIwNjUsNTcgQEAgaW50IGFwcGx5X3RvX3BhZ2VfcmFuZ2Uoc3RydWN0IG1t
X3N0cnVjdA0KPiA+ICptbSwgdW5zaWduZWQgbG9uZyBhZGRyLA0KPiA+ICAJaWYgKFdBUk5fT04o
YWRkciA+PSBlbmQpKQ0KPiA+ICAJCXJldHVybiAtRUlOVkFMOw0KPiA+ICANCj4gPiAtCXBnZCA9
IHBnZF9vZmZzZXQobW0sIGFkZHIpOw0KPiA+ICsJcGdkID0gcGdkX29mZnNldChjbG9zdXJlLT5t
bSwgYWRkcik7DQo+ID4gIAlkbyB7DQo+ID4gIAkJbmV4dCA9IHBnZF9hZGRyX2VuZChhZGRyLCBl
bmQpOw0KPiA+IC0JCWVyciA9IGFwcGx5X3RvX3A0ZF9yYW5nZShtbSwgcGdkLCBhZGRyLCBuZXh0
LCBmbiwNCj4gPiBkYXRhKTsNCj4gPiArCQlpZiAoIWNsb3N1cmUtPmFsbG9jICYmIHBnZF9ub25l
X29yX2NsZWFyX2JhZChwZ2QpKQ0KPiA+ICsJCQljb250aW51ZTsNCj4gPiArCQllcnIgPSBhcHBs
eV90b19wNGRfcmFuZ2UoY2xvc3VyZSwgcGdkLCBhZGRyLCBuZXh0KTsNCj4gPiAgCQlpZiAoZXJy
KQ0KPiA+ICAJCQlicmVhazsNCj4gPiAgCX0gd2hpbGUgKHBnZCsrLCBhZGRyID0gbmV4dCwgYWRk
ciAhPSBlbmQpOw0KPiA+ICANCj4gPiAgCXJldHVybiBlcnI7DQo+ID4gIH0NCj4gPiArRVhQT1JU
X1NZTUJPTF9HUEwoYXBwbHlfdG9fcGZuX3JhbmdlKTsNCj4gPiArDQo+ID4gK3N0cnVjdCBwYWdl
X3JhbmdlX2FwcGx5IHsNCj4gPiArCXN0cnVjdCBwZm5fcmFuZ2VfYXBwbHkgcHRlcjsNCj4gPiAr
CXB0ZV9mbl90IGZuOw0KPiA+ICsJdm9pZCAqZGF0YTsNCj4gPiArfTsNCj4gPiArDQo+ID4gKy8q
DQo+ID4gKyAqIENhbGxiYWNrIHdyYXBwZXIgdG8gZW5hYmxlIHVzZSBvZiBhcHBseV90b19wZm5f
cmFuZ2UgZm9yDQo+ID4gKyAqIHRoZSBhcHBseV90b19wYWdlX3JhbmdlIGludGVyZmFjZQ0KPiA+
ICsgKi8NCj4gPiArc3RhdGljIGludCBhcHBseV90b19wYWdlX3JhbmdlX3dyYXBwZXIocHRlX3Qg
KnB0ZSwgcGd0YWJsZV90DQo+ID4gdG9rZW4sDQo+ID4gKwkJCQkgICAgICAgdW5zaWduZWQgbG9u
ZyBhZGRyLA0KPiA+ICsJCQkJICAgICAgIHN0cnVjdCBwZm5fcmFuZ2VfYXBwbHkgKnB0ZXIpDQo+
ID4gK3sNCj4gPiArCXN0cnVjdCBwYWdlX3JhbmdlX2FwcGx5ICpwcmEgPQ0KPiA+ICsJCWNvbnRh
aW5lcl9vZihwdGVyLCB0eXBlb2YoKnByYSksIHB0ZXIpOw0KPiA+ICsNCj4gPiArCXJldHVybiBw
cmEtPmZuKHB0ZSwgdG9rZW4sIGFkZHIsIHByYS0+ZGF0YSk7DQo+ID4gK30NCj4gPiArDQo+ID4g
Ky8qDQo+ID4gKyAqIFNjYW4gYSByZWdpb24gb2YgdmlydHVhbCBtZW1vcnksIGZpbGxpbmcgaW4g
cGFnZSB0YWJsZXMgYXMNCj4gPiBuZWNlc3NhcnkNCj4gPiArICogYW5kIGNhbGxpbmcgYSBwcm92
aWRlZCBmdW5jdGlvbiBvbiBlYWNoIGxlYWYgcGFnZSB0YWJsZS4NCj4gPiArICovDQo+ID4gK2lu
dCBhcHBseV90b19wYWdlX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCB1bnNpZ25lZCBsb25n
IGFkZHIsDQo+ID4gKwkJCXVuc2lnbmVkIGxvbmcgc2l6ZSwgcHRlX2ZuX3QgZm4sIHZvaWQgKmRh
dGEpDQo+ID4gK3sNCj4gPiArCXN0cnVjdCBwYWdlX3JhbmdlX2FwcGx5IHByYSA9IHsNCj4gPiAr
CQkucHRlciA9IHsubW0gPSBtbSwNCj4gPiArCQkJIC5hbGxvYyA9IDEsDQo+ID4gKwkJCSAucHRl
Zm4gPSBhcHBseV90b19wYWdlX3JhbmdlX3dyYXBwZXIgfSwNCj4gPiArCQkuZm4gPSBmbiwNCj4g
PiArCQkuZGF0YSA9IGRhdGENCj4gPiArCX07DQo+ID4gKw0KPiA+ICsJcmV0dXJuIGFwcGx5X3Rv
X3Bmbl9yYW5nZSgmcHJhLnB0ZXIsIGFkZHIsIHNpemUpOw0KPiA+ICt9DQo+ID4gIEVYUE9SVF9T
WU1CT0xfR1BMKGFwcGx5X3RvX3BhZ2VfcmFuZ2UpOw0KPiA+ICANCj4gPiAgLyoNCj4gPiAtLSAN
Cj4gPiAyLjE5LjAucmMxDQo+ID4gDQo=

