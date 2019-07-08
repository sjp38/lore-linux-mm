Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFB2FC606BA
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 14:09:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8770E216B7
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 14:09:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="BNXst4q3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8770E216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ED838E0016; Mon,  8 Jul 2019 10:09:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 177BD8E0002; Mon,  8 Jul 2019 10:09:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F322D8E0016; Mon,  8 Jul 2019 10:09:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0458E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 10:09:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so11535671eda.9
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 07:09:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=F9SnTdGJOzPh7PEhqpPLkWfo+Z7SasLHzoEWCLSlDVw=;
        b=DieWozTAmGkO7gu1GoSz2yIsfgBbImmiwlmruP0EFL1vOoR15NZJS92ZCjSDpJnNfV
         LwzsWq7PFAxIWcyvTiBwcuyOPWFdNa8H4WDsByRR9s29YLUpkZZvUKi5sSLbIBhWI2o3
         ju0NLwMomPfbOjJ45k660N9XEmB2KPxTrRWX1Y2mY0nsLdgA2YQCKojWG5Ekf1WEoSCp
         Uw2Ui9jyCeBkU/DhMcUoHFg6HSODmY54sLDvPAi1mC7mPQglGC3EjjoGj3/vbeXu1SLW
         VA+s1t4Uj9H8sJcpSlmzE/gLcTozfJqf6QdTFJNAM7RGWCeSs0P9+4w0ulNPMZ1DMolm
         xKgQ==
X-Gm-Message-State: APjAAAVifG/OkE1xqbo6GpR0v7EzE+gWB2q4pTfvdt7hrh9ZaJ1LBaAl
	OoPy1IpWm8NV1s0LLr/5ydYz31CRfzDO0e/0gGxaayffCVIGQrljEue6WWpVogrW1wMwCbTIOU0
	WXU/r+WIHULYYKIuwweX1I2O8/cNSx8AAY7EMnyM3GyxStOU70535yFjzbEu2TLWeRg==
X-Received: by 2002:a50:d2d3:: with SMTP id q19mr20470005edg.64.1562594983218;
        Mon, 08 Jul 2019 07:09:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLjS3HelpZLlT3m8qLPFhf7Ij+MAWcFvD4cXmA+W3IFXbSDG1V324My/FORpw9+xdHkU6s
X-Received: by 2002:a50:d2d3:: with SMTP id q19mr20469885edg.64.1562594982012;
        Mon, 08 Jul 2019 07:09:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562594982; cv=none;
        d=google.com; s=arc-20160816;
        b=mGo618nC1ceIN5Rvn/FvUqthVXj2T6RPAF4cI564wUXPmqsBACvFWM+CIY9jM3X44m
         S1KBUOCRvYRaPNi+PHK1wJe0W2qei/mK9GGWsq/nBcO9PigUAExeRLthclCw4mFOOQ+6
         AvGG3rnyyXycRB0jotXA/SwyntWqYdKgoUxNLUDOI4a/wOyUOPUNnroh/Fo+voORcKr9
         LsCpsTeAgY1XhckXk+7ZJkHr3rietEzrySBr+PVhVQG3K8TMmQVGfsyH6qeMeFLeyEXI
         ZzDjeyNQs6cu+UFOJmKUuGFtPLeFEdb1SF4zEAOdn/uxlCSmzTx5/uE1eSm552V5umRq
         lrrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=F9SnTdGJOzPh7PEhqpPLkWfo+Z7SasLHzoEWCLSlDVw=;
        b=R1HFwMR2FBBmXufzol/X/49KFrAIaCfbHgSbXSu9QKjzLGyNXhbt5Pz4/o6FnncU91
         Q1Gh2k44SjIZ2Ggof0AnMcg+7dbUilTLB2FP64aGEJ7COibeSLEY9j1SFbBA9t9/Nd6s
         PjN837S5eIxxhy6ag4T1PzQ5dtR5RMk9pJD8HjQXoqk+ZOQiEggWjHAKWZ20a9hzqByZ
         isNcWOCnoeTnZX4gIlmuGqI/KbgRWDPPVZoy/MbQ50WoxvLNkpEHpJxfAqUnvaZURZIK
         Yw7lZudEzYmCr5tRtgMN3gRJyIo1zIEPDVyqN9iKXfkwRiHOjMN+8UMO+6VkkB7IrswO
         Kf7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=BNXst4q3;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.55 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80055.outbound.protection.outlook.com. [40.107.8.55])
        by mx.google.com with ESMTPS id k21si4851569ejr.44.2019.07.08.07.09.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Jul 2019 07:09:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.8.55 as permitted sender) client-ip=40.107.8.55;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=BNXst4q3;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.55 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=F9SnTdGJOzPh7PEhqpPLkWfo+Z7SasLHzoEWCLSlDVw=;
 b=BNXst4q3wUJQ7fT6nZR3ltTJdRrhzIuLGZTcemoyOsqqOsacTVtmJ7yTQpwRw9loeaZVYADq1cp7lw/EtDIEr5PGSv/n0e6fvSsJEdc/EaQrv/6hpV20StKRybnZGhioHr2Fr+cJ5qqzIf3zN0utuwb3mVMinZlgEu7u9fSHcS4=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3311.eurprd05.prod.outlook.com (10.170.238.32) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2052.18; Mon, 8 Jul 2019 14:09:40 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2052.020; Mon, 8 Jul 2019
 14:09:40 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
