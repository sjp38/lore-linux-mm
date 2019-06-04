Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B63BC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:49:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAC962133D
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:49:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="08LvuO6n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAC962133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 760326B0273; Tue,  4 Jun 2019 07:49:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 710C66B0276; Tue,  4 Jun 2019 07:49:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 563DA6B0277; Tue,  4 Jun 2019 07:49:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 263786B0273
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 07:49:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t196so3349794qke.0
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 04:49:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=AuvUjLTuUv06KHwWBNifnh3rfmmJqB0eNoQmoWoPShM=;
        b=aurIG0EOZZl1/MxpIq1l3HI7Txyt+VijEx2lqeE7dnDKm+7fFu7wnFqgzB0VaEFGFU
         cSVGsamNu/4fJ3vMfDfsnRIvkYY632Jl4SbIjcQPeu7DI4PaegJhNWSNEBmVXqRXTwFc
         Bjtn615ffyjNaGaMs51RToMJRv33aSuuAsE2c1gk9blb1fgQsmNRrG3e7m/KX9Ymeskb
         0KUtsHoFuus3/jf7n9vjwZq47iDnEba4iNJKOaHR4Pmg3gqlFfcYTUp0sv2UJ/Tcn1RS
         yoomUY46UldYjmlmOI4k8P4Qd4AnmVVI7pVOQR/hyjX/UbLSivpfaTNmxTizqJQFbZuK
         U3vQ==
X-Gm-Message-State: APjAAAW513RiQYmBqZ4jM7KwAoIpBJeWt9GVBwEtzcSlwnU9ceW5WFiw
	DDp8hB6TlOlL5U1Oe7iG9iYczI2tkYqx2qUdseFvAlfbdDUs9L5eryGIwcZkQNl0SGaD1inNwWM
	6tP1DrmoBWhCgr9UjLXG5eBuITl8u1lRWeP5HvKJ6fC+mWlRWHReAUGaPCl7EpH0=
X-Received: by 2002:a37:8e03:: with SMTP id q3mr27448593qkd.234.1559648995878;
        Tue, 04 Jun 2019 04:49:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8v810oW45EsmT50HPYPT8+1Fjnq/TPMKwECv7lndNn5OQcgGdJv/d9Z4aVKBmcaHWFx2N
X-Received: by 2002:a37:8e03:: with SMTP id q3mr27448554qkd.234.1559648995355;
        Tue, 04 Jun 2019 04:49:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559648995; cv=none;
        d=google.com; s=arc-20160816;
        b=vDK31mwaXWffmqtLGtNlafF6Cy57TREw/6A8woL1b8DAPMyagkdE3xjnVLo2HWsWmR
         0lEmRGLOjKMJF6ZoWGIsqavxxAUnifmKszUVOisNpazISwnIb7yJJjsT1OBVlvo2xGuf
         ter6VampEpUEzUw9iku67QQuKFkJMSx+0pUyXierlTLaJM6a5Z/8YxbFztPWGw7Kv1up
         UqA8aGqESrlNwvy4nusj6K+VnmfyMHakvmBam7PSAFHrEVgv+pcR+FCB3fTlTZJa69I5
         ocd3lZS1Ncy9wRqIyfQ8I4QYwTpHiqsH/BZzG+hAXz8P/3B6+1HPq7WuBJfetyruqlbx
         TCww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=AuvUjLTuUv06KHwWBNifnh3rfmmJqB0eNoQmoWoPShM=;
        b=JlOWj8ZBjvOlY+kKyJ0ct0q8ozxFElMG7hRo/LzMYpOFul3EIZVpetBULayLVHlkKL
         KioVRge1FpbyRXj/Hc7epP8s3k3cly7H47wFxYDouOzzAj+E/9OQyDBAOVTnisBgQHqD
         x4ljXpzzhibrnOG5dHkeDCLvMvB5Lhy0Lvyhr7qdiMpUkSx8tjh0OXymNpz/95Hr66ga
         cIy93b+IXYWWW1i2bcEi0iERtKPim7lwPBOF2/boooiKXHSKV8vSngcgLtTU9JBx5kl3
         avAWo/hbYhDWM0c/uUn8eM/A9NEpbTAQpXlDGdgJZFRQCJ6mrcuZOoGs9En/Lla9nGIc
         LqnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=08LvuO6n;
       spf=neutral (google.com: 40.107.68.62 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) smtp.mailfrom=Christian.Koenig@amd.com
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680062.outbound.protection.outlook.com. [40.107.68.62])
        by mx.google.com with ESMTPS id 2si2072737qtc.41.2019.06.04.04.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 04:49:55 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.68.62 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) client-ip=40.107.68.62;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=08LvuO6n;
       spf=neutral (google.com: 40.107.68.62 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) smtp.mailfrom=Christian.Koenig@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=AuvUjLTuUv06KHwWBNifnh3rfmmJqB0eNoQmoWoPShM=;
 b=08LvuO6nLT19eMwPqCH/JHlwPE3DwNgnlsl2k7pTfzleHgzS2iJAnFtTvYg3BL7PVRXdi+G3MFLUWXitq6BDoqKMIYUj58W24YWtmo6PTEAHWvmKrWjA8+rle3r8zIYtKe2W6ZMG8sj2+31r+4jsWGa+vvrpuj69i86DQhZs070=
