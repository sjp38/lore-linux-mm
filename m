Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F321C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 15:49:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1941425D22
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 15:49:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="ibTaG1qk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1941425D22
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5E3D6B0270; Thu, 30 May 2019 11:49:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0EE26B0271; Thu, 30 May 2019 11:49:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D7DE6B0272; Thu, 30 May 2019 11:49:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8C36B0270
	for <linux-mm@kvack.org>; Thu, 30 May 2019 11:49:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d15so9214902edm.7
        for <linux-mm@kvack.org>; Thu, 30 May 2019 08:49:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=N4VhIAMP+vYb+hX1wa84OBgkG1r0ptiv6LE3EMVT/A8=;
        b=ikLWvhQuTQej0yJeDOyXikB5RQD5qw/nk1UUnP1Inzbc6w0ZepQi38fXi401gQszbI
         bzIzgqJUj09KynJsXz5J2XNk75V/b8U33NyWcQc5Gak1GBaemLht5AL7p/MOnAIIpwbV
         LDhDAQMDqzgax9tze4DPlGtrlDkIc11SY5yhdZv5a1DIqbF96mjfcM2IJKt/tAtN1Tr2
         X43cwghiFwIM8IIOCJ9WPlbTiEhyaLru6nouRjbuIQifsNCdoghWSG2EsYxig6+LfS3F
         BlAsWDIJYnGLIqUz0KN85pFYdlfFN2AsMmRZYmrXp0IVmKpd/Zf/SgCqHU5wTmPRoLjR
         FqXg==
X-Gm-Message-State: APjAAAUidJbSsoe0K6xhSztahQ86dQtAUMyPwUN97rQxcNyjjG6bysiz
	/p7RpLtIpQAPjv4D2z9Pr1bvbviIn6j0jOHBbDnUgDoFQ9H3cj/0QcoFmntqx6GD0uBktGClRFc
	7zpJkWdQYRHE4tjwupEyDRPmc5+6FYOwUUrV/P3XrNpmMJLPdcjFoPLksLKYr2WICsQ==
X-Received: by 2002:a50:954c:: with SMTP id v12mr5493471eda.227.1559231371732;
        Thu, 30 May 2019 08:49:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwneJKjIYQki3xPTrLHjzy818Y43f62DAjgg2EJnzWFLf0w1C2W+LZULp64TbR7cibiwWiN
X-Received: by 2002:a50:954c:: with SMTP id v12mr5493398eda.227.1559231370894;
        Thu, 30 May 2019 08:49:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559231370; cv=none;
        d=google.com; s=arc-20160816;
        b=LyhbJ2oyHuwbdCUGaps5ycdr/3idWdwpRpB/F7bDwFEEKpTU1e+9KDaGyBvdhCAfmb
         G22SDRboYIhyYcxscg1Xy7ueDxgwpxiYFz3ISjRIZWhvstDg74qjMIFZGk2lbA88O0Gw
         QOp2JiKhjK2S+QsB3klTpvd4B2rXRGs+xrrNd75OUGiwpS28Yg/3n09cqigLNMMHyzG1
         bkxup/lNaq3cJP5kK97yeyLtOAZDzQoAnkMZ3F5kkMhBu3qA+Rd8frFKBNCi6cWcyF2g
         Zf+UOqvuqjT1AniuysUI+crHc7cTU4xk8eBoznPnA/B70wde+l3zzZeY1li+QkZvlkg/
         pY4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=N4VhIAMP+vYb+hX1wa84OBgkG1r0ptiv6LE3EMVT/A8=;
        b=e88vIogH2kv7tl919g+oN/m8qdjTwQhBuxGnnnCMpH5KLGEqlmo64/aK6qsR255Wad
         Iwj1cNJH33xgYlRHZjsFaQOpWselSi71iUNXmRcld2KOEyyofxs33mWr5HwhknwsfQud
         Z1AK7ORuOREOlhWx7HJM/Br3oJ175VMhMo29Zenl0XKQaDjayKm0rBL7hltPcLYLdlgo
         zY07+IlqgMSUW/D1NCpD+yMlGvVzh0jrvbHuPO4+CTUYQwNjYOYqdwgTGeUFhi672hFl
         3kC4p0rpcGtNzQvQtXNpwGVcdcURPMSn5Fi9VqXz36bEYvKYbE3yUwxI+Dgy0RnypHqi
         3aKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=ibTaG1qk;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.43 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150043.outbound.protection.outlook.com. [40.107.15.43])
        by mx.google.com with ESMTPS id c47si2255563edc.304.2019.05.30.08.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 08:49:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.15.43 as permitted sender) client-ip=40.107.15.43;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=ibTaG1qk;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.43 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=N4VhIAMP+vYb+hX1wa84OBgkG1r0ptiv6LE3EMVT/A8=;
 b=ibTaG1qkyX1q/WC9GufXcj5fQ9YrBrvprCTD5LAO1Wc2FHhWIZoUParniw8vwjBcrytDod1DCmH0fV1Yp9uIvowVzkvQiu9UI7/N13K89YE56yGABhvIv10Rr2IEECHUZeTgynr+DAAkIDYMTJ5g7EgXLRUUlpYR19XxfwK5j1k=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5038.eurprd05.prod.outlook.com (20.177.52.75) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.16; Thu, 30 May 2019 15:49:28 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1943.016; Thu, 30 May 2019
 15:49:27 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Yuehaibing <yuehaibing@huawei.com>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?=
	<jglisse@redhat.com>
CC: "bskeggs@redhat.com" <bskeggs@redhat.com>, "airlied@linux.ie"
	<airlied@linux.ie>, "daniel@ffwll.ch" <daniel@ffwll.ch>, "jglisse@redhat.com"
	<jglisse@redhat.com>, "rcampbell@nvidia.com" <rcampbell@nvidia.com>, Leon
 Romanovsky <leonro@mellanox.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH] drm/nouveau: Fix DEVICE_PRIVATE dependencies
