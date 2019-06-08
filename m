Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0902CC28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 11:41:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1814214DA
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 11:41:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="kAuQwdJx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1814214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DFCF6B026D; Sat,  8 Jun 2019 07:41:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48F2E6B026F; Sat,  8 Jun 2019 07:41:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37E936B0271; Sat,  8 Jun 2019 07:41:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC1F76B026D
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 07:41:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s5so6673222eda.10
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 04:41:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=dm5t7RwyC8mbdoq110urMkfCMJmGmRbbuzagndSbNrE=;
        b=bENDFGVvl94dz00+Ns+PsEURwH8CYIKH1uZWcJfPfzpdBszIrXRMnh9PZduQ/+n97H
         74uLGLum96vbZZlCyX6uUL2gnvXkyWKRyZFqgkYJzBG+1phHk0Xa/tYyEddyO3GuQjzg
         feD9GwRJbRlpiwLg2Lq45XBnTDivELI4FEQFqChAAz7nmF1OkN6d3WwyJ0eCG+h6bTYH
         dHmLe7mivHgsP+fxqyiy3/arzAF8IgzqgM1uXyrtPjdE0T5XtsWqMsdo0yjN2hldFLqY
         NhFpS+pjDMndECuq40KY7J8c8qaar+VMceJqn9T7S8mGq/70VxbAHn5mK6LNP1446lHC
         81RQ==
X-Gm-Message-State: APjAAAWZ54MKYnWvYaK2GAreYoFzDpJBKvw31cMz5D1gbg0ATaLbGxQ4
	3ve1m7eD5HocooNKJAULQa7lvP8QB/AkE51bw1Nn0O+JSoAj+LxYwSNb50xhK/vY5sxzhKIZBzo
	Vv9lY9rLCSt4PTS6Pm7RBJq9mvbtXexe96BRmj4q5AkS8hAz9DpS5yCCd86jV6KaEAQ==
X-Received: by 2002:a50:be42:: with SMTP id b2mr61185708edi.228.1559994103413;
        Sat, 08 Jun 2019 04:41:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHER9ZuNMtK2tKGG0JY676qNomr9LK4V+cif6ezMSWBtJRDEaTy8ENRL7MZ6NNixBgLJwu
X-Received: by 2002:a50:be42:: with SMTP id b2mr61185660edi.228.1559994102587;
        Sat, 08 Jun 2019 04:41:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559994102; cv=none;
        d=google.com; s=arc-20160816;
        b=HXgCDLQorexq9ortNs0vCsze4mN5tglfHRhdAfQl8VtmTKvgMn1waRvuXuHVHBbjLg
         LBswhMfsQW7SIbtSjIDiOjwGBwp8Ty9QeG+kmoQ8soCtx+Db2HP5DG8u3cqycQYV4n4M
         LV3QRP9DsfwNQyc8dDfSq8ymfEhpw98QlaY2y6heYkYVU6CqHOUFAaMmb4GACClqjvBA
         VDdj7wdbKXeGHqVmUs3Nx/OWcQUJU2gHEAhF0QCRWXS1fCIbdzIA6k1LpmYSS6anY2jf
         p0K7u3ipj6xAC24OJ2oCERxm6KYQ8tUSXleZ2XY5nGeMu2COJsfi+u35g2TRVGSjDbUl
         v9LA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=dm5t7RwyC8mbdoq110urMkfCMJmGmRbbuzagndSbNrE=;
        b=w0GvvGbBfjonLKlQ85QKH7nBFlFqmHyErsJHr4i/pAb0vvMDDWi9x8uZAUSpDPMtrD
         DZQSDHIc1sZdur4O+dKgEILmX48z69XhnEVZ5GzYxwxsLv/JftzLfWQMCygpNLCrNc/Z
         JvaYYKIVRGRZpoBH+PMPupzL4IR9jmoAyGn2rlTQkocClr5TgyHKDT1IbcCg+4vowus0
         yHMVJi3RlIx69PsGaE51VaTgyh+hp/sEwkhIcldMcSkDKtOm3/NknIvtxxqplb+Q7HNF
         XINbG0pChU3l/aefqLmVpzlNYoyuEvWqGPBSJHCtyFAC4au/5KwT94DQorjJZu+6StUr
         U0KA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=kAuQwdJx;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.71 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30071.outbound.protection.outlook.com. [40.107.3.71])
        by mx.google.com with ESMTPS id k25si3458319ede.169.2019.06.08.04.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Jun 2019 04:41:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.3.71 as permitted sender) client-ip=40.107.3.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=kAuQwdJx;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.71 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dm5t7RwyC8mbdoq110urMkfCMJmGmRbbuzagndSbNrE=;
 b=kAuQwdJx1jmLjEj4PWsyTzdyj3xbNHpqiYq8uVn1CwPaInYlsDlDgcvLGEwEZRbNZwmu41CzRD1PfVE4QNeUN0S0O27Bu8ChRWZpGt8rl1V+NGmb0cyGRSx4+c31pooCcjxJRQMWiK49ruQDQvmDxu/8pp7KGU05D5gPyiUwaMk=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5007.eurprd05.prod.outlook.com (20.177.52.28) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.12; Sat, 8 Jun 2019 11:41:39 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1965.017; Sat, 8 Jun 2019
 11:41:39 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@infradead.org>
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
Thread-Index: AQHVHY87cnj6rYaF00uB6DOqwK5J5aaReNEAgAAqToA=
Date: Sat, 8 Jun 2019 11:41:39 +0000
Message-ID: <20190608114133.GA14873@mellanox.com>
References: <20190608001452.7922-1-rcampbell@nvidia.com>
 <20190608091008.GC32185@infradead.org>
