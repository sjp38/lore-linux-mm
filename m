Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A23FC282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 16:04:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E63B20869
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 16:04:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="bofC0lsB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E63B20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9725C6B0010; Fri, 12 Apr 2019 12:04:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F7176B026A; Fri, 12 Apr 2019 12:04:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 772E96B026B; Fri, 12 Apr 2019 12:04:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 515416B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:04:25 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id x8so7208262ybp.14
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 09:04:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=f7oBFBuUUMZqExdodvXw/5iH6kBXEmpotsiHCy+Jh8w=;
        b=FEwMfbt5BFLa0w7sIRH0CbOYFXegu6srFrVNICCVDVVQFMnZRHFnyxvJkyPOnuHQjA
         8RTI80xhb4o5jo5oz5kYh/S+XMogaqoyPExkAQrkIz5mUUzyGBqiU7k53Jlgh2w4l2LM
         y3YgSFHvz11bC1/vcjkkgHtJuIlXv9un9QN5sdzEYAYBSMkMYC82cDEfiI9iGMWIovUq
         YVOAk9vVhqjgxPEVdicChJDi6VO8C3AVCzBXOOP+8IG7a92fD2XeVJ6E7VZudwpNULJ6
         eZSMcv5/QP6m1cBscxlpAJKLx6vqaLOAyHl7kQjFm4vsdfcBPFE+6dDL6l4KO2NEFmIS
         gZRg==
X-Gm-Message-State: APjAAAXUezGOoC6NXv5ZhDPCi3SqbkjFVL4waUFWRrKzXuEFUKd3kl/e
	YH/NEfXFGSGATMFpt57nXXtyEqHW77Sx2xW9NkBe0NqveDtDRLC+3mrPBDN4xAqJRvRsGJbaKRm
	y2hggiUhdbVwnY2M5svtFIOBdE/U483mj2CSPqKBseGGPL2On6jL6afXXeYPbdRPL4Q==
X-Received: by 2002:a0d:dfca:: with SMTP id i193mr46596716ywe.290.1555085065004;
        Fri, 12 Apr 2019 09:04:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhZICVq8D2/M5GaoycqhxIrxl7DerScsbHHGba1Vd2Py37Cmz6VpMzMBSe1RXjyEwTnlpk
X-Received: by 2002:a0d:dfca:: with SMTP id i193mr46596617ywe.290.1555085063980;
        Fri, 12 Apr 2019 09:04:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555085063; cv=none;
        d=google.com; s=arc-20160816;
        b=GcDqnf0kf+xbR/DT7aIoytL1hxDfUhqVOJjZ2NVmplbWtuI7Qcvm6Tjy4VgMuE/86T
         vwr71KPkRh5fmahuoh4oeA3Wk7Ti7liYB0wu3tTBuCPva+xwlklfoclwrYyL2C6GVdXT
         TFfe8vKoJ7gF2lveeBIOVFCIr7s/RCTiHIkFohxsrqTzJskq+ODEvSdm2Pv/bBAJz2LP
         VwyUhmGEm9k9JrmkPWtNSwdIyKsxulrV0I8HTJKz+iFxn79EFu+nUtdudBaaongf62fX
         H5gc8sEQ2jb2aioTD5spMJ3Ks1hNEaYfQkKP4AVf6gL60P8/+F0E0yliT/BdwXwJwN28
         7gXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=f7oBFBuUUMZqExdodvXw/5iH6kBXEmpotsiHCy+Jh8w=;
        b=k8Tm6ig5ZCMn5ie/S44VDZFdcnpsR67GTB2jVSuDbJf2s5k+Ba/FouKrQmu3gObcTJ
         GQTagiciF7O6v+SmMN7+NijjCs50j2xUGwHaimZN7XWn7ESW8x/00jyWT9AUU2wSw6D9
         5372FXyumnIIcA6r13eC93YQW5d9ucNXeanAgRZF8sj4ccst1lKU4k/6y6tyF8CQ0mlk
         ejq+ZU14JH29HIN8WwJl+aJH0gvbZ3W/hAFk1N1SeLq04fqzMmjkSZbxiuUEZXbxU116
         Xkjp9uh6l6erQAr2f3pHRY8kkUJAHJCqrrJvfF040UeyPFVsB0i4KfCyd5BFas4n31cd
         HrpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=bofC0lsB;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.51 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800051.outbound.protection.outlook.com. [40.107.80.51])
        by mx.google.com with ESMTPS id h67si17918478ywh.96.2019.04.12.09.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 12 Apr 2019 09:04:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.51 as permitted sender) client-ip=40.107.80.51;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=bofC0lsB;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.51 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=f7oBFBuUUMZqExdodvXw/5iH6kBXEmpotsiHCy+Jh8w=;
 b=bofC0lsBadQ4QNmho8df4eXjXo5g9ynYsthu7xNM8egPh+P+vmjs8KPT2n5a7QXlDjtjBM6iCGHEP/Fm2IVISFtGKZKTUmnAgB6POk3KZ50NRgcW3xPtBQ1gJebZBDsfeI9NQLoxMFyTETJIAyzsgKCHRsnIO234ZjIlYH+j664=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6030.namprd05.prod.outlook.com (20.178.241.159) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.9; Fri, 12 Apr 2019 16:04:19 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad%7]) with mapi id 15.20.1792.009; Fri, 12 Apr 2019
 16:04:19 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: Thomas Hellstrom <thellstrom@vmware.com>, Andrew Morton
	<akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Will
 Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, Rik van
 Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko
	<mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Souptick Joarder
	<jrdr.linux@gmail.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: [PATCH 2/9] mm: Add an apply_to_pfn_range interface
