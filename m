Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBC59C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 09:36:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D11D20823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 09:36:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="E44+Ob0e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D11D20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 042878E0003; Mon,  4 Mar 2019 04:36:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F35738E0001; Mon,  4 Mar 2019 04:36:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFDA58E0003; Mon,  4 Mar 2019 04:36:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 813F68E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 04:36:27 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id j5so2354682edt.17
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 01:36:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=IxqGEBC/jHcM5UK8xlYSwhTJjJZr+dZ2OFSTXCD3NMA=;
        b=Yz4xSIkfts7CCpuuB+dy2jJia85DQqwJmnt9nmkSBDgibb55oV+4uMZyCWgkJAq457
         EPfHVX1gHUUzz6TTsCynmmmQVEUFqoh+5XnOjv+LT6ILC9tIj1jdHiBX1fc8R8qlat5i
         YAPqWvgyji7ivJPoRiF4R1IzH++VmCE+iPpOj4A08NUK6dcQs177H1oBhCtThdtR3HzA
         w7hvVTGZ4LW6PaAcRPWjmf+a+VRwCT1bSO9AFcF+BC+wosBv2jpSgTSytT3RTSr90ih2
         mSicGEGE6RIVOqohPQ1B08LcUWonTlHNyf2CI00YlkoT60MBzNNTTn+5+Jz8TEjKjVPc
         ZCdA==
X-Gm-Message-State: APjAAAWVCV7TXc5qqtQCmb3inJIfJDmvMTIesDidZNg2W2AW1mgk8W9R
	tk5ZjLouBkDCoyiQFcIzitF0+mWFuC3o0eBq48FIbdZpSI9TKdv/MBioCm+1FoSFz4llql1EQ88
	NhTPkvEWY8zldfKC3seCQ7Y7VeudZnh07fya/0ZQ+Z08eX3LTTAbj+2mceiMnp+YCBw==
X-Received: by 2002:a17:906:a445:: with SMTP id cb5mr11878480ejb.72.1551692186968;
        Mon, 04 Mar 2019 01:36:26 -0800 (PST)
X-Google-Smtp-Source: APXvYqwJYS3irzvOFViJI4MzDRJQq/ITh26X4sOZEA3KMdsQyOYzpzXPB2rG7MJmrKTSRwXuAwsg
X-Received: by 2002:a17:906:a445:: with SMTP id cb5mr11878427ejb.72.1551692185806;
        Mon, 04 Mar 2019 01:36:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551692185; cv=none;
        d=google.com; s=arc-20160816;
        b=VptdRk+C9/Y4frT6hhuDnnTRgM4WCXkY/YWhG4wPJ6Xs1vjih/WNZYzVW9y58Ml8OE
         47eipsZqRTh0+Ur3GAyYM5Fvq0NjOYUG0wgZPaiBX9hvFas4IxAa8Ma7+6SEWXNYm3VM
         9U11dP6e5e8FNRLwE3kE5BY/K6BNHtkVu4/Ldry7Ci+WRVTM1A+5vA2cl5heM4vy6lUQ
         gvE7YvZs3XcRkJFvwuBk7NW8vzbz/oD4CXIQAmp30Vg+EGoeslsQnValdXNgiAyYaGzh
         JiLpWlbhTXgTFYv9sSXpS1MlGjkjvH91dQGCirz28L4fFjjiMfD6FEB7Mv2pXzuOYqPG
         RuoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=IxqGEBC/jHcM5UK8xlYSwhTJjJZr+dZ2OFSTXCD3NMA=;
        b=yZvGzNNvuL0qPyBxsIguNW0tRJYdSx5NKjPj/ZkR+JUZFsYkzK7FaV6cYwi7RcFREF
         /5QZ7RIVJz7Xk85FM2AjzKqu97G7I39D5o5id7lkkEpwjkoCUSYG6b4hAM4TH8xstgc5
         zJamTtiyaSujANDjUioV7t614FCWqkQIMHgDGbqWgRal+tFHa9Rs329W9EdGXlI3mQDe
         aQOmDrsP9U3rjOPmfInIZnnyEE8NN24p4GKKlVdvZYrT8bFqa5Dg1t/hCHIIVBHckM9Y
         7PvF22MAkDfoNlvnt53fDjkoFd+FtqD56mSNycu6k8q1F+FEmw92GIzzmNAWa83z/g/v
         0v6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=E44+Ob0e;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.13.79 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-eopbgr130079.outbound.protection.outlook.com. [40.107.13.79])
        by mx.google.com with ESMTPS id n21si37841eja.150.2019.03.04.01.36.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 01:36:25 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.13.79 as permitted sender) client-ip=40.107.13.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=E44+Ob0e;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.13.79 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=IxqGEBC/jHcM5UK8xlYSwhTJjJZr+dZ2OFSTXCD3NMA=;
 b=E44+Ob0ennR7caU21jkRQoeXwJXE0XrABhoQusg0qIy/CM8xQ9ogHS9CAuXOtdyaYJHvYpySz3rRXdQygMK89uLNrxRFzM6ccmG9GfBNz04tAm9RAvL+5PaMN3Ob0pybkXDEO6FSybxqN6Ffj7igBtZtnNEtiPeBq6ql5Mzl/xA=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB6276.eurprd04.prod.outlook.com (20.179.35.142) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.16; Mon, 4 Mar 2019 09:36:24 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Mon, 4 Mar 2019
 09:36:24 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>
