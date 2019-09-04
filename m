Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C7EAC3A59E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 04:58:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A727722CF7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 04:58:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="iw0i47tr";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="z3fwkj1L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A727722CF7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F9456B0003; Wed,  4 Sep 2019 00:58:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 482866B0006; Wed,  4 Sep 2019 00:58:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FBFE6B0007; Wed,  4 Sep 2019 00:58:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0184.hostedemail.com [216.40.44.184])
	by kanga.kvack.org (Postfix) with ESMTP id F29146B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 00:58:06 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4AAFD824CA3A
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 04:58:06 +0000 (UTC)
X-FDA: 75896031372.23.heart87_c43699f58748
X-HE-Tag: heart87_c43699f58748
X-Filterd-Recvd-Size: 15128
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80043.outbound.protection.outlook.com [40.107.8.43])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 04:58:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qdpowkyk/cja+ABcow/f7mjzVLg0CNtikCWDBCr+yOw=;
 b=iw0i47trdN0t4laO0kYR9IWxz8GKUtPhsIr7zsMDdT1oNho3k8g2JJyEeKEs9rUWnFTui1bgBKE/qdXF9ecgdVIkVQnIb19kJ7vSJvktMLnAkztZQb7MXA6z/URsxeaLwn+3iejaxmHYZIEM61a1HuXzOW03bBcHed5+svIAFpw=
Received: from VI1PR08CA0213.eurprd08.prod.outlook.com (2603:10a6:802:15::22)
 by DB8PR08MB4171.eurprd08.prod.outlook.com (2603:10a6:10:a4::13) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2241.14; Wed, 4 Sep
 2019 04:57:59 +0000
Received: from DB5EUR03FT015.eop-EUR03.prod.protection.outlook.com
 (2a01:111:f400:7e0a::206) by VI1PR08CA0213.outlook.office365.com
 (2603:10a6:802:15::22) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.2220.20 via Frontend
 Transport; Wed, 4 Sep 2019 04:57:58 +0000
Authentication-Results: spf=temperror (sender IP is 63.35.35.123)
 smtp.mailfrom=arm.com; kvack.org; dkim=pass (signature was verified)
 header.d=armh.onmicrosoft.com;kvack.org; dmarc=temperror action=none
 header.from=arm.com;
Received-SPF: TempError (protection.outlook.com: error in processing during
 lookup of arm.com: DNS Timeout)
Received: from 64aa7808-outbound-1.mta.getcheckrecipient.com (63.35.35.123) by
 DB5EUR03FT015.mail.protection.outlook.com (10.152.20.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.20.2241.14 via Frontend Transport; Wed, 4 Sep 2019 04:57:57 +0000
Received: ("Tessian outbound aa6cb5c8f945:v27"); Wed, 04 Sep 2019 04:57:48 +0000
X-CR-MTA-TID: 64aa7808
Received: from a2d840627751.2 (ip-172-16-0-2.eu-west-1.compute.internal [104.47.12.52])
	by 64aa7808-outbound-1.mta.getcheckrecipient.com id 0725EAD5-9224-4444-B8BF-4EC8E87FFAE8.1;
	Wed, 04 Sep 2019 04:57:43 +0000
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-db3eur04lp2052.outbound.protection.outlook.com [104.47.12.52])
    by 64aa7808-outbound-1.mta.getcheckrecipient.com with ESMTPS id a2d840627751.2
    (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384);
    Wed, 04 Sep 2019 04:57:43 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=dV/D9MgptZYB0+Itajt5ZhAePFkm8esmNO3QUmfUtEmugXNgrdlverAYOx4+/ko7gViZqTPxUw4W+sRe2ZMLTlFBc18PDPb37nwDwNayyZpxp1h0xfgGLwhKLxOoKnaO7oO3hvm7nUL67Um+lFhXsgYCt7/vlXfciWfmQYIjrosVzEll1wVPXUJahULUaftEV1gFnmDN9y0h4F/53EPwKaStnMqheh2SOMtc38JfL5FEO4BAgW8SrRDmPMZlzSHj+ton+3uWFxORbzoeXo5/ByyJ1vvXl5s1gg766xiMJ1FDlEkZG9V/nkSD3k3hTmTEcpEJ2Ou/5KsnMiQew3P2rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=m8p7GsmgXo8JlYmDqgb9OofmIpgC1iuhI9AD5kXPK5M=;
 b=mkODFhAEBTQMsEyinAZf3U7dXy5U1EjVkhUhWtFO6LaZ3eLU57wGz+xUlRfjTdQie9AkTa54tE+UStTfFt13I0U1BVJneXGKfy+4SugPjUz+j7VLONmYIaBzm9UHxzalFSi6Yogn9LGa9h949z0aFYLCn3SOz/x/Ytt2p+3ZZ5V3EHjs0LkgefIgG4E/Vb1GGjA34Ja5lSnbsBKlMeA+82qkh/WSZ+sjTyhY/EedA92ZkAEBreRjJ8vbkr74Isi9BHHXbKrnYqUUYCZW2xMUV9aVfcLHZ6xD3BrJM42W2irrPr5b7CRA9WhVTNVckS+YbXBZ3bIJ/C0ggpyWxaAjGQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=arm.com; dmarc=pass action=none header.from=arm.com; dkim=pass
 header.d=arm.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=m8p7GsmgXo8JlYmDqgb9OofmIpgC1iuhI9AD5kXPK5M=;
 b=z3fwkj1L0Be+J8uQXfL/SxIpRRwj4+DSg0YTju8lQuc6DUGmck1JpWsfeb5pnxS9Kg6AP/+847QsU258sobv3JmDbNT+rI7HKZXa43P9gQ5NBMNuWEs04Ue4KqOx5R0f8NXsDwXJRoU72ChElqQN6mEfnN3QLrF9MeBsuzkVUSo=
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com (52.134.110.24) by
 DB7PR08MB4217.eurprd08.prod.outlook.com (20.178.47.91) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2220.20; Wed, 4 Sep 2019 04:57:42 +0000
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734]) by DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734%3]) with mapi id 15.20.2220.022; Wed, 4 Sep 2019
 04:57:42 +0000
