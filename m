Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC8F4C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 12:00:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EBFB218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 12:00:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="Z62YwseQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EBFB218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B1E76B0007; Wed, 24 Apr 2019 08:00:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 457706B0008; Wed, 24 Apr 2019 08:00:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DD026B000C; Wed, 24 Apr 2019 08:00:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id DDB316B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 08:00:31 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id k28so10682316otf.3
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 05:00:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=QBWt2g/z3v41SOvbwMr7NQcEzmiLjjfyLkhHpnrA4lc=;
        b=Ht3fI1e0VVZQL3b8EPJqQQUTXnk8e7uyeGhMWHMLFiPZNpiuZR0YTACsJNluV/JDAS
         OOO93z4qhrCkqHdsKvgs0ZMhUnkSDvifvAwenMhyi6zzHhkj8u+41UGfoCj540UceU8N
         9ATEg3P2LBnkwl5SiGWkcnyuYl8eN5+JbjCwYpPurT5Y9u5ZUu1JqbSO6YiyyT4sYlsa
         0mXvGgFedqy4R5i2vRvajueURiKxAfc+uCznAp4lv7XJsHN2iH51sOJu4STB+ZJ7EIN5
         MV9L4caIhgqTjMBeWlXd9XkHb+lx74leA+crr58y8bqM0oTrKjbIj+MvVOuboXnGJRJI
         VlSw==
X-Gm-Message-State: APjAAAX/BnsNzmXa0HB1aVxqpCDN0vhTxZxhUZ7NetRt9XmgqvQNqBuh
	x+O2mrGMSS/tAfTJtTzPXV14tqrGM+lJkl7hh5GjAQrsdqIvgcLKCYYf84Lx6R5+CcyC3j1cusT
	pvD9Xdisr6WWacWjpxXY2PjwM2bnIphN2GR+aFUjC3BIC1aHD+W8RoqBdDdNIAjzI+g==
X-Received: by 2002:a05:6830:1017:: with SMTP id a23mr20097902otp.120.1556107231217;
        Wed, 24 Apr 2019 05:00:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyf2nir3l3+spXQaupsQX4szAZfTiKjHiRiUSTFxbPauMCuJVrj5JCnyGfdFrc+c5L4JSri
X-Received: by 2002:a05:6830:1017:: with SMTP id a23mr20097793otp.120.1556107229875;
        Wed, 24 Apr 2019 05:00:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556107229; cv=none;
        d=google.com; s=arc-20160816;
        b=DMYYORdv+2SRj+ypmdk5XTioB3e4uZXE+BuXFy2yRoUyNdqlSWjGmKnIf+M0WuvZVB
         ZNvlA6nRIsvF7d1W2bypuZGx9mgI4uKw9QzVljX9xKekmh/VJzx7DPqkVFRoivAj4oxx
         hKzpO5cmT+ozWZ8L6W396Jvs9dOezIVbQoCdHx4ithhfqWcvHT3GP+u82c/3Mr6Of3eH
         cdvFoH4SI9IDMfwVruhWDv/BpgSmKWVZx2iQ2m0NfkDEMDyc/P/mkMtt5oboZQPbjGA4
         cf1gRh5Z9lExV4jWOeQcIiacv/Iw6pbxg0NZdj11hYZJPKyLQFNt00p8pCSvB3cVHwnV
         ZzIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=QBWt2g/z3v41SOvbwMr7NQcEzmiLjjfyLkhHpnrA4lc=;
        b=cMeUj4SaJ2b1LO2odr9kxv2I1gZghVHfHq1XJ9sYTaEZy0GWqbbIHbBZOJbSp+oHkj
         ptdcdULeU8PSHxkgojhZUIMte+fHKnyJEuYTBkCJiKr8oeu2HgEjyPX3nTyRfbpoc/R6
         YQKzavfxR6f69cs3Xc4bqjLtJZfXW2RPUHS1ouaLPEy1zq/0+aqpSM/R3bkb+wuLGOkS
         OhpLvjVHtcTrl6vSv6xmnAf9NK38IcfVYBG4t7fVCF9KL+YCgAaDkFip3ZoRNTbsbxQU
         xCf2qpPVphtC7ajQqJBpvdXXZ/OvTuSQ6uMuEGcZ+CJ7ERe7RRW4GbXyQ9Xj9glAe5mr
         J9iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=Z62YwseQ;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.81.48 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810048.outbound.protection.outlook.com. [40.107.81.48])
        by mx.google.com with ESMTPS id k204si416748oib.181.2019.04.24.05.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 05:00:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.81.48 as permitted sender) client-ip=40.107.81.48;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=Z62YwseQ;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.81.48 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QBWt2g/z3v41SOvbwMr7NQcEzmiLjjfyLkhHpnrA4lc=;
 b=Z62YwseQ+JoFxRhKoSxPMDgH6yR4QK7QGymDPtKCS1hy10z5x9JUgxQWEc+DpNThjdFiK4EvqG4Jqai+L4ZpLIBOwCgQ9m5FnYnDhM763Au8r7knBTIHAzb5JnjJ92xGHtdwmtHdGgU79uvtSUwlQ5tisSa/vzpVIYCdE898Nyk=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6272.namprd05.prod.outlook.com (20.178.240.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.6; Wed, 24 Apr 2019 12:00:16 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::441b:ef64:e316:b294]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::441b:ef64:e316:b294%5]) with mapi id 15.20.1835.010; Wed, 24 Apr 2019
 12:00:16 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>
