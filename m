Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27BC9C04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:43:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2E1920656
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:43:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="HjfFqM3U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2E1920656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7263F6B0008; Tue,  7 May 2019 12:43:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AF786B000A; Tue,  7 May 2019 12:43:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 502C76B000C; Tue,  7 May 2019 12:43:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 243526B0008
	for <linux-mm@kvack.org>; Tue,  7 May 2019 12:43:50 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id 1so1127218oin.3
        for <linux-mm@kvack.org>; Tue, 07 May 2019 09:43:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=M6VFbky3ymyVMrcNdfwd/tdxQTzdcc3pSaBPWG3vy6A=;
        b=n3OZmht4jsibs4G2G9xnu5N+av/MagbuiDCpboT6wAcBbarX7iiT/4RgoozWmNf7sj
         oFoGaABmsb3c3Oiez0ht/oQuz7tZEQqCMPhlboLws/RmUxv1UvaAue+uXsRRIau6497+
         aq2mm41wKtCoaeVtqO2MIjcdI2ykIbDBPk/OzWtZpmPOFQH7ulsSjRZortyRnkKXT8uV
         KoCO0YyftRGpAsGTR36l9oKyNS6GWkf9+41k8rIYmFSFHAcj1eam+uXO2jB0S5KzBz95
         rd0Q/LhyChFMAdh6Xn8YquJBypMt4aNFAIKm2PqHphKSKnQUFsd+POjjr9qMAjWm5MQ2
         fsgA==
X-Gm-Message-State: APjAAAWAH4wwcFDVVMjHMo3GlXrhiLLSTxwI0kWPwUlLzdM6+8clvyQz
	dxowK2UioPmWqgH32vwYYi++xWC4h2kS4+3ZDxGow17oc3A0jjCj1eC4/zHM12NH6687DbZPjfK
	lWfOI0AYwflhT5uLzhrE+r3ckYieXPDnz/GbVXyJYGHBQgqihaFNIlReQNyrDaYQ=
X-Received: by 2002:a9d:7f13:: with SMTP id j19mr5454012otq.301.1557247428818;
        Tue, 07 May 2019 09:43:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzN/O+bTkS6PXQgVT6PWnbVIkQukVDlcLpjNrmj1+OW+Yj6QPz1uDUSd2JuOD/V5YGucDRL
X-Received: by 2002:a9d:7f13:: with SMTP id j19mr5453934otq.301.1557247427259;
        Tue, 07 May 2019 09:43:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557247427; cv=none;
        d=google.com; s=arc-20160816;
        b=RIr71p+X3q86n0EMeJXJiS4fywdJpuo+OlsqyrJUkZ3ej22P6LzIr2rrK6BxowuILk
         q6pcrwY8rAiboP7QhvYnDNPok7ShRY2We8mVCKJe0/QDOrTVSBj9Ags4IdP5IgB1aikm
         0OfZddHLeVn8nyjfawBGDfip8bbbEekGAtnFAq0yxW7Yhhk67ZkhP+uTYQSYbUhxnVRw
         ogsyTm0V/S1NGDAM0+AqGr+o76PvGPNWBqz5apIHUDzf8NcxRbTVeYA/4hP2s5+QbguL
         XbGVtRYxdpgc9DzVZCHyffscVqmHgqobBAzsgAeAYhhEcUGZZdGn8WvHz1gMuMGy8mZY
         nCbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=M6VFbky3ymyVMrcNdfwd/tdxQTzdcc3pSaBPWG3vy6A=;
        b=SYGLFwK9khYORoWyTxS5kuIoFAaeqPodKOKu99TAODuKrgm7Pe3+od1or3b2t5czY7
         vDkaHkBiM22xgaaRat+sK2ZPr7vQgPUs5DQv9UOjJDXFQTyhbDa80Jfv1k46IsEpTp9x
         3F6zJsK6l+qYJNjc6Op5d6gNmHfUkSjKpoXn9/inO1PplOZr8I7i2W1se2qauNvOPOi8
         AYp8DD6gzHYNC8LmQMQtSbGya6mMMcgquCLGYyiunZJNBPQLVCZW/gH/49bDxxLIf7gS
         ouo1G1ad8jrdXlULEL8CLyKdDg8eNb8LzQ4vz3up0yAYVNLCTXvoJmRXIyUGQ0K1LayG
         ybfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=HjfFqM3U;
       spf=neutral (google.com: 40.107.73.57 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730057.outbound.protection.outlook.com. [40.107.73.57])
        by mx.google.com with ESMTPS id c3si348308otr.37.2019.05.07.09.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 09:43:47 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.73.57 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.73.57;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=HjfFqM3U;
       spf=neutral (google.com: 40.107.73.57 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=M6VFbky3ymyVMrcNdfwd/tdxQTzdcc3pSaBPWG3vy6A=;
 b=HjfFqM3UsXrd+Qok5En8MfdyZFNJ8bFZ/ag7iiAfSDoMlfaD2HVd8/vk2e886DFRBtJ+TT3XpBuvCWBJJa6jui9ZWygx9dU0JxWxGtJbUwcCiT+3Wj2iSHV0mYir9iaE8nwBWblnb2Bx71JtVjg1/XOjlANN7eigqBFyYAGn6gM=
Received: from BYAPR12MB3176.namprd12.prod.outlook.com (20.179.92.82) by
 BYAPR12MB3544.namprd12.prod.outlook.com (20.179.94.154) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1856.11; Tue, 7 May 2019 16:43:44 +0000
Received: from BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::9118:73f2:809c:22c7]) by BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::9118:73f2:809c:22c7%4]) with mapi id 15.20.1856.012; Tue, 7 May 2019
 16:43:44 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Andrey Konovalov <andreyknvl@google.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-media@vger.kernel.org"
	<linux-media@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>
