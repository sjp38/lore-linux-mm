Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80814C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:35:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12169214AF
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:35:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="KA8xoI4Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12169214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 766D76B0003; Wed, 19 Jun 2019 16:35:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 718328E0002; Wed, 19 Jun 2019 16:35:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DF5F8E0001; Wed, 19 Jun 2019 16:35:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CFBE6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:35:18 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id a18so581697qtj.18
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:35:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=jneXLD3L55zplpX/eGVFAeEnB7A4+qOVDh06M4taQJY=;
        b=TRw+MvE6/BlxLRrfl34IRFhZ8REK2etm1TfscEvtzD08fcqLvPo4zueq6ovusdkqFV
         qnucdDAsYFOQhCbzwCqMi3PxGKWaZrHU7/sUAd1USXSkF5l6cpiSEx1V0hb4RrrbTm3L
         91A3yun1LMnNYcOH3vgmwKSUozooLwjcsG1L6l2FkrHpOE5/uoyVTAX9siau3T4K2TWL
         LdT2/haO076luxvxfD3K+8GFne6/sSCniZGBZXMZiv6FY8dib9T7FSJmf59N7K39PmtR
         FPxpgyyzLMIolMWxWnXK1Q5efBHKKewsYpyDblSckccaVPXw3Ki7IvOC/gdANSNdzr9C
         Or7g==
X-Gm-Message-State: APjAAAUQ+Prc7V5PmjHrilcB7eno2QA1DyNgVA3c7hY/Sn4lp6b4Zyf/
	I8KQJdMquYMHElLpYJhM65dgUg5JK3a6wifDFR6MM9IeIBBX+u/vnR9LvNZPWa9t4xo86ePmhdP
	vDC0AUoWmFB7cjRBURKUn3/pVhYEQJJ5n7Be1bhRr/uS1k38BtGZoLMPFzIx0Vq9lvA==
X-Received: by 2002:a37:a247:: with SMTP id l68mr40379076qke.89.1560976517889;
        Wed, 19 Jun 2019 13:35:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXeVN0seEN7ZlETGEo0mDP0AR3lCAhJmn+q59ZEItlxbR+Mck0gPzMLrUC5f5aiNeZlLTL
X-Received: by 2002:a37:a247:: with SMTP id l68mr40379031qke.89.1560976517060;
        Wed, 19 Jun 2019 13:35:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560976517; cv=none;
        d=google.com; s=arc-20160816;
        b=N6SCOyTARD68W93Qvm//XS97Rl/X9qUoDMWAI5f7Q+yUO+qby4npCArtbtjRbLAEZr
         8I8vVQxAxRXd6pL2RqTO36gGG84Mv5xZVZO2HF60TGZe+il0pGKrwmZgtLeF8GEs4X0i
         DCpCLFXtO+Snhifitl47mCQYCgl43COWBB5t+Cy5dkoerz6kn60ZfRCml2oBXBwPaiRu
         OL+bcv0S1variWkiS95g7vRLefpwIVPcpo6OQLvIdjT1cxACr4JlrsbENQoflNoNKTTM
         TTu98uj/ZnDJV1aAnpSipgm8Zg2DlF4ZqDCggcygMxVjP+x/7BrzhsNM3XYg8uif0gQQ
         TnZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=jneXLD3L55zplpX/eGVFAeEnB7A4+qOVDh06M4taQJY=;
        b=A2A9OzdSCkqwkEjzEAFJ1rrtHdThBI4uDWCkmm8mcE7u2sDimPnVJHYouAJNNYZmbJ
         G597t/0m5GlS2/79afqcjw1IshOv6d6ZMTbHOCicylENF08RvYWGNL/vN3yVe7nTR5W7
         /Szo2oRovAT7sqn25gxyya5UgU9yVMEiGsjFs/hewQiFLHm3Lt5v3UEaQtxvNKHJvaRN
         6v3kR6zKlnmzPlERQsCkqEY+R96ghuvacXYhnZRglkTdHQPOsdNYMJD4L0mKfwNmlY9n
         DzKJ+1kYqGxndsLe5P8kLJPi2WKR/RE2ZfDO4o0gEFEOr6DQsdtM1W8l+cKgiNWYI/PC
         9SRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=KA8xoI4Q;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.71.67 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710067.outbound.protection.outlook.com. [40.107.71.67])
        by mx.google.com with ESMTPS id l28si3427635qtc.376.2019.06.19.13.35.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 13:35:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.71.67 as permitted sender) client-ip=40.107.71.67;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=KA8xoI4Q;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.71.67 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jneXLD3L55zplpX/eGVFAeEnB7A4+qOVDh06M4taQJY=;
 b=KA8xoI4Qc1jSBEpfRwJCAXjeFSc9Q8xNPd/JUY7aE+NXRrmhxMbrtGyhwaoNedX30pkOA+tAex1gVSiGEgQV8o3CVnkz8f+kM8GQ7+7NEHOuzcoOSdEp02tFA9FZv3h9AUIoAW/aV4j/BNqgh3Wa0TNLW4A4qvYfnENwBvkzkhw=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB6151.namprd05.prod.outlook.com (20.178.55.28) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.13; Wed, 19 Jun 2019 20:35:14 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58%7]) with mapi id 15.20.2008.007; Wed, 19 Jun 2019
 20:35:14 +0000
