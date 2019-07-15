Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28836C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 17:25:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B97C4206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 17:25:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="YqYrrYiu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B97C4206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AC586B0003; Mon, 15 Jul 2019 13:25:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75D276B0005; Mon, 15 Jul 2019 13:25:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 626186B0006; Mon, 15 Jul 2019 13:25:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B65B6B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 13:25:24 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id w11so9176323wrl.7
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 10:25:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Tlyk88b4Yf7SQV1fS60WfUohTkEkzjx19R1MZdQ+JcI=;
        b=tCVQP69c3OC6S+Se2Gs683z6ZiSbMnzP2s1rd4h4rljbUhWNd0z62fLi5Gg3Im/Exf
         MOjP1A4kwDYnPPPB2/rB2OFJd/NfXFfqX1lzyaemM1reFCxooClHU1TkKM7H4iekKaRl
         a2syT97q/ye9TdeTpr9nvZsa8evb5VZGUY5rdlkT9hx2DxWVNE8RjfbvHiJpTeJyqFLk
         k2iK+0bCbS2o/4HHPH9VJS9VYGdOHSS1Q1tNiLUWNQs/obIwhfNRb03EYef+/RlWtkL6
         DfnE6+/jIeYq4w/qQg+I75aRov+ckOiozo+WbKZ2tlczx8lc0RRJgEmmxmmIZfixSDdI
         algQ==
X-Gm-Message-State: APjAAAVYAEsNuDRDfp4w6SRjFz4v/EAHnFWaADCEJxK2mm3+qMS+nu2U
	5WIL7m++OtftLzilmMCXhFcxfY+fSP2Vd2wutYqKdKTco5BpZojkdXZJeYDDvVZdKGIRTWBgh9h
	a+yd9tMIWrb1eBcCy+jBnoN1cvsAiihvTIDhZ2u1WcWDs+AYIA4hG6ncbQ+fPBsIUEw==
X-Received: by 2002:a5d:5186:: with SMTP id k6mr31967880wrv.30.1563211523407;
        Mon, 15 Jul 2019 10:25:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwD1kxS3+ow03KD57BdpZH6ANzlGwJK1fJkL3yGrCC+iJQsyQ1glya80FtGg5XZH/yokfUf
