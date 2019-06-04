Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E87AC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:46:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4817624A1A
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:46:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="ynNgfZ2/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4817624A1A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D55296B026E; Tue,  4 Jun 2019 07:46:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D06C86B0272; Tue,  4 Jun 2019 07:46:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA66C6B0273; Tue,  4 Jun 2019 07:46:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6626B026E
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 07:46:45 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z16so10372004qto.10
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 04:46:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=DqUjcMcbMs7i/otuz38agqtYdmvPCMOB96DAhTDcH7M=;
        b=relCp1e98e3HyuIsOlw2fDN6dHsUeO2ppgUgZfwSYreOlG/d1Bg/W48kwuFQACWwRV
         7UovBHFr+UUjtOsENcUf1InShcyzeZbzmgaFsZVIFrKdZdjItOo6Il2kRBV2pVeGpkqw
         RQ3VpgREuCA83Q5/UCvVOeGONlHmXfYEtXm9K8dboC8GCXCjHM/GmF8UxapZ5mGOpgQj
         dbmFBSEnQotBovS5AfxcjC4abjwyl1VzQmdvckpXYJN3xdgGZFim380mTsn3bkcX6PcN
         yQGcGQ4O5k8eXweQtsz0TihbUMeyirxVKpHw4zm+oG2VY8Ice4jQNkaVwwtjpRTaTyRv
         Tm0g==
X-Gm-Message-State: APjAAAVqynaMpFTNEhS7TrGCoHLikfPUqUEuMLr/vlN7Yz1ud7QNpRpo
	QTagF41bxyKRMgQFrM6unYkZkhwL/uLk729uXtfj13jXybOox2q7az4v4u2kdt1p+0TBCKQLLOz
	MvHcsp9QyglqO+RhZfBRCQVRyDJnMEpDy4pLT/QR8LozUXlUI301Dw5mIkAwIHWs=
X-Received: by 2002:ac8:2448:: with SMTP id d8mr28252234qtd.197.1559648805262;
        Tue, 04 Jun 2019 04:46:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLfryTaUMRJszO7q/RzctbbGFclE7U77xVu1O6xMw+LU1mEQ4ymKSjwwyNxbtUbZy2csc1
X-Received: by 2002:ac8:2448:: with SMTP id d8mr28252184qtd.197.1559648804785;
        Tue, 04 Jun 2019 04:46:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559648804; cv=none;
        d=google.com; s=arc-20160816;
        b=tjTvy2vA16HoRjiOU/HGnGJDgKeeoZg4YpQs8Zh8J8bI/c7YEMQ781E129QHe/4i5K
         eX7OaLFgFm/Gfp6RhSWyQYCCbXgDyTO3K5HSAqZRhZobc1xgvKFegEaZJXXJaFIoGkYB
         Yw0kzjKSU1H4UlzqrlvXKbMY10K477rKx9OFjZEV7dpx8C/eEVhS6Ovv885PuwSzvNa5
         aI8iwS+CE72SIkgIFxjSANIzv5GhJC4JCvCkxGQuQCqWd0FgydwH31l3zglgV90lBOtr
         1rHxYxXbnfSHgxb3h69Qqs6GKWsa8++H2/Wx1AClQ5S7JRR15iYyindAjA8XV7Z0F2af
         c9wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=DqUjcMcbMs7i/otuz38agqtYdmvPCMOB96DAhTDcH7M=;
        b=GYokDQqez3/4YuzUKBbwXQ1uNXYhxi2yDVxp0h2YSjKye8JctXLgXycMmqzH3/Bqn9
         pw9n3qkFlDIG+KXojm9N4nrJ/9Dfm7/1lPD9vDJacrSDvK3sQVIlt53fjQtFcADLQTrV
         wqB7F0N3Q2xsRZMdEuPbh+jYwj+sk56pJIrfMmIo6VSB+x5YFznbZtum94mxdYcRTYQ7
         JL1G6UaCIDYSP+iJyKhxntRfbEIkCeDFwBQc6EHGHrCilr6AFxTx65ubbHSbTwFA5Mrf
         tSb2plnvNv0L0uGz/aGgzQX9CmtJ8nokyoLpIn6wYBbmviCJ925m2mUvzAqZ+mbCCxv9
         hBmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b="ynNgfZ2/";
       spf=neutral (google.com: 40.107.71.81 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) smtp.mailfrom=Christian.Koenig@amd.com
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710081.outbound.protection.outlook.com. [40.107.71.81])
        by mx.google.com with ESMTPS id v91si1026635qvv.1.2019.06.04.04.46.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 04 Jun 2019 04:46:44 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.71.81 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) client-ip=40.107.71.81;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b="ynNgfZ2/";
       spf=neutral (google.com: 40.107.71.81 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) smtp.mailfrom=Christian.Koenig@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=DqUjcMcbMs7i/otuz38agqtYdmvPCMOB96DAhTDcH7M=;
 b=ynNgfZ2/NknECAm/daCNfCH29Z1DxAsuwfFuBhdlp1+VB3OacXYoJ26WcvWqRM+bPN33FbGpNWdzgF+TDJydRUFhqWePfwJaUUL01/yI/w9fdPPebdgskMYB8omtC5fOo2fAlv4Hg0Z1OZL8yLLuUfO003hADVZfXaLXk34wF/U=
