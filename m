Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B06DC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:40:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 251512133D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:40:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="URF2uSJY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 251512133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB2F86B000A; Thu, 13 Jun 2019 16:40:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C64E88E0002; Thu, 13 Jun 2019 16:40:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2D256B000D; Thu, 13 Jun 2019 16:40:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 602726B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:40:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d13so474385edo.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:40:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=PX9Eys8Q8xmnOpn1Ekl1bpVYtyk5txyOqqCNrhyPFYU=;
        b=jC5uFWbFtyB+ayrMyyw2PM7WwbUpAyPuSSOsrpF36pnTnoq0agsuVeyQ65ecFx0VdJ
         iAOtUnGfPkdAGDJWCj/XuSCc3w/iOrn21sdszswTxXP3x7mRNm48Q4rMFd1BxtM/Jxuj
         p4qypNl9Hj9JkM7mus3Gj4djRK7w++jMcXkGO7KD3oPn65qT3EaCo7zb6e5yLc4UzSZm
         lDLJq1/8aBfQpSdtfnTxhDCPntVnAg4uLUyaOJqu0JI3b6hvLoPRhUJLIEjNAzkyWnV3
         s5Zz22biGxMss/8zK0sRwbvl+JwvWM0/4iyPKH2DAxisgQWG4ZLbiC6HhkBUVHmDJsKx
         0ejg==
X-Gm-Message-State: APjAAAXNiYdwY5l073BZFaCmbLjPkrzZgHc2/gzYIPxMOnDIBCDRzZDI
	tDExSjLHrJCj9gGfI2gBE4b6AowyFkZQHMkw6XGb0UTEUc0Ykg5wGn18Yo8FEW7kq8RLHuObBRw
	aqTWADixxJIighrSFdQxYgKiZBVqSpd3iAQW0A1zxZdc6tjPR1QeH+AKbvPaEhwgaAQ==
X-Received: by 2002:a17:906:7ac5:: with SMTP id k5mr3326422ejo.128.1560458448930;
        Thu, 13 Jun 2019 13:40:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGQoN6Q9egSpc19uTjx3LgnsX+QEeREuXy9CMxKBJoRndTHYOOOHm3kJdmP47mvNF74baD
X-Received: by 2002:a17:906:7ac5:: with SMTP id k5mr3326361ejo.128.1560458448013;
        Thu, 13 Jun 2019 13:40:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560458448; cv=none;
        d=google.com; s=arc-20160816;
        b=WA2PNWvkEH3hTBVFoL5CPx3tKKH87d5kGaVXCanCVlEx9gxZoRMvcDdvRnPWHGDdE5
         Wx1nRf2HG17QtUKU75cq5VsfuG9KAvEuGNjnQ0crcUqs+IOfNWywlQF28GArkkgUAkMp
         43xiS75+mtexLP2qzycA2eIivum0cbB/B/Bc6MFe4baGAa3PEouMl35jzMvLpywnfSZ8
         ErOguqwKwIhLS4qPdAFOj4036xJtgdv9kPw3mmhYahtr4LdFE35kjMSktPhh07Ezxi0e
         uIA4xoKcg/sjBl9T4Dl9Ms3pMwXLWfKORjcwPl8S/RO5tca4fCGYGN8pIQpSf2YmedPV
         ZEXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=PX9Eys8Q8xmnOpn1Ekl1bpVYtyk5txyOqqCNrhyPFYU=;
        b=GSZGDOGU8yJg80hxfTxFx0jX6vQ0Kq0zPe8jsV2TB57EWvlFmtnNydouK/qCP2Fpfw
         zyDu0XMR4DSSyEjzydtIytfcePNLE0XuK2QBmCTbUEIDCmx37RzN9rb1QGvh3H4UezC+
         N8pPm2fZUm+8jJT0ZBs6TjkMubSItySw3mVRTRc3GG2MaJbmZVQY2N/kpDfJTX4XbtCC
         RwCjYyxzKaTnxYF5bS8yuGTrLwWyWGS+ko8RTSLsYxcQinlYz9EGOexgmQuzw4zOlfNJ
         SkvnqmTDOh2+nvXFR+vUZbWnHlqUO34KPiHM30bb82CavBcYNNdlP4EK4j+cSs//tQgK
         rCPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=URF2uSJY;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.82 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20082.outbound.protection.outlook.com. [40.107.2.82])
        by mx.google.com with ESMTPS id i20si633691ejv.210.2019.06.13.13.40.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 13:40:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.2.82 as permitted sender) client-ip=40.107.2.82;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=URF2uSJY;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.82 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=PX9Eys8Q8xmnOpn1Ekl1bpVYtyk5txyOqqCNrhyPFYU=;
 b=URF2uSJYN6xjfsDoOg3OcSWCsk/8ctWmC21ScNLKDpkwEtHJ77Vj0z41hA5Ec74JGDldBLZArLu5+S1sKmWbY1DMZNe7mhUfYpp2fx5Q/f3aOCCLDECz4wNM3EafC1Z9gcgvAOWNOJa9Jk5hWMKGL/4tbDvR5wOkPbeaKzUyz1g=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5455.eurprd05.prod.outlook.com (20.177.201.10) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.12; Thu, 13 Jun 2019 20:40:46 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 20:40:46 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Christoph Hellwig <hch@lst.de>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM
	<linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, Maling list - DRI developers
	<dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Linux Kernel Mailing
 List <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>