From: "Justin He (Arm Technology China)" <Justin.He@arm.com>
To: Anshuman Khandual <Anshuman.Khandual@arm.com>, Andrew Morton
	<akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ralph Campbell
	<rcampbell@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>, Peter Zijlstra
	<peterz@infradead.org>, Dave Airlie <airlied@redhat.com>, Aneesh Kumar K.V
	<aneesh.kumar@linux.ibm.com>, Thomas Hellstrom <thellstrom@vmware.com>,
	Souptick Joarder <jrdr.linux@gmail.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
Thread-Topic: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
Thread-Index: AQHVYrxRC4qr3uPmLUaMEJjscnv5A6ca2YiAgAAV/4CAAAK4AA==
Date: Wed, 4 Sep 2019 04:57:42 +0000
Message-ID:
 <DB7PR08MB3082E820B4871F1D1552BF34F7B80@DB7PR08MB3082.eurprd08.prod.outlook.com>
References: <20190904005831.153934-1-justin.he@arm.com>
 <fd22d787-3240-fe42-3ca3-9e8a98f86fce@arm.com>
 <961889b3-ef08-2ee9-e3a1-6aba003f47c1@arm.com>
In-Reply-To: <961889b3-ef08-2ee9-e3a1-6aba003f47c1@arm.com>
Accept-Language: en-US, zh-CN
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-ts-tracking-id: 4afff2e0-e8f6-4070-a7d6-c80a954b6b92.1
x-checkrecipientchecked: true
Authentication-Results-Original: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
x-originating-ip: [113.29.88.7]
x-ms-publictraffictype: Email
X-MS-Office365-Filtering-Correlation-Id: 9e87d671-7f16-47ec-f9db-08d730f4746a
X-MS-Office365-Filtering-HT: Tenant
X-Microsoft-Antispam-Untrusted:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600166)(711020)(4605104)(1401327)(4618075)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DB7PR08MB4217;
X-MS-TrafficTypeDiagnostic: DB7PR08MB4217:|DB7PR08MB4217:|DB8PR08MB4171:
x-ms-exchange-transport-forked: True
X-Microsoft-Antispam-PRVS:
	<DB8PR08MB41713335EFDAB353CD8821D1F7B80@DB8PR08MB4171.eurprd08.prod.outlook.com>
