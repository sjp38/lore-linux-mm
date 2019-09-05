Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 948FDC3A59E
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 01:22:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39CB420820
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 01:22:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="s5dBnise";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="iNrmFm0D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39CB420820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C854F6B0003; Wed,  4 Sep 2019 21:22:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C36576B0005; Wed,  4 Sep 2019 21:22:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFDBC6B0006; Wed,  4 Sep 2019 21:22:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id 80CFC6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 21:22:07 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 2F0E0824CA2F
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 01:22:07 +0000 (UTC)
X-FDA: 75899115894.01.room50_4c721e9c18514
X-HE-Tag: room50_4c721e9c18514
X-Filterd-Recvd-Size: 14861
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60045.outbound.protection.outlook.com [40.107.6.45])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 01:22:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9YKnyHS652Cbb1wvgvDP4vJUmw1jWutV2zghFdbbCMM=;
 b=s5dBniselx3GNxZEtpDd6+mJj9ZwYOHPVlF5ueNp59k4aJywbHzqTOdyDksBSNTQmzGqLqimqVCu7S7l2FErHcOUrkg2O9EfmF40CflXq2+bxMyL0egYsBqfuU+1Iid8WF4KcnpmPZLcrwLdHoYRlbnCzhtSxga45nbIERpM6Ao=
Received: from VI1PR08CA0126.eurprd08.prod.outlook.com (2603:10a6:800:d4::28)
 by HE1PR0802MB2523.eurprd08.prod.outlook.com (2603:10a6:3:e1::12) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2220.19; Thu, 5 Sep
 2019 01:21:59 +0000
Received: from DB5EUR03FT028.eop-EUR03.prod.protection.outlook.com
 (2a01:111:f400:7e0a::203) by VI1PR08CA0126.outlook.office365.com
 (2603:10a6:800:d4::28) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2241.14 via Frontend
 Transport; Thu, 5 Sep 2019 01:21:59 +0000
Authentication-Results: spf=temperror (sender IP is 63.35.35.123)
 smtp.mailfrom=arm.com; kvack.org; dkim=pass (signature was verified)
 header.d=armh.onmicrosoft.com;kvack.org; dmarc=temperror action=none
 header.from=arm.com;
Received-SPF: TempError (protection.outlook.com: error in processing during
 lookup of arm.com: DNS Timeout)
Received: from 64aa7808-outbound-1.mta.getcheckrecipient.com (63.35.35.123) by
 DB5EUR03FT028.mail.protection.outlook.com (10.152.20.99) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2241.14 via Frontend Transport; Thu, 5 Sep 2019 01:21:58 +0000
Received: ("Tessian outbound 802e738ad7e5:v27"); Thu, 05 Sep 2019 01:21:48 +0000
X-CR-MTA-TID: 64aa7808
Received: from 787d53705d9a.2 (ip-172-16-0-2.eu-west-1.compute.internal [104.47.4.55])
	by 64aa7808-outbound-1.mta.getcheckrecipient.com id 148682F1-7933-4E20-B909-7031F2E520A1.1;
	Thu, 05 Sep 2019 01:21:43 +0000
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-am5eur02lp2055.outbound.protection.outlook.com [104.47.4.55])
    by 64aa7808-outbound-1.mta.getcheckrecipient.com with ESMTPS id 787d53705d9a.2
    (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384);
    Thu, 05 Sep 2019 01:21:43 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=NR255acE14+PqmVj6l28MzvmBQDIYif7BIy8Pi/nKFxmiRSAwEjHLB4HHUiyyyi1ilcdB7msTtO03mTU+y5PRdZVbcnMOT8xdkeUihmb21JPWw74PsY9ne0YR2tTB+s1w9suokolcKrL8IWmq7idsqT0lxPwFrloILQcouaaWyeIgGyJv7AGj+U8Aue1YHll0kcrZSsZqVZJZ13dGzyc1CzrRLU/kydfryAo5trC2wJ/Ze5gYzZCK0viQAZUCPVfhav90Q6UwfWdgXjtWJedpUy13TcDqujVMvDruDtLwM4bEPzGilUzil+0VjdmUK0fY9rwLJQw6QlDHwRaRHbmrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Ok6uu42W2hmOANTHZpgDn/Wnk3neufhu2rUm3ULisxw=;
 b=b5SWtFQ7gPp7pEYxWNxHSNeTgUz1vjWHvm7ib1AwncMfKLZDIzchjwv/8f8U9Vre7X3cspjKTSttzPzbVgMyE24zXTuvxobfugeRElzCjdJ1W3Wbq4yUNUnQbDHzo8LMpCSYmxNGhvPrHeN9kjWIdz7HP0V6pVKo2avXF6QcYvz0Dg9ESiSKBY2yFGWA5P7wLw2v+NzE23zSl5yMe5BO6L1RlpLeyXlbZ3htUNR/xgfC8IAXHlxQfsZn1nvi7liXU5N+JkxsMQHXxX0yAvxIwd2rjfzVYq5f4lM+SzzVrd6+WywnAgHPr4FiEstvyokdxBdjbeYunbr89e7RzvQukQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=arm.com; dmarc=pass action=none header.from=arm.com; dkim=pass
 header.d=arm.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Ok6uu42W2hmOANTHZpgDn/Wnk3neufhu2rUm3ULisxw=;
 b=iNrmFm0DjSs4BH++r8jZ3UQNbJxCPg3Ez0AAOtuihakZysYznG1jvaVVO2xoyk3WtYqaXg2xPi0JvXMwhoOSTiwHopzB8sAuwLTW9CsFdt3cWClAth61imdPvhiMySSEfCI9omHhIBAFSvuVyGK3ko7Lff++fUd17evc7GiwH9E=
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com (52.134.110.24) by
 DB7PR08MB4588.eurprd08.prod.outlook.com (20.178.45.91) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2220.19; Thu, 5 Sep 2019 01:21:41 +0000
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734]) by DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734%3]) with mapi id 15.20.2220.022; Thu, 5 Sep 2019
 01:21:41 +0000
