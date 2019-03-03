Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03344C43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 06:01:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6047D20863
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 06:01:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="o7H0UpUS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6047D20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 851EE8E0004; Sun,  3 Mar 2019 01:01:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FF1F8E0001; Sun,  3 Mar 2019 01:01:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 679B88E0004; Sun,  3 Mar 2019 01:01:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E74788E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 01:01:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x47so1031767eda.8
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 22:01:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=LUAOeuH6lkmMtegu5ScD/WAbUGVyIToJwh5l5kWnuWQ=;
        b=Mxp1p3Z3vomaSuT/0rUzM3amLrn7jy03dadrtnnMybcPGEhqjPErWOz4tGqENH+4+7
         01l8QHuKSlOMcAWqDzMljQxfRohYvWNJmg0y+E/V0YeyIvX1s+rQ5VeaSd1noNWo80uv
         QTVUkQJYCX7vPes77MfGa/gexVMmVegHNxHWitI7Ly0UKqzrfiMnZvtVTUrlA735xsCh
         /QulMtR5wA8N9t3cPS8SJSAdTfF83qiDza5yOZKcWz3IXqpCUcH8mV+XFZkXc2P4Rt/Q
         WQXsF4flKTvya6k4U8DProjrW3cPKtMwHXyiOfIwe0qlFavLM3wIumqWp+q2PK4nA/FS
         HHHA==
X-Gm-Message-State: APjAAAUzESVeErT9ViTJ7DmD0zIj9Q/9oAqEiMwIxES4NPyDnnABIsc3
	Ha8hpsYXUKI2fsWKyEo43L8dcXntDQN9PhEOtsRlH5STOFLFVk2WTWOiRZLOs5NOXAJmCIW8dHm
	CfFt+XZ4A1LpZPafF6E2gWVNheXebY4RYnxKBdfx5s3ZpR6Plvpgs2hl9Qzh0pFsOCw==
X-Received: by 2002:aa7:d795:: with SMTP id s21mr10195017edq.116.1551592905476;
        Sat, 02 Mar 2019 22:01:45 -0800 (PST)
X-Google-Smtp-Source: APXvYqx7pkz5HQPCEYyh0bci3ZJBRiZU6jATIrRnlrkrf1kDhzTLg+Y8cG7atDGW5umzBVddUTyI
X-Received: by 2002:aa7:d795:: with SMTP id s21mr10194961edq.116.1551592904148;
        Sat, 02 Mar 2019 22:01:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551592904; cv=none;
        d=google.com; s=arc-20160816;
        b=J9da1TFMkcCxaWKpT3VQ3VRTdCBiEV76h5mz6oyyzq7W879vgN0o+FHYOOyPsQjcMV
         T1ZcLM07d9r+ib2nuk7um+0IrS/uzLxuYh1vCoxktAu0KuUqsPePzgWQOnew+oe/K4ft
         CjQMJtobPhjd8/PxI5TntWGwluJp5mU9DY+UiwFtNCnd85JwepOVz4wQrKg+0Wuw9Wzp
         Sw9wAjhwh98hvkWmQSxXkxOy8gt0YKcttv4pdq2f8ar66aUOr9gUGlYrLHuqtBGrTKMa
         RyIwGbeXEvHRoJX+gl7RKRD6AZi2O9bJgs1IRG4nXPsl/SbrXZgf/KmvAl7XDMZoqRBs
         DGfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=LUAOeuH6lkmMtegu5ScD/WAbUGVyIToJwh5l5kWnuWQ=;
        b=0y3pcp4Wd0UQWcwjx6LSUzTSV4vC8RSD2qhBpie/GaBwPvmAa2We7MzJpaDhNOKAPB
         G8vymPGjSQG25fBa1y36EWSTDPMriiaCK+hebpqDLGicZvbdzEp3N/LppgLgBVE3UfsH
         S4p6pfXCO1c9JID0z5fQtNNOTA5wzq2uHjx7qtMHvdVzytHf7ydyyZpe2EpN5J9VyFnP
         E2bAAuWr4m3CyhkA1uW3jUriwMNBh8Yz5H5+GAeysHguhK9EX3hiiZpaR8HlGQb83zAk
         cCPGsVSygUlqz1bRZNgdj1JZS1j27rd1MTSMxgFhSUOCVoiGEl1KR3gXOootRM1GdSxM
         JWLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=o7H0UpUS;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.42 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80042.outbound.protection.outlook.com. [40.107.8.42])
        by mx.google.com with ESMTPS id o13si458824ejg.179.2019.03.02.22.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 02 Mar 2019 22:01:44 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.42 as permitted sender) client-ip=40.107.8.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=o7H0UpUS;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.42 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LUAOeuH6lkmMtegu5ScD/WAbUGVyIToJwh5l5kWnuWQ=;
 b=o7H0UpUShxGEjXaO8imRSYZb4uVpcxY2XWOrj86wmaeVT0eiH7IXABfk7UVFD4vSCqA8dtSfSzExUWQIBG1af/xHN/YBOUpPLo3Zhjqgh9yTM+l7AAg8B8svkY4FqCGNxyOAg1DtlEL5Uqa/wLgcVTRggsuHmQlV9WqWfrQ6YfM=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB5682.eurprd04.prod.outlook.com (20.178.202.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.19; Sun, 3 Mar 2019 06:01:42 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Sun, 3 Mar 2019
 06:01:42 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph
 Lameter <cl@linux.com>
CC: Vlad Buslov <vladbu@mellanox.com>, "kernel-team@fb.com"
	<kernel-team@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 07/12] percpu: add block level scan_hint
