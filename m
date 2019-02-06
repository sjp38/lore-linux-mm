Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4188C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 08:44:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D3402081B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 08:44:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="bsZALHB/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D3402081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD5148E00B2; Wed,  6 Feb 2019 03:44:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAA748E00AA; Wed,  6 Feb 2019 03:44:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A726F8E00B2; Wed,  6 Feb 2019 03:44:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4D98E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 03:44:31 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c18so2442618edt.23
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 00:44:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=GWlkkbZ8f95jp0MiZZtFh9AFNIyu4s/GKLo3LCe0VoQ=;
        b=IOMppzSG1qWzzhCywJoXiDbO2wz7rBbY4chwbYmrjzLCzr4rA/db2N+0UZTikiJEIo
         tIoH6RM6yQjC2IclILPrdYWPJ6ZLz2LncM8pgxY3dVwh3k8Ms+h5u72dEMxgIHDO0Xx9
         qK+OWdpCC4P7Aw0wvCGkObLax4IBfWDsGVNGMecWk9pJLgdX1Y7VchHN071uUMFPUBoc
         CBLGw95ELjVzAkzRGbg2+6jLYq/DJPLhwNXFxBdfBUc69UnIL7r8vQab1VqWweaecPcJ
         y5WTjvJ/JLRbp749UMEWKSuMqPvyzitwi84idU8QUJ2L3GFVluDJT0YrT8Ng6VhMQTVR
         4pqg==
X-Gm-Message-State: AHQUAuZpZ2RUQTRQnpry2XYzSWei/s7OMXhenZ3x9Ii3ZRtqMpzSaglu
	Uq47H9ejnkYDTsrd8RHNSjxNDnNrkGGlnt+E8T51zuLfyF/Jvf0Lk1T+anO89hywNf164+dpVKR
	yAEa0gnk/WdoEN4qRol1D4R7osrmRoTQMwNUXQPIHe+DAdUANhNa4fQ6ChrXSrMdkaQ==
X-Received: by 2002:aa7:d0c5:: with SMTP id u5mr7193507edo.158.1549442670661;
        Wed, 06 Feb 2019 00:44:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZlrtoTewp7/QlVhJ1lQrgubleO4Fz9697KDd2yQ+t/9aXoRZTsXkGhRHwPrOkzNOa0MIag
X-Received: by 2002:aa7:d0c5:: with SMTP id u5mr7193442edo.158.1549442669336;
        Wed, 06 Feb 2019 00:44:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549442669; cv=none;
        d=google.com; s=arc-20160816;
        b=rS4amUMjN2ndi3A7K9ADhTQyeRWa/6XSFd5GqQpGcmXp45+Em574w+YG/UuFg0y/9N
         KDqlMl9fqpxTtIGSKd2yp6KutvYe1tMyKbP2M5G9BjgREFmIqydDAMkgDxtknOg4jTc4
         8fde4acLdzHLmQMTZx1IUASOzFnijkBsVH3jPNsOEYIotQOLMQ6AsOG1d5RggJMrRrSU
         NmogRtcSnDOYUII2rHhp2A0GcLFgpvSt9cuLUcTy/Yhf27lyE7opqq2+CjAtGAzz2PA0
         Jd9SFXZRn6oYSdBc/N0fe5Ydy2y5K9Dsn29A6T757wfScNUcn3Gtlt4d8nU7uDanPm3W
         8Q1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=GWlkkbZ8f95jp0MiZZtFh9AFNIyu4s/GKLo3LCe0VoQ=;
        b=Xj8HRM+wZVAWbe+M6niZSR12kNUSfD+jHmy33X5e74G38T7ZJfvIdq+2cyI41Kve4/
         fGhy+PsY8M2ADGTOyrjl8E+T6qrPE7KqV8uxuI2OtQFx3T7fQBe+lNS4RTrj7MokNEVV
         6NKcSiT867kpHr4w9R5tTwf9ZjDFOnSXTo7BOjsbZPCl8HVa7T7EP4KXpyZQhJli2bVa
         njg1LiToZ73P7st9uELDWwbfkcvbkQK3FdOssr5WykN+uaJAn2kyLaqVhojdr5KWdy3L
         3oH5Tj1n8jONLV6OBx/cJoXWsedMBvEc5zxKmD6WEqSrvDpqAQLuVAUQoUzuAartCXsy
         +9Pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="bsZALHB/";
       spf=pass (google.com: domain of haggaie@mellanox.com designates 40.107.3.70 as permitted sender) smtp.mailfrom=haggaie@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30070.outbound.protection.outlook.com. [40.107.3.70])
        by mx.google.com with ESMTPS id a1si2822697ejy.130.2019.02.06.00.44.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 00:44:29 -0800 (PST)
