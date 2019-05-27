Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B15FEC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:53:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D0912070D
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:53:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=elektrobit.onmicrosoft.com header.i=@elektrobit.onmicrosoft.com header.b="q8gjawXy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D0912070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=elektrobit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0C656B026F; Mon, 27 May 2019 03:53:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D95B46B0270; Mon, 27 May 2019 03:53:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C106D6B0271; Mon, 27 May 2019 03:53:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 547666B026F
	for <linux-mm@kvack.org>; Mon, 27 May 2019 03:53:53 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id a21so2695157lff.9
        for <linux-mm@kvack.org>; Mon, 27 May 2019 00:53:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=IrDMXXLOZuqClmZUFX57XNpADLFT9wrLxaBakKxxt2U=;
        b=gjp2/W0CofhLj/yOHQxDpdTrOuT58okJmhqooD2g0BKS9OeCHGhW5kne2CIz/pxtX0
         u78s2inApKD7CbQzRO8uYk581rnpkJ3ukPq1dufg7IvxsXvi9J+d0Y61DbXU3EiDIfSq
         cj7gRLb6PyL790qPa7iZ6/a0Gy8/ZlOXcCT5tLDWzMFs1/Mv30zS43UO+H9c/54nbdXL
         jEEaJa0zYm8RCosoZ1p5IRTNtxvUMmhid6Gcjm/7kMRC3rR79fUZ9G5GWx+xrFdl71T6
         mr2YZnd0k8UgNFzJ8eWE2BR2F0EyRAINThBPEIpJW4etfklIrRi5t8sI9t2HxG0B8NvB
         L/oA==
X-Gm-Message-State: APjAAAXU7icBTbyeAP2lO5szKpH8r4QBSswd8wBHkyyP1g/pUB1Cb+r9
	8Ps0z5EBqIgY2qJdoVcxg95mOyqSEPVMRb1i/r8d+dk/ocADWZejX6SAZlncIbItexoI//qNIGJ
	3y78wVCHJuAcT9uM8b1ESlAprQXfayybtUka6LgTiGX46xzYWRkQF0RizCIbK2nF8Pg==
X-Received: by 2002:a2e:6817:: with SMTP id c23mr38051282lja.145.1558943632772;
        Mon, 27 May 2019 00:53:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9kepuHM/LQV9NmesM9Wi3sNPcpRkw91poP4P/rzYTzIr5ROYfjQGPRF6NtbUg5Nvc5qp7
X-Received: by 2002:a2e:6817:: with SMTP id c23mr38051251lja.145.1558943632004;
        Mon, 27 May 2019 00:53:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558943631; cv=none;
        d=google.com; s=arc-20160816;
        b=I5RKOQo0Islero9d26xxWyIT6ASUqQAq1YiHwbZFvcI/ao7vsb8PcNd3KA+qP+NYGI
         gHCECoZqp8DvEnZPSR0MQfP3BCjgpCo9Lcr2Vj0sI+M/MNopmfN3D0KVZw8wpxLVHFkO
         34TFUaKzqMhiSZtKJXw2hRDfFoU0eBU4bc9ShHzTGtUKBo/yc2nS0Xt8yLLwQliveQqV
         LYnGBL8kZzloQY+ZT5s9OxZYXX3MFJSVg6Ifs83B58t2XglBHGEgos9PcRkcF6jFTvHa
         x/XFTnFAnqpjxXRqiDNzgDl9wqFtvSs2JtfqX8LKoLrcSMm0w3IMryqRpVX4lco767jg
         cI7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=IrDMXXLOZuqClmZUFX57XNpADLFT9wrLxaBakKxxt2U=;
        b=olZkh8df2lF2/zTFGwhv+aDNS3rqUtXbnJnq2XWNJXhFJ+MB1wbIDXRcM0aaZRrn0z
         dPDJuHFlNQSWlxeelt5OQbM7fjIICz7T+Mmu+qAz4FYxiYxUZ5lA3ZiukhlKRtwPXFke
         Vc0SFMHTX27oHgVs0q8tPjxgh5jxQ1bcY9t8Diw+Q6WB3QCYIpM6XgyCUrKCai/KjBlS
         eR2j02tkPe2EwrE+H8JwKp+C3W2AebAIVfOe9d0GH2XPofXlorlwv1iFCpbmygu9Ycpk
         WvRVIj82bbtPF+meiI059bEefjfoaY7TmluVJiXKV34Jnj85CJyTzp4131EaRTN0NQFP
         Q1yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@elektrobit.onmicrosoft.com header.s=selector1-elektrobit-onmicrosoft-com header.b=q8gjawXy;
       spf=pass (google.com: best guess record for domain of prvs=1050031a21=stefan.potyra@elektrobit.com designates 213.95.163.141 as permitted sender) smtp.mailfrom="prvs=1050031a21=stefan.potyra@elektrobit.com"
