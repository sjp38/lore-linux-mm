Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2BAEC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:26:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96FE42133F
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:26:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="MHijS0oY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96FE42133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E97D6B0003; Thu, 27 Jun 2019 12:26:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29B118E0005; Thu, 27 Jun 2019 12:26:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13BCA8E0002; Thu, 27 Jun 2019 12:26:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B84816B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 12:26:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s5so6395768eda.10
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:26:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Jq7Cu3ouaiLqX0IyGygS1qxPemZhEAEBbrhyRDwG1Is=;
        b=bnWlTrR5gfp3zc6agVpeWnZEA2JtSy0MqBua8jGDoDw+7QkOpqgl+Qu4q3qe41V+SM
         f386gj+YxkPCO7/4Z9ha8HQmlorsoINfzDuvwxDKx5QCkncO8ADYyaQwLQbNbahHF9p4
         +YJ593WklW90eFCry+MEyh0r0mRfx9IB9DJAk/EsCmpkzBfHo3FYHWMynGga8U62+JkH
         Gm6+MndzXpHmCY8WyBljByIynyMLWblQB0vJWcAIUNXXWRWudgbXSIQAm3TbkbAvTOSR
         VfYKmNUAhlL14/th7EFfASwF97tnuYbBGYjiVBdRGd9qaJsphzNWytDH30ijx17O84Nf
         yuHA==
X-Gm-Message-State: APjAAAWu9pEjAR9eyMxkaiNZSPFgnbR+3XOB7fhdANevdATFw3dJSFIZ
	4RoPWPCUpVJ7QxyeQwSXGy15TYeEe1WPbkhZuWV1daOngtaAdv6ZUBXnVPA0ucAZoTbTpfMIoU7
	vO0oGS1hEfSF9NnPCU7m0q6+8d2dfYuPLKPOSiZsfEPfS3bqzO9lNtaERhXRsYw1GJg==
X-Received: by 2002:a17:906:27c7:: with SMTP id k7mr4076889ejc.91.1561652793288;
        Thu, 27 Jun 2019 09:26:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQrSUimp5PpfE32G7I9g5gpXzIrJFTbZW8qIIWnarhhjXRY9GdXaU88KoL7tfNE0kFL4CC
X-Received: by 2002:a17:906:27c7:: with SMTP id k7mr4076852ejc.91.1561652792653;
        Thu, 27 Jun 2019 09:26:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561652792; cv=none;
        d=google.com; s=arc-20160816;
        b=qs7HxLK0SG1UJhH2/c6q2jg4YIEXchqBy9LDbb/0nCbLoKjB1OLTcHgSbeoAfkeHeL
         uwI+uIDhnYCUyZsNAwQwH6iG2p6FYsN1BaSzISZrSh/ut6tXqP/lmSctXhd1ZPVWl2oa
         Dq17bFW2w/tCtxvtPcd0nmQzYDTeerYsgRQFbmGX1ZzxK2qmkop2eC8q4GL9g8LJmYAQ
         gZyL0qL0hc4k4xJrANLZGu0f8arZ4leRtUG4KUOiyDFFGLk3qD2UaRbN7pN22yGDV2RJ
         VhwH0fZuBS+gBuHo6ijcmf3EhKW295Xrkx7bBgRP0TsAW2igzop0dkVPqqkSks9L+4ZN
         y1Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Jq7Cu3ouaiLqX0IyGygS1qxPemZhEAEBbrhyRDwG1Is=;
        b=B8fXoWm0nVHuan+eQR3lRiyn5VnRYzVLzNJUywr1LKDkADLJea+ikY52zuo9uLXMa2
         D0CE3r+rr1wOJKvxG8+jYbgU1r8coTpFgdC5NW5Il8TnHevt60t8ewVO4LIEZIerSljM
         r49451STE7IHprt7qJQUfUnt8hJkJOZnU9/r/tbhNt5RIuLqWjk09GmYIr5yD/gVc7sP
         1LsK4s25foiel/lap/kLe9u0ggVCfxi2SXGtO7+RGUa1UBDi5eMRY0Co5my6DoLolqai
         ePX6smTI3hmeXXvyqdj4daWmnjhHq2T14gfU3VPoMzw1OsUxs4s//K2xt7c0pfBa7Enq
         bTBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=MHijS0oY;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.72 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10072.outbound.protection.outlook.com. [40.107.1.72])
        by mx.google.com with ESMTPS id f17si2420665eda.220.2019.06.27.09.26.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Jun 2019 09:26:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.1.72 as permitted sender) client-ip=40.107.1.72;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=MHijS0oY;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.72 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Jq7Cu3ouaiLqX0IyGygS1qxPemZhEAEBbrhyRDwG1Is=;
 b=MHijS0oYLxu5vC+EWNq92BwDqgOvHOLP1gLfS8iXKfrGgNfN9WJTK0hB1ynANWCXGoyqlhu0/QlDM533DGiRJA+Rh+Ea6zZVzIf52jqvqrhNwaRr/zhF2HfgU1T3QeUrRV+nyqmmEfeQaLdmZjCRPEQiJmdvd19qZeQoanou9uE=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6032.eurprd05.prod.outlook.com (20.178.127.217) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Thu, 27 Jun 2019 16:26:31 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2008.014; Thu, 27 Jun 2019
 16:26:31 +0000
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
Subject: Re: [PATCH 20/25] mm: remove hmm_vma_alloc_locked_page
Thread-Topic: [PATCH 20/25] mm: remove hmm_vma_alloc_locked_page
Thread-Index: AQHVLBqmxPw5VkIwH0Gf/TUCNUoY46avseoA
Date: Thu, 27 Jun 2019 16:26:31 +0000
Message-ID: <20190627162624.GE9499@mellanox.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-21-hch@lst.de>
In-Reply-To: <20190626122724.13313-21-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR08CA0045.namprd08.prod.outlook.com
 (2603:10b6:a03:117::22) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [12.199.206.50]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 01f337c1-21dc-4ca8-4b59-08d6fb1c364d
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6032;
x-ms-traffictypediagnostic: VI1PR05MB6032:
x-microsoft-antispam-prvs:
 <VI1PR05MB6032F49F38A52C3FBF316643CFFD0@VI1PR05MB6032.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2733;