CC: Pv-drivers <Pv-drivers@vmware.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox
	<willy@infradead.org>, Will Deacon <will.deacon@arm.com>, Peter Zijlstra
	<peterz@infradead.org>, Rik van Riel <riel@surriel.com>, Minchan Kim
	<minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Huang Ying
	<ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 2/9] mm: Add an apply_to_pfn_range interface v2
Thread-Topic: [PATCH 2/9] mm: Add an apply_to_pfn_range interface v2
Thread-Index: AQHU+pVH9stKyQ68Qki9hYNu3940Jg==
Date: Wed, 24 Apr 2019 12:00:16 +0000
Message-ID: <20190424115918.3380-3-thellstrom@vmware.com>
References: <20190424115918.3380-1-thellstrom@vmware.com>
In-Reply-To: <20190424115918.3380-1-thellstrom@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: VI1PR07CA0208.eurprd07.prod.outlook.com
 (2603:10a6:802:3f::32) To MN2PR05MB6141.namprd05.prod.outlook.com
 (2603:10b6:208:c7::25)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.20.1
x-originating-ip: [155.4.205.35]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d6c59e7d-e563-42ee-2880-08d6c8ac69e0
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:MN2PR05MB6272;
x-ms-traffictypediagnostic: MN2PR05MB6272:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB6272F630262B1A37A5FECCDBA13C0@MN2PR05MB6272.namprd05.prod.outlook.com>
x-forefront-prvs: 00179089FD
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(376002)(136003)(396003)(366004)(39860400002)(199004)(189003)(64756008)(66476007)(71200400001)(66446008)(86362001)(66556008)(305945005)(7416002)(14444005)(50226002)(478600001)(256004)(8936002)(81156014)(7736002)(81166006)(2906002)(66066001)(66946007)(71190400001)(8676002)(4326008)(25786009)(1076003)(66574012)(73956011)(186003)(26005)(6116002)(6512007)(486006)(6486002)(53936002)(110136005)(102836004)(6506007)(386003)(316002)(99286004)(54906003)(5660300002)(11346002)(2616005)(68736007)(14454004)(36756003)(6436002)(446003)(476003)(76176011)(3846002)(52116002)(97736004)(2501003);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6272;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 ACOQSDls9H2r/5KxlQOPQlNLEWLOz7Z8MqV4BTjDgFdzNYsJW/GSs11RwjMfoAVdT1iuFwat8cqwCzBtUqWI5ZVpw0QxWrgChkgDMPRIDqs6g7IncvIXrmWdG+DQmxfqXoMWfRwDocsE1G5zioWW/RrxAcnQnsQhxUpS9FTcAmndhcRDiEwdXnHHMRoTt0J/nbsyVt5atKGI9tMTg4soDY7dTmqrvOSVJv3I+33Z84JejwQUBUw+6RG/29sy0HNqPoS/fUfUo9HbUaiHMkTCy4qq1a//0EpUnCRGjj6rApVFU2KL21/nPds4sld/0B7D6TnGVjHxEMLPGa6LicIFJDfCk+rSwb28EMCvVkLYL+2zV9Vorxxt25nnMHYHImhKQeaGplPYEQWu3o8009bYkeaboH4ZBRXGksxKYo7LR+8=
Content-Type: text/plain; charset="utf-8"
Content-ID: <A8189CAD4E23244DB73D19B2E9B6005A@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d6c59e7d-e563-42ee-2880-08d6c8ac69e0
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Apr 2019 12:00:16.1666
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6272
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
DQptbWFwX3NlbSB0byBiZSBoZWxkIHJhdGhlciB0aGFuIG9uIHZtYXMgYmVsb25naW5nIHRvIGEg
cHJvY2VzcyB3aXRoIHRoZQ0KbW1hcF9zZW0gaGVsZC4NCg0KTm90YWJsZSBjaGFuZ2VzIHNpbmNl
IFJGQzoNCkRvbid0IGV4cG9ydCBhcHBseV90b19wZm4gcmFuZ2UuDQoNCkNjOiBBbmRyZXcgTW9y
dG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPg0KQ2M6IE1hdHRoZXcgV2lsY294IDx3aWxs
eUBpbmZyYWRlYWQub3JnPg0KQ2M6IFdpbGwgRGVhY29uIDx3aWxsLmRlYWNvbkBhcm0uY29tPg0K
Q2M6IFBldGVyIFppamxzdHJhIDxwZXRlcnpAaW5mcmFkZWFkLm9yZz4NCkNjOiBSaWsgdmFuIFJp
ZWwgPHJpZWxAc3VycmllbC5jb20+DQpDYzogTWluY2hhbiBLaW0gPG1pbmNoYW5Aa2VybmVsLm9y
Zz4NCkNjOiBNaWNoYWwgSG9ja28gPG1ob2Nrb0BzdXNlLmNvbT4NCkNjOiBIdWFuZyBZaW5nIDx5
aW5nLmh1YW5nQGludGVsLmNvbT4NCkNjOiBTb3VwdGljayBKb2FyZGVyIDxqcmRyLmxpbnV4QGdt
YWlsLmNvbT4NCkNjOiAiSsOpcsO0bWUgR2xpc3NlIiA8amdsaXNzZUByZWRoYXQuY29tPg0KQ2M6
IGxpbnV4LW1tQGt2YWNrLm9yZw0KQ2M6IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCg0K
U2lnbmVkLW9mZi1ieTogVGhvbWFzIEhlbGxzdHJvbSA8dGhlbGxzdHJvbUB2bXdhcmUuY29tPg0K
UmV2aWV3ZWQtYnk6IFJhbHBoIENhbXBiZWxsIDxyY2FtcGJlbGxAbnZpZGlhLmNvbT4gI3YxDQot
LS0NCnYyOiBDbGVhcmx5IHdhcm4gcGVvcGxlIGZyb20gdXNpbmcgYXBwbHlfdG9fcGZuX3Jhbmdl
IGFuZA0KICAgIGFwcGx5X3RvX3BhZ2VfcmFuZ2UgdW5sZXNzIHRoZXkga25vdyB3aGF0IHRoZXkg
YXJlIGRvaW5nLg0KLS0tDQogaW5jbHVkZS9saW51eC9tbS5oIHwgIDEwICsrKysNCiBtbS9tZW1v
cnkuYyAgICAgICAgfCAxMzUgKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKy0tLS0t
LS0tLS0tDQogMiBmaWxlcyBjaGFuZ2VkLCAxMTMgaW5zZXJ0aW9ucygrKSwgMzIgZGVsZXRpb25z
KC0pDQoNCmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L21tLmggYi9pbmNsdWRlL2xpbnV4L21t
LmgNCmluZGV4IDgwYmI2NDA4ZmU3My4uYjdkZDRkZGQ2ZWZiIDEwMDY0NA0KLS0tIGEvaW5jbHVk
ZS9saW51eC9tbS5oDQorKysgYi9pbmNsdWRlL2xpbnV4L21tLmgNCkBAIC0yNjMyLDYgKzI2MzIs
MTYgQEAgdHlwZWRlZiBpbnQgKCpwdGVfZm5fdCkocHRlX3QgKnB0ZSwgcGd0YWJsZV90IHRva2Vu
LCB1bnNpZ25lZCBsb25nIGFkZHIsDQogZXh0ZXJuIGludCBhcHBseV90b19wYWdlX3JhbmdlKHN0
cnVjdCBtbV9zdHJ1Y3QgKm1tLCB1bnNpZ25lZCBsb25nIGFkZHJlc3MsDQogCQkJICAgICAgIHVu
c2lnbmVkIGxvbmcgc2l6ZSwgcHRlX2ZuX3QgZm4sIHZvaWQgKmRhdGEpOw0KIA0KK3N0cnVjdCBw
Zm5fcmFuZ2VfYXBwbHk7DQordHlwZWRlZiBpbnQgKCpwdGVyX2ZuX3QpKHB0ZV90ICpwdGUsIHBn
dGFibGVfdCB0b2tlbiwgdW5zaWduZWQgbG9uZyBhZGRyLA0KKwkJCSBzdHJ1Y3QgcGZuX3Jhbmdl
X2FwcGx5ICpjbG9zdXJlKTsNCitzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5IHsNCisJc3RydWN0IG1t
X3N0cnVjdCAqbW07DQorCXB0ZXJfZm5fdCBwdGVmbjsNCisJdW5zaWduZWQgaW50IGFsbG9jOw0K
K307DQorZXh0ZXJuIGludCBhcHBseV90b19wZm5fcmFuZ2Uoc3RydWN0IHBmbl9yYW5nZV9hcHBs
eSAqY2xvc3VyZSwNCisJCQkgICAgICB1bnNpZ25lZCBsb25nIGFkZHJlc3MsIHVuc2lnbmVkIGxv
bmcgc2l6ZSk7DQogDQogI2lmZGVmIENPTkZJR19QQUdFX1BPSVNPTklORw0KIGV4dGVybiBib29s
IHBhZ2VfcG9pc29uaW5nX2VuYWJsZWQodm9pZCk7DQpkaWZmIC0tZ2l0IGEvbW0vbWVtb3J5LmMg
Yi9tbS9tZW1vcnkuYw0KaW5kZXggOTU4MGQ4OTRmOTYzLi4wYTg2ZWU1MjdmZmEgMTAwNjQ0DQot
LS0gYS9tbS9tZW1vcnkuYw0KKysrIGIvbW0vbWVtb3J5LmMNCkBAIC0xOTM4LDE4ICsxOTM4LDE3
IEBAIGludCB2bV9pb21hcF9tZW1vcnkoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHBoeXNf
YWRkcl90IHN0YXJ0LCB1bnNpZ25lZCBsb25nDQogfQ0KIEVYUE9SVF9TWU1CT0wodm1faW9tYXBf
bWVtb3J5KTsNCiANCi1zdGF0aWMgaW50IGFwcGx5X3RvX3B0ZV9yYW5nZShzdHJ1Y3QgbW1fc3Ry
dWN0ICptbSwgcG1kX3QgKnBtZCwNCi0JCQkJICAgICB1bnNpZ25lZCBsb25nIGFkZHIsIHVuc2ln
bmVkIGxvbmcgZW5kLA0KLQkJCQkgICAgIHB0ZV9mbl90IGZuLCB2b2lkICpkYXRhKQ0KK3N0YXRp
YyBpbnQgYXBwbHlfdG9fcHRlX3JhbmdlKHN0cnVjdCBwZm5fcmFuZ2VfYXBwbHkgKmNsb3N1cmUs
IHBtZF90ICpwbWQsDQorCQkJICAgICAgdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25n
IGVuZCkNCiB7DQogCXB0ZV90ICpwdGU7DQogCWludCBlcnI7DQogCXBndGFibGVfdCB0b2tlbjsN
CiAJc3BpbmxvY2tfdCAqdW5pbml0aWFsaXplZF92YXIocHRsKTsNCiANCi0JcHRlID0gKG1tID09
ICZpbml0X21tKSA/DQorCXB0ZSA9IChjbG9zdXJlLT5tbSA9PSAmaW5pdF9tbSkgPw0KIAkJcHRl
X2FsbG9jX2tlcm5lbChwbWQsIGFkZHIpIDoNCi0JCXB0ZV9hbGxvY19tYXBfbG9jayhtbSwgcG1k
LCBhZGRyLCAmcHRsKTsNCisJCXB0ZV9hbGxvY19tYXBfbG9jayhjbG9zdXJlLT5tbSwgcG1kLCBh
ZGRyLCAmcHRsKTsNCiAJaWYgKCFwdGUpDQogCQlyZXR1cm4gLUVOT01FTTsNCiANCkBAIC0xOTYw
LDg2ICsxOTU5LDEwOSBAQCBzdGF0aWMgaW50IGFwcGx5X3RvX3B0ZV9yYW5nZShzdHJ1Y3QgbW1f
c3RydWN0ICptbSwgcG1kX3QgKnBtZCwNCiAJdG9rZW4gPSBwbWRfcGd0YWJsZSgqcG1kKTsNCiAN
CiAJZG8gew0KLQkJZXJyID0gZm4ocHRlKyssIHRva2VuLCBhZGRyLCBkYXRhKTsNCisJCWVyciA9
IGNsb3N1cmUtPnB0ZWZuKHB0ZSsrLCB0b2tlbiwgYWRkciwgY2xvc3VyZSk7DQogCQlpZiAoZXJy
KQ0KIAkJCWJyZWFrOw0KIAl9IHdoaWxlIChhZGRyICs9IFBBR0VfU0laRSwgYWRkciAhPSBlbmQp
Ow0KIA0KIAlhcmNoX2xlYXZlX2xhenlfbW11X21vZGUoKTsNCiANCi0JaWYgKG1tICE9ICZpbml0
X21tKQ0KKwlpZiAoY2xvc3VyZS0+bW0gIT0gJmluaXRfbW0pDQogCQlwdGVfdW5tYXBfdW5sb2Nr
KHB0ZS0xLCBwdGwpOw0KIAlyZXR1cm4gZXJyOw0KIH0NCiANCi1zdGF0aWMgaW50IGFwcGx5X3Rv
X3BtZF9yYW5nZShzdHJ1Y3QgbW1fc3RydWN0ICptbSwgcHVkX3QgKnB1ZCwNCi0JCQkJICAgICB1
bnNpZ25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcgZW5kLA0KLQkJCQkgICAgIHB0ZV9mbl90
IGZuLCB2b2lkICpkYXRhKQ0KK3N0YXRpYyBpbnQgYXBwbHlfdG9fcG1kX3JhbmdlKHN0cnVjdCBw
Zm5fcmFuZ2VfYXBwbHkgKmNsb3N1cmUsIHB1ZF90ICpwdWQsDQorCQkJICAgICAgdW5zaWduZWQg
bG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGVuZCkNCiB7DQogCXBtZF90ICpwbWQ7DQogCXVuc2ln
bmVkIGxvbmcgbmV4dDsNCi0JaW50IGVycjsNCisJaW50IGVyciA9IDA7DQogDQogCUJVR19PTihw
dWRfaHVnZSgqcHVkKSk7DQogDQotCXBtZCA9IHBtZF9hbGxvYyhtbSwgcHVkLCBhZGRyKTsNCisJ
cG1kID0gcG1kX2FsbG9jKGNsb3N1cmUtPm1tLCBwdWQsIGFkZHIpOw0KIAlpZiAoIXBtZCkNCiAJ
CXJldHVybiAtRU5PTUVNOw0KKw0KIAlkbyB7DQogCQluZXh0ID0gcG1kX2FkZHJfZW5kKGFkZHIs
IGVuZCk7DQotCQllcnIgPSBhcHBseV90b19wdGVfcmFuZ2UobW0sIHBtZCwgYWRkciwgbmV4dCwg
Zm4sIGRhdGEpOw0KKwkJaWYgKCFjbG9zdXJlLT5hbGxvYyAmJiBwbWRfbm9uZV9vcl9jbGVhcl9i
YWQocG1kKSkNCisJCQljb250aW51ZTsNCisJCWVyciA9IGFwcGx5X3RvX3B0ZV9yYW5nZShjbG9z
dXJlLCBwbWQsIGFkZHIsIG5leHQpOw0KIAkJaWYgKGVycikNCiAJCQlicmVhazsNCiAJfSB3aGls
ZSAocG1kKyssIGFkZHIgPSBuZXh0LCBhZGRyICE9IGVuZCk7DQogCXJldHVybiBlcnI7DQogfQ0K
IA0KLXN0YXRpYyBpbnQgYXBwbHlfdG9fcHVkX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCBw
NGRfdCAqcDRkLA0KLQkJCQkgICAgIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWduZWQgbG9uZyBl
bmQsDQotCQkJCSAgICAgcHRlX2ZuX3QgZm4sIHZvaWQgKmRhdGEpDQorc3RhdGljIGludCBhcHBs
eV90b19wdWRfcmFuZ2Uoc3RydWN0IHBmbl9yYW5nZV9hcHBseSAqY2xvc3VyZSwgcDRkX3QgKnA0
ZCwNCisJCQkgICAgICB1bnNpZ25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcgZW5kKQ0KIHsN
CiAJcHVkX3QgKnB1ZDsNCiAJdW5zaWduZWQgbG9uZyBuZXh0Ow0KLQlpbnQgZXJyOw0KKwlpbnQg
ZXJyID0gMDsNCiANCi0JcHVkID0gcHVkX2FsbG9jKG1tLCBwNGQsIGFkZHIpOw0KKwlwdWQgPSBw
dWRfYWxsb2MoY2xvc3VyZS0+bW0sIHA0ZCwgYWRkcik7DQogCWlmICghcHVkKQ0KIAkJcmV0dXJu
IC1FTk9NRU07DQorDQogCWRvIHsNCiAJCW5leHQgPSBwdWRfYWRkcl9lbmQoYWRkciwgZW5kKTsN
Ci0JCWVyciA9IGFwcGx5X3RvX3BtZF9yYW5nZShtbSwgcHVkLCBhZGRyLCBuZXh0LCBmbiwgZGF0
YSk7DQorCQlpZiAoIWNsb3N1cmUtPmFsbG9jICYmIHB1ZF9ub25lX29yX2NsZWFyX2JhZChwdWQp
KQ0KKwkJCWNvbnRpbnVlOw0KKwkJZXJyID0gYXBwbHlfdG9fcG1kX3JhbmdlKGNsb3N1cmUsIHB1
ZCwgYWRkciwgbmV4dCk7DQogCQlpZiAoZXJyKQ0KIAkJCWJyZWFrOw0KIAl9IHdoaWxlIChwdWQr
KywgYWRkciA9IG5leHQsIGFkZHIgIT0gZW5kKTsNCiAJcmV0dXJuIGVycjsNCiB9DQogDQotc3Rh
dGljIGludCBhcHBseV90b19wNGRfcmFuZ2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHBnZF90ICpw
Z2QsDQotCQkJCSAgICAgdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGVuZCwNCi0J
CQkJICAgICBwdGVfZm5fdCBmbiwgdm9pZCAqZGF0YSkNCitzdGF0aWMgaW50IGFwcGx5X3RvX3A0
ZF9yYW5nZShzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpjbG9zdXJlLCBwZ2RfdCAqcGdkLA0KKwkJ
CSAgICAgIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWduZWQgbG9uZyBlbmQpDQogew0KIAlwNGRf
dCAqcDRkOw0KIAl1bnNpZ25lZCBsb25nIG5leHQ7DQotCWludCBlcnI7DQorCWludCBlcnIgPSAw
Ow0KIA0KLQlwNGQgPSBwNGRfYWxsb2MobW0sIHBnZCwgYWRkcik7DQorCXA0ZCA9IHA0ZF9hbGxv
YyhjbG9zdXJlLT5tbSwgcGdkLCBhZGRyKTsNCiAJaWYgKCFwNGQpDQogCQlyZXR1cm4gLUVOT01F
TTsNCisNCiAJZG8gew0KIAkJbmV4dCA9IHA0ZF9hZGRyX2VuZChhZGRyLCBlbmQpOw0KLQkJZXJy
ID0gYXBwbHlfdG9fcHVkX3JhbmdlKG1tLCBwNGQsIGFkZHIsIG5leHQsIGZuLCBkYXRhKTsNCisJ
CWlmICghY2xvc3VyZS0+YWxsb2MgJiYgcDRkX25vbmVfb3JfY2xlYXJfYmFkKHA0ZCkpDQorCQkJ
Y29udGludWU7DQorCQllcnIgPSBhcHBseV90b19wdWRfcmFuZ2UoY2xvc3VyZSwgcDRkLCBhZGRy
LCBuZXh0KTsNCiAJCWlmIChlcnIpDQogCQkJYnJlYWs7DQogCX0gd2hpbGUgKHA0ZCsrLCBhZGRy
ID0gbmV4dCwgYWRkciAhPSBlbmQpOw0KIAlyZXR1cm4gZXJyOw0KIH0NCiANCi0vKg0KLSAqIFNj
YW4gYSByZWdpb24gb2YgdmlydHVhbCBtZW1vcnksIGZpbGxpbmcgaW4gcGFnZSB0YWJsZXMgYXMg
bmVjZXNzYXJ5DQotICogYW5kIGNhbGxpbmcgYSBwcm92aWRlZCBmdW5jdGlvbiBvbiBlYWNoIGxl
YWYgcGFnZSB0YWJsZS4NCisvKioNCisgKiBhcHBseV90b19wZm5fcmFuZ2UgLSBTY2FuIGEgcmVn
aW9uIG9mIHZpcnR1YWwgbWVtb3J5LCBjYWxsaW5nIGEgcHJvdmlkZWQNCisgKiBmdW5jdGlvbiBv
biBlYWNoIGxlYWYgcGFnZSB0YWJsZSBlbnRyeQ0KKyAqIEBjbG9zdXJlOiBEZXRhaWxzIGFib3V0
IGhvdyB0byBzY2FuIGFuZCB3aGF0IGZ1bmN0aW9uIHRvIGFwcGx5DQorICogQGFkZHI6IFN0YXJ0
IHZpcnR1YWwgYWRkcmVzcw0KKyAqIEBzaXplOiBTaXplIG9mIHRoZSByZWdpb24NCisgKg0KKyAq
IElmIEBjbG9zdXJlLT5hbGxvYyBpcyBzZXQgdG8gMSwgdGhlIGZ1bmN0aW9uIHdpbGwgZmlsbCBp
biB0aGUgcGFnZSB0YWJsZQ0KKyAqIGFzIG5lY2Vzc2FyeS4gT3RoZXJ3aXNlIGl0IHdpbGwgc2tp
cCBub24tcHJlc2VudCBwYXJ0cy4NCisgKiBOb3RlOiBUaGUgY2FsbGVyIG11c3QgZW5zdXJlIHRo
YXQgdGhlIHJhbmdlIGRvZXMgbm90IGNvbnRhaW4gaHVnZSBwYWdlcy4NCisgKiBUaGUgY2FsbGVy
IG11c3QgYWxzbyBhc3N1cmUgdGhhdCB0aGUgcHJvcGVyIG1tdV9ub3RpZmllciBmdW5jdGlvbnMg
YXJlDQorICogY2FsbGVkIGJlZm9yZSBhbmQgYWZ0ZXIgdGhlIGNhbGwgdG8gYXBwbHlfdG9fcGZu
X3JhbmdlLg0KKyAqDQorICogV0FSTklORzogRG8gbm90IHVzZSB0aGlzIGZ1bmN0aW9uIHVubGVz
cyB5b3Uga25vdyBleGFjdGx5IHdoYXQgeW91IGFyZQ0KKyAqIGRvaW5nLiBJdCBpcyBsYWNraW5n
IHN1cHBvcnQgZm9yIGh1Z2UgcGFnZXMgYW5kIHRyYW5zcGFyZW50IGh1Z2UgcGFnZXMuDQorICoN
CisgKiBSZXR1cm46IFplcm8gb24gc3VjY2Vzcy4gSWYgdGhlIHByb3ZpZGVkIGZ1bmN0aW9uIHJl
dHVybnMgYSBub24temVybyBzdGF0dXMsDQorICogdGhlIHBhZ2UgdGFibGUgd2FsayB3aWxsIHRl
cm1pbmF0ZSBhbmQgdGhhdCBzdGF0dXMgd2lsbCBiZSByZXR1cm5lZC4NCisgKiBJZiBAY2xvc3Vy
ZS0+YWxsb2MgaXMgc2V0IHRvIDEsIHRoZW4gdGhpcyBmdW5jdGlvbiBtYXkgYWxzbyByZXR1cm4g
bWVtb3J5DQorICogYWxsb2NhdGlvbiBlcnJvcnMgYXJpc2luZyBmcm9tIGFsbG9jYXRpbmcgcGFn
ZSB0YWJsZSBtZW1vcnkuDQogICovDQotaW50IGFwcGx5X3RvX3BhZ2VfcmFuZ2Uoc3RydWN0IG1t
X3N0cnVjdCAqbW0sIHVuc2lnbmVkIGxvbmcgYWRkciwNCi0JCQl1bnNpZ25lZCBsb25nIHNpemUs
IHB0ZV9mbl90IGZuLCB2b2lkICpkYXRhKQ0KK2ludCBhcHBseV90b19wZm5fcmFuZ2Uoc3RydWN0
IHBmbl9yYW5nZV9hcHBseSAqY2xvc3VyZSwNCisJCSAgICAgICB1bnNpZ25lZCBsb25nIGFkZHIs
IHVuc2lnbmVkIGxvbmcgc2l6ZSkNCiB7DQogCXBnZF90ICpwZ2Q7DQogCXVuc2lnbmVkIGxvbmcg
bmV4dDsNCkBAIC0yMDQ5LDE2ICsyMDcxLDY1IEBAIGludCBhcHBseV90b19wYWdlX3JhbmdlKHN0
cnVjdCBtbV9zdHJ1Y3QgKm1tLCB1bnNpZ25lZCBsb25nIGFkZHIsDQogCWlmIChXQVJOX09OKGFk
ZHIgPj0gZW5kKSkNCiAJCXJldHVybiAtRUlOVkFMOw0KIA0KLQlwZ2QgPSBwZ2Rfb2Zmc2V0KG1t
LCBhZGRyKTsNCisJcGdkID0gcGdkX29mZnNldChjbG9zdXJlLT5tbSwgYWRkcik7DQogCWRvIHsN
CiAJCW5leHQgPSBwZ2RfYWRkcl9lbmQoYWRkciwgZW5kKTsNCi0JCWVyciA9IGFwcGx5X3RvX3A0
ZF9yYW5nZShtbSwgcGdkLCBhZGRyLCBuZXh0LCBmbiwgZGF0YSk7DQorCQlpZiAoIWNsb3N1cmUt
PmFsbG9jICYmIHBnZF9ub25lX29yX2NsZWFyX2JhZChwZ2QpKQ0KKwkJCWNvbnRpbnVlOw0KKwkJ
ZXJyID0gYXBwbHlfdG9fcDRkX3JhbmdlKGNsb3N1cmUsIHBnZCwgYWRkciwgbmV4dCk7DQogCQlp
ZiAoZXJyKQ0KIAkJCWJyZWFrOw0KIAl9IHdoaWxlIChwZ2QrKywgYWRkciA9IG5leHQsIGFkZHIg
IT0gZW5kKTsNCiANCiAJcmV0dXJuIGVycjsNCiB9DQorDQorLyoqDQorICogc3RydWN0IHBhZ2Vf
cmFuZ2VfYXBwbHkgLSBDbG9zdXJlIHN0cnVjdHVyZSBmb3IgYXBwbHlfdG9fcGFnZV9yYW5nZSgp
DQorICogQHB0ZXI6IFRoZSBiYXNlIGNsb3N1cmUgc3RydWN0dXJlIHdlIGRlcml2ZSBmcm9tDQor
ICogQGZuOiBUaGUgbGVhZiBwdGUgZnVuY3Rpb24gdG8gY2FsbA0KKyAqIEBkYXRhOiBUaGUgbGVh
ZiBwdGUgZnVuY3Rpb24gY2xvc3VyZQ0KKyAqLw0KK3N0cnVjdCBwYWdlX3JhbmdlX2FwcGx5IHsN
CisJc3RydWN0IHBmbl9yYW5nZV9hcHBseSBwdGVyOw0KKwlwdGVfZm5fdCBmbjsNCisJdm9pZCAq
ZGF0YTsNCit9Ow0KKw0KKy8qDQorICogQ2FsbGJhY2sgd3JhcHBlciB0byBlbmFibGUgdXNlIG9m
IGFwcGx5X3RvX3Bmbl9yYW5nZSBmb3INCisgKiB0aGUgYXBwbHlfdG9fcGFnZV9yYW5nZSBpbnRl
cmZhY2UNCisgKi8NCitzdGF0aWMgaW50IGFwcGx5X3RvX3BhZ2VfcmFuZ2Vfd3JhcHBlcihwdGVf
dCAqcHRlLCBwZ3RhYmxlX3QgdG9rZW4sDQorCQkJCSAgICAgICB1bnNpZ25lZCBsb25nIGFkZHIs
DQorCQkJCSAgICAgICBzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpwdGVyKQ0KK3sNCisJc3RydWN0
IHBhZ2VfcmFuZ2VfYXBwbHkgKnByYSA9DQorCQljb250YWluZXJfb2YocHRlciwgdHlwZW9mKCpw
cmEpLCBwdGVyKTsNCisNCisJcmV0dXJuIHByYS0+Zm4ocHRlLCB0b2tlbiwgYWRkciwgcHJhLT5k
YXRhKTsNCit9DQorDQorLyoNCisgKiBTY2FuIGEgcmVnaW9uIG9mIHZpcnR1YWwgbWVtb3J5LCBm
aWxsaW5nIGluIHBhZ2UgdGFibGVzIGFzIG5lY2Vzc2FyeQ0KKyAqIGFuZCBjYWxsaW5nIGEgcHJv
dmlkZWQgZnVuY3Rpb24gb24gZWFjaCBsZWFmIHBhZ2UgdGFibGUuDQorICoNCisgKiBXQVJOSU5H
OiBEbyBub3QgdXNlIHRoaXMgZnVuY3Rpb24gdW5sZXNzIHlvdSBrbm93IGV4YWN0bHkgd2hhdCB5
b3UgYXJlDQorICogZG9pbmcuIEl0IGlzIGxhY2tpbmcgc3VwcG9ydCBmb3IgaHVnZSBwYWdlcyBh
bmQgdHJhbnNwYXJlbnQgaHVnZSBwYWdlcy4NCisgKi8NCitpbnQgYXBwbHlfdG9fcGFnZV9yYW5n
ZShzdHJ1Y3QgbW1fc3RydWN0ICptbSwgdW5zaWduZWQgbG9uZyBhZGRyLA0KKwkJCXVuc2lnbmVk
IGxvbmcgc2l6ZSwgcHRlX2ZuX3QgZm4sIHZvaWQgKmRhdGEpDQorew0KKwlzdHJ1Y3QgcGFnZV9y
YW5nZV9hcHBseSBwcmEgPSB7DQorCQkucHRlciA9IHsubW0gPSBtbSwNCisJCQkgLmFsbG9jID0g
MSwNCisJCQkgLnB0ZWZuID0gYXBwbHlfdG9fcGFnZV9yYW5nZV93cmFwcGVyIH0sDQorCQkuZm4g
PSBmbiwNCisJCS5kYXRhID0gZGF0YQ0KKwl9Ow0KKw0KKwlyZXR1cm4gYXBwbHlfdG9fcGZuX3Jh
bmdlKCZwcmEucHRlciwgYWRkciwgc2l6ZSk7DQorfQ0KIEVYUE9SVF9TWU1CT0xfR1BMKGFwcGx5
X3RvX3BhZ2VfcmFuZ2UpOw0KIA0KIC8qDQotLSANCjIuMjAuMQ0KDQo=