Received: from smtpgwcipde.elektrobit.com (smtpgwcipde.automotive.elektrobit.com. [213.95.163.141])
        by mx.google.com with ESMTPS id p70si9817479ljp.7.2019.05.27.00.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 May 2019 00:53:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of prvs=1050031a21=stefan.potyra@elektrobit.com designates 213.95.163.141 as permitted sender) client-ip=213.95.163.141;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@elektrobit.onmicrosoft.com header.s=selector1-elektrobit-onmicrosoft-com header.b=q8gjawXy;
       spf=pass (google.com: best guess record for domain of prvs=1050031a21=stefan.potyra@elektrobit.com designates 213.95.163.141 as permitted sender) smtp.mailfrom="prvs=1050031a21=stefan.potyra@elektrobit.com"
Received: from denue6es002.localdomain (denue6es002.automotive.elektrobit.com [213.95.163.135])
	by smtpgwcipde.elektrobit.com  with ESMTP id x4R7rlge000382-x4R7rlgg000382
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=OK);
	Mon, 27 May 2019 09:53:47 +0200
Received: from denue6es002.securemail.local (localhost [127.0.0.1])
	by denue6es002.localdomain (Postfix) with SMTP id 50A3419288;
	Mon, 27 May 2019 09:53:47 +0200 (CEST)
Received: from denue6es011.ebgroup.elektrobit.com (denue6es011.ebgroup.elektrobit.com [10.243.160.101])
	by denue6es002.localdomain (Postfix) with ESMTPS;
	Mon, 27 May 2019 09:53:45 +0200 (CEST)
Received: from denue6es010.ebgroup.elektrobit.com (10.243.160.100) by
 denue6es011.ebgroup.elektrobit.com (10.243.160.101) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 27 May 2019 09:53:45 +0200
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (104.47.41.52) by
 denue6es010.ebgroup.elektrobit.com (10.243.160.100) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id
 15.1.1713.5 via Frontend Transport; Mon, 27 May 2019 09:53:44 +0200
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=elektrobit.onmicrosoft.com; s=selector1-elektrobit-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=IrDMXXLOZuqClmZUFX57XNpADLFT9wrLxaBakKxxt2U=;
 b=q8gjawXy7qgTd7slxXo5q2yG6gdM+23seC4MCsOORZvj8SHXTW+7hOPkhKfzHM6h4orrnl1ivQZZY8/Z/iuQV4mfSqQRnFWqi6/kz4y0GNXzC5h2jp1BZL5/l4YMi+vHLWxCHaOojN6W0nEAJBqbXuf3n9+sbZX2C8tOYTGwyQs=
Received: from DM6PR08MB5195.namprd08.prod.outlook.com (20.176.118.25) by
 DM6PR08MB5977.namprd08.prod.outlook.com (20.179.69.209) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.15; Mon, 27 May 2019 07:53:42 +0000
Received: from DM6PR08MB5195.namprd08.prod.outlook.com
 ([fe80::3165:8bdb:ef18:9e1a]) by DM6PR08MB5195.namprd08.prod.outlook.com
 ([fe80::3165:8bdb:ef18:9e1a%2]) with mapi id 15.20.1922.021; Mon, 27 May 2019
 07:53:42 +0000
