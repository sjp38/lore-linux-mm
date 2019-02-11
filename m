Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8609C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:38:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A3B6222A5
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:38:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="cCn0QqaM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A3B6222A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3F0D8E00EA; Mon, 11 Feb 2019 10:38:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DECFB8E00E9; Mon, 11 Feb 2019 10:38:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB4AE8E00EA; Mon, 11 Feb 2019 10:38:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 702768E00E9
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:38:26 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so9865377ede.14
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:38:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=18PH/99sFHWsSpYwGpdGsmG9xhKLAlU+L49Bl16JviY=;
        b=aCS2YjhovOe4HYz8T+6Qv6c7LfhvuwceYSmpNhMI3wGBWgtGYjEvLRLOjqjzFGbKim
         6dRai1+AhNwT4oO++6l8A4rNAOEvNdXEmPT5hA+oHq3pdsUxCiB+mdxNgmWwiDBtgBUd
         0SEu28yERt/LAEmA/+tTjO8lCwGfs+dpVOfNQyvcA8pJK6/WTKxKpw7m34XGB/AFUI9d
         4iritDjR/C+cqHCsWxGbKMMpcY874djaDw9RX/qS2CLu495XkWQ3zMDixbHcViv+uW9C
         4zgMFBTTil2+yV5cT8EegPiAScP5wBHrpq34xtd6WgB9XHX3cnXqsigsrxPJgIfnN1Kk
         UeJA==
X-Gm-Message-State: AHQUAuaatnBuWLJrlwahWNMCug0yddyeId5nWfYUPJ3lZi+It9kPJYTw
	wKSNQMqzTIUrShh4wzukywvtP1nJBMGiACkr/IAuAhchkqaGXUPTixm5A9fgxe1B13jXYBbJH9b
	Es3DUPb5RloE/muRDgLbPpFJl9+D13qjWGvsYfyJBZRoEzJlSLzVRn+H6fMQCBNLb5A==
X-Received: by 2002:a50:c089:: with SMTP id k9mr28575899edf.89.1549899505914;
        Mon, 11 Feb 2019 07:38:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaLuqSzDlD01q5TNqYVwkZhHuF5hm8xUZ4btfXo+CRtAqNRl726mjriaTFZi+paRxwDhbda
X-Received: by 2002:a50:c089:: with SMTP id k9mr28575838edf.89.1549899505089;
        Mon, 11 Feb 2019 07:38:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549899505; cv=none;
        d=google.com; s=arc-20160816;
        b=SvQ3ybJXRe/KyUgdDbaeV5b3mBoCSmalRBHofon+3Mgkk86CzsAWbdvrbhhlIXSSlr
         Hnc9X2NP1+YvlHIbY+K0n8NUY7TKXGc7uIuwiwH5d4etbxbxLylzmZpmpCHggjWo7Aei
         YkBpnk6g9vCYaZbHULWepZ8Sk1H/xypYXFQ+NoUNsUq8RIWUnekYNwWh7ZO8XZHXEV8I
         sI867Wkwh9sVPw3r3x6poOA+rfEMRMx3OIZkRMYM/MjfTUcaGKKQ00xeifPktgkp0oCv
         n8pDVnqdFmjo4AZgeNWZsHVcgioY6TZfjOdmgBTCDL32zuIdQxneeVhxHCKgba8mjNl0
         PZAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=18PH/99sFHWsSpYwGpdGsmG9xhKLAlU+L49Bl16JviY=;
        b=Ise6s30CNI0Jkp2T3iG1FdbH5BKvohZduzICh6qMn3Gzxqq+9h4Qe96S81P5xhxKUE
         E9rLXDQgxWdx+9AlUtHlZUgXh3U5f+vc2NxqhzYTuJoPZVTW1FUiG+07JruaWaOPGOSD
         BMqzAyqcMpdbIJ6TGYAomHyfGVrjgZ+oGb7ZEa7Jo1aKUkx9MUz8eu9bwKManvbaBpPz
         9gmafEiJqGPNjkSJw9pev5zHWcJLxZRnwr0UBz5ABdzEQbC76upf5uJZYHx3OMgDQnuM
         63Cc8d7jK4/zXkekLNAqPjO1Wi8G95VRxPsE7hFNU2+mux537DVgz6CNFiaa6Gj3iQuJ
         z0zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=cCn0QqaM;
       spf=pass (google.com: domain of tariqt@mellanox.com designates 40.107.3.82 as permitted sender) smtp.mailfrom=tariqt@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30082.outbound.protection.outlook.com. [40.107.3.82])
        by mx.google.com with ESMTPS id r30si968997edd.123.2019.02.11.07.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 07:38:25 -0800 (PST)
