Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDCD6C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:51:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7227020674
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:51:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Pli0gShJ";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Qeq3AAqA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7227020674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 264D46B0006; Wed, 24 Apr 2019 15:51:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 214E86B0007; Wed, 24 Apr 2019 15:51:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DDA46B0008; Wed, 24 Apr 2019 15:51:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD38E6B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:51:33 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id u66so16962294qkh.9
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:51:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=tS+a+MHZixdLX1Hby0gWxiTjUrqcSq39If4EyiZkPaE=;
        b=DqzqF8KzoqfLC84eoPkM5rRxyu4c8zx5gUTzb6L2EF3onHNBcfxoUQsaEQfDS8/QWq
         0di2n6qpApQH+rkit07oREMCVZzJEuZZDkCVNWZHsfGcFmJq1+1KBj1GjWmQ2OojTDBo
         BzJ45lh2lgSLVN+oGNtpKPz3AmJ1LWwfwlt+daXYmEne5tumt2CTclkK5GMgZWVpRpma
         fA/Cu4u0Ezt0H/G76GS62t3Tjsdakfp480Jr6qCkvqRXh94ACEM6/Qv3MBYUC0mzxunH
         q2QqHsb4sS9ih+KtFLWABDzLBI4hSqBdkmxl4hZShapwB3XGE0/fT748fWXaREXX8mdQ
         rHyQ==
X-Gm-Message-State: APjAAAVZ2OMFiqRQ1gN+kX3l6ydYPELugJhMokAHfBwIebfrz64mrjP2
	7mj7Cmc3TbclAlBQX2i9sGHPlVfS7XZ56xGhdrS5LMJxz7XFb8n4pVje/yJFRyYHajzcuCikWfu
	ChuOUuvQRCSDcLyF38ZH0MJOQSQ7kPCke7nQuzrr6nVdbhldvqdvBvpOirk+khbS7kg==
X-Received: by 2002:a37:6087:: with SMTP id u129mr26990072qkb.300.1556135493629;
        Wed, 24 Apr 2019 12:51:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxf/d0hqdhMgulBWWoLetnGv31HjnSYZ8NG6sYWgXMv12fhbQHPpy5hHZvIPA2vyQAWYuGm
X-Received: by 2002:a37:6087:: with SMTP id u129mr26990010qkb.300.1556135492853;
        Wed, 24 Apr 2019 12:51:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556135492; cv=none;
        d=google.com; s=arc-20160816;
        b=aaZst3XY1ReEpZeLu6wHSVhm38I6CK8ilecMUazwhO0lnJgX65WFka5w7xADUmHR5Z
         FF7bbtDfL55v5fskD8dXOW1Dxn6s70hvEo83gi/3ZWOv51cdHKRVl4c2Gq9rT3Kitk/H
         P73r2VEc3h1ssyTT0UgKNrBI2JkkuhZEss7Eev/8S3vSfzuleySsRH4nhuXKomX0dx08
         Wt7Jusu4iXgV/qzqWsu6luhM+b/NEUrAef6wJE6TlzIgsyXsCu0RGkob3+ESlkyaKeZt
         HDgK0OAxRZoFmDq/2MRGgVx9eafi+9ibzXv7R6884bg+hh3qcKHiDN59zfxeBFh6LbEh
         xJbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=tS+a+MHZixdLX1Hby0gWxiTjUrqcSq39If4EyiZkPaE=;
        b=cc3f6dFBzyqBa7KSLLDgQrPKicDrfH+Ji/N+6Q947AOJT4XMMI5GlBMmiSdNPG02qH
         IutiCX6+LrsI2ywUGtCvFTay9urgZOSlpuHCo8I7kfN8K7vw8dMnz2tUOtTxGFOoZFXH
         lpy0I9A1Qyh1bw/N4KiWcCpnXDvf/wMhTcMYfLKWiGny33tWhMhFSgP7W6+5Kx3LE6dO
         GI63H48rJhwr2TsprHbzLzEYrOVl6Gkbfj0fGRTwUDDofc6e97rj3Up/8Ls9fJsA7eYK
         hHXAuXLXt5A7HCph0a/WZpptq++zWKIO/HjseUdY9rZ/mVAeu86tm1xj0G7ZvBNXalVf
         dIAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Pli0gShJ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Qeq3AAqA;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u128si11702974qkb.50.2019.04.24.12.51.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 12:51:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Pli0gShJ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Qeq3AAqA;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OJiIsc028888;
	Wed, 24 Apr 2019 12:51:20 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=tS+a+MHZixdLX1Hby0gWxiTjUrqcSq39If4EyiZkPaE=;
 b=Pli0gShJA+G5HcMZcfIbTLOQIKE1pG3gvJXEM2CcPDIySko9Limpc9cGeuuQg1nKt2jx
 cdQoNPuFxiVQlxPV9aQz3yN9nRlZf0ExNDrKBqP+cMQz/bVvSZcdBJrbdzfy4+9iaSkX
 kIPKNohC/88TmSOe020b7G5hto08AOKmcss= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2s2x7kg0xk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 24 Apr 2019 12:51:20 -0700
