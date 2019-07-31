Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 816EDC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:39:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A1C9206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:39:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="c+MdHKeB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A1C9206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C19688E0007; Wed, 31 Jul 2019 09:39:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA1FF8E0001; Wed, 31 Jul 2019 09:39:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A44198E0007; Wed, 31 Jul 2019 09:39:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3368E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:39:00 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id s25so57905807qkj.18
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:39:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=JRAw6rg+EaCPZ5u5Ta75c88T7hcMDALhjpceIqSItVY=;
        b=ua4XHi0t5JH/pMTMwJxNZcrM/cq+aKqVgs8JumyEsx5nOuijMUah5I+GC2akpejBUe
         QPSO2bJesmL+nBtclDkOCuba6rEVf5iA51pEWmQ6DdeyqbTj25H5wGK4+xV0DTFkwbc7
         3EAOQ33vIie74TZjbptkb2kFW1boDXnsbp66bs3CexYoiQegCzxgMOsIDEoM1QsXSXei
         J7Df2aFys85p0f8XaMQZrMfsF70ciyvgG/xudFQSahakuqHi+SanNsgX0Jfaw35xt45X
         KH4bTnDDK+qvb/8e+0ovucwz8uPbhc+Hx+3XluuyF4IDyml1cRIHnw0HHiHPwA8ahB38
         PFdw==
X-Gm-Message-State: APjAAAX0XdBA5klwpKmsB8RJpxzjZ20ltstSteRj6hqnX3NlWGnoN2Tq
	SCKK54NAdYSXiw+jCNpGdq3NGA+SDKkNnEx9DJUCcbS/rMElWCdFS1DndLAMiHgKUkIbaLY7be7
	6GLlfj6DBFThC/tXmYpSLKZ/dojEDtyBqiRccgexe2AZhQSR1WXvJ+LVFogvZdbc=
X-Received: by 2002:a37:2d43:: with SMTP id t64mr77281067qkh.472.1564580340048;
        Wed, 31 Jul 2019 06:39:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrYHfiHlkOuIwvRf4ORvTXk3gJvduL1iToLCyoecY0ifBiTKkeo308VwedyKzHIS7MyA+M
