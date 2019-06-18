Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 994FAC31E5D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 21:56:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5036C20B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 21:56:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="2kFH24C+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5036C20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFDF26B0005; Tue, 18 Jun 2019 17:56:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B88208E0002; Tue, 18 Jun 2019 17:56:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A28268E0001; Tue, 18 Jun 2019 17:56:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 522D56B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 17:56:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so23116852eda.2
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 14:56:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=gnlMSJEdso7veKqh30diH+zIt9D1j5E7I4f0b7gxMaM=;
        b=bsebodnoG69pgeLlAkWpRixJph0TYVwYK4ttGJ2pW+D8ru7AD00iw+4AVySmT2f5O8
         0gk3Zjn4LnuAcSNME9cJIAXl7WaQpR+40D7NcDaRkxGqKqJqMaoZkn5/4QSFpvRca7lc
         HFs0PWczGy+e02oRucL+uEssi1oVVZ14TOAUpJJfhg4ad3RmmU1Ryp3jHtKB/JmMWRAh
         Ka6g3GjlfeVFTU8nlMTVGtmV8riqv+fXzbfDfMdDaVMig3zlkNLVRcKrmYRQxNoDLi8/
         aS5D/s5Xpew93GowC2FTMjjozWnf1JBWqpoBzTUMtGc6mJTodx/gQt1+GlnWNMpoUXtt
         mZhg==
X-Gm-Message-State: APjAAAX33re5UgbnjLuiUCeu0JkrQ2nsz+hGd3h9M7JhNByIKdCgY1mG
	Mr9mGtjVUPuiALPI9cRckUnJXiMTbUtQ4q7ncyPm847RAKJUbA7MjQvDaTv9q5m/AxRuBC24o4N
	pTBds6WQBfHXAvYaa8Dvjd55fzLZGsEFrAbnl7wvoEKeP2Pp+qZrbkGpcxiIooISQVQ==
X-Received: by 2002:a50:b329:: with SMTP id q38mr127356741edd.246.1560895006908;
        Tue, 18 Jun 2019 14:56:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFbGOBznmd7zC8RKd8Hp9xh2pBsnYuz4Xw12fWq4BhuOWwXstkbzdHcuYCnc+m+P66wYTY
X-Received: by 2002:a50:b329:: with SMTP id q38mr127356697edd.246.1560895006147;
        Tue, 18 Jun 2019 14:56:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560895006; cv=none;
        d=google.com; s=arc-20160816;
        b=qNc9aXrVsRx3EkyKOxiFy4vA56A0a1joh5iQWaZkleoN0ZntLiVTxzwUxuoQlOoV6Y
         Pjlejzr3D9C2BDRjQmWlwK4sn/nDropvoeCP1q/TjEwZh5ek1/nQtXcrsakLmhYifxPK
         f3/fTE1K+TbtsuthBXoeV63K5lmaMXT+BDvgk6n12IJSOiiDBVfhV+Wo8oHpvlHbLO2j
         5+X/KvifNP+xj7BnIFxSrirbvIipHbBCzgulsCEPPhKPYGxHY7sbKjJ9dDMg8UP1+SKa
         SKWYPFs8QOrONb7kXyK+wJOuuCyDHFbyPj7QbB9UkZfnJ0wRZGjzBVqWUuvrSe72CG9e
         +wRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=gnlMSJEdso7veKqh30diH+zIt9D1j5E7I4f0b7gxMaM=;
        b=tkzQ+sJ6SG8LtYCpgHchKD/vermjW+bErfdBixEbZBQ+K4S2wFlh1ZNT4qs1G3p6lp
         Cr78NhzlrL3dP3Bg3KACfC56RHm6J3QaGLcHNgYpkuQZSbtu9jqg33ZYC/kLP7olkTtd
         Cfn3Gh4AJD42kC/iBD6/q1Vbo+RswlYcqXNZ5R98V7xk1TjYwTJ/M4FdCL79r548ogBr
         OJ/ee9NHjnlP8AlkmyeRVg3EgTI3Zgtq741bAMosQcZtSjilcVixSrJvLfXnXnZUTd9m
         PxajFDq2j7N75CCt4rkLt2EvTA2H58z+H+F8oKeUe8xFdi4ai0gj44VW9Eu+TyYW5hoU
         0J1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=2kFH24C+;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.82.72 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-eopbgr820072.outbound.protection.outlook.com. [40.107.82.72])
        by mx.google.com with ESMTPS id r5si12181345edm.368.2019.06.18.14.56.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Jun 2019 14:56:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.82.72 as permitted sender) client-ip=40.107.82.72;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=2kFH24C+;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.82.72 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=gnlMSJEdso7veKqh30diH+zIt9D1j5E7I4f0b7gxMaM=;
 b=2kFH24C+nVrXf4MZLrx4udVit102FmhukadUvdXb/8x8jI5AjOiWWNCd59nsFs08QfJajGMW3Rsk44owlmFpQYxHe0Ly6Q1KtGFmgBMS2WvIzgjiAPwqpPuEYyLvZVuaWm09vw9/SWSCU1T3ywcjIAgXYQbDtFxRpiSwFLwALcg=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB4501.namprd05.prod.outlook.com (52.135.203.33) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.10; Tue, 18 Jun 2019 21:56:44 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58%7]) with mapi id 15.20.2008.007; Tue, 18 Jun 2019
 21:56:44 +0000
