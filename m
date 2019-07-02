Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0963EC5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:59:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF20721985
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:59:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="gSzqYBar"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF20721985
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A0686B0005; Tue,  2 Jul 2019 18:59:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4797A8E0003; Tue,  2 Jul 2019 18:59:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 318ED8E0001; Tue,  2 Jul 2019 18:59:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EC89A6B0005
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 18:59:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so318204edb.1
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 15:59:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=yJtGx4PkCuRACTU0P1T4Qum92TEAZ9p57W6xppYw/7w=;
        b=HPPxoFh94uQVXMXRj7WSrzt7emhnfA3WR+7FpSsnPpcCrY2R7CrDnrrZwtrSgFDh6z
         /5J/+bDf5lGLywy7WL+PeLAtHAMCU3xjAEMFk8EvtGMfn/rzrDiF7l1wvKMvUz/lNHpw
         gPUAqrf5PiFcM8Ed01I61uXHsmLtmyW0mz0t875UKBW88DHL22YR4bsSKF/qW9s84unb
         V8u3iEhVXfPprTCudmzWv8FCIW6moBOYxKj6OF+A0XWauiFERE/1HD+F182s24J3w291
         09h2jk5NA1pgPBfZN9UC2c+okbHUow4Sq7IVOqegKGAqVEG30MTPVKhxnllD6nUikRnE
         itlg==
X-Gm-Message-State: APjAAAXBQxB8eMPN52q3sTEpcLM3Tl1u1M8fSMdvbfV17+PjW6EDDzEw
	yFRFfK6YRwkefkb0uh9+cLZFMlKUrVFgM2qNLFEZlose5TAqCfYBzSPmAiAve1B850AnZBL3BD0
	fJkwZpjOdKrtTSRrfCNOsTL5RHK9KgCWOqdW9nDO7t1D3oxqWlxooBj3yJzx+2PVE2w==
X-Received: by 2002:a17:906:a952:: with SMTP id hh18mr31184886ejb.289.1562108359487;
        Tue, 02 Jul 2019 15:59:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwBam8e1VdpIZABTAhjS2YzLnrvNKXZ7BgkUjvpGgxCaratrjBAsg3PL6HlhxfmQsQ7efw