From: "Justin He (Arm Technology China)" <Justin.He@arm.com>
To: Catalin Marinas <Catalin.Marinas@arm.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox
	<willy@infradead.org>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>, Peter
 Zijlstra <peterz@infradead.org>, Dave Airlie <airlied@redhat.com>, Aneesh
 Kumar K.V <aneesh.kumar@linux.ibm.com>, Thomas Hellstrom
	<thellstrom@vmware.com>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm
	<linux-mm@kvack.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
Thread-Topic: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
Thread-Index: AQHVYrxRC4qr3uPmLUaMEJjscnv5A6cbiZwAgADBTgA=
Date: Thu, 5 Sep 2019 01:21:40 +0000
Message-ID:
 <DB7PR08MB308282EEE73CD142E0E5B756F7BB0@DB7PR08MB3082.eurprd08.prod.outlook.com>
References: <20190904005831.153934-1-justin.he@arm.com>
 <CAHkRjk7jNeoXz_zg6KmTam-pAzO3ALFARS91w+zZHmZN_9JsTg@mail.gmail.com>
In-Reply-To:
 <CAHkRjk7jNeoXz_zg6KmTam-pAzO3ALFARS91w+zZHmZN_9JsTg@mail.gmail.com>
Accept-Language: en-US, zh-CN
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-ts-tracking-id: edf43c91-9096-4d66-a17c-b6a33ba62f7f.1
x-checkrecipientchecked: true
Authentication-Results-Original: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
x-originating-ip: [113.29.88.7]
x-ms-publictraffictype: Email
X-MS-Office365-Filtering-Correlation-Id: 934f4892-1c2f-4922-16f2-08d7319f7240
X-MS-Office365-Filtering-HT: Tenant
X-Microsoft-Antispam-Untrusted:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DB7PR08MB4588;
X-MS-TrafficTypeDiagnostic: DB7PR08MB4588:|DB7PR08MB4588:|HE1PR0802MB2523:
x-ms-exchange-transport-forked: True
X-Microsoft-Antispam-PRVS:
	<HE1PR0802MB252324B1068EC0316CFEF0DEF7BB0@HE1PR0802MB2523.eurprd08.prod.outlook.com>