X-Received: by 2002:a5d:5186:: with SMTP id k6mr31967835wrv.30.1563211522546;
        Mon, 15 Jul 2019 10:25:22 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563211522; cv=pass;
        d=google.com; s=arc-20160816;
        b=ZEsxgSrTnZ2qOpx/Ypjw1vMrMrz3a+Lc4LV4G1txJqIYr+Xtqkpw+JkjyvywIJfReq
         sZYRxoy8tmPuJkqLz7io5q6NJ1xTC87TAN10g0tbWQVZPAaoPd6teKvLLAnrtfpLZN80
         OiekISZQjXnwCt6igNTgLeMG6QDp6wuB+AbC6+4iBvOSouQ9+dKpMng7JY69iakwa8GQ
         kSczXqS7pP8dNI/FVcT6odoPn53vQpgCFSAtqlGuEP7+qZfrATi2r6QjFj/YaJaTerLT
         0zvnTUAGc9pVr2cBFCpJjm/OoNpC8w0+JcST6y6ni/gyOPzZIPLb22nV5PDUOxxuEfnQ
         cG5A==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Tlyk88b4Yf7SQV1fS60WfUohTkEkzjx19R1MZdQ+JcI=;
        b=YODbjA7LMg3ZvKJfOvP9/FLOTaEvvE2V/i/WrfKGeqg/1En+P7lMa3moeCZxNGrTVV
         bKhMFOmi1Y+fB24Nqaa4WkIPhuPMq8Fbq4kN3REHfFg9kMVT4NLumrnQ+0xSqfIboTLG
         4b84wBDTuMzi6vjhM/rtdLSzER4mk1p7yupg5s35bfLmUG12CYBMWV+P3T75IrebE5TL
         l41ar/7gzZ7aRr1sdOaJPPrl0WC1fXk+hU743l/p6Ef5xwSwjgmxpajyVCJuv8EoSmse
         RYbUCmj7LXTme6rezdiMBK8dCl4GhvxSpwyNnCl2OUe3w53UmKC3lqP/06AFPsnGjANl
         cJjg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=YqYrrYiu;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.87 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150087.outbound.protection.outlook.com. [40.107.15.87])
        by mx.google.com with ESMTPS id r22si14856110wmh.136.2019.07.15.10.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 15 Jul 2019 10:25:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.15.87 as permitted sender) client-ip=40.107.15.87;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=YqYrrYiu;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.87 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=mFw4M//qPzso7YRc2S8DnHEHtmFJZfMZXrto4KnHQrrdOr2LTIszkSFozYPedlZaVCdVY42SxmdaPXjXxpAy7JLV+BCzwrDS/EY8agl29zAURLF+GPWMksF+7r+SkU6fyJ2FyG9QbTV1wye6stdcs37EovhQnpHUGrhwqBQ5p0HhrVGgKQvrPrqrRQ7pfStHax9yoV3TvTc3s0TCgz8My7z4hSENklUUH9dbM1UX/Uu9i4jK05Kd6QMaV161RMW5I25/xT47gcK+bhVR3nMemoJevWxn/PblBsZoXlJNY6nFbjOXe9qEUjSYi+/0DHiQRK/B8sObwNlflUPmP6PvAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Tlyk88b4Yf7SQV1fS60WfUohTkEkzjx19R1MZdQ+JcI=;
 b=QgqsSAMiexDICneEdFROa87ctxquedqiPxZy2DPZdScPrNoQsSRZ4JT8+85bEjn34H0POvwSTOHcjzEFijP0f3tk1fuM6EXHNdPasg/9/Ir9yu4pO96qm2DcPOHiBffUaNuScB6gP+5hy92r2C2E3wrpOtDZa0Kv6HmP/tYhYAiqwVyUw3OVgr81rS0u7EFceI9PkFKxmIL/48ZQoezu+RcEZoL+vILCyu1bwLjUMBhJsdxLiZE/ZaocSE6EqFfenk5SN9GKmmdEkK0am8Ll877e5yIYKfC7HISc17uGBJ1VMBkbG9pimNS8VQQlDr5YfbgoSJv35h5cO4wVmCzNgA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Tlyk88b4Yf7SQV1fS60WfUohTkEkzjx19R1MZdQ+JcI=;
 b=YqYrrYiuKejPdSPUFfQn/xNEDEk//Pk7LBNhsuBzvAxkYE7SeVaKZCSF/uuwunXbYhz0Z44T13dW8i1sGfJojzUvDMTUm4iwGNufUH830cHFVvuYuX5TM69c90qGbh2e0e7xcMu4rDbB0IbBQLuecwAO56cDc28npT2LKaReJvg=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5279.eurprd05.prod.outlook.com (20.178.11.155) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2073.14; Mon, 15 Jul 2019 17:25:21 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2073.012; Mon, 15 Jul 2019
 17:25:21 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: =?utf-8?B?TWljaGVsIETDpG56ZXI=?= <michel@daenzer.net>