X-Received: by 2002:a17:906:a952:: with SMTP id hh18mr31184858ejb.289.1562108358790;
        Tue, 02 Jul 2019 15:59:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562108358; cv=none;
        d=google.com; s=arc-20160816;
        b=P5TvcvEzByRibawatUWXTnGThhnb1uY78JCveBq1btQWS5ivxKL5nnwkeI9zRoYuEP
         x7hW9stLsJoiYkFbU26f56Rg1YHpfTRhl41QetjcBndtyZhuFSqhpJFZEEmshk3Hqpsf
         bTFV3vRPRqvcWgzIZ3PQyjJ0rj9gt4YeeVgQ/IeHHMhJljmW6fNDhDiSfFT8Se7bzkQl
         XYXCYiMKGVUanxCCZcs67Hj9ZaVsV7JiONhObDnnMIOzoMTM/piLVIfHYI0eDbGu7NGg
         /F3mhLtNv6hOwkqUORtxTtuUVKEDTPa2Ehr0ptW2cItwQR6AdlOC/rYjCdQAo0B3gCz3
         /fvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=yJtGx4PkCuRACTU0P1T4Qum92TEAZ9p57W6xppYw/7w=;
        b=L/3CKwkWslQ3YTpGRaqsGi7pl/Z6U+AXxLhY7Tsg/i18gWub/vQM0/r54NE2ToyzDn
         tchX4f/pDQMKOEMGw+vkWi3Zh1Ozg5EiIFixkx6zxup7X3AfkVXi7mLUHEn0DanUFc8Z
         G8C6FHZe+xOavEOtMklzIM4ZMTcmOJRi9q3STAWc/VT4bipSCCufHfEg259BYKNR4cmo
         o1u7C86/oalyMSNYNhRf8MUqbVdEf3C+THrofPaim2i/j6EiwxfiLGqqLQUNquF968/M
         JrPHLD5rZVF+W1xtlaTD/JZLEk4kynYTlPpt2F1kNHXQcw/xLcDwJjp694lGVgCTvjK9
         Yliw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=gSzqYBar;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.6.72 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60072.outbound.protection.outlook.com. [40.107.6.72])
        by mx.google.com with ESMTPS id f6si293315edx.449.2019.07.02.15.59.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Jul 2019 15:59:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.6.72 as permitted sender) client-ip=40.107.6.72;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=gSzqYBar;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.6.72 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yJtGx4PkCuRACTU0P1T4Qum92TEAZ9p57W6xppYw/7w=;
 b=gSzqYBaruYiU0Ht5pEVesU0DK3QcMfRsA/MnZRv03tzUFZrUvmh6ZXITLU0c/GQk+erbzTkCUV/xLAT7Sie0kXz89X1vmC/o26yrslY33H+oOJ+qQa9igt+5OTJyRTdA1bBA/YwRktEigR8QwOdMlZR9Bq/8XfJovoiP6MT+cwo=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6016.eurprd05.prod.outlook.com (20.178.127.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Tue, 2 Jul 2019 22:59:16 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2032.019; Tue, 2 Jul 2019
 22:59:16 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Ralph Campbell <rcampbell@nvidia.com>, Jerome Glisse <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>, "Felix.Kuehling@amd.com"
	<Felix.Kuehling@amd.com>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
Subject: Re: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Thread-Topic: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Thread-Index: AQHVHY87cnj6rYaF00uB6DOqwK5J5aa35HaAgAAxJwCAAALKgA==
Date: Tue, 2 Jul 2019 22:59:16 +0000
Message-ID: <20190702225911.GA11833@mellanox.com>
References: <20190608001452.7922-1-rcampbell@nvidia.com>
 <20190702195317.GT31718@mellanox.com> <20190702224912.GA24043@lst.de>
In-Reply-To: <20190702224912.GA24043@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR05CA0031.namprd05.prod.outlook.com
 (2603:10b6:208:c0::44) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 57ec13c7-bc4b-47da-4719-08d6ff40e85e
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6016;
x-ms-traffictypediagnostic: VI1PR05MB6016:
x-microsoft-antispam-prvs:
 <VI1PR05MB601689AD153B34CC5B7C4B6ECFF80@VI1PR05MB6016.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:983;
x-forefront-prvs: 008663486A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(366004)(39860400002)(396003)(376002)(346002)(199004)(189003)(53936002)(102836004)(6512007)(6486002)(8676002)(76176011)(1076003)(99286004)(229853002)(6916009)(3846002)(6436002)(66476007)(52116002)(71190400001)(6246003)(8936002)(186003)(305945005)(6116002)(81156014)(81166006)(54906003)(26005)(386003)(71200400001)(316002)(14454004)(4326008)(6506007)(25786009)(446003)(476003)(7736002)(256004)(66066001)(7416002)(11346002)(36756003)(64756008)(66556008)(2616005)(86362001)(478600001)(4744005)(5660300002)(2906002)(68736007)(66946007)(66446008)(73956011)(486006)(33656002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6016;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 u5/HLB79NxZclFWXBUKTF4jOZlEqnhnnMDrMYxfhGbOltKcB4c403SDzQlF5ld9Lyn5NipC2rohko6DbRJt+LP998EA7Mf4CnYzIha6RflauOW4/FR9toJXtvkuX2/NtaAVB9VTNctSSm0tgClZS1msIkQUcjXSTncgJQj4feuWZX79f6YFWYU3IlAN9W0/doChmVt4LvVv2pKefZ7iv+WL08LckM+zN2rY/8SSV3+6SOarO2kpLhr2DgIarnXa5PBpGR5bKw1ghKIn6SaKwWRuVnceqqwmfFLt0tSDcGk0hnzNg6cfk5LsSfFT7CroOErx4eDBgN1UEQEJymrc/uEQdwu6ayrrQQDCI43CSVTTfBK1Cq4hXMdsqYpCZiKxs7ZxhlSrem3L9OwaSvB6fwn6mFATihYOGVNXzcgZ71os=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <C21602A5B8952E41ACC1E76FEF5C90F2@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 57ec13c7-bc4b-47da-4719-08d6ff40e85e
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Jul 2019 22:59:16.4254
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6016
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 12:49:12AM +0200, Christoph Hellwig wrote:
> On Tue, Jul 02, 2019 at 07:53:23PM +0000, Jason Gunthorpe wrote:
> > > I'm sending this out now since we are updating many of the HMM APIs
> > > and I think it will be useful.
> >=20
> > This make so much sense, I'd like to apply this in hmm.git, is there
> > any objection?
>=20
> As this creates a somewhat hairy conflict for amdgpu, wouldn't it be
> a better idea to wait a bit and apply it first thing for next merge
> window?

My thinking is that AMD GPU already has a monster conflict from this:

 int hmm_range_register(struct hmm_range *range,
-                      struct mm_struct *mm,
+                      struct hmm_mirror *mirror,
                       unsigned long start,
                       unsigned long end,
                       unsigned page_shift);

So, depending on how that is resolved we might want to do both API
changes at once.

Or we may have to revert the above change at this late date.

Waiting for AMDGPU team to discuss what process they want to use.

Jason

