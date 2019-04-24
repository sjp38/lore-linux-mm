Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D09F1C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:17:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72DC1205ED
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:17:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="RlEhoc/k";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="I3YTA9pz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72DC1205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1700C6B0005; Wed, 24 Apr 2019 15:17:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11D966B0006; Wed, 24 Apr 2019 15:17:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F26A36B0007; Wed, 24 Apr 2019 15:17:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB8F66B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:17:24 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id b10so8958666vkf.3
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:17:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=YaopUjZJy+hmGVptkNC+a3/dCOZGizWEQXEvUySQ7qA=;
        b=dUx9VyfthJ1BTOObCI6wvVSkG6E4fX6JY4FqUzlJQs1FyUZvqdEh7PqhGNg+asAnHE
         YPjuaQEKFZi43TaDu0dp/fdfXaanplaTF2Jt39Ym0J9MOQirlSq9Vg7vg8eCG7tvNZy4
         r8qsxP4ILgqfQdxZ2WOjL8HIaN3U17PkDlokTq2JjegapISz9cD2EHBkEEGU/gXBmL9C
         9pUOd6J+WzV7491jnb+D9tpNtaP3rD54YAv2OswpilbP3TUFjzLFMgW3+GZseoTEyCNe
         BaTAXjuypefOKl5KQrPKu0fB8IGtf/RFUi8mV9jHPkHsotQMqT1p78ldEOPfcgNCGrMu
         SR+Q==
X-Gm-Message-State: APjAAAVMsVnpghHIoXx5yVpqNWFX21H7rSR1a93uKnPP5dfT4IGHRJkC
	MMH+wHpgLx8vKM4HD2ALtdeLTkd86eZVqySrdNGgSemOm0xYVzAM7U98CRCGFAlGeGial+kXkwe
	isnFTvjQWxb2rHP2wSEECfeimrLiOXuJ61CCsLnbg4+sq8l1jxpgL1W6+6iqrL7W3Pg==
X-Received: by 2002:ab0:7003:: with SMTP id k3mr17778126ual.0.1556133444410;
        Wed, 24 Apr 2019 12:17:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoKaeckYhnTMsezbPfXVCzCRrPRup9YG6k0jEEK53HZL/7wr8ErqB4eD1gysMAHIhfDXNr
X-Received: by 2002:ab0:7003:: with SMTP id k3mr17778054ual.0.1556133443499;
        Wed, 24 Apr 2019 12:17:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556133443; cv=none;
        d=google.com; s=arc-20160816;
        b=nLDNrb9vdILKfDCss987WGvp5nR1TpMVVm+Rwj0XfTxTSdopSmzvMQw6Skdl9fZuE7
         WdNpN/V8hCydOCf4Vj646Z1g753hEATbX0GUUAs+dD81IjyUxMWIENLy3Hcr99qumON1
         fwbbS4mdRtWbxukRbkXhtf/fNMuR6DSUhQJzikVbpsbms5e//pyrBOk5eU59O8aTRPck
         JbOQEdD8+81pSbjQ79ysA4tCBjbegoGsTEg3ufE+aAOb3QpcRB1n59U7NmYL8py8qU8M
         ptbhFOpFzs1/l3UKDDlZ/PY7n9bNEW6sU7bWU1DAUzHaxcCpon5uUK0Ksr1HQR216vi0
         w/Tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=YaopUjZJy+hmGVptkNC+a3/dCOZGizWEQXEvUySQ7qA=;
        b=O/I/bu0wuJHehq5ePs0R1SvY7Y8Hnn8LcT4x4/m4TyQZcL979HjkuKQJcO4k82jaPy
         yszy8k8AP45V04sDwGNqCkeKDHXjUrUNkLHzHM+Y/17ivN9mOs/Qf3U8oB9zuVuOKBYn
         Q/7jGW8rUVQQkTRp1W2BCt4kDphZOoFSXsPMi+qpuBzvuUb5eoY0Ssdhlv67fvCsNWyy
         Ah4Ae6hfdr6xSOB050qA2WYBzNt/AN8MS5cTMid6WwppMTSjoWHmc80ShjNG2m+KWcYA
         0QsXePxnGRui4n2MpYjFfNa6ZmGAtqsBlM0T7yQUfkWmtKxVYBoHfRUfqabwiDrwZ9jO
         Cz1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="RlEhoc/k";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=I3YTA9pz;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 186si4532004vsl.346.2019.04.24.12.17.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 12:17:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="RlEhoc/k";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=I3YTA9pz;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OJ4XSe008920;
	Wed, 24 Apr 2019 12:17:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=YaopUjZJy+hmGVptkNC+a3/dCOZGizWEQXEvUySQ7qA=;
 b=RlEhoc/kw5Roh6ogLWx45qe5yRQZLRK90uQZbGvl048xjbuvSxz6L1g0QKf1OLFJdJcx
 GDQr6ljSoMzZhmSFe/TDG04R3W3QU5U6Z6Rjg9GUsND7osnxh7zZLPJNMd82mSXnoxGm
 YVpKwk1aUJ8NOAdarIrBQ4nd8bhvWW0mWeQ= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2s2tvc8xbt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 24 Apr 2019 12:17:17 -0700
