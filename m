Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50886C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 10:58:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E36602064A
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 10:58:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="QOHepA6q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E36602064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC02F6B0007; Wed, 17 Apr 2019 06:58:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A70806B0008; Wed, 17 Apr 2019 06:58:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 911DC6B000A; Wed, 17 Apr 2019 06:58:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6B06B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:58:47 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id y9so17700111ywc.22
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 03:58:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=U4Luo3zAhHfrXAVaeLKS+3ZPTqUap1iVMeuJvKzZvpY=;
        b=QnOxRZceMWdfD8VEeBw3kVZkoSn6KpjMlt3F2/BhaNoyhY4isATmgsCTd9LXs42up6
         pjSdgEKCNeGsPNFuyPHTgLSOjLqhH45cVPKGe8f9p+V7FegRnPxcqW6s1gI3zXIMDP/J
         rUxaMY9DmTBBW2Eoye7y6sqCBP+P+vAz2W3RJMeLfCvG5uoX23J69Qb7CNp63vCyxQLN
         mHKuXrhZfskK+VDaSw423fmvLB7tnW9RSOFHO5CRpu7bcfdKWUNJujeMhkOehzthYqBK
         Bp6gxVDT9YDuRg0s/xvfIAZdpAvOF4AZWENhYlDwBjYWmRwgCzPczDtu947sTmjY66Ib
         lY9Q==
X-Gm-Message-State: APjAAAWBVox9DlREtMbmRYa29T8OhkUiVZEaoMb4ZfbRvepfK8SbpKU1
	UYf8Lbf0ReDiGaobfLqnPosCPn059SLeBtah73kx4qaWMYwNQgDR0Rx1Dx6OntQadIfgTaPVnhX
	DCNJwXSEtajDn9UYf0ahVaNFp+KXrIWCPHCia/q3jyDw8xrPKx5zQwo9C0hmYZCj9SQ==
X-Received: by 2002:a81:3982:: with SMTP id g124mr70070120ywa.264.1555498727150;
        Wed, 17 Apr 2019 03:58:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDA3A4ynEGuwrXFBp2xqsdxcoRF3WOVP5UaBWQ+HI+AFf4YlSL/DLyQOu8MkeLyF1dQCn6
X-Received: by 2002:a81:3982:: with SMTP id g124mr70070079ywa.264.1555498726356;
        Wed, 17 Apr 2019 03:58:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555498726; cv=none;
        d=google.com; s=arc-20160816;
        b=wxLmaJizx7Lhjg236CN8Qug9kG72g/kOYOXcxmUhoDqxGi5jK3DmBobiKaW+4ggb0d
         30wH0opkaIE0MGFNFZqrU54mGX/QkUrCG7OX9IzuOVg+BZNikgBjZG2dPQQlMoMpnmyk
         C+YsE6MUn++wIzoEFYlH6HyEy98hMzwxytDrXoql9ICdpLaLBeQnkCZ0bPNfPFc/3pFL
         rSfDfUNFLBgFhQ1nA1h8JUh5TAq1/RUcVuTm1uNykQG2kE4wYoB8WoAgZraTElSFi20S
         gdVMEoxINVStquzFLzpQT7GOEpdarmKsg5Vezaj6oy8H6fLYiM1lmxCoVoVGQJyZi5si
         JxRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=U4Luo3zAhHfrXAVaeLKS+3ZPTqUap1iVMeuJvKzZvpY=;
        b=xUqVQrDTXuD3+2fRQHAqMnOOQVLKFM6CzCTkekZIEwuPiG/yxMzVUPJsXFju4phfHV
         X5Rv3UWeqyd0ziPrRWwUC4GgkSeUC/hvWSS+HqFHoJkVKG+Wr32HXCvMaUNSrRpMYvt+
         GET+PBwejsZTZk2ffe/lO9ajeWjWDThP8N+HjgwyG5boZFQkHhbQ2YizBoN22ZUw6crE
         zO8e6k4R2Pcx/jaFmdweS0TihjBkSzsaIiPmQh+w7GrP9jrNdjCg2c6Yl9M5zi9bkuWV
         G7oEKH+Qk7dPaYWoLncYSK1aZ1DHJuYCfkZCyZqkHOt3E3zvZAGhGAU1t8Qycl8nm4ny
         9Org==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=QOHepA6q;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.76.83 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760083.outbound.protection.outlook.com. [40.107.76.83])
        by mx.google.com with ESMTPS id b205si35679024ywa.113.2019.04.17.03.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Apr 2019 03:58:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.76.83 as permitted sender) client-ip=40.107.76.83;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=QOHepA6q;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.76.83 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=U4Luo3zAhHfrXAVaeLKS+3ZPTqUap1iVMeuJvKzZvpY=;
 b=QOHepA6qW2XyQyvrys/80DYvVykN2RnxR6zYKI6+Tfjz1cYwd250TK62Pfmxul1qmAf/PzRLQWnlfuzBiptMw1iT9t+NcirYSGLpvNKufVvAD95b/Xa8wHy4j/ZsE0kRT8CSFNKthkUJIL6DzzqGt+ZMixtdfTldf+rmhAArJB4=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6542.namprd05.prod.outlook.com (20.178.247.204) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.9; Wed, 17 Apr 2019 10:58:42 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad%7]) with mapi id 15.20.1813.009; Wed, 17 Apr 2019
 10:58:42 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: "jrdr.linux@gmail.com" <jrdr.linux@gmail.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>, "willy@infradead.org"
	<willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org"
	<minchan@kernel.org>, "jglisse@redhat.com" <jglisse@redhat.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>, Linux-graphics-maintainer
	<Linux-graphics-maintainer@vmware.com>, "mhocko@suse.com" <mhocko@suse.com>,
	"ying.huang@intel.com" <ying.huang@intel.com>, "riel@surriel.com"
	<riel@surriel.com>