CC: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Vlad Buslov
	<vladbu@mellanox.com>, "kernel-team@fb.com" <kernel-team@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 07/12] percpu: add block level scan_hint
Thread-Topic: [PATCH 07/12] percpu: add block level scan_hint
Thread-Index: AQHUzwv6lsqDgTFFmUKPJkiHnO4qFKX5ZeIAgAD57ICAAN1iIA==
Date: Mon, 4 Mar 2019 09:36:24 +0000
Message-ID:
 <AM0PR04MB44812F00CC6FA3DE09D8327688710@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-8-dennis@kernel.org>
 <AM0PR04MB44813651B653B5269C5C211D88700@AM0PR04MB4481.eurprd04.prod.outlook.com>
 <20190303202323.GB4868@dennisz-mbp.dhcp.thefacebook.com>
In-Reply-To: <20190303202323.GB4868@dennisz-mbp.dhcp.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [92.121.36.198]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c993d182-a495-420c-880b-08d6a084de2b
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB6276;
x-ms-traffictypediagnostic: AM0PR04MB6276:
x-microsoft-exchange-diagnostics:
 =?utf-8?B?MTtBTTBQUjA0TUI2Mjc2OzIzOmRXSlBJNlZ3d0VRdXhYSjNiNG1ZK2o5eWVW?=
 =?utf-8?B?SFdEY0FyZ3ZFMmJEWGUvcUpNdHFEZjU4dzQ2WmRwMEtFMlh2SG42MHhBbW1q?=
 =?utf-8?B?bkFOQ3BEVi9ORk5mUmIxZmtRczBBeDMzWEpMVXJ1UUlnNUVIclRFaityL2g2?=
 =?utf-8?B?dzlKU2loS1QvYlEzQUZKT2hodnVLQnhTREJVV3NvTDZvWkV2UTJUR04vSkc3?=
 =?utf-8?B?RnZzRWk3T2dOMGpucnNLaW8yeS9VZ0JzK2t4WXNrQ2FaOGVqVE5xSGozbjZt?=
 =?utf-8?B?c0pBTno5djNMVDg2Y0c3cS9HZ0dYeFI0Z2tFbUlheGdOQ2ROdUJwNHYyZTZL?=
 =?utf-8?B?aXVjMGZBZ1VKTE1vbVpuZWJ4M1poUlYyRTVRdFkvKzUxeDB2czQ4U2hGMmRy?=
 =?utf-8?B?VDdmTkFGY3FMUnlNUFJQUExJeE9CTlhvMXJ1ME1jMElkQ3BsUHBRcWhyK3hL?=
 =?utf-8?B?MWdDZDNRMVdVbzd3Uy9XTWZuVW00N3hZM2grZEhZWEhoUFB2YkZJSDFzbTdo?=
 =?utf-8?B?ei8wZ3VRbnZxZ0xCLzFVT0IxQ0J2aWNqeUJ3cVJSVVd5K09jaXFwZHVET0RO?=
 =?utf-8?B?YnJ1NGRVdmgwd3VaNkorSTRkNStBdnFERk9xTnJ5L1dtSkVUVzBNZHRjVENM?=
 =?utf-8?B?UUVMU0RWa05ycEZoRGpvTDVHZmYrdjdpTk52U1hhUWNQQmN5YjN1RWxRN0k3?=
 =?utf-8?B?Z1dyL1FFc1JMUE1KVjN6RDBlOUZVbnZwclNPRGdOblB3eW5qdmluQTNCaDYv?=
 =?utf-8?B?cTF1N1JEU0JidzFnNVVTa3JhWDJmb1VFRTh4QTZsVTBDV2pEbiswbXN6UmVP?=
 =?utf-8?B?NlBqMTFvenlXVXJuVTFSUEI4ZlNPY3dBa3NZcHk4Q0ZsaWJyODNLZnJETlhC?=
 =?utf-8?B?ZUdzeXl3blJSSU9GTzcrRWVwaFR4Z3cvTFYyVS9XMjVuNkJ0L0dScURiM1Zs?=
 =?utf-8?B?OFpPQ21pYWpoK3NmQlpiYlYwM0FVdzlNdUlnbEc2RllodWJaMFgyeEY3aDZy?=
 =?utf-8?B?TkFqSXFRZ1VzNWg3bGJpdEdSM0s1djlNOU10dnJ6TWNKL29JVlVNTDF3c0hw?=
 =?utf-8?B?bXV0VHpSVHZVaFhtZHE5cDUzdjVHdkJ0SWJkU2RFMU9HeDlxaXJYc2xKUGR6?=
 =?utf-8?B?OWYrKzJ5clc3d29rZktkeHAxbUl3ejVkNk9jMkZOQnY3K3huN0cyL3M0aGtP?=
 =?utf-8?B?cENod2liUUowNlVacmd3WDJWRTVSUjMydjAwNmp6NnZGRXNRUXdqZk1EVFJs?=
 =?utf-8?B?Q0Y5MVE4dEYvcU1iQXhXM0pra0x6OGtXV3VQNDhlZXN0dE9KQ2JGc0k1UnlF?=
 =?utf-8?B?bUllOUN6RDBqUVM0RHFhcEZVZjVKd2czNmx1NXAzeTdsNk1adGdqbEJIYWlS?=
 =?utf-8?B?NlAzc0ZvdW9TSHZtTVFqdlZydWpFdU1UTE1tSjI1eVVxYmxRckpmd0MzYTEr?=
 =?utf-8?B?NEZQL3ZDZk9WbCtkaXNJQVNlQzFkbjBIOStjaGtLN1JSbXd0WEl3cVRvZ2lU?=
 =?utf-8?B?ODlNQlNnVDE5WTFKN3FEZS9OWDVNYTB0bnk1eThWOE0xSXBPVlZFMUo1WW4y?=
 =?utf-8?B?MHd1WUF0SG5aWm9UbWl1YmFLUk5OVmpVeFRzaStjSWU1S1grYlRMRDNBekMv?=
 =?utf-8?B?ZWtTcTFTMFBJVzFPRGNRc2I4Njh0cElvMXJISXpWL0J5bEQ1d0l3Z2dURS82?=
 =?utf-8?B?ei9NV2MxL3UycWJqSlRlTVB1SlZLWEd1RENEdXgxTjdOSEQ5Q05SQjRwV1hX?=
 =?utf-8?Q?kKosbvLf4U2SImeCfccFTGthHIgKlo6v+wig8=3D?=