X-Received: by 2002:a37:2d43:: with SMTP id t64mr77280987qkh.472.1564580339358;
        Wed, 31 Jul 2019 06:38:59 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564580339; cv=pass;
        d=google.com; s=arc-20160816;
        b=yC0PeuHvZC1z4Qt82t2bqVRTcS8p3eoNzLQgWjmzkUzu1IbokCphA7VG9n07RaG4NO
         2XSnnQ+2Bv2ykYuXdFLo02Bt60ubNJr9B3ebHTY9IuF3KH+r2F/7DWjS49z1ELict6sw
         bk60QAB/yBnAubqNsahuxOlBmNKgKcaIEvicShcxqqUo6M4NcmGJpPnKjg4kEciVKdMo
         GzeuY4HjG31NZy7XSEtgRJon5PjxIAaL3gGIrK4F0TJSjgPOqQEr/0otbc1KeYGsA7yj
         cnJ12Vhs2XTKsukrFgU8vx+pihRE1GqYc4BrB2Y0jwmYyGOORbUgL/32RqZw+UArJVlh
         ZNaQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=JRAw6rg+EaCPZ5u5Ta75c88T7hcMDALhjpceIqSItVY=;
        b=R7b7A1fWsegMgfCIzLlkqncokkyBVFtoHM0RBzEzjIH73SD5lGVVILXki3KepZZH0u
         dW1k4T7cF/kdeXivmb62caQxuLO9VDRXpa5b3lZXcWiM6F5Odxc2zTlmPTXr+wVGrYCT
         NS50YUjXEJnbaJPjPhxTEceQUK2fdyWtik12nvlcBRinVpH3w3cl0j74zYRawGAbu6ow
         CEJusMLbsuZTlBwjJKkcKS6bZABEJpW2pX13VCkfHAnbs6uZY/P9vf+4KvJuriNTr3OD
         9CHwtWfyDFUugjH2jSe/Rg1WsfvZajUY/tBq+47yzGFk34AgYfB13nFw1YT4gI0Q/89u
         iDnw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=c+MdHKeB;
       arc=pass (i=1 spf=pass spfdomain=amd.com dkim=pass dkdomain=amd.com dmarc=pass fromdomain=amd.com);
       spf=neutral (google.com: 40.107.68.42 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680042.outbound.protection.outlook.com. [40.107.68.42])
        by mx.google.com with ESMTPS id o24si38544317qtm.127.2019.07.31.06.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:38:59 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.68.42 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.68.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=c+MdHKeB;
       arc=pass (i=1 spf=pass spfdomain=amd.com dkim=pass dkdomain=amd.com dmarc=pass fromdomain=amd.com);
       spf=neutral (google.com: 40.107.68.42 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Xif1y/y5GzxvoLfZLUhnP35LPrTtKzSfcBFCHiZKX4yQHbjHlZshlTgAM8nvd4ON4IUqjmX5bIU4x7nW4fj1z5JJiQM84Cu4vGqMkIhQusYnlClenY42G7EwselKmbPE8mSkCxMrr9ECePZMQJKdXyvD3gaLNGQMI44TNHpQVPUOTQTAIjuYAZRny4VAzcugz1JfSDWNDKkkR4Ov3pgIyO79hZ2f8w2lz0TBLH4DYrozhx2GqxyprKJ6VbJ8EmEDDLru4OS9YBOyJajLiEq4jRwdAI5YO5NHZh3dzHdgATFFNI87lvkfCo2g/SyGp3PI84PCcYneXEUGWaNu0Gm3nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=JRAw6rg+EaCPZ5u5Ta75c88T7hcMDALhjpceIqSItVY=;
 b=DyB22IGV/JOAYaC50I79exOGPvrExONoxPGuG81/afntqdZ3spt4cs13NZ1D1E+cwrb2sa3geA5vX4GvIVXc6LYJSldeOu2Ppcs+ohb/9TuWKqoWSXbRldR27rfGw2Whwzqq1AyPLxpw4axtBKcP0j1yZrUglUQvmxljhhJhT0qlr3N7TbxTUmVNuVUdXHLQ5CGCvrKgYdZTceaYXSAYAm+zSmBK05UUKp0es4OYDbLmNaxsYh+tlOUv6jZmDlq8mjnv04zY535THCFkyMgde0XMYqhQZFoL8CVRSN+/NG7oP1BiXoM29j7oBgk8KgKE5sRyPFSr5sSFfRrlrN8ngw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=amd.com;dmarc=pass action=none header.from=amd.com;dkim=pass
 header.d=amd.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=JRAw6rg+EaCPZ5u5Ta75c88T7hcMDALhjpceIqSItVY=;
 b=c+MdHKeBHjRKK7OY0O3cmG1WYrDuzSynJGp/+TpRttdaEFfvxqwuHI7jXM5cWN1DhLa9Ba0CwbPlW923FRRlI5QRZjJx+OWVEe34raS4rKQSOQ05TvXtANHLKy08KP2J/naEBkHjeb6VKQlnL9RGo5IgpmCzT4Jqr02qz4UWkRc=
Received: from DM6PR12MB3947.namprd12.prod.outlook.com (10.255.174.156) by
 DM6PR12MB3867.namprd12.prod.outlook.com (10.255.173.212) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.14; Wed, 31 Jul 2019 13:38:57 +0000
Received: from DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::1c82:54e7:589b:539c]) by DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::1c82:54e7:589b:539c%5]) with mapi id 15.20.2136.010; Wed, 31 Jul 2019
 13:38:57 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Christoph Hellwig <hch@lst.de>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: Ralph Campbell <rcampbell@nvidia.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 07/13] mm: remove the page_shift member from struct
 hmm_range
Thread-Topic: [PATCH 07/13] mm: remove the page_shift member from struct
 hmm_range
Thread-Index: AQHVRpr/Wa6m0vuiq0KkZIv40rbQDqbkvWMA
Date: Wed, 31 Jul 2019 13:38:57 +0000
Message-ID: <f0da1205-42a6-8427-2e89-7670acac7247@amd.com>
References: <20190730055203.28467-1-hch@lst.de>
 <20190730055203.28467-8-hch@lst.de>