Subject: Re: dev_pagemap related cleanups
Thread-Topic: dev_pagemap related cleanups
Thread-Index: AQHVIcx5DdVrUhs/HUiF5V2FmmsvzKaZ58OAgAAlLoA=
Date: Thu, 13 Jun 2019 20:40:46 +0000
Message-ID: <20190613204043.GD22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
In-Reply-To:
 <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: AM5PR0602CA0012.eurprd06.prod.outlook.com
 (2603:10a6:203:a3::22) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: de96dcdd-fcb6-4b31-c96c-08d6f03f6962
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB5455;
x-ms-traffictypediagnostic: VI1PR05MB5455:
x-microsoft-antispam-prvs:
 <VI1PR05MB5455783021F6B9AAA05E7D83CFEF0@VI1PR05MB5455.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1751;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(396003)(366004)(39860400002)(136003)(346002)(199004)(189003)(68736007)(53936002)(7116003)(14454004)(476003)(486006)(76176011)(1076003)(2616005)(256004)(14444005)(229853002)(8676002)(66476007)(66946007)(6436002)(66556008)(7416002)(6116002)(64756008)(446003)(81166006)(81156014)(11346002)(73956011)(6512007)(3846002)(8936002)(6486002)(66066001)(86362001)(2906002)(102836004)(6246003)(6916009)(478600001)(6506007)(66446008)(186003)(4326008)(52116002)(33656002)(36756003)(5660300002)(66574012)(99286004)(26005)(7736002)(71200400001)(71190400001)(316002)(25786009)(305945005)(54906003)(53546011)(386003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5455;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 VOUbwNTtQRybG06If3HGlhEeAdyRzVHyFE1PeYAnM2YST+XoV0HGXZmSRan2NLI4WzAL1uZHMOtxy2X19FOcN+ugIzEDUFaX/y9lsF432qn7eSAyrVCYonDHrej64NV4alsmCSSJokb9RspANzH4x63s7VqvMHLgzo59lUHDsWdAEVbzpL7WQ18EWRni5TbqLfFiUPRVpSCZGqmJDVxOTingKPJqTbNp+v0SquuxNy3Mex+3+W3QOi7ysRhyLQb0zSCh5J5QVp0cRn132iQGoWMQelu0ugQqizw44PX87UzQ2V2o6rwl6/4Hnvt21dLXxJjYf8VqxNV1nOX9BSxMnePDL//+83pg+owX+oZg6X73UgwJVYNPVw4bnFul+YoMR4T2/va4ViKQdFdOkUW3qT7Y3anPGP/LSkSZAo/2xrw=
Content-Type: text/plain; charset="utf-8"
Content-ID: <865564E19763524E9F69913C820BFA34@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: de96dcdd-fcb6-4b31-c96c-08d6f03f6962
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 20:40:46.4819
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5455
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCBKdW4gMTMsIDIwMTkgYXQgMTE6Mjc6MzlBTSAtMDcwMCwgRGFuIFdpbGxpYW1zIHdy
b3RlOg0KPiBPbiBUaHUsIEp1biAxMywgMjAxOSBhdCAyOjQzIEFNIENocmlzdG9waCBIZWxsd2ln
IDxoY2hAbHN0LmRlPiB3cm90ZToNCj4gPg0KPiA+IEhpIERhbiwgSsOpcsO0bWUgYW5kIEphc29u
LA0KPiA+DQo+ID4gYmVsb3cgaXMgYSBzZXJpZXMgdGhhdCBjbGVhbnMgdXAgdGhlIGRldl9wYWdl
bWFwIGludGVyZmFjZSBzbyB0aGF0DQo+ID4gaXQgaXMgbW9yZSBlYXNpbHkgdXNhYmxlLCB3aGlj
aCByZW1vdmVzIHRoZSBuZWVkIHRvIHdyYXAgaXQgaW4gaG1tDQo+ID4gYW5kIHRodXMgYWxsb3dp
bmcgdG8ga2lsbCBhIGxvdCBvZiBjb2RlDQo+ID4NCj4gPiBEaWZmc3RhdDoNCj4gPg0KPiA+ICAy
MiBmaWxlcyBjaGFuZ2VkLCAyNDUgaW5zZXJ0aW9ucygrKSwgODAyIGRlbGV0aW9ucygtKQ0KPiAN
Cj4gSG9vcmF5IQ0KPiANCj4gPiBHaXQgdHJlZToNCj4gPg0KPiA+ICAgICBnaXQ6Ly9naXQuaW5m
cmFkZWFkLm9yZy91c2Vycy9oY2gvbWlzYy5naXQgaG1tLWRldm1lbS1jbGVhbnVwDQo+IA0KPiBJ
IGp1c3QgcmVhbGl6ZWQgdGhpcyBjb2xsaWRlcyB3aXRoIHRoZSBkZXZfcGFnZW1hcCByZWxlYXNl
IHJld29yayBpbg0KPiBBbmRyZXcncyB0cmVlIChjb21taXQgaWRzIGJlbG93IGFyZSBmcm9tIG5l
eHQuZ2l0IGFuZCBhcmUgbm90IHN0YWJsZSkNCj4gDQo+IDQ0MjJlZTg0NzZmMCBtbS9kZXZtX21l
bXJlbWFwX3BhZ2VzOiBmaXggZmluYWwgcGFnZSBwdXQgcmFjZQ0KPiA3NzFmMDcxNGQwZGMgUENJ
L1AyUERNQTogdHJhY2sgcGdtYXAgcmVmZXJlbmNlcyBwZXIgcmVzb3VyY2UsIG5vdCBnbG9iYWxs
eQ0KPiBhZjM3MDg1ZGU5MDYgbGliL2dlbmFsbG9jOiBpbnRyb2R1Y2UgY2h1bmsgb3duZXJzDQo+
IGUwMDQ3ZmY4YWE3NyBQQ0kvUDJQRE1BOiBmaXggdGhlIGdlbl9wb29sX2FkZF92aXJ0KCkgZmFp
bHVyZSBwYXRoDQo+IDAzMTVkNDdkNmFlOSBtbS9kZXZtX21lbXJlbWFwX3BhZ2VzOiBpbnRyb2R1
Y2UgZGV2bV9tZW11bm1hcF9wYWdlcw0KPiAyMTY0NzVjN2VhYTggZHJpdmVycy9iYXNlL2RldnJl
czogaW50cm9kdWNlIGRldm1fcmVsZWFzZV9hY3Rpb24oKQ0KPiANCj4gQ09ORkxJQ1QgKGNvbnRl
bnQpOiBNZXJnZSBjb25mbGljdCBpbiB0b29scy90ZXN0aW5nL252ZGltbS90ZXN0L2lvbWFwLmMN
Cj4gQ09ORkxJQ1QgKGNvbnRlbnQpOiBNZXJnZSBjb25mbGljdCBpbiBtbS9obW0uYw0KPiBDT05G
TElDVCAoY29udGVudCk6IE1lcmdlIGNvbmZsaWN0IGluIGtlcm5lbC9tZW1yZW1hcC5jDQo+IENP
TkZMSUNUIChjb250ZW50KTogTWVyZ2UgY29uZmxpY3QgaW4gaW5jbHVkZS9saW51eC9tZW1yZW1h
cC5oDQo+IENPTkZMSUNUIChjb250ZW50KTogTWVyZ2UgY29uZmxpY3QgaW4gZHJpdmVycy9wY2kv
cDJwZG1hLmMNCj4gQ09ORkxJQ1QgKGNvbnRlbnQpOiBNZXJnZSBjb25mbGljdCBpbiBkcml2ZXJz
L252ZGltbS9wbWVtLmMNCj4gQ09ORkxJQ1QgKGNvbnRlbnQpOiBNZXJnZSBjb25mbGljdCBpbiBk
cml2ZXJzL2RheC9kZXZpY2UuYw0KPiBDT05GTElDVCAoY29udGVudCk6IE1lcmdlIGNvbmZsaWN0
IGluIGRyaXZlcnMvZGF4L2RheC1wcml2YXRlLmgNCj4gDQo+IFBlcmhhcHMgd2Ugc2hvdWxkIHB1
bGwgdGhvc2Ugb3V0IGFuZCByZXNlbmQgdGhlbSB0aHJvdWdoIGhtbS5naXQ/DQoNCkl0IGNvdWxk
IGJlIGRvbmUgLSBidXQgaG93IGJhZCBpcyB0aGUgY29uZmxpY3QgcmVzb2x1dGlvbj8NCg0KSSdk
IGJlIG1vcmUgY29tZm9ydGFibGUgdG8gdGFrZSBhIFBSIGZyb20geW91IHRvIG1lcmdlIGludG8g
aG1tLmdpdCwNCnJhdGhlciB0aGFuIHJhdyBwYXRjaGVzLCB0aGVuIGFwcGx5IENIJ3Mgc2VyaWVz
IG9uIHRvcC4gSSB0aGluay4NCg0KVGhhdCB3YXkgaWYgc29tZXRoaW5nIGdvZXMgd3JvbmcgeW91
IGNhbiBzZW5kIHlvdXIgUFIgdG8gTGludXMNCmRpcmVjdGx5Lg0KDQo+IEl0IGFsc28gdHVybnMg
b3V0IHRoZSBudmRpbW0gdW5pdCB0ZXN0cyBjcmFzaCB3aXRoIHRoaXMgc2lnbmF0dXJlIG9uDQo+
IHRoYXQgYnJhbmNoIHdoZXJlIGJhc2UgdjUuMi1yYzMgcGFzc2VzOg0KPiANCj4gICAgIEJVRzog
a2VybmVsIE5VTEwgcG9pbnRlciBkZXJlZmVyZW5jZSwgYWRkcmVzczogMDAwMDAwMDAwMDAwMDAw
OA0KPiAgICAgWy4uXQ0KPiAgICAgQ1BVOiAxNSBQSUQ6IDE0MTQgQ29tbTogbHQtbGlibmRjdGwg
VGFpbnRlZDogRyAgICAgICAgICAgT0UNCj4gNS4yLjAtcmMzKyAjMzM5OQ0KPiAgICAgSGFyZHdh
cmUgbmFtZTogUUVNVSBTdGFuZGFyZCBQQyAoaTQ0MEZYICsgUElJWCwgMTk5NiksIEJJT1MgMC4w
LjAgMDIvMDYvMjAxNQ0KPiAgICAgUklQOiAwMDEwOnBlcmNwdV9yZWZfa2lsbF9hbmRfY29uZmly
bSsweDFlLzB4MTgwDQo+ICAgICBbLi5dDQo+ICAgICBDYWxsIFRyYWNlOg0KPiAgICAgIHJlbGVh
c2Vfbm9kZXMrMHgyMzQvMHgyODANCj4gICAgICBkZXZpY2VfcmVsZWFzZV9kcml2ZXJfaW50ZXJu
YWwrMHhlOC8weDFiMA0KPiAgICAgIGJ1c19yZW1vdmVfZGV2aWNlKzB4ZjIvMHgxNjANCj4gICAg
ICBkZXZpY2VfZGVsKzB4MTY2LzB4MzcwDQo+ICAgICAgdW5yZWdpc3Rlcl9kZXZfZGF4KzB4MjMv
MHg1MA0KPiAgICAgIHJlbGVhc2Vfbm9kZXMrMHgyMzQvMHgyODANCj4gICAgICBkZXZpY2VfcmVs
ZWFzZV9kcml2ZXJfaW50ZXJuYWwrMHhlOC8weDFiMA0KPiAgICAgIHVuYmluZF9zdG9yZSsweDk0
LzB4MTIwDQo+ICAgICAga2VybmZzX2ZvcF93cml0ZSsweGYwLzB4MWEwDQo+ICAgICAgdmZzX3dy
aXRlKzB4YjcvMHgxYjANCj4gICAgICBrc3lzX3dyaXRlKzB4NWMvMHhkMA0KPiAgICAgIGRvX3N5
c2NhbGxfNjQrMHg2MC8weDI0MA0KDQpUb28gYmFkIHRoZSB0cmFjZSBkaWRuJ3Qgc2F5IHdoaWNo
IGRldm0gY2xlYW51cCB0cmlnZ2VyZWQgaXQuLiBEaWQNCmRldl9wYWdlbWFwX3BlcmNwdV9leGl0
IGdldCBjYWxsZWQgd2l0aCBhIE5VTEwgcGdtYXAtPnJlZiA/DQoNCkphc29uDQo=

