Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1B75C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:33:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 708772133F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:33:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="V/nOFIy6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 708772133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03B518E0003; Tue, 18 Jun 2019 01:33:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2CB68E0001; Tue, 18 Jun 2019 01:33:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCE268E0003; Tue, 18 Jun 2019 01:33:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id B07A78E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:33:15 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id w123so4465722oie.21
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 22:33:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=JBj+6gPNppaLfSon7xS8n0B5MCFhpTaR8lqFB4mqKV8=;
        b=XFdcmpiv+xzsAlLpK6pQNIC2T53u3JgMWro1mn6jCSrtqh7WoYXNvR9g9mgRwjkBOV
         UzEIxcK14SZpJAZ6yCqmzRCXr8NuZ1DEVFQDrveyGZ19yUY8WScTM6PhkyQ6tVk9DHtK
         koVNQ8Fk9/Zx/H6DQkaN0Soz61QCO32gjilTWnrTS2fK0KR7NI2GguMUD2pAT4XHl+5p
         3PpZKLzUi7ZDywDZZei9bCHh9vZnvZrGdaMNw6t/T0mQx4rZxjLKccU3q2FiahbTlBON
         +hOIidySfm29Gt7dh7C4Ws4DsFV4lzQpTAkDm8jms5m5pvtQ6fcizdZ/l8/z+THje1lX
         9ajQ==
X-Gm-Message-State: APjAAAUeQ44RxKgkTrPLiPFkIrO5c/9kKgyWtdjDjNkxh0fuq70hr1eq
	Ao2NQsnbJkCxQ6BHNAR5EGk1LHULJHEmr6Q3fLDNkiKNHkvCCoIF2PqpQkQXSE4IvqgGmeZ5kAt
	co51R/OpYEkPrQVhSHBuEr32eSMk5ln8l6RCO2kKJDxv8evO57bvIKc6vMrGdkElw/g==
X-Received: by 2002:a9d:774a:: with SMTP id t10mr4061359otl.228.1560835995206;
        Mon, 17 Jun 2019 22:33:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3siRoauQVZD+z++/Nt2kLMumb+W/yo2zD8vT0dscqnpbHGNuI3MkpIQiQPVDJWkadn5Cj
X-Received: by 2002:a9d:774a:: with SMTP id t10mr4061281otl.228.1560835994171;
        Mon, 17 Jun 2019 22:33:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560835994; cv=none;
        d=google.com; s=arc-20160816;
        b=Uy5nOztb4szw2lK5AXHtEaKMOd9VUET4nxV2jne+s+lrmuiYMUVX5g1Rox5r5msfG8
         dcpViuD0mSIcdqcdlMAySNPqnFC1el9ylhH4bpvJrYoj/GxGGYL5DM98VkxZZNjWFQCm
         hgVMj3O9eLePhl9r8tYhfvPkqryEMnH6YsnEU0GHK1XnotvI9rQ0QNk35UqjdmWeW9aX
         BcZGbzpQ/R058zQhCD4r24zp0LdGwE9AMXQsaI3RtgTaJebP6buWXjAMdwORu665QRge
         U8Bot9rCxqCfRTnFVaTlwC4d51Fp1PD0U1N4aKcXMYxWbKQdNcDuhbIXyKxg1o7Kdst1
         83dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=JBj+6gPNppaLfSon7xS8n0B5MCFhpTaR8lqFB4mqKV8=;
        b=LsOp+OXMj2iK/nEudZT57VvKAlr1irtSQIrbfEArPuibDUf3654ES5L3PtOlh5S9bb
         tNv9wHveOpMcPcfVHYEg4htE8Gebhkapu4ZpPczK6D5YYx+knuUTZar0UK+gRukbg/7Z
         p4I14+ta0n0tzbv4DAG87pYXazffEzBGvQZCBM2Y5LC9F7hk5N9GYzkaDT0U58L8bhCD
         lORW1/p94F0gu0uaXlKe+E7Kz5ALldxjlE1lRtdpGJBqPKVkSssOWQ9rylw1EuSlZawk
         s6siFubrE0V3EAyfmP2uKnzuyu2D9ZKyOi1vJQ/CTZB2LC+QKWHDSqSPBp3M+WREYbs4
         +l1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b="V/nOFIy6";
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.77.75 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-eopbgr770075.outbound.protection.outlook.com. [40.107.77.75])
        by mx.google.com with ESMTPS id k190si7179930oih.206.2019.06.17.22.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jun 2019 22:33:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.77.75 as permitted sender) client-ip=40.107.77.75;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b="V/nOFIy6";
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.77.75 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=JBj+6gPNppaLfSon7xS8n0B5MCFhpTaR8lqFB4mqKV8=;
 b=V/nOFIy6yWCfsC7FstmTWZQ6j8bu4WmTJOJ6itnrcggA0SKkjrrXEbq0QKSvLunUmAHz8zpXg2fGeGnjwzzmL2iS4s2iBIusi2N28mxWakZ3JfO7BGRXeIwKN5DriuKh5aOydU3Xxn8IMW8M694NnwmpcfKA1iqakq4FBvKE0yI=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB6312.namprd05.prod.outlook.com (20.178.51.89) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.11; Tue, 18 Jun 2019 05:33:12 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58%7]) with mapi id 15.20.2008.007; Tue, 18 Jun 2019
 05:33:12 +0000