Received: from prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 24 Apr 2019 12:51:20 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 24 Apr 2019 12:51:19 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 24 Apr 2019 12:51:19 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=tS+a+MHZixdLX1Hby0gWxiTjUrqcSq39If4EyiZkPaE=;
 b=Qeq3AAqAUNLrcUWsZ7jLc7Cc/ORE/jE0tQtWiJH9rA2VKyBwVrEtaFSfraL0qLfQxTlDEUFZcuJaFg4dx5itBSHAxAzvsGzW32cK3ZYO5QdJvcZo7qIsVeuy9GCgsHwDRso7o0FUim7X1BznmVoSKslzxm5Fjijj1xlU2A+T63c=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3237.namprd15.prod.outlook.com (20.179.57.28) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.14; Wed, 24 Apr 2019 19:51:17 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1813.017; Wed, 24 Apr 2019
 19:51:17 +0000
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
Thread-Index: AQHU+le/pG/VfTvnsEqWX9tIv1e8wqZLkEGA//+qVQCAAHwCgIAAAtsA
Date: Wed, 24 Apr 2019 19:51:17 +0000
Message-ID: <20190424195112.GB26707@tower.DHCP.thefacebook.com>
References: <20190423213133.3551969-1-guro@fb.com>
 <20190423213133.3551969-5-guro@fb.com>
 <CALvZod6A43nQgkYj38K4h_ZYLSmYp0xJwO7n44kGJx2Ut7-EVg@mail.gmail.com>
 <20190424191706.GA26707@tower.DHCP.thefacebook.com>
 <CALvZod7sG+sD76dQmMhXa92=zpXz=wdUcsR9ah7YRj13g=YT+g@mail.gmail.com>