In-Reply-To: <20190730055203.28467-8-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
x-clientproxiedby: YT1PR01CA0018.CANPRD01.PROD.OUTLOOK.COM (2603:10b6:b01::31)
 To DM6PR12MB3947.namprd12.prod.outlook.com (2603:10b6:5:1cb::28)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c27cd368-513e-4464-435b-08d715bc6fe5
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM6PR12MB3867;
x-ms-traffictypediagnostic: DM6PR12MB3867:
x-microsoft-antispam-prvs:
 <DM6PR12MB3867BE183648E3592EA4CE9792DF0@DM6PR12MB3867.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 011579F31F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(136003)(346002)(366004)(376002)(39860400002)(52314003)(199004)(189003)(25786009)(64126003)(478600001)(99286004)(6512007)(58126008)(66446008)(316002)(64756008)(386003)(66556008)(66476007)(6486002)(71190400001)(71200400001)(66946007)(229853002)(5660300002)(6436002)(31686004)(36756003)(6246003)(52116002)(4326008)(65956001)(65806001)(7736002)(66066001)(54906003)(110136005)(6116002)(76176011)(53936002)(486006)(14454004)(446003)(102836004)(8676002)(65826007)(305945005)(6506007)(31696002)(81156014)(81166006)(7416002)(476003)(3846002)(2906002)(68736007)(2616005)(11346002)(53546011)(86362001)(26005)(8936002)(256004)(14444005)(186003);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR12MB3867;H:DM6PR12MB3947.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 KjMDkTosBMChcPhWnzR/xLnDSJ/q0k7KtsqdLP5h2G+PrRtxWYt/1moT/wgbI2jyTWvdsIExgLj5DkvjGlH3WUyi/Eq340FH3x4ZdNsansPAJfE5AGn/WQcd006UOUtbOabeVdlQDuJxWViuIqhMJuu71Q74/xks33gUQNaVINpm3hivyMhMpazbq0p6ojWB/pwK2pS5rZKqWHycwIEjhnisLgoBCIbhx4d0Xqcouo3KmaP414B+PmOs6AR95govN7ZRw0QoFaicKHh4EMczQUhTo90aALNMOENwEa9eQ9QkbHIqQcyMru8Vjo/Hr1DG4N1juTxKxJGNNhyvGVtjQbXO81D16ymU2jUySEXSCriWRo32AdX0WWgF/zRQVWqKZ2TNjVe1+KGs860NTZe4gCa0rQvF1woZBdgAFBdEYKk=