Thread-Topic: [PATCH 2/9] mm: Add an apply_to_pfn_range interface
Thread-Index: AQHU8UlivMPCX9sP50+Af9Zp3fb7Aw==
Date: Fri, 12 Apr 2019 16:04:18 +0000
Message-ID: <20190412160338.64994-3-thellstrom@vmware.com>
References: <20190412160338.64994-1-thellstrom@vmware.com>
In-Reply-To: <20190412160338.64994-1-thellstrom@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: VE1PR03CA0023.eurprd03.prod.outlook.com
 (2603:10a6:802:a0::35) To MN2PR05MB6141.namprd05.prod.outlook.com
 (2603:10b6:208:c7::25)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.20.1
x-originating-ip: [155.4.205.35]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ceb25dd5-c65d-4956-ceb0-08d6bf6084cd
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:MN2PR05MB6030;
x-ms-traffictypediagnostic: MN2PR05MB6030:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB60305783771B84A94A98DA8DA1280@MN2PR05MB6030.namprd05.prod.outlook.com>
x-forefront-prvs: 0005B05917
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(346002)(376002)(39860400002)(396003)(199004)(189003)(110136005)(25786009)(476003)(2616005)(71190400001)(6512007)(2906002)(186003)(486006)(316002)(54906003)(68736007)(1076003)(6486002)(6436002)(446003)(478600001)(3846002)(71200400001)(6116002)(11346002)(66574012)(99286004)(256004)(14444005)(14454004)(2501003)(8676002)(66066001)(7736002)(4326008)(6506007)(81166006)(36756003)(81156014)(386003)(97736004)(102836004)(50226002)(106356001)(52116002)(5660300002)(53936002)(8936002)(7416002)(305945005)(76176011)(26005)(86362001)(105586002);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6030;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 WU9SNH03eeDNGq/ip+SsIVF7fIXqp/bqU5kKsIzAESgdo2W+c0dl6focC/dgDGwE1BVlnlwlF1D5VEXmjcAcYDiQdZUvijRDvsHRrIl9npPwhgGa5zeHs8KFv0M4oTO5AnL6mZYOgOjNYTelnxFvTx9uVrdFWP6qEvzdbD/ewQmNy4hDSViPT+/D8xlK86R+C4/DAGlV9plMJvihBfxl7OZ6tDd1S4CsHsKh7i1ENz0vuzFVKLilxBLsRufPbvBKW1khhSoMFimIbJzSIlvGlESadW4ac6FFOrxJECtDFe9IsWtGlbZmKdiANPe+8ar7/Xl3pFfsqCID64eynrtHTprnSSrz+bUN6ixNHDxmpuuTjhCAWLihB0o7ZmNLc2Scbz0N+Xvf0WbkQNmMMqZfZl7IwfRQU7FyI9XOeFKVq5I=
Content-Type: text/plain; charset="utf-8"
Content-ID: <D786105394F1C04A9B58F98184CE1E06@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ceb25dd5-c65d-4956-ceb0-08d6bf6084cd
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Apr 2019 16:04:19.0183
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6030
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