x-microsoft-antispam-prvs:
 <AM0PR04MB627622DA8A6C2E6B6AE102DB88710@AM0PR04MB6276.eurprd04.prod.outlook.com>
x-forefront-prvs: 09669DB681
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(396003)(39860400002)(376002)(346002)(189003)(199004)(13464003)(476003)(14454004)(486006)(8936002)(305945005)(7736002)(66066001)(74316002)(25786009)(33656002)(68736007)(2906002)(4326008)(44832011)(478600001)(6436002)(186003)(256004)(86362001)(9686003)(6506007)(55016002)(76176011)(14444005)(316002)(6116002)(97736004)(54906003)(106356001)(102836004)(53546011)(99286004)(6246003)(93886005)(8676002)(7696005)(6916009)(71190400001)(52536013)(71200400001)(81156014)(11346002)(5660300002)(446003)(105586002)(81166006)(53936002)(3846002)(26005)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB6276;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 40abuJX2gHuODeBV0o6rJbBLF4smJxXA8hFWwtb2qREUoK5PEJp/8unDpGaVjB5cFIOHVXe7eXY3Tt/IjJJu1WDbdxaPAlDDdHKxSKOxjnbAlV5beDKVV8TDDn4fEgkYo2gdngKlVcqFjr9QZpc9RLwEGKGgWzu8zlrs2qTkXHc5fpb2W+IK18PvkT6O9vs69l/COQ++oNp7KPrJlVK41Mt5GHrUcY0eVO7IzkJMNCsFHVdN3xTt6thaQjxC/0x8uHgrI75zrlYfy3d1mnKE0xz0a/Fko/jNqp2Dc5FnmdMQSgmrm8cHvC5uE1EdUYVbNHarSsMiIflUQXnpbAQjLcQhWZnYK911u6Vs3c8cGdrfmDruH6DtXhFcCz1hz959zRh4VV9iMOfLUyq6aoivNOH15YHVX/sgkBkWa0Oqfsk=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c993d182-a495-420c-880b-08d6a084de2b
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Mar 2019 09:36:24.2555
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB6276
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRGVubmlzIFpob3UgW21h
aWx0bzpkZW5uaXNAa2VybmVsLm9yZ10NCj4gU2VudDogMjAxOeW5tDPmnIg05pelIDQ6MjMNCj4g
VG86IFBlbmcgRmFuIDxwZW5nLmZhbkBueHAuY29tPg0KPiBDYzogVGVqdW4gSGVvIDx0akBrZXJu
ZWwub3JnPjsgQ2hyaXN0b3BoIExhbWV0ZXIgPGNsQGxpbnV4LmNvbT47IFZsYWQNCj4gQnVzbG92
IDx2bGFkYnVAbWVsbGFub3guY29tPjsga2VybmVsLXRlYW1AZmIuY29tOyBsaW51eC1tbUBrdmFj
ay5vcmc7DQo+IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogUmU6IFtQ
QVRDSCAwNy8xMl0gcGVyY3B1OiBhZGQgYmxvY2sgbGV2ZWwgc2Nhbl9oaW50DQo+IA0KPiBPbiBT
dW4sIE1hciAwMywgMjAxOSBhdCAwNjowMTo0MkFNICswMDAwLCBQZW5nIEZhbiB3cm90ZToNCj4g
PiBIaSBEZW5uaXMNCj4gPg0KPiA+ID4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gPiA+
IEZyb206IG93bmVyLWxpbnV4LW1tQGt2YWNrLm9yZyBbbWFpbHRvOm93bmVyLWxpbnV4LW1tQGt2
YWNrLm9yZ10NCj4gT24NCj4gPiA+IEJlaGFsZiBPZiBEZW5uaXMgWmhvdQ0KPiA+ID4gU2VudDog
MjAxOeW5tDLmnIgyOOaXpSAxMDoxOQ0KPiA+ID4gVG86IERlbm5pcyBaaG91IDxkZW5uaXNAa2Vy
bmVsLm9yZz47IFRlanVuIEhlbyA8dGpAa2VybmVsLm9yZz47DQo+ID4gPiBDaHJpc3RvcGggTGFt
ZXRlciA8Y2xAbGludXguY29tPg0KPiA+ID4gQ2M6IFZsYWQgQnVzbG92IDx2bGFkYnVAbWVsbGFu
b3guY29tPjsga2VybmVsLXRlYW1AZmIuY29tOw0KPiA+ID4gbGludXgtbW1Aa3ZhY2sub3JnOyBs
aW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+ID4gPiBTdWJqZWN0OiBbUEFUQ0ggMDcvMTJd
IHBlcmNwdTogYWRkIGJsb2NrIGxldmVsIHNjYW5faGludA0KPiA+ID4NCj4gPiA+IEZyYWdtZW50
YXRpb24gY2FuIGNhdXNlIGJvdGggYmxvY2tzIGFuZCBjaHVua3MgdG8gaGF2ZSBhbiBlYXJseQ0K
PiA+ID4gZmlyc3RfZmlyZWUgYml0IGF2YWlsYWJsZSwgYnV0IG9ubHkgYWJsZSB0byBzYXRpc2Z5
IGFsbG9jYXRpb25zIG11Y2gNCj4gPiA+IGxhdGVyIG9uLiBUaGlzIHBhdGNoIGludHJvZHVjZXMg
YSBzY2FuX2hpbnQgdG8gaGVscCBtaXRpZ2F0ZSBzb21lDQo+IHVubmVjZXNzYXJ5IHNjYW5uaW5n
Lg0KPiA+ID4NCj4gPiA+IFRoZSBzY2FuX2hpbnQgcmVtZW1iZXJzIHRoZSBsYXJnZXN0IGFyZWEg
cHJpb3IgdG8gdGhlIGNvbnRpZ19oaW50Lg0KPiA+ID4gSWYgdGhlIGNvbnRpZ19oaW50ID09IHNj
YW5faGludCwgdGhlbiBzY2FuX2hpbnRfc3RhcnQgPiBjb250aWdfaGludF9zdGFydC4NCj4gPiA+
IFRoaXMgaXMgbmVjZXNzYXJ5IGZvciBzY2FuX2hpbnQgZGlzY292ZXJ5IHdoZW4gcmVmcmVzaGlu
ZyBhIGJsb2NrLg0KPiA+ID4NCj4gPiA+IFNpZ25lZC1vZmYtYnk6IERlbm5pcyBaaG91IDxkZW5u
aXNAa2VybmVsLm9yZz4NCj4gPiA+IC0tLQ0KPiA+ID4gIG1tL3BlcmNwdS1pbnRlcm5hbC5oIHwg
ICA5ICsrKysNCj4gPiA+ICBtbS9wZXJjcHUuYyAgICAgICAgICB8IDEwMQ0KPiA+ID4gKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKy0tLQ0KPiA+ID4gIDIgZmlsZXMgY2hh
bmdlZCwgMTAzIGluc2VydGlvbnMoKyksIDcgZGVsZXRpb25zKC0pDQo+ID4gPg0KPiA+ID4gZGlm
ZiAtLWdpdCBhL21tL3BlcmNwdS1pbnRlcm5hbC5oIGIvbW0vcGVyY3B1LWludGVybmFsLmggaW5k
ZXgNCj4gPiA+IGIxNzM5ZGMwNmI3My4uZWM1OGIyNDQ1NDVkIDEwMDY0NA0KPiA+ID4gLS0tIGEv
bW0vcGVyY3B1LWludGVybmFsLmgNCj4gPiA+ICsrKyBiL21tL3BlcmNwdS1pbnRlcm5hbC5oDQo+
ID4gPiBAQCAtOSw4ICs5LDE3IEBADQo+ID4gPiAgICogcGNwdV9ibG9ja19tZCBpcyB0aGUgbWV0
YWRhdGEgYmxvY2sgc3RydWN0Lg0KPiA+ID4gICAqIEVhY2ggY2h1bmsncyBiaXRtYXAgaXMgc3Bs
aXQgaW50byBhIG51bWJlciBvZiBmdWxsIGJsb2Nrcy4NCj4gPiA+ICAgKiBBbGwgdW5pdHMgYXJl
IGluIHRlcm1zIG9mIGJpdHMuDQo+ID4gPiArICoNCj4gPiA+ICsgKiBUaGUgc2NhbiBoaW50IGlz
IHRoZSBsYXJnZXN0IGtub3duIGNvbnRpZ3VvdXMgYXJlYSBiZWZvcmUgdGhlIGNvbnRpZw0KPiBo
aW50Lg0KPiA+ID4gKyAqIEl0IGlzIG5vdCBuZWNlc3NhcmlseSB0aGUgYWN0dWFsIGxhcmdlc3Qg
Y29udGlnIGhpbnQgdGhvdWdoLg0KPiA+ID4gKyBUaGVyZSBpcyBhbg0KPiA+ID4gKyAqIGludmFy
aWFudCB0aGF0IHRoZSBzY2FuX2hpbnRfc3RhcnQgPiBjb250aWdfaGludF9zdGFydCBpZmYNCj4g
PiA+ICsgKiBzY2FuX2hpbnQgPT0gY29udGlnX2hpbnQuICBUaGlzIGlzIG5lY2Vzc2FyeSBiZWNh
dXNlIHdoZW4NCj4gPiA+ICsgc2Nhbm5pbmcgZm9yd2FyZCwNCj4gPiA+ICsgKiB3ZSBkb24ndCBr
bm93IGlmIGEgbmV3IGNvbnRpZyBoaW50IHdvdWxkIGJlIGJldHRlciB0aGFuIHRoZSBjdXJyZW50
DQo+IG9uZS4NCj4gPiA+ICAgKi8NCj4gPiA+ICBzdHJ1Y3QgcGNwdV9ibG9ja19tZCB7DQo+ID4g
PiArCWludAkJCXNjYW5faGludDsJLyogc2NhbiBoaW50IGZvciBibG9jayAqLw0KPiA+ID4gKwlp
bnQJCQlzY2FuX2hpbnRfc3RhcnQ7IC8qIGJsb2NrIHJlbGF0aXZlIHN0YXJ0aW5nDQo+ID4gPiAr
CQkJCQkJICAgIHBvc2l0aW9uIG9mIHRoZSBzY2FuIGhpbnQgKi8NCj4gPiA+ICAJaW50ICAgICAg
ICAgICAgICAgICAgICAgY29udGlnX2hpbnQ7ICAgIC8qIGNvbnRpZyBoaW50IGZvciBibG9jaw0K
PiAqLw0KPiA+ID4gIAlpbnQgICAgICAgICAgICAgICAgICAgICBjb250aWdfaGludF9zdGFydDsg
LyogYmxvY2sgcmVsYXRpdmUNCj4gc3RhcnRpbmcNCj4gPiA+ICAJCQkJCQkgICAgICBwb3NpdGlv
biBvZiB0aGUgY29udGlnIGhpbnQgKi8gZGlmZg0KPiAtLWdpdCBhL21tL3BlcmNwdS5jDQo+ID4g
PiBiL21tL3BlcmNwdS5jIGluZGV4IDk2N2M5Y2MzYTkyOC4uZGYxYWFjZjU4YWM4IDEwMDY0NA0K
PiA+ID4gLS0tIGEvbW0vcGVyY3B1LmMNCj4gPiA+ICsrKyBiL21tL3BlcmNwdS5jDQo+ID4gPiBA
QCAtMzIwLDYgKzMyMCwzNCBAQCBzdGF0aWMgdW5zaWduZWQgbG9uZyBwY3B1X2Jsb2NrX29mZl90
b19vZmYoaW50DQo+ID4gPiBpbmRleCwgaW50IG9mZikNCj4gPiA+ICAJcmV0dXJuIGluZGV4ICog
UENQVV9CSVRNQVBfQkxPQ0tfQklUUyArIG9mZjsgIH0NCj4gPiA+DQo+ID4gPiArLyoNCj4gPiA+
ICsgKiBwY3B1X25leHRfaGludCAtIGRldGVybWluZSB3aGljaCBoaW50IHRvIHVzZQ0KPiA+ID4g
KyAqIEBibG9jazogYmxvY2sgb2YgaW50ZXJlc3QNCj4gPiA+ICsgKiBAYWxsb2NfYml0czogc2l6
ZSBvZiBhbGxvY2F0aW9uDQo+ID4gPiArICoNCj4gPiA+ICsgKiBUaGlzIGRldGVybWluZXMgaWYg
d2Ugc2hvdWxkIHNjYW4gYmFzZWQgb24gdGhlIHNjYW5faGludCBvciBmaXJzdF9mcmVlLg0KPiA+
ID4gKyAqIEluIGdlbmVyYWwsIHdlIHdhbnQgdG8gc2NhbiBmcm9tIGZpcnN0X2ZyZWUgdG8gZnVs
ZmlsbA0KPiA+ID4gK2FsbG9jYXRpb25zIGJ5DQo+ID4gPiArICogZmlyc3QgZml0LiAgSG93ZXZl
ciwgaWYgd2Uga25vdyBhIHNjYW5faGludCBhdCBwb3NpdGlvbg0KPiA+ID4gK3NjYW5faGludF9z
dGFydA0KPiA+ID4gKyAqIGNhbm5vdCBmdWxmaWxsIGFuIGFsbG9jYXRpb24sIHdlIGNhbiBiZWdp
biBzY2FubmluZyBmcm9tIHRoZXJlDQo+ID4gPiAra25vd2luZw0KPiA+ID4gKyAqIHRoZSBjb250
aWdfaGludCB3aWxsIGJlIG91ciBmYWxsYmFjay4NCj4gPiA+ICsgKi8NCj4gPiA+ICtzdGF0aWMg
aW50IHBjcHVfbmV4dF9oaW50KHN0cnVjdCBwY3B1X2Jsb2NrX21kICpibG9jaywgaW50DQo+ID4g
PiArYWxsb2NfYml0cykgew0KPiA+ID4gKwkvKg0KPiA+ID4gKwkgKiBUaGUgdGhyZWUgY29uZGl0
aW9ucyBiZWxvdyBkZXRlcm1pbmUgaWYgd2UgY2FuIHNraXAgcGFzdCB0aGUNCj4gPiA+ICsJICog
c2Nhbl9oaW50LiAgRmlyc3QsIGRvZXMgdGhlIHNjYW4gaGludCBleGlzdC4gIFNlY29uZCwgaXMg
dGhlDQo+ID4gPiArCSAqIGNvbnRpZ19oaW50IGFmdGVyIHRoZSBzY2FuX2hpbnQgKHBvc3NpYmx5
IG5vdCB0cnVlIGlmZg0KPiA+ID4gKwkgKiBjb250aWdfaGludCA9PSBzY2FuX2hpbnQpLiAgVGhp
cmQsIGlzIHRoZSBhbGxvY2F0aW9uIHJlcXVlc3QNCj4gPiA+ICsJICogbGFyZ2VyIHRoYW4gdGhl
IHNjYW5faGludC4NCj4gPiA+ICsJICovDQo+ID4gPiArCWlmIChibG9jay0+c2Nhbl9oaW50ICYm
DQo+ID4gPiArCSAgICBibG9jay0+Y29udGlnX2hpbnRfc3RhcnQgPiBibG9jay0+c2Nhbl9oaW50
X3N0YXJ0ICYmDQo+ID4gPiArCSAgICBhbGxvY19iaXRzID4gYmxvY2stPnNjYW5faGludCkNCj4g
PiA+ICsJCXJldHVybiBibG9jay0+c2Nhbl9oaW50X3N0YXJ0ICsgYmxvY2stPnNjYW5faGludDsN
Cj4gPiA+ICsNCj4gPiA+ICsJcmV0dXJuIGJsb2NrLT5maXJzdF9mcmVlOw0KPiA+ID4gK30NCj4g
PiA+ICsNCj4gPiA+ICAvKioNCj4gPiA+ICAgKiBwY3B1X25leHRfbWRfZnJlZV9yZWdpb24gLSBm
aW5kcyB0aGUgbmV4dCBoaW50IGZyZWUgYXJlYQ0KPiA+ID4gICAqIEBjaHVuazogY2h1bmsgb2Yg
aW50ZXJlc3QNCj4gPiA+IEBAIC00MTUsOSArNDQzLDExIEBAIHN0YXRpYyB2b2lkIHBjcHVfbmV4
dF9maXRfcmVnaW9uKHN0cnVjdA0KPiA+ID4gcGNwdV9jaHVuayAqY2h1bmssIGludCBhbGxvY19i
aXRzLA0KPiA+ID4gIAkJaWYgKGJsb2NrLT5jb250aWdfaGludCAmJg0KPiA+ID4gIAkJICAgIGJs
b2NrLT5jb250aWdfaGludF9zdGFydCA+PSBibG9ja19vZmYgJiYNCj4gPiA+ICAJCSAgICBibG9j
ay0+Y29udGlnX2hpbnQgPj0gKmJpdHMgKyBhbGxvY19iaXRzKSB7DQo+ID4gPiArCQkJaW50IHN0
YXJ0ID0gcGNwdV9uZXh0X2hpbnQoYmxvY2ssIGFsbG9jX2JpdHMpOw0KPiA+ID4gKw0KPiA+ID4g
IAkJCSpiaXRzICs9IGFsbG9jX2JpdHMgKyBibG9jay0+Y29udGlnX2hpbnRfc3RhcnQgLQ0KPiA+
ID4gLQkJCQkgYmxvY2stPmZpcnN0X2ZyZWU7DQo+ID4gPiAtCQkJKmJpdF9vZmYgPSBwY3B1X2Js
b2NrX29mZl90b19vZmYoaSwgYmxvY2stPmZpcnN0X2ZyZWUpOw0KPiA+ID4gKwkJCQkgc3RhcnQ7
DQo+ID4NCj4gPiBUaGlzIG1pZ2h0IG5vdCByZWxldmFudCB0byB0aGlzIHBhdGNoLg0KPiA+IE5v
dCBzdXJlIGl0IGlzIGludGVuZGVkIG9yIG5vdC4NCj4gPiBGb3IgYGFsbG9jX2JpdHMgKyBibG9j
ay0+Y29udGlnX2hpbmtfc3RhcnQgLSBbYmxvY2stPmZpcnN0X2ZyZWUgb3INCj4gPiBzdGFydF1g
IElmIHRoZSByZWFzb24gaXMgdG8gbGV0IHBjcHVfaXNfcG9wdWxhdGVkIHJldHVybiBhIHByb3Bl
cg0KPiA+IG5leHRfb2ZmIHdoZW4gcGNwdV9pc19wb3B1bGF0ZWQgZmFpbCwgaXQgbWFrZXMgc2Vu
c2UuIElmIG5vdCwgd2h5IG5vdCBqdXN0DQo+IHVzZSAqYml0cyArPSBhbGxvY19iaXRzLg0KPiA+
DQo+IA0KPiBUaGlzIGlzIGhvdyB0aGUgaXRlcmF0b3Igd29ya3MuIFdpdGhvdXQgaXQsIGl0IGRv
ZXNuJ3QuDQoNCk9vcHPvvIxJIG1hZGUgYSBtaXN0YWtlLCB5b3UgYXJlIHJpZ2h0LCB0aGUgaXRl
cmF0b3IgbmVlZHMgc3VjaCBsb2dpYy4NCg0KVGhhbmtzLA0KUGVuZy4NCg0KPiANCj4gVGhhbmtz
LA0KPiBEZW5uaXMNCg==