Content-Type: text/plain; charset="utf-8"
Content-ID: <3444F4D31C9224418100B98160B88C5A@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c27cd368-513e-4464-435b-08d715bc6fe5
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Jul 2019 13:38:57.3184
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: fkuehlin@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB3867
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wNy0zMCAxOjUxIGEubS4sIENocmlzdG9waCBIZWxsd2lnIHdyb3RlOg0KPiBBbGwg
dXNlcnMgcGFzcyBQQUdFX1NJWkUgaGVyZSwgYW5kIGlmIHdlIHdhbnRlZCB0byBzdXBwb3J0IHNp
bmdsZQ0KPiBlbnRyaWVzIGZvciBodWdlIHBhZ2VzIHdlIHNob3VsZCByZWFsbHkganVzdCBhZGQg
YSBITU1fRkFVTFRfSFVHRVBBR0UNCj4gZmxhZyBpbnN0ZWFkIHRoYXQgdXNlcyB0aGUgaHVnZSBw
YWdlIHNpemUgaW5zdGVhZCBvZiBoYXZpbmcgdGhlDQo+IGNhbGxlciBjYWxjdWxhdGUgdGhhdCBz
aXplIG9uY2UsIGp1c3QgZm9yIHRoZSBobW0gY29kZSB0byB2ZXJpZnkgaXQuDQoNCk1heWJlIHRo
aXMgd2FzIG1lYW50IHRvIHN1cHBvcnQgZGV2aWNlIHBhZ2Ugc2l6ZSAhPSBuYXRpdmUgcGFnZSBz
aXplPyANCkFueXdheSwgbG9va3MgbGlrZSB3ZSBkaWRuJ3QgdXNlIGl0IHRoYXQgd2F5Lg0KDQpB
Y2tlZC1ieTogRmVsaXggS3VlaGxpbmcgPEZlbGl4Lkt1ZWhsaW5nQGFtZC5jb20+DQoNCg0KPg0K
PiBTaWduZWQtb2ZmLWJ5OiBDaHJpc3RvcGggSGVsbHdpZyA8aGNoQGxzdC5kZT4NCj4gLS0tDQo+
ICAgZHJpdmVycy9ncHUvZHJtL2FtZC9hbWRncHUvYW1kZ3B1X3R0bS5jIHwgIDEgLQ0KPiAgIGRy
aXZlcnMvZ3B1L2RybS9ub3V2ZWF1L25vdXZlYXVfc3ZtLmMgICB8ICAxIC0NCj4gICBpbmNsdWRl
L2xpbnV4L2htbS5oICAgICAgICAgICAgICAgICAgICAgfCAyMiAtLS0tLS0tLS0tLS0tDQo+ICAg
bW0vaG1tLmMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHwgNDIgKysrKysrLS0tLS0t
LS0tLS0tLS0tLS0tLQ0KPiAgIDQgZmlsZXMgY2hhbmdlZCwgOSBpbnNlcnRpb25zKCspLCA1NyBk
ZWxldGlvbnMoLSkNCj4NCj4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvZ3B1L2RybS9hbWQvYW1kZ3B1
L2FtZGdwdV90dG0uYyBiL2RyaXZlcnMvZ3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV90dG0uYw0K
PiBpbmRleCA3MWQ2ZTcwODdiMGIuLjhiZjc5Mjg4YzRlMiAxMDA2NDQNCj4gLS0tIGEvZHJpdmVy
cy9ncHUvZHJtL2FtZC9hbWRncHUvYW1kZ3B1X3R0bS5jDQo+ICsrKyBiL2RyaXZlcnMvZ3B1L2Ry
bS9hbWQvYW1kZ3B1L2FtZGdwdV90dG0uYw0KPiBAQCAtODE4LDcgKzgxOCw2IEBAIGludCBhbWRn
cHVfdHRtX3R0X2dldF91c2VyX3BhZ2VzKHN0cnVjdCBhbWRncHVfYm8gKmJvLCBzdHJ1Y3QgcGFn
ZSAqKnBhZ2VzKQ0KPiAgIAkJCQkwIDogcmFuZ2UtPmZsYWdzW0hNTV9QRk5fV1JJVEVdOw0KPiAg
IAlyYW5nZS0+cGZuX2ZsYWdzX21hc2sgPSAwOw0KPiAgIAlyYW5nZS0+cGZucyA9IHBmbnM7DQo+
IC0JcmFuZ2UtPnBhZ2Vfc2hpZnQgPSBQQUdFX1NISUZUOw0KPiAgIAlyYW5nZS0+c3RhcnQgPSBz
dGFydDsNCj4gICAJcmFuZ2UtPmVuZCA9IHN0YXJ0ICsgdHRtLT5udW1fcGFnZXMgKiBQQUdFX1NJ
WkU7DQo+ICAgDQo+IGRpZmYgLS1naXQgYS9kcml2ZXJzL2dwdS9kcm0vbm91dmVhdS9ub3V2ZWF1
X3N2bS5jIGIvZHJpdmVycy9ncHUvZHJtL25vdXZlYXUvbm91dmVhdV9zdm0uYw0KPiBpbmRleCA0
MGU3MDYyMzQ1NTQuLmU3MDY4Y2U0Njk0OSAxMDA2NDQNCj4gLS0tIGEvZHJpdmVycy9ncHUvZHJt
L25vdXZlYXUvbm91dmVhdV9zdm0uYw0KPiArKysgYi9kcml2ZXJzL2dwdS9kcm0vbm91dmVhdS9u
b3V2ZWF1X3N2bS5jDQo+IEBAIC02ODAsNyArNjgwLDYgQEAgbm91dmVhdV9zdm1fZmF1bHQoc3Ry
dWN0IG52aWZfbm90aWZ5ICpub3RpZnkpDQo+ICAgCQkJIGFyZ3MuaS5wLmFkZHIgKyBhcmdzLmku
cC5zaXplLCBmbiAtIGZpKTsNCj4gICANCj4gICAJCS8qIEhhdmUgSE1NIGZhdWx0IHBhZ2VzIHdp
dGhpbiB0aGUgZmF1bHQgd2luZG93IHRvIHRoZSBHUFUuICovDQo+IC0JCXJhbmdlLnBhZ2Vfc2hp
ZnQgPSBQQUdFX1NISUZUOw0KPiAgIAkJcmFuZ2Uuc3RhcnQgPSBhcmdzLmkucC5hZGRyOw0KPiAg
IAkJcmFuZ2UuZW5kID0gYXJncy5pLnAuYWRkciArIGFyZ3MuaS5wLnNpemU7DQo+ICAgCQlyYW5n
ZS5wZm5zID0gYXJncy5waHlzOw0KPiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9obW0uaCBi
L2luY2x1ZGUvbGludXgvaG1tLmgNCj4gaW5kZXggYzViNTEzNzZiNDUzLi41MWUxOGZiYjg5NTMg
MTAwNjQ0DQo+IC0tLSBhL2luY2x1ZGUvbGludXgvaG1tLmgNCj4gKysrIGIvaW5jbHVkZS9saW51
eC9obW0uaA0KPiBAQCAtMTU4LDcgKzE1OCw2IEBAIGVudW0gaG1tX3Bmbl92YWx1ZV9lIHsNCj4g
ICAgKiBAdmFsdWVzOiBwZm4gdmFsdWUgZm9yIHNvbWUgc3BlY2lhbCBjYXNlIChub25lLCBzcGVj
aWFsLCBlcnJvciwgLi4uKQ0KPiAgICAqIEBkZWZhdWx0X2ZsYWdzOiBkZWZhdWx0IGZsYWdzIGZv
ciB0aGUgcmFuZ2UgKHdyaXRlLCByZWFkLCAuLi4gc2VlIGhtbSBkb2MpDQo+ICAgICogQHBmbl9m
bGFnc19tYXNrOiBhbGxvd3MgdG8gbWFzayBwZm4gZmxhZ3Mgc28gdGhhdCBvbmx5IGRlZmF1bHRf
ZmxhZ3MgbWF0dGVyDQo+IC0gKiBAcGFnZV9zaGlmdDogZGV2aWNlIHZpcnR1YWwgYWRkcmVzcyBz
aGlmdCB2YWx1ZSAoc2hvdWxkIGJlID49IFBBR0VfU0hJRlQpDQo+ICAgICogQHBmbl9zaGlmdHM6
IHBmbiBzaGlmdCB2YWx1ZSAoc2hvdWxkIGJlIDw9IFBBR0VfU0hJRlQpDQo+ICAgICogQHZhbGlk
OiBwZm5zIGFycmF5IGRpZCBub3QgY2hhbmdlIHNpbmNlIGl0IGhhcyBiZWVuIGZpbGwgYnkgYW4g
SE1NIGZ1bmN0aW9uDQo+ICAgICovDQo+IEBAIC0xNzIsMzEgKzE3MSwxMCBAQCBzdHJ1Y3QgaG1t
X3JhbmdlIHsNCj4gICAJY29uc3QgdWludDY0X3QJCSp2YWx1ZXM7DQo+ICAgCXVpbnQ2NF90CQlk
ZWZhdWx0X2ZsYWdzOw0KPiAgIAl1aW50NjRfdAkJcGZuX2ZsYWdzX21hc2s7DQo+IC0JdWludDhf
dAkJCXBhZ2Vfc2hpZnQ7DQo+ICAgCXVpbnQ4X3QJCQlwZm5fc2hpZnQ7DQo+ICAgCWJvb2wJCQl2
YWxpZDsNCj4gICB9Ow0KPiAgIA0KPiAtLyoNCj4gLSAqIGhtbV9yYW5nZV9wYWdlX3NoaWZ0KCkg
LSByZXR1cm4gdGhlIHBhZ2Ugc2hpZnQgZm9yIHRoZSByYW5nZQ0KPiAtICogQHJhbmdlOiByYW5n
ZSBiZWluZyBxdWVyaWVkDQo+IC0gKiBSZXR1cm46IHBhZ2Ugc2hpZnQgKHBhZ2Ugc2l6ZSA9IDEg
PDwgcGFnZSBzaGlmdCkgZm9yIHRoZSByYW5nZQ0KPiAtICovDQo+IC1zdGF0aWMgaW5saW5lIHVu
c2lnbmVkIGhtbV9yYW5nZV9wYWdlX3NoaWZ0KGNvbnN0IHN0cnVjdCBobW1fcmFuZ2UgKnJhbmdl
KQ0KPiAtew0KPiAtCXJldHVybiByYW5nZS0+cGFnZV9zaGlmdDsNCj4gLX0NCj4gLQ0KPiAtLyoN
Cj4gLSAqIGhtbV9yYW5nZV9wYWdlX3NpemUoKSAtIHJldHVybiB0aGUgcGFnZSBzaXplIGZvciB0
aGUgcmFuZ2UNCj4gLSAqIEByYW5nZTogcmFuZ2UgYmVpbmcgcXVlcmllZA0KPiAtICogUmV0dXJu
OiBwYWdlIHNpemUgZm9yIHRoZSByYW5nZSBpbiBieXRlcw0KPiAtICovDQo+IC1zdGF0aWMgaW5s
aW5lIHVuc2lnbmVkIGxvbmcgaG1tX3JhbmdlX3BhZ2Vfc2l6ZShjb25zdCBzdHJ1Y3QgaG1tX3Jh
bmdlICpyYW5nZSkNCj4gLXsNCj4gLQlyZXR1cm4gMVVMIDw8IGhtbV9yYW5nZV9wYWdlX3NoaWZ0
KHJhbmdlKTsNCj4gLX0NCj4gLQ0KPiAgIC8qDQo+ICAgICogaG1tX3JhbmdlX3dhaXRfdW50aWxf
dmFsaWQoKSAtIHdhaXQgZm9yIHJhbmdlIHRvIGJlIHZhbGlkDQo+ICAgICogQHJhbmdlOiByYW5n
ZSBhZmZlY3RlZCBieSBpbnZhbGlkYXRpb24gdG8gd2FpdCBvbg0KPiBkaWZmIC0tZ2l0IGEvbW0v
aG1tLmMgYi9tbS9obW0uYw0KPiBpbmRleCA5MjY3MzVhM2FlZjkuLmYyNmQ2YWJjNGVkMiAxMDA2
NDQNCj4gLS0tIGEvbW0vaG1tLmMNCj4gKysrIGIvbW0vaG1tLmMNCj4gQEAgLTM0NCwxMyArMzQ0
LDEyIEBAIHN0YXRpYyBpbnQgaG1tX3ZtYV93YWxrX2hvbGVfKHVuc2lnbmVkIGxvbmcgYWRkciwg
dW5zaWduZWQgbG9uZyBlbmQsDQo+ICAgCXN0cnVjdCBobW1fdm1hX3dhbGsgKmhtbV92bWFfd2Fs
ayA9IHdhbGstPnByaXZhdGU7DQo+ICAgCXN0cnVjdCBobW1fcmFuZ2UgKnJhbmdlID0gaG1tX3Zt
YV93YWxrLT5yYW5nZTsNCj4gICAJdWludDY0X3QgKnBmbnMgPSByYW5nZS0+cGZuczsNCj4gLQl1
bnNpZ25lZCBsb25nIGksIHBhZ2Vfc2l6ZTsNCj4gKwl1bnNpZ25lZCBsb25nIGk7DQo+ICAgDQo+
ICAgCWhtbV92bWFfd2Fsay0+bGFzdCA9IGFkZHI7DQo+IC0JcGFnZV9zaXplID0gaG1tX3Jhbmdl
X3BhZ2Vfc2l6ZShyYW5nZSk7DQo+IC0JaSA9IChhZGRyIC0gcmFuZ2UtPnN0YXJ0KSA+PiByYW5n
ZS0+cGFnZV9zaGlmdDsNCj4gKwlpID0gKGFkZHIgLSByYW5nZS0+c3RhcnQpID4+IFBBR0VfU0hJ
RlQ7DQo+ICAgDQo+IC0JZm9yICg7IGFkZHIgPCBlbmQ7IGFkZHIgKz0gcGFnZV9zaXplLCBpKysp
IHsNCj4gKwlmb3IgKDsgYWRkciA8IGVuZDsgYWRkciArPSBQQUdFX1NJWkUsIGkrKykgew0KPiAg
IAkJcGZuc1tpXSA9IHJhbmdlLT52YWx1ZXNbSE1NX1BGTl9OT05FXTsNCj4gICAJCWlmIChmYXVs
dCB8fCB3cml0ZV9mYXVsdCkgew0KPiAgIAkJCWludCByZXQ7DQo+IEBAIC03NzIsNyArNzcxLDcg
QEAgc3RhdGljIGludCBobW1fdm1hX3dhbGtfaHVnZXRsYl9lbnRyeShwdGVfdCAqcHRlLCB1bnNp
Z25lZCBsb25nIGhtYXNrLA0KPiAgIAkJCQkgICAgICBzdHJ1Y3QgbW1fd2FsayAqd2FsaykNCj4g
ICB7DQo+ICAgI2lmZGVmIENPTkZJR19IVUdFVExCX1BBR0UNCj4gLQl1bnNpZ25lZCBsb25nIGFk
ZHIgPSBzdGFydCwgaSwgcGZuLCBtYXNrLCBzaXplLCBwZm5faW5jOw0KPiArCXVuc2lnbmVkIGxv
bmcgYWRkciA9IHN0YXJ0LCBpLCBwZm4sIG1hc2s7DQo+ICAgCXN0cnVjdCBobW1fdm1hX3dhbGsg
KmhtbV92bWFfd2FsayA9IHdhbGstPnByaXZhdGU7DQo+ICAgCXN0cnVjdCBobW1fcmFuZ2UgKnJh
bmdlID0gaG1tX3ZtYV93YWxrLT5yYW5nZTsNCj4gICAJc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2
bWEgPSB3YWxrLT52bWE7DQo+IEBAIC03ODMsMjQgKzc4MiwxMiBAQCBzdGF0aWMgaW50IGhtbV92
bWFfd2Fsa19odWdldGxiX2VudHJ5KHB0ZV90ICpwdGUsIHVuc2lnbmVkIGxvbmcgaG1hc2ssDQo+
ICAgCXB0ZV90IGVudHJ5Ow0KPiAgIAlpbnQgcmV0ID0gMDsNCj4gICANCj4gLQlzaXplID0gaHVn
ZV9wYWdlX3NpemUoaCk7DQo+IC0JbWFzayA9IHNpemUgLSAxOw0KPiAtCWlmIChyYW5nZS0+cGFn
ZV9zaGlmdCAhPSBQQUdFX1NISUZUKSB7DQo+IC0JCS8qIE1ha2Ugc3VyZSB3ZSBhcmUgbG9va2lu
ZyBhdCBhIGZ1bGwgcGFnZS4gKi8NCj4gLQkJaWYgKHN0YXJ0ICYgbWFzaykNCj4gLQkJCXJldHVy
biAtRUlOVkFMOw0KPiAtCQlpZiAoZW5kIDwgKHN0YXJ0ICsgc2l6ZSkpDQo+IC0JCQlyZXR1cm4g
LUVJTlZBTDsNCj4gLQkJcGZuX2luYyA9IHNpemUgPj4gUEFHRV9TSElGVDsNCj4gLQl9IGVsc2Ug
ew0KPiAtCQlwZm5faW5jID0gMTsNCj4gLQkJc2l6ZSA9IFBBR0VfU0laRTsNCj4gLQl9DQo+ICsJ
bWFzayA9IGh1Z2VfcGFnZV9zaXplKGgpIC0gMTsNCj4gICANCj4gICAJcHRsID0gaHVnZV9wdGVf
bG9jayhoc3RhdGVfdm1hKHZtYSksIHdhbGstPm1tLCBwdGUpOw0KPiAgIAllbnRyeSA9IGh1Z2Vf
cHRlcF9nZXQocHRlKTsNCj4gICANCj4gLQlpID0gKHN0YXJ0IC0gcmFuZ2UtPnN0YXJ0KSA+PiBy
YW5nZS0+cGFnZV9zaGlmdDsNCj4gKwlpID0gKHN0YXJ0IC0gcmFuZ2UtPnN0YXJ0KSA+PiBQQUdF
X1NISUZUOw0KPiAgIAlvcmlnX3BmbiA9IHJhbmdlLT5wZm5zW2ldOw0KPiAgIAlyYW5nZS0+cGZu
c1tpXSA9IHJhbmdlLT52YWx1ZXNbSE1NX1BGTl9OT05FXTsNCj4gICAJY3B1X2ZsYWdzID0gcHRl
X3RvX2htbV9wZm5fZmxhZ3MocmFuZ2UsIGVudHJ5KTsNCj4gQEAgLTgxMiw4ICs3OTksOCBAQCBz
dGF0aWMgaW50IGhtbV92bWFfd2Fsa19odWdldGxiX2VudHJ5KHB0ZV90ICpwdGUsIHVuc2lnbmVk
IGxvbmcgaG1hc2ssDQo+ICAgCQlnb3RvIHVubG9jazsNCj4gICAJfQ0KPiAgIA0KPiAtCXBmbiA9
IHB0ZV9wZm4oZW50cnkpICsgKChzdGFydCAmIG1hc2spID4+IHJhbmdlLT5wYWdlX3NoaWZ0KTsN
Cj4gLQlmb3IgKDsgYWRkciA8IGVuZDsgYWRkciArPSBzaXplLCBpKyssIHBmbiArPSBwZm5faW5j
KQ0KPiArCXBmbiA9IHB0ZV9wZm4oZW50cnkpICsgKChzdGFydCAmIG1hc2spID4+IFBBR0VfU0hJ
RlQpOw0KPiArCWZvciAoOyBhZGRyIDwgZW5kOyBhZGRyICs9IFBBR0VfU0laRSwgaSsrLCBwZm4r
KykNCj4gICAJCXJhbmdlLT5wZm5zW2ldID0gaG1tX2RldmljZV9lbnRyeV9mcm9tX3BmbihyYW5n
ZSwgcGZuKSB8DQo+ICAgCQkJCSBjcHVfZmxhZ3M7DQo+ICAgCWhtbV92bWFfd2Fsay0+bGFzdCA9
IGVuZDsNCj4gQEAgLTg1MCwxNCArODM3LDEzIEBAIHN0YXRpYyB2b2lkIGhtbV9wZm5zX2NsZWFy
KHN0cnVjdCBobW1fcmFuZ2UgKnJhbmdlLA0KPiAgICAqLw0KPiAgIGludCBobW1fcmFuZ2VfcmVn
aXN0ZXIoc3RydWN0IGhtbV9yYW5nZSAqcmFuZ2UsIHN0cnVjdCBobW1fbWlycm9yICptaXJyb3Ip
DQo+ICAgew0KPiAtCXVuc2lnbmVkIGxvbmcgbWFzayA9ICgoMVVMIDw8IHJhbmdlLT5wYWdlX3No
aWZ0KSAtIDFVTCk7DQo+ICAgCXN0cnVjdCBobW0gKmhtbSA9IG1pcnJvci0+aG1tOw0KPiAgIAl1
bnNpZ25lZCBsb25nIGZsYWdzOw0KPiAgIA0KPiAgIAlyYW5nZS0+dmFsaWQgPSBmYWxzZTsNCj4g
ICAJcmFuZ2UtPmhtbSA9IE5VTEw7DQo+ICAgDQo+IC0JaWYgKChyYW5nZS0+c3RhcnQgJiBtYXNr
KSB8fCAocmFuZ2UtPmVuZCAmIG1hc2spKQ0KPiArCWlmICgocmFuZ2UtPnN0YXJ0ICYgKFBBR0Vf
U0laRSAtIDEpKSB8fCAocmFuZ2UtPmVuZCAmIChQQUdFX1NJWkUgLSAxKSkpDQo+ICAgCQlyZXR1
cm4gLUVJTlZBTDsNCj4gICAJaWYgKHJhbmdlLT5zdGFydCA+PSByYW5nZS0+ZW5kKQ0KPiAgIAkJ
cmV0dXJuIC1FSU5WQUw7DQo+IEBAIC05NjQsMTYgKzk1MCw2IEBAIGxvbmcgaG1tX3JhbmdlX2Zh
dWx0KHN0cnVjdCBobW1fcmFuZ2UgKnJhbmdlLCB1bnNpZ25lZCBpbnQgZmxhZ3MpDQo+ICAgCQlp
ZiAodm1hID09IE5VTEwgfHwgKHZtYS0+dm1fZmxhZ3MgJiBkZXZpY2Vfdm1hKSkNCj4gICAJCQly
ZXR1cm4gLUVGQVVMVDsNCj4gICANCj4gLQkJaWYgKGlzX3ZtX2h1Z2V0bGJfcGFnZSh2bWEpKSB7
DQo+IC0JCQlpZiAoaHVnZV9wYWdlX3NoaWZ0KGhzdGF0ZV92bWEodm1hKSkgIT0NCj4gLQkJCSAg
ICByYW5nZS0+cGFnZV9zaGlmdCAmJg0KPiAtCQkJICAgIHJhbmdlLT5wYWdlX3NoaWZ0ICE9IFBB
R0VfU0hJRlQpDQo+IC0JCQkJcmV0dXJuIC1FSU5WQUw7DQo+IC0JCX0gZWxzZSB7DQo+IC0JCQlp
ZiAocmFuZ2UtPnBhZ2Vfc2hpZnQgIT0gUEFHRV9TSElGVCkNCj4gLQkJCQlyZXR1cm4gLUVJTlZB
TDsNCj4gLQkJfQ0KPiAtDQo+ICAgCQlpZiAoISh2bWEtPnZtX2ZsYWdzICYgVk1fUkVBRCkpIHsN
Cj4gICAJCQkvKg0KPiAgIAkJCSAqIElmIHZtYSBkbyBub3QgYWxsb3cgcmVhZCBhY2Nlc3MsIHRo
ZW4gYXNzdW1lIHRoYXQgaXQNCg==