Received-SPF: pass (google.com: domain of haggaie@mellanox.com designates 40.107.3.70 as permitted sender) client-ip=40.107.3.70;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="bsZALHB/";
       spf=pass (google.com: domain of haggaie@mellanox.com designates 40.107.3.70 as permitted sender) smtp.mailfrom=haggaie@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=GWlkkbZ8f95jp0MiZZtFh9AFNIyu4s/GKLo3LCe0VoQ=;
 b=bsZALHB/3wBsEuDpm62Kt8x13+NqOUn7vy3Pj4BAztZg9z/fKC71u1hQFG/jRy67lf9qtKXeJ3CGPnG3261IgAkgSyrFoeV1Ulz3hW5Tg88bRfvC4EyIgZD6zOwTv2O7sW9fs7nNZNA7DjReUCl2kxoaC3E1ltChp726g36SrhI=
Received: from AM6PR05MB4167.eurprd05.prod.outlook.com (52.135.161.24) by
 AM6PR05MB5287.eurprd05.prod.outlook.com (20.177.191.76) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.17; Wed, 6 Feb 2019 08:44:27 +0000
Received: from AM6PR05MB4167.eurprd05.prod.outlook.com
 ([fe80::c0e8:4363:53c6:6957]) by AM6PR05MB4167.eurprd05.prod.outlook.com
 ([fe80::c0e8:4363:53c6:6957%2]) with mapi id 15.20.1601.016; Wed, 6 Feb 2019
 08:44:27 +0000
From: Haggai Eran <haggaie@mellanox.com>
To: "jglisse@redhat.com" <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, Jason Gunthorpe
	<jgg@mellanox.com>, Leon Romanovsky <leonro@mellanox.com>, Doug Ledford
	<dledford@redhat.com>, Artemy Kovalyov <artemyko@mellanox.com>, Moni Shoua
	<monis@mellanox.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Kaike
 Wan <kaike.wan@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Aviad Yehezkel <aviadye@mellanox.com>
Subject: Re: [PATCH 1/1] RDMA/odp: convert to use HMM for ODP
Thread-Topic: [PATCH 1/1] RDMA/odp: convert to use HMM for ODP
Thread-Index: AQHUt/PsykunvwDRykiSsUeH8/rg2aXSgFiA
Date: Wed, 6 Feb 2019 08:44:26 +0000
Message-ID: <f48ed64f-22fe-c366-6a0e-1433e72b9359@mellanox.com>
References: <20190129165839.4127-1-jglisse@redhat.com>
 <20190129165839.4127-2-jglisse@redhat.com>