From: Nadav Amit <namit@vmware.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra
	<peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
	Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/3] resource: Introduce resource cache
Thread-Topic: [PATCH 3/3] resource: Introduce resource cache
Thread-Index: AQHVIaTIgkJbYpRVG0mXAw73pWsOuqag4XgAgAAJ4gA=
Date: Tue, 18 Jun 2019 05:33:12 +0000
Message-ID: <98464609-8F5A-47B9-A64E-2F67809737AD@vmware.com>
References: <20190613045903.4922-1-namit@vmware.com>
 <20190613045903.4922-4-namit@vmware.com>
 <20190617215750.8e46ae846c09cd5c1f22fdf9@linux-foundation.org>
In-Reply-To: <20190617215750.8e46ae846c09cd5c1f22fdf9@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 640bd28d-cb55-49f8-0dd8-08d6f3ae74bd
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR05MB6312;
x-ms-traffictypediagnostic: BYAPR05MB6312:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <BYAPR05MB631223752283964C12CA8573D0EA0@BYAPR05MB6312.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 007271867D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(346002)(136003)(366004)(39860400002)(396003)(199004)(189003)(486006)(14454004)(53546011)(66946007)(6506007)(66446008)(64756008)(66476007)(478600001)(4326008)(5660300002)(33656002)(73956011)(36756003)(229853002)(66556008)(86362001)(76116006)(966005)(25786009)(2616005)(186003)(446003)(71190400001)(476003)(71200400001)(14444005)(256004)(26005)(102836004)(53376002)(2906002)(6246003)(81166006)(6436002)(8676002)(81156014)(99286004)(11346002)(6512007)(76176011)(6306002)(66066001)(53936002)(68736007)(305945005)(316002)(6916009)(54906003)(7736002)(6486002)(8936002)(3846002)(6116002)(7416002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB6312;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 SilzUoourfhHYUwbGY/Te8pM7BRAuv2/ZefLrzM5YVCKvJr+/73PW9aDL5VjCDDOHQ8Dnmd+Vh7KxSHgiLV9xPv8UgsCQAO18xciy5rW0xyqofwtcfJS3YbfSpP7HY1/3M13TzVt1o04j27b2mEoaPBGsvFHbHko/DpdPcoFQm66aQkcacAoe4LUmfMI64ASbibZieElEfixyqsi3RYb9fGqQnh6cl+gHNbwp8d+2hbWGyHz5jbbjHbgvEfWqa7qKdvcmx/nfBBTEgTSaYkv17nh2GafXLtOIUSUxsSf2U/+TG52uhks+bSw+FKHg5wnerlX7lzhv9Qwsbfmroq39ruafMY8JYFqb4goJowHIFPAu8mVkJ89ljggrWjYfnjg7y8T4LXDl/KcDlFrMR0iSO4nRRwwuIHkT3AGTPWSCv4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F4A32AD2F1BDF74F9714AD2C3E4E6334@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 640bd28d-cb55-49f8-0dd8-08d6f3ae74bd
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Jun 2019 05:33:12.6640
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB6312
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBKdW4gMTcsIDIwMTksIGF0IDk6NTcgUE0sIEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgt
Zm91bmRhdGlvbi5vcmc+IHdyb3RlOg0KPiANCj4gT24gV2VkLCAxMiBKdW4gMjAxOSAyMTo1OTow
MyAtMDcwMCBOYWRhdiBBbWl0IDxuYW1pdEB2bXdhcmUuY29tPiB3cm90ZToNCj4gDQo+PiBGb3Ig
ZWZmaWNpZW50IHNlYXJjaCBvZiByZXNvdXJjZXMsIGFzIG5lZWRlZCB0byBkZXRlcm1pbmUgdGhl
IG1lbW9yeQ0KPj4gdHlwZSBmb3IgZGF4IHBhZ2UtZmF1bHRzLCBpbnRyb2R1Y2UgYSBjYWNoZSBv
ZiB0aGUgbW9zdCByZWNlbnRseSB1c2VkDQo+PiB0b3AtbGV2ZWwgcmVzb3VyY2UuIENhY2hpbmcg
dGhlIHRvcC1sZXZlbCBzaG91bGQgYmUgc2FmZSBhcyByYW5nZXMgaW4NCj4+IHRoYXQgbGV2ZWwg
ZG8gbm90IG92ZXJsYXAgKHVubGlrZSB0aG9zZSBvZiBsb3dlciBsZXZlbHMpLg0KPj4gDQo+PiBL
ZWVwIHRoZSBjYWNoZSBwZXItY3B1IHRvIGF2b2lkIHBvc3NpYmxlIGNvbnRlbnRpb24uIFdoZW5l
dmVyIGEgcmVzb3VyY2UNCj4+IGlzIGFkZGVkLCByZW1vdmVkIG9yIGNoYW5nZWQsIGludmFsaWRh
dGUgYWxsIHRoZSByZXNvdXJjZXMuIFRoZQ0KPj4gaW52YWxpZGF0aW9uIHRha2VzIHBsYWNlIHdo
ZW4gdGhlIHJlc291cmNlX2xvY2sgaXMgdGFrZW4gZm9yIHdyaXRlLA0KPj4gcHJldmVudGluZyBw
b3NzaWJsZSByYWNlcy4NCj4+IA0KPj4gVGhpcyBwYXRjaCBwcm92aWRlcyByZWxhdGl2ZWx5IHNt
YWxsIHBlcmZvcm1hbmNlIGltcHJvdmVtZW50cyBvdmVyIHRoZQ0KPj4gcHJldmlvdXMgcGF0Y2gg
KH4wLjUlIG9uIHN5c2JlbmNoKSwgYnV0IGNhbiBiZW5lZml0IHN5c3RlbXMgd2l0aCBtYW55DQo+
PiByZXNvdXJjZXMuDQo+IA0KPj4gLS0tIGEva2VybmVsL3Jlc291cmNlLmMNCj4+ICsrKyBiL2tl
cm5lbC9yZXNvdXJjZS5jDQo+PiBAQCAtNTMsNiArNTMsMTIgQEAgc3RydWN0IHJlc291cmNlX2Nv
bnN0cmFpbnQgew0KPj4gDQo+PiBzdGF0aWMgREVGSU5FX1JXTE9DSyhyZXNvdXJjZV9sb2NrKTsN
Cj4+IA0KPj4gKy8qDQo+PiArICogQ2FjaGUgb2YgdGhlIHRvcC1sZXZlbCByZXNvdXJjZSB0aGF0
IHdhcyBtb3N0IHJlY2VudGx5IHVzZSBieQ0KPj4gKyAqIGZpbmRfbmV4dF9pb21lbV9yZXMoKS4N
Cj4+ICsgKi8NCj4+ICtzdGF0aWMgREVGSU5FX1BFUl9DUFUoc3RydWN0IHJlc291cmNlICosIHJl
c291cmNlX2NhY2hlKTsNCj4gDQo+IEEgcGVyLWNwdSBjYWNoZSB3aGljaCBpcyBhY2Nlc3NlZCB1
bmRlciBhIGtlcm5lbC13aWRlIHJlYWRfbG9jayBsb29rcyBhDQo+IGJpdCBvZGQgLSB0aGUgbGF0
ZW5jeSBnZXR0aW5nIGF0IHRoYXQgcndsb2NrIHdpbGwgc3dhbXAgdGhlIGJlbmVmaXQgb2YNCj4g
aXNvbGF0aW5nIHRoZSBDUFVzIGZyb20gZWFjaCBvdGhlciB3aGVuIGFjY2Vzc2luZyByZXNvdXJj
ZV9jYWNoZS4NCj4gDQo+IE9uIHRoZSBvdGhlciBoYW5kLCBpZiB3ZSBoYXZlIG11bHRpcGxlIENQ
VXMgcnVubmluZw0KPiBmaW5kX25leHRfaW9tZW1fcmVzKCkgY29uY3VycmVudGx5IHRoZW4geWVz
LCBJIHNlZSB0aGUgYmVuZWZpdC4gIEhhcw0KPiB0aGUgYmVuZWZpdCBvZiB1c2luZyBhIHBlci1j
cHUgY2FjaGUgKHJhdGhlciB0aGFuIGEga2VybmVsLXdpZGUgb25lKQ0KPiBiZWVuIHF1YW50aWZp
ZWQ/DQoNCk5vLiBJIGFtIG5vdCBzdXJlIGhvdyBlYXN5IGl0IHdvdWxkIGJlIHRvIG1lYXN1cmUg
aXQuIE9uIHRoZSBvdGhlciBoYW5kZXINCnRoZSBsb2NrIGlzIG5vdCBzdXBwb3NlZCB0byBiZSBj
b250ZW5kZWQgKGF0IG1vc3QgY2FzZXMpLiBBdCB0aGUgdGltZSBJIHNhdw0KbnVtYmVycyB0aGF0
IHNob3dlZCB0aGF0IHN0b3JlcyB0byDigJxleGNsdXNpdmUiIGNhY2hlIGxpbmVzIGNhbiBiZSBh
cw0KZXhwZW5zaXZlIGFzIGF0b21pYyBvcGVyYXRpb25zIFsxXS4gSSBhbSBub3Qgc3VyZSBob3cg
dXAgdG8gZGF0ZSB0aGVzZQ0KbnVtYmVycyBhcmUgdGhvdWdoLiBJbiB0aGUgYmVuY2htYXJrIEkg
cmFuLCBtdWx0aXBsZSBDUFVzIHJhbg0KZmluZF9uZXh0X2lvbWVtX3JlcygpIGNvbmN1cnJlbnRs
eS4NCg0KWzFdIGh0dHA6Ly9zaWdvcHMub3JnL3MvY29uZmVyZW5jZXMvc29zcC8yMDEzL3BhcGVy
cy9wMzMtZGF2aWQucGRmDQoNCj4gDQo+IA0KPj4gQEAgLTI2Miw5ICsyNjgsMjAgQEAgc3RhdGlj
IHZvaWQgX19yZWxlYXNlX2NoaWxkX3Jlc291cmNlcyhzdHJ1Y3QgcmVzb3VyY2UgKnIpDQo+PiAJ
fQ0KPj4gfQ0KPj4gDQo+PiArc3RhdGljIHZvaWQgaW52YWxpZGF0ZV9yZXNvdXJjZV9jYWNoZSh2
b2lkKQ0KPj4gK3sNCj4+ICsJaW50IGNwdTsNCj4+ICsNCj4+ICsJbG9ja2RlcF9hc3NlcnRfaGVs
ZF9leGNsdXNpdmUoJnJlc291cmNlX2xvY2spOw0KPj4gKw0KPj4gKwlmb3JfZWFjaF9wb3NzaWJs
ZV9jcHUoY3B1KQ0KPj4gKwkJcGVyX2NwdShyZXNvdXJjZV9jYWNoZSwgY3B1KSA9IE5VTEw7DQo+
PiArfQ0KPiANCj4gQWxsIHRoZSBjYWxscyB0byBpbnZhbGlkYXRlX3Jlc291cmNlX2NhY2hlKCkg
YXJlIHJhdGhlciBhDQo+IG1haW50YWluYWJpbGl0eSBpc3N1ZSAtIGVhc3kgdG8gbWlzcyBvbmUg
YXMgdGhlIGNvZGUgZXZvbHZlcy4NCj4gDQo+IENhbid0IHdlIGp1c3QgbWFrZSBmaW5kX25leHRf
aW9tZW1fcmVzKCkgc21hcnRlcj8gIEZvciBleGFtcGxlLCBzdGFydA0KPiB0aGUgbG9va3VwIGZy
b20gdGhlIGNhY2hlZCBwb2ludCBhbmQgaWYgdGhhdCBmYWlsZWQsIGRvIGEgZnVsbCBzd2VlcD8N
Cg0KSSBtYXkgYmUgYWJsZSB0byBkbyBzb21ldGhpbmcgbGlrZSB0aGF0IHRvIHJlZHVjZSB0aGUg
bnVtYmVyIG9mIGxvY2F0aW9ucw0KdGhhdCBuZWVkIHRvIGJlIHVwZGF0ZWQsIGJ1dCB5b3UgYWx3
YXlzIG5lZWQgdG8gaW52YWxpZGF0ZSBpZiBhIHJlc291cmNlIGlzDQpyZW1vdmVkLiBUaGlzIG1p
Z2h0IG1ha2UgdGhlIGNvZGUgbW9yZSBwcm9uZSB0byBidWdzLCBzaW5jZSB0aGUgbG9naWMgb2YN
CndoZW4gdG8gaW52YWxpZGF0ZSBiZWNvbWVzIG1vcmUgY29tcGxpY2F0ZWQuDQoNCj4+ICsJaW52
YWxpZGF0ZV9yZXNvdXJjZV9jYWNoZSgpOw0KPj4gKwlpbnZhbGlkYXRlX3Jlc291cmNlX2NhY2hl
KCk7DQo+PiArCWludmFsaWRhdGVfcmVzb3VyY2VfY2FjaGUoKTsNCj4+ICsJaW52YWxpZGF0ZV9y
ZXNvdXJjZV9jYWNoZSgpOw0KPj4gKwlpbnZhbGlkYXRlX3Jlc291cmNlX2NhY2hlKCk7DQo+PiAr
CWludmFsaWRhdGVfcmVzb3VyY2VfY2FjaGUoKTsNCj4+ICsJaW52YWxpZGF0ZV9yZXNvdXJjZV9j
YWNoZSgpOw0KPj4gKwlpbnZhbGlkYXRlX3Jlc291cmNlX2NhY2hlKCk7DQo+PiArCWludmFsaWRh
dGVfcmVzb3VyY2VfY2FjaGUoKTsNCj4+ICsJaW52YWxpZGF0ZV9yZXNvdXJjZV9jYWNoZSgpOw0K
Pj4gKwlpbnZhbGlkYXRlX3Jlc291cmNlX2NhY2hlKCk7DQo+PiArCQkJaW52YWxpZGF0ZV9yZXNv
dXJjZV9jYWNoZSgpOw0KPj4gKwlpbnZhbGlkYXRlX3Jlc291cmNlX2NhY2hlKCk7DQo+PiArCWlu
dmFsaWRhdGVfcmVzb3VyY2VfY2FjaGUoKTsNCj4gDQo+IE93LiAgSSBndWVzcyB0aGUgbWFpbnRh
aW5hYmlsaXR5IHNpdHVhdGlvbiBjYW4gYmUgaW1wcm92ZWQgYnkgcmVuYW1pbmcNCj4gcmVzb3Vy
Y2VfbG9jayB0byBzb21ldGhpbmcgZWxzZSAodG8gYXZvaWQgbWlzaGFwcykgdGhlbiBhZGRpbmcg
d3JhcHBlcg0KPiBmdW5jdGlvbnMuICBCdXQgc3RpbGwuICBJIGNhbid0IHNheSB0aGlzIGlzIGEg
c3VwZXItZXhjaXRpbmcgcGF0Y2ggOigNCg0KSSBjb25zaWRlcmVkIGRvaW5nIHNvLCBidXQgSSB3
YXMgbm90IHN1cmUgaXQgaXMgYmV0dGVyLiBJZiB5b3Ugd2FudCBJ4oCZbGwNCmltcGxlbWVudCBp
dCB1c2luZyB3cmFwcGVyIGZ1bmN0aW9ucyAoYnV0IGJvdGggbG9jayBhbmQgdW5sb2NrIHdvdWxk
IG5lZWQgDQp0byBiZSB3cmFwcGVkIGZvciBjb25zaXN0ZW5jeSkuDQoNClRoZSBiZW5lZml0IG9m
IHRoaXMgcGF0Y2ggb3ZlciB0aGUgcHJldmlvdXMgb25lIGlzIG5vdCBodWdlLCBhbmQgSSBkb27i
gJl0DQprbm93IGhvdyB0byBpbXBsZW1lbnQgaXQgYW55IGJldHRlciAoZXhjbHVkaW5nIHdyYXBw
ZXIgZnVuY3Rpb24sIGlmIHlvdQ0KY29uc2lkZXIgaXQgYmV0dGVyKS4gSWYgeW91IHdhbnQsIHlv
dSBjYW4ganVzdCBkcm9wIHRoaXMgcGF0Y2guDQoNCg0K