VGhpcyBpcyBiYXNpY2FsbHkgYXBwbHlfdG9fcGFnZV9yYW5nZSB3aXRoIGFkZGVkIGZ1bmN0aW9u
YWxpdHk6DQpBbGxvY2F0aW5nIG1pc3NpbmcgcGFydHMgb2YgdGhlIHBhZ2UgdGFibGUgYmVjb21l
cyBvcHRpb25hbCwgd2hpY2gNCm1lYW5zIHRoYXQgdGhlIGZ1bmN0aW9uIGNhbiBiZSBndWFyYW50
ZWVkIG5vdCB0byBlcnJvciBpZiBhbGxvY2F0aW9uDQppcyBkaXNhYmxlZC4gQWxzbyBwYXNzaW5n
IG9mIHRoZSBjbG9zdXJlIHN0cnVjdCBhbmQgY2FsbGJhY2sgZnVuY3Rpb24NCmJlY29tZXMgZGlm
ZmVyZW50IGFuZCBtb3JlIGluIGxpbmUgd2l0aCBob3cgdGhpbmdzIGFyZSBkb25lIGVsc2V3aGVy
ZS4NCg0KRmluYWxseSB3ZSBrZWVwIGFwcGx5X3RvX3BhZ2VfcmFuZ2UgYXMgYSB3cmFwcGVyIGFy
b3VuZCBhcHBseV90b19wZm5fcmFuZ2UNCg0KVGhlIHJlYXNvbiBmb3Igbm90IHVzaW5nIHRoZSBw
YWdlLXdhbGsgY29kZSBpcyB0aGF0IHdlIHdhbnQgdG8gcGVyZm9ybQ0KdGhlIHBhZ2Utd2FsayBv
biB2bWFzIHBvaW50aW5nIHRvIGFuIGFkZHJlc3Mgc3BhY2Ugd2l0aG91dCByZXF1aXJpbmcgdGhl
DQptbWFwX3NlbSB0byBiZSBoZWxkIHJhdGhlciB0aGFuZCBvbiB2bWFzIGJlbG9uZ2luZyB0byBh
IHByb2Nlc3Mgd2l0aCB0aGUNCm1tYXBfc2VtIGhlbGQuDQoNCk5vdGFibGUgY2hhbmdlcyBzaW5j
ZSBSRkM6DQpEb24ndCBleHBvcnQgYXBwbHlfdG9fcGZuIHJhbmdlLg0KDQpDYzogQW5kcmV3IE1v
cnRvbiA8YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4NCkNjOiBNYXR0aGV3IFdpbGNveCA8d2ls
bHlAaW5mcmFkZWFkLm9yZz4NCkNjOiBXaWxsIERlYWNvbiA8d2lsbC5kZWFjb25AYXJtLmNvbT4N
CkNjOiBQZXRlciBaaWpsc3RyYSA8cGV0ZXJ6QGluZnJhZGVhZC5vcmc+DQpDYzogUmlrIHZhbiBS
aWVsIDxyaWVsQHN1cnJpZWwuY29tPg0KQ2M6IE1pbmNoYW4gS2ltIDxtaW5jaGFuQGtlcm5lbC5v
cmc+DQpDYzogTWljaGFsIEhvY2tvIDxtaG9ja29Ac3VzZS5jb20+DQpDYzogSHVhbmcgWWluZyA8
eWluZy5odWFuZ0BpbnRlbC5jb20+DQpDYzogU291cHRpY2sgSm9hcmRlciA8anJkci5saW51eEBn
bWFpbC5jb20+DQpDYzogIkrDqXLDtG1lIEdsaXNzZSIgPGpnbGlzc2VAcmVkaGF0LmNvbT4NCkNj
OiBsaW51eC1tbUBrdmFjay5vcmcNCkNjOiBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQpT
aWduZWQtb2ZmLWJ5OiBUaG9tYXMgSGVsbHN0cm9tIDx0aGVsbHN0cm9tQHZtd2FyZS5jb20+DQot
LS0NCiBpbmNsdWRlL2xpbnV4L21tLmggfCAgMTAgKysrKw0KIG1tL21lbW9yeS5jICAgICAgICB8
IDEzMCArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0NCiAyIGZp
bGVzIGNoYW5nZWQsIDEwOCBpbnNlcnRpb25zKCspLCAzMiBkZWxldGlvbnMoLSkNCg0KZGlmZiAt
LWdpdCBhL2luY2x1ZGUvbGludXgvbW0uaCBiL2luY2x1ZGUvbGludXgvbW0uaA0KaW5kZXggODBi
YjY0MDhmZTczLi5iN2RkNGRkZDZlZmIgMTAwNjQ0DQotLS0gYS9pbmNsdWRlL2xpbnV4L21tLmgN
CisrKyBiL2luY2x1ZGUvbGludXgvbW0uaA0KQEAgLTI2MzIsNiArMjYzMiwxNiBAQCB0eXBlZGVm
IGludCAoKnB0ZV9mbl90KShwdGVfdCAqcHRlLCBwZ3RhYmxlX3QgdG9rZW4sIHVuc2lnbmVkIGxv
bmcgYWRkciwNCiBleHRlcm4gaW50IGFwcGx5X3RvX3BhZ2VfcmFuZ2Uoc3RydWN0IG1tX3N0cnVj
dCAqbW0sIHVuc2lnbmVkIGxvbmcgYWRkcmVzcywNCiAJCQkgICAgICAgdW5zaWduZWQgbG9uZyBz
aXplLCBwdGVfZm5fdCBmbiwgdm9pZCAqZGF0YSk7DQogDQorc3RydWN0IHBmbl9yYW5nZV9hcHBs
eTsNCit0eXBlZGVmIGludCAoKnB0ZXJfZm5fdCkocHRlX3QgKnB0ZSwgcGd0YWJsZV90IHRva2Vu
LCB1bnNpZ25lZCBsb25nIGFkZHIsDQorCQkJIHN0cnVjdCBwZm5fcmFuZ2VfYXBwbHkgKmNsb3N1
cmUpOw0KK3N0cnVjdCBwZm5fcmFuZ2VfYXBwbHkgew0KKwlzdHJ1Y3QgbW1fc3RydWN0ICptbTsN
CisJcHRlcl9mbl90IHB0ZWZuOw0KKwl1bnNpZ25lZCBpbnQgYWxsb2M7DQorfTsNCitleHRlcm4g
aW50IGFwcGx5X3RvX3Bmbl9yYW5nZShzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpjbG9zdXJlLA0K
KwkJCSAgICAgIHVuc2lnbmVkIGxvbmcgYWRkcmVzcywgdW5zaWduZWQgbG9uZyBzaXplKTsNCiAN
CiAjaWZkZWYgQ09ORklHX1BBR0VfUE9JU09OSU5HDQogZXh0ZXJuIGJvb2wgcGFnZV9wb2lzb25p
bmdfZW5hYmxlZCh2b2lkKTsNCmRpZmYgLS1naXQgYS9tbS9tZW1vcnkuYyBiL21tL21lbW9yeS5j
DQppbmRleCBhOTViNGEzYjFhZTIuLjYwZDY3MTU4OTY0ZiAxMDA2NDQNCi0tLSBhL21tL21lbW9y
eS5jDQorKysgYi9tbS9tZW1vcnkuYw0KQEAgLTE5MzgsMTggKzE5MzgsMTcgQEAgaW50IHZtX2lv
bWFwX21lbW9yeShzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwgcGh5c19hZGRyX3Qgc3RhcnQs
IHVuc2lnbmVkIGxvbmcNCiB9DQogRVhQT1JUX1NZTUJPTCh2bV9pb21hcF9tZW1vcnkpOw0KIA0K
LXN0YXRpYyBpbnQgYXBwbHlfdG9fcHRlX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCBwbWRf
dCAqcG1kLA0KLQkJCQkgICAgIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWduZWQgbG9uZyBlbmQs
DQotCQkJCSAgICAgcHRlX2ZuX3QgZm4sIHZvaWQgKmRhdGEpDQorc3RhdGljIGludCBhcHBseV90
b19wdGVfcmFuZ2Uoc3RydWN0IHBmbl9yYW5nZV9hcHBseSAqY2xvc3VyZSwgcG1kX3QgKnBtZCwN
CisJCQkgICAgICB1bnNpZ25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcgZW5kKQ0KIHsNCiAJ
cHRlX3QgKnB0ZTsNCiAJaW50IGVycjsNCiAJcGd0YWJsZV90IHRva2VuOw0KIAlzcGlubG9ja190
ICp1bmluaXRpYWxpemVkX3ZhcihwdGwpOw0KIA0KLQlwdGUgPSAobW0gPT0gJmluaXRfbW0pID8N
CisJcHRlID0gKGNsb3N1cmUtPm1tID09ICZpbml0X21tKSA/DQogCQlwdGVfYWxsb2Nfa2VybmVs
KHBtZCwgYWRkcikgOg0KLQkJcHRlX2FsbG9jX21hcF9sb2NrKG1tLCBwbWQsIGFkZHIsICZwdGwp
Ow0KKwkJcHRlX2FsbG9jX21hcF9sb2NrKGNsb3N1cmUtPm1tLCBwbWQsIGFkZHIsICZwdGwpOw0K
IAlpZiAoIXB0ZSkNCiAJCXJldHVybiAtRU5PTUVNOw0KIA0KQEAgLTE5NjAsODYgKzE5NTksMTA3
IEBAIHN0YXRpYyBpbnQgYXBwbHlfdG9fcHRlX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCBw
bWRfdCAqcG1kLA0KIAl0b2tlbiA9IHBtZF9wZ3RhYmxlKCpwbWQpOw0KIA0KIAlkbyB7DQotCQll
cnIgPSBmbihwdGUrKywgdG9rZW4sIGFkZHIsIGRhdGEpOw0KKwkJZXJyID0gY2xvc3VyZS0+cHRl
Zm4ocHRlKyssIHRva2VuLCBhZGRyLCBjbG9zdXJlKTsNCiAJCWlmIChlcnIpDQogCQkJYnJlYWs7
DQogCX0gd2hpbGUgKGFkZHIgKz0gUEFHRV9TSVpFLCBhZGRyICE9IGVuZCk7DQogDQogCWFyY2hf
bGVhdmVfbGF6eV9tbXVfbW9kZSgpOw0KIA0KLQlpZiAobW0gIT0gJmluaXRfbW0pDQorCWlmIChj
bG9zdXJlLT5tbSAhPSAmaW5pdF9tbSkNCiAJCXB0ZV91bm1hcF91bmxvY2socHRlLTEsIHB0bCk7
DQogCXJldHVybiBlcnI7DQogfQ0KIA0KLXN0YXRpYyBpbnQgYXBwbHlfdG9fcG1kX3JhbmdlKHN0
cnVjdCBtbV9zdHJ1Y3QgKm1tLCBwdWRfdCAqcHVkLA0KLQkJCQkgICAgIHVuc2lnbmVkIGxvbmcg
YWRkciwgdW5zaWduZWQgbG9uZyBlbmQsDQotCQkJCSAgICAgcHRlX2ZuX3QgZm4sIHZvaWQgKmRh
dGEpDQorc3RhdGljIGludCBhcHBseV90b19wbWRfcmFuZ2Uoc3RydWN0IHBmbl9yYW5nZV9hcHBs
eSAqY2xvc3VyZSwgcHVkX3QgKnB1ZCwNCisJCQkgICAgICB1bnNpZ25lZCBsb25nIGFkZHIsIHVu
c2lnbmVkIGxvbmcgZW5kKQ0KIHsNCiAJcG1kX3QgKnBtZDsNCiAJdW5zaWduZWQgbG9uZyBuZXh0
Ow0KLQlpbnQgZXJyOw0KKwlpbnQgZXJyID0gMDsNCiANCiAJQlVHX09OKHB1ZF9odWdlKCpwdWQp
KTsNCiANCi0JcG1kID0gcG1kX2FsbG9jKG1tLCBwdWQsIGFkZHIpOw0KKwlwbWQgPSBwbWRfYWxs
b2MoY2xvc3VyZS0+bW0sIHB1ZCwgYWRkcik7DQogCWlmICghcG1kKQ0KIAkJcmV0dXJuIC1FTk9N
RU07DQorDQogCWRvIHsNCiAJCW5leHQgPSBwbWRfYWRkcl9lbmQoYWRkciwgZW5kKTsNCi0JCWVy
ciA9IGFwcGx5X3RvX3B0ZV9yYW5nZShtbSwgcG1kLCBhZGRyLCBuZXh0LCBmbiwgZGF0YSk7DQor
CQlpZiAoIWNsb3N1cmUtPmFsbG9jICYmIHBtZF9ub25lX29yX2NsZWFyX2JhZChwbWQpKQ0KKwkJ
CWNvbnRpbnVlOw0KKwkJZXJyID0gYXBwbHlfdG9fcHRlX3JhbmdlKGNsb3N1cmUsIHBtZCwgYWRk
ciwgbmV4dCk7DQogCQlpZiAoZXJyKQ0KIAkJCWJyZWFrOw0KIAl9IHdoaWxlIChwbWQrKywgYWRk
ciA9IG5leHQsIGFkZHIgIT0gZW5kKTsNCiAJcmV0dXJuIGVycjsNCiB9DQogDQotc3RhdGljIGlu
dCBhcHBseV90b19wdWRfcmFuZ2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHA0ZF90ICpwNGQsDQot
CQkJCSAgICAgdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGVuZCwNCi0JCQkJICAg
ICBwdGVfZm5fdCBmbiwgdm9pZCAqZGF0YSkNCitzdGF0aWMgaW50IGFwcGx5X3RvX3B1ZF9yYW5n
ZShzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpjbG9zdXJlLCBwNGRfdCAqcDRkLA0KKwkJCSAgICAg
IHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWduZWQgbG9uZyBlbmQpDQogew0KIAlwdWRfdCAqcHVk
Ow0KIAl1bnNpZ25lZCBsb25nIG5leHQ7DQotCWludCBlcnI7DQorCWludCBlcnIgPSAwOw0KIA0K
LQlwdWQgPSBwdWRfYWxsb2MobW0sIHA0ZCwgYWRkcik7DQorCXB1ZCA9IHB1ZF9hbGxvYyhjbG9z
dXJlLT5tbSwgcDRkLCBhZGRyKTsNCiAJaWYgKCFwdWQpDQogCQlyZXR1cm4gLUVOT01FTTsNCisN
CiAJZG8gew0KIAkJbmV4dCA9IHB1ZF9hZGRyX2VuZChhZGRyLCBlbmQpOw0KLQkJZXJyID0gYXBw
bHlfdG9fcG1kX3JhbmdlKG1tLCBwdWQsIGFkZHIsIG5leHQsIGZuLCBkYXRhKTsNCisJCWlmICgh
Y2xvc3VyZS0+YWxsb2MgJiYgcHVkX25vbmVfb3JfY2xlYXJfYmFkKHB1ZCkpDQorCQkJY29udGlu
dWU7DQorCQllcnIgPSBhcHBseV90b19wbWRfcmFuZ2UoY2xvc3VyZSwgcHVkLCBhZGRyLCBuZXh0
KTsNCiAJCWlmIChlcnIpDQogCQkJYnJlYWs7DQogCX0gd2hpbGUgKHB1ZCsrLCBhZGRyID0gbmV4
dCwgYWRkciAhPSBlbmQpOw0KIAlyZXR1cm4gZXJyOw0KIH0NCiANCi1zdGF0aWMgaW50IGFwcGx5
X3RvX3A0ZF9yYW5nZShzdHJ1Y3QgbW1fc3RydWN0ICptbSwgcGdkX3QgKnBnZCwNCi0JCQkJICAg
ICB1bnNpZ25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcgZW5kLA0KLQkJCQkgICAgIHB0ZV9m
bl90IGZuLCB2b2lkICpkYXRhKQ0KK3N0YXRpYyBpbnQgYXBwbHlfdG9fcDRkX3JhbmdlKHN0cnVj
dCBwZm5fcmFuZ2VfYXBwbHkgKmNsb3N1cmUsIHBnZF90ICpwZ2QsDQorCQkJICAgICAgdW5zaWdu
ZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGVuZCkNCiB7DQogCXA0ZF90ICpwNGQ7DQogCXVu
c2lnbmVkIGxvbmcgbmV4dDsNCi0JaW50IGVycjsNCisJaW50IGVyciA9IDA7DQogDQotCXA0ZCA9
IHA0ZF9hbGxvYyhtbSwgcGdkLCBhZGRyKTsNCisJcDRkID0gcDRkX2FsbG9jKGNsb3N1cmUtPm1t
LCBwZ2QsIGFkZHIpOw0KIAlpZiAoIXA0ZCkNCiAJCXJldHVybiAtRU5PTUVNOw0KKw0KIAlkbyB7
DQogCQluZXh0ID0gcDRkX2FkZHJfZW5kKGFkZHIsIGVuZCk7DQotCQllcnIgPSBhcHBseV90b19w
dWRfcmFuZ2UobW0sIHA0ZCwgYWRkciwgbmV4dCwgZm4sIGRhdGEpOw0KKwkJaWYgKCFjbG9zdXJl
LT5hbGxvYyAmJiBwNGRfbm9uZV9vcl9jbGVhcl9iYWQocDRkKSkNCisJCQljb250aW51ZTsNCisJ
CWVyciA9IGFwcGx5X3RvX3B1ZF9yYW5nZShjbG9zdXJlLCBwNGQsIGFkZHIsIG5leHQpOw0KIAkJ
aWYgKGVycikNCiAJCQlicmVhazsNCiAJfSB3aGlsZSAocDRkKyssIGFkZHIgPSBuZXh0LCBhZGRy
ICE9IGVuZCk7DQogCXJldHVybiBlcnI7DQogfQ0KIA0KLS8qDQotICogU2NhbiBhIHJlZ2lvbiBv
ZiB2aXJ0dWFsIG1lbW9yeSwgZmlsbGluZyBpbiBwYWdlIHRhYmxlcyBhcyBuZWNlc3NhcnkNCi0g
KiBhbmQgY2FsbGluZyBhIHByb3ZpZGVkIGZ1bmN0aW9uIG9uIGVhY2ggbGVhZiBwYWdlIHRhYmxl
Lg0KKy8qKg0KKyAqIGFwcGx5X3RvX3Bmbl9yYW5nZSAtIFNjYW4gYSByZWdpb24gb2YgdmlydHVh
bCBtZW1vcnksIGNhbGxpbmcgYSBwcm92aWRlZA0KKyAqIGZ1bmN0aW9uIG9uIGVhY2ggbGVhZiBw
YWdlIHRhYmxlIGVudHJ5DQorICogQGNsb3N1cmU6IERldGFpbHMgYWJvdXQgaG93IHRvIHNjYW4g
YW5kIHdoYXQgZnVuY3Rpb24gdG8gYXBwbHkNCisgKiBAYWRkcjogU3RhcnQgdmlydHVhbCBhZGRy
ZXNzDQorICogQHNpemU6IFNpemUgb2YgdGhlIHJlZ2lvbg0KKyAqDQorICogSWYgQGNsb3N1cmUt
PmFsbG9jIGlzIHNldCB0byAxLCB0aGUgZnVuY3Rpb24gd2lsbCBmaWxsIGluIHRoZSBwYWdlIHRh
YmxlDQorICogYXMgbmVjZXNzYXJ5LiBPdGhlcndpc2UgaXQgd2lsbCBza2lwIG5vbi1wcmVzZW50
IHBhcnRzLg0KKyAqIE5vdGU6IFRoZSBjYWxsZXIgbXVzdCBlbnN1cmUgdGhhdCB0aGUgcmFuZ2Ug
ZG9lcyBub3QgY29udGFpbiBodWdlIHBhZ2VzLg0KKyAqIFRoZSBjYWxsZXIgbXVzdCBhbHNvIGFz
c3VyZSB0aGF0IHRoZSBwcm9wZXIgbW11X25vdGlmaWVyIGZ1bmN0aW9ucyBhcmUNCisgKiBjYWxs
ZWQuIEVpdGhlciBpbiB0aGUgcHRlIGxlYWYgZnVuY3Rpb24gb3IgYmVmb3JlIGFuZCBhZnRlciB0
aGUgY2FsbCB0bw0KKyAqIGFwcGx5X3RvX3Bmbl9yYW5nZS4NCisgKg0KKyAqIFJldHVybnM6IFpl
cm8gb24gc3VjY2Vzcy4gSWYgdGhlIHByb3ZpZGVkIGZ1bmN0aW9uIHJldHVybnMgYSBub24temVy
byBzdGF0dXMsDQorICogdGhlIHBhZ2UgdGFibGUgd2FsayB3aWxsIHRlcm1pbmF0ZSBhbmQgdGhh
dCBzdGF0dXMgd2lsbCBiZSByZXR1cm5lZC4NCisgKiBJZiBAY2xvc3VyZS0+YWxsb2MgaXMgc2V0
IHRvIDEsIHRoZW4gdGhpcyBmdW5jdGlvbiBtYXkgYWxzbyByZXR1cm4gbWVtb3J5DQorICogYWxs
b2NhdGlvbiBlcnJvcnMgYXJpc2luZyBmcm9tIGFsbG9jYXRpbmcgcGFnZSB0YWJsZSBtZW1vcnku
DQogICovDQotaW50IGFwcGx5X3RvX3BhZ2VfcmFuZ2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHVu
c2lnbmVkIGxvbmcgYWRkciwNCi0JCQl1bnNpZ25lZCBsb25nIHNpemUsIHB0ZV9mbl90IGZuLCB2
b2lkICpkYXRhKQ0KK2ludCBhcHBseV90b19wZm5fcmFuZ2Uoc3RydWN0IHBmbl9yYW5nZV9hcHBs
eSAqY2xvc3VyZSwNCisJCSAgICAgICB1bnNpZ25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcg
c2l6ZSkNCiB7DQogCXBnZF90ICpwZ2Q7DQogCXVuc2lnbmVkIGxvbmcgbmV4dDsNCkBAIC0yMDQ5
LDE2ICsyMDY5LDYyIEBAIGludCBhcHBseV90b19wYWdlX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3Qg
Km1tLCB1bnNpZ25lZCBsb25nIGFkZHIsDQogCWlmIChXQVJOX09OKGFkZHIgPj0gZW5kKSkNCiAJ
CXJldHVybiAtRUlOVkFMOw0KIA0KLQlwZ2QgPSBwZ2Rfb2Zmc2V0KG1tLCBhZGRyKTsNCisJcGdk
ID0gcGdkX29mZnNldChjbG9zdXJlLT5tbSwgYWRkcik7DQogCWRvIHsNCiAJCW5leHQgPSBwZ2Rf
YWRkcl9lbmQoYWRkciwgZW5kKTsNCi0JCWVyciA9IGFwcGx5X3RvX3A0ZF9yYW5nZShtbSwgcGdk
LCBhZGRyLCBuZXh0LCBmbiwgZGF0YSk7DQorCQlpZiAoIWNsb3N1cmUtPmFsbG9jICYmIHBnZF9u
b25lX29yX2NsZWFyX2JhZChwZ2QpKQ0KKwkJCWNvbnRpbnVlOw0KKwkJZXJyID0gYXBwbHlfdG9f
cDRkX3JhbmdlKGNsb3N1cmUsIHBnZCwgYWRkciwgbmV4dCk7DQogCQlpZiAoZXJyKQ0KIAkJCWJy
ZWFrOw0KIAl9IHdoaWxlIChwZ2QrKywgYWRkciA9IG5leHQsIGFkZHIgIT0gZW5kKTsNCiANCiAJ
cmV0dXJuIGVycjsNCiB9DQorDQorLyoqDQorICogc3RydWN0IHBhZ2VfcmFuZ2VfYXBwbHkgLSBD
bG9zdXJlIHN0cnVjdHVyZSBmb3IgYXBwbHlfdG9fcGFnZV9yYW5nZSgpDQorICogQHB0ZXI6IFRo
ZSBiYXNlIGNsb3N1cmUgc3RydWN0dXJlIHdlIGRlcml2ZSBmcm9tDQorICogQGZuOiBUaGUgbGVh
ZiBwdGUgZnVuY3Rpb24gdG8gY2FsbA0KKyAqIEBkYXRhOiBUaGUgbGVhZiBwdGUgZnVuY3Rpb24g
Y2xvc3VyZQ0KKyAqLw0KK3N0cnVjdCBwYWdlX3JhbmdlX2FwcGx5IHsNCisJc3RydWN0IHBmbl9y
YW5nZV9hcHBseSBwdGVyOw0KKwlwdGVfZm5fdCBmbjsNCisJdm9pZCAqZGF0YTsNCit9Ow0KKw0K
Ky8qDQorICogQ2FsbGJhY2sgd3JhcHBlciB0byBlbmFibGUgdXNlIG9mIGFwcGx5X3RvX3Bmbl9y
YW5nZSBmb3INCisgKiB0aGUgYXBwbHlfdG9fcGFnZV9yYW5nZSBpbnRlcmZhY2UNCisgKi8NCitz
dGF0aWMgaW50IGFwcGx5X3RvX3BhZ2VfcmFuZ2Vfd3JhcHBlcihwdGVfdCAqcHRlLCBwZ3RhYmxl
X3QgdG9rZW4sDQorCQkJCSAgICAgICB1bnNpZ25lZCBsb25nIGFkZHIsDQorCQkJCSAgICAgICBz
dHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpwdGVyKQ0KK3sNCisJc3RydWN0IHBhZ2VfcmFuZ2VfYXBw
bHkgKnByYSA9DQorCQljb250YWluZXJfb2YocHRlciwgdHlwZW9mKCpwcmEpLCBwdGVyKTsNCisN
CisJcmV0dXJuIHByYS0+Zm4ocHRlLCB0b2tlbiwgYWRkciwgcHJhLT5kYXRhKTsNCit9DQorDQor
LyoNCisgKiBTY2FuIGEgcmVnaW9uIG9mIHZpcnR1YWwgbWVtb3J5LCBmaWxsaW5nIGluIHBhZ2Ug
dGFibGVzIGFzIG5lY2Vzc2FyeQ0KKyAqIGFuZCBjYWxsaW5nIGEgcHJvdmlkZWQgZnVuY3Rpb24g
b24gZWFjaCBsZWFmIHBhZ2UgdGFibGUuDQorICovDQoraW50IGFwcGx5X3RvX3BhZ2VfcmFuZ2Uo
c3RydWN0IG1tX3N0cnVjdCAqbW0sIHVuc2lnbmVkIGxvbmcgYWRkciwNCisJCQl1bnNpZ25lZCBs
b25nIHNpemUsIHB0ZV9mbl90IGZuLCB2b2lkICpkYXRhKQ0KK3sNCisJc3RydWN0IHBhZ2VfcmFu
Z2VfYXBwbHkgcHJhID0gew0KKwkJLnB0ZXIgPSB7Lm1tID0gbW0sDQorCQkJIC5hbGxvYyA9IDEs
DQorCQkJIC5wdGVmbiA9IGFwcGx5X3RvX3BhZ2VfcmFuZ2Vfd3JhcHBlciB9LA0KKwkJLmZuID0g
Zm4sDQorCQkuZGF0YSA9IGRhdGENCisJfTsNCisNCisJcmV0dXJuIGFwcGx5X3RvX3Bmbl9yYW5n
ZSgmcHJhLnB0ZXIsIGFkZHIsIHNpemUpOw0KK30NCiBFWFBPUlRfU1lNQk9MX0dQTChhcHBseV90
b19wYWdlX3JhbmdlKTsNCiANCiAvKg0KLS0gDQoyLjIwLjENCg0K