x-checkrecipientrouted: true
x-ms-oob-tlc-oobclassifiers: OLM:7219;OLM:7219;
x-forefront-prvs: 015114592F
X-Forefront-Antispam-Report-Untrusted:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(366004)(136003)(39860400002)(346002)(396003)(13464003)(189003)(199004)(26005)(446003)(14454004)(476003)(11346002)(102836004)(53546011)(478600001)(6506007)(66476007)(7736002)(76116006)(7416002)(8936002)(186003)(55236004)(305945005)(8676002)(486006)(71200400001)(52536014)(99286004)(71190400001)(25786009)(54906003)(66574012)(4326008)(55016002)(9686003)(86362001)(6862004)(5660300002)(66446008)(6246003)(6116002)(64756008)(53936002)(6436002)(66946007)(66066001)(256004)(14444005)(2906002)(3846002)(74316002)(81156014)(81166006)(316002)(76176011)(7696005)(66556008)(229853002)(33656002)(6636002);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR08MB4588;H:DB7PR08MB3082.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info-Original:
 MiuqqDxjsUASzUWWFXv0kkxc9zokHsQan+jra/MFV3EE+M4G4Xb/7I9hHb2xcJkWRf27n9R1yy3Qf7T6Yw9Rvmb/gSJVXRHElnopr7L3JvuM3ZvvS9NP9/+akhx8K9FveqZjZDmeoaaJCunDT8RASfNae5LYZ25J/2jGqggNHlKbNpJ/UDItKBG47Em8VyPa7Qef8Yn5nCIR/5vKOIIfcANYP/sW6q5cjaDPUBBLTHOGoLvBWxbqtxLYae/7bEkfN5Y5RHwoTHb6b1OsVHpGqoFg4a5kPHiSWWzthkDaYI9FH/GfKYyhtanxl5R7AUGUA6xzFFlwq9z/6Gfx7cAVZsbfKzVVdHk9HVZ79gVDjnATRiL/H95FgnjlWuXyUDjd51UboAf5DUDz9/+Z75SwuiYO8FKneEZz5cIYRU0Yb8s=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR08MB4588