In-Reply-To: <20190129165839.4127-2-jglisse@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: AM6P192CA0047.EURP192.PROD.OUTLOOK.COM
 (2603:10a6:209:82::24) To AM6PR05MB4167.eurprd05.prod.outlook.com
 (2603:10a6:209:40::24)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=haggaie@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [193.47.165.251]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;AM6PR05MB5287;6:BiWE10d936HDF1S8QwyQG9vB1A1Bo6CPc6lRa9liD9rJdnx0nIyuJdjfMrOTlGlqwSzEY/lzEaq4Zei8dgMmUe/vxXDO0xhwQCM5UUzrY2cKagTJrB8NE5JzQCe/sH/+vLLYwchLRSiqgKQWhiQbsfj4zF0hGSmKNcNyMx04JRy5qvyM2lxqcazbgH1Rzpqb0CZfBcbcM8p5YXbh8wAB5XWLoHn4c0JHTIeBN7GjCV1frFzt2yXQNfX+iIfLKEC2NfIFDOQloQDUqrA310At0BVdKmwp6lOB4WWvvPLLEOmfkKIO58AvJSAS0vdEEmlWqjmo3HuwsM59P93wEgrZsTB8ATwy1Jp1AkHNHU1gpmCqJS/z+JEVp+sywSz7asX5ENlU0olgF38KdAvgJx/Ocbbiyb0g5qiu7Fhv6nQO2wsjAUBug9p9hj4BmlaD+TOyBrHaAa7SB5gRsZH8pPXbaw==;5:vubsnLo3iXeWzzNHb9XmunlIEXIGcK5/0iZXzkVJviCAsgxOm/Hk4iQI3Pbfca4UdwvigqJHCQynPav4hBGLMO8rJX+uYY367Wc9jrMbUXfhFmPm/Oj/RZg4xWBqQgI/Wyd+E/kJetcn8xbovP8hua6MTxHTp9j55+eCAZ4WM8VCN5CxwSPiHYAFnb+IsMyQ69DUVCUqmebezCGXrbFEZA==;7:k2EPf0HiPosEaZC/Kj/2uYNEO7KGd9CmevO2kJp5NfDUvnC2PJ8EPXVNRBR9nR7/q1EXtd++c9WBjWJQ8Km/QS7FWrAzRfaEAI9tRmhQYewC5h2DZV8VMu/aNZIb9IjwqKDLCWstUoU2JstBTMScWA==
x-ms-office365-filtering-correlation-id: b2b4b879-1237-419b-71f4-08d68c0f4d25
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM6PR05MB5287;
x-ms-traffictypediagnostic: AM6PR05MB5287:
x-microsoft-antispam-prvs:
 <AM6PR05MB528772D4005BDD73E4BA3F11C16F0@AM6PR05MB5287.eurprd05.prod.outlook.com>
