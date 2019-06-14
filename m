Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B625C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:24:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AB2D208CA
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:24:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="a/oW8uBQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AB2D208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E2886B000D; Thu, 13 Jun 2019 20:24:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 493BB6B000E; Thu, 13 Jun 2019 20:24:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35C426B0266; Thu, 13 Jun 2019 20:24:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC52F6B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:24:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s7so1146606edb.19
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:24:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=cAImgzXnowv6qDhqtjF71NCMmyzHuhDMrZiDcAdDS44=;
        b=bayQ0GgeP9/P0xVVF5zkxB6LY4liag1f9+mQBnUj8KM4DEnj0TqpIIwS5zTrgbptn1
         wS+A8Y4ZFAG2VZVeOtN/U2eIlHVGqjuBVm3vL7kfRUklfFUhHvFA4GiMDwdL3vmKS5iG
         x+oYlCtvtbFwM7JOWDCAHj7nltlflb0vuAO+Lm+MQ+PZhvOePpz1vNcBKCq4NfwIc9MY
         eodF8z6Li9AAKLojjkSJFFVjBb8eDZuxa1kUnaA4vFs0V8ZVHwnTblOQBdZErJS+MpT+
         Lr5QjgM/RB+gG1zQrvJpb7umVkHrlUU2IRIZDQ+0T2lB3I26bnVLYUXxhm/jRIStEOZu
         4w/Q==
X-Gm-Message-State: APjAAAXL342Fm4m0c49dQNNwReJctcsigQxVTEYFDQFaTOVlQb7Kd131
	QnC2b684JHXSg4PQ76EKccLsc6CsPeZEA1hTDH3h6BpGEXt8Zf3iwByUkL1HrMG9IPonY83UdQP
	f53y9aTeG26ze0ZIWHhOamgseH6+HE403wIsaV9QTd3UGNHSHWx7HtSOFfXE6Z6NZXw==
X-Received: by 2002:aa7:c5d2:: with SMTP id h18mr96463146eds.110.1560471848394;
        Thu, 13 Jun 2019 17:24:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZhO4i/k2Wi2hdUFVwxD3eC/oKCS6utPhfOS3Lx3AFlPJiVMqMDvsfLiCdr/BL+pVMVhag
X-Received: by 2002:aa7:c5d2:: with SMTP id h18mr96463104eds.110.1560471847832;
        Thu, 13 Jun 2019 17:24:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560471847; cv=none;
        d=google.com; s=arc-20160816;
        b=EI31H+tSbbRMBQlAbKBx8xOIf91NfBfMMCEJAXYRpK6CsW90IOEZyGCaeCLV2JZ7No
         E0ds+BxCnWDORCY1k8RWeLNpTDAPKzN4Pq18gj5yI5RJuAcYMl77P3WjO3Kf3ehob1zc
         2ndJxf8emT4aPU5ET1HCkIIMNMHsIxcnLXfT7AQdzY+Q2j/Gm8TPe2IWwvtJdUwOyzti
         cj4fJT/Ufr9OYI4jg21M4oO08RKECnAZhxoOnLWKjONio96hFwCbUweOjxkou5tCtwEw
         FtNwLqBJLiCrJ1SC9c9E8RJCE66n7ABCGS2k3Ka7XiurEc/NlrajdKTd6QlGQnqDIuX9
         IXIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=cAImgzXnowv6qDhqtjF71NCMmyzHuhDMrZiDcAdDS44=;
        b=hF6Q4lHVxkDKlWRx8zIstzgrY7zeCa7MZcleEtleE5z1ZPvBl+/q3Lxk9pRpfEepRO
         9iGWY6X41agoiPP90svyEX0v3JZLo9y8aoeYjMFwAQaERVy1ueyFt0zT3Ga4XGEwMnbq
         ex1s8/oJLO1sf4JcNG8/tZj4SR9xNNHa9TUDdHIecsxncb+HfD4D3+Ikjq5uoVQa1D07
         QJWktMxQTe3wQP4EbM3xPPnxy8HO0LIYmoG/1KOgUD5m4BJoAuAoZ1iSwNy1BKHkbccv
         3cJ661C6Ihv1L37UnxAa4MXQ5WROlIcDc5L2ryeacXJR+12YJ2GvZUUvJikTa7LfSVF0
         TaqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="a/oW8uBQ";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.6.61 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60061.outbound.protection.outlook.com. [40.107.6.61])
        by mx.google.com with ESMTPS id x62si921818edc.47.2019.06.13.17.24.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Jun 2019 17:24:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.6.61 as permitted sender) client-ip=40.107.6.61;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="a/oW8uBQ";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.6.61 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cAImgzXnowv6qDhqtjF71NCMmyzHuhDMrZiDcAdDS44=;
 b=a/oW8uBQB1y3cJMNZOZdFMpTw65gCxejE6t7g+GQEdfiSVYl1g8e8O5bHmyvzR8MZ92W7Mmg4v5Oc4coEY3Q4BrvBplxJWJ6MjIbCpx6OaxRXpxCgRflLiNiy0z8dnm0tP+93f3cg0vF5uKtJHuApzN0nnJsFquSZRVE0sdmPAM=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4320.eurprd05.prod.outlook.com (52.133.12.148) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.12; Fri, 14 Jun 2019 00:24:05 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Fri, 14 Jun 2019
 00:24:05 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ralph Campbell <rcampbell@nvidia.com>