Received: from frc-hub03.TheFacebook.com (2620:10d:c021:18::173) by
 frc-hub06.TheFacebook.com (2620:10d:c021:18::176) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 24 Apr 2019 12:17:15 -0700
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.73) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 24 Apr 2019 12:17:15 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=YaopUjZJy+hmGVptkNC+a3/dCOZGizWEQXEvUySQ7qA=;
 b=I3YTA9pzR9DqPZ7I0CR8A4ZGolLHkHL8FCmbicpxEFSk6a4L74E2khRimiVbgM5P988NkmeQT2lPks7gQ50NxPF9RlFaxyr2n2OMvRZXo2s6pk7ERZCwSvUFqW90/pGoz0+uRo91YIiUp0T/dwMSuWwTorBlGIjs1jcG9vVMAkU=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3351.namprd15.prod.outlook.com (20.179.58.157) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.12; Wed, 24 Apr 2019 19:17:13 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1813.017; Wed, 24 Apr 2019
 19:17:13 +0000
From: Roman Gushchin <guro@fb.com>
To: Shakeel Butt <shakeelb@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
        "Rik
 van Riel" <riel@surriel.com>, Christoph Lameter <cl@linux.com>,
        "Vladimir
 Davydov" <vdavydov.dev@gmail.com>,
        Cgroups <cgroups@vger.kernel.org>
Subject: Re: [PATCH v2 4/6] mm: unify SLAB and SLUB page accounting
Thread-Topic: [PATCH v2 4/6] mm: unify SLAB and SLUB page accounting
Thread-Index: AQHU+le/pG/VfTvnsEqWX9tIv1e8wqZLkEGAgAAfr4A=
Date: Wed, 24 Apr 2019 19:17:12 +0000
Message-ID: <20190424191706.GA26707@tower.DHCP.thefacebook.com>
References: <20190423213133.3551969-1-guro@fb.com>
 <20190423213133.3551969-5-guro@fb.com>
 <CALvZod6A43nQgkYj38K4h_ZYLSmYp0xJwO7n44kGJx2Ut7-EVg@mail.gmail.com>