In-Reply-To: <CALvZod7sG+sD76dQmMhXa92=zpXz=wdUcsR9ah7YRj13g=YT+g@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR14CA0028.namprd14.prod.outlook.com
 (2603:10b6:300:12b::14) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:1630]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 14b189c1-56bd-46d6-70fd-08d6c8ee36d7
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3237;
x-ms-traffictypediagnostic: BYAPR15MB3237:
x-microsoft-antispam-prvs: <BYAPR15MB3237A8DEA56F9A4245CBC5EEBE3C0@BYAPR15MB3237.namprd15.prod.outlook.com>
x-forefront-prvs: 00179089FD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(396003)(39860400002)(366004)(346002)(376002)(52314003)(189003)(199004)(229853002)(71200400001)(93886005)(54906003)(6486002)(316002)(1076003)(6916009)(86362001)(7416002)(66476007)(66946007)(8676002)(71190400001)(66446008)(81166006)(66556008)(15650500001)(7736002)(64756008)(81156014)(73956011)(14444005)(8936002)(305945005)(25786009)(2906002)(256004)(53936002)(11346002)(46003)(68736007)(446003)(386003)(102836004)(186003)(53546011)(6506007)(4326008)(6436002)(52116002)(9686003)(6246003)(486006)(76176011)(97736004)(476003)(478600001)(14454004)(6116002)(33656002)(5660300002)(6512007)(99286004);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3237;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Lfr7DMvDkvpMPd5o9Z4Vh4ql/PmN2L2WuGYAoPYADbVdDqV+2kB3aOACakVCZfqEMeSutxb8ODk1bDxCsWpmWFgXIdIfS0hXnubItW7ewFsibnkvAcYbLyehvaskVSClxLkurpMz7dVBX9VDkI2h6MK67nMNfqLyndNfy74itgcCgAHu91qF3h6sBGK9M06B4z/jRzcrHrUf4CUwB1QifwTFzcpdPXEYGRgV6iQzdCXwVm4x1eCqeTw/PxomLvsjj5bKmQ7fdghkYuO0Geq0xn7K989MUqBcRkhC9xx2ClWno2KIddccnFBsd70J4oBTzeYjeNMSrYKltRpe9gquoZvE+d3yvrCYexA2GhhtFuf6DlDk9k4maMacsRpQIfDitXYaqJe8pl80fjYVxhH/z+1z4cjxjcXD/SgKq4vPp5Q=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F45B68BFB4D7F84B9711AC2AE8B29159@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 14b189c1-56bd-46d6-70fd-08d6c8ee36d7
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Apr 2019 19:51:17.1597
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3237
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

On Wed, Apr 24, 2019 at 12:40:59PM -0700, Shakeel Butt wrote:
> On Wed, Apr 24, 2019 at 12:17 PM Roman Gushchin <guro@fb.com> wrote:
> >
> > On Wed, Apr 24, 2019 at 10:23:45AM -0700, Shakeel Butt wrote:
> > > Hi Roman,
> > >
> > > On Tue, Apr 23, 2019 at 9:30 PM Roman Gushchin <guro@fb.com> wrote:
> > > >
> > > > Currently the page accounting code is duplicated in SLAB and SLUB
> > > > internals. Let's move it into new (un)charge_slab_page helpers
> > > > in the slab_common.c file. These helpers will be responsible
> > > > for statistics (global and memcg-aware) and memcg charging.
> > > > So they are replacing direct memcg_(un)charge_slab() calls.
> > > >
> > > > Signed-off-by: Roman Gushchin <guro@fb.com>
> > > > ---
> > > >  mm/slab.c | 19 +++----------------
> > > >  mm/slab.h | 22 ++++++++++++++++++++++
> > > >  mm/slub.c | 14 ++------------
> > > >  3 files changed, 27 insertions(+), 28 deletions(-)
> > > >
> > > > diff --git a/mm/slab.c b/mm/slab.c
> > > > index 14466a73d057..53e6b2687102 100644
> > > > --- a/mm/slab.c
> > > > +++ b/mm/slab.c
> > > > @@ -1389,7 +1389,6 @@ static struct page *kmem_getpages(struct kmem=
_cache *cachep, gfp_t flags,
> > > >                                                                 int=
 nodeid)