Received-SPF: pass (google.com: domain of tariqt@mellanox.com designates 40.107.3.82 as permitted sender) client-ip=40.107.3.82;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=cCn0QqaM;
       spf=pass (google.com: domain of tariqt@mellanox.com designates 40.107.3.82 as permitted sender) smtp.mailfrom=tariqt@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=18PH/99sFHWsSpYwGpdGsmG9xhKLAlU+L49Bl16JviY=;
 b=cCn0QqaMgBBmGZIAymbzlNQYi0MuaCTsqBT+aaHD9GTDtE50e0JYjlJovofwQsXQpYvpHuOS6kaDudwQKhBgs4hn+PgarZ+Fm1Zhw0t+h+q/sHNTkoBiuMRyIHcNFegrOFG4heHkjPVaCVyEyTizYdtRuhRiD134H7L0uJuPph0=
Received: from HE1PR05MB3257.eurprd05.prod.outlook.com (10.170.243.19) by
 HE1PR05MB1209.eurprd05.prod.outlook.com (10.161.119.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.19; Mon, 11 Feb 2019 15:38:22 +0000
Received: from HE1PR05MB3257.eurprd05.prod.outlook.com
 ([fe80::550a:a35e:2062:792a]) by HE1PR05MB3257.eurprd05.prod.outlook.com
 ([fe80::550a:a35e:2062:792a%7]) with mapi id 15.20.1601.023; Mon, 11 Feb 2019
 15:38:22 +0000
From: Tariq Toukan <tariqt@mellanox.com>
To: Matthew Wilcox <willy@infradead.org>, Tariq Toukan <tariqt@mellanox.com>
CC: Ilias Apalodimas <ilias.apalodimas@linaro.org>, David Miller
	<davem@davemloft.net>, "brouer@redhat.com" <brouer@redhat.com>,
	"toke@redhat.com" <toke@redhat.com>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "mgorman@techsingularity.net"
	<mgorman@techsingularity.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Thread-Topic: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Thread-Index:
 AQHUvvKPEpTQQqXqi0+ZzMx9yc3kKaXUb92AgAADlACAAGXpgIAAAm4AgAACaICABZPkAIAAFgsAgAA5mgA=
Date: Mon, 11 Feb 2019 15:38:22 +0000
Message-ID: <d3aae1c0-a9ac-b79d-fed9-0f57230167de@mellanox.com>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
 <20190207213400.GA21860@bombadil.infradead.org>
 <20190207214237.GA10676@Iliass-MBP.lan>
 <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
 <20190211121208.GB12668@bombadil.infradead.org>
In-Reply-To: <20190211121208.GB12668@bombadil.infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: LO2P265CA0275.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:a1::23) To HE1PR05MB3257.eurprd05.prod.outlook.com
 (2603:10a6:7:35::19)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=tariqt@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [193.47.165.251]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;HE1PR05MB1209;6:Y/S5qlIvcqtsfqCnYnM12ItI/z2i3aJdaZTyiM0xHPf8W9TnaE/PUtohBZ2Zd1roZ/zisLzZ/hVogkRoi89n+64Tl1obviZv9iYZYf681WXx470Q5Qmn7cb5lKuVhpu+fmyGuIrrpjUWO8OeBHlso552liA2P5tHvB+DpfZC8Kg7zLiS9D5I2BxlrGQO4h8kvfGw2wdO4goljbUfjTu/iio6JLwSqRKYl6zgIVxddPPcImTYdCeL3HxcWiCNZI9C3jEoyAwkZTig0scO6khuiwbWb+wkbd2jYCJtJe5s/hvmASyC0U9oDi85TN0jIr75Aoj473dDbmqJgN2Ylwo2Mfu5WEupY1kX86IHL3bnQ/8apYIgww+KiaoFkNfq6X0YJ8hs2Y95soZZ/0Ev5yxNFqQmQVObuSglj0MOd/NKGVyQo8mUb+Wj5zOg6j5LEf32UyxbT7iyMd4hFnlI3WBzhw==;5:Xr6SFGIAAApV+4DnkM0v8m1OYlbCoDARhCYD1bOu60aJqSNUaUJkCtPOhMlcBeTVHEyD1Mrpc/QRp2zVXjcmHYuM+Tq+Z9/6Cbak+g2fwGpYEYwONTrWQSaTrJdJialWUYHqmA4uZnEBUpqUBYBer8gbKYG7+xFeaxlySG3e1OdY6Ihi91BgxNAGKrZXWfablGO69TAqmeThAJsGkCviBQ==;7:W3aTL1YLTKqVWW5oVQQWMMKA2oHi62Vt6aOFL3cBWkSgmfZ03SbA+0dKf4byT/f1EFJ0/Ekqnr3Uhh2t0E48Bs6fayeWSll+xW23RQsAE64ASUaSbkn6+z2QsZO7w6g4847KKiHnIQl2/hY72ORgnA==
