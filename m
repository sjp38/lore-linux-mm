Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE125C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 01:31:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0CD620675
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 01:31:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="eDufUeoD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0CD620675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4050F8E0003; Mon,  4 Mar 2019 20:31:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B4F48E0001; Mon,  4 Mar 2019 20:31:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 230C88E0003; Mon,  4 Mar 2019 20:31:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D192E8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 20:31:49 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id g197so7443705pfb.15
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 17:31:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=bQ0sZKuOdUJl5ZUGg1HcGw8V9oJ2L81R+WQTf7BCO8I=;
        b=PbRla3D1uMB+4n6cA3eeqj1l7WqAUNXcfCAjjxa9r6XHQRK/NOjdX+6GQ+iQoyhgGE
         oAuDNo5pdmk975Xt0YtTtzS9GsBtxoE4aNfBCEVOuCch2sBds18GhMQ/BJVhO7sSMfAC
         7+70uZkPDX+JARk3QU/exWyJZA5msnvr9uJz51vq4hSIj1I1LJqbx+cY1/n0WtQL427e
         S3KRVK2imoV27fcEQwphlLMkcBgTeAqwrztMrzc1RzEo0qsx7E/LS4Si7wRbW+UILcIO
         rITosG69UPMB4Apnha+lxiYlLYRMnjUl1GmCPd/Dg+Mml0iwWxgkTEqLKj+Z/wuPhdhA
         OzLg==
X-Gm-Message-State: APjAAAWG6KlR9IMBxXXrvoo5jDiiDo9dpdNtN/HR3V1eQYsMqCRQdUdF
	C1y8Bf4m6mIXQEi1SGHlsKuz5YquCGwW1zFV7+0tKdpXbzrrrhxpQwZ5FUiQ6jVJt+IyKSdKfTl
	7QjWGgjty7arTD5GkVwvH0LJ7S226NLmX9MAfwL5I24yBZKFDyXb4C8CRPq16BlRhew==
X-Received: by 2002:a63:702:: with SMTP id 2mr21360605pgh.14.1551749509020;
        Mon, 04 Mar 2019 17:31:49 -0800 (PST)
X-Google-Smtp-Source: APXvYqwQNWx0BwsqghD545y+LHMFBJCwnYTXn/pTBrCrFNh3/iA19xwlUtWakZqOYu6aKD73Ciaq
X-Received: by 2002:a63:702:: with SMTP id 2mr21360517pgh.14.1551749507878;
        Mon, 04 Mar 2019 17:31:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551749507; cv=none;
        d=google.com; s=arc-20160816;
        b=ZtUQEmtI6tjMGukSMjK3q0UD54QhWEwZ9bZJvuXu1LXpIHvzDUuprUKeriHZeEzbmU
         PkAN+fkfQU/v1Pe2OJD6Hymd+fkiD8mlESIoviyuEPzALJWKdjNtvrxTNh+ixlL4KKCt
         YkcaE4ySJ83h2UK+vHnwY7tHL6Lh2orPPKzhsrQt9d8pFPr2/4AzMefM68S2tu8mJqKv
         lWYbmQ7CXbXnjTHue8HUO5zIcTEX7qqQtKBm6J2oBaVnwYd12k+9oB3/WDX2cMDcZBa3
         cDuReSmYXN1eBjutTy0wbXKg3dy1anTXFKDSSP22MhR7/4xk11evZUaX54vfB/NjxUav
         o0qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=bQ0sZKuOdUJl5ZUGg1HcGw8V9oJ2L81R+WQTf7BCO8I=;
        b=rRXYjjX+FLCirlJ4w2UgyAsIKrVfjdMEuBLh3K67YPD4c4Ipi2NMAdBL1NknmTjhz+
         1RdlBT0Jtxj3PZDMINzqeXpXq0U5z3hrsCNdtsEUU+GNaLrnT3TcP5h2F7ksQWvP+Vzg
         TtRF+hROKpzgrYi2H1+OcbMa6xiYN4NyvDI37M/vxaPQ3UEV02yY5RvnA+BpYVgrsYSu
         4U6xuEezVDt8aogiBXT9/+TS1TeN2467LruSnS8NEefCH5fMGk4qr09aQ4rmMl268irF
         1VMVnTIEnnPWqMPX9PNGmgxWji62UoJYYDaCj3FxBoJIHb5iNMBAxXja9kUl7yCgGHgB
         ujEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=eDufUeoD;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.4.83 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40083.outbound.protection.outlook.com. [40.107.4.83])
        by mx.google.com with ESMTPS id u18si6756770pgn.590.2019.03.04.17.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Mar 2019 17:31:47 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.4.83 as permitted sender) client-ip=40.107.4.83;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=eDufUeoD;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.4.83 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=bQ0sZKuOdUJl5ZUGg1HcGw8V9oJ2L81R+WQTf7BCO8I=;
 b=eDufUeoDsjefvXn3chRprrtkXpcPmYmHKf6fe8GIgcskjzG8aYrrinK8b2/NjzfoqDheMpPW3hYum1CBJQ23a8ErGsBY9L3Lfla10ARfq6BIlPjfKLef4G+GYIw/hcIS90vWFm6pJyM5tw0gW8er5azlL9Xx02msjlPY0JIx3VY=
