Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADC5CC43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 06:35:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5521320857
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 06:35:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="POlFOVAg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5521320857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA5758E0005; Sun,  3 Mar 2019 01:35:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2BAF8E0001; Sun,  3 Mar 2019 01:35:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7DA78E0005; Sun,  3 Mar 2019 01:35:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C85E8E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 01:35:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o27so1072698edc.14
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 22:35:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=kEtW5obe2/pHsmzQvB+ErO+srM1KYDkTV+yTZizdzrA=;
        b=Ds2O+1+m8hh97pK50y9z+t15Ndz0DLR94MAX/PqLs+T1wEVtbgpun0ANC2l1BLPJoJ
         zs9LnzVqgnEbynABDNXmasfUbGURF1j1xuaLYcc6At19fTS/72tNSSkmdPdbR2rNjIIr
         QDqAI9gzezKlbSjEtIiV/pucuXQcNfbA56y+f5VTfZvasVyXdIWBmrXrcZGdz7NvuCsG
         0jOEjiQUdV83mBGYuk/fxD3vSAG5dyO975+zk97mBj0vLv8LOUTEPrGqCH8gVnok2b+1
         MCo6nq3XtSDd6G3gffYYhJapaBh8gWGxu4h+YSFOR7xH5g+qVbWLngUCpiaaMPIPdp0g
         kO8Q==
X-Gm-Message-State: APjAAAVtkwykqjWk5aeL0W5hWJrLnd4vrGjMKy9Ip8fTdvHh/1O5egBp
	om6SWZ9zgUMDa2EgMRS6WXXMEfSfIgJeYFechb3Dyqm5pKjPbK7oUE7EUy+8SWFUY1v5rsmSSEM
	0QLLtD5AzFrPO8Ouw0RsQQtp86ubhyKQstxPke/5MN0+iLLh8upfmmvvj+cVi0d6rsA==
X-Received: by 2002:a50:ca41:: with SMTP id e1mr10580164edi.73.1551594938764;
        Sat, 02 Mar 2019 22:35:38 -0800 (PST)
X-Google-Smtp-Source: APXvYqyRv0IIQ3rC/FAYrMINch2UUyS+vTU96Imd2Ul0TdIY3Dmk6KSTA8zuSOrNy5aS2VYMT+M+
X-Received: by 2002:a50:ca41:: with SMTP id e1mr10580140edi.73.1551594938012;
        Sat, 02 Mar 2019 22:35:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551594938; cv=none;
        d=google.com; s=arc-20160816;
        b=zuMeZIVYDvRD9svQsBB/mSFLQzPbLDy7ayeDV0dZpewNBOxzr+TtQZykmgmAQ47nqh
         Q1Fr8gc+fVDAaM6dcXgO3idgtxdNHOoA5xr5AUIRZvNWzVCH0AtQ7FH0v8/hvsGgpzDv
         /1r/1r3BJXcmOEteQBq0QnK9PfjnqH2UCmPMvc/coGSwlNimI8S1dsVFqkrTrKCeIph1
         rtxw6//LiZHv5LTLqBAqod+aZRkn1bsVAeIPeuJMF9hh4gjiV0TY9AuRg69P2byn7dgp
         6UXD7nTh5biZE618gIyECQ/RbqCTs2EGUY/wldbiA5zcg9YyiR7W50DfzeGCkO8ye6BB
         45KA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=kEtW5obe2/pHsmzQvB+ErO+srM1KYDkTV+yTZizdzrA=;
        b=WGXzlzgKm+3u2pukndioiIVEogL/FVLsv9gp4z/eBt4A1rXJmzUr9e7frCEeta9ewW
         0gUV3bkHHdE0PWr7PIwYpNaLpTmVsxkn6Lo/9ijDvgKN4JN61D5PwcFzAclp0dpc/i/0
         AS4RHkeP7zhBuzOn/KlCLJ1MoeHCe7Aa054fSddXOrINxsbpoWd86VBp26qBez+ScKdB
         Bj88iKQswLXVUVN+TsU6SAFcCOSdYgtYwHFwsMH6RNA4PFuw4Mx//diysXGmf3o7yrlJ
         UaOqgskLRtWy1YMUepQRyiBIVc91QOTkblOWnRU5QSxUyMXVXbIFIkdYFNc9guPBzFP1
         TmiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=POlFOVAg;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.3.85 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30085.outbound.protection.outlook.com. [40.107.3.85])
        by mx.google.com with ESMTPS id f9si1090018edd.334.2019.03.02.22.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 02 Mar 2019 22:35:37 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.3.85 as permitted sender) client-ip=40.107.3.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=POlFOVAg;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.3.85 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=kEtW5obe2/pHsmzQvB+ErO+srM1KYDkTV+yTZizdzrA=;
 b=POlFOVAg6cQL3maCsmWrO/YvKK/3OYpdPH3iax010C8lvJIL7uunTpjg5v6ILgZZdF9WZuX0ll6h8ghtffO3pesdJNEAsQC/iFIzOXbJBkHi9wB12ZfPoZHbfdofD9kAN5hHBfuYJEX1mcpaJnl6yKl3cv69Ie2KgfOC1NUgG18=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB5491.eurprd04.prod.outlook.com (20.178.113.157) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.18; Sun, 3 Mar 2019 06:35:36 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Sun, 3 Mar 2019
 06:35:36 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph
 Lameter <cl@linux.com>