CC: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino
	<vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland
	<mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook
	<keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, "Deucher,
 Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian"
	<Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Jens
 Wiklander <jens.wiklander@linaro.org>, Alex Williamson
	<alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, Dmitry
 Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy
 Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana
 Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley
	<Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin
 Murphy <robin.murphy@arm.com>, Luc Van Oostenryck
	<luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, Kevin
 Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	"Kuehling@google.com" <Kuehling@google.com>
Subject: Re: [PATCH v15 11/17] drm/amdgpu, arm64: untag user pointers
Thread-Topic: [PATCH v15 11/17] drm/amdgpu, arm64: untag user pointers
Thread-Index: AQHVBCkwhlWrfC6yEUGolKUQ2UvD0qZf37iA
Date: Tue, 7 May 2019 16:43:44 +0000
Message-ID: <f452d003-157d-c307-3a27-fe5c3394e34e@amd.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <84676a97cec129eb7a10559ceae2bec526160ad6.1557160186.git.andreyknvl@google.com>
In-Reply-To:
 <84676a97cec129eb7a10559ceae2bec526160ad6.1557160186.git.andreyknvl@google.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
x-clientproxiedby: YTXPR0101CA0068.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::45) To BYAPR12MB3176.namprd12.prod.outlook.com
 (2603:10b6:a03:133::18)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 09e7b200-0034-47ca-9971-08d6d30b2b1a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:BYAPR12MB3544;