Received: from DB7PR04MB4490.eurprd04.prod.outlook.com (52.135.138.16) by
 DB7PR04MB3964.eurprd04.prod.outlook.com (52.134.107.13) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.19; Tue, 5 Mar 2019 01:31:43 +0000
Received: from DB7PR04MB4490.eurprd04.prod.outlook.com
 ([fe80::cda3:5f5:6a0:df0e]) by DB7PR04MB4490.eurprd04.prod.outlook.com
 ([fe80::cda3:5f5:6a0:df0e%5]) with mapi id 15.20.1665.020; Tue, 5 Mar 2019
 01:31:43 +0000
From: Peng Fan <peng.fan@nxp.com>
To: "dennis@kernel.org" <dennis@kernel.org>
CC: "tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "van.freenix@gmail.com"
	<van.freenix@gmail.com>
Subject: RE: [PATCH 2/2] percpu: pcpu_next_md_free_region: inclusive check for
 PCPU_BITMAP_BLOCK_BITS
Thread-Topic: [PATCH 2/2] percpu: pcpu_next_md_free_region: inclusive check
 for PCPU_BITMAP_BLOCK_BITS
Thread-Index: AQHU0nXEG16tPwZG4EKC+VpW/1eoj6X70ymAgABtc+A=
Date: Tue, 5 Mar 2019 01:31:43 +0000
Message-ID:
 <DB7PR04MB4490859B718948F4AABCEBE788720@DB7PR04MB4490.eurprd04.prod.outlook.com>
References: <20190304104541.25745-1-peng.fan@nxp.com>
 <20190304104541.25745-2-peng.fan@nxp.com>
 <20190304185657.GA17970@dennisz-mbp.dhcp.thefacebook.com>