CC: Vlad Buslov <vladbu@mellanox.com>, "kernel-team@fb.com"
	<kernel-team@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 10/12] percpu: make pcpu_block_md generic
Thread-Topic: [PATCH 10/12] percpu: make pcpu_block_md generic
Thread-Index: AQHUzwv/tukJuc5LL02ZOvuifi5i06X5eHAQ
Date: Sun, 3 Mar 2019 06:35:36 +0000
Message-ID:
 <AM0PR04MB44813F889E555ABBE787576E88700@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-11-dennis@kernel.org>
In-Reply-To: <20190228021839.55779-11-dennis@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 98db45ce-635b-48e5-e01b-08d69fa271fe
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB5491;
x-ms-traffictypediagnostic: AM0PR04MB5491:
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtBTTBQUjA0TUI1NDkxOzIzOkl2cFZCU3lJa0NsL2Y4L1RKQmRIL0pDejdj?=
 =?gb2312?B?MFBUS2g5VkhNTDd5bjJ2cXh6NE1WUHovemNKSFg4R05wTUZsYnFCaFBuNEVZ?=
 =?gb2312?B?dWVxUGVoMTg5M2J3dzdheGlVK2VuZ0pzeFRhQis0MHZMQU9iSHptRmFUM1ZK?=
 =?gb2312?B?blpoNTJzY2QxNlhUQXI2MFd3aGdCUlJpbmxiOHQ5WFBOcm9kTGZaaHovczZH?=
 =?gb2312?B?amVJTC9IR2lHWEpvbmFDMDFGYVc4dkNxcTloTjV0SkpnV052Q3RDZ0VxZXVS?=
 =?gb2312?B?c1hPcDVxK1dmZTJiN2RCcDBCa0l4cW81c0NyTEg5dTBCOWVpL2F6ZU5nNTFl?=
 =?gb2312?B?L2tKbWVYSGJ3ZlJWVjZuR3RLdzRDUGlVOHdOSTBaNWhDUzJpSTNzaEdlMkR0?=
 =?gb2312?B?RlRmRWZxY3NsK0IyV2dxcXAyY0hBNE1SQmdEb1hmL2J2a2VaUGQxdVhDbTNF?=
 =?gb2312?B?NjVYeHJPNTFhNEpETlNjYlNGUW1ONGtsNGtmK2l5Z2RaV1hxTVp1NjArYits?=
 =?gb2312?B?RkVDWW5NdWhxSmVhU0hsYmhaakp6TWpKNUdNYzNwNWpTSkVxS2FKMDBadXBS?=
 =?gb2312?B?b1Q4YVBMVVNqWnFzNFhjN1A3SVhETWp5L2xzWEZmYzZ1bzVLNHFLZUd3WDZG?=
 =?gb2312?B?MzJLM1BwUEo4TFRtUFZsK3EwVmhrNXlmeVpOZHhjZFJiV0V2WG1UNWdYMGNr?=
 =?gb2312?B?TWNvakVETEdZTUI1N2dOV3JzQ0tJR3F0RjJuV3lVSEt2QW1xWlZMZGxUN2xn?=
 =?gb2312?B?MnhFTnZPelpvSVg0UngvZWFPc09OVTNNcTE0b01KQ1pVZmF1L3JUcVMzWXBM?=
 =?gb2312?B?cmZ2ZlVUVGFod2VwNkhhQUNEMmhoMVcwbG4yNFJPSmhSSGRtMzNRUkJJeVpV?=
 =?gb2312?B?NnNPREFEMStNcXZBYThNdDR3WTcxZUJSc0tRWHkrS1JESXhwUnluNlpmVmtL?=
 =?gb2312?B?aHNsNlVqZ2hzcUhpZFRYY1gxUUw2d3p2TXJZSHNjeE5wZC9uV0JxeHlDelgr?=
 =?gb2312?B?My9Nak1kdXppRHpnZHZFeTNldDlLckh6MW5EMnJvUEtqVDZnL3haNEE0SFhH?=
 =?gb2312?B?VG8wM3A1ZHhQeFdpczFHVTR1TjhvOGs3a1dXakJzUWs2SjBkb09JZDFHa0Qy?=
 =?gb2312?B?N1BWL2w3V24vNm5PeGY4bGQzb29QR0dDZkE4bGNyc0lQY1Rwb3pKeTJmTCth?=
 =?gb2312?B?VDlOS3IreUpYSGRXTTRVeCtNUTBiTlBFYXEyS3hlU1BYa0t4TGdUMTE4MUhC?=
 =?gb2312?B?RXd0Y29ZVlFHaUsvWktDaHd1b3VlS3BQWFJOSkpZN1NMa2lHY0l1elgzbXN5?=
 =?gb2312?B?R3duSHFGcC8rTzRyOUJVZHNBdkxNY1FKdVhheElPRkNEb1E3Qk1EczlIYmh1?=
 =?gb2312?B?L3MyWlROZ1BNS29VQ2FkNlphdUdmZ3NLUVY2cFYrMkVJeGVBU0xCdzJwaGpI?=
 =?gb2312?B?Z3M0QUdwTnBRMWczVkdFTnBYM2xGL1VaUEd0eEZndjFGOEV3RERNSDN0UzVD?=
 =?gb2312?B?b243RmhzMno1NU11c2s3REtMNGpQVlVkMVBaU3RiSVdTKzc0Sk9sUWRzRzJ2?=
 =?gb2312?B?TmgySkMrVEpXUTJYdnh1ODBheWFMWDJtYjNia1k5QnFFS01CdTlvclQ5Z0Nx?=
 =?gb2312?B?amw3b1Y3RG9ic04vMWdjeVl1Tm5PSmhJcWFENW5HT1BRYm41NE9oR0JlUi93?=
 =?gb2312?B?L0J4TFdja3lLVTB0bE5JWjdyNVU1QVRGMGtqZzJNNzhrUkQzeWhIYmFkTkFQ?=
 =?gb2312?Q?mQlbGbnfrvVyuqRzfesofNK5RJL1RRA+qX1bM=3D?=