In-Reply-To: <20190608091008.GC32185@infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTXPR0101CA0025.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00::38) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1d05033d-46b3-43bb-b701-08d6ec064493
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5007;
x-ms-traffictypediagnostic: VI1PR05MB5007:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR05MB5007B0248BAF930F089C6908CF110@VI1PR05MB5007.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5236;
x-forefront-prvs: 0062BDD52C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(39850400004)(396003)(376002)(366004)(136003)(189003)(199004)(53936002)(66946007)(316002)(66476007)(66556008)(26005)(64756008)(73956011)(6246003)(4326008)(186003)(2906002)(81166006)(25786009)(66066001)(8676002)(66446008)(81156014)(54906003)(86362001)(229853002)(8936002)(14454004)(1076003)(478600001)(966005)(6116002)(7416002)(3846002)(102836004)(6916009)(476003)(76176011)(6512007)(99286004)(14444005)(5660300002)(6486002)(68736007)(256004)(6306002)(52116002)(386003)(6506007)(71200400001)(71190400001)(33656002)(486006)(7736002)(305945005)(446003)(6436002)(2616005)(36756003)(11346002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5007;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 oo6gBf4xnKbnuLgjj+3gOZyAmqrCSoudzh6QQhuIXOxJwXWerg0BwM3MLb/FmZYDen+hzwRsqXde1gz4fbbE9MW5380nn2C8DdViZojxawz4Qs8tSrHS3VW+PGvkJTVaEEONDTOpuFk9g0mo1L7bQkFeDoIeHRQAn3UZ0q2MbKGOGdKF5SvsSGkUZMCav8dOCInP11RZ4x8vitV8NHglioRn4obmW+sy8Ld2EkNHVSLf1VafoSEUdnLfF5l5b5FVg3eZkXFZnKQNd/b5923jHl8DsAqp9fCZPu7Tg5TyoJcFlxiGH/efr/HKr1BEgoRVQHXcT5c3FpSTL7g2whImTeICvXhibJ8ErhDkV/XFDIkXGhaj9GGr7onZNYFuvp5E4DG7d5BKOL2DdiC/FFJ67XyHKWENSAjyCXKKNHQboiA=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <EECCBA142F666248ACACC3016329ACD8@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1d05033d-46b3-43bb-b701-08d6ec064493
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Jun 2019 11:41:39.2878
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5007
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 08, 2019 at 02:10:08AM -0700, Christoph Hellwig wrote:
> On Fri, Jun 07, 2019 at 05:14:52PM -0700, Ralph Campbell wrote:
> > HMM defines its own struct hmm_update which is passed to the
> > sync_cpu_device_pagetables() callback function. This is
> > sufficient when the only action is to invalidate. However,
> > a device may want to know the reason for the invalidation and
> > be able to see the new permissions on a range, update device access
> > rights or range statistics. Since sync_cpu_device_pagetables()
> > can be called from try_to_unmap(), the mmap_sem may not be held
> > and find_vma() is not safe to be called.
> > Pass the struct mmu_notifier_range to sync_cpu_device_pagetables()
> > to allow the full invalidation information to be used.
> >=20
> > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> >=20
> > I'm sending this out now since we are updating many of the HMM APIs
> > and I think it will be useful.
>=20
> This is the right thing to do.  But the really right thing is to just
> kill the hmm_mirror API entirely and move to mmu_notifiers.  At least
> for noveau this already is way simpler, although right now it defeats
> Jasons patch to avoid allocating the struct hmm in the fault path.
> But as said before that can be avoided by just killing struct hmm,
> which for many reasons is the right thing to do anyway.
>=20
> I've got a series here, which is a bit broken (epecially the last
> patch can't work as-is), but should explain where I'm trying to head:
>=20
> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-mirro=
r-simplification

At least the current hmm approach does rely on the collision retry
locking scheme in struct hmm/struct hmm_range for the pagefault side
to work right.

So, before we can apply patch one in this series we need to fix
hmm_vma_fault() and all its varients. Otherwise the driver will be
broken.

I'm hoping to first define what this locking should be (see other
emails to Ralph) then, ideally, see if we can extend mmu notifiers to
get it directly withouth hmm stuff.

Then we apply your patch one and the hmm ops wrapper dies.

Jason

