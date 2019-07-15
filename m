Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21A72C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 21:47:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA0E92086C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 21:47:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=daktronics.com header.i=@daktronics.com header.b="mjQTlKo2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA0E92086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=daktronics.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 366656B0003; Mon, 15 Jul 2019 17:47:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 317686B0006; Mon, 15 Jul 2019 17:47:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DE926B0007; Mon, 15 Jul 2019 17:47:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id F29086B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 17:47:48 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l16so9410432qtq.16
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 14:47:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=+QEEByh4lS/gSMRbtZUtuN5W91MwldMSc83SzKGqWs0=;
        b=a1NW52tVBaYRk6CTk9GN16Qm8AtKqKBhH+y1wJ+l5D0iMHFj02UHTb5umBB8oGq8qG
         06gTHzDLJ4XW9cccjJTEx1Puc6IBaY4TcUkTa1jy5a9v9Mg6u2yMplMs5dwdhEeTBmei
         yHzt+vY10uQLe8CUfIJ4Gdll6V5npGlenLf+HLjpxb6RSvOxeNi8QjMTnHWQe7X4/mSN
         UDm4YrxHED9s0LrZq/ukNmjq5Zn2Xj2TNeLLIVRH2t1QXm3OfZ+y7mpyBDU+9xXblvKm
         Nl+6FsKk53RN8igw2GUzG5eGZ3mgQGOfS3THXNfhH4n63u807wq1KHOnwgkt0IJ0MiE/
         Eg1w==
X-Gm-Message-State: APjAAAWmGEHN77bqVOX9xEMwJUy5cNslBF3jGRSdbX7FMPqDGhKDjwtR
	lE8ED9CI/JpdWwWgHNJZiRXXo+w7/R377EKhLAFSfhEbP2PmMmnGnFZf/D2hJUVDGrqdbVP+aka
	33nOXIHasZ6ik11+/DqVh3V5txCGChGZiwLO93hDfWNzk+zg+Z7cH0HNzDRqKaA3wUQ==
X-Received: by 2002:ac8:2734:: with SMTP id g49mr20180331qtg.228.1563227268687;
        Mon, 15 Jul 2019 14:47:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlV7qWhxKgxbxnvYoYfxpDxotJkXRF2ubnUm6/hjCHVFFF0CP1JI3Pkk84DoGGFFr2uxim
X-Received: by 2002:ac8:2734:: with SMTP id g49mr20180291qtg.228.1563227267815;
        Mon, 15 Jul 2019 14:47:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563227267; cv=none;
        d=google.com; s=arc-20160816;
        b=dpW/RtM6CTNyIwDsZoypSlNqPUB09Kl3qMkPMajLZ/uByQxyTSSw3/5MKG0krM+wOA
         y1QdRP0xkthzB1kH5ZKgRM/JjnVluIO8A5xVsrCzW0pfLQyuScqVv0ElKGZh8/fPSe8M
         pPbHer+lawCfnefM2rAHwSgqNQ+EBRV6AqM0h8wg9b4cUiTRQlgK3a3rnD4o7R2FRGC4
         sYCxoOJmB0wWXvORvTL16EG9V4Dm13CjZIvLuSCpqM7pPe6aSXD4bS2kS84qn38a8FdJ
         MNAbm2xxf2+rEmHcUGd6BvShgE+DoMbD3URbBo/HB/WF9ThMRpmtzgNnL5/lJxxeCECG
         Zwug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=+QEEByh4lS/gSMRbtZUtuN5W91MwldMSc83SzKGqWs0=;
        b=n9ynZKbsOn7iHCxGIKknT0fBkJo+X98QqmKfycth3RKMzKMYgHjS2MfZ4K5M2qjyMU
         cZagWj4ZSw7BFI4TqBwhWix2kcXKmegBct4p27Zw4ZZoA3KyLgxWXqC5E0FsjmRHxdi1
         dzBbp0f0BIbxtnZW2W4zlBflcf7C3la0w047cuSlo9azo0mb894CYrB0MM4iLD72ce7a
         vR0iJoboF9PjrVs+zSiedSDfCYr2yoLOzjcXXKJlQvMqqMBZcGmSEFmFpMrKe1T6GA0u
         FQL6Wehe2DugWHnASOsN6cgY6kBJTd0fs4YSj8U5Mg1/Eyrq1tHO9YGXl2OLg12j7meU
         8tOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@daktronics.com header.s=selector1 header.b=mjQTlKo2;
       spf=pass (google.com: domain of matt.sickler@daktronics.com designates 40.107.68.83 as permitted sender) smtp.mailfrom=Matt.Sickler@daktronics.com
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680083.outbound.protection.outlook.com. [40.107.68.83])
        by mx.google.com with ESMTPS id y17si12259337qth.380.2019.07.15.14.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 14:47:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of matt.sickler@daktronics.com designates 40.107.68.83 as permitted sender) client-ip=40.107.68.83;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@daktronics.com header.s=selector1 header.b=mjQTlKo2;
       spf=pass (google.com: domain of matt.sickler@daktronics.com designates 40.107.68.83 as permitted sender) smtp.mailfrom=Matt.Sickler@daktronics.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=daktronics.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+QEEByh4lS/gSMRbtZUtuN5W91MwldMSc83SzKGqWs0=;
 b=mjQTlKo2t5HI1bSImm8F0DSw/qEwYMVOXHw99bsMHvkXmHx+XQJoc+cREq7DLtHUofyhyjkkp/sqUErraTo4mSdRpbjgPCs/22rosWK+GOHIyUSBROJyvcacwW5qc8PrcRm+jJea47cBpmPO1h7f8qoGIEE91kxCm4ftoUJDTjI=
