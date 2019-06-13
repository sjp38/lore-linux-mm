Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C608C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:18:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D94420896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:18:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="JE2ZAoEv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D94420896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D17FA8E0002; Thu, 13 Jun 2019 15:18:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEE968E0001; Thu, 13 Jun 2019 15:18:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB6208E0002; Thu, 13 Jun 2019 15:18:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7085C8E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:18:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so199497edb.1
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:18:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Gn0XRHQHsCKYYQ7MbFb4+orPe8vwTjckiXF1+JOZDCI=;
        b=V5nnqgMzFvxu00+RXsbgtb1Oi2L9SNU13xuGnJg5WZyQnmvEezFU+yHlouJPdXKOuf
         TcCIpUH8R3ZyT+OBx5RoJAF4Yc0BK83x4k2KsRwUpKdfMQlANihdppnpIeA83EOnP3FA
         d4rYYetElweP8TonDWSSBBYLP/At9HykFJPFXbz/QnMZytLKb2rGZEH5mKCHUA5Zux/Y
         zXYYsXm67wtttEcltxDbE0UfFMF88nJOIxMjfnDxI9r8BqoX5y1mFEnDOWoIxPBoV0/z
         +lsk6smSb8vVyIrV7LIB0Oo4jj/ApVZMIlMSsFbhC+LmKPy9pH7p8H/lK2S8cl+s0M+N
         kuOA==
X-Gm-Message-State: APjAAAVZnPjx30Rwtj6G7NJcqrGKAhJ8AOnexYl4m7aCwCr7pBtxjcSw
	tCixX8FfxzVFuqyMPSuDYKluyNdIuIY+idUuDButiwV9RFIkF41etSPQBAwlZQoy5Z98WMYRPGI
	bFqJ/jpn7nj8y/5Z2MMGXVIlJs6C18iosrd2+/qrv5BHVQZRJKMY52qRVRuueXOudog==
X-Received: by 2002:a17:906:7632:: with SMTP id c18mr37096614ejn.266.1560453519032;
        Thu, 13 Jun 2019 12:18:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxs52DgWxi115ecXyZaQ9l/YEgbiGMfZnyH+LmLjMbMy/0Ttiil4o1abrf33Dpg82Wa4DWH
X-Received: by 2002:a17:906:7632:: with SMTP id c18mr37096562ejn.266.1560453518242;
        Thu, 13 Jun 2019 12:18:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560453518; cv=none;
        d=google.com; s=arc-20160816;
        b=yi3waQxtpNa93WHrJeqPGCrRINoAzseQFrpwbKlQEN+0N4t6T7HfEIaqe/t03qRWPe
         5NNzQS9wfz3Smq8Fy07EkBJL3zYpCs9dSky4YUanoCWdTjlGupjZYjlHVbXLpuXUPK/m
         ugXqtT55f3vKFIez3d/NUN9TtPgWs2p3RdR5OYRpHXzQr1fef7JzqxwU7t7cSRzXpPiR
         w+U8ecOJxCd5d06NUtxSto0YbRKD3rniOWP5cxNSOFMYS5L3QL1LKEFtFnlYyc7mDHta
         SvV7DsTy9zzqd58DoQPVbu/wRGBR/LtyGoHMTCKzeEOManw6T6OCOJIpvMUodW+Trw0V
         RioQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Gn0XRHQHsCKYYQ7MbFb4+orPe8vwTjckiXF1+JOZDCI=;
        b=pDsVXcE7u/KkPVJMfprDD+SX1u4UM++Ue/M6M5zBbZK61q+A24Wiu5oyYTrHck8r0D
         rm6jrRs74HEAeO2VlscuX6o4GUggbzdoZoEmyRIVAeoEuVLAuFB3/2XC6dZYjFxp2SQS
         jqi30BNY5ECmgASlJevleV6BM2TqbhMtqzArU19UCHUAxY6liY2t92S5oWoKUzYFVouX
         ZnBodiCiPeeAeqq6CouFnKVRztN4+5XVcHedbsGNkGcv1yHizGnX2qBOPILGONPu9+aQ
         sETfkVzhVkk/nZQc+/1hzKRD208m62FZ8PCNQQancMFc2Nv1/zALIkvGiN0Gao97DuTN
         FLvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=JE2ZAoEv;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.85 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140085.outbound.protection.outlook.com. [40.107.14.85])
        by mx.google.com with ESMTPS id w27si360273edw.366.2019.06.13.12.18.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 12:18:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.14.85 as permitted sender) client-ip=40.107.14.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=JE2ZAoEv;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.85 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Gn0XRHQHsCKYYQ7MbFb4+orPe8vwTjckiXF1+JOZDCI=;
 b=JE2ZAoEvKjfR8HiDlxRBnqpf44FucC6/Ut0TOrVfWTFT7Li85DVE4y3CPsTOdE+VgemGpQSSB0Nr8x3zW9S7AL4siG9nHIvDBbbF9diHhAgdny9jlPfnjZAp1hg7R1rWDeb3JtgFIRfmVfpbAeaaMOrEz6F312C7bzLapp/cUEM=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6431.eurprd05.prod.outlook.com (20.179.27.213) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.14; Thu, 13 Jun 2019 19:18:36 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 19:18:36 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 07/22] memremap: move dev_pagemap callbacks into a
 separate structure