x-checkrecipientrouted: true
x-ms-oob-tlc-oobclassifiers: OLM:9508;OLM:9508;
x-forefront-prvs: 0150F3F97D
X-Forefront-Antispam-Report-Untrusted:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(376002)(39860400002)(396003)(136003)(366004)(51914003)(13464003)(199004)(189003)(229853002)(26005)(8936002)(76116006)(66946007)(99286004)(6436002)(66446008)(110136005)(76176011)(74316002)(8676002)(316002)(53936002)(6246003)(66476007)(66556008)(64756008)(3846002)(81156014)(81166006)(52536014)(6116002)(5660300002)(186003)(25786009)(66574012)(102836004)(486006)(2201001)(71190400001)(33656002)(86362001)(478600001)(7416002)(14454004)(2501003)(446003)(66066001)(53546011)(14444005)(6506007)(55016002)(2906002)(7736002)(55236004)(256004)(476003)(11346002)(7696005)(305945005)(9686003)(71200400001)(921003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR08MB4217;H:DB7PR08MB3082.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info-Original:
 9pFViu0iyO3P/VPGNVdNlYfFedAhFuU51unuaoKiOX9NNv/DEcwZuv3L3wI10YAI5evMEuGAoei7GrmGm7PyA/6XhBo1W5WJAc0PGWEgAYXBw3AIPIc2EnlD2b1LglUvEHLZYoIvK3Jjxjr2Gm9wK3ASIMcZlSyb/4bGFg7M0ReLDoxk6puisxVzSLaG1Jt5PfaTLbhhohXajHeAL0KrKvY9TJO9DXC9JQZYKGxIMXCdwICB1FpG7wTYWsetLViUTUo8VxTsRAULJaa2st5r7MHZVDG0WQ/Vc3kz3B1jRTmQHVtz18p0cjVYNeeNsStGv3v+zqkmGvl25W/JbeHxTFB2gXf3hKtZpZqqmWVzenxQUkV4kTxaSORPpFf/yvmMJ1QgJSwm4PAk6elO1bwhs7JsNGWW5aiFMrKBpzMzTN4=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR08MB4217
Original-Authentication-Results: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 DB5EUR03FT015.eop-EUR03.prod.protection.outlook.com
X-Forefront-Antispam-Report:
	CIP:63.35.35.123;IPV:CAL;SCL:-1;CTRY:IE;EFV:NLI;SFV:NSPM;SFS:(10009020)(4636009)(396003)(376002)(346002)(39860400002)(136003)(2980300002)(13464003)(51914003)(40434004)(189003)(199004)(52536014)(22756006)(476003)(6246003)(126002)(486006)(25786009)(14444005)(5024004)(14454004)(8676002)(7736002)(305945005)(9686003)(74316002)(55016002)(99286004)(336012)(436003)(63370400001)(63350400001)(2486003)(23676004)(229853002)(446003)(11346002)(70586007)(70206006)(33656002)(26005)(6506007)(7696005)(186003)(50466002)(47776003)(76130400001)(2906002)(66066001)(2201001)(66574012)(5660300002)(2501003)(8936002)(86362001)(102836004)(478600001)(110136005)(76176011)(53546011)(6116002)(81156014)(356004)(3846002)(316002)(26826003)(81166006)(921003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:DB8PR08MB4171;H:64aa7808-outbound-1.mta.getcheckrecipient.com;FPR:;SPF:TempError;LANG:en;PTR:ec2-63-35-35-123.eu-west-1.compute.amazonaws.com;MX:1;A:1;
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	2f8ab4ca-1f41-4671-5d7c-08d730f46b14
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(710020)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DB8PR08MB4171;
X-Forefront-PRVS: 0150F3F97D
X-Microsoft-Antispam-Message-Info:
	mT710IZVrCxibCjKwv0EJz41Up63a6RjudPx4nvLgD2hXny/BbaKttXcF2TLAY+vuLPjPpOXtNIkjXYE9tfvLrBH+T+YPBX3kNTexrYZrISnsOej1gJPLEtr9LZWewVq/QCx7k72zq9d3VqGWRAo/3MqVDW9ihNr/cioTC9AnkLsJlOFry8JmdvnGU0ISXBvfoVuYmG+4AToD4bk5k2qSABo83PsO1SYGyWPqkBxuAa+3OA8tv3648rBQzd9WJmOyDVHaixqRmLrSdTCV6eIApKA9at0RkrqACNb4ar8r73C2WrZYknOgT4SDcmOreaSUO65eKzAkMo9BiPwFTyYtJNCYNoyx2A9ORF1IS9zI7z8k+fz0wgwzMc6W4RG2o9eeOIaTWvdWBycPrv3u+tT3KM34P6STaRNTY3M/gHSoaY=
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 04 Sep 2019 04:57:57.8745
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 9e87d671-7f16-47ec-f9db-08d730f4746a
X-MS-Exchange-CrossTenant-Id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=f34e5979-57d9-4aaa-ad4d-b122a662184d;Ip=[63.35.35.123];Helo=[64aa7808-outbound-1.mta.getcheckrecipient.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB8PR08MB4171
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgQW5zaHVtYW4sIHRoYW5rcyBmb3IgdGhlIGNvbW1lbnRzLCBzZWUgYmVsb3cgcGxlYXNlDQoN
Cj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQW5zaHVtYW4gS2hhbmR1YWwg
PGFuc2h1bWFuLmtoYW5kdWFsQGFybS5jb20+DQo+IFNlbnQ6IDIwMTnlubQ55pyINOaXpSAxMjoz
OA0KPiBUbzogSnVzdGluIEhlIChBcm0gVGVjaG5vbG9neSBDaGluYSkgPEp1c3Rpbi5IZUBhcm0u
Y29tPjsgQW5kcmV3DQo+IE1vcnRvbiA8YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz47IE1hdHRo
ZXcgV2lsY294DQo+IDx3aWxseUBpbmZyYWRlYWQub3JnPjsgSsOpcsO0bWUgR2xpc3NlIDxqZ2xp
c3NlQHJlZGhhdC5jb20+OyBSYWxwaA0KPiBDYW1wYmVsbCA8cmNhbXBiZWxsQG52aWRpYS5jb20+
OyBKYXNvbiBHdW50aG9ycGUgPGpnZ0B6aWVwZS5jYT47DQo+IFBldGVyIFppamxzdHJhIDxwZXRl
cnpAaW5mcmFkZWFkLm9yZz47IERhdmUgQWlybGllIDxhaXJsaWVkQHJlZGhhdC5jb20+Ow0KPiBB
bmVlc2ggS3VtYXIgSy5WIDxhbmVlc2gua3VtYXJAbGludXguaWJtLmNvbT47IFRob21hcyBIZWxs
c3Ryb20NCj4gPHRoZWxsc3Ryb21Adm13YXJlLmNvbT47IFNvdXB0aWNrIEpvYXJkZXIgPGpyZHIu
bGludXhAZ21haWwuY29tPjsNCj4gbGludXgtbW1Aa3ZhY2sub3JnOyBsaW51eC1rZXJuZWxAdmdl
ci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0hdIG1tOiBmaXggZG91YmxlIHBhZ2Ug
ZmF1bHQgb24gYXJtNjQgaWYgUFRFX0FGIGlzDQo+IGNsZWFyZWQNCj4NCj4NCj4NCj4gT24gMDkv
MDQvMjAxOSAwODo0OSBBTSwgQW5zaHVtYW4gS2hhbmR1YWwgd3JvdGU6DQo+ID4gICAgICAgICAg
ICAgLyoNCj4gPiAgICAgICAgICAgICAgKiBUaGlzIHJlYWxseSBzaG91bGRuJ3QgZmFpbCwgYmVj
YXVzZSB0aGUgcGFnZSBpcyB0aGVyZQ0KPiA+ICAgICAgICAgICAgICAqIGluIHRoZSBwYWdlIHRh
Ymxlcy4gQnV0IGl0IG1pZ2h0IGp1c3QgYmUgdW5yZWFkYWJsZSwNCj4gPiAgICAgICAgICAgICAg
KiBpbiB3aGljaCBjYXNlIHdlIGp1c3QgZ2l2ZSB1cCBhbmQgZmlsbCB0aGUgcmVzdWx0IHdpdGgN
Cj4gPiAtICAgICAgICAgICAgKiB6ZXJvZXMuDQo+ID4gKyAgICAgICAgICAgICogemVyb2VzLiBJ
ZiBQVEVfQUYgaXMgY2xlYXJlZCBvbiBhcm02NCwgaXQgbWlnaHQNCj4gPiArICAgICAgICAgICAg
KiBjYXVzZSBkb3VibGUgcGFnZSBmYXVsdCBoZXJlLiBzbyBtYWtlcyBwdGUgeW91bmcgaGVyZQ0K
PiA+ICAgICAgICAgICAgICAqLw0KPiA+ICsgICAgICAgICAgIGlmICghcHRlX3lvdW5nKHZtZi0+
b3JpZ19wdGUpKSB7DQo+ID4gKyAgICAgICAgICAgICAgICAgICBlbnRyeSA9IHB0ZV9ta3lvdW5n
KHZtZi0+b3JpZ19wdGUpOw0KPiA+ICsgICAgICAgICAgICAgICAgICAgaWYgKHB0ZXBfc2V0X2Fj
Y2Vzc19mbGFncyh2bWYtPnZtYSwgdm1mLT5hZGRyZXNzLA0KPiA+ICsgICAgICAgICAgICAgICAg
ICAgICAgICAgICB2bWYtPnB0ZSwgZW50cnksIHZtZi0+ZmxhZ3MgJg0KPiBGQVVMVF9GTEFHX1dS
SVRFKSkNCj4gPiArICAgICAgICAgICAgICAgICAgICAgICAgICAgdXBkYXRlX21tdV9jYWNoZSh2
bWYtPnZtYSwgdm1mLQ0KPiA+YWRkcmVzcywNCj4gPiArICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgIHZtZi0+cHRlKTsNCj4gPiArICAgICAgICAgICB9DQo+DQo+IFRo
aXMgbG9va3MgY29ycmVjdCB3aGVyZSBpdCB1cGRhdGVzIHRoZSBwdGUgZW50cnkgd2l0aCBQVEVf
QUYgd2hpY2gNCj4gd2lsbCBwcmV2ZW50IGEgc3Vic2VxdWVudCBwYWdlIGZhdWx0LiBCdXQgSSB0
aGluayB3aGF0IHdlIHJlYWxseSBuZWVkDQo+IGhlcmUgaXMgdG8gbWFrZSBzdXJlICd1YWRkcicg
aXMgbWFwcGVkIGNvcnJlY3RseSBhdCB2bWEtPnB0ZS4gUHJvYmFibHkNCj4gYSBnZW5lcmljIGZ1
bmN0aW9uIGFyY2hfbWFwX3B0ZSgpIHdoZW4gZGVmaW5lZCBmb3IgYXJtNjQgc2hvdWxkIGNoZWNr
DQo+IENQVSB2ZXJzaW9uIGFuZCBlbnN1cmUgY29udGludWFuY2Ugb2YgUFRFX0FGIGlmIHJlcXVp
cmVkLiBUaGUgY29tbWVudA0KPiBhYm92ZSBhbHNvIG5lZWQgdG8gYmUgdXBkYXRlZCBzYXlpbmcg
bm90IG9ubHkgdGhlIHBhZ2Ugc2hvdWxkIGJlIHRoZXJlDQo+IGluIHRoZSBwYWdlIHRhYmxlLCBp
dCBuZWVkcyB0byBtYXBwZWQgYXBwcm9wcmlhdGVseSBhcyB3ZWxsLg0KDQpJIGFncmVlIHRoYXQg
YSBnZW5lcmljIGludGVyZmFjZSBoZXJlIGlzIG5lZWRlZCBidXQgbm90IHRoZSBhcmNoX21hcF9w
dGUoKS4NCkluIHRoaXMgY2FzZSwgSSB0aG91Z2h0IGFsbCB0aGUgcGdkL3B1ZC9wbWQvcHRlIGhh
ZCBiZWVuIHNldCBjb3JyZWN0bHkgZXhjZXB0DQpmb3IgdGhlIFBURV9BRiBiaXQuDQpIb3cgYWJv
dXQgYXJjaF9od19hY2Nlc3NfZmxhZygpPw0KSWYgbm9uLWFybTY0LCBhcmNoX2h3X2FjY2Vzc19m
bGFnKCkgPT0gdHJ1ZQ0KSWYgYXJtNjQgd2l0aCBoYXJkd2FyZS1tYW5hZ2VkIGFjY2VzcyBmbGFn
IHN1cHBvcnRlZCwgPT0gdHJ1ZQ0KZWxzZSA9PSBmYWxzZT8NCg0KDQotLQ0KQ2hlZXJzLA0KSnVz
dGluIChKaWEgSGUpDQoNCg0KSU1QT1JUQU5UIE5PVElDRTogVGhlIGNvbnRlbnRzIG9mIHRoaXMg
ZW1haWwgYW5kIGFueSBhdHRhY2htZW50cyBhcmUgY29uZmlkZW50aWFsIGFuZCBtYXkgYWxzbyBi
ZSBwcml2aWxlZ2VkLiBJZiB5b3UgYXJlIG5vdCB0aGUgaW50ZW5kZWQgcmVjaXBpZW50LCBwbGVh
c2Ugbm90aWZ5IHRoZSBzZW5kZXIgaW1tZWRpYXRlbHkgYW5kIGRvIG5vdCBkaXNjbG9zZSB0aGUg
Y29udGVudHMgdG8gYW55IG90aGVyIHBlcnNvbiwgdXNlIGl0IGZvciBhbnkgcHVycG9zZSwgb3Ig
c3RvcmUgb3IgY29weSB0aGUgaW5mb3JtYXRpb24gaW4gYW55IG1lZGl1bS4gVGhhbmsgeW91Lg0K