Received: from SN6PR02MB4016.namprd02.prod.outlook.com (52.135.69.145) by
 SN6PR02MB4943.namprd02.prod.outlook.com (52.135.116.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2052.18; Mon, 15 Jul 2019 21:47:45 +0000
Received: from SN6PR02MB4016.namprd02.prod.outlook.com
 ([fe80::3dba:454:9025:c1d0]) by SN6PR02MB4016.namprd02.prod.outlook.com
 ([fe80::3dba:454:9025:c1d0%7]) with mapi id 15.20.2073.012; Mon, 15 Jul 2019
 21:47:45 +0000
From: Matt Sickler <Matt.Sickler@daktronics.com>
To: John Hubbard <jhubbard@nvidia.com>, Bharath Vedartham
	<linux.bhar@gmail.com>, "ira.weiny@intel.com" <ira.weiny@intel.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jglisse@redhat.com" <jglisse@redhat.com>
CC: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCH] staging: kpc2000: Convert put_page() to put_user_page*()
Thread-Topic: [PATCH] staging: kpc2000: Convert put_page() to put_user_page*()
Thread-Index: AQHVO0bnrb019gUuHEupUjqic0YUcabMHS+AgAAWgjA=
Date: Mon, 15 Jul 2019 21:47:45 +0000
Message-ID:
 <SN6PR02MB4016687B605E3D97D699956EEECF0@SN6PR02MB4016.namprd02.prod.outlook.com>
References: <20190715195248.GA22495@bharath12345-Inspiron-5559>
 <2604fcd1-4829-d77e-9f7c-d4b731782ff9@nvidia.com>