x-ms-office365-filtering-correlation-id: ce95b8b7-8876-4e5b-fe81-08d69036f46b
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:HE1PR05MB1209;
x-ms-traffictypediagnostic: HE1PR05MB1209:
x-microsoft-antispam-prvs:
 <HE1PR05MB1209412AF88BDC4844A6BE07AE640@HE1PR05MB1209.eurprd05.prod.outlook.com>
x-forefront-prvs: 0945B0CC72
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(346002)(366004)(136003)(396003)(39860400002)(189003)(199004)(476003)(110136005)(2616005)(486006)(25786009)(446003)(316002)(11346002)(4326008)(54906003)(256004)(8676002)(99286004)(93886005)(97736004)(52116002)(81166006)(8936002)(81156014)(76176011)(31686004)(106356001)(105586002)(6436002)(6512007)(305945005)(53936002)(229853002)(6246003)(68736007)(386003)(6506007)(53546011)(31696002)(102836004)(26005)(6486002)(186003)(66066001)(3846002)(4744005)(478600001)(14454004)(6116002)(86362001)(36756003)(71190400001)(71200400001)(2906002)(7736002);DIR:OUT;SFP:1101;SCL:1;SRVR:HE1PR05MB1209;H:HE1PR05MB3257.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 8t0iSwFco9upVk8poR6PhUyp+YuiLqGWhy4cAaj/Zc54PdDh34tmIUgsWbPqrwOdkGxTFOLAdwBAnalKJir8XKIjoAbMi9H00Kubeh+ggMCJRECgu4YbV7mzBIX8dmz+5bWFIJT+KWtlkklW7E+r8gAno4gSMTEJ6gkLEXeosj6qVju6/1FMS1oivvpDDfPf+iIpJ2d16Nc3TERJSkJeihM0MmDLwBzcOl8MdNxcLggjL6vXbpZisL0t+A0uDFsPZ6WssXNd+4LVOQDA+2ypTgFTSh1K8SQLRUG5ub8WAbi4cWkeMQv/TenBDxuGm0rWpuECIy8x55FpsjAkojILP7XKYCA43453a2Uk9wD+HShFAPH5uCujGAe5Jmvw0awo4RBJwGAMbCM1UVkBud5hj/Q+Nh3RiGrvfBRldT+vZKs=
Content-Type: text/plain; charset="utf-8"
Content-ID: <B2BE6C2559379842B85AE14F15E36D87@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ce95b8b7-8876-4e5b-fe81-08d69036f46b
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Feb 2019 15:38:21.1567
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: HE1PR05MB1209
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCk9uIDIvMTEvMjAxOSAyOjEyIFBNLCBNYXR0aGV3IFdpbGNveCB3cm90ZToNCj4gT24gTW9u
LCBGZWIgMTEsIDIwMTkgYXQgMDg6NTM6MTlBTSArMDAwMCwgVGFyaXEgVG91a2FuIHdyb3RlOg0K
Pj4gSXQncyBncmVhdCB0byB1c2UgdGhlIHN0cnVjdCBwYWdlIHRvIHN0b3JlIGl0cyBkbWEgbWFw
cGluZywgYnV0IEkgYW0NCj4+IHdvcnJpZWQgYWJvdXQgZXh0ZW5zaWJpbGl0eS4NCj4+IHBhZ2Vf
cG9vbCBpcyBldm9sdmluZywgYW5kIGl0IHdvdWxkIG5lZWQgc2V2ZXJhbCBtb3JlIHBlci1wYWdl
IGZpZWxkcy4NCj4+IE9uZSBvZiB0aGVtIHdvdWxkIGJlIHBhZ2VyZWZfYmlhcywgYSBwbGFubmVk
IG9wdGltaXphdGlvbiB0byByZWR1Y2UgdGhlDQo+PiBudW1iZXIgb2YgdGhlIGNvc3RseSBhdG9t
aWMgcGFnZXJlZiBvcGVyYXRpb25zIChhbmQgcmVwbGFjZSBleGlzdGluZw0KPj4gY29kZSBpbiBz
ZXZlcmFsIGRyaXZlcnMpLg0KPiANCj4gVGhlcmUncyBzcGFjZSBmb3IgZml2ZSB3b3JkcyAoMjAg
b3IgNDAgYnl0ZXMgb24gMzIvNjQgYml0KS4NCj4gDQoNCk9LIHNvIHRoaXMgaXMgZ29vZCBmb3Ig
bm93LCBhbmQgZm9yIHRoZSBuZWFyIGZ1dHVyZS4NCkZpbmUgYnkgbWUuDQoNClJlZ2FyZHMsDQpU
YXJpcQ0K