CC: Jerome Glisse <jglisse@redhat.com>, David Airlie <airlied@linux.ie>, Ben
 Skeggs <bskeggs@redhat.com>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] drm/nouveau/dmem: missing mutex_lock in error path
Thread-Topic: [PATCH] drm/nouveau/dmem: missing mutex_lock in error path
Thread-Index: AQHVIkXN8eYXmKvfbEike7oriK2vlaaaSl+A
Date: Fri, 14 Jun 2019 00:24:04 +0000
Message-ID: <20190614002359.GI22062@mellanox.com>
References: <20190614001121.23950-1-rcampbell@nvidia.com>
In-Reply-To: <20190614001121.23950-1-rcampbell@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTOPR0101CA0059.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:14::36) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4bb8361b-ff68-4286-7658-08d6f05e9b95
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4320;
x-ms-traffictypediagnostic: VI1PR05MB4320:
x-microsoft-antispam-prvs:
 <VI1PR05MB4320DD8E3FB7FDC1A1C21F98CFEE0@VI1PR05MB4320.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0068C7E410
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(136003)(396003)(376002)(366004)(39860400002)(199004)(189003)(6506007)(386003)(68736007)(305945005)(54906003)(8936002)(86362001)(81166006)(81156014)(25786009)(8676002)(2906002)(102836004)(7736002)(26005)(186003)(4326008)(3846002)(6116002)(486006)(478600001)(6246003)(6916009)(446003)(11346002)(53936002)(1076003)(76176011)(476003)(2616005)(6436002)(6512007)(52116002)(99286004)(14454004)(64756008)(66556008)(66446008)(66476007)(5660300002)(316002)(73956011)(6486002)(66946007)(71190400001)(71200400001)(33656002)(4744005)(66066001)(229853002)(36756003)(256004)(14444005);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4320;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 OH4rhpR5cFF4RnjFeJHTsT/RtqndUbX2mQZUNK2YZeLkTeXw2JdfEoDUDFNkchTzWJxAbjI8Ihv2SjWcNQ0+xjahfkTPm3W3JL2UlSE1+7dRxv5r12z7wySspEoqd3dyLlF33mZI8D1a4hOJ0D7iZ12wvQdEe1va21K8F53LxuNzKWFnx13TOOKvCDhMibYwlRWtNOA593YlS91DjVPjKjCsM4Lyagvz2vRjndxjSTG6K4F/Fz2qe38uDpVaFfTkoqLXQTopAUV2Snyqe3VbZlPTHDkuX6Mt0+X5/9BAjrqKC3Cuoorc65sGvTZ0dH6PGyy6z+MzHW5VTwZocCRE7jDgFdqvY880t071cAhndTqUxdunJ+XKXTcgY89wrGOmy1UCmLBBRwaefWHgNF1bxjIYfZzKiASkzYLVGh4vydM=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <563E69CBF7DBDB4381F3D484B873273B@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4bb8361b-ff68-4286-7658-08d6f05e9b95
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 Jun 2019 00:24:04.9798
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4320
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 05:11:21PM -0700, Ralph Campbell wrote:
> In nouveau_dmem_pages_alloc(), the drm->dmem->mutex is unlocked before
> calling nouveau_dmem_chunk_alloc().
> Reacquire the lock before continuing to the next page.
>=20
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> ---
>=20
> I found this while testing Jason Gunthorpe's hmm tree but this is
> independant of those changes. I guess it could go through
> David Airlie's tree for nouveau or Jason's tree.

This seems like a bad enough bug to send it into -rc?

It probably should go through the normal nouveau channels, thanks

Jason