Thread-Topic: [PATCH 07/12] percpu: add block level scan_hint
Thread-Index: AQHUzwv6lsqDgTFFmUKPJkiHnO4qFKX5ZeIA
Date: Sun, 3 Mar 2019 06:01:42 +0000
Message-ID:
 <AM0PR04MB44813651B653B5269C5C211D88700@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-8-dennis@kernel.org>
In-Reply-To: <20190228021839.55779-8-dennis@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ffc78d03-46ae-43e4-9733-08d69f9db58f
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB5682;
x-ms-traffictypediagnostic: AM0PR04MB5682:
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtBTTBQUjA0TUI1NjgyOzIzOlA0UTRKc01UdklzMnJuWk4rallFbk5KV0pi?=
 =?gb2312?B?VlkwNHJQWUZ1TFVHaTBLZ0lkNnE5NllhU3dRamQva244Q2dKOVBqQUt3bjBZ?=
 =?gb2312?B?d3dWdHVsN3BDbGhFcU9mQ3A5aHR2MVBPK2x3MmZoZERldUtsNmoxQlVpVUtB?=
 =?gb2312?B?QUhYeEdGcjMxTGNPNmI4MzVwRmYxTHRWQ0VEdTVFSHNlS0NnSTZhSWlVM1FN?=
 =?gb2312?B?dXdUU0h2VVBLbndSUmFVTGZhUzhxMUtZWThQUjZXR0NFYUZWT2VISjBRM01i?=
 =?gb2312?B?SEZLN1BMbTNnOGp5eE43UkVWbzN5TDg3a2tHc3FsamVmQnJ6TG5wQStnNEc2?=
 =?gb2312?B?ZGF6V0Q0czhQUnNWM3l2Z3pVUGhZaUVEaEZINWIxTFlRNVkzUWF1UkFzNjM2?=
 =?gb2312?B?Y3J1QkoyY0I4QlJtRW11S0E1MEFKdWI4R3UvM0dKd2l4U3FYbUNXMnNjbmhG?=
 =?gb2312?B?U1JzUi9RTnhPM0RXbDZxVHI0VUducUdnTG5hdi90d2J2MVNQeTlrYzdrS2NL?=
 =?gb2312?B?MHpQamp5S0FDL1hoRDhjSUY2TXpnVXcwbDRLMVltOWg2bEI1OXY4NDEyTThD?=
 =?gb2312?B?OEszc2UwTVA3aUZUY29KWXZ0Nng5bHJ5bGgySlROd0dRejZncTN2Qy9qUzVF?=
 =?gb2312?B?NDhtakdvNUZLTHF3c2ZkUEhZbXJtSmwwUDdkaHZ3NXBQWFkxZ3hJVlM2QzZv?=
 =?gb2312?B?by9paGtoY2xwZnJwVkFuWTl4OTJrOUNyRi9XeFM2a0ZBTVdYOFVtUWYyVm1Z?=
 =?gb2312?B?djBQdzFqZjlsVVU5YitiYzRURGRiSWlVbW8xenBnN0FqNWNaaysxRDFzeTBx?=
 =?gb2312?B?djVtVFd6Qkx2RFhwM0FOT1FYckFNVGEvTThKZ2xIRUZZakFpTy9Zb09YWFdU?=
 =?gb2312?B?RFdEYzR6aWQ3RXVHMlFaTlZ1aEN4eVF1eGhRaEsrbmt6SkRTbForYVF6L0JT?=
 =?gb2312?B?RlRRaERSYUJlL2NVclFiNys4VVlQRUhGQ2UwSEJVdkV5RDNpdnU5cHdRbi82?=
 =?gb2312?B?eTg4S2lxdEVUK003NGZSL1p6T2s2elFQRkQ0MnhBaXRNdGs0UVBKckRBdU9K?=
 =?gb2312?B?VkxBYlp6ejNucS9KTkorb1dqaVI5WUFwQ0JvSmhpck5nRVdwUXZobkMrRy9I?=
 =?gb2312?B?M3F2TnE1dFp0djUwb0p0M3B5aDUvMGwzVGYwdHN2UDFQUlV4UlBxaWl0RFlK?=
 =?gb2312?B?Z2F2WXBuemVvQysxR3B0ZDB2aHJ6b2IwMmd3dXBmT1J0M0Q3YkxOOTF2eTkz?=
 =?gb2312?B?RjY2NzRTQm5adXg5VnpucE90S3EwWkRkeE5XU2pMY2lSb1BCT3RaSm8ydnky?=
 =?gb2312?B?U1k5UEdQcFZkWFFVRGNxL2ZtQitxd0k5cTlPdHNReXNqQVNITGQ5dnpzYjIx?=
 =?gb2312?B?MENrY2o1WHRHeml5N1laVWIydlJIVVRTZ0VDRU1Pek80bnR1V0hUWS8wZGMw?=
 =?gb2312?B?bFducm9XSWgvbmsyS2hRSERXTWdjQWNBSHlISGxuZEJEakhwK2VvbjJ1WktP?=
 =?gb2312?B?clRtNEswN3dxRHZMYzNTbCtnWXBhL3pjcFJXTDJ1TEpwWXhUc0xHVFJGNFlY?=
 =?gb2312?B?aExXeDZsSVViZEpLVGJDcThFZDBkMUtDUUd2TFMrTnJwNTlBYUErMVZ5akJo?=
 =?gb2312?B?TVB2QVJoRityc2VvdjYzK1A2V3NucEF0SENQRE8vbE5vYTRpNUJuSU53MTlt?=
 =?gb2312?B?bTBoeDJGZmZRS3c2REZHZjBiTTRMbE94L3V4REZHem11Vnpzc0VtTTI5a0gv?=
 =?gb2312?Q?RYl9fUZGiX4iOPr9VUaI7l2Ep3rVr2YgNQ8l0=3D?=