Received: from DM5PR12MB1546.namprd12.prod.outlook.com (10.172.36.23) by
 DM5PR12MB2454.namprd12.prod.outlook.com (52.132.141.35) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1943.22; Tue, 4 Jun 2019 11:46:39 +0000
Received: from DM5PR12MB1546.namprd12.prod.outlook.com
 ([fe80::e1b1:5b6f:b2df:afa5]) by DM5PR12MB1546.namprd12.prod.outlook.com
 ([fe80::e1b1:5b6f:b2df:afa5%7]) with mapi id 15.20.1943.018; Tue, 4 Jun 2019
 11:46:39 +0000
From: "Koenig, Christian" <Christian.Koenig@amd.com>
To: Andrey Konovalov <andreyknvl@google.com>, Linus Torvalds
	<torvalds@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino
	<vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland
	<mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook
	<keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, "Kuehling,
 Felix" <Felix.Kuehling@amd.com>, "Deucher, Alexander"
	<Alexander.Deucher@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Jens
 Wiklander <jens.wiklander@linaro.org>, Alex Williamson
	<alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, Luc Van
 Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe
	<jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov
	<dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov
	<eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan
	<Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben
 Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH] uaccess: add noop untagged_addr definition
Thread-Topic: [PATCH] uaccess: add noop untagged_addr definition
Thread-Index: AQHVGsrrPMdhu+tmg0GkOarNrJ33baaLYLQA
Date: Tue, 4 Jun 2019 11:46:39 +0000
Message-ID: <d74b1621-70a2-94a0-e24b-dae32adc457d@amd.com>
References:
 <8ab5cd1813b0890f8780018e9784838456ace49e.1559648669.git.andreyknvl@google.com>
In-Reply-To:
 <8ab5cd1813b0890f8780018e9784838456ace49e.1559648669.git.andreyknvl@google.com>
Accept-Language: de-DE, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
x-originating-ip: [2a02:908:1252:fb60:be8a:bd56:1f94:86e7]
x-clientproxiedby: AM0PR02CA0063.eurprd02.prod.outlook.com
 (2603:10a6:208:d2::40) To DM5PR12MB1546.namprd12.prod.outlook.com
 (2603:10b6:4:8::23)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Christian.Koenig@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b5afe70f-bd4c-4ef0-b2cd-08d6e8e24e58
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM5PR12MB2454;
x-ms-traffictypediagnostic: DM5PR12MB2454:
x-microsoft-antispam-prvs:
 <DM5PR12MB24547D2498D24083A63E19D283150@DM5PR12MB2454.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 0058ABBBC7
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(396003)(376002)(39860400002)(346002)(366004)(189003)(199004)(102836004)(5660300002)(2501003)(64126003)(8676002)(81156014)(6116002)(186003)(4326008)(76176011)(8936002)(6246003)(81166006)(71200400001)(71190400001)(110136005)(54906003)(31696002)(2201001)(2906002)(86362001)(316002)(58126008)(53936002)(256004)(478600001)(65806001)(46003)(72206003)(52116002)(6506007)(386003)(2616005)(11346002)(7406005)(36756003)(99286004)(66446008)(476003)(66946007)(6512007)(6436002)(66476007)(446003)(66556008)(64756008)(6486002)(25786009)(31686004)(305945005)(14454004)(68736007)(65826007)(65956001)(7416002)(7736002)(73956011)(229853002)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR12MB2454;H:DM5PR12MB1546.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 BTUYgxf6LVWOUaiXhcDIXPqKTGV8JQlWKUiPF7BHdbvpw2EvuLfEKVhud6WGOw6XmPZVynz+zFRdlpYHRE+F115S+IxcRZYuBeIszGrpu7pC+Mi3Ag3+SBFn3MMIDq6u1vKLEWfXeseTdLxby6CeBXAVKtxYbNkKrIIB7V9aVaK8l8wAfEPyVezvSDCjDWmnwomXsU5xfFG5P8PaLwINRy3oGBUDJZpLI1NUyE2GNqzPywtHVYVZMAeYxK0vjd6mWOG5cJax0LwhWWa/LNNXowMjWOfP1+QGM5GIHhT34T11+CzGzg2QOSyJUHRWAbLMrgwWYBL6yToCAnpGvRtevQxUkyvCv3ibiDQogv5Xmh6DezwDp6vDKQStVUSjqpID+69S03umWcSxh5dt31HX3NwqHJJagQ6m5NyGv2bCVFc=
Content-Type: text/plain; charset="utf-8"
Content-ID: <71D9DBF4A3B16B4F887771F2B480FC3F@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b5afe70f-bd4c-4ef0-b2cd-08d6e8e24e58
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Jun 2019 11:46:39.8145
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: ckoenig@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR12MB2454
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