Received: from DM5PR12MB1546.namprd12.prod.outlook.com (10.172.36.23) by
 DM5PR12MB1865.namprd12.prod.outlook.com (10.175.87.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1943.22; Tue, 4 Jun 2019 11:49:52 +0000
Received: from DM5PR12MB1546.namprd12.prod.outlook.com
 ([fe80::e1b1:5b6f:b2df:afa5]) by DM5PR12MB1546.namprd12.prod.outlook.com
 ([fe80::e1b1:5b6f:b2df:afa5%7]) with mapi id 15.20.1943.018; Tue, 4 Jun 2019
 11:49:52 +0000
From: "Koenig, Christian" <Christian.Koenig@amd.com>
To: Andrey Konovalov <andreyknvl@google.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin
 Marinas <catalin.marinas@arm.com>, Vincenzo Frascino
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
Thread-Index: AQHVGsrrPMdhu+tmg0GkOarNrJ33baaLYLQAgAAAcYCAAAB0AA==
Date: Tue, 4 Jun 2019 11:49:52 +0000
Message-ID: <ff73058a-f57b-526b-af53-c0e30b7b1bc1@amd.com>
References:
 <8ab5cd1813b0890f8780018e9784838456ace49e.1559648669.git.andreyknvl@google.com>
 <d74b1621-70a2-94a0-e24b-dae32adc457d@amd.com>
 <CAAeHK+w0_9QdxCJXEf=6nMgZpsb8NyrAaMO010Hh86TW75jJvw@mail.gmail.com>
In-Reply-To:
 <CAAeHK+w0_9QdxCJXEf=6nMgZpsb8NyrAaMO010Hh86TW75jJvw@mail.gmail.com>
Accept-Language: de-DE, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
x-originating-ip: [2a02:908:1252:fb60:be8a:bd56:1f94:86e7]
x-clientproxiedby: AM6P195CA0004.EURP195.PROD.OUTLOOK.COM
 (2603:10a6:209:81::17) To DM5PR12MB1546.namprd12.prod.outlook.com
 (2603:10b6:4:8::23)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Christian.Koenig@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b797c529-0a71-4368-46eb-08d6e8e2c115
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM5PR12MB1865;
x-ms-traffictypediagnostic: DM5PR12MB1865:
x-microsoft-antispam-prvs:
 <DM5PR12MB1865BD38A6AC9E0DE3677D0283150@DM5PR12MB1865.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0058ABBBC7
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(346002)(376002)(136003)(396003)(39860400002)(189003)(199004)(6486002)(65806001)(46003)(66446008)(8936002)(65956001)(2616005)(7736002)(476003)(66556008)(71200400001)(71190400001)(52116002)(81166006)(6436002)(7406005)(64756008)(229853002)(6512007)(81156014)(31696002)(14454004)(72206003)(316002)(66476007)(86362001)(4326008)(53936002)(8676002)(478600001)(36756003)(65826007)(99286004)(6506007)(256004)(6116002)(5660300002)(7416002)(54906003)(76176011)(305945005)(186003)(66946007)(73956011)(58126008)(11346002)(64126003)(68736007)(53546011)(31686004)(486006)(386003)(6916009)(102836004)(6246003)(2906002)(25786009)(446003);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR12MB1865;H:DM5PR12MB1546.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 14omzt9GIzLZUiQb3h6pGr9c5vOsiSoeWiuS9rOVo2NJXEndL9vpilTVBtxnECz0dUf7+DLZcPeXxb58B9jDZb7k5raKDR769KHtEr67sq19O8mDLmNc27LQkKTPWgXH8b76BGLA/XKceBqIJzN0rmhZJKLfj6iiHNNwdZN6ws697P0AfrH+XnOlPo1wSsf0EjJShvO1EiT1x5dkcfQmKZygt+Ug5RqmyrHD0LEH2VxwLynFlKTxnSUPhdvgL5kiztR7R9lCdJZiDYCn190kDIuPUVMcvmOdWG7mnPNxlRvVZkt8aZB54rsMOcUhqxEY9UL/k0NVKLMpTTtwpsyilZf/TMp8FK6wJxSa+DeoPs8FV1QAKVQwmZFyP55LnD3MMr4YmiUF+qyj9IlXhD/6s4xLnUIAX95bW8ZbeQ1/fv8=
Content-Type: text/plain; charset="utf-8"
Content-ID: <18F83B8CBEA40C4E8B90F01B157267FB@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b797c529-0a71-4368-46eb-08d6e8e2c115
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Jun 2019 11:49:52.4528
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: ckoenig@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR12MB1865
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

QW0gMDQuMDYuMTkgdW0gMTM6NDggc2NocmllYiBBbmRyZXkgS29ub3ZhbG92Og0KPiBPbiBUdWUs
IEp1biA0LCAyMDE5IGF0IDE6NDYgUE0gS29lbmlnLCBDaHJpc3RpYW4NCj4gPENocmlzdGlhbi5L
b2VuaWdAYW1kLmNvbT4gd3JvdGU6DQo+PiBBbSAwNC4wNi4xOSB1bSAxMzo0NCBzY2hyaWViIEFu
ZHJleSBLb25vdmFsb3Y6DQo+Pj4gQXJjaGl0ZWN0dXJlcyB0aGF0IHN1cHBvcnQgbWVtb3J5IHRh
Z2dpbmcgaGF2ZSBhIG5lZWQgdG8gcGVyZm9ybSB1bnRhZ2dpbmcNCj4+PiAoc3RyaXBwaW5nIHRo
ZSB0YWcpIGluIHZhcmlvdXMgcGFydHMgb2YgdGhlIGtlcm5lbC4gVGhpcyBwYXRjaCBhZGRzIGFu
DQo+Pj4gdW50YWdnZWRfYWRkcigpIG1hY3JvLCB3aGljaCBpcyBkZWZpbmVkIGFzIG5vb3AgZm9y
IGFyY2hpdGVjdHVyZXMgdGhhdCBkbw0KPj4+IG5vdCBzdXBwb3J0IG1lbW9yeSB0YWdnaW5nLiBU
aGUgb25jb21pbmcgcGF0Y2ggc2VyaWVzIHdpbGwgZGVmaW5lIGl0IGF0DQo+Pj4gbGVhc3QgZm9y
IHNwYXJjNjQgYW5kIGFybTY0Lg0KPj4+DQo+Pj4gQWNrZWQtYnk6IENhdGFsaW4gTWFyaW5hcyA8
Y2F0YWxpbi5tYXJpbmFzQGFybS5jb20+DQo+Pj4gUmV2aWV3ZWQtYnk6IEtoYWxpZCBBeml6IDxr
aGFsaWQuYXppekBvcmFjbGUuY29tPg0KPj4+IFNpZ25lZC1vZmYtYnk6IEFuZHJleSBLb25vdmFs
b3YgPGFuZHJleWtudmxAZ29vZ2xlLmNvbT4NCj4+PiAtLS0NCj4+PiAgICBpbmNsdWRlL2xpbnV4
L21tLmggfCA0ICsrKysNCj4+PiAgICAxIGZpbGUgY2hhbmdlZCwgNCBpbnNlcnRpb25zKCspDQo+
Pj4NCj4+PiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9tbS5oIGIvaW5jbHVkZS9saW51eC9t
bS5oDQo+Pj4gaW5kZXggMGU4ODM0YWMzMmI3Li45NDlkNDNlOWMwYjYgMTAwNjQ0DQo+Pj4gLS0t
IGEvaW5jbHVkZS9saW51eC9tbS5oDQo+Pj4gKysrIGIvaW5jbHVkZS9saW51eC9tbS5oDQo+Pj4g
QEAgLTk5LDYgKzk5LDEwIEBAIGV4dGVybiBpbnQgbW1hcF9ybmRfY29tcGF0X2JpdHMgX19yZWFk
X21vc3RseTsNCj4+PiAgICAjaW5jbHVkZSA8YXNtL3BndGFibGUuaD4NCj4+PiAgICAjaW5jbHVk
ZSA8YXNtL3Byb2Nlc3Nvci5oPg0KPj4+DQo+Pj4gKyNpZm5kZWYgdW50YWdnZWRfYWRkcg0KPj4+
ICsjZGVmaW5lIHVudGFnZ2VkX2FkZHIoYWRkcikgKGFkZHIpDQo+Pj4gKyNlbmRpZg0KPj4+ICsN
Cj4+IE1heWJlIGFkZCBhIGNvbW1lbnQgd2hhdCB0YWdnaW5nIGFjdHVhbGx5IGlzPyBDYXVzZSB0
aGF0IGlzIG5vdCByZWFsbHkNCj4+IG9idmlvdXMgZnJvbSB0aGUgY29udGV4dC4NCj4gSGksDQo+
DQo+IERvIHlvdSBtZWFuIGEgY29tbWVudCBpbiB0aGUgY29kZSBvciBhbiBleHBsYW5hdGlvbiBp
biB0aGUgcGF0Y2ggZGVzY3JpcHRpb24/DQoNClRoZSBjb2RlLCB0aGUgcGF0Y2ggZGVzY3JpcHRp
b24gYWN0dWFsbHkgc291bmRzIGdvb2QgdG8gbWUuDQoNCkNocmlzdGlhbi4NCg0KPg0KPiBUaGFu
a3MhDQo+DQo+PiBDaHJpc3RpYW4uDQo+Pg0KPj4+ICAgICNpZm5kZWYgX19wYV9zeW1ib2wNCj4+
PiAgICAjZGVmaW5lIF9fcGFfc3ltYm9sKHgpICBfX3BhKFJFTE9DX0hJREUoKHVuc2lnbmVkIGxv
bmcpKHgpLCAwKSkNCj4+PiAgICAjZW5kaWYNCg0K

