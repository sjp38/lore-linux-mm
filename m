Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17C9FC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 18:17:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFFEF21E70
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 18:17:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="XVrvAlpr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFFEF21E70
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E0816B0007; Wed,  7 Aug 2019 14:17:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36AEB6B0008; Wed,  7 Aug 2019 14:17:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BD496B000A; Wed,  7 Aug 2019 14:17:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0D126B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 14:17:43 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id 9so18291256ljp.7
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 11:17:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=2EXPUC9MWpnXQilcdUkMQeiZeh83FjcLgirnjUQqTlo=;
        b=PEOK6Vlp8ruXrEjs1N9pgCesdDw4WM+JrUWNM0FSo37NI8uW6tOfXH6GHGqCY1R5/k
         GB+mmu6+J/5w/QqVaW+QZRAlAdb4q+DkrLlG3exDs7WmDERTGDFweGS4WDZb+ytU00rJ
         HjYOM/rD6tDD/HxgrPzOG9xH/JNlBs0tD/5OmkAq4EPKJuL3RYRwv8INTyB1uyyjBu+x
         z9EyxJFB6WLoMj9TWrYLTQ29k34tk5BiKXYuNbRjiau1AklmUo8jSWwVE7P9TawaqUat
         qx3Zz7kg1TMUeJebJ3ia+1mJ83Oo1jOZ1JjajtCYdB1N7HbW5WtBCMT9CUQaCK2p+CR7
         kD0g==
X-Gm-Message-State: APjAAAXqydmgxGZgi+rCsnBep4DxgUsvJ9t0T+Xf5ltWVR1WTlMRcXA4
	LROfnk+6VdOaYuQhtOPf5E4Mr3xlcQo1agYJhmpXBO6X28ywtxvGxAicoTlT78mPCePmqbSBzpt
	nX29x/U+JhJ4YYxAmSpuco98Y45v7qIYjKV5FMGlu3a5DykLATv//jBO4UPi6Ormi+Q==
X-Received: by 2002:a19:cbd3:: with SMTP id b202mr6612357lfg.185.1565201862848;
        Wed, 07 Aug 2019 11:17:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4KMrzpOjKE9SiL2DkvovWxeDB3zo6jGXJVUXdr9w8a5eLrNpZM+bl+9HWW+mIXL1tMvX5