CC: Alex Deucher <alexdeucher@gmail.com>, "Kuehling, Felix"
	<Felix.Kuehling@amd.com>, "Yang, Philip" <Philip.Yang@amd.com>, Dave Airlie
	<airlied@linux.ie>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "Deucher,
 Alexander" <Alexander.Deucher@amd.com>
Subject: Re: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Thread-Topic: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Thread-Index: AQHVMUJXWs8sf5cAOUS0d/4NvIH/Saa473yAgABzhwCAAAGdAIAGcL0AgAD1qgA=
Date: Mon, 8 Jul 2019 14:09:40 +0000
Message-ID: <20190708140936.GD23966@mellanox.com>
References: <20190703015442.11974-1-Felix.Kuehling@amd.com>
 <20190703141001.GH18688@mellanox.com>
 <a9764210-9401-471b-96a7-b93606008d07@amd.com>
 <CADnq5_M0GREGG73wiu3eb=E+G2iTRmjXELh7m69BRJfVNEiHtw@mail.gmail.com>
 <20190708093020.676f5b3f@canb.auug.org.au>
In-Reply-To: <20190708093020.676f5b3f@canb.auug.org.au>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR0102CA0028.prod.exchangelabs.com
 (2603:10b6:207:18::41) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8d33c027-b8b8-4829-58f3-08d703adeb28
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB3311;
x-ms-traffictypediagnostic: VI1PR05MB3311:
x-microsoft-antispam-prvs:
 <VI1PR05MB33112416FE3452DBE336BC08CFF60@VI1PR05MB3311.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 00922518D8
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(396003)(376002)(346002)(39860400002)(136003)(53754006)(189003)(199004)(229853002)(68736007)(99286004)(305945005)(6116002)(33656002)(316002)(54906003)(386003)(3846002)(11346002)(4326008)(6916009)(1076003)(6436002)(6486002)(53936002)(102836004)(446003)(7736002)(14444005)(256004)(81156014)(476003)(14454004)(64756008)(478600001)(8676002)(66476007)(86362001)(6246003)(26005)(66946007)(81166006)(5660300002)(66556008)(73956011)(186003)(2616005)(66446008)(53546011)(486006)(66066001)(52116002)(25786009)(6506007)(36756003)(76176011)(71190400001)(6512007)(8936002)(2906002)(71200400001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3311;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 My4MtGaj6SQDJGP75ODjDhnPRryt3VphHK9qrPje6tzohAhhucXHsgvmUuXz381ezjD0eGJipwZcsHnWJ7DZWz7Wt1LKgFw+wr0v3MqsXEji/0HeWopoDZ0hz4xGrPdIqhDldt4HmKtdlchzv+v+n1/qtdTCTxuVW7viM2O7D86+W6A5jTYwp7kKA4sg6YHo3ls5OvCdqHuxvx1Gr764cVUhu5M8F9QZ4bOzcJHChQluf3nmq9WHiF77FIBZK88GTg16ssW45xKMw5R/hIdfAhH3O2lXSlJdMHH9nPD9Oy7yLDyfDAwNuF28bwSJUv2/EPGtq4/U7xL6V10LgLaLmaaYCGFbhZPHx7vIQAJKoN24a2a3OXOJ0ZokoMq1lvpCm4tiH54/OCfn7Gb8dXQSVu+v9KEHHWBaVJ4ovIPKrC0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <913C3D0530EA7F4B93FADA01B3279D28@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8d33c027-b8b8-4829-58f3-08d703adeb28
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Jul 2019 14:09:40.7888
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3311
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 08, 2019 at 09:30:20AM +1000, Stephen Rothwell wrote:
> Hi all,
>=20
> On Wed, 3 Jul 2019 17:09:16 -0400 Alex Deucher <alexdeucher@gmail.com> wr=
ote:
> >
> > On Wed, Jul 3, 2019 at 5:03 PM Kuehling, Felix <Felix.Kuehling@amd.com>=
 wrote:
> > >
> > > On 2019-07-03 10:10 a.m., Jason Gunthorpe wrote: =20
> > > > On Wed, Jul 03, 2019 at 01:55:08AM +0000, Kuehling, Felix wrote: =20
> > > >> From: Philip Yang <Philip.Yang@amd.com>
> > > >>
> > > >> In order to pass mirror instead of mm to hmm_range_register, we ne=
ed
> > > >> pass bo instead of ttm to amdgpu_ttm_tt_get_user_pages because mir=
ror
> > > >> is part of amdgpu_mn structure, which is accessible from bo.
> > > >>
> > > >> Signed-off-by: Philip Yang <Philip.Yang@amd.com>
> > > >> Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
> > > >> Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>
> > > >> CC: Stephen Rothwell <sfr@canb.auug.org.au>
> > > >> CC: Jason Gunthorpe <jgg@mellanox.com>
> > > >> CC: Dave Airlie <airlied@linux.ie>
> > > >> CC: Alex Deucher <alexander.deucher@amd.com>
> > > >>   drivers/gpu/drm/Kconfig                          |  1 -
> > > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c |  5 ++---
> > > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c           |  2 +-
> > > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          |  3 +--
> > > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c           |  8 ++++++++
> > > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.h           |  5 +++++
> > > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c          | 12 ++++++++++=
--
> > > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h          |  5 +++--
> > > >>   8 files changed, 30 insertions(+), 11 deletions(-) =20
> > > > This is too big to use as a conflict resolution, what you could do =
is
> > > > apply the majority of the patch on top of your tree as-is (ie keep
> > > > using the old hmm_range_register), then the conflict resolution for
> > > > the updated AMD GPU tree can be a simple one line change:
> > > >
> > > >   -   hmm_range_register(range, mm, start,
> > > >   +   hmm_range_register(range, mirror, start,
> > > >                          start + ttm->num_pages * PAGE_SIZE, PAGE_S=
HIFT);
> > > >
> > > > Which is trivial for everone to deal with, and solves the problem. =
=20
> > >
> > > Good idea.
>=20
> With the changes added to the amdgpu tree over the weekend, I will
> apply the following merge fix patch to the hmm merge today:
>=20
> From: Philip Yang <Philip.Yang@amd.com>
> Sibject: drm/amdgpu: adopt to hmm_range_register API change
>=20
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
>=20
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/am=
d/amdgpu/amdgpu_ttm.c
> @@ -783,7 +783,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, =
struct page **pages)
>  				0 : range->flags[HMM_PFN_WRITE];
>  	range->pfn_flags_mask =3D 0;
>  	range->pfns =3D pfns;
> -	hmm_range_register(range, mm, start,
> +	hmm_range_register(range, mirror, start,
>  			   start + ttm->num_pages * PAGE_SIZE, PAGE_SHIFT);
> =20
>  retry:
>=20
> And someone just needs to make sure Linus is aware of this needed merge f=
ix.

Great, thanks everyone

Jason