> > > >  {
> > > >         struct page *page;
> > > > -       int nr_pages;
> > > >
> > > >         flags |=3D cachep->allocflags;
> > > >
> > > > @@ -1399,17 +1398,11 @@ static struct page *kmem_getpages(struct km=
em_cache *cachep, gfp_t flags,
> > > >                 return NULL;
> > > >         }
> > > >
> > > > -       if (memcg_charge_slab(page, flags, cachep->gfporder, cachep=
)) {
> > > > +       if (charge_slab_page(page, flags, cachep->gfporder, cachep)=
) {
> > > >                 __free_pages(page, cachep->gfporder);
> > > >                 return NULL;
> > > >         }
> > > >
> > > > -       nr_pages =3D (1 << cachep->gfporder);
> > > > -       if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> > > > -               mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, nr=
_pages);
> > > > -       else
> > > > -               mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, =
nr_pages);
> > > > -
> > > >         __SetPageSlab(page);
> > > >         /* Record if ALLOC_NO_WATERMARKS was set when allocating th=
e slab */
> > > >         if (sk_memalloc_socks() && page_is_pfmemalloc(page))
> > > > @@ -1424,12 +1417,6 @@ static struct page *kmem_getpages(struct kme=
m_cache *cachep, gfp_t flags,
> > > >  static void kmem_freepages(struct kmem_cache *cachep, struct page =
*page)
> > > >  {
> > > >         int order =3D cachep->gfporder;
> > > > -       unsigned long nr_freed =3D (1 << order);
> > > > -
> > > > -       if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> > > > -               mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, -n=
r_freed);
> > > > -       else
> > > > -               mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, =
-nr_freed);
> > > >
> > > >         BUG_ON(!PageSlab(page));
> > > >         __ClearPageSlabPfmemalloc(page);
> > > > @@ -1438,8 +1425,8 @@ static void kmem_freepages(struct kmem_cache =
*cachep, struct page *page)
> > > >         page->mapping =3D NULL;
> > > >
> > > >         if (current->reclaim_state)
> > > > -               current->reclaim_state->reclaimed_slab +=3D nr_free=
d;
> > > > -       memcg_uncharge_slab(page, order, cachep);
> > > > +               current->reclaim_state->reclaimed_slab +=3D 1 << or=
der;
> > > > +       uncharge_slab_page(page, order, cachep);
> > > >         __free_pages(page, order);
> > > >  }
> > > >
> > > > diff --git a/mm/slab.h b/mm/slab.h
> > > > index 4a261c97c138..0f5c5444acf1 100644
> > > > --- a/mm/slab.h
> > > > +++ b/mm/slab.h
> > > > @@ -205,6 +205,12 @@ ssize_t slabinfo_write(struct file *file, cons=
t char __user *buffer,
> > > >  void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
> > > >  int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, vo=
id **);
> > > >
> > > > +static inline int cache_vmstat_idx(struct kmem_cache *s)
> > > > +{
> > > > +       return (s->flags & SLAB_RECLAIM_ACCOUNT) ?
> > > > +               NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
> > > > +}
> > > > +
> > > >  #ifdef CONFIG_MEMCG_KMEM
> > > >
> > > >  /* List of all root caches. */
> > > > @@ -352,6 +358,22 @@ static inline void memcg_link_cache(struct kme=
m_cache *s,
> > > >
> > > >  #endif /* CONFIG_MEMCG_KMEM */
> > > >
> > > > +static __always_inline int charge_slab_page(struct page *page,
> > > > +                                           gfp_t gfp, int order,
> > > > +                                           struct kmem_cache *s)
> > > > +{
> > > > +       memcg_charge_slab(page, gfp, order, s);
> > >
> > > This does not seem right. Why the return of memcg_charge_slab is igno=
red?
> >
> > Hi Shakeel!
> >
> > Right, it's a bug. It's actually fixed later in the patchset
> > (in "mm: rework non-root kmem_cache lifecycle management"),
> > so the final result looks correct to me. Anyway, I'll fix it.
> >
> > How does everything else look to you?
> >
> > Thank you!
>=20
> I caught this during quick glance. Another high level issue I found is
> breakage of /proc/kpagecgroup for the slab pages which is easy to fix.

Good point! I'll add it in the next iteration.

>=20
> At the moment I am kind of stuck on some other stuff but will get back
> to this in a week or so.

I'm looking forward then... I'm also repeating my long-term test with this
iteration, and I'll have updated results in few days.

Thank you for looking into it!

Roman