Thread-Topic: [PATCH 07/22] memremap: move dev_pagemap callbacks into a
 separate structure
Thread-Index: AQHVIcyDw9xwI/Mm4EyaKLgP+NlRp6aZ9fgA
Date: Thu, 13 Jun 2019 19:18:36 +0000
Message-ID: <20190613191830.GS22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-8-hch@lst.de>
In-Reply-To: <20190613094326.24093-8-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0016.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:15::29) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c5665e8b-42b6-483f-4da2-08d6f033ee8b
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6431;
x-ms-traffictypediagnostic: VI1PR05MB6431:
x-microsoft-antispam-prvs:
 <VI1PR05MB643182491356C4DBAF72DD47CFEF0@VI1PR05MB6431.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1169;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(376002)(346002)(39860400002)(396003)(199004)(189003)(71190400001)(186003)(36756003)(11346002)(446003)(71200400001)(14454004)(305945005)(66066001)(6506007)(478600001)(76176011)(53936002)(52116002)(316002)(386003)(81166006)(54906003)(476003)(99286004)(2616005)(102836004)(8936002)(486006)(3846002)(86362001)(6116002)(1076003)(8676002)(558084003)(4326008)(81156014)(66556008)(7736002)(7416002)(66476007)(6916009)(25786009)(2906002)(66946007)(73956011)(66446008)(5660300002)(229853002)(6486002)(26005)(6246003)(64756008)(33656002)(256004)(68736007)(6512007)(6436002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6431;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 iWI5spS7w2QJSos+Acyk0mhUS4x786Nzmhq9nBWZJfIgq5mZ00pPuEhRM1QrPO0/A5zugseKUQTlJDUrW2/+LT7LeSgHzpgN5+7ZCWtvzIbO2NhaqLzU+tUqVe3ZsUtbQYbNc27ibTqNCB9tYAo45UYiW+cFlUfB4hdPoZbymAbiACKH3gxd8bKNnswT0IFqMbvSXQkGTbm/QWYVpODtXoMlMy5JLjXgRQxg+6WOTHQmnHTeL+F31uB8QglOIKmDDaKALJaDM1P+2ZEoxcWdlkNLR2+YgB5EdioE4E8qajCC5xLyn5amDP/+anCm9tLY74LjyO9b51ZTQlTBBhzBsk5vV1zsGWXapz3GHeUepGUAEpEaSs/PAy4P4Z9BsTASRcJwDjjou5eaax2Ad3kMg5nguEXxlG1ynhhU1B0IOc4=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <B5D9BF5FD8C3BF4E8DFA048B14902A45@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c5665e8b-42b6-483f-4da2-08d6f033ee8b
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 19:18:36.1185
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6431
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:10AM +0200, Christoph Hellwig wrote:
> The dev_pagemap is a growing too many callbacks.  Move them into a
> separate ops structure so that they are not duplicated for multiple
> instances, and an attacker can't easily overwrite them.

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