Subject: Re: [PATCH 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop
 the mmap_sem
Thread-Topic: [PATCH 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop
 the mmap_sem
Thread-Index: AQHU8UlgUqBNZlsCAEaA+wc3NiIS7aY6M7iAgAYCvoA=
Date: Wed, 17 Apr 2019 10:58:42 +0000
Message-ID: <e9211a5c28de521bbaabf1c2576c640f3195b0c2.camel@vmware.com>
References: <20190412160338.64994-1-thellstrom@vmware.com>
	 <20190412160338.64994-2-thellstrom@vmware.com>
	 <CAFqt6zb4qBdrWev1KEruDzPJt5wP4ax_7hUyz+JMV9zLxd_iiw@mail.gmail.com>
In-Reply-To:
 <CAFqt6zb4qBdrWev1KEruDzPJt5wP4ax_7hUyz+JMV9zLxd_iiw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-originating-ip: [155.4.205.35]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a9ae07d9-e331-4bf7-1630-08d6c323a7f4
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600140)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:MN2PR05MB6542;
x-ms-traffictypediagnostic: MN2PR05MB6542:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB6542E172FF33103B3CE4D3EDA1250@MN2PR05MB6542.namprd05.prod.outlook.com>
x-forefront-prvs: 0010D93EFE
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(396003)(136003)(346002)(39860400002)(366004)(199004)(189003)(1361003)(3846002)(25786009)(14444005)(6116002)(99286004)(6916009)(486006)(7736002)(26005)(36756003)(316002)(2501003)(53546011)(446003)(97736004)(105586002)(2906002)(118296001)(11346002)(102836004)(8936002)(8676002)(14454004)(6506007)(106356001)(66066001)(6246003)(7416002)(476003)(2351001)(81156014)(5640700003)(5660300002)(68736007)(66574012)(54906003)(71200400001)(229853002)(86362001)(6512007)(2616005)(6436002)(76176011)(305945005)(478600001)(71190400001)(81166006)(4326008)(53936002)(256004)(6486002)(186003);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6542;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 zq35elGDDf7jOXLOKeLK9he4mGxjqX7Mm4YfSxCHHGBzx9yiuSJTkvLrUoMbu2DotZARNLRbSqcl5Kl+ORPskpKheQW1oy75DAuJ8fanesVTX1q7r12Z/sd8nJRzRx9Vh8/EKQd+mbo89DQFGuvn84312el+1D3XPBzoPQu08BWP10fnkIv+RdZpRJOsF9D5CvecAIrRFxm3S5+s1fe4SIAUWU1ag5SBbHSdcd1LGoCXvjqBTf661QjalN9GnV6+uvsDSckWctfwt5+ZUBIXtG+i84jAX0voojPndTOQKZjNusy2TQV/zySnZNaKafFeTZ85FFJaVXV4g7OGrwvMeGuMcmpRNzQ1Ajm8L+F1CN1iRSmVPDrgmkXliY+F3mzeEitz/UShsk5dN4ZgcqpPvfA7YX6EP/RoqZaMnIdIyyM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <7C3BFD6A04A83A43835DF7565B8EB22C@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a9ae07d9-e331-4bf7-1630-08d6c323a7f4
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Apr 2019 10:58:42.6065
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6542
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGksIFNvdXB0aWNrLA0KDQpPbiBTYXQsIDIwMTktMDQtMTMgYXQgMjA6NDEgKzA1MzAsIFNvdXB0
aWNrIEpvYXJkZXIgd3JvdGU6DQo+IE9uIEZyaSwgQXByIDEyLCAyMDE5IGF0IDk6MzQgUE0gVGhv
bWFzIEhlbGxzdHJvbSA8DQo+IHRoZWxsc3Ryb21Adm13YXJlLmNvbT4gd3JvdGU6DQo+ID4gRHJp
dmVyIGZhdWx0IGNhbGxiYWNrcyBhcmUgYWxsb3dlZCB0byBkcm9wIHRoZSBtbWFwX3NlbSB3aGVu
DQo+ID4gZXhwZWN0aW5nDQo+ID4gbG9uZyBoYXJkd2FyZSB3YWl0cyB0byBhdm9pZCBibG9ja2lu
ZyBvdGhlciBtbSB1c2Vycy4gQWxsb3cgdGhlDQo+ID4gbWt3cml0ZQ0KPiA+IGNhbGxiYWNrcyB0
byBkbyB0aGUgc2FtZSBieSByZXR1cm5pbmcgZWFybHkgb24gVk1fRkFVTFRfUkVUUlkuDQo+ID4g
DQo+ID4gSW4gcGFydGljdWxhciB3ZSB3YW50IHRvIGJlIGFibGUgdG8gZHJvcCB0aGUgbW1hcF9z
ZW0gd2hlbiB3YWl0aW5nDQo+ID4gZm9yDQo+ID4gYSByZXNlcnZhdGlvbiBvYmplY3QgbG9jayBv
biBhIEdQVSBidWZmZXIgb2JqZWN0LiBUaGVzZSBsb2NrcyBtYXkNCj4gPiBiZQ0KPiA+IGhlbGQg
d2hpbGUgd2FpdGluZyBmb3IgdGhlIEdQVS4NCj4gPiANCj4gPiBDYzogQW5kcmV3IE1vcnRvbiA8
YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4NCj4gPiBDYzogTWF0dGhldyBXaWxjb3ggPHdpbGx5
QGluZnJhZGVhZC5vcmc+DQo+ID4gQ2M6IFdpbGwgRGVhY29uIDx3aWxsLmRlYWNvbkBhcm0uY29t
Pg0KPiA+IENjOiBQZXRlciBaaWpsc3RyYSA8cGV0ZXJ6QGluZnJhZGVhZC5vcmc+DQo+ID4gQ2M6
IFJpayB2YW4gUmllbCA8cmllbEBzdXJyaWVsLmNvbT4NCj4gPiBDYzogTWluY2hhbiBLaW0gPG1p
bmNoYW5Aa2VybmVsLm9yZz4NCj4gPiBDYzogTWljaGFsIEhvY2tvIDxtaG9ja29Ac3VzZS5jb20+
DQo+ID4gQ2M6IEh1YW5nIFlpbmcgPHlpbmcuaHVhbmdAaW50ZWwuY29tPg0KPiA+IENjOiBTb3Vw
dGljayBKb2FyZGVyIDxqcmRyLmxpbnV4QGdtYWlsLmNvbT4NCj4gPiBDYzogIkrDqXLDtG1lIEds
aXNzZSIgPGpnbGlzc2VAcmVkaGF0LmNvbT4NCj4gPiBDYzogbGludXgtbW1Aa3ZhY2sub3JnDQo+
ID4gQ2M6IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gPiANCj4gPiBTaWduZWQtb2Zm
LWJ5OiBUaG9tYXMgSGVsbHN0cm9tIDx0aGVsbHN0cm9tQHZtd2FyZS5jb20+DQo+ID4gLS0tDQo+
ID4gIG1tL21lbW9yeS5jIHwgMTAgKysrKysrLS0tLQ0KPiA+ICAxIGZpbGUgY2hhbmdlZCwgNiBp
bnNlcnRpb25zKCspLCA0IGRlbGV0aW9ucygtKQ0KPiA+IA0KPiA+IGRpZmYgLS1naXQgYS9tbS9t
ZW1vcnkuYyBiL21tL21lbW9yeS5jDQo+ID4gaW5kZXggZTExY2E5ZGQ4MjNmLi5hOTViNGEzYjFh
ZTIgMTAwNjQ0DQo+ID4gLS0tIGEvbW0vbWVtb3J5LmMNCj4gPiArKysgYi9tbS9tZW1vcnkuYw0K
PiA+IEBAIC0yMTQ0LDcgKzIxNDQsNyBAQCBzdGF0aWMgdm1fZmF1bHRfdCBkb19wYWdlX21rd3Jp
dGUoc3RydWN0DQo+ID4gdm1fZmF1bHQgKnZtZikNCj4gPiAgICAgICAgIHJldCA9IHZtZi0+dm1h
LT52bV9vcHMtPnBhZ2VfbWt3cml0ZSh2bWYpOw0KPiA+ICAgICAgICAgLyogUmVzdG9yZSBvcmln
aW5hbCBmbGFncyBzbyB0aGF0IGNhbGxlciBpcyBub3Qgc3VycHJpc2VkDQo+ID4gKi8NCj4gPiAg
ICAgICAgIHZtZi0+ZmxhZ3MgPSBvbGRfZmxhZ3M7DQo+ID4gLSAgICAgICBpZiAodW5saWtlbHko
cmV0ICYgKFZNX0ZBVUxUX0VSUk9SIHwgVk1fRkFVTFRfTk9QQUdFKSkpDQo+ID4gKyAgICAgICBp
ZiAodW5saWtlbHkocmV0ICYgKFZNX0ZBVUxUX0VSUk9SIHwgVk1fRkFVTFRfUkVUUlkgfA0KPiA+
IFZNX0ZBVUxUX05PUEFHRSkpKQ0KPiANCj4gV2l0aCB0aGlzIHBhdGNoIHRoZXJlIHdpbGwgbXVs
dGlwbGUgaW5zdGFuY2VzIG9mIChWTV9GQVVMVF9FUlJPUiB8DQo+IFZNX0ZBVUxUX1JFVFJZIHwg
Vk1fRkFVTFRfTk9QQUdFKQ0KPiBpbiBtbS9tZW1vcnkuYy4gRG9lcyBpdCBtYWtlIHNlbnNlIHRv
IHdyYXAgaXQgaW4gYSBtYWNybyBhbmQgdXNlIGl0ID8NCg0KRXZlbiB0aG91Z2ggdGhlIGNvZGUg
d2lsbCBsb29rIG5lYXRlciwgaXQgbWlnaHQgYmUgdHJpY2tpZXIgdG8gZm9sbG93IGENCnBhcnRp
Y3VsYXIgZXJyb3IgcGF0aC4gQ291bGQgd2UgcGVyaGFwcyBwb3N0cG9uZSB0byBhIGZvbGxvdy11
cCBwYXRjaD8NCg0KVGhvbWFzDQoNCg0KDQo+IA0KPiA+ICAgICAgICAgICAgICAgICByZXR1cm4g
cmV0Ow0KPiA+ICAgICAgICAgaWYgKHVubGlrZWx5KCEocmV0ICYgVk1fRkFVTFRfTE9DS0VEKSkp
IHsNCj4gPiAgICAgICAgICAgICAgICAgbG9ja19wYWdlKHBhZ2UpOw0KPiA+IEBAIC0yNDE5LDcg
KzI0MTksNyBAQCBzdGF0aWMgdm1fZmF1bHRfdCB3cF9wZm5fc2hhcmVkKHN0cnVjdA0KPiA+IHZt
X2ZhdWx0ICp2bWYpDQo+ID4gICAgICAgICAgICAgICAgIHB0ZV91bm1hcF91bmxvY2sodm1mLT5w
dGUsIHZtZi0+cHRsKTsNCj4gPiAgICAgICAgICAgICAgICAgdm1mLT5mbGFncyB8PSBGQVVMVF9G
TEFHX01LV1JJVEU7DQo+ID4gICAgICAgICAgICAgICAgIHJldCA9IHZtYS0+dm1fb3BzLT5wZm5f
bWt3cml0ZSh2bWYpOw0KPiA+IC0gICAgICAgICAgICAgICBpZiAocmV0ICYgKFZNX0ZBVUxUX0VS
Uk9SIHwgVk1fRkFVTFRfTk9QQUdFKSkNCj4gPiArICAgICAgICAgICAgICAgaWYgKHJldCAmIChW
TV9GQVVMVF9FUlJPUiB8IFZNX0ZBVUxUX1JFVFJZIHwNCj4gPiBWTV9GQVVMVF9OT1BBR0UpKQ0K
PiA+ICAgICAgICAgICAgICAgICAgICAgICAgIHJldHVybiByZXQ7DQo+ID4gICAgICAgICAgICAg
ICAgIHJldHVybiBmaW5pc2hfbWt3cml0ZV9mYXVsdCh2bWYpOw0KPiA+ICAgICAgICAgfQ0KPiA+
IEBAIC0yNDQwLDcgKzI0NDAsOCBAQCBzdGF0aWMgdm1fZmF1bHRfdCB3cF9wYWdlX3NoYXJlZChz
dHJ1Y3QNCj4gPiB2bV9mYXVsdCAqdm1mKQ0KPiA+ICAgICAgICAgICAgICAgICBwdGVfdW5tYXBf
dW5sb2NrKHZtZi0+cHRlLCB2bWYtPnB0bCk7DQo+ID4gICAgICAgICAgICAgICAgIHRtcCA9IGRv
X3BhZ2VfbWt3cml0ZSh2bWYpOw0KPiA+ICAgICAgICAgICAgICAgICBpZiAodW5saWtlbHkoIXRt
cCB8fCAodG1wICYNCj4gPiAtICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIChW
TV9GQVVMVF9FUlJPUiB8DQo+ID4gVk1fRkFVTFRfTk9QQUdFKSkpKSB7DQo+ID4gKyAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAoVk1fRkFVTFRfRVJST1IgfA0KPiA+IFZNX0ZB
VUxUX1JFVFJZIHwNCj4gPiArICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBW
TV9GQVVMVF9OT1BBR0UpKSkpIHsNCj4gPiAgICAgICAgICAgICAgICAgICAgICAgICBwdXRfcGFn
ZSh2bWYtPnBhZ2UpOw0KPiA+ICAgICAgICAgICAgICAgICAgICAgICAgIHJldHVybiB0bXA7DQo+
ID4gICAgICAgICAgICAgICAgIH0NCj4gPiBAQCAtMzQ5NCw3ICszNDk1LDggQEAgc3RhdGljIHZt
X2ZhdWx0X3QgZG9fc2hhcmVkX2ZhdWx0KHN0cnVjdA0KPiA+IHZtX2ZhdWx0ICp2bWYpDQo+ID4g
ICAgICAgICAgICAgICAgIHVubG9ja19wYWdlKHZtZi0+cGFnZSk7DQo+ID4gICAgICAgICAgICAg
ICAgIHRtcCA9IGRvX3BhZ2VfbWt3cml0ZSh2bWYpOw0KPiA+ICAgICAgICAgICAgICAgICBpZiAo
dW5saWtlbHkoIXRtcCB8fA0KPiA+IC0gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgKHRt
cCAmIChWTV9GQVVMVF9FUlJPUiB8DQo+ID4gVk1fRkFVTFRfTk9QQUdFKSkpKSB7DQo+ID4gKyAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAodG1wICYgKFZNX0ZBVUxUX0VSUk9SIHwNCj4g
PiBWTV9GQVVMVF9SRVRSWSB8DQo+ID4gKyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIFZNX0ZBVUxUX05PUEFHRSkpKSkgew0KPiA+ICAgICAgICAgICAgICAgICAgICAgICAg
IHB1dF9wYWdlKHZtZi0+cGFnZSk7DQo+ID4gICAgICAgICAgICAgICAgICAgICAgICAgcmV0dXJu
IHRtcDsNCj4gPiAgICAgICAgICAgICAgICAgfQ0KPiA+IC0tDQo+ID4gMi4yMC4xDQo+ID4gDQo=