In-Reply-To: <20190304185657.GA17970@dennisz-mbp.dhcp.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [92.121.36.198]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 17ff188f-22e2-4729-8f55-08d6a10a52f0
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:DB7PR04MB3964;
x-ms-traffictypediagnostic: DB7PR04MB3964:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtEQjdQUjA0TUIzOTY0OzIzOkFIVTBxM1NtcHR6aWx6Qk9vWkVhNWRNZHEv?=
 =?gb2312?B?TE1Ic0tPZndFZitTNXNqMllJUFdFQnZWUEdQWHFpZ2FSdUs1TWRWSGwzUERi?=
 =?gb2312?B?N25lSUhMUTlIY00rUjcxUFBxdmo3RmZrQmVJcERTdGErZWRWcElWU0xMTkRY?=
 =?gb2312?B?OTM1QTFVSEE1UkY5S25vL2R3d3lNUFE0WHhKa0RXSUpCck0vK1AzenIzdjl4?=
 =?gb2312?B?U1VhYWRranlNaEkxY1hPT09YSnA4L05zUENPT25qQ3BlNUU3M3hoSnQ3Rlc4?=
 =?gb2312?B?ODJLODhpS2RlYW9oSmkyWkhtZ1MxSmNNd29OZ0huWkdTNTZIY0NkZ1A0YnZH?=
 =?gb2312?B?QWxtbEx4ZXRud2VjMmN2SGJkYzFHdGNWZnhTUzNBdVJmRXp3cmh1ZVBRbjJr?=
 =?gb2312?B?cmZ1UnNtS0k0OVRUMXB3Z3E0M3EvUFRsd0RBMDZzR0JOODJnY0dDVHpGQ0FB?=
 =?gb2312?B?anRBcEkwUkdMendCMVIzYzdzUzMxSWMzNmwwUDg5NkxnNEVpQk5Ka2l3cHlM?=
 =?gb2312?B?OG9SWFNXaGc4Mm01MkdLQ0VRUXlHUnJIb2JOb3pQeXY5UGo5WUZ4aFl0akM3?=
 =?gb2312?B?MS9pMnhTZUhRZkN0dVZMMmMzQ01TckpsV04waDlvMzNSM2NvT1kyOWQ1YXVI?=
 =?gb2312?B?b2NmSE1jbUUxWm5TNTBsb3FHN3ZlNTBYQXdmQzRVTkVXWXlDakdLVmRld2Qw?=
 =?gb2312?B?ZDMzU1B1ZUtRcXpWUUNDUS9LM2lHczdZczBNUDJXVFBLYS9WaUtQaUtpSWVT?=
 =?gb2312?B?MktQSU5ueXdIdXF4NzVNa1ZhSDAzdzlVbWFZd3VnWHFNVUhLSEI5U2pKRVlh?=
 =?gb2312?B?U2M5dXFjSlBIWjFWSkdwelIydVVLTmVIWnZtRENpUTNKVTJWeTJHNkVrNXdW?=
 =?gb2312?B?ZTAwMXBiVTAvbVY0eGREcGlDd1BRVS9qYi85RUM4SmFYZHlxZThvY09QVVpG?=
 =?gb2312?B?WWFQN0RONDFZZ1ptUVlJNmR0eHpObDJ6c1hpY3ZIY2UxOHpxQ2tCRDdUMjNY?=
 =?gb2312?B?K0xYVHJTVk1HbUVZclRxZ3dobTkzZUJxUmFsQzNyclhzR3BRNFF0enFzc1JX?=
 =?gb2312?B?d3BaeDdwUHRCMDRnZFMzOTZQMjZMbUdkVkx0SWxHTWJUUmxHVUgreDZQblNi?=
 =?gb2312?B?WG8rNzYxTmZ0ZGFialNIYXcrenVGM3lCcENoUEpZa1BCbHQrTXVnV1k1RXB3?=
 =?gb2312?B?Wjd6V2JKdUt5bWh0QmhQc3ZBZ0VjTERMQ1hZZWs3V0EyLzN4ODZRbFQvbUNs?=
 =?gb2312?B?UzJBY3RpWTVER2xnbDNDNVJZRk1rU2RTbUZDeC94RC9jdEExZURuQ2hRUmts?=
 =?gb2312?B?VlQzM2FOVnplZDU0U2lhYU9uZlpuVEx4UVZrYUU5REZ0RWtmMTJDeFNKUVFk?=
 =?gb2312?B?YjMzVXZHcHFBQTg2UGdNNnJHRWNuSFg3b3FyOG5jMDY5dWpaUWhVeE9yMFhY?=
 =?gb2312?B?YVQzZjhIY2hVYnoyY1pOa3ZwKytqVFFsY09nUFFVeGJRR2FVNVF0emdoQnlI?=
 =?gb2312?B?ZXNFdy9pRDVIbW1ScVZyc0xTOEdrbHFheTBMVjU2czVVNFdGNkJSeERwMEFH?=
 =?gb2312?B?bFhYK21UOTBqK1BKM3A0OUR6U09kOFBlVXFsNWkrZzJUcXJWMzQvVFRYNDZk?=
 =?gb2312?B?aW12aXZ5YXpXbFMwdU1lYlNpOVZsUzV5c3FqNVgxR3dYS0F3VmJMdHY2NTdI?=
 =?gb2312?B?a0puQWVZc2JZbGlnck01QXBQYXg3K1daK1M0TUhLb3pabit2Wk00L2RuaHVw?=
 =?gb2312?B?UVFLY0lnOXlGNXJzYmNBYVR0RVNPazNrWmhHZlIvT09PeEExeXF1RDgvdnpU?=
 =?gb2312?B?MUp4a2NXVXdNM080OVpHcVowVEVIWjN6TUpsRW9KVmcvdE5zVVFKODNSVzYy?=
 =?gb2312?B?WndrVmUwU2poNDBONVUwbTJKQWtUbzlCKzk4NDN2QURKZ3JqWVJkRk5TbWt6?=
 =?gb2312?B?bjlZbmtuSTlQS0p6VVpEejM3djgyWUZMakNUbS9obWZ5V2czRlBoVHpjaTda?=
 =?gb2312?Q?yEDOh8?=