QW0gMDQuMDYuMTkgdW0gMTM6NDQgc2NocmllYiBBbmRyZXkgS29ub3ZhbG92Og0KPiBBcmNoaXRl
Y3R1cmVzIHRoYXQgc3VwcG9ydCBtZW1vcnkgdGFnZ2luZyBoYXZlIGEgbmVlZCB0byBwZXJmb3Jt
IHVudGFnZ2luZw0KPiAoc3RyaXBwaW5nIHRoZSB0YWcpIGluIHZhcmlvdXMgcGFydHMgb2YgdGhl
IGtlcm5lbC4gVGhpcyBwYXRjaCBhZGRzIGFuDQo+IHVudGFnZ2VkX2FkZHIoKSBtYWNybywgd2hp
Y2ggaXMgZGVmaW5lZCBhcyBub29wIGZvciBhcmNoaXRlY3R1cmVzIHRoYXQgZG8NCj4gbm90IHN1
cHBvcnQgbWVtb3J5IHRhZ2dpbmcuIFRoZSBvbmNvbWluZyBwYXRjaCBzZXJpZXMgd2lsbCBkZWZp
bmUgaXQgYXQNCj4gbGVhc3QgZm9yIHNwYXJjNjQgYW5kIGFybTY0Lg0KPg0KPiBBY2tlZC1ieTog
Q2F0YWxpbiBNYXJpbmFzIDxjYXRhbGluLm1hcmluYXNAYXJtLmNvbT4NCj4gUmV2aWV3ZWQtYnk6
IEtoYWxpZCBBeml6IDxraGFsaWQuYXppekBvcmFjbGUuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBB
bmRyZXkgS29ub3ZhbG92IDxhbmRyZXlrbnZsQGdvb2dsZS5jb20+DQo+IC0tLQ0KPiAgIGluY2x1
ZGUvbGludXgvbW0uaCB8IDQgKysrKw0KPiAgIDEgZmlsZSBjaGFuZ2VkLCA0IGluc2VydGlvbnMo
KykNCj4NCj4gZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvbW0uaCBiL2luY2x1ZGUvbGludXgv
bW0uaA0KPiBpbmRleCAwZTg4MzRhYzMyYjcuLjk0OWQ0M2U5YzBiNiAxMDA2NDQNCj4gLS0tIGEv
aW5jbHVkZS9saW51eC9tbS5oDQo+ICsrKyBiL2luY2x1ZGUvbGludXgvbW0uaA0KPiBAQCAtOTks
NiArOTksMTAgQEAgZXh0ZXJuIGludCBtbWFwX3JuZF9jb21wYXRfYml0cyBfX3JlYWRfbW9zdGx5
Ow0KPiAgICNpbmNsdWRlIDxhc20vcGd0YWJsZS5oPg0KPiAgICNpbmNsdWRlIDxhc20vcHJvY2Vz
c29yLmg+DQo+ICAgDQo+ICsjaWZuZGVmIHVudGFnZ2VkX2FkZHINCj4gKyNkZWZpbmUgdW50YWdn
ZWRfYWRkcihhZGRyKSAoYWRkcikNCj4gKyNlbmRpZg0KPiArDQoNCk1heWJlIGFkZCBhIGNvbW1l
bnQgd2hhdCB0YWdnaW5nIGFjdHVhbGx5IGlzPyBDYXVzZSB0aGF0IGlzIG5vdCByZWFsbHkgDQpv
YnZpb3VzIGZyb20gdGhlIGNvbnRleHQuDQoNCkNocmlzdGlhbi4NCg0KPiAgICNpZm5kZWYgX19w
YV9zeW1ib2wNCj4gICAjZGVmaW5lIF9fcGFfc3ltYm9sKHgpICBfX3BhKFJFTE9DX0hJREUoKHVu
c2lnbmVkIGxvbmcpKHgpLCAwKSkNCj4gICAjZW5kaWYNCg0K