x-forefront-prvs: 008184426E
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(979002)(376002)(39860400002)(346002)(136003)(396003)(366004)(189003)(199004)(6506007)(26005)(6916009)(64756008)(186003)(6486002)(36756003)(71200400001)(71190400001)(25786009)(86362001)(73956011)(66446008)(66556008)(33656002)(4326008)(4744005)(66946007)(8676002)(7416002)(14454004)(66476007)(1076003)(476003)(81156014)(478600001)(256004)(102836004)(6512007)(5660300002)(486006)(305945005)(7736002)(6116002)(229853002)(316002)(6246003)(54906003)(2906002)(66066001)(68736007)(8936002)(99286004)(3846002)(76176011)(11346002)(386003)(53936002)(6436002)(81166006)(52116002)(2616005)(446003)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6032;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 /wKHS2Wcqi+iX24iwXUD8ArjOm9W3DfrSJrbk8SW/dAF176EK8nGoG4iNVHmTibsz8VHuwClL+aIp65i7lxuQFO0AyDfq1V2xvjK5FVX/MwyJYhX6TOLkhroZJnvUb7+7rShZFQgt6bdixcvylD0nFpEoLmiK0WQTscQ97Vo5fRqIQdB3kKUMLmzp2v2JaYLOZhH8r5TXLJjb7Uhg+msPNpdbraZXFXiZPJ2rRRj32tBOf0GDwdkC2O9ShEeGhfCSSeWRBx4KKxSthRvRvfsGDmJv0kCUnxe5qdCK8L8ZX2Y7wi8CdVGcYCjXQi60vtDNxoZSvNpX5+PtYKr0i2Nms3pwYQejTxXaODp1CJe4Zmd73q3oBdnP5VavdWarJU0x5j3pUWp0a1Hyvjq+0lAU7UmpENfOR3TZebAbITisM0=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <6EDBED9EAD9A054886AF3DDD66AD8103@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 01f337c1-21dc-4ca8-4b59-08d6fb1c364d
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Jun 2019 16:26:31.1693
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6032
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:19PM +0200, Christoph Hellwig wrote:
> The only user of it has just been removed, and there wasn't really any ne=
ed
> to wrap a basic memory allocator to start with.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/hmm.h |  3 ---
>  mm/hmm.c            | 14 --------------
>  2 files changed, 17 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