Thread-Topic: [PATCH] drm/nouveau: Fix DEVICE_PRIVATE dependencies
Thread-Index: AQHU9Smp7DtPqq1csU6J+upeBQ7IX6aEDxgAgAAFFYA=
Date: Thu, 30 May 2019 15:49:27 +0000
Message-ID: <20190530154923.GJ13461@mellanox.com>
References: <20190417142632.12992-1-yuehaibing@huawei.com>
 <583de550-d816-f619-d402-688c87c86fe3@huawei.com>
In-Reply-To: <583de550-d816-f619-d402-688c87c86fe3@huawei.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR1501CA0010.namprd15.prod.outlook.com
 (2603:10b6:207:17::23) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: eb64e4a5-1883-4fa3-abde-08d6e516657f
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5038;
x-ms-traffictypediagnostic: VI1PR05MB5038:
x-microsoft-antispam-prvs:
 <VI1PR05MB5038A0DBC9732A6345508206CF180@VI1PR05MB5038.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1186;
x-forefront-prvs: 00531FAC2C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(136003)(396003)(39860400002)(366004)(376002)(189003)(199004)(53754006)(6486002)(110136005)(446003)(486006)(66446008)(53936002)(86362001)(14454004)(6512007)(478600001)(54906003)(7416002)(7736002)(81156014)(26005)(186003)(1076003)(8936002)(8676002)(4326008)(6436002)(3846002)(305945005)(33656002)(66556008)(5660300002)(6116002)(64756008)(81166006)(2616005)(73956011)(66476007)(2906002)(25786009)(102836004)(36756003)(71200400001)(71190400001)(66066001)(256004)(76176011)(99286004)(316002)(386003)(229853002)(68736007)(66946007)(14444005)(53546011)(6246003)(52116002)(11346002)(6506007)(476003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5038;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 mD+yXMynfy4cxpwEDWUiTZK3y7e3HTcdtyeyxxhGMJYJCRoGQjggi/MVCYWDaEZhTs6JRyaO65Im0wo83Z7roj+akgVuSIaSi/tUocwZyEnlBMIhH+kT540cISNX7AQnsgvYJxOWqxXlHrvHnDs+oNoF+mLvxbpKeoChDYV/HwBsqbk8TOgVfqHsmDPMhu6nXgF85ULOdp+55FuClaG6W9OBO40IuayZ60NDABOdE2ofDNbpHDLNr7SOhbnZXe4wQC2qSZ/6BrKjUsHVNxQBIo+HyQFVZGCs6lhpfcAKMCwljEFtq957iVez48KViXGjvLMCslgwnV1JN2Bh7tLJATJGvN0Wg3jzvcoPxTJWizt1z7WllEXvcnqizgfXvP4Dlzc9QgcNgtOaNRsA/V/msr+SYHruZjBesDW69tYjOxs=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <56987BA9B86175409FE65B63660189BB@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: eb64e4a5-1883-4fa3-abde-08d6e516657f
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 May 2019 15:49:27.8018
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5038
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, May 30, 2019 at 11:31:12PM +0800, Yuehaibing wrote:
> Hi all,
>=20
> Friendly ping:
>=20
> Who can take this?
>=20
> On 2019/4/17 22:26, Yue Haibing wrote:
> > From: YueHaibing <yuehaibing@huawei.com>
> >=20
> > During randconfig builds, I occasionally run into an invalid configurat=
ion
> >=20
> > WARNING: unmet direct dependencies detected for DEVICE_PRIVATE
> >   Depends on [n]: ARCH_HAS_HMM_DEVICE [=3Dn] && ZONE_DEVICE [=3Dn]
> >   Selected by [y]:
> >   - DRM_NOUVEAU_SVM [=3Dy] && HAS_IOMEM [=3Dy] && ARCH_HAS_HMM [=3Dy] &=
& DRM_NOUVEAU [=3Dy] && STAGING [=3Dy]
> >=20
> > mm/memory.o: In function `do_swap_page':
> > memory.c:(.text+0x2754): undefined reference to `device_private_entry_f=
ault'
> >=20
> > commit 5da25090ab04 ("mm/hmm: kconfig split HMM address space mirroring=
 from device memory")
> > split CONFIG_DEVICE_PRIVATE dependencies from
> > ARCH_HAS_HMM to ARCH_HAS_HMM_DEVICE and ZONE_DEVICE,
> > so enable DRM_NOUVEAU_SVM will trigger this warning,
> > cause building failed.
> >=20
> > Reported-by: Hulk Robot <hulkci@huawei.com>
> > Fixes: 5da25090ab04 ("mm/hmm: kconfig split HMM address space mirroring=
 from device memory")
> > Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> >  drivers/gpu/drm/nouveau/Kconfig | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/=
Kconfig
> > index 00cd9ab..99e30c1 100644
> > +++ b/drivers/gpu/drm/nouveau/Kconfig
> > @@ -74,7 +74,8 @@ config DRM_NOUVEAU_BACKLIGHT
> > =20
> >  config DRM_NOUVEAU_SVM
> >  	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
> > -	depends on ARCH_HAS_HMM
> > +	depends on ARCH_HAS_HMM_DEVICE
> > +	depends on ZONE_DEVICE
> >  	depends on DRM_NOUVEAU
> >  	depends on STAGING
> >  	select HMM_MIRROR
> >=20

I'm expecting to take a patch like this into the new hmm git tree once
Jerome sends his Final Solution for the kconfig problems.

Maybe it is this patch, Jerome??

Regards,
Jason=20