X-Received: by 2002:a19:cbd3:: with SMTP id b202mr6612318lfg.185.1565201861950;
        Wed, 07 Aug 2019 11:17:41 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565201861; cv=pass;
        d=google.com; s=arc-20160816;
        b=TPHXs5YDlCtHaw+8Otsw6eb1ZdVCdkogBg1n4RtJvh8f8TsViNNhquWTK3p2aBgAUN
         wrp7bvjPqI2nTCo0H9pGc8v6lQqxti8D5OFa8AmQk5YV1kbu1aQkgjz+Bgx3Uz85Dx5J
         S8Bu5DJNgJX0yNpp+i5R5XonS4Hr1aRv4ALacR3WxgIxCRGQ802WHrxV1PIfxBCrX5Zg
         vvjuOCGMfGF+wFPzrROTDvGmkx/9nK3UtMNd9GWGULIEqJT8BOjq63tLklhL16CzrHG1
         tdgCiXARfND0N3S+r8QUPjQ9nwnl7+a3ZaTTmxQUJOeT8prYeu02zR4q/tNw59GZRVgB
         0yOw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=2EXPUC9MWpnXQilcdUkMQeiZeh83FjcLgirnjUQqTlo=;
        b=fXrnorQjCdjVFqk4/9VlU0/GnCoSk0mSAYu5aXsaTngoogARAU4Q0wD1CdC15Pyo9+
         0y2QLDgI9ukoFuWpobYmLTTBLyuRGVOx9ETpT6isylcAouF32mQN5fiH6+fN/Oow6KMt
         YefFdYv3LC5/Per2AGwYZe4nB6RzfgunoVVvSPwL+25fyqEkDyx8/otTuwLYVExdiacF
         cs9jOXnspA/4pydqeHDA5Tsguws+3Njo2+Tbt+i4uWMX2xb0Mbni0ckiiXl/u+fTCVgf
         P9CTxf2JPQ2YSHEj6v0Ag6x2pG8U6j8OvulM2Hf4uS6ztBpOzLMr6A6QI5WsQqojTLZA
         DSMg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=XVrvAlpr;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.0.50 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00050.outbound.protection.outlook.com. [40.107.0.50])
        by mx.google.com with ESMTPS id x15si81976861ljh.120.2019.08.07.11.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 11:17:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.0.50 as permitted sender) client-ip=40.107.0.50;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=XVrvAlpr;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.0.50 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=DQje8g+Ju47ImkZwiBuVOtSQHMkxvF0Wci+I/rnWd4JZ8GxXH78Brlpty7+pmS/s0wq56AcUeNT3AltTxYJfVReWuMYDi/LXp3qYWjfNWuLjaUO66wCW0USMFIRwa8FuP5UEg/2qnORN/7VbyJJc2NBAr17to8XHJ+WGQCNVfwLX0eccIgNOtx9kgve19yZRnpGWn79MXTIHPdTtDFmkjgovl6IDR2SCIng/RjiwHACrha4/THw4eb3XBSLnpMVnqe4vN1uW+lcvlMXi9zQeSdGooit6i0g3aZs8b63+rY52g7MLCjL6u5KDZC1qJbOWp3qM98sWV9plI3jOHUPdbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2EXPUC9MWpnXQilcdUkMQeiZeh83FjcLgirnjUQqTlo=;
 b=VHq4j2uISXpKY39PO7d5XO2QvgjsSja0yPAs75Ph/HgBFSb4Wf7GWNc5nLRUHbTfKlKc68UZXWA5Q/pABCwEWRzrSekHIAFdUkEDiTrtqfLvG6D3iFI6pY/BVmibVaOt5TbFpFy6bI0mrP9Sb1oS8JqIRIJoqLBCx5lcZwijjeEw99lektl21mAa7wZpwLDGXns093ggStamS7b1erQHGrYC6Rng/nP70WA/0Gv0dte4uTsPSrYLm+F2o+kvqUgm+zf4S3ixIuhogx69QWXMcKF2CApciwkInJMoD2oqL1/2XixaOFH0duMYFbv283SMyfRvvIvhnDvRhl/vg9QHXw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2EXPUC9MWpnXQilcdUkMQeiZeh83FjcLgirnjUQqTlo=;
 b=XVrvAlprNK3yw7vO6hrlpoO7EMfq+IJe+Brm5elZxCR+n5Abs7XT34Xt7xU0KbaCm3SCTY7LmfWiTzQNDLU1HxCt5IRHqPEv4YfNvu2VSd6os3pyMbstgtcKDaTBL3joAOx29+r7m8x10HZNoP486tAU6SrllQnvTbLaL4idbfo=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6461.eurprd05.prod.outlook.com (20.179.24.213) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.16; Wed, 7 Aug 2019 18:17:39 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2136.018; Wed, 7 Aug 2019
 18:17:39 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>, John Hubbard <jhubbard@nvidia.com>