x-ms-traffictypediagnostic: BYAPR12MB3544:
x-microsoft-antispam-prvs:
 <BYAPR12MB3544ED1AEDC3F608873090EF92310@BYAPR12MB3544.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 0030839EEE
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(376002)(366004)(346002)(136003)(39860400002)(189003)(199004)(72206003)(71190400001)(2501003)(316002)(76176011)(386003)(36756003)(81166006)(53546011)(66066001)(476003)(81156014)(6506007)(14454004)(8936002)(478600001)(52116002)(102836004)(486006)(2906002)(8676002)(65956001)(31696002)(65806001)(68736007)(25786009)(5660300002)(186003)(2616005)(6116002)(6246003)(66446008)(73956011)(11346002)(86362001)(446003)(66476007)(64756008)(2201001)(66946007)(26005)(4326008)(31686004)(71200400001)(6512007)(66556008)(53936002)(229853002)(64126003)(58126008)(54906003)(305945005)(6486002)(7406005)(7416002)(256004)(14444005)(99286004)(65826007)(7736002)(110136005)(6436002)(3846002)(921003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR12MB3544;H:BYAPR12MB3176.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 fHcoZnbq9hf2cYkyJCy1IaiD/PM1Vj0DJH3jKfi+aVbuz0nKby+qIya9Jvj61fxNkWgd6wJ2TZFhOMWgIRoBLMBanxM859JGflQ59K+s8RFNIct8hJsIwJ6VE53EniVRTEiOJ71+THdgKc4UuaglK/w1gwDkEDO7Sz49xcdNMo+B6a1Kwr99TuQBUx3qSeFHEqTixIo1etZTz3A69eG9Ssn5u7UWxbSNv847Lm/d0RBKzL7aXwFTQKty6oCOW3GeQJo76qimZ4rrx1r9hK9R4O+yyTEBt8IJttn3Qr0DA58jGDFXtmL/ImI4mjiXUDqyGS6xQ/i5qRjq1gb0r/8PxTNgenUEyN8djedX6sU93fV22s1Ch5Wxi6pvsOW9dF1SwO5fO/xjwavNzjJfY3hmjA==
Content-Type: text/plain; charset="utf-8"
Content-ID: <D2B88B58BE4D1C41BB18133F73BDE5B9@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 09e7b200-0034-47ca-9971-08d6d30b2b1a
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 May 2019 16:43:44.3320
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR12MB3544
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wNS0wNiAxMjozMCBwLm0uLCBBbmRyZXkgS29ub3ZhbG92IHdyb3RlOg0KPiBbQ0FV
VElPTjogRXh0ZXJuYWwgRW1haWxdDQo+DQo+IFRoaXMgcGF0Y2ggaXMgYSBwYXJ0IG9mIGEgc2Vy
aWVzIHRoYXQgZXh0ZW5kcyBhcm02NCBrZXJuZWwgQUJJIHRvIGFsbG93IHRvDQo+IHBhc3MgdGFn
Z2VkIHVzZXIgcG9pbnRlcnMgKHdpdGggdGhlIHRvcCBieXRlIHNldCB0byBzb21ldGhpbmcgZWxz
ZSBvdGhlcg0KPiB0aGFuIDB4MDApIGFzIHN5c2NhbGwgYXJndW1lbnRzLg0KPg0KPiBJbiBhbWRn
cHVfZ2VtX3VzZXJwdHJfaW9jdGwoKSBhbmQgYW1kZ3B1X2FtZGtmZF9ncHV2bS5jL2luaXRfdXNl
cl9wYWdlcygpDQo+IGFuIE1NVSBub3RpZmllciBpcyBzZXQgdXAgd2l0aCBhICh0YWdnZWQpIHVz
ZXJzcGFjZSBwb2ludGVyLiBUaGUgdW50YWdnZWQNCj4gYWRkcmVzcyBzaG91bGQgYmUgdXNlZCBz
byB0aGF0IE1NVSBub3RpZmllcnMgZm9yIHRoZSB1bnRhZ2dlZCBhZGRyZXNzIGdldA0KPiBjb3Jy
ZWN0bHkgbWF0Y2hlZCB1cCB3aXRoIHRoZSByaWdodCBCTy4gVGhpcyBwYXRjaCB1bnRhZyB1c2Vy
IHBvaW50ZXJzIGluDQo+IGFtZGdwdV9nZW1fdXNlcnB0cl9pb2N0bCgpIGZvciB0aGUgR0VNIGNh
c2UgYW5kIGluIGFtZGdwdV9hbWRrZmRfZ3B1dm1fDQo+IGFsbG9jX21lbW9yeV9vZl9ncHUoKSBm
b3IgdGhlIEtGRCBjYXNlLiBUaGlzIGFsc28gbWFrZXMgc3VyZSB0aGF0IGFuDQo+IHVudGFnZ2Vk
IHBvaW50ZXIgaXMgcGFzc2VkIHRvIGFtZGdwdV90dG1fdHRfZ2V0X3VzZXJfcGFnZXMoKSwgd2hp
Y2ggdXNlcw0KPiBpdCBmb3Igdm1hIGxvb2t1cHMuDQo+DQo+IFN1Z2dlc3RlZC1ieTogS3VlaGxp
bmcsIEZlbGl4IDxGZWxpeC5LdWVobGluZ0BhbWQuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBBbmRy
ZXkgS29ub3ZhbG92IDxhbmRyZXlrbnZsQGdvb2dsZS5jb20+DQoNCkFja2VkLWJ5OiBGZWxpeCBL
dWVobGluZyA8RmVsaXguS3VlaGxpbmdAYW1kLmNvbT4NCg0KDQo+IC0tLQ0KPiAgIGRyaXZlcnMv
Z3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV9hbWRrZmRfZ3B1dm0uYyB8IDIgKy0NCj4gICBkcml2
ZXJzL2dwdS9kcm0vYW1kL2FtZGdwdS9hbWRncHVfZ2VtLmMgICAgICAgICAgfCAyICsrDQo+ICAg
MiBmaWxlcyBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkNCj4NCj4gZGlm
ZiAtLWdpdCBhL2RyaXZlcnMvZ3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV9hbWRrZmRfZ3B1dm0u
YyBiL2RyaXZlcnMvZ3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV9hbWRrZmRfZ3B1dm0uYw0KPiBp
bmRleCAxOTIxZGVjM2RmN2EuLjIwY2FjNDRlZDQ0OSAxMDA2NDQNCj4gLS0tIGEvZHJpdmVycy9n
cHUvZHJtL2FtZC9hbWRncHUvYW1kZ3B1X2FtZGtmZF9ncHV2bS5jDQo+ICsrKyBiL2RyaXZlcnMv
Z3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV9hbWRrZmRfZ3B1dm0uYw0KPiBAQCAtMTEyMSw3ICsx
MTIxLDcgQEAgaW50IGFtZGdwdV9hbWRrZmRfZ3B1dm1fYWxsb2NfbWVtb3J5X29mX2dwdSgNCj4g
ICAgICAgICAgICAgICAgICBhbGxvY19mbGFncyA9IDA7DQo+ICAgICAgICAgICAgICAgICAgaWYg
KCFvZmZzZXQgfHwgISpvZmZzZXQpDQo+ICAgICAgICAgICAgICAgICAgICAgICAgICByZXR1cm4g
LUVJTlZBTDsNCj4gLSAgICAgICAgICAgICAgIHVzZXJfYWRkciA9ICpvZmZzZXQ7DQo+ICsgICAg
ICAgICAgICAgICB1c2VyX2FkZHIgPSB1bnRhZ2dlZF9hZGRyKCpvZmZzZXQpOw0KPiAgICAgICAg
ICB9IGVsc2UgaWYgKGZsYWdzICYgQUxMT0NfTUVNX0ZMQUdTX0RPT1JCRUxMKSB7DQo+ICAgICAg
ICAgICAgICAgICAgZG9tYWluID0gQU1ER1BVX0dFTV9ET01BSU5fR1RUOw0KPiAgICAgICAgICAg
ICAgICAgIGFsbG9jX2RvbWFpbiA9IEFNREdQVV9HRU1fRE9NQUlOX0NQVTsNCj4gZGlmZiAtLWdp
dCBhL2RyaXZlcnMvZ3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV9nZW0uYyBiL2RyaXZlcnMvZ3B1
L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV9nZW0uYw0KPiBpbmRleCBkMjFkZDJmMzY5ZGEuLjk4NWNi
ODJiMmFhNiAxMDA2NDQNCj4gLS0tIGEvZHJpdmVycy9ncHUvZHJtL2FtZC9hbWRncHUvYW1kZ3B1
X2dlbS5jDQo+ICsrKyBiL2RyaXZlcnMvZ3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV9nZW0uYw0K
PiBAQCAtMjg2LDYgKzI4Niw4IEBAIGludCBhbWRncHVfZ2VtX3VzZXJwdHJfaW9jdGwoc3RydWN0
IGRybV9kZXZpY2UgKmRldiwgdm9pZCAqZGF0YSwNCj4gICAgICAgICAgdWludDMyX3QgaGFuZGxl
Ow0KPiAgICAgICAgICBpbnQgcjsNCj4NCj4gKyAgICAgICBhcmdzLT5hZGRyID0gdW50YWdnZWRf
YWRkcihhcmdzLT5hZGRyKTsNCj4gKw0KPiAgICAgICAgICBpZiAob2Zmc2V0X2luX3BhZ2UoYXJn
cy0+YWRkciB8IGFyZ3MtPnNpemUpKQ0KPiAgICAgICAgICAgICAgICAgIHJldHVybiAtRUlOVkFM
Ow0KPg0KPiAtLQ0KPiAyLjIxLjAuMTAyMC5nZjI4MjBjZjAxYS1nb29nDQo+DQo=