From: Nadav Amit <namit@vmware.com>
To: Bjorn Helgaas <bhelgaas@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>, LKML
	<linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Borislav
 Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra
	<peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/3] resource: Introduce resource cache
Thread-Topic: [PATCH 3/3] resource: Introduce resource cache
Thread-Index: AQHVIaTIgkJbYpRVG0mXAw73pWsOuqag4XgAgAAJ4gCAAAHyAIACDT6AgAB/KoA=
Date: Wed, 19 Jun 2019 20:35:14 +0000
Message-ID: <9175AC33-BB3A-4D1F-B7FC-D0B1A8F971B6@vmware.com>
References: <20190613045903.4922-1-namit@vmware.com>
 <20190613045903.4922-4-namit@vmware.com>
 <20190617215750.8e46ae846c09cd5c1f22fdf9@linux-foundation.org>
 <98464609-8F5A-47B9-A64E-2F67809737AD@vmware.com>
 <8072D878-BBF2-47E4-B4C9-190F379F6221@vmware.com>
 <CAErSpo5eiweMk2rfT81Kwnpd=MZsOa01prPo_rAFp-MZ9F2xdQ@mail.gmail.com>
In-Reply-To:
 <CAErSpo5eiweMk2rfT81Kwnpd=MZsOa01prPo_rAFp-MZ9F2xdQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ece9d029-9d18-4130-4fe6-08d6f4f5a23a
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR05MB6151;
x-ms-traffictypediagnostic: BYAPR05MB6151:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <BYAPR05MB61510D14E283587E5859CC3AD0E50@BYAPR05MB6151.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0073BFEF03
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(376002)(366004)(396003)(346002)(136003)(189003)(199004)(14444005)(2616005)(71200400001)(81156014)(256004)(6436002)(8936002)(81166006)(66066001)(6306002)(71190400001)(53546011)(66556008)(446003)(33656002)(102836004)(14454004)(6486002)(66446008)(316002)(6506007)(36756003)(73956011)(966005)(66476007)(11346002)(54906003)(64756008)(229853002)(7736002)(66946007)(76116006)(478600001)(8676002)(305945005)(186003)(2906002)(5660300002)(6246003)(86362001)(6116002)(99286004)(3846002)(26005)(486006)(45080400002)(25786009)(4326008)(7416002)(68736007)(53936002)(76176011)(6512007)(6916009)(476003);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB6151;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 gSzlG4E18bsZSFAI6hgudqNqdzYvTI/xMyaEZgA0t5khciUPmzbTp/rp0a6LQ3ZUIaE6YyTrmKrc7++CLto9qVr0E3AbockpaYZkPRGrvgwW3KZmIFRM8G4yErMg1tmw04eEegyvF+mL56Cu2qIAyU69ZP+NpRdTBQnKmt/MohIj6ZFDqSXGVkAnxX9WZVdcjt7p206f8hVwI0a90cpBvh1+75B6BQkx1x38DNBK4TPNw/yIR/gObU4PH3POEGN1izGtkLSqRLku1cjLox+YrXNYdiWprdDWPVgYRUGN/wXRtrlkQvoIldRHqTpcpUdvnu5cX/j8Kg+3XRlD/rhxIF3K4XL1JFWuoOrTDFmsW1HSz62pfRJfCJXvoyKLffxLCwV7CzOeQOr55CHcLXP/OR495UKLZfCpVyKiJA8P+38=
Content-Type: text/plain; charset="utf-8"
Content-ID: <E7004E164DFA074B88A53BE1530DDEF2@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ece9d029-9d18-4130-4fe6-08d6f4f5a23a
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Jun 2019 20:35:14.3740
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB6151
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBKdW4gMTksIDIwMTksIGF0IDY6MDAgQU0sIEJqb3JuIEhlbGdhYXMgPGJoZWxnYWFzQGdv
b2dsZS5jb20+IHdyb3RlOg0KPiANCj4gT24gVHVlLCBKdW4gMTgsIDIwMTkgYXQgMTI6NDAgQU0g
TmFkYXYgQW1pdCA8bmFtaXRAdm13YXJlLmNvbT4gd3JvdGU6DQo+Pj4gT24gSnVuIDE3LCAyMDE5
LCBhdCAxMDozMyBQTSwgTmFkYXYgQW1pdCA8bmFtaXRAdm13YXJlLmNvbT4gd3JvdGU6DQo+Pj4g
DQo+Pj4+IE9uIEp1biAxNywgMjAxOSwgYXQgOTo1NyBQTSwgQW5kcmV3IE1vcnRvbiA8YWtwbUBs
aW51eC1mb3VuZGF0aW9uLm9yZz4gd3JvdGU6DQo+Pj4+IA0KPj4+PiBPbiBXZWQsIDEyIEp1biAy
MDE5IDIxOjU5OjAzIC0wNzAwIE5hZGF2IEFtaXQgPG5hbWl0QHZtd2FyZS5jb20+IHdyb3RlOg0K
Pj4+PiANCj4+Pj4+IEZvciBlZmZpY2llbnQgc2VhcmNoIG9mIHJlc291cmNlcywgYXMgbmVlZGVk
IHRvIGRldGVybWluZSB0aGUgbWVtb3J5DQo+Pj4+PiB0eXBlIGZvciBkYXggcGFnZS1mYXVsdHMs
IGludHJvZHVjZSBhIGNhY2hlIG9mIHRoZSBtb3N0IHJlY2VudGx5IHVzZWQNCj4+Pj4+IHRvcC1s
ZXZlbCByZXNvdXJjZS4gQ2FjaGluZyB0aGUgdG9wLWxldmVsIHNob3VsZCBiZSBzYWZlIGFzIHJh
bmdlcyBpbg0KPj4+Pj4gdGhhdCBsZXZlbCBkbyBub3Qgb3ZlcmxhcCAodW5saWtlIHRob3NlIG9m
IGxvd2VyIGxldmVscykuDQo+Pj4+PiANCj4+Pj4+IEtlZXAgdGhlIGNhY2hlIHBlci1jcHUgdG8g
YXZvaWQgcG9zc2libGUgY29udGVudGlvbi4gV2hlbmV2ZXIgYSByZXNvdXJjZQ0KPj4+Pj4gaXMg
YWRkZWQsIHJlbW92ZWQgb3IgY2hhbmdlZCwgaW52YWxpZGF0ZSBhbGwgdGhlIHJlc291cmNlcy4g
VGhlDQo+Pj4+PiBpbnZhbGlkYXRpb24gdGFrZXMgcGxhY2Ugd2hlbiB0aGUgcmVzb3VyY2VfbG9j
ayBpcyB0YWtlbiBmb3Igd3JpdGUsDQo+Pj4+PiBwcmV2ZW50aW5nIHBvc3NpYmxlIHJhY2VzLg0K
Pj4+Pj4gDQo+Pj4+PiBUaGlzIHBhdGNoIHByb3ZpZGVzIHJlbGF0aXZlbHkgc21hbGwgcGVyZm9y
bWFuY2UgaW1wcm92ZW1lbnRzIG92ZXIgdGhlDQo+Pj4+PiBwcmV2aW91cyBwYXRjaCAofjAuNSUg
b24gc3lzYmVuY2gpLCBidXQgY2FuIGJlbmVmaXQgc3lzdGVtcyB3aXRoIG1hbnkNCj4+Pj4+IHJl
c291cmNlcy4NCj4+Pj4gDQo+Pj4+PiAtLS0gYS9rZXJuZWwvcmVzb3VyY2UuYw0KPj4+Pj4gKysr
IGIva2VybmVsL3Jlc291cmNlLmMNCj4+Pj4+IEBAIC01Myw2ICs1MywxMiBAQCBzdHJ1Y3QgcmVz
b3VyY2VfY29uc3RyYWludCB7DQo+Pj4+PiANCj4+Pj4+IHN0YXRpYyBERUZJTkVfUldMT0NLKHJl
c291cmNlX2xvY2spOw0KPj4+Pj4gDQo+Pj4+PiArLyoNCj4+Pj4+ICsgKiBDYWNoZSBvZiB0aGUg
dG9wLWxldmVsIHJlc291cmNlIHRoYXQgd2FzIG1vc3QgcmVjZW50bHkgdXNlIGJ5DQo+Pj4+PiAr
ICogZmluZF9uZXh0X2lvbWVtX3JlcygpLg0KPj4+Pj4gKyAqLw0KPj4+Pj4gK3N0YXRpYyBERUZJ
TkVfUEVSX0NQVShzdHJ1Y3QgcmVzb3VyY2UgKiwgcmVzb3VyY2VfY2FjaGUpOw0KPj4+PiANCj4+
Pj4gQSBwZXItY3B1IGNhY2hlIHdoaWNoIGlzIGFjY2Vzc2VkIHVuZGVyIGEga2VybmVsLXdpZGUg
cmVhZF9sb2NrIGxvb2tzIGENCj4+Pj4gYml0IG9kZCAtIHRoZSBsYXRlbmN5IGdldHRpbmcgYXQg
dGhhdCByd2xvY2sgd2lsbCBzd2FtcCB0aGUgYmVuZWZpdCBvZg0KPj4+PiBpc29sYXRpbmcgdGhl
IENQVXMgZnJvbSBlYWNoIG90aGVyIHdoZW4gYWNjZXNzaW5nIHJlc291cmNlX2NhY2hlLg0KPj4+
PiANCj4+Pj4gT24gdGhlIG90aGVyIGhhbmQsIGlmIHdlIGhhdmUgbXVsdGlwbGUgQ1BVcyBydW5u
aW5nDQo+Pj4+IGZpbmRfbmV4dF9pb21lbV9yZXMoKSBjb25jdXJyZW50bHkgdGhlbiB5ZXMsIEkg
c2VlIHRoZSBiZW5lZml0LiAgSGFzDQo+Pj4+IHRoZSBiZW5lZml0IG9mIHVzaW5nIGEgcGVyLWNw
dSBjYWNoZSAocmF0aGVyIHRoYW4gYSBrZXJuZWwtd2lkZSBvbmUpDQo+Pj4+IGJlZW4gcXVhbnRp
ZmllZD8NCj4+PiANCj4+PiBOby4gSSBhbSBub3Qgc3VyZSBob3cgZWFzeSBpdCB3b3VsZCBiZSB0
byBtZWFzdXJlIGl0LiBPbiB0aGUgb3RoZXIgaGFuZGVyDQo+Pj4gdGhlIGxvY2sgaXMgbm90IHN1
cHBvc2VkIHRvIGJlIGNvbnRlbmRlZCAoYXQgbW9zdCBjYXNlcykuIEF0IHRoZSB0aW1lIEkgc2F3
DQo+Pj4gbnVtYmVycyB0aGF0IHNob3dlZCB0aGF0IHN0b3JlcyB0byDigJxleGNsdXNpdmUiIGNh
Y2hlIGxpbmVzIGNhbiBiZSBhcw0KPj4+IGV4cGVuc2l2ZSBhcyBhdG9taWMgb3BlcmF0aW9ucyBb
MV0uIEkgYW0gbm90IHN1cmUgaG93IHVwIHRvIGRhdGUgdGhlc2UNCj4+PiBudW1iZXJzIGFyZSB0
aG91Z2guIEluIHRoZSBiZW5jaG1hcmsgSSByYW4sIG11bHRpcGxlIENQVXMgcmFuDQo+Pj4gZmlu
ZF9uZXh0X2lvbWVtX3JlcygpIGNvbmN1cnJlbnRseS4NCj4+PiANCj4+PiBbMV0gaHR0cHM6Ly9u
YW0wNC5zYWZlbGlua3MucHJvdGVjdGlvbi5vdXRsb29rLmNvbS8/dXJsPWh0dHAlM0ElMkYlMkZz
aWdvcHMub3JnJTJGcyUyRmNvbmZlcmVuY2VzJTJGc29zcCUyRjIwMTMlMkZwYXBlcnMlMkZwMzMt
ZGF2aWQucGRmJmFtcDtkYXRhPTAyJTdDMDElN0NuYW1pdCU0MHZtd2FyZS5jb20lN0NhMjcwNmM1
YWIyYzU0NDI4M2YzYjA4ZDZmNGI2MTUyYiU3Q2IzOTEzOGNhM2NlZTRiNGFhNGQ2Y2Q4M2Q5ZGQ2
MmYwJTdDMCU3QzElN0M2MzY5NjU0NjAyMzQwMjIzNzEmYW1wO3NkYXRhPWNEN05oczRqY0pHTUQ3
TGF2NkQlMkJDNkU1U2VpMERpV2hLWEw3dnoyY1ZIQSUzRCZhbXA7cmVzZXJ2ZWQ9MA0KPj4gDQo+
PiBKdXN0IHRvIGNsYXJpZnkgLSB0aGUgbWFpbiBtb3RpdmF0aW9uIGJlaGluZCB0aGUgcGVyLWNw
dSB2YXJpYWJsZSBpcyBub3QNCj4+IGFib3V0IGNvbnRlbnRpb24sIGJ1dCBhYm91dCB0aGUgZmFj
dCB0aGUgZGlmZmVyZW50IHByb2Nlc3Nlcy90aHJlYWRzIHRoYXQNCj4+IHJ1biBjb25jdXJyZW50
bHkgbWlnaHQgdXNlIGRpZmZlcmVudCByZXNvdXJjZXMuDQo+IA0KPiBJSVVDLCB0aGUgdW5kZXJs
eWluZyBwcm9ibGVtIGlzIHRoYXQgZGF4IHJlbGllcyBoZWF2aWx5IG9uIGlvcmVtYXAoKSwNCj4g
YW5kIGlvcmVtYXAoKSBvbiB4ODYgdGFrZXMgdG9vIGxvbmcgYmVjYXVzZSBpdCByZWxpZXMgb24N
Cj4gZmluZF9uZXh0X2lvbWVtX3JlcygpIHZpYSB0aGUgX19pb3JlbWFwX2NhbGxlcigpIC0+DQo+
IF9faW9yZW1hcF9jaGVja19tZW0oKSAtPiB3YWxrX21lbV9yZXMoKSBwYXRoLg0KDQpJIGRvbuKA
mXQga25vdyBtdWNoIGFib3V0IHRoaXMgcGF0aCBhbmQgd2hldGhlciBpdCBpcyBwYWluZnVsLiBU
aGUgcGF0aCBJIHdhcw0KcmVnYXJkaW5nIGlzIGR1cmluZyBwYWdlLWZhdWx0IGhhbmRsaW5nOg0K
DQogICAtIGhhbmRsZV9tbV9mYXVsdA0KICAgICAgLSBfX2hhbmRsZV9tbV9mYXVsdA0KICAgICAg
ICAgLSBkb193cF9wYWdlDQogICAgICAgICAgICAtIGV4dDRfZGF4X2ZhdWx0DQogICAgICAgICAg
ICAgICAtIGV4dDRfZGF4X2h1Z2VfZmF1bHQNCiAgICAgICAgICAgICAgICAgIC0gZGF4X2lvbWFw
X2ZhdWx0DQogICAgICAgICAgICAgICAgICAgICAtIGRheF9pb21hcF9wdGVfZmF1bHQNCiAgICAg
ICAgICAgICAgICAgICAgICAgIC0gdm1mX2luc2VydF9taXhlZF9ta3dyaXRlDQogICAgICAgICAg
ICAgICAgICAgICAgICAgICAtIF9fdm1faW5zZXJ0X21peGVkDQogICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAtIHRyYWNrX3Bmbl9pbnNlcnQNCiAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIC0gbG9va3VwX21lbXR5cGUNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgIC0gcGF0X3BhZ2VyYW5nZV9pc19yYW0NCg0KQnV0IGluZGVlZCB0cmFja19wZm5faW5zZXJ0
KCkgaW4geDg2IHNwZWNpZmljLiBJIGd1ZXNzIHRoZSBkaWZmZXJlbmNlcyBhcmUNCmR1ZSB0byB0
aGUgcGFnZS10YWJsZSBjb250cm9sbGluZyB0aGUgY2FjaGFiaWxpdHkgaW4geDg2IChQQVQpLCBi
dXQgSSBkb27igJl0DQprbm93IG11Y2ggYWJvdXQgb3RoZXIgYXJjaGl0ZWN0dXJlcyBhbmQgd2hl
dGhlciB0aGV5IGhhdmUgc2ltaWxhcg0KY2FjaGFiaWxpdHkgY29udHJvbHMgaW4gdGhlIHBhZ2Ut
dGFibGVzLg0KDQo=