CC: =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: hmm cleanups, v2
Thread-Topic: hmm cleanups, v2
Thread-Index: AQHVTHDXDUnAIZqjmEOq1Yke5EzQp6bv/+GA
Date: Wed, 7 Aug 2019 18:17:39 +0000
Message-ID: <20190807181733.GL1571@mellanox.com>
References: <20190806160554.14046-1-hch@lst.de>
In-Reply-To: <20190806160554.14046-1-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YT1PR01CA0004.CANPRD01.PROD.OUTLOOK.COM (2603:10b6:b01::17)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b9004f64-56d0-4808-36e5-08d71b6387c7
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6461;
x-ms-traffictypediagnostic: VI1PR05MB6461:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR05MB646181193F251A672B9334EDCFD40@VI1PR05MB6461.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 01221E3973
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(396003)(366004)(346002)(376002)(136003)(199004)(189003)(966005)(6116002)(53936002)(229853002)(8676002)(6486002)(33656002)(7736002)(71190400001)(476003)(26005)(8936002)(81156014)(81166006)(486006)(71200400001)(36756003)(256004)(2616005)(305945005)(446003)(3846002)(2906002)(11346002)(14454004)(6506007)(4326008)(66946007)(66476007)(6246003)(54906003)(86362001)(386003)(66556008)(64756008)(66446008)(5660300002)(99286004)(478600001)(6306002)(6512007)(102836004)(68736007)(7416002)(186003)(1076003)(316002)(76176011)(6436002)(52116002)(110136005)(25786009)(66066001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6461;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 evQ9V92IoJTtn2zv2EdFZ9MNnfJPb2jedbASOg3TsWMb6M6dSvkP4p/klz0PwZ4o44H6NWNbOVS+G54hOrPtmpy6hqKzKV3Zp+0ciGNSFKpNdqWp50tSKaUBzE8aGYos4X5xC7Azbrl16BzFBJC6GFbIbD8VVYM4S1xXr9vlaZBHMoORPochpoM95SMZ8Y2+84yQpxmSK0stvOu3wHH64J6INsj0YzE5ws0AoXuOrwj2tx/ttYvAIsyBPvpoXOXjHMDUGTrOXoFUtKLqn6orpS/QMtNTdnIleogvsVDRCBC2HAJkfw0X8WuTxaJ3bKrV3kIEiJUrDDzaxDndXaaReZ/2U5EwdogoSOpXOYkpFyy9TsaDX4GDMuJwd6QTPa2PAYJCcx9edMWxz7k3iqZ0LGiJH8Q+9Dq2NGk6d+QSVRk=
Content-Type: text/plain; charset="utf-8"
Content-ID: <B71F314D18668A44A07719FC1462D90A@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b9004f64-56d0-4808-36e5-08d71b6387c7
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Aug 2019 18:17:39.1325
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6461
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVHVlLCBBdWcgMDYsIDIwMTkgYXQgMDc6MDU6MzhQTSArMDMwMCwgQ2hyaXN0b3BoIEhlbGx3
aWcgd3JvdGU6DQo+IA0KPiBIaSBKw6lyw7RtZSwgQmVuLCBGZWxpeCBhbmQgSmFzb24sDQo+IA0K
PiBiZWxvdyBpcyBhIHNlcmllcyBhZ2FpbnN0IHRoZSBobW0gdHJlZSB3aGljaCBjbGVhbnMgdXAg
dmFyaW91cyBtaW5vcg0KPiBiaXRzIGFuZCBhbGxvd3MgSE1NX01JUlJPUiB0byBiZSBidWlsdCBv
biBhbGwgYXJjaGl0ZWN0dXJlcy4NCj4gDQo+IERpZmZzdGF0Og0KPiANCj4gICAgIDExIGZpbGVz
IGNoYW5nZWQsIDk0IGluc2VydGlvbnMoKyksIDIxMCBkZWxldGlvbnMoLSkNCj4gDQo+IEEgZ2l0
IHRyZWUgaXMgYWxzbyBhdmFpbGFibGUgYXQ6DQo+IA0KPiAgICAgZ2l0Oi8vZ2l0LmluZnJhZGVh
ZC5vcmcvdXNlcnMvaGNoL21pc2MuZ2l0IGhtbS1jbGVhbnVwcy4yDQo+IA0KPiBHaXR3ZWI6DQo+
IA0KPiAgICAgaHR0cDovL2dpdC5pbmZyYWRlYWQub3JnL3VzZXJzL2hjaC9taXNjLmdpdC9zaG9y
dGxvZy9yZWZzL2hlYWRzL2htbS1jbGVhbnVwcy4yDQo+IA0KPiBDaGFuZ2VzIHNpbmNlIHYxOg0K
PiAgLSBmaXggdGhlIGNvdmVyIGxldHRlciBzdWJqZWN0DQo+ICAtIGltcHJvdmUgdmFyaW91cyBw
YXRjaCBkZXNjcmlwdGlvbnMNCj4gIC0gdXNlIHN2bW0tPm1tIGluIG5vdXZlYXVfcmFuZ2VfZmF1
bHQNCj4gIC0gaW52ZXJzZSB0aGUgaG1hc2sgZmllbGQgd2hlbiB1c2luZyBpdA0KPiAgLSBzZWxl
Y3QgSE1NX01JUlJPUiBpbnN0ZWFkIG9mIG1ha2luZyBpdCBhIHVzZXIgdmlzaWJsZSBvcHRpb24N
CiANCkkgdGhpbmsgaXQgaXMgc3RyYWlnaHRmb3J3YXJkIGVub3VnaCB0byBtb3ZlIGludG8gLW5l
eHQsIHNvIGFwcGxpZWQgdG8NCnRoZSBobW0uZ2l0IGxldHMgZ2V0IHNvbWUgbW9yZSByZXZpZXdl
ZC1ieXMvdGVzdGVkLWJ5IHRob3VnaC4NCg0KRm9yIG5vdyBJIGRyb3BwZWQgJ3JlbW92ZSB0aGUg
cGdtYXAgZmllbGQgZnJvbSBzdHJ1Y3QgaG1tX3ZtYV93YWxrJw0KanVzdCB0byBoZWFyIHRoZSBm
b2xsb3d1cCBhbmQgJ2FtZGdwdTogcmVtb3ZlDQpDT05GSUdfRFJNX0FNREdQVV9VU0VSUFRSJyB1
bnRpbCB0aGUgQU1EIHRlYW0gQWNrcw0KDQpUaGFua3MsDQpKYXNvbg0K