From: Nadav Amit <namit@vmware.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Borislav
 Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra
	<peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bjorn
 Helgaas <bhelgaas@google.com>, Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] resource: find_next_iomem_res() improvements
Thread-Topic: [PATCH 0/3] resource: find_next_iomem_res() improvements
Thread-Index: AQHVIaTGJ7ym4R/nDEy6A26DLGCJOaag/0oAgAC3tYCAAA1/gIAAOaaA
Date: Tue, 18 Jun 2019 21:56:43 +0000
Message-ID: <19C3DCA0-823E-46CB-A758-D5F82C5FA3C8@vmware.com>
References: <20190613045903.4922-1-namit@vmware.com>
 <CAPcyv4hpWg5DWRhazS-ftyghiZP-J_M-7Vd5tiUd5UKONOib8g@mail.gmail.com>
 <9387A285-B768-4B58-B91B-61B70D964E6E@vmware.com>
 <CAPcyv4hstt+0teXPtAq2nwFQaNb9TujgetgWPVMOnYH8JwqGeA@mail.gmail.com>
In-Reply-To:
 <CAPcyv4hstt+0teXPtAq2nwFQaNb9TujgetgWPVMOnYH8JwqGeA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0cae4390-edb5-42ed-a7e2-08d6f437da29
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR05MB4501;
x-ms-traffictypediagnostic: BYAPR05MB4501:
x-microsoft-antispam-prvs:
 <BYAPR05MB45019A584A4A4A95F2B3AD38D0EA0@BYAPR05MB4501.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 007271867D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(39860400002)(346002)(366004)(136003)(376002)(51914003)(199004)(189003)(5660300002)(4326008)(316002)(54906003)(25786009)(53936002)(6436002)(6486002)(229853002)(478600001)(6916009)(7416002)(33656002)(446003)(486006)(11346002)(476003)(6246003)(14444005)(256004)(99286004)(36756003)(7736002)(26005)(305945005)(71200400001)(6512007)(6116002)(8676002)(3846002)(81166006)(102836004)(81156014)(186003)(76176011)(6506007)(66556008)(66446008)(64756008)(2616005)(66476007)(14454004)(73956011)(53546011)(66946007)(2906002)(66066001)(68736007)(76116006)(86362001)(71190400001)(8936002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB4501;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 m1ZqHl5ezVkV2drGsDR7ZdwTe2D8gwFIRLLBkIRnyMonZDjzd92ZTZ5JRDWux3DJEHZDrLdq9lMwX4cLK6Ke3EBosMeXs5bLjt7zqFq2U8+3vhhXduPKludiN7lmrT6UwSu+UhROoPFZJwM7uCdZKLnebxEkscHOd0esA7aqUFR2x66eDQR80BTmoDLDn8a11eD4HgnfDjFvFzaIYq6Fi/LTLuMNmHytoMu+lQ6l7KWBXtdrWzhlnthkmVF+o9GW43vDzhfgzcZIAYBkZ4AU3PKRlpwHPiUcjoFUf2h87NUgMeu3/wGsPyHc+qNVdvd+B/177YV1FWLr/dXdxwPj3449Tu+8iNZlqcpyV8MXbGF7pR/EYA+rzocosUFZ9VbiZMTiBKx4T5Sd8P2Lk839s+FnpDMer+c98/JGVwhx4/0=
Content-Type: text/plain; charset="utf-8"
Content-ID: <3646E9E76A9CEE4FB1F7E615BC67D646@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0cae4390-edb5-42ed-a7e2-08d6f437da29
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Jun 2019 21:56:43.8396
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB4501
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBKdW4gMTgsIDIwMTksIGF0IDExOjMwIEFNLCBEYW4gV2lsbGlhbXMgPGRhbi5qLndpbGxp
YW1zQGludGVsLmNvbT4gd3JvdGU6DQo+IA0KPiBPbiBUdWUsIEp1biAxOCwgMjAxOSBhdCAxMDo0
MiBBTSBOYWRhdiBBbWl0IDxuYW1pdEB2bXdhcmUuY29tPiB3cm90ZToNCj4+PiBPbiBKdW4gMTcs
IDIwMTksIGF0IDExOjQ0IFBNLCBEYW4gV2lsbGlhbXMgPGRhbi5qLndpbGxpYW1zQGludGVsLmNv
bT4gd3JvdGU6DQo+Pj4gDQo+Pj4gT24gV2VkLCBKdW4gMTIsIDIwMTkgYXQgOTo1OSBQTSBOYWRh
diBBbWl0IDxuYW1pdEB2bXdhcmUuY29tPiB3cm90ZToNCj4+Pj4gUnVubmluZyBzb21lIG1pY3Jv
YmVuY2htYXJrcyBvbiBkYXgga2VlcHMgc2hvd2luZyBmaW5kX25leHRfaW9tZW1fcmVzKCkNCj4+
Pj4gYXMgYSBwbGFjZSBpbiB3aGljaCBzaWduaWZpY2FudCBhbW91bnQgb2YgdGltZSBpcyBzcGVu
dC4gSXQgYXBwZWFycyB0aGF0DQo+Pj4+IGluIG9yZGVyIHRvIGRldGVybWluZSB0aGUgY2FjaGVh
YmlsaXR5IHRoYXQgaXMgcmVxdWlyZWQgZm9yIHRoZSBQVEUsDQo+Pj4+IGxvb2t1cF9tZW10eXBl
KCkgaXMgY2FsbGVkLCBhbmQgdGhpcyBvbmUgdHJhdmVyc2VzIHRoZSByZXNvdXJjZXMgbGlzdCBp
bg0KPj4+PiBhbiBpbmVmZmljaWVudCBtYW5uZXIuIFRoaXMgcGF0Y2gtc2V0IHRyaWVzIHRvIGlt
cHJvdmUgdGhpcyBzaXR1YXRpb24uDQo+Pj4gDQo+Pj4gTGV0J3MganVzdCBkbyB0aGlzIGxvb2t1
cCBvbmNlIHBlciBkZXZpY2UsIGNhY2hlIHRoYXQsIGFuZCByZXBsYXkgaXQNCj4+PiB0byBtb2Rp
ZmllZCB2bWZfaW5zZXJ0Xyogcm91dGluZXMgdGhhdCB0cnVzdCB0aGUgY2FsbGVyIHRvIGFscmVh
ZHkNCj4+PiBrbm93IHRoZSBwZ3Byb3RfdmFsdWVzLg0KPj4gDQo+PiBJSVVDLCBvbmUgZGV2aWNl
IGNhbiBoYXZlIG11bHRpcGxlIHJlZ2lvbnMgd2l0aCBkaWZmZXJlbnQgY2hhcmFjdGVyaXN0aWNz
LA0KPj4gd2hpY2ggcmVxdWlyZSBkaWZmZXJlbmNlIGNhY2hhYmlsaXR5Lg0KPiANCj4gTm90IGZv
ciBwbWVtLiBJdCB3aWxsIGFsd2F5cyBiZSBvbmUgY29tbW9uIGNhY2hlYWJpbGl0eSBzZXR0aW5n
IGZvcg0KPiB0aGUgZW50aXJldHkgb2YgcGVyc2lzdGVudCBtZW1vcnkuDQo+IA0KPj4gQXBwYXJl
bnRseSwgdGhhdCBpcyB0aGUgcmVhc29uIHRoZXJlDQo+PiBpcyBhIHRyZWUgb2YgcmVzb3VyY2Vz
LiBQbGVhc2UgYmUgbW9yZSBzcGVjaWZpYyBhYm91dCB3aGVyZSB5b3Ugd2FudCB0bw0KPj4gY2Fj
aGUgaXQsIHBsZWFzZS4NCj4gDQo+IFRoZSByZWFzb24gZm9yIGxvb2t1cF9tZW10eXBlKCkgd2Fz
IHRvIHRyeSB0byBwcmV2ZW50IG1peGVkDQo+IGNhY2hlYWJpbGl0eSBzZXR0aW5ncyBvZiBwYWdl
cyBhY3Jvc3MgZGlmZmVyZW50IHByb2Nlc3NlcyAuIFRoZQ0KPiBtYXBwaW5nIHR5cGUgZm9yIHBt
ZW0vZGF4IGlzIGVzdGFibGlzaGVkIGJ5IG9uZSBvZjoNCj4gDQo+IGRyaXZlcnMvbnZkaW1tL3Bt
ZW0uYzo0MTM6ICAgICAgICAgICAgICBhZGRyID0NCj4gZGV2bV9tZW1yZW1hcF9wYWdlcyhkZXYs
ICZwbWVtLT5wZ21hcCk7DQo+IGRyaXZlcnMvbnZkaW1tL3BtZW0uYzo0MjU6ICAgICAgICAgICAg
ICBhZGRyID0NCj4gZGV2bV9tZW1yZW1hcF9wYWdlcyhkZXYsICZwbWVtLT5wZ21hcCk7DQo+IGRy
aXZlcnMvbnZkaW1tL3BtZW0uYzo0MzI6ICAgICAgICAgICAgICBhZGRyID0gZGV2bV9tZW1yZW1h
cChkZXYsDQo+IHBtZW0tPnBoeXNfYWRkciwNCj4gZHJpdmVycy9udmRpbW0vcG1lbS5jLTQzMy0g
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICBwbWVtLT5zaXplLA0KPiBBUkNIX01FTVJFTUFQ
X1BNRU0pOw0KPiANCj4gLi4uYW5kIGlzIGNvbnN0YW50IGZvciB0aGUgbGlmZSBvZiB0aGUgZGV2
aWNlIGFuZCBhbGwgc3Vic2VxdWVudCBtYXBwaW5ncy4NCj4gDQo+PiBQZXJoYXBzIHlvdSB3YW50
IHRvIGNhY2hlIHRoZSBjYWNoYWJpbGl0eS1tb2RlIGluIHZtYS0+dm1fcGFnZV9wcm90ICh3aGlj
aCBJDQo+PiBzZWUgYmVpbmcgZG9uZSBpbiBxdWl0ZSBhIGZldyBjYXNlcyksIGJ1dCBJIGRvbuKA
mXQga25vdyB0aGUgY29kZSB3ZWxsIGVub3VnaA0KPj4gdG8gYmUgY2VydGFpbiB0aGF0IGV2ZXJ5
IHZtYSBzaG91bGQgaGF2ZSBhIHNpbmdsZSBwcm90ZWN0aW9uIGFuZCB0aGF0IGl0DQo+PiBzaG91
bGQgbm90IGNoYW5nZSBhZnRlcndhcmRzLg0KPiANCj4gTm8sIEknbSB0aGlua2luZyB0aGlzIHdv
dWxkIG5hdHVyYWxseSBmaXQgYXMgYSBwcm9wZXJ0eSBoYW5naW5nIG9mZiBhDQo+ICdzdHJ1Y3Qg
ZGF4X2RldmljZScsIGFuZCB0aGVuIGNyZWF0ZSBhIHZlcnNpb24gb2Ygdm1mX2luc2VydF9taXhl
ZCgpDQo+IGFuZCB2bWZfaW5zZXJ0X3Bmbl9wbWQoKSB0aGF0IGJ5cGFzcyB0cmFja19wZm5faW5z
ZXJ0KCkgdG8gaW5zZXJ0IHRoYXQNCj4gc2F2ZWQgdmFsdWUuDQoNClRoYW5rcyBmb3IgdGhlIGRl
dGFpbGVkIGV4cGxhbmF0aW9uLiBJ4oCZbGwgZ2l2ZSBpdCBhIHRyeSAodGhlIG1vbWVudCBJIGZp
bmQNCnNvbWUgZnJlZSB0aW1lKS4gSSBzdGlsbCB0aGluayB0aGF0IHBhdGNoIDIvMyBpcyBiZW5l
ZmljaWFsLCBidXQgYmFzZWQgb24NCnlvdXIgZmVlZGJhY2ssIHBhdGNoIDMvMyBzaG91bGQgYmUg
ZHJvcHBlZC4NCg0K