In-Reply-To: <2604fcd1-4829-d77e-9f7c-d4b731782ff9@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Matt.Sickler@daktronics.com; 
x-originating-ip: [2620:9b:8000:6046:9335:3b1c:cd5f:f1d3]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d4f9dbea-40c0-4a6d-52f3-08d7096e1288
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:SN6PR02MB4943;
x-ms-traffictypediagnostic: SN6PR02MB4943:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <SN6PR02MB4943530D267C230C0674C110EECF0@SN6PR02MB4943.namprd02.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 00997889E7
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(39850400004)(376002)(136003)(366004)(396003)(346002)(189003)(199004)(76116006)(64756008)(66446008)(966005)(66556008)(66476007)(66946007)(81166006)(476003)(81156014)(8676002)(486006)(256004)(46003)(229853002)(11346002)(8936002)(446003)(478600001)(102836004)(6246003)(5660300002)(7696005)(316002)(53936002)(6436002)(55016002)(6506007)(54906003)(110136005)(9686003)(76176011)(6306002)(33656002)(68736007)(186003)(52536014)(45080400002)(6116002)(4326008)(99286004)(25786009)(71190400001)(305945005)(71200400001)(86362001)(2201001)(2501003)(14454004)(74316002)(7736002)(2906002);DIR:OUT;SFP:1101;SCL:1;SRVR:SN6PR02MB4943;H:SN6PR02MB4016.namprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: daktronics.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 ndV78HoM98QrUbiI2IIUjvNf0Ml6CDjQzZlkM8Cz6qaxr+hIuZmjt4aqwHKJymy7XXpa0ohPL1ScA2m4C9BQmRxhL0tnI569YO0C2O9gLciEZZSl635Qxl26FN/XmpQv2YEsZW2Pedqp7ENNWSn7fyIt3JvPKIEAZYgBOwVm5rJ7BjmpaIRr4KwyKxUafKImG1ebYm53XkQc6QGl0GtBk5Fc1uF2l+WJOqERkrsYh95tpqddps6cf4f9A8psRwf6u9sLRxIH5A77rwwdsPjzDv3FaiDf4o5SLBF1iT9/+xiyQH5tWCBT3TVkmguFcqgTpXwcAJCVbYUU1dGLu8uKfXED1+y+QwyK/3J7Dt/c6gbRYnTMnPZQTIQa4bkYmthTKOiAah1JoQXWSnIeY357KIoCL2RtcsBG/qiOQskjo6o=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: daktronics.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d4f9dbea-40c0-4a6d-52f3-08d7096e1288
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Jul 2019 21:47:45.7821
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: be88af81-0945-42aa-a3d2-b122777351a2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: matt.sickler@daktronics.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR02MB4943
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SXQgbG9va3MgbGlrZSBPdXRsb29rIGlzIGdvaW5nIHRvIGFic29sdXRlbHkgdHJhc2ggdGhpcyBl
bWFpbC4gIEhvcGVmdWxseSBpdCBjb21lcyB0aHJvdWdoIG9rYXkuDQoNCj4+IFRoZXJlIGhhdmUg
YmVlbiBpc3N1ZXMgd2l0aCBnZXRfdXNlcl9wYWdlcyBhbmQgZmlsZXN5c3RlbSB3cml0ZWJhY2su
DQo+PiBUaGUgaXNzdWVzIGFyZSBiZXR0ZXIgZGVzY3JpYmVkIGluIFsxXS4NCj4+DQo+PiBUaGUg
c29sdXRpb24gYmVpbmcgcHJvcG9zZWQgd2FudHMgdG8ga2VlcCB0cmFjayBvZiBndXBfcGlubmVk
IHBhZ2VzDQo+d2hpY2ggd2lsbCBhbGxvdyB0byB0YWtlIGZ1cnRodXIgc3RlcHMgdG8gY29vcmRp
bmF0ZSBiZXR3ZWVuIHN1YnN5c3RlbXMNCj51c2luZyBndXAuDQo+Pg0KPj4gcHV0X3VzZXJfcGFn
ZSgpIHNpbXBseSBjYWxscyBwdXRfcGFnZSBpbnNpZGUgZm9yIG5vdy4gQnV0IHRoZQ0KPmltcGxl
bWVudGF0aW9uIHdpbGwgY2hhbmdlIG9uY2UgYWxsIGNhbGwgc2l0ZXMgb2YgcHV0X3BhZ2UoKSBh
cmUgY29udmVydGVkLg0KPj4NCj4+IEkgY3VycmVudGx5IGRvIG5vdCBoYXZlIHRoZSBkcml2ZXIg
dG8gdGVzdC4gQ291bGQgSSBoYXZlIHNvbWUgc3VnZ2VzdGlvbnMgdG8NCj50ZXN0IHRoaXMgY29k
ZT8gVGhlIHNvbHV0aW9uIGlzIGN1cnJlbnRseSBpbXBsZW1lbnRlZCBpbiBbMl0gYW5kDQo+PiBp
dCB3b3VsZCBiZSBncmVhdCBpZiB3ZSBjb3VsZCBhcHBseSB0aGUgcGF0Y2ggb24gdG9wIG9mIFsy
XSBhbmQgcnVuIHNvbWUNCj50ZXN0cyB0byBjaGVjayBpZiBhbnkgcmVncmVzc2lvbnMgb2NjdXIu
DQo+DQo+QmVjYXVzZSB0aGlzIGlzIGEgY29tbW9uIHBhdHRlcm4sIGFuZCBiZWNhdXNlIHRoZSBj
b2RlIGhlcmUgZG9lc24ndCBsaWtlbHkNCj5uZWVkIHRvIHNldCBwYWdlIGRpcnR5IGJlZm9yZSB0
aGUgZG1hX3VubWFwX3NnIGNhbGwsIEkgdGhpbmsgdGhlIGZvbGxvd2luZw0KPndvdWxkIGJlIGJl
dHRlciAoaXQncyB1bnRlc3RlZCksIGluc3RlYWQgb2YgdGhlIGFib3ZlIGRpZmYgaHVuazoNCj4N
Cj5kaWZmIC0tZ2l0IGEvZHJpdmVycy9zdGFnaW5nL2twYzIwMDAva3BjX2RtYS9maWxlb3BzLmMN
Cj5iL2RyaXZlcnMvc3RhZ2luZy9rcGMyMDAwL2twY19kbWEvZmlsZW9wcy5jDQo+aW5kZXggNDhj
YTg4YmM2YjBiLi5kNDg2Zjk4NjY0NDkgMTAwNjQ0DQo+LS0tIGEvZHJpdmVycy9zdGFnaW5nL2tw
YzIwMDAva3BjX2RtYS9maWxlb3BzLmMNCj4rKysgYi9kcml2ZXJzL3N0YWdpbmcva3BjMjAwMC9r
cGNfZG1hL2ZpbGVvcHMuYw0KPkBAIC0yMTEsMTYgKzIxMSwxMyBAQCB2b2lkICB0cmFuc2Zlcl9j
b21wbGV0ZV9jYihzdHJ1Y3QgYWlvX2NiX2RhdGENCj4qYWNkLCBzaXplX3QgeGZyX2NvdW50LCB1
MzIgZmxhZ3MpDQo+ICAgICAgICBCVUdfT04oYWNkLT5sZGV2ID09IE5VTEwpOw0KPiAgICAgICAg
QlVHX09OKGFjZC0+bGRldi0+cGxkZXYgPT0gTlVMTCk7DQo+DQo+LSAgICAgICBmb3IgKGkgPSAw
IDsgaSA8IGFjZC0+cGFnZV9jb3VudCA7IGkrKykgew0KPi0gICAgICAgICAgICAgICBpZiAoIVBh
Z2VSZXNlcnZlZChhY2QtPnVzZXJfcGFnZXNbaV0pKSB7DQo+LSAgICAgICAgICAgICAgICAgICAg
ICAgc2V0X3BhZ2VfZGlydHkoYWNkLT51c2VyX3BhZ2VzW2ldKTsNCj4tICAgICAgICAgICAgICAg
fQ0KPi0gICAgICAgfQ0KPi0NCj4gICAgICAgIGRtYV91bm1hcF9zZygmYWNkLT5sZGV2LT5wbGRl
di0+ZGV2LCBhY2QtPnNndC5zZ2wsIGFjZC0+c2d0Lm5lbnRzLCBhY2QtPmxkZXYtPmRpcik7DQo+
DQo+ICAgICAgICBmb3IgKGkgPSAwIDsgaSA8IGFjZC0+cGFnZV9jb3VudCA7IGkrKykgew0KPi0g
ICAgICAgICAgICAgICBwdXRfcGFnZShhY2QtPnVzZXJfcGFnZXNbaV0pOw0KPisgICAgICAgICAg
ICAgICBpZiAoIVBhZ2VSZXNlcnZlZChhY2QtPnVzZXJfcGFnZXNbaV0pKSB7DQo+KyAgICAgICAg
ICAgICAgICAgICAgICAgcHV0X3VzZXJfcGFnZXNfZGlydHkoJmFjZC0+dXNlcl9wYWdlc1tpXSwg
MSk7DQo+KyAgICAgICAgICAgICAgIGVsc2UNCj4rICAgICAgICAgICAgICAgICAgICAgICBwdXRf
dXNlcl9wYWdlKGFjZC0+dXNlcl9wYWdlc1tpXSk7DQo+ICAgICAgICB9DQo+DQo+ICAgICAgICBz
Z19mcmVlX3RhYmxlKCZhY2QtPnNndCk7DQoNCkkgZG9uJ3QgdGhpbmsgSSBldmVyIHJlYWxseSBr
bmV3IHRoZSByaWdodCB3YXkgdG8gZG8gdGhpcy4gDQoNClRoZSBjaGFuZ2VzIEJoYXJhdGggc3Vn
Z2VzdGVkIGxvb2sgb2theSB0byBtZS4gIEknbSBub3Qgc3VyZSBhYm91dCB0aGUgY2hlY2sgZm9y
IFBhZ2VSZXNlcnZlZCgpLCB0aG91Z2guICBBdCBmaXJzdCBnbGFuY2UgaXQgYXBwZWFycyB0byBi
ZSBlcXVpdmFsZW50IHRvIHdoYXQgd2FzIHRoZXJlIGJlZm9yZSwgYnV0IG1heWJlIEkgc2hvdWxk
IGxlYXJuIHdoYXQgdGhhdCBSZXNlcnZlZCBwYWdlIGZsYWcgcmVhbGx5IG1lYW5zLg0KRnJvbSBb
MV0sIHRoZSBvbmx5IGNvbW1lbnQgdGhhdCBzZWVtcyBhcHBsaWNhYmxlIGlzDQoqIC0gTU1JTy9E
TUEgcGFnZXMuIFNvbWUgYXJjaGl0ZWN0dXJlcyBkb24ndCBhbGxvdyB0byBpb3JlbWFwIHBhZ2Vz
IHRoYXQgYXJlDQogKiAgIG5vdCBtYXJrZWQgUEdfcmVzZXJ2ZWQgKGFzIHRoZXkgbWlnaHQgYmUg
aW4gdXNlIGJ5IHNvbWVib2R5IGVsc2Ugd2hvIGRvZXMNCiAqICAgbm90IHJlc3BlY3QgdGhlIGNh
Y2hpbmcgc3RyYXRlZ3kpLg0KDQpUaGVzZSBwYWdlcyBzaG91bGQgYmUgY29taW5nIGZyb20gYW5v
bnltb3VzIChSQU0sIG5vdCBmaWxlIGJhY2tlZCkgbWVtb3J5IGluIHVzZXJzcGFjZS4gIFNvbWV0
aW1lcyBpdCBjb21lcyBmcm9tIGh1Z2VwYWdlIGJhY2tlZCBtZW1vcnksIHRob3VnaCBJIGRvbid0
IHRoaW5rIHRoYXQgbWFrZXMgYSBkaWZmZXJlbmNlLiAgSSBzaG91bGQgbm90ZSB0aGF0IHRyYW5z
ZmVyX2NvbXBsZXRlX2NiIGhhbmRsZXMgYm90aCBSQU0gdG8gZGV2aWNlIGFuZCBkZXZpY2UgdG8g
UkFNIERNQXMsIGlmIHRoYXQgbWF0dGVycy4NCg0KWzFdIGh0dHBzOi8vZWxpeGlyLmJvb3RsaW4u
Y29tL2xpbnV4L3Y1LjIvc291cmNlL2luY2x1ZGUvbGludXgvcGFnZS1mbGFncy5oI0wxNw0K