CC: "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
Subject: Re: HMM related use-after-free with amdgpu
Thread-Topic: HMM related use-after-free with amdgpu
Thread-Index: AQHVOy2BuBeOBwIpPkyfmkDLpwDNk6bL7iyA
Date: Mon, 15 Jul 2019 17:25:21 +0000
Message-ID: <20190715172515.GA5043@mellanox.com>
References: <9a38f48b-3974-a238-5987-5251c1343f6b@daenzer.net>
In-Reply-To: <9a38f48b-3974-a238-5987-5251c1343f6b@daenzer.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0040.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:14::17) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 034d530f-77b8-42bf-a6ca-08d7094969f8
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB5279;
x-ms-traffictypediagnostic: VI1PR05MB5279:
x-microsoft-antispam-prvs:
 <VI1PR05MB52793FCA67CC024FBF888F8ECFCF0@VI1PR05MB5279.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 00997889E7
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(376002)(39860400002)(366004)(396003)(346002)(199004)(189003)(8676002)(256004)(6916009)(52116002)(76176011)(5024004)(86362001)(5660300002)(186003)(66446008)(386003)(6116002)(2616005)(476003)(66556008)(6506007)(25786009)(64756008)(66476007)(66946007)(486006)(3846002)(11346002)(446003)(305945005)(7736002)(2906002)(71190400001)(8936002)(229853002)(33656002)(71200400001)(68736007)(81156014)(81166006)(6246003)(6486002)(66066001)(66574012)(478600001)(6512007)(26005)(14454004)(102836004)(36756003)(4326008)(53936002)(99286004)(316002)(6436002)(1076003)(54906003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5279;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 pBtCQesL2QDaZnRUAhk/73RgcWiKskdsWFHd4ZQe8LJf+c4OxUahE+aRiTHWuuTXVl9VQamFl/iKhYUgFvixAHURiIRSLhE/IPt+ZEIFlLN2rsRg5BQdSeTHkNbXMDV3Fv8o1oUmTRk76hbEMx746DGHD/Cx76qkinGoq1h/TI9/pQLBiuEA0Yu/IPVJJckwaD+3w40rWWDZYG6+dALpAczZXhF1zpc7h0FrdftFIenqUWa27ieR1MO0BVQufxMAuDv1q++AVTtSiQmEQzmDxbbtGRfr7CwjvwZIqmOJ+lK6OmGdpd1//2ohCXHKWJWz8uaCHCQ+hAlaI71qII7L3S4h0CR8mhsix9jaYPFWmCnlqJan/oFNwpE8QzMRfExz1RueTbxBBGraIDBnzlHW3mYiqBqcG02GWw/x43VjmsM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <DFDD35BEF84A19498025B2135B14AE30@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 034d530f-77b8-42bf-a6ca-08d7094969f8
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Jul 2019 17:25:21.2949
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5279
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCBKdWwgMTUsIDIwMTkgYXQgMDY6NTE6MDZQTSArMDIwMCwgTWljaGVsIETDpG56ZXIg
d3JvdGU6DQo+IA0KPiBXaXRoIGEgS0FTQU4gZW5hYmxlZCBrZXJuZWwgYnVpbHQgZnJvbSBhbWQt
c3RhZ2luZy1kcm0tbmV4dCwgdGhlDQo+IGF0dGFjaGVkIHVzZS1hZnRlci1mcmVlIGlzIHByZXR0
eSByZWxpYWJseSBkZXRlY3RlZCBkdXJpbmcgYSBwaWdsaXQgZ3B1IHJ1bi4NCg0KRG9lcyB0aGlz
IGJyYW5jaCB5b3UgYXJlIHRlc3RpbmcgaGF2ZSB0aGUgaG1tLmdpdCBtZXJnZWQ/IEkgdGhpbmsg
ZnJvbQ0KdGhlIG5hbWUgaXQgZG9lcyBub3Q/DQoNClVzZSBhZnRlciBmcmVlJ3Mgb2YgdGhpcyBu
YXR1cmUgd2VyZSBzb21ldGhpbmcgdGhhdCB3YXMgZml4ZWQgaW4NCmhtbS5naXQuLg0KDQpJIGRv
bid0IHNlZSBhbiBvYnZpb3VzIHdheSB5b3UgY2FuIGhpdCBzb21ldGhpbmcgbGlrZSB0aGlzIHdp
dGggdGhlDQpuZXcgY29kZSBhcnJhbmdlbWVudC4uDQoNCj4gUC5TLiBXaXRoIG15IHN0YW5kYXJk
IGtlcm5lbHMgd2l0aG91dCBLQVNBTiAoY3VycmVudGx5IDUuMi55ICsgZHJtLW5leHQNCj4gY2hh
bmdlcyBmb3IgNS4zKSwgSSdtIGhhdmluZyB0cm91YmxlIGxhdGVseSBjb21wbGV0aW5nIGEgcGln
bGl0IHJ1biwNCj4gcnVubmluZyBpbnRvIHZhcmlvdXMgaXNzdWVzIHdoaWNoIGxvb2sgbGlrZSBt
ZW1vcnkgY29ycnVwdGlvbiwgc28gbWlnaHQNCj4gYmUgcmVsYXRlZC4NCg0KSSdtIHNrZXB0aWNh
bCB0aGF0IHRoZSBBTURHUFUgaW1wbGVtZW50YXRpb24gb2YgdGhlIGxvY2tpbmcgYXJvdW5kIHRo
ZQ0KaG1tX3JhbmdlICYgbWlycm9yIGlzIHdvcmtpbmcsIGl0IGRvZXNuJ3IgZm9sbG93IHRoZSBw
ZXJzY3JpYmVkDQpwYXR0ZXJuIGF0IGxlYXN0Lg0KDQo+IEp1bCAxNSAxODowOToyOSBrYXZlcmkg
a2VybmVsOiBbICA1NjAuMzg4NzUxXVtUMTI1NjhdID09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQ0KPiBKdWwgMTUgMTg6MDk6
Mjkga2F2ZXJpIGtlcm5lbDogWyAgNTYwLjM4OTA2M11bVDEyNTY4XSBCVUc6IEtBU0FOOiB1c2Ut
YWZ0ZXItZnJlZSBpbiBfX21tdV9ub3RpZmllcl9yZWxlYXNlKzB4Mjg2LzB4M2UwDQo+IEp1bCAx
NSAxODowOToyOSBrYXZlcmkga2VybmVsOiBbICA1NjAuMzg5MDY4XVtUMTI1NjhdIFJlYWQgb2Yg
c2l6ZSA4IGF0IGFkZHIgZmZmZjg4ODM1ZTFjN2NiMCBieSB0YXNrIGFtZF9waW5uZWRfbWVtby8x
MjU2OA0KPiBKdWwgMTUgMTg6MDk6Mjkga2F2ZXJpIGtlcm5lbDogWyAgNTYwLjM4OTA3MV1bVDEy
NTY4XSANCj4gSnVsIDE1IDE4OjA5OjI5IGthdmVyaSBrZXJuZWw6IFsgIDU2MC4zODkwNzddW1Qx
MjU2OF0gQ1BVOiA5IFBJRDogMTI1NjggQ29tbTogYW1kX3Bpbm5lZF9tZW1vIFRhaW50ZWQ6IEcg
ICAgICAgICAgIE9FICAgICA1LjIuMC1yYzEtMDA4MTEtZzJhZDVhN2QzMWJkZiAjMTI1DQo+IEp1
bCAxNSAxODowOToyOSBrYXZlcmkga2VybmVsOiBbICA1NjAuMzg5MDgwXVtUMTI1NjhdIEhhcmR3
YXJlIG5hbWU6IE1pY3JvLVN0YXIgSW50ZXJuYXRpb25hbCBDby4sIEx0ZC4gTVMtN0EzNC9CMzUw
IFRPTUFIQVdLIChNUy03QTM0KSwgQklPUyAxLjgwIDA5LzEzLzIwMTcNCj4gSnVsIDE1IDE4OjA5
OjI5IGthdmVyaSBrZXJuZWw6IFsgIDU2MC4zODkwODRdW1QxMjU2OF0gQ2FsbCBUcmFjZToNCj4g
SnVsIDE1IDE4OjA5OjI5IGthdmVyaSBrZXJuZWw6IFsgIDU2MC4zODkwOTFdW1QxMjU2OF0gIGR1
bXBfc3RhY2srMHg3Yy8weGMwDQo+IEp1bCAxNSAxODowOToyOSBrYXZlcmkga2VybmVsOiBbICA1
NjAuMzg5MDk3XVtUMTI1NjhdICA/IF9fbW11X25vdGlmaWVyX3JlbGVhc2UrMHgyODYvMHgzZTAN
Cj4gSnVsIDE1IDE4OjA5OjI5IGthdmVyaSBrZXJuZWw6IFsgIDU2MC4zODkxMDFdW1QxMjU2OF0g
IHByaW50X2FkZHJlc3NfZGVzY3JpcHRpb24rMHg2NS8weDIyZQ0KPiBKdWwgMTUgMTg6MDk6Mjkg
a2F2ZXJpIGtlcm5lbDogWyAgNTYwLjM4OTEwNl1bVDEyNTY4XSAgPyBfX21tdV9ub3RpZmllcl9y
ZWxlYXNlKzB4Mjg2LzB4M2UwDQo+IEp1bCAxNSAxODowOToyOSBrYXZlcmkga2VybmVsOiBbICA1
NjAuMzg5MTEwXVtUMTI1NjhdICA/IF9fbW11X25vdGlmaWVyX3JlbGVhc2UrMHgyODYvMHgzZTAN
Cj4gSnVsIDE1IDE4OjA5OjI5IGthdmVyaSBrZXJuZWw6IFsgIDU2MC4zODkxMTVdW1QxMjU2OF0g
IF9fa2FzYW5fcmVwb3J0LmNvbGQuMysweDFhLzB4M2QNCj4gSnVsIDE1IDE4OjA5OjI5IGthdmVy
aSBrZXJuZWw6IFsgIDU2MC4zODkxMjJdW1QxMjU2OF0gID8gX19tbXVfbm90aWZpZXJfcmVsZWFz
ZSsweDI4Ni8weDNlMA0KPiBKdWwgMTUgMTg6MDk6Mjkga2F2ZXJpIGtlcm5lbDogWyAgNTYwLjM4
OTEyOF1bVDEyNTY4XSAga2FzYW5fcmVwb3J0KzB4ZS8weDIwDQo+IEp1bCAxNSAxODowOToyOSBr
YXZlcmkga2VybmVsOiBbICA1NjAuMzg5MTMyXVtUMTI1NjhdICBfX21tdV9ub3RpZmllcl9yZWxl
YXNlKzB4Mjg2LzB4M2UwDQoNClNvIHdlIGFyZSBpdGVyYXRpbmcgb3ZlciB0aGUgbW4gbGlzdCBh
bmQgdG91Y2hlZCBmcmVlJ2QgbWVtb3J5DQoNCj4gSnVsIDE1IDE4OjA5OjI5IGthdmVyaSBrZXJu
ZWw6IFsgIDU2MC4zODkzMDldW1QxMjU2OF0gQWxsb2NhdGVkIGJ5IHRhc2sgMTI1Njg6DQo+IEp1
bCAxNSAxODowOToyOSBrYXZlcmkga2VybmVsOiBbICA1NjAuMzg5MzE0XVtUMTI1NjhdICBzYXZl
X3N0YWNrKzB4MTkvMHg4MA0KPiBKdWwgMTUgMTg6MDk6Mjkga2F2ZXJpIGtlcm5lbDogWyAgNTYw
LjM4OTMxOF1bVDEyNTY4XSAgX19rYXNhbl9rbWFsbG9jLmNvbnN0cHJvcC44KzB4YzEvMHhkMA0K
PiBKdWwgMTUgMTg6MDk6Mjkga2F2ZXJpIGtlcm5lbDogWyAgNTYwLjM4OTMyM11bVDEyNTY4XSAg
aG1tX2dldF9vcl9jcmVhdGUrMHg4Zi8weDNmMA0KDQpUaGUgbWVtb3J5IGlzIHByb2JhYmx5IGEg
c3RydWN0IGhtbQ0KDQo+IEp1bCAxNSAxODowOToyOSBrYXZlcmkga2VybmVsOiBbICA1NjAuMzg5
ODU3XVtUMTI1NjhdIEZyZWVkIGJ5IHRhc2sgMTI1Njg6DQo+IEp1bCAxNSAxODowOToyOSBrYXZl
cmkga2VybmVsOiBbICA1NjAuMzg5ODYwXVtUMTI1NjhdICBzYXZlX3N0YWNrKzB4MTkvMHg4MA0K
PiBKdWwgMTUgMTg6MDk6Mjkga2F2ZXJpIGtlcm5lbDogWyAgNTYwLjM4OTg2NF1bVDEyNTY4XSAg
X19rYXNhbl9zbGFiX2ZyZWUrMHgxMjUvMHgxNzANCj4gSnVsIDE1IDE4OjA5OjI5IGthdmVyaSBr
ZXJuZWw6IFsgIDU2MC4zODk4NjddW1QxMjU2OF0gIGtmcmVlKzB4ZTIvMHgyOTANCj4gSnVsIDE1
IDE4OjA5OjI5IGthdmVyaSBrZXJuZWw6IFsgIDU2MC4zODk4NzFdW1QxMjU2OF0gIF9fbW11X25v
dGlmaWVyX3JlbGVhc2UrMHhlZi8weDNlMA0KPiBKdWwgMTUgMTg6MDk6Mjkga2F2ZXJpIGtlcm5l
bDogWyAgNTYwLjM4OTg3NV1bVDEyNTY4XSAgZXhpdF9tbWFwKzB4OTMvMHg0MDANCg0KQW5kIHRo
ZSBmcmVlIHdhcyBhbHNvIGRvbmUgaW4gbm90aWZpZXJfcmVsZWFzZSAocHJlc3VtYWJseSB0aGUN
CmJhY2t0cmFjZSBpcyBjb3JydXB0IGFuZCB0aGlzIGlzIHJlYWxseSBpbiB0aGUgb2xkIGhtbV9y
ZWxlYXNlIC0+DQpobW1fcHV0IC0+IGhtbV9mcmVlIC0+IGtmcmVlIGNhbGwgY2hhaW4pDQoNCldo
aWNoIHdhcyBub3QgT0ssIGFzIF9fbW11X25vdGlmaWVyX3JlbGVhc2UgZG9lc24ndCB1c2UgYSAn
c2FmZScgaGxpc3QNCml0ZXJhdG9yLCBzbyB0aGUgcmVsZWFzZSBjYWxsYmFjayBjYW4gbmV2ZXIg
dHJpZ2dlciBrZnJlZSBvZiBhIHN0cnVjdA0KbW11X25vdGlmaWVyLg0KDQpUaGUgbmV3IGhtbS5n
aXQgY29kZSBkb2VzIG5vdCBjYWxsIGtmcmVlIGZyb20gcmVsZWFzZSwgaXQgc2NoZWR1bGVzDQp0
aGF0IHRocm91Z2ggYSBTUkNVIHdoaWNoIHdvbid0IHJ1biB1bnRpbCBfX21tdV9ub3RpZmllcl9y
ZWxlYXNlDQpyZXR1cm5zLCBieSBkZWZpbml0aW9uLiANCg0KU28gc2hvdWxkIGJlIGZpeGVkLg0K
DQpKYXNvbg0K