Original-Authentication-Results: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 DB5EUR03FT028.eop-EUR03.prod.protection.outlook.com
X-Forefront-Antispam-Report:
	CIP:63.35.35.123;IPV:CAL;SCL:-1;CTRY:IE;EFV:NLI;SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(136003)(376002)(346002)(396003)(2980300002)(40434004)(13464003)(199004)(189003)(74316002)(476003)(305945005)(66574012)(70586007)(70206006)(229853002)(26826003)(478600001)(436003)(336012)(126002)(63370400001)(446003)(33656002)(356004)(63350400001)(47776003)(11346002)(66066001)(7696005)(7736002)(6506007)(316002)(186003)(26005)(102836004)(14454004)(50466002)(8936002)(53546011)(99286004)(25786009)(81156014)(81166006)(23676004)(76176011)(55016002)(9686003)(54906003)(486006)(2486003)(6862004)(107886003)(6246003)(4326008)(8676002)(6636002)(76130400001)(14444005)(5024004)(52536014)(2906002)(86362001)(3846002)(22756006)(6116002)(5660300002);DIR:OUT;SFP:1101;SCL:1;SRVR:HE1PR0802MB2523;H:64aa7808-outbound-1.mta.getcheckrecipient.com;FPR:;SPF:TempError;LANG:en;PTR:ec2-63-35-35-123.eu-west-1.compute.amazonaws.com;A:1;MX:1;
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	00179664-1def-483b-8ea2-08d7319f67fd
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(710020)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:HE1PR0802MB2523;
X-Forefront-PRVS: 015114592F
X-Microsoft-Antispam-Message-Info:
	WWvnlcOXF5RDPuWIHn7JaV8kFRZqf3STA+340diosr9aNDk3DdgY3vWdJH4fyXe+JaYX0JSbmaX+mGzxheN8oL9OiR9GKy0wP5s9/DhG3nYmaRWRelmOXZEB02+ACFWXTwi/Fdv3IcdxWHHj/kLWnY59SBK1rS0yV7S37zCFOBaOkPM3r3oHzNxpwz1eDkpN9iajLAfuQm2ne57YgNH5TMmwnemtZK5DSZ8sNtEGAayQz+lAGRX8jn3CrWNTv5brgFZl1J3D4pUH/PrGwoCDHAAQWxz7662MT90MMZVqm2c/HTbZJeaNHwcjHyytq917m9ZOSI7XtpI/8LA4dprVvjBViblUBurLE5oKvwkt+WkyDTdOu2DURDvCmRtKPhE/sgXH3uapDsL5fOHbwswC2qcU2Pofu5VT2wU8uCQ56ag=
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 05 Sep 2019 01:21:58.1877
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 934f4892-1c2f-4922-16f2-08d7319f7240
X-MS-Exchange-CrossTenant-Id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=f34e5979-57d9-4aaa-ad4d-b122a662184d;Ip=[63.35.35.123];Helo=[64aa7808-outbound-1.mta.getcheckrecipient.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: HE1PR0802MB2523
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQ2F0YWxpbiBNYXJpbmFz
IDxjYXRhbGluLm1hcmluYXNAYXJtLmNvbT4NCj4gU2VudDogMjAxOeW5tDnmnIg05pelIDIxOjQ5
DQo+IFRvOiBKdXN0aW4gSGUgKEFybSBUZWNobm9sb2d5IENoaW5hKSA8SnVzdGluLkhlQGFybS5j
b20+DQo+IENjOiBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPjsgTWF0
dGhldyBXaWxjb3gNCj4gPHdpbGx5QGluZnJhZGVhZC5vcmc+OyBKw6lyw7RtZSBHbGlzc2UgPGpn
bGlzc2VAcmVkaGF0LmNvbT47IFJhbHBoDQo+IENhbXBiZWxsIDxyY2FtcGJlbGxAbnZpZGlhLmNv
bT47IEphc29uIEd1bnRob3JwZSA8amdnQHppZXBlLmNhPjsNCj4gUGV0ZXIgWmlqbHN0cmEgPHBl
dGVyekBpbmZyYWRlYWQub3JnPjsgRGF2ZSBBaXJsaWUgPGFpcmxpZWRAcmVkaGF0LmNvbT47DQo+
IEFuZWVzaCBLdW1hciBLLlYgPGFuZWVzaC5rdW1hckBsaW51eC5pYm0uY29tPjsgVGhvbWFzIEhl
bGxzdHJvbQ0KPiA8dGhlbGxzdHJvbUB2bXdhcmUuY29tPjsgU291cHRpY2sgSm9hcmRlciA8anJk
ci5saW51eEBnbWFpbC5jb20+Ow0KPiBsaW51eC1tbSA8bGludXgtbW1Aa3ZhY2sub3JnPjsgTGlu
dXggS2VybmVsIE1haWxpbmcgTGlzdCA8bGludXgtDQo+IGtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc+
DQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0hdIG1tOiBmaXggZG91YmxlIHBhZ2UgZmF1bHQgb24gYXJt
NjQgaWYgUFRFX0FGIGlzDQo+IGNsZWFyZWQNCj4NCj4gT24gV2VkLCA0IFNlcCAyMDE5IGF0IDAx
OjU5LCBKaWEgSGUgPGp1c3Rpbi5oZUBhcm0uY29tPiB3cm90ZToNCj4gPiBAQCAtMjE1MiwyMCAr
MjE1MywzMCBAQCBzdGF0aWMgaW5saW5lIHZvaWQgY293X3VzZXJfcGFnZShzdHJ1Y3QgcGFnZQ0K
PiAqZHN0LCBzdHJ1Y3QgcGFnZSAqc3JjLCB1bnNpZ25lZCBsbw0KPiA+ICAgICAgICAgICovDQo+
ID4gICAgICAgICBpZiAodW5saWtlbHkoIXNyYykpIHsNCj4gPiAgICAgICAgICAgICAgICAgdm9p
ZCAqa2FkZHIgPSBrbWFwX2F0b21pYyhkc3QpOw0KPiA+IC0gICAgICAgICAgICAgICB2b2lkIF9f
dXNlciAqdWFkZHIgPSAodm9pZCBfX3VzZXIgKikodmEgJiBQQUdFX01BU0spOw0KPiA+ICsgICAg
ICAgICAgICAgICB2b2lkIF9fdXNlciAqdWFkZHIgPSAodm9pZCBfX3VzZXIgKikodm1mLT5hZGRy
ZXNzICYNCj4gUEFHRV9NQVNLKTsNCj4gPiArICAgICAgICAgICAgICAgcHRlX3QgZW50cnk7DQo+
ID4NCj4gPiAgICAgICAgICAgICAgICAgLyoNCj4gPiAgICAgICAgICAgICAgICAgICogVGhpcyBy
ZWFsbHkgc2hvdWxkbid0IGZhaWwsIGJlY2F1c2UgdGhlIHBhZ2UgaXMgdGhlcmUNCj4gPiAgICAg
ICAgICAgICAgICAgICogaW4gdGhlIHBhZ2UgdGFibGVzLiBCdXQgaXQgbWlnaHQganVzdCBiZSB1
bnJlYWRhYmxlLA0KPiA+ICAgICAgICAgICAgICAgICAgKiBpbiB3aGljaCBjYXNlIHdlIGp1c3Qg
Z2l2ZSB1cCBhbmQgZmlsbCB0aGUgcmVzdWx0IHdpdGgNCj4gPiAtICAgICAgICAgICAgICAgICog
emVyb2VzLg0KPiA+ICsgICAgICAgICAgICAgICAgKiB6ZXJvZXMuIElmIFBURV9BRiBpcyBjbGVh
cmVkIG9uIGFybTY0LCBpdCBtaWdodA0KPiA+ICsgICAgICAgICAgICAgICAgKiBjYXVzZSBkb3Vi
bGUgcGFnZSBmYXVsdCBoZXJlLiBzbyBtYWtlcyBwdGUgeW91bmcgaGVyZQ0KPiA+ICAgICAgICAg
ICAgICAgICAgKi8NCj4gPiArICAgICAgICAgICAgICAgaWYgKCFwdGVfeW91bmcodm1mLT5vcmln
X3B0ZSkpIHsNCj4gPiArICAgICAgICAgICAgICAgICAgICAgICBlbnRyeSA9IHB0ZV9ta3lvdW5n
KHZtZi0+b3JpZ19wdGUpOw0KPiA+ICsgICAgICAgICAgICAgICAgICAgICAgIGlmIChwdGVwX3Nl
dF9hY2Nlc3NfZmxhZ3Modm1mLT52bWEsIHZtZi0+YWRkcmVzcywNCj4gPiArICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgIHZtZi0+cHRlLCBlbnRyeSwgdm1mLT5mbGFncyAmIEZBVUxUX0ZM
QUdfV1JJVEUpKQ0KPg0KPiBJIHRoaW5rIHlvdSBuZWVkIHRvIHBhc3MgZGlydHkgPSAwIHRvIHB0
ZXBfc2V0X2FjY2Vzc19mbGFncygpIHJhdGhlcg0KPiB0aGFuIHRoZSB2bWYtPmZsYWdzICYgRkFV
TFRfRkxBR19XUklURS4gVGhpcyBpcyBjb3B5aW5nIGZyb20gdGhlIHVzZXINCj4gYWRkcmVzcyBp
bnRvIGEga2VybmVsIG1hcHBpbmcgYW5kIHRoZSBmYXVsdCB5b3Ugd2FudCB0byBwcmV2ZW50IGlz
IGENCj4gcmVhZCBhY2Nlc3Mgb24gdWFkZHIgdmlhIF9fY29weV9mcm9tX3VzZXJfaW5hdG9taWMo
KS4gVGhlIHB0ZSB3aWxsIGJlDQo+IG1hZGUgd3JpdGFibGUgaW4gdGhlIHdwX3BhZ2VfY29weSgp
IGZ1bmN0aW9uLg0KDQpPaywgdGhhbmtzDQoNCi0tDQpDaGVlcnMsDQpKdXN0aW4gKEppYSBIZSkN
Cg0KDQo+DQo+IC0tDQo+IENhdGFsaW4NCklNUE9SVEFOVCBOT1RJQ0U6IFRoZSBjb250ZW50cyBv
ZiB0aGlzIGVtYWlsIGFuZCBhbnkgYXR0YWNobWVudHMgYXJlIGNvbmZpZGVudGlhbCBhbmQgbWF5
IGFsc28gYmUgcHJpdmlsZWdlZC4gSWYgeW91IGFyZSBub3QgdGhlIGludGVuZGVkIHJlY2lwaWVu
dCwgcGxlYXNlIG5vdGlmeSB0aGUgc2VuZGVyIGltbWVkaWF0ZWx5IGFuZCBkbyBub3QgZGlzY2xv
c2UgdGhlIGNvbnRlbnRzIHRvIGFueSBvdGhlciBwZXJzb24sIHVzZSBpdCBmb3IgYW55IHB1cnBv
c2UsIG9yIHN0b3JlIG9yIGNvcHkgdGhlIGluZm9ybWF0aW9uIGluIGFueSBtZWRpdW0uIFRoYW5r
IHlvdS4NCg==