x-microsoft-antispam-prvs:
 <AM0PR04MB5491C3EF8B2638985BDB2BB388700@AM0PR04MB5491.eurprd04.prod.outlook.com>
x-forefront-prvs: 096507C068
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(366004)(396003)(39860400002)(346002)(136003)(199004)(189003)(13464003)(99286004)(5660300002)(229853002)(66066001)(55016002)(53936002)(9686003)(71190400001)(71200400001)(256004)(14444005)(6246003)(106356001)(105586002)(6436002)(2906002)(8936002)(97736004)(86362001)(68736007)(74316002)(52536013)(33656002)(3846002)(305945005)(26005)(7736002)(186003)(4326008)(76176011)(7696005)(53546011)(25786009)(8676002)(102836004)(81156014)(81166006)(6506007)(14454004)(316002)(478600001)(54906003)(110136005)(476003)(486006)(446003)(11346002)(44832011)(6116002)(41533002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB5491;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 EKR0+cP41YoKoW4bE4V1APjdnxo+JLELbzBaF6IXtzLgTzHUR/CwqJJkAJXqav62Duhx3hy6LLUa5r4YMMmP6XZvBt4WICggP/AoIgoIY2uk2W8MuOTiV+BDSNMNVxotJ1Q5vr7mqQY+DShDuoegCnrypuUlPsPSJaF/Zq3lGIIMfNGaTjAlKrhQOUbnvzRkl3IERHJGKfpFHuN+/20yYvWi1QlQqsWJ7eXssuUh8mZihgwXESkyzcXK4q4zfA3yrT77VMoDqN1vfKoo3B79/YZSLgZu474ZXB/SvdacLIdA2WaMXqyFaH+SHDWjlwYhT8dO+Ys1sltay7dqSspu9NHpZRknUbF48jg0jwkoNleYizslq9uuA5PE3xudDpmF5hTkdqtvYMn2Dce+/FZzDyDI74w4A8ChYeU3j2viKoM=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 98db45ce-635b-48e5-e01b-08d69fa271fe
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Mar 2019 06:35:36.4520
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB5491
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogb3duZXItbGludXgtbW1A
a3ZhY2sub3JnIFttYWlsdG86b3duZXItbGludXgtbW1Aa3ZhY2sub3JnXSBPbg0KPiBCZWhhbGYg
T2YgRGVubmlzIFpob3UNCj4gU2VudDogMjAxOcTqMtTCMjjI1SAxMDoxOQ0KPiBUbzogRGVubmlz
IFpob3UgPGRlbm5pc0BrZXJuZWwub3JnPjsgVGVqdW4gSGVvIDx0akBrZXJuZWwub3JnPjsgQ2hy
aXN0b3BoDQo+IExhbWV0ZXIgPGNsQGxpbnV4LmNvbT4NCj4gQ2M6IFZsYWQgQnVzbG92IDx2bGFk
YnVAbWVsbGFub3guY29tPjsga2VybmVsLXRlYW1AZmIuY29tOw0KPiBsaW51eC1tbUBrdmFjay5v
cmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogW1BBVENIIDEwLzEy
XSBwZXJjcHU6IG1ha2UgcGNwdV9ibG9ja19tZCBnZW5lcmljDQo+IA0KPiBJbiByZWFsaXR5LCBh
IGNodW5rIGlzIGp1c3QgYSBibG9jayBjb3ZlcmluZyBhIGxhcmdlciBudW1iZXIgb2YgYml0cy4N
Cj4gVGhlIGhpbnRzIHRoZW1zZWx2ZXMgYXJlIG9uZSBpbiB0aGUgc2FtZS4gUmF0aGVyIHRoYW4g
bWFpbnRhaW5pbmcgdGhlIGhpbnRzDQo+IHNlcGFyYXRlbHksIGZpcnN0IGludHJvZHVjZSBucl9i
aXRzIHRvIGdlbmVyaWNpemUNCj4gcGNwdV9ibG9ja191cGRhdGUoKSB0byBjb3JyZWN0bHkgbWFp
bnRhaW4gYmxvY2stPnJpZ2h0X2ZyZWUuIFRoZSBuZXh0IHBhdGNoDQo+IHdpbGwgY29udmVydCBj
aHVuayBoaW50cyB0byBiZSBtYW5hZ2VkIGFzIGEgcGNwdV9ibG9ja19tZC4NCj4gDQo+IFNpZ25l
ZC1vZmYtYnk6IERlbm5pcyBaaG91IDxkZW5uaXNAa2VybmVsLm9yZz4NCj4gLS0tDQo+ICBtbS9w
ZXJjcHUtaW50ZXJuYWwuaCB8ICAxICsNCj4gIG1tL3BlcmNwdS5jICAgICAgICAgIHwgMjAgKysr
KysrKysrKysrKy0tLS0tLS0NCj4gIDIgZmlsZXMgY2hhbmdlZCwgMTQgaW5zZXJ0aW9ucygrKSwg
NyBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9tbS9wZXJjcHUtaW50ZXJuYWwuaCBi
L21tL3BlcmNwdS1pbnRlcm5hbC5oIGluZGV4DQo+IGVjNThiMjQ0NTQ1ZC4uMTE5YmQxMTE5YWE3
IDEwMDY0NA0KPiAtLS0gYS9tbS9wZXJjcHUtaW50ZXJuYWwuaA0KPiArKysgYi9tbS9wZXJjcHUt
aW50ZXJuYWwuaA0KPiBAQCAtMjgsNiArMjgsNyBAQCBzdHJ1Y3QgcGNwdV9ibG9ja19tZCB7DQo+
ICAJaW50ICAgICAgICAgICAgICAgICAgICAgcmlnaHRfZnJlZTsgICAgIC8qIHNpemUgb2YgZnJl
ZSBzcGFjZSBhbG9uZw0KPiAgCQkJCQkJICAgdGhlIHJpZ2h0IHNpZGUgb2YgdGhlIGJsb2NrICov
DQo+ICAJaW50ICAgICAgICAgICAgICAgICAgICAgZmlyc3RfZnJlZTsgICAgIC8qIGJsb2NrIHBv
c2l0aW9uIG9mIGZpcnN0IGZyZWUNCj4gKi8NCj4gKwlpbnQJCQlucl9iaXRzOwkvKiB0b3RhbCBi
aXRzIHJlc3BvbnNpYmxlIGZvciAqLw0KPiAgfTsNCj4gDQo+ICBzdHJ1Y3QgcGNwdV9jaHVuayB7
DQo+IGRpZmYgLS1naXQgYS9tbS9wZXJjcHUuYyBiL21tL3BlcmNwdS5jDQo+IGluZGV4IGU1MWMx
NTFlZDY5Mi4uN2NkZjE0YzI0MmRlIDEwMDY0NA0KPiAtLS0gYS9tbS9wZXJjcHUuYw0KPiArKysg
Yi9tbS9wZXJjcHUuYw0KPiBAQCAtNjU4LDcgKzY1OCw3IEBAIHN0YXRpYyB2b2lkIHBjcHVfYmxv
Y2tfdXBkYXRlKHN0cnVjdCBwY3B1X2Jsb2NrX21kDQo+ICpibG9jaywgaW50IHN0YXJ0LCBpbnQg
ZW5kKQ0KPiAgCWlmIChzdGFydCA9PSAwKQ0KPiAgCQlibG9jay0+bGVmdF9mcmVlID0gY29udGln
Ow0KPiANCj4gLQlpZiAoZW5kID09IFBDUFVfQklUTUFQX0JMT0NLX0JJVFMpDQo+ICsJaWYgKGVu
ZCA9PSBibG9jay0+bnJfYml0cykNCj4gIAkJYmxvY2stPnJpZ2h0X2ZyZWUgPSBjb250aWc7DQo+
IA0KPiAgCWlmIChjb250aWcgPiBibG9jay0+Y29udGlnX2hpbnQpIHsNCj4gQEAgLTEyNzEsMTgg
KzEyNzEsMjQgQEAgc3RhdGljIHZvaWQgcGNwdV9mcmVlX2FyZWEoc3RydWN0IHBjcHVfY2h1bmsN
Cj4gKmNodW5rLCBpbnQgb2ZmKQ0KPiAgCXBjcHVfY2h1bmtfcmVsb2NhdGUoY2h1bmssIG9zbG90
KTsNCj4gIH0NCj4gDQo+ICtzdGF0aWMgdm9pZCBwY3B1X2luaXRfbWRfYmxvY2soc3RydWN0IHBj
cHVfYmxvY2tfbWQgKmJsb2NrLCBpbnQNCj4gK25yX2JpdHMpIHsNCj4gKwlibG9jay0+c2Nhbl9o
aW50ID0gMDsNCj4gKwlibG9jay0+Y29udGlnX2hpbnQgPSBucl9iaXRzOw0KPiArCWJsb2NrLT5s
ZWZ0X2ZyZWUgPSBucl9iaXRzOw0KPiArCWJsb2NrLT5yaWdodF9mcmVlID0gbnJfYml0czsNCj4g
KwlibG9jay0+Zmlyc3RfZnJlZSA9IDA7DQo+ICsJYmxvY2stPm5yX2JpdHMgPSBucl9iaXRzOw0K
PiArfQ0KPiArDQo+ICBzdGF0aWMgdm9pZCBwY3B1X2luaXRfbWRfYmxvY2tzKHN0cnVjdCBwY3B1
X2NodW5rICpjaHVuaykgIHsNCj4gIAlzdHJ1Y3QgcGNwdV9ibG9ja19tZCAqbWRfYmxvY2s7DQo+
IA0KPiAgCWZvciAobWRfYmxvY2sgPSBjaHVuay0+bWRfYmxvY2tzOw0KPiAgCSAgICAgbWRfYmxv
Y2sgIT0gY2h1bmstPm1kX2Jsb2NrcyArIHBjcHVfY2h1bmtfbnJfYmxvY2tzKGNodW5rKTsNCj4g
LQkgICAgIG1kX2Jsb2NrKyspIHsNCj4gLQkJbWRfYmxvY2stPnNjYW5faGludCA9IDA7DQo+IC0J
CW1kX2Jsb2NrLT5jb250aWdfaGludCA9IFBDUFVfQklUTUFQX0JMT0NLX0JJVFM7DQo+IC0JCW1k
X2Jsb2NrLT5sZWZ0X2ZyZWUgPSBQQ1BVX0JJVE1BUF9CTE9DS19CSVRTOw0KPiAtCQltZF9ibG9j
ay0+cmlnaHRfZnJlZSA9IFBDUFVfQklUTUFQX0JMT0NLX0JJVFM7DQo+IC0JfQ0KPiArCSAgICAg
bWRfYmxvY2srKykNCj4gKwkJcGNwdV9pbml0X21kX2Jsb2NrKG1kX2Jsb2NrLCBQQ1BVX0JJVE1B
UF9CTE9DS19CSVRTKTsNCj4gIH0NCg0KUmV2aWV3ZWQtYnk6IFBlbmcgRmFuIDxwZW5nLmZhbkBu
eHAuY29tPg0KDQo+IA0KPiAgLyoqDQo+IC0tDQo+IDIuMTcuMQ0KDQo=