x-microsoft-antispam-prvs:
 <DB7PR04MB39642908F7B0944914D8D5DB88720@DB7PR04MB3964.eurprd04.prod.outlook.com>
x-forefront-prvs: 0967749BC1
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(39860400002)(396003)(346002)(376002)(199004)(189003)(13464003)(99286004)(14454004)(74316002)(52536013)(33656002)(316002)(7736002)(54906003)(305945005)(6916009)(6346003)(2906002)(26005)(186003)(6506007)(53546011)(102836004)(66066001)(966005)(7696005)(76176011)(4326008)(478600001)(45080400002)(97736004)(5660300002)(71190400001)(71200400001)(68736007)(55016002)(8936002)(8676002)(81156014)(81166006)(2351001)(25786009)(1730700003)(106356001)(105586002)(486006)(53936002)(6246003)(476003)(446003)(11346002)(6306002)(44832011)(256004)(9686003)(86362001)(14444005)(6436002)(2501003)(3846002)(5640700003)(6116002)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR04MB3964;H:DB7PR04MB4490.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 bY4DDJDm7m+gEBv/+XzmShazfv0nokFQRvEhLFtUdPWuiL9RqJWY1pJiniBN/TZgtEZXsoTfncSg6YFKXN0AfEe1cu8OQ+25aMqmpYzNlKAQO8HGtyxWvo2EE2eMWbKwUjwjubP+IdF+/L5zfaMW9QcCn8YeNYKWN6uKUs8iWShA4NrJFcEw2DF1xIg2Lebk+odk+UmnqwP1BdejdIkPl/6MzxRIdUcoQTDVdEa+CVf0n3n/bmbLgrN41ScMhbRE1eqTV2uUPHNGtGWi6KEeJvqm/CL6SnKydl60mJIkxI45V15rUbIiKfN4ZBIWvj0cHWxFkVoMQCNSRtiuMxDA5X3Uyu9Z+e8zioCsUPzPdQ6tCG/ORdK29FO5qCkASY1QYaYuzhvVJ8S0dwehVLXPUnVyhkOM7is6sX8ZnK/pxAE=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 17ff188f-22e2-4729-8f55-08d6a10a52f0
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Mar 2019 01:31:43.1164
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR04MB3964
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogZGVubmlzQGtlcm5lbC5v
cmcgW21haWx0bzpkZW5uaXNAa2VybmVsLm9yZ10NCj4gU2VudDogMjAxOcTqM9TCNcjVIDI6NTcN
Cj4gVG86IFBlbmcgRmFuIDxwZW5nLmZhbkBueHAuY29tPg0KPiBDYzogdGpAa2VybmVsLm9yZzsg
Y2xAbGludXguY29tOyBsaW51eC1tbUBrdmFjay5vcmc7DQo+IGxpbnV4LWtlcm5lbEB2Z2VyLmtl
cm5lbC5vcmc7IHZhbi5mcmVlbml4QGdtYWlsLmNvbQ0KPiBTdWJqZWN0OiBSZTogW1BBVENIIDIv
Ml0gcGVyY3B1OiBwY3B1X25leHRfbWRfZnJlZV9yZWdpb246IGluY2x1c2l2ZSBjaGVjaw0KPiBm
b3IgUENQVV9CSVRNQVBfQkxPQ0tfQklUUw0KPiANCj4gSGkgUGVuZywNCj4gDQo+IE9uIE1vbiwg
TWFyIDA0LCAyMDE5IGF0IDEwOjMzOjU1QU0gKzAwMDAsIFBlbmcgRmFuIHdyb3RlOg0KPiA+IElm
IHRoZSBibG9jayBbY29udGlnX2hpbnRfc3RhcnQsIGNvbnRpZ19oaW50X3N0YXJ0ICsgY29udGln
X2hpbnQpDQo+ID4gbWF0Y2hlcyBibG9jay0+cmlnaHRfZnJlZSBhcmVhLCBuZWVkIHVzZSAiPD0i
LCBub3QgIjwiLg0KPiA+DQo+ID4gU2lnbmVkLW9mZi1ieTogUGVuZyBGYW4gPHBlbmcuZmFuQG54
cC5jb20+DQo+ID4gLS0tDQo+ID4NCj4gPiBWMToNCj4gPiAgIEJhc2VkIG9uDQo+IGh0dHBzOi8v
ZW1lYTAxLnNhZmVsaW5rcy5wcm90ZWN0aW9uLm91dGxvb2suY29tLz91cmw9aHR0cHMlM0ElMkYl
MkZwYXRjDQo+IGh3b3JrLmtlcm5lbC5vcmclMkZjb3ZlciUyRjEwODMyNDU5JTJGJmFtcDtkYXRh
PTAyJTdDMDElN0NwZW5nLmYNCj4gYW4lNDBueHAuY29tJTdDNjU0NmRmY2M4NWYwNDkyZDdjNzUw
OGQ2YTBkMzMwNzYlN0M2ODZlYTFkM2JjMmINCj4gNGM2ZmE5MmNkOTljNWMzMDE2MzUlN0MwJTdD
MCU3QzYzNjg3MzIyNjI0MTE4NTUzNCZhbXA7c2RhdGE9OQ0KPiBhekl3OHZYSjhlcXFkMFQwem5t
RU42alIyY1doRmdoS0JmZzB6SUpNRE0lM0QmYW1wO3Jlc2VydmVkPTANCj4gYXBwbGllZCBsaW51
eC1uZXh0DQo+ID4gICBib290IHRlc3Qgb24gcWVtdSBhYXJjaDY0DQo+ID4NCj4gPiAgbW0vcGVy
Y3B1LmMgfCAzICsrLQ0KPiA+ICAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAxIGRl
bGV0aW9uKC0pDQo+ID4NCj4gPiBkaWZmIC0tZ2l0IGEvbW0vcGVyY3B1LmMgYi9tbS9wZXJjcHUu
YyBpbmRleA0KPiA+IDVlZTkwZmMzNGVhMy4uMGY5MWYxZDg4M2M2IDEwMDY0NA0KPiA+IC0tLSBh
L21tL3BlcmNwdS5jDQo+ID4gKysrIGIvbW0vcGVyY3B1LmMNCj4gPiBAQCAtMzkwLDcgKzM5MCw4
IEBAIHN0YXRpYyB2b2lkIHBjcHVfbmV4dF9tZF9mcmVlX3JlZ2lvbihzdHJ1Y3QNCj4gcGNwdV9j
aHVuayAqY2h1bmssIGludCAqYml0X29mZiwNCj4gPiAgCQkgKi8NCj4gPiAgCQkqYml0cyA9IGJs
b2NrLT5jb250aWdfaGludDsNCj4gPiAgCQlpZiAoKmJpdHMgJiYgYmxvY2stPmNvbnRpZ19oaW50
X3N0YXJ0ID49IGJsb2NrX29mZiAmJg0KPiA+IC0JCSAgICAqYml0cyArIGJsb2NrLT5jb250aWdf
aGludF9zdGFydCA8IFBDUFVfQklUTUFQX0JMT0NLX0JJVFMpDQo+IHsNCj4gPiArCQkgICAgKmJp
dHMgKyBibG9jay0+Y29udGlnX2hpbnRfc3RhcnQgPD0NCj4gPiArCQkgICAgUENQVV9CSVRNQVBf
QkxPQ0tfQklUUykgew0KPiA+ICAJCQkqYml0X29mZiA9IHBjcHVfYmxvY2tfb2ZmX3RvX29mZihp
LA0KPiA+ICAJCQkJCWJsb2NrLT5jb250aWdfaGludF9zdGFydCk7DQo+ID4gIAkJCXJldHVybjsN
Cj4gPiAtLQ0KPiA+IDIuMTYuNA0KPiA+DQo+IA0KPiBUaGlzIGlzIHdyb25nLiBUaGlzIGl0ZXJh
dG9yIGlzIGZvciB1cGRhdGluZyBjb250aWcgaGludHMgYW5kIG5vdCBmb3INCj4gZmluZGluZyBm
aXQuDQoNCkkgbWlzc2VkIHRvIGNvbnNpZGVyIHRoZSBjYXNlIHRoZSB3aGVuIGNvbnRpZ19oaW50
X3N0YXJ0IG1hdGNoZXMNCnJpZ2h0X2ZyZWUgYXJlYSwgdGhlIHJpZ2h0X2ZyZWUgYXJlYSB3aWxs
IGJlIHRha2UgaW50byBjb25zaWRlcmF0aW9uDQppbnRvIG5leHQgbG9vcC4NCg0KPiANCj4gSGF2
ZSB5b3UgdHJpZWQgcmVwcm9kdWNpbmcgYW5kIHByb3ZpbmcgdGhlIGlzc3VlIHlvdSBhcmUgc2Vl
aW5nPyBJbg0KPiBnZW5lcmFsLCBtYWtpbmcgY2hhbmdlcyB0byBwZXJjcHUgY2FycmllcyBhIGxv
dCBvZiByaXNrLiBJIHJlYWxseSBvbmx5DQo+IHdhbnQgdG8gYmUgdGFraW5nIGNvZGUgdGhhdCBp
cyBwcm92YWJseSBzb2x2aW5nIGEgcHJvYmxlbSBhbmQgbm90DQo+IHN1cHBvcnRlZCBieSBqdXN0
IGNvZGUgaW5zcGVjdGlvbi4gQm9vdCB0ZXN0aW5nIGZvciBhIGNoYW5nZSBsaWtlIHRoaXMNCj4g
aXMgcmVhbGx5IG5vdCBlbm91Z2ggYXMgd2UgbmVlZCB0byBiZSBzdXJlIGNoYW5nZXMgbGlrZSB0
aGVzZSBhcmUNCj4gY29ycmVjdC4NCg0KSSdsbCBiZSBjYXJlZnVsIGZvciBmdXR1cmUgcGF0Y2hl
cy4NCg0KVGhhbmtzLA0KUGVuZy4NCg0KPiANCj4gVGhhbmtzLA0KPiBEZW5uaXMNCg==