x-forefront-prvs: 0940A19703
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(136003)(376002)(39860400002)(366004)(346002)(189003)(199004)(54906003)(6512007)(110136005)(71190400001)(71200400001)(486006)(2501003)(2616005)(4326008)(476003)(7736002)(305945005)(53936002)(86362001)(31696002)(6486002)(3846002)(6116002)(6246003)(81166006)(8936002)(107886003)(81156014)(8676002)(25786009)(6436002)(229853002)(316002)(386003)(36756003)(52116002)(31686004)(26005)(76176011)(6506007)(99286004)(105586002)(446003)(11346002)(53546011)(106356001)(186003)(102836004)(2906002)(97736004)(478600001)(14454004)(66066001)(256004)(68736007)(14444005);DIR:OUT;SFP:1101;SCL:1;SRVR:AM6PR05MB5287;H:AM6PR05MB4167.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 hbyo3zXdv+6vXPMbp7QpTUMwbTiIrSD3hJ0NU8Hg1xG2EtWejPA6fMRKsvBON3E0PGp04cnHRODHyn2GEH6+9nhh24QeY2jXnFNiRaslJEFn7yvQbJZoGtQjz9CtlNGEAjmNVI2E2PJbRhxrNemnG6ZL8IK0SWPQt/hLCS5u0Ik3W3hY5pCqC8EwErrUYKkHkd+85AKv/CfuVaFFrpaaZDXLh3957bDLOzkU/r0bZGizjFe9MnU9PqS9EaCWKA2zZlCeaT634C0dAC/yQzkeDZ+kUFv/Lea95gAgxgsDGjFOHduqsfJp8LYf/tCFDGt41QcvkHPClDWu0R02Y6JkqEZBIvn1yBab0CA6sQNYQgs8IFYCoKtVoj9lyfUXgIa9j7E02MqtfEt3VXA7aiLpdmOXXDWDi291m0vRSWvnfyQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <BAC279C652EA7940BD3C957E72761F73@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b2b4b879-1237-419b-71f4-08d68c0f4d25
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Feb 2019 08:44:25.3222
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM6PR05MB5287
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMS8yOS8yMDE5IDY6NTggUE0sIGpnbGlzc2VAcmVkaGF0LmNvbSB3cm90ZToNCiA+IENvbnZl
cnQgT0RQIHRvIHVzZSBITU0gc28gdGhhdCB3ZSBjYW4gYnVpbGQgb24gY29tbW9uIGluZnJhc3Ry
dWN0dXJlDQogPiBmb3IgZGlmZmVyZW50IGNsYXNzIG9mIGRldmljZXMgdGhhdCB3YW50IHRvIG1p
cnJvciBhIHByb2Nlc3MgYWRkcmVzcw0KID4gc3BhY2UgaW50byBhIGRldmljZS4gVGhlcmUgaXMg
bm8gZnVuY3Rpb25hbCBjaGFuZ2VzLg0KDQpUaGFua3MgZm9yIHNlbmRpbmcgdGhpcyBwYXRjaC4g
SSB0aGluayBpbiBnZW5lcmFsIGl0IGlzIGEgZ29vZCBpZGVhIHRvIA0KdXNlIGEgY29tbW9uIGlu
ZnJhc3RydWN0dXJlIGZvciBPRFAuDQoNCkkgaGF2ZSBhIGNvdXBsZSBvZiBxdWVzdGlvbnMgYmVs
b3cuDQoNCj4gLXN0YXRpYyB2b2lkIGliX3VtZW1fbm90aWZpZXJfaW52YWxpZGF0ZV9yYW5nZV9l
bmQoc3RydWN0IG1tdV9ub3RpZmllciAqbW4sDQo+IC0JCQkJY29uc3Qgc3RydWN0IG1tdV9ub3Rp
Zmllcl9yYW5nZSAqcmFuZ2UpDQo+IC17DQo+IC0Jc3RydWN0IGliX3Vjb250ZXh0X3Blcl9tbSAq
cGVyX21tID0NCj4gLQkJY29udGFpbmVyX29mKG1uLCBzdHJ1Y3QgaWJfdWNvbnRleHRfcGVyX21t
LCBtbik7DQo+IC0NCj4gLQlpZiAodW5saWtlbHkoIXBlcl9tbS0+YWN0aXZlKSkNCj4gLQkJcmV0
dXJuOw0KPiAtDQo+IC0JcmJ0X2liX3VtZW1fZm9yX2VhY2hfaW5fcmFuZ2UoJnBlcl9tbS0+dW1l
bV90cmVlLCByYW5nZS0+c3RhcnQsDQo+IC0JCQkJICAgICAgcmFuZ2UtPmVuZCwNCj4gLQkJCQkg
ICAgICBpbnZhbGlkYXRlX3JhbmdlX2VuZF90cmFtcG9saW5lLCB0cnVlLCBOVUxMKTsNCj4gICAJ
dXBfcmVhZCgmcGVyX21tLT51bWVtX3J3c2VtKTsNCj4gKwlyZXR1cm4gcmV0Ow0KPiAgIH0NClBy
ZXZpb3VzbHkgdGhlIGNvZGUgaGVsZCB0aGUgdW1lbV9yd3NlbSBiZXR3ZWVuIHJhbmdlX3N0YXJ0
IGFuZCANCnJhbmdlX2VuZCBjYWxscy4gSSBndWVzcyB0aGF0IHdhcyBpbiBvcmRlciB0byBndWFy
YW50ZWUgdGhhdCBubyBkZXZpY2UgDQpwYWdlIGZhdWx0cyB0YWtlIHJlZmVyZW5jZSB0byB0aGUg
cGFnZXMgYmVpbmcgaW52YWxpZGF0ZWQgd2hpbGUgdGhlIA0KaW52YWxpZGF0aW9uIGlzIG9uZ29p
bmcuIEkgYXNzdW1lIHRoaXMgaXMgbm93IGhhbmRsZWQgYnkgaG1tIGluc3RlYWQsIA0KY29ycmVj
dD8NCg0KPiArDQo+ICtzdGF0aWMgdWludDY0X3Qgb2RwX2htbV9mbGFnc1tITU1fUEZOX0ZMQUdf
TUFYXSA9IHsNCj4gKwlPRFBfUkVBRF9CSVQsCS8qIEhNTV9QRk5fVkFMSUQgKi8NCj4gKwlPRFBf
V1JJVEVfQklULAkvKiBITU1fUEZOX1dSSVRFICovDQo+ICsJT0RQX0RFVklDRV9CSVQsCS8qIEhN
TV9QRk5fREVWSUNFX1BSSVZBVEUgKi8NCkl0IHNlZW1zIHRoYXQgdGhlIG1seDVfaWIgY29kZSBp
biB0aGlzIHBhdGNoIGN1cnJlbnRseSBpZ25vcmVzIHRoZSANCk9EUF9ERVZJQ0VfQklUIChlLmcu
LCBpbiB1bWVtX2RtYV90b19tdHQpLiBJcyB0aGF0IG9rYXk/IE9yIGlzIGl0IA0KaGFuZGxlZCBp
bXBsaWNpdGx5IGJ5IHRoZSBITU1fUEZOX1NQRUNJQUwgY2FzZT8NCg0KDQo+IEBAIC0zMjcsOSAr
Mjg3LDEwIEBAIHZvaWQgcHV0X3Blcl9tbShzdHJ1Y3QgaWJfdW1lbV9vZHAgKnVtZW1fb2RwKQ0K
PiAgCXVwX3dyaXRlKCZwZXJfbW0tPnVtZW1fcndzZW0pOw0KPiAgDQo+ICAJV0FSTl9PTighUkJf
RU1QVFlfUk9PVCgmcGVyX21tLT51bWVtX3RyZWUucmJfcm9vdCkpOw0KPiAtCW1tdV9ub3RpZmll
cl91bnJlZ2lzdGVyX25vX3JlbGVhc2UoJnBlcl9tbS0+bW4sIHBlcl9tbS0+bW0pOw0KPiArCWht
bV9taXJyb3JfdW5yZWdpc3RlcigmcGVyX21tLT5taXJyb3IpOw0KPiAgCXB1dF9waWQocGVyX21t
LT50Z2lkKTsNCj4gLQltbXVfbm90aWZpZXJfY2FsbF9zcmN1KCZwZXJfbW0tPnJjdSwgZnJlZV9w
ZXJfbW0pOw0KPiArDQo+ICsJa2ZyZWUocGVyX21tKTsNCj4gIH0NClByZXZpb3VzbHkgdGhlIHBl
cl9tbSBzdHJ1Y3Qgd2FzIHJlbGVhc2VkIHRocm91Z2ggY2FsbCBzcmN1LCBidXQgbm93IGl0IA0K
aXMgcmVsZWFzZWQgaW1tZWRpYXRlbHkuIElzIGl0IHNhZmU/IEkgc2F3IHRoYXQgaG1tX21pcnJv
cl91bnJlZ2lzdGVyIA0KY2FsbHMgbW11X25vdGlmaWVyX3VucmVnaXN0ZXJfbm9fcmVsZWFzZSwg
c28gSSBkb24ndCB1bmRlcnN0YW5kIHdoYXQgDQpwcmV2ZW50cyBjb25jdXJyZW50bHkgcnVubmlu
ZyBpbnZhbGlkYXRpb25zIGZyb20gYWNjZXNzaW5nIHRoZSByZWxlYXNlZCANCnBlcl9tbSBzdHJ1
Y3QuDQoNCj4gQEAgLTU3OCwxMSArNTc4LDI3IEBAIHN0YXRpYyBpbnQgcGFnZWZhdWx0X21yKHN0
cnVjdCBtbHg1X2liX2RldiAqZGV2LCBzdHJ1Y3QgbWx4NV9pYl9tciAqbXIsDQo+ICANCj4gIG5l
eHRfbXI6DQo+ICAJc2l6ZSA9IG1pbl90KHNpemVfdCwgYmNudCwgaWJfdW1lbV9lbmQoJm9kcC0+
dW1lbSkgLSBpb192aXJ0KTsNCj4gLQ0KPiAgCXBhZ2Vfc2hpZnQgPSBtci0+dW1lbS0+cGFnZV9z
aGlmdDsNCj4gIAlwYWdlX21hc2sgPSB+KEJJVChwYWdlX3NoaWZ0KSAtIDEpOw0KPiArCW9mZiA9
IChpb192aXJ0ICYgKH5wYWdlX21hc2spKTsNCj4gKwlzaXplICs9IChpb192aXJ0ICYgKH5wYWdl
X21hc2spKTsNCj4gKwlpb192aXJ0ID0gaW9fdmlydCAmIHBhZ2VfbWFzazsNCj4gKwlvZmYgKz0g
KHNpemUgJiAofnBhZ2VfbWFzaykpOw0KPiArCXNpemUgPSBBTElHTihzaXplLCAxVUwgPDwgcGFn
ZV9zaGlmdCk7DQo+ICsNCj4gKwlpZiAoaW9fdmlydCA8IGliX3VtZW1fc3RhcnQoJm9kcC0+dW1l
bSkpDQo+ICsJCXJldHVybiAtRUlOVkFMOw0KPiArDQo+ICAJc3RhcnRfaWR4ID0gKGlvX3ZpcnQg
LSAobXItPm1ta2V5LmlvdmEgJiBwYWdlX21hc2spKSA+PiBwYWdlX3NoaWZ0Ow0KPiAgDQo+ICsJ
aWYgKG9kcF9tci0+cGVyX21tID09IE5VTEwgfHwgb2RwX21yLT5wZXJfbW0tPm1tID09IE5VTEwp
DQo+ICsJCXJldHVybiAtRU5PRU5UOw0KPiArDQo+ICsJcmV0ID0gaG1tX3JhbmdlX3JlZ2lzdGVy
KCZyYW5nZSwgb2RwX21yLT5wZXJfbW0tPm1tLA0KPiArCQkJCSBpb192aXJ0LCBpb192aXJ0ICsg
c2l6ZSwgcGFnZV9zaGlmdCk7DQo+ICsJaWYgKHJldCkNCj4gKwkJcmV0dXJuIHJldDsNCj4gKw0K
PiAgCWlmIChwcmVmZXRjaCAmJiAhZG93bmdyYWRlICYmICFtci0+dW1lbS0+d3JpdGFibGUpIHsN
Cj4gIAkJLyogcHJlZmV0Y2ggd2l0aCB3cml0ZS1hY2Nlc3MgbXVzdA0KPiAgCQkgKiBiZSBzdXBw
b3J0ZWQgYnkgdGhlIE1SDQpJc24ndCB0aGVyZSBhIG1pc3Rha2UgaW4gdGhlIGNhbGN1bGF0aW9u
IG9mIHRoZSB2YXJpYWJsZSBzaXplPyBJdGlzIA0KZmlyc3Qgc2V0IHRvIHRoZSBzaXplIG9mIHRo
ZSBwYWdlIGZhdWx0IHJhbmdlLCBidXQgdGhlbiB5b3UgYWRkIHRoZSANCnZpcnR1YWwgYWRkcmVz
cywgc28gSSBndWVzcyBpdCBpcyBhY3R1YWxseSB0aGUgcmFuZ2UgZW5kLiBUaGVuIHlvdSBwYXNz
IA0KaW9fdmlydCArIHNpemUgdG8gaG1tX3JhbmdlX3JlZ2lzdGVyLiBEb2Vzbid0IGl0IGRvdWJs
ZSB0aGUgc2l6ZSBvZiB0aGUgDQpyYW5nZQ0KDQo+IC12b2lkIGliX3VtZW1fb2RwX3VubWFwX2Rt
YV9wYWdlcyhzdHJ1Y3QgaWJfdW1lbV9vZHAgKnVtZW1fb2RwLCB1NjQgdmlydCwNCj4gLQkJCQkg
dTY0IGJvdW5kKQ0KPiArdm9pZCBpYl91bWVtX29kcF91bm1hcF9kbWFfcGFnZXMoc3RydWN0IGli
X3VtZW1fb2RwICp1bWVtX29kcCwNCj4gKwkJCQkgdTY0IHZpcnQsIHU2NCBib3VuZCkNCj4gIHsN
Cj4gKwlzdHJ1Y3QgZGV2aWNlICpkZXZpY2UgPSB1bWVtX29kcC0+dW1lbS5jb250ZXh0LT5kZXZp
Y2UtPmRtYV9kZXZpY2U7DQo+ICAJc3RydWN0IGliX3VtZW0gKnVtZW0gPSAmdW1lbV9vZHAtPnVt
ZW07DQo+IC0JaW50IGlkeDsNCj4gLQl1NjQgYWRkcjsNCj4gLQlzdHJ1Y3QgaWJfZGV2aWNlICpk
ZXYgPSB1bWVtLT5jb250ZXh0LT5kZXZpY2U7DQo+ICsJdW5zaWduZWQgbG9uZyBpZHgsIHBhZ2Vf
bWFzazsNCj4gKwlzdHJ1Y3QgaG1tX3JhbmdlIHJhbmdlOw0KPiArCWxvbmcgcmV0Ow0KPiArDQo+
ICsJaWYgKCF1bWVtLT5ucGFnZXMpDQo+ICsJCXJldHVybjsNCj4gKw0KPiArCWJvdW5kID0gQUxJ
R04oYm91bmQsIDFVTCA8PCB1bWVtLT5wYWdlX3NoaWZ0KTsNCj4gKwlwYWdlX21hc2sgPSB+KEJJ
VCh1bWVtLT5wYWdlX3NoaWZ0KSAtIDEpOw0KPiArCXZpcnQgJj0gcGFnZV9tYXNrOw0KPiAgDQo+
ICAJdmlydCAgPSBtYXhfdCh1NjQsIHZpcnQsICBpYl91bWVtX3N0YXJ0KHVtZW0pKTsNCj4gIAli
b3VuZCA9IG1pbl90KHU2NCwgYm91bmQsIGliX3VtZW1fZW5kKHVtZW0pKTsNCj4gLQkvKiBOb3Rl
IHRoYXQgZHVyaW5nIHRoZSBydW4gb2YgdGhpcyBmdW5jdGlvbiwgdGhlDQo+IC0JICogbm90aWZp
ZXJzX2NvdW50IG9mIHRoZSBNUiBpcyA+IDAsIHByZXZlbnRpbmcgYW55IHJhY2luZw0KPiAtCSAq
IGZhdWx0cyBmcm9tIGNvbXBsZXRpb24uIFdlIG1pZ2h0IGJlIHJhY2luZyB3aXRoIG90aGVyDQo+
IC0JICogaW52YWxpZGF0aW9ucywgc28gd2UgbXVzdCBtYWtlIHN1cmUgd2UgZnJlZSBlYWNoIHBh
Z2Ugb25seQ0KPiAtCSAqIG9uY2UuICovDQo+ICsNCj4gKwlpZHggPSAoKHVuc2lnbmVkIGxvbmcp
dmlydCAtIGliX3VtZW1fc3RhcnQodW1lbSkpID4+IFBBR0VfU0hJRlQ7DQo+ICsNCj4gKwlyYW5n
ZS5wYWdlX3NoaWZ0ID0gdW1lbS0+cGFnZV9zaGlmdDsNCj4gKwlyYW5nZS5wZm5zID0gJnVtZW1f
b2RwLT5wZm5zW2lkeF07DQo+ICsJcmFuZ2UucGZuX3NoaWZ0ID0gT0RQX0ZMQUdTX0JJVFM7DQo+
ICsJcmFuZ2UudmFsdWVzID0gb2RwX2htbV92YWx1ZXM7DQo+ICsJcmFuZ2UuZmxhZ3MgPSBvZHBf
aG1tX2ZsYWdzOw0KPiArCXJhbmdlLnN0YXJ0ID0gdmlydDsNCj4gKwlyYW5nZS5lbmQgPSBib3Vu
ZDsNCj4gKw0KPiAgCW11dGV4X2xvY2soJnVtZW1fb2RwLT51bWVtX211dGV4KTsNCj4gLQlmb3Ig
KGFkZHIgPSB2aXJ0OyBhZGRyIDwgYm91bmQ7IGFkZHIgKz0gQklUKHVtZW0tPnBhZ2Vfc2hpZnQp
KSB7DQo+IC0JCWlkeCA9IChhZGRyIC0gaWJfdW1lbV9zdGFydCh1bWVtKSkgPj4gdW1lbS0+cGFn
ZV9zaGlmdDsNCj4gLQkJaWYgKHVtZW1fb2RwLT5wYWdlX2xpc3RbaWR4XSkgew0KPiAtCQkJc3Ry
dWN0IHBhZ2UgKnBhZ2UgPSB1bWVtX29kcC0+cGFnZV9saXN0W2lkeF07DQo+IC0JCQlkbWFfYWRk
cl90IGRtYSA9IHVtZW1fb2RwLT5kbWFfbGlzdFtpZHhdOw0KPiAtCQkJZG1hX2FkZHJfdCBkbWFf
YWRkciA9IGRtYSAmIE9EUF9ETUFfQUREUl9NQVNLOw0KPiAtDQo+IC0JCQlXQVJOX09OKCFkbWFf
YWRkcik7DQo+IC0NCj4gLQkJCWliX2RtYV91bm1hcF9wYWdlKGRldiwgZG1hX2FkZHIsIFBBR0Vf
U0laRSwNCj4gLQkJCQkJICBETUFfQklESVJFQ1RJT05BTCk7DQo+IC0JCQlpZiAoZG1hICYgT0RQ
X1dSSVRFX0FMTE9XRURfQklUKSB7DQo+IC0JCQkJc3RydWN0IHBhZ2UgKmhlYWRfcGFnZSA9IGNv
bXBvdW5kX2hlYWQocGFnZSk7DQo+IC0JCQkJLyoNCj4gLQkJCQkgKiBzZXRfcGFnZV9kaXJ0eSBw
cmVmZXJzIGJlaW5nIGNhbGxlZCB3aXRoDQo+IC0JCQkJICogdGhlIHBhZ2UgbG9jay4gSG93ZXZl
ciwgTU1VIG5vdGlmaWVycyBhcmUNCj4gLQkJCQkgKiBjYWxsZWQgc29tZXRpbWVzIHdpdGggYW5k
IHNvbWV0aW1lcyB3aXRob3V0DQo+IC0JCQkJICogdGhlIGxvY2suIFdlIHJlbHkgb24gdGhlIHVt
ZW1fbXV0ZXggaW5zdGVhZA0KPiAtCQkJCSAqIHRvIHByZXZlbnQgb3RoZXIgbW11IG5vdGlmaWVy
cyBmcm9tDQo+IC0JCQkJICogY29udGludWluZyBhbmQgYWxsb3dpbmcgdGhlIHBhZ2UgbWFwcGlu
ZyB0bw0KPiAtCQkJCSAqIGJlIHJlbW92ZWQuDQo+IC0JCQkJICovDQo+IC0JCQkJc2V0X3BhZ2Vf
ZGlydHkoaGVhZF9wYWdlKTsNCj4gLQkJCX0NCj4gLQkJCS8qIG9uIGRlbWFuZCBwaW5uaW5nIHN1
cHBvcnQgKi8NCj4gLQkJCWlmICghdW1lbS0+Y29udGV4dC0+aW52YWxpZGF0ZV9yYW5nZSkNCj4g
LQkJCQlwdXRfcGFnZShwYWdlKTsNCj4gLQkJCXVtZW1fb2RwLT5wYWdlX2xpc3RbaWR4XSA9IE5V
TEw7DQo+IC0JCQl1bWVtX29kcC0+ZG1hX2xpc3RbaWR4XSA9IDA7DQo+IC0JCQl1bWVtLT5ucGFn
ZXMtLTsNCj4gLQkJfQ0KPiAtCX0NCj4gKwlyZXQgPSBobW1fcmFuZ2VfZG1hX3VubWFwKCZyYW5n
ZSwgTlVMTCwgZGV2aWNlLA0KPiArCQkmdW1lbV9vZHAtPmRtYV9saXN0W2lkeF0sIHRydWUpOw0K
PiArCWlmIChyZXQgPiAwKQ0KPiArCQl1bWVtLT5ucGFnZXMgLT0gcmV0Ow0KQ2FuIGhtbV9yYW5n
ZV9kbWFfdW5tYXAgZmFpbD8gSWYgaXQgZG9lcywgd2UgZG8gd2Ugc2ltcGx5IGxlYWsgdGhlIERN
QSANCm1hcHBpbmdzPw0KPiAgCW11dGV4X3VubG9jaygmdW1lbV9vZHAtPnVtZW1fbXV0ZXgpOw0K
PiAgfQ0KDQpSZWdhcmRzLA0KSGFnZ2FpDQo=