In-Reply-To: <CALvZod6A43nQgkYj38K4h_ZYLSmYp0xJwO7n44kGJx2Ut7-EVg@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR19CA0094.namprd19.prod.outlook.com
 (2603:10b6:320:1f::32) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:1630]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a94306f0-9714-4419-3ecf-08d6c8e97480
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3351;
x-ms-traffictypediagnostic: BYAPR15MB3351:
x-microsoft-antispam-prvs: <BYAPR15MB33511CB2DDAF72162E02112EBE3C0@BYAPR15MB3351.namprd15.prod.outlook.com>
x-forefront-prvs: 00179089FD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(136003)(396003)(346002)(39860400002)(366004)(52314003)(189003)(199004)(6486002)(68736007)(86362001)(71200400001)(8936002)(97736004)(54906003)(6916009)(9686003)(71190400001)(6512007)(478600001)(64756008)(66946007)(81166006)(7416002)(5660300002)(6436002)(73956011)(8676002)(66556008)(66476007)(4326008)(52116002)(66446008)(81156014)(14444005)(256004)(316002)(76176011)(2906002)(99286004)(305945005)(53936002)(14454004)(386003)(33656002)(11346002)(46003)(6506007)(486006)(476003)(229853002)(7736002)(53546011)(102836004)(6116002)(446003)(1076003)(15650500001)(25786009)(186003)(6246003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3351;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 0enE/1eOvRPwJXiy46eGZwSRy5wKXaUD4rvakdaIw1tZsHAbMgGmjy6nUxXFdZiVEqCb+XSciDqbhQc64RkaHzVsx9GMcKJCrPElqfzriI4F069eJ9jyzyIurtpZibkOQB9hY1nEqIT8QvzAAlTN2NdiGuYuNaGxbD9oAK7qOL78bTarNJJ8i+FSSCMqVvV6j3zQbmxz0dksjUshoTV5khrjBQIA+X+5SD6Pe/RC8PudgDS6PR3cS2De/Yw+cjMZmfTkCBC6BI10matnFpjngMPAA0yDlu2evXt9UKGw2bQZjwgrMGWMrkr2dsyPv7gOho9uzX2Fvu2g+rdm5BQFgS6lJDxaBHFUYWkNILXkAYVVyBJ3rUOeTKc2+/z3c366wMN0d7/VzJLIcJ4xOArBN8/nikKN4GYcKHlA1ZaK92k=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6FAACE41325E304CBA651E0E42932B9F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: a94306f0-9714-4419-3ecf-08d6c8e97480
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Apr 2019 19:17:12.9642
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3351
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_12:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 10:23:45AM -0700, Shakeel Butt wrote:
> Hi Roman,
>=20
> On Tue, Apr 23, 2019 at 9:30 PM Roman Gushchin <guro@fb.com> wrote:
> >
> > Currently the page accounting code is duplicated in SLAB and SLUB
> > internals. Let's move it into new (un)charge_slab_page helpers
> > in the slab_common.c file. These helpers will be responsible
> > for statistics (global and memcg-aware) and memcg charging.
> > So they are replacing direct memcg_(un)charge_slab() calls.
> >
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > ---
> >  mm/slab.c | 19 +++----------------
> >  mm/slab.h | 22 ++++++++++++++++++++++
> >  mm/slub.c | 14 ++------------
> >  3 files changed, 27 insertions(+), 28 deletions(-)
> >
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 14466a73d057..53e6b2687102 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -1389,7 +1389,6 @@ static struct page *kmem_getpages(struct kmem_cac=
he *cachep, gfp_t flags,
> >                                                                 int nod=
eid)
> >  {
> >         struct page *page;
> > -       int nr_pages;
> >
> >         flags |=3D cachep->allocflags;
> >
> > @@ -1399,17 +1398,11 @@ static struct page *kmem_getpages(struct kmem_c=
ache *cachep, gfp_t flags,
> >                 return NULL;
> >         }
> >
> > -       if (memcg_charge_slab(page, flags, cachep->gfporder, cachep)) {
> > +       if (charge_slab_page(page, flags, cachep->gfporder, cachep)) {
> >                 __free_pages(page, cachep->gfporder);
> >                 return NULL;
> >         }
> >
> > -       nr_pages =3D (1 << cachep->gfporder);
> > -       if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> > -               mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, nr_pag=
es);
> > -       else
> > -               mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, nr_p=
ages);
> > -
> >         __SetPageSlab(page);
> >         /* Record if ALLOC_NO_WATERMARKS was set when allocating the sl=
ab */
> >         if (sk_memalloc_socks() && page_is_pfmemalloc(page))
> > @@ -1424,12 +1417,6 @@ static struct page *kmem_getpages(struct kmem_ca=
che *cachep, gfp_t flags,
> >  static void kmem_freepages(struct kmem_cache *cachep, struct page *pag=
e)
> >  {
> >         int order =3D cachep->gfporder;
> > -       unsigned long nr_freed =3D (1 << order);
> > -
> > -       if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> > -               mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, -nr_fr=
eed);
> > -       else
> > -               mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, -nr_=
freed);
> >
> >         BUG_ON(!PageSlab(page));
> >         __ClearPageSlabPfmemalloc(page);
> > @@ -1438,8 +1425,8 @@ static void kmem_freepages(struct kmem_cache *cac=
hep, struct page *page)
> >         page->mapping =3D NULL;
> >
> >         if (current->reclaim_state)
> > -               current->reclaim_state->reclaimed_slab +=3D nr_freed;
> > -       memcg_uncharge_slab(page, order, cachep);
> > +               current->reclaim_state->reclaimed_slab +=3D 1 << order;
> > +       uncharge_slab_page(page, order, cachep);
> >         __free_pages(page, order);
> >  }
> >
> > diff --git a/mm/slab.h b/mm/slab.h
> > index 4a261c97c138..0f5c5444acf1 100644
> > --- a/mm/slab.h
> > +++ b/mm/slab.h
> > @@ -205,6 +205,12 @@ ssize_t slabinfo_write(struct file *file, const ch=
ar __user *buffer,
> >  void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
> >  int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void *=
*);
> >
> > +static inline int cache_vmstat_idx(struct kmem_cache *s)
> > +{
> > +       return (s->flags & SLAB_RECLAIM_ACCOUNT) ?
> > +               NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
> > +}
> > +
> >  #ifdef CONFIG_MEMCG_KMEM
> >
> >  /* List of all root caches. */
> > @@ -352,6 +358,22 @@ static inline void memcg_link_cache(struct kmem_ca=
che *s,
> >
> >  #endif /* CONFIG_MEMCG_KMEM */
> >
> > +static __always_inline int charge_slab_page(struct page *page,
> > +                                           gfp_t gfp, int order,
> > +                                           struct kmem_cache *s)
> > +{
> > +       memcg_charge_slab(page, gfp, order, s);
>=20
> This does not seem right. Why the return of memcg_charge_slab is ignored?

Hi Shakeel!

Right, it's a bug. It's actually fixed later in the patchset
(in "mm: rework non-root kmem_cache lifecycle management"),
so the final result looks correct to me. Anyway, I'll fix it.

How does everything else look to you?

Thank you!