From: "Potyra, Stefan" <Stefan.Potyra@elektrobit.com>
To: Michal Hocko <mhocko@kernel.org>,
        Daniel Jordan
	<daniel.m.jordan@oracle.com>
CC: "Potyra, Stefan" <Stefan.Potyra@elektrobit.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        "Jordan, Tobias"
	<Tobias.Jordan@elektrobit.com>,
        "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>,
        "vbabka@suse.cz" <vbabka@suse.cz>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>
Subject: [PATCH v2] mm: mlockall error for flag MCL_ONFAULT
Thread-Topic: [PATCH v2] mm: mlockall error for flag MCL_ONFAULT
Thread-Index: AQHVFGFNv0h5WJVR6EeShGKsboxNMQ==
Date: Mon, 27 May 2019 07:53:42 +0000
Message-ID: <20190527075333.GA6339@er01809n.ebgroup.elektrobit.com>
References: <20190527070415.GA1658@dhcp22.suse.cz>
In-Reply-To: <20190527070415.GA1658@dhcp22.suse.cz>
Accept-Language: de-DE, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: AM6PR0202CA0025.eurprd02.prod.outlook.com
 (2603:10a6:209:15::38) To DM6PR08MB5195.namprd08.prod.outlook.com
 (2603:10b6:5:42::25)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Stefan.Potyra@elektrobit.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [213.95.148.172]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9bef0ffe-d812-49d7-f2f2-08d6e2786fcb
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM6PR08MB5977;
x-ms-traffictypediagnostic: DM6PR08MB5977:
x-microsoft-antispam-prvs: <DM6PR08MB59775BE33D076AE683353458801D0@DM6PR08MB5977.namprd08.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4125;
x-forefront-prvs: 0050CEFE70
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(136003)(396003)(346002)(376002)(39840400004)(366004)(189003)(199004)(1076003)(6436002)(6512007)(25786009)(33656002)(6486002)(14454004)(68736007)(64756008)(66446008)(66556008)(66476007)(72206003)(478600001)(316002)(66946007)(73956011)(52116002)(99286004)(486006)(76176011)(71190400001)(71200400001)(8676002)(8936002)(110136005)(54906003)(11346002)(186003)(446003)(102836004)(386003)(26005)(476003)(6506007)(53936002)(256004)(5660300002)(14444005)(4326008)(86362001)(6116002)(3846002)(305945005)(7736002)(81156014)(81166006)(66066001)(2906002);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR08MB5977;H:DM6PR08MB5195.namprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: elektrobit.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: W8qP1zlKiH58N0Xa05QqiEfqPc7IAZ/IM+5SV7idtNtjnE8qob8gQrxjppB23rBl0XFZvhhrMBCA1CIDEZDJasztMjxJj8Y4WC/i1HcVaFnyDbQ9Et2gCBUTsoN8XEO4Xg7+pw03Cb1+BFyjoUJ2mz0ucGDKRSZAi67pnj3wkiVdS7zmu3R50Cmc0Og5Msj/7Vu1EZ1aNfGOM05enCsuI5SPzP1rttt4WtV3cvH6BR3xUL1UYG6SFc6ITgHq0d6ru086MlyA9u5TCj79LAvFDs2jrJTTe3TS/+YgDml0ECfmJ7SK+wlLlKCSdf5zJ7ptgUSA1q1zwlbUMh0fadqZ6dDw2oDjgBKLoI8tI7XRA45rBZDeG9G0SLwW2q+UhkFdffpR6STYkcV/QPIduyQmmkpvj7rLpETFOqP2sbkSIrM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <45C0C401F4D9434B806A15C5EEE14E5F@namprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 9bef0ffe-d812-49d7-f2f2-08d6e2786fcb
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 May 2019 07:53:42.2251
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: e764c36b-012e-4216-910d-8fd16283182d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Stefan.Potyra@elektrobit.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR08MB5977
X-OriginatorOrg: elektrobit.com
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SWYgbWxvY2thbGwoKSBpcyBjYWxsZWQgd2l0aCBvbmx5IE1DTF9PTkZBVUxUIGFzIGZsYWcsDQpp
dCByZW1vdmVzIGFueSBwcmV2aW91c2x5IGFwcGxpZWQgbG9ja2luZ3MgYW5kIGRvZXMNCm5vdGhp
bmcgZWxzZS4NCg0KVGhpcyBiZWhhdmlvciBpcyBjb3VudGVyLWludHVpdGl2ZSBhbmQgZG9lc24n
dCBtYXRjaCB0aGUNCkxpbnV4IG1hbiBwYWdlLg0KDQogIEZvciBtbG9ja2FsbCgpOg0KDQogIEVJ
TlZBTCBVbmtub3duICBmbGFncyB3ZXJlIHNwZWNpZmllZCBvciBNQ0xfT05GQVVMVCB3YXMgc3Bl
Y2lmaWVkIHdpdGjigJANCiAgICAgICAgIG91dCBlaXRoZXIgTUNMX0ZVVFVSRSBvciBNQ0xfQ1VS
UkVOVC4NCg0KQ29uc2VxdWVudGx5LCByZXR1cm4gdGhlIGVycm9yIEVJTlZBTCwgaWYgb25seSBN
Q0xfT05GQVVMVA0KaXMgcGFzc2VkLiBUaGF0IHdheSwgYXBwbGljYXRpb25zIHdpbGwgYXQgbGVh
c3QgZGV0ZWN0IHRoYXQNCnRoZXkgYXJlIGNhbGxpbmcgbWxvY2thbGwoKSBpbmNvcnJlY3RseS4N
Cg0KRml4ZXM6IGIwZjIwNWMyYTMwOCAoIm1tOiBtbG9jazogYWRkIG1sb2NrIGZsYWdzIHRvIGVu
YWJsZSBWTV9MT0NLT05GQVVMVCB1c2FnZSIpDQpTaWduZWQtb2ZmLWJ5OiBTdGVmYW4gUG90eXJh
IDxTdGVmYW4uUG90eXJhQGVsZWt0cm9iaXQuY29tPg0KUmV2aWV3ZWQtYnk6IERhbmllbCBKb3Jk
YW4gPGRhbmllbC5tLmpvcmRhbkBvcmFjbGUuY29tPg0KQWNrZWQtYnk6IE1pY2hhbCBIb2NrbyA8
bWhvY2tvQHN1c2UuY29tPg0KLS0tDQogbW0vbWxvY2suYyB8IDMgKystDQogMSBmaWxlIGNoYW5n
ZWQsIDIgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQ0KDQpkaWZmIC0tZ2l0IGEvbW0vbWxv
Y2suYyBiL21tL21sb2NrLmMNCmluZGV4IGU0OTJhMTU1YzUxYS4uMDNmMzljYmRkNGM0IDEwMDY0
NA0KLS0tIGEvbW0vbWxvY2suYw0KKysrIGIvbW0vbWxvY2suYw0KQEAgLTc5Nyw3ICs3OTcsOCBA
QCBTWVNDQUxMX0RFRklORTEobWxvY2thbGwsIGludCwgZmxhZ3MpDQogCXVuc2lnbmVkIGxvbmcg
bG9ja19saW1pdDsNCiAJaW50IHJldDsNCiANCi0JaWYgKCFmbGFncyB8fCAoZmxhZ3MgJiB+KE1D
TF9DVVJSRU5UIHwgTUNMX0ZVVFVSRSB8IE1DTF9PTkZBVUxUKSkpDQorCWlmICghZmxhZ3MgfHwg
KGZsYWdzICYgfihNQ0xfQ1VSUkVOVCB8IE1DTF9GVVRVUkUgfCBNQ0xfT05GQVVMVCkpIHx8DQor
CSAgICBmbGFncyA9PSBNQ0xfT05GQVVMVCkNCiAJCXJldHVybiAtRUlOVkFMOw0KIA0KIAlpZiAo
IWNhbl9kb19tbG9jaygpKQ0KLS0gDQoyLjIwLjENCg0K