x-microsoft-antispam-prvs:
 <AM0PR04MB5682AA4DBA1B9DF16C3C674188700@AM0PR04MB5682.eurprd04.prod.outlook.com>
x-forefront-prvs: 096507C068
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(346002)(396003)(366004)(39860400002)(376002)(13464003)(189003)(199004)(81156014)(54906003)(8936002)(446003)(11346002)(110136005)(6116002)(81166006)(106356001)(478600001)(2906002)(6246003)(52536013)(9686003)(316002)(256004)(53936002)(3846002)(44832011)(486006)(7736002)(14444005)(476003)(76176011)(7696005)(186003)(66066001)(74316002)(6346003)(4326008)(86362001)(305945005)(14454004)(5660300002)(68736007)(105586002)(55016002)(8676002)(6436002)(97736004)(71190400001)(25786009)(6506007)(33656002)(102836004)(229853002)(53546011)(26005)(99286004)(71200400001);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB5682;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 0ug/mJ9Vli6joXWSLUKt8OVwBnlDpH47cPR5dUrDoTJSSQf+/ddqCuE8tchVY4e0n5G0Jtmr0XBczX1oGxg6pEzZWShkqRFfC108H8dUNOYht1GdLONAJ1nh5u5Juks6gtvtN94TV5P9p3NBwbSjz7RX3e4RISG8J9XAov+EGMB3Y3YXjGhWYR032h9XEt1gt8OTXcijDwrb9u1aIkr9zGXiaU0R0jy7pr+oBL3wmcwS3NxbBuEj0yturlu/sChyAYVcLdldsBqbEgX+bo6E9CtsbPLVI3JieWLU4PBK1PJxwvOt3XMCjHQY2N0ovsiWyyLC+S2M6ux1gDmuZONOcjfnE764Xa2n26C9HFVf96ibBBdT0pLbyOZeMwegxl2/QLVzQLoCzjMZ5uFmWZEFU0YLUlpwFvqSCH2elOpOdwE=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ffc78d03-46ae-43e4-9733-08d69f9db58f
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Mar 2019 06:01:42.3101
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB5682
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgRGVubmlzDQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogb3duZXIt
bGludXgtbW1Aa3ZhY2sub3JnIFttYWlsdG86b3duZXItbGludXgtbW1Aa3ZhY2sub3JnXSBPbg0K
PiBCZWhhbGYgT2YgRGVubmlzIFpob3UNCj4gU2VudDogMjAxOcTqMtTCMjjI1SAxMDoxOQ0KPiBU
bzogRGVubmlzIFpob3UgPGRlbm5pc0BrZXJuZWwub3JnPjsgVGVqdW4gSGVvIDx0akBrZXJuZWwu
b3JnPjsgQ2hyaXN0b3BoDQo+IExhbWV0ZXIgPGNsQGxpbnV4LmNvbT4NCj4gQ2M6IFZsYWQgQnVz
bG92IDx2bGFkYnVAbWVsbGFub3guY29tPjsga2VybmVsLXRlYW1AZmIuY29tOw0KPiBsaW51eC1t
bUBrdmFjay5vcmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogW1BB
VENIIDA3LzEyXSBwZXJjcHU6IGFkZCBibG9jayBsZXZlbCBzY2FuX2hpbnQNCj4gDQo+IEZyYWdt
ZW50YXRpb24gY2FuIGNhdXNlIGJvdGggYmxvY2tzIGFuZCBjaHVua3MgdG8gaGF2ZSBhbiBlYXJs
eSBmaXJzdF9maXJlZQ0KPiBiaXQgYXZhaWxhYmxlLCBidXQgb25seSBhYmxlIHRvIHNhdGlzZnkg
YWxsb2NhdGlvbnMgbXVjaCBsYXRlciBvbi4gVGhpcyBwYXRjaA0KPiBpbnRyb2R1Y2VzIGEgc2Nh
bl9oaW50IHRvIGhlbHAgbWl0aWdhdGUgc29tZSB1bm5lY2Vzc2FyeSBzY2FubmluZy4NCj4gDQo+
IFRoZSBzY2FuX2hpbnQgcmVtZW1iZXJzIHRoZSBsYXJnZXN0IGFyZWEgcHJpb3IgdG8gdGhlIGNv
bnRpZ19oaW50LiBJZiB0aGUNCj4gY29udGlnX2hpbnQgPT0gc2Nhbl9oaW50LCB0aGVuIHNjYW5f
aGludF9zdGFydCA+IGNvbnRpZ19oaW50X3N0YXJ0Lg0KPiBUaGlzIGlzIG5lY2Vzc2FyeSBmb3Ig
c2Nhbl9oaW50IGRpc2NvdmVyeSB3aGVuIHJlZnJlc2hpbmcgYSBibG9jay4NCj4gDQo+IFNpZ25l
ZC1vZmYtYnk6IERlbm5pcyBaaG91IDxkZW5uaXNAa2VybmVsLm9yZz4NCj4gLS0tDQo+ICBtbS9w
ZXJjcHUtaW50ZXJuYWwuaCB8ICAgOSArKysrDQo+ICBtbS9wZXJjcHUuYyAgICAgICAgICB8IDEw
MQ0KPiArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrLS0tDQo+ICAyIGZp
bGVzIGNoYW5nZWQsIDEwMyBpbnNlcnRpb25zKCspLCA3IGRlbGV0aW9ucygtKQ0KPiANCj4gZGlm
ZiAtLWdpdCBhL21tL3BlcmNwdS1pbnRlcm5hbC5oIGIvbW0vcGVyY3B1LWludGVybmFsLmggaW5k
ZXgNCj4gYjE3MzlkYzA2YjczLi5lYzU4YjI0NDU0NWQgMTAwNjQ0DQo+IC0tLSBhL21tL3BlcmNw
dS1pbnRlcm5hbC5oDQo+ICsrKyBiL21tL3BlcmNwdS1pbnRlcm5hbC5oDQo+IEBAIC05LDggKzks
MTcgQEANCj4gICAqIHBjcHVfYmxvY2tfbWQgaXMgdGhlIG1ldGFkYXRhIGJsb2NrIHN0cnVjdC4N
Cj4gICAqIEVhY2ggY2h1bmsncyBiaXRtYXAgaXMgc3BsaXQgaW50byBhIG51bWJlciBvZiBmdWxs
IGJsb2Nrcy4NCj4gICAqIEFsbCB1bml0cyBhcmUgaW4gdGVybXMgb2YgYml0cy4NCj4gKyAqDQo+
ICsgKiBUaGUgc2NhbiBoaW50IGlzIHRoZSBsYXJnZXN0IGtub3duIGNvbnRpZ3VvdXMgYXJlYSBi
ZWZvcmUgdGhlIGNvbnRpZyBoaW50Lg0KPiArICogSXQgaXMgbm90IG5lY2Vzc2FyaWx5IHRoZSBh
Y3R1YWwgbGFyZ2VzdCBjb250aWcgaGludCB0aG91Z2guICBUaGVyZQ0KPiArIGlzIGFuDQo+ICsg
KiBpbnZhcmlhbnQgdGhhdCB0aGUgc2Nhbl9oaW50X3N0YXJ0ID4gY29udGlnX2hpbnRfc3RhcnQg
aWZmDQo+ICsgKiBzY2FuX2hpbnQgPT0gY29udGlnX2hpbnQuICBUaGlzIGlzIG5lY2Vzc2FyeSBi
ZWNhdXNlIHdoZW4gc2Nhbm5pbmcNCj4gKyBmb3J3YXJkLA0KPiArICogd2UgZG9uJ3Qga25vdyBp
ZiBhIG5ldyBjb250aWcgaGludCB3b3VsZCBiZSBiZXR0ZXIgdGhhbiB0aGUgY3VycmVudCBvbmUu
DQo+ICAgKi8NCj4gIHN0cnVjdCBwY3B1X2Jsb2NrX21kIHsNCj4gKwlpbnQJCQlzY2FuX2hpbnQ7
CS8qIHNjYW4gaGludCBmb3IgYmxvY2sgKi8NCj4gKwlpbnQJCQlzY2FuX2hpbnRfc3RhcnQ7IC8q
IGJsb2NrIHJlbGF0aXZlIHN0YXJ0aW5nDQo+ICsJCQkJCQkgICAgcG9zaXRpb24gb2YgdGhlIHNj
YW4gaGludCAqLw0KPiAgCWludCAgICAgICAgICAgICAgICAgICAgIGNvbnRpZ19oaW50OyAgICAv
KiBjb250aWcgaGludCBmb3IgYmxvY2sgKi8NCj4gIAlpbnQgICAgICAgICAgICAgICAgICAgICBj
b250aWdfaGludF9zdGFydDsgLyogYmxvY2sgcmVsYXRpdmUgc3RhcnRpbmcNCj4gIAkJCQkJCSAg
ICAgIHBvc2l0aW9uIG9mIHRoZSBjb250aWcgaGludCAqLyBkaWZmIC0tZ2l0DQo+IGEvbW0vcGVy
Y3B1LmMgYi9tbS9wZXJjcHUuYyBpbmRleCA5NjdjOWNjM2E5MjguLmRmMWFhY2Y1OGFjOCAxMDA2
NDQNCj4gLS0tIGEvbW0vcGVyY3B1LmMNCj4gKysrIGIvbW0vcGVyY3B1LmMNCj4gQEAgLTMyMCw2
ICszMjAsMzQgQEAgc3RhdGljIHVuc2lnbmVkIGxvbmcgcGNwdV9ibG9ja19vZmZfdG9fb2ZmKGlu
dCBpbmRleCwNCj4gaW50IG9mZikNCj4gIAlyZXR1cm4gaW5kZXggKiBQQ1BVX0JJVE1BUF9CTE9D
S19CSVRTICsgb2ZmOyAgfQ0KPiANCj4gKy8qDQo+ICsgKiBwY3B1X25leHRfaGludCAtIGRldGVy
bWluZSB3aGljaCBoaW50IHRvIHVzZQ0KPiArICogQGJsb2NrOiBibG9jayBvZiBpbnRlcmVzdA0K
PiArICogQGFsbG9jX2JpdHM6IHNpemUgb2YgYWxsb2NhdGlvbg0KPiArICoNCj4gKyAqIFRoaXMg
ZGV0ZXJtaW5lcyBpZiB3ZSBzaG91bGQgc2NhbiBiYXNlZCBvbiB0aGUgc2Nhbl9oaW50IG9yIGZp
cnN0X2ZyZWUuDQo+ICsgKiBJbiBnZW5lcmFsLCB3ZSB3YW50IHRvIHNjYW4gZnJvbSBmaXJzdF9m
cmVlIHRvIGZ1bGZpbGwgYWxsb2NhdGlvbnMNCj4gK2J5DQo+ICsgKiBmaXJzdCBmaXQuICBIb3dl
dmVyLCBpZiB3ZSBrbm93IGEgc2Nhbl9oaW50IGF0IHBvc2l0aW9uDQo+ICtzY2FuX2hpbnRfc3Rh
cnQNCj4gKyAqIGNhbm5vdCBmdWxmaWxsIGFuIGFsbG9jYXRpb24sIHdlIGNhbiBiZWdpbiBzY2Fu
bmluZyBmcm9tIHRoZXJlDQo+ICtrbm93aW5nDQo+ICsgKiB0aGUgY29udGlnX2hpbnQgd2lsbCBi
ZSBvdXIgZmFsbGJhY2suDQo+ICsgKi8NCj4gK3N0YXRpYyBpbnQgcGNwdV9uZXh0X2hpbnQoc3Ry
dWN0IHBjcHVfYmxvY2tfbWQgKmJsb2NrLCBpbnQgYWxsb2NfYml0cykNCj4gK3sNCj4gKwkvKg0K
PiArCSAqIFRoZSB0aHJlZSBjb25kaXRpb25zIGJlbG93IGRldGVybWluZSBpZiB3ZSBjYW4gc2tp
cCBwYXN0IHRoZQ0KPiArCSAqIHNjYW5faGludC4gIEZpcnN0LCBkb2VzIHRoZSBzY2FuIGhpbnQg
ZXhpc3QuICBTZWNvbmQsIGlzIHRoZQ0KPiArCSAqIGNvbnRpZ19oaW50IGFmdGVyIHRoZSBzY2Fu
X2hpbnQgKHBvc3NpYmx5IG5vdCB0cnVlIGlmZg0KPiArCSAqIGNvbnRpZ19oaW50ID09IHNjYW5f
aGludCkuICBUaGlyZCwgaXMgdGhlIGFsbG9jYXRpb24gcmVxdWVzdA0KPiArCSAqIGxhcmdlciB0
aGFuIHRoZSBzY2FuX2hpbnQuDQo+ICsJICovDQo+ICsJaWYgKGJsb2NrLT5zY2FuX2hpbnQgJiYN
Cj4gKwkgICAgYmxvY2stPmNvbnRpZ19oaW50X3N0YXJ0ID4gYmxvY2stPnNjYW5faGludF9zdGFy
dCAmJg0KPiArCSAgICBhbGxvY19iaXRzID4gYmxvY2stPnNjYW5faGludCkNCj4gKwkJcmV0dXJu
IGJsb2NrLT5zY2FuX2hpbnRfc3RhcnQgKyBibG9jay0+c2Nhbl9oaW50Ow0KPiArDQo+ICsJcmV0
dXJuIGJsb2NrLT5maXJzdF9mcmVlOw0KPiArfQ0KPiArDQo+ICAvKioNCj4gICAqIHBjcHVfbmV4
dF9tZF9mcmVlX3JlZ2lvbiAtIGZpbmRzIHRoZSBuZXh0IGhpbnQgZnJlZSBhcmVhDQo+ICAgKiBA
Y2h1bms6IGNodW5rIG9mIGludGVyZXN0DQo+IEBAIC00MTUsOSArNDQzLDExIEBAIHN0YXRpYyB2
b2lkIHBjcHVfbmV4dF9maXRfcmVnaW9uKHN0cnVjdCBwY3B1X2NodW5rDQo+ICpjaHVuaywgaW50
IGFsbG9jX2JpdHMsDQo+ICAJCWlmIChibG9jay0+Y29udGlnX2hpbnQgJiYNCj4gIAkJICAgIGJs
b2NrLT5jb250aWdfaGludF9zdGFydCA+PSBibG9ja19vZmYgJiYNCj4gIAkJICAgIGJsb2NrLT5j
b250aWdfaGludCA+PSAqYml0cyArIGFsbG9jX2JpdHMpIHsNCj4gKwkJCWludCBzdGFydCA9IHBj
cHVfbmV4dF9oaW50KGJsb2NrLCBhbGxvY19iaXRzKTsNCj4gKw0KPiAgCQkJKmJpdHMgKz0gYWxs
b2NfYml0cyArIGJsb2NrLT5jb250aWdfaGludF9zdGFydCAtDQo+IC0JCQkJIGJsb2NrLT5maXJz
dF9mcmVlOw0KPiAtCQkJKmJpdF9vZmYgPSBwY3B1X2Jsb2NrX29mZl90b19vZmYoaSwgYmxvY2st
PmZpcnN0X2ZyZWUpOw0KPiArCQkJCSBzdGFydDsNCg0KVGhpcyBtaWdodCBub3QgcmVsZXZhbnQg
dG8gdGhpcyBwYXRjaC4NCk5vdCBzdXJlIGl0IGlzIGludGVuZGVkIG9yIG5vdC4NCkZvciBgYWxs
b2NfYml0cyArIGJsb2NrLT5jb250aWdfaGlua19zdGFydCAtIFtibG9jay0+Zmlyc3RfZnJlZSBv
ciBzdGFydF1gDQpJZiB0aGUgcmVhc29uIGlzIHRvIGxldCBwY3B1X2lzX3BvcHVsYXRlZCByZXR1
cm4gYSBwcm9wZXIgbmV4dF9vZmYgd2hlbiBwY3B1X2lzX3BvcHVsYXRlZA0KZmFpbCwgaXQgbWFr
ZXMgc2Vuc2UuIElmIG5vdCwgd2h5IG5vdCBqdXN0IHVzZSAqYml0cyArPSBhbGxvY19iaXRzLg0K
DQo+ICsJCQkqYml0X29mZiA9IHBjcHVfYmxvY2tfb2ZmX3RvX29mZihpLCBzdGFydCk7DQo+ICAJ
CQlyZXR1cm47DQo+ICAJCX0NCj4gIAkJLyogcmVzZXQgdG8gc2F0aXNmeSB0aGUgc2Vjb25kIHBy
ZWRpY2F0ZSBhYm92ZSAqLyBAQCAtNjMyLDEyDQo+ICs2NjIsNTcgQEAgc3RhdGljIHZvaWQgcGNw
dV9ibG9ja191cGRhdGUoc3RydWN0IHBjcHVfYmxvY2tfbWQgKmJsb2NrLCBpbnQNCj4gc3RhcnQs
IGludCBlbmQpDQo+ICAJCWJsb2NrLT5yaWdodF9mcmVlID0gY29udGlnOw0KPiANCj4gIAlpZiAo
Y29udGlnID4gYmxvY2stPmNvbnRpZ19oaW50KSB7DQo+ICsJCS8qIHByb21vdGUgdGhlIG9sZCBj
b250aWdfaGludCB0byBiZSB0aGUgbmV3IHNjYW5faGludCAqLw0KPiArCQlpZiAoc3RhcnQgPiBi
bG9jay0+Y29udGlnX2hpbnRfc3RhcnQpIHsNCj4gKwkJCWlmIChibG9jay0+Y29udGlnX2hpbnQg
PiBibG9jay0+c2Nhbl9oaW50KSB7DQo+ICsJCQkJYmxvY2stPnNjYW5faGludF9zdGFydCA9DQo+
ICsJCQkJCWJsb2NrLT5jb250aWdfaGludF9zdGFydDsNCj4gKwkJCQlibG9jay0+c2Nhbl9oaW50
ID0gYmxvY2stPmNvbnRpZ19oaW50Ow0KPiArCQkJfSBlbHNlIGlmIChzdGFydCA8IGJsb2NrLT5z
Y2FuX2hpbnRfc3RhcnQpIHsNCj4gKwkJCQkvKg0KPiArCQkJCSAqIFRoZSBvbGQgY29udGlnX2hp
bnQgPT0gc2Nhbl9oaW50LiAgQnV0LCB0aGUNCj4gKwkJCQkgKiBuZXcgY29udGlnIGlzIGxhcmdl
ciBzbyBob2xkIHRoZSBpbnZhcmlhbnQNCj4gKwkJCQkgKiBzY2FuX2hpbnRfc3RhcnQgPCBjb250
aWdfaGludF9zdGFydC4NCj4gKwkJCQkgKi8NCj4gKwkJCQlibG9jay0+c2Nhbl9oaW50ID0gMDsN
Cj4gKwkJCX0NCj4gKwkJfSBlbHNlIHsNCj4gKwkJCWJsb2NrLT5zY2FuX2hpbnQgPSAwOw0KPiAr
CQl9DQo+ICAJCWJsb2NrLT5jb250aWdfaGludF9zdGFydCA9IHN0YXJ0Ow0KPiAgCQlibG9jay0+
Y29udGlnX2hpbnQgPSBjb250aWc7DQo+IC0JfSBlbHNlIGlmIChibG9jay0+Y29udGlnX2hpbnRf
c3RhcnQgJiYgY29udGlnID09IGJsb2NrLT5jb250aWdfaGludCAmJg0KPiAtCQkgICAoIXN0YXJ0
IHx8IF9fZmZzKHN0YXJ0KSA+IF9fZmZzKGJsb2NrLT5jb250aWdfaGludF9zdGFydCkpKSB7DQo+
IC0JCS8qIHVzZSB0aGUgc3RhcnQgd2l0aCB0aGUgYmVzdCBhbGlnbm1lbnQgKi8NCj4gLQkJYmxv
Y2stPmNvbnRpZ19oaW50X3N0YXJ0ID0gc3RhcnQ7DQo+ICsJfSBlbHNlIGlmIChjb250aWcgPT0g
YmxvY2stPmNvbnRpZ19oaW50KSB7DQo+ICsJCWlmIChibG9jay0+Y29udGlnX2hpbnRfc3RhcnQg
JiYNCj4gKwkJICAgICghc3RhcnQgfHwNCj4gKwkJICAgICBfX2ZmcyhzdGFydCkgPiBfX2Zmcyhi
bG9jay0+Y29udGlnX2hpbnRfc3RhcnQpKSkgew0KPiArCQkJLyogc3RhcnQgaGFzIGEgYmV0dGVy
IGFsaWdubWVudCBzbyB1c2UgaXQgKi8NCj4gKwkJCWJsb2NrLT5jb250aWdfaGludF9zdGFydCA9
IHN0YXJ0Ow0KPiArCQkJaWYgKHN0YXJ0IDwgYmxvY2stPnNjYW5faGludF9zdGFydCAmJg0KPiAr
CQkJICAgIGJsb2NrLT5jb250aWdfaGludCA+IGJsb2NrLT5zY2FuX2hpbnQpDQo+ICsJCQkJYmxv
Y2stPnNjYW5faGludCA9IDA7DQo+ICsJCX0gZWxzZSBpZiAoc3RhcnQgPiBibG9jay0+c2Nhbl9o
aW50X3N0YXJ0IHx8DQo+ICsJCQkgICBibG9jay0+Y29udGlnX2hpbnQgPiBibG9jay0+c2Nhbl9o
aW50KSB7DQo+ICsJCQkvKg0KPiArCQkJICogS25vd2luZyBjb250aWcgPT0gY29udGlnX2hpbnQs
IHVwZGF0ZSB0aGUgc2Nhbl9oaW50DQo+ICsJCQkgKiBpZiBpdCBpcyBmYXJ0aGVyIHRoYW4gb3Ig
bGFyZ2VyIHRoYW4gdGhlIGN1cnJlbnQNCj4gKwkJCSAqIHNjYW5faGludC4NCj4gKwkJCSAqLw0K
PiArCQkJYmxvY2stPnNjYW5faGludF9zdGFydCA9IHN0YXJ0Ow0KPiArCQkJYmxvY2stPnNjYW5f
aGludCA9IGNvbnRpZzsNCj4gKwkJfQ0KPiArCX0gZWxzZSB7DQo+ICsJCS8qDQo+ICsJCSAqIFRo
ZSByZWdpb24gaXMgc21hbGxlciB0aGFuIHRoZSBjb250aWdfaGludC4gIFNvIG9ubHkgdXBkYXRl
DQo+ICsJCSAqIHRoZSBzY2FuX2hpbnQgaWYgaXQgaXMgbGFyZ2VyIHRoYW4gb3IgZXF1YWwgYW5k
IGZhcnRoZXIgdGhhbg0KPiArCQkgKiB0aGUgY3VycmVudCBzY2FuX2hpbnQuDQo+ICsJCSAqLw0K
PiArCQlpZiAoKHN0YXJ0IDwgYmxvY2stPmNvbnRpZ19oaW50X3N0YXJ0ICYmDQo+ICsJCSAgICAg
KGNvbnRpZyA+IGJsb2NrLT5zY2FuX2hpbnQgfHwNCj4gKwkJICAgICAgKGNvbnRpZyA9PSBibG9j
ay0+c2Nhbl9oaW50ICYmDQo+ICsJCSAgICAgICBzdGFydCA+IGJsb2NrLT5zY2FuX2hpbnRfc3Rh
cnQpKSkpIHsNCj4gKwkJCWJsb2NrLT5zY2FuX2hpbnRfc3RhcnQgPSBzdGFydDsNCj4gKwkJCWJs
b2NrLT5zY2FuX2hpbnQgPSBjb250aWc7DQo+ICsJCX0NCj4gIAl9DQo+ICB9DQo+IA0KPiBAQCAt
NjU2LDcgKzczMSw3IEBAIHN0YXRpYyB2b2lkIHBjcHVfYmxvY2tfcmVmcmVzaF9oaW50KHN0cnVj
dA0KPiBwY3B1X2NodW5rICpjaHVuaywgaW50IGluZGV4KQ0KPiAgCWludCBycywgcmU7CS8qIHJl
Z2lvbiBzdGFydCwgcmVnaW9uIGVuZCAqLw0KPiANCj4gIAkvKiBjbGVhciBoaW50cyAqLw0KPiAt
CWJsb2NrLT5jb250aWdfaGludCA9IDA7DQo+ICsJYmxvY2stPmNvbnRpZ19oaW50ID0gYmxvY2st
PnNjYW5faGludCA9IDA7DQo+ICAJYmxvY2stPmxlZnRfZnJlZSA9IGJsb2NrLT5yaWdodF9mcmVl
ID0gMDsNCj4gDQo+ICAJLyogaXRlcmF0ZSBvdmVyIGZyZWUgYXJlYXMgYW5kIHVwZGF0ZSB0aGUg
Y29udGlnIGhpbnRzICovIEBAIC03MTMsNg0KPiArNzg4LDEyIEBAIHN0YXRpYyB2b2lkIHBjcHVf
YmxvY2tfdXBkYXRlX2hpbnRfYWxsb2Moc3RydWN0IHBjcHVfY2h1bmsNCj4gKmNodW5rLCBpbnQg
Yml0X29mZiwNCj4gIAkJCQkJUENQVV9CSVRNQVBfQkxPQ0tfQklUUywNCj4gIAkJCQkJc19vZmYg
KyBiaXRzKTsNCj4gDQo+ICsJaWYgKHBjcHVfcmVnaW9uX292ZXJsYXAoc19ibG9jay0+c2Nhbl9o
aW50X3N0YXJ0LA0KPiArCQkJCXNfYmxvY2stPnNjYW5faGludF9zdGFydCArIHNfYmxvY2stPnNj
YW5faGludCwNCj4gKwkJCQlzX29mZiwNCj4gKwkJCQlzX29mZiArIGJpdHMpKQ0KPiArCQlzX2Js
b2NrLT5zY2FuX2hpbnQgPSAwOw0KPiArDQo+ICAJaWYgKHBjcHVfcmVnaW9uX292ZXJsYXAoc19i
bG9jay0+Y29udGlnX2hpbnRfc3RhcnQsDQo+ICAJCQkJc19ibG9jay0+Y29udGlnX2hpbnRfc3Rh
cnQgKw0KPiAgCQkJCXNfYmxvY2stPmNvbnRpZ19oaW50LA0KPiBAQCAtNzQ5LDYgKzgzMCw5IEBA
IHN0YXRpYyB2b2lkIHBjcHVfYmxvY2tfdXBkYXRlX2hpbnRfYWxsb2Moc3RydWN0DQo+IHBjcHVf
Y2h1bmsgKmNodW5rLCBpbnQgYml0X29mZiwNCj4gIAkJCS8qIHJlc2V0IHRoZSBibG9jayAqLw0K
PiAgCQkJZV9ibG9jaysrOw0KPiAgCQl9IGVsc2Ugew0KPiArCQkJaWYgKGVfb2ZmID4gZV9ibG9j
ay0+c2Nhbl9oaW50X3N0YXJ0KQ0KPiArCQkJCWVfYmxvY2stPnNjYW5faGludCA9IDA7DQo+ICsN
Cj4gIAkJCWlmIChlX29mZiA+IGVfYmxvY2stPmNvbnRpZ19oaW50X3N0YXJ0KSB7DQo+ICAJCQkJ
LyogY29udGlnIGhpbnQgaXMgYnJva2VuIC0gc2NhbiB0byBmaXggaXQgKi8NCj4gIAkJCQlwY3B1
X2Jsb2NrX3JlZnJlc2hfaGludChjaHVuaywgZV9pbmRleCk7IEBAIC03NjMsNg0KPiArODQ3LDcg
QEAgc3RhdGljIHZvaWQgcGNwdV9ibG9ja191cGRhdGVfaGludF9hbGxvYyhzdHJ1Y3QgcGNwdV9j
aHVuaw0KPiAqY2h1bmssIGludCBiaXRfb2ZmLA0KPiAgCQkvKiB1cGRhdGUgaW4tYmV0d2VlbiBt
ZF9ibG9ja3MgKi8NCj4gIAkJbnJfZW1wdHlfcGFnZXMgKz0gKGVfaW5kZXggLSBzX2luZGV4IC0g
MSk7DQo+ICAJCWZvciAoYmxvY2sgPSBzX2Jsb2NrICsgMTsgYmxvY2sgPCBlX2Jsb2NrOyBibG9j
aysrKSB7DQo+ICsJCQlibG9jay0+c2Nhbl9oaW50ID0gMDsNCj4gIAkJCWJsb2NrLT5jb250aWdf
aGludCA9IDA7DQo+ICAJCQlibG9jay0+bGVmdF9mcmVlID0gMDsNCj4gIAkJCWJsb2NrLT5yaWdo
dF9mcmVlID0gMDsNCj4gQEAgLTg3Myw2ICs5NTgsNyBAQCBzdGF0aWMgdm9pZCBwY3B1X2Jsb2Nr
X3VwZGF0ZV9oaW50X2ZyZWUoc3RydWN0DQo+IHBjcHVfY2h1bmsgKmNodW5rLCBpbnQgYml0X29m
ZiwNCj4gIAkJbnJfZW1wdHlfcGFnZXMgKz0gKGVfaW5kZXggLSBzX2luZGV4IC0gMSk7DQo+ICAJ
CWZvciAoYmxvY2sgPSBzX2Jsb2NrICsgMTsgYmxvY2sgPCBlX2Jsb2NrOyBibG9jaysrKSB7DQo+
ICAJCQlibG9jay0+Zmlyc3RfZnJlZSA9IDA7DQo+ICsJCQlibG9jay0+c2Nhbl9oaW50ID0gMDsN
Cj4gIAkJCWJsb2NrLT5jb250aWdfaGludF9zdGFydCA9IDA7DQo+ICAJCQlibG9jay0+Y29udGln
X2hpbnQgPSBQQ1BVX0JJVE1BUF9CTE9DS19CSVRTOw0KPiAgCQkJYmxvY2stPmxlZnRfZnJlZSA9
IFBDUFVfQklUTUFQX0JMT0NLX0JJVFM7IEBAIC0xMDg0LDYNCj4gKzExNzAsNyBAQCBzdGF0aWMg
dm9pZCBwY3B1X2luaXRfbWRfYmxvY2tzKHN0cnVjdCBwY3B1X2NodW5rICpjaHVuaykNCj4gIAlm
b3IgKG1kX2Jsb2NrID0gY2h1bmstPm1kX2Jsb2NrczsNCj4gIAkgICAgIG1kX2Jsb2NrICE9IGNo
dW5rLT5tZF9ibG9ja3MgKyBwY3B1X2NodW5rX25yX2Jsb2NrcyhjaHVuayk7DQo+ICAJICAgICBt
ZF9ibG9jaysrKSB7DQo+ICsJCW1kX2Jsb2NrLT5zY2FuX2hpbnQgPSAwOw0KPiAgCQltZF9ibG9j
ay0+Y29udGlnX2hpbnQgPSBQQ1BVX0JJVE1BUF9CTE9DS19CSVRTOw0KPiAgCQltZF9ibG9jay0+
bGVmdF9mcmVlID0gUENQVV9CSVRNQVBfQkxPQ0tfQklUUzsNCj4gIAkJbWRfYmxvY2stPnJpZ2h0
X2ZyZWUgPSBQQ1BVX0JJVE1BUF9CTE9DS19CSVRTOw0KDQpSZXZpZXdlZC1ieTogUGVuZyBGYW4g
PHBlbmcuZmFuQG54cC5jb20+DQoNCj4gLS0NCj4gMi4xNy4xDQoNCg==

