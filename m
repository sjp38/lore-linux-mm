Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0665C04A6B
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:33:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 674E2217D6
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:33:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FLenrYKC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 674E2217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1810E6B0008; Fri, 10 May 2019 20:33:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10B516B000A; Fri, 10 May 2019 20:33:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3CE26B000C; Fri, 10 May 2019 20:33:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id D01266B0008
	for <linux-mm@kvack.org>; Fri, 10 May 2019 20:33:30 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id a70so12827256ywe.21
        for <linux-mm@kvack.org>; Fri, 10 May 2019 17:33:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=06yq7LJHXJLhXvJtT8Hx1dzG/UksnBqriBWB06TOKsM=;
        b=RDgPfWi5jpMciAIGuvJYDq4MxLYb7SepdIqZW3yY4ELcTdhU55Bdq/2w4dNHkcpeq4
         j6cN44bB3L1qxU2eXo6dLywCHBcmvlwGsYk/7E0y1hF6VEwljlostrY2F1h6ar6haxhi
         rsUQJjVCjU9ECaEmERMIlVZMZJW5UhptGpdH6u/y9NspJ+QnCzOAcRkNzfsbPP9pc0d2
         srPTvUerSCCeaXtDinqu9yx3oqsQ+tWZ7mlI1xZOa49QNo+VOZ9a+SrZvcexcr/UXBw0
         Hc2QkecEWY331ph/h3EXBXPYQpY8jyTG+5qCKmngbj7IpYjQMOZAXrKjP3mhBOc7dzhS
         /wtA==
X-Gm-Message-State: APjAAAWnLW80UdRiduarQKxM7MP4KjX9VrtzUIhJ5lb2hYMcxAV/XFMe
	8Cszoo0jtg8xa8XtX9yCJgjGcgzvJ5YRWkI1UMMw0vHgOTWV2Mtq/1tTrW+j/nzGczqheifJome
	MPxppN2BMo7GGBDIP0WSKIAkG+EqccYQNOTDaVB9Ie7rnnTdYXLPyry3dSejZnzprgg==
X-Received: by 2002:a25:b88c:: with SMTP id w12mr8081043ybj.4.1557534810618;
        Fri, 10 May 2019 17:33:30 -0700 (PDT)
X-Received: by 2002:a25:b88c:: with SMTP id w12mr8081016ybj.4.1557534809987;
        Fri, 10 May 2019 17:33:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557534809; cv=none;
        d=google.com; s=arc-20160816;
        b=TNwrfbabyezrwrxh/5bhDcRgBYn9yZGcUsXo2PtiVY95pNaJV7AzpLvNn62CNMh5tD
         S7ZmCQyCAYdrWscotCiCdkxwtelpWR99tA83YVdo7E0VTZrTvMzxx0dgzDcSVVJAlL4I
         TmiJiVHAhaNZZv4k8W3JPSh9PUoz1S6F34Bjh8VbAoMcDbJuNdS2j0HJkS6D8iJgHhi5
         da8wUYlaziD2Yk5FVfscLX/POowjVay2QHer6VMKwbgLKFPyWX3VYxXsajz+HRXikLas
         mFfNa4sLyIgZt4oWFcdXvwKRBZB9vXCZGrVibBaTPI2zufgqaBfaN1J/EV+ZsMvf4YQm
         uhqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=06yq7LJHXJLhXvJtT8Hx1dzG/UksnBqriBWB06TOKsM=;
        b=pmE3DEFzglRySlXzx3sLpZtzR2wYU8bpkpG/Edtuss83XnY3BREsSZlL7zZpZHa+K7
         jc1/ha6S8pgTHqeO+Pfz8SKNrymR34A4Z3L+vwR57K3rKP+SGrtt7+JT4gIlW7zPu7zz
         eZHHt/rDgX2Y3u8oc0RZZb97RsGSeehD5xjg8b5ja2q/zxWxUhVo9VU9TEBgCLnJqRt5
         PtX8b4GxEQoDVEbzPFslXSBFsQ+IkFpFlg4E1PwHSyTEYIfk0q5vK4uwP+4tyiAL81rp
         4P3usVmPJ4UWC7OfFrGSX9PSIBe/mLdj7yGIZCtIEfI+SEr6orWE1u2r234j7BZuep8d
         zCDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FLenrYKC;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v1sor3569349ywf.185.2019.05.10.17.33.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 17:33:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FLenrYKC;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=06yq7LJHXJLhXvJtT8Hx1dzG/UksnBqriBWB06TOKsM=;
        b=FLenrYKCC/buLryrtTHR0QOzi7NfAoKEeQmjNgykhtuIow+SzOjew+0nhueVyTV8oG
         icHsrXyG4xGD0CDDMGWrvOhe+pUJC0h5crxPrcPIEjz3XsSbHIcPefgG/PwCkvb/3p+G
         cXsLhi6+XzgmpQUNfHk0KAD+C9L/7rV4lK8clWAv70+zNj2VKr0cIQK7EAuGd6SN1YBr
         eKE9IoajJZTDXrLuV3ytJW0X4APyReZzMv/1E/XrkOl28mSphBIQtGjW2G+YUr5yTUNl
         mgmK6pclL8909ZZq1z3N8iL9M6kyiN3LgMnZz6IcnmXYdiuK4XzET2jCogNThKOse6fY
         0lAg==
X-Google-Smtp-Source: APXvYqySypYcSRvUZW+oAz8+5kM6/4U8A5b6xBJaRdDGuwRUvh4M1NiOMeCygnFvnnfciBHvIghMxKiWSj2ZrQFEQSY=
X-Received: by 2002:a81:25cb:: with SMTP id l194mr7255617ywl.489.1557534809439;
 Fri, 10 May 2019 17:33:29 -0700 (PDT)
MIME-Version: 1.0
References: <20190508202458.550808-1-guro@fb.com> <20190508202458.550808-5-guro@fb.com>
In-Reply-To: <20190508202458.550808-5-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 10 May 2019 17:33:18 -0700
Message-ID: <CALvZod5mLReoo44=+s3uYng=e76tXcjDMdr=RPT=hKKr5Azy4Q@mail.gmail.com>
Subject: Re: [PATCH v3 4/7] mm: unify SLAB and SLUB page accounting
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <kernel-team@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, 
	Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Roman Gushchin <guro@fb.com>
Date: Wed, May 8, 2019 at 1:40 PM
To: Andrew Morton, Shakeel Butt
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
<kernel-team@fb.com>, Johannes Weiner, Michal Hocko, Rik van Riel,
Christoph Lameter, Vladimir Davydov, <cgroups@vger.kernel.org>, Roman
Gushchin

> Currently the page accounting code is duplicated in SLAB and SLUB
> internals. Let's move it into new (un)charge_slab_page helpers
> in the slab_common.c file. These helpers will be responsible
> for statistics (global and memcg-aware) and memcg charging.
> So they are replacing direct memcg_(un)charge_slab() calls.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>


> ---
>  mm/slab.c | 19 +++----------------
>  mm/slab.h | 25 +++++++++++++++++++++++++
>  mm/slub.c | 14 ++------------
>  3 files changed, 30 insertions(+), 28 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 83000e46b870..32e6af9ed9af 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1389,7 +1389,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
>                                                                 int nodeid)
>  {
>         struct page *page;
> -       int nr_pages;
>
>         flags |= cachep->allocflags;
>
> @@ -1399,17 +1398,11 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
>                 return NULL;
>         }
>
> -       if (memcg_charge_slab(page, flags, cachep->gfporder, cachep)) {
> +       if (charge_slab_page(page, flags, cachep->gfporder, cachep)) {
>                 __free_pages(page, cachep->gfporder);
>                 return NULL;
>         }
>
> -       nr_pages = (1 << cachep->gfporder);
> -       if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> -               mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, nr_pages);
> -       else
> -               mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, nr_pages);
> -
>         __SetPageSlab(page);
>         /* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
>         if (sk_memalloc_socks() && page_is_pfmemalloc(page))
> @@ -1424,12 +1417,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
>  static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
>  {
>         int order = cachep->gfporder;
> -       unsigned long nr_freed = (1 << order);
> -
> -       if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> -               mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, -nr_freed);
> -       else
> -               mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, -nr_freed);
>
>         BUG_ON(!PageSlab(page));
>         __ClearPageSlabPfmemalloc(page);
> @@ -1438,8 +1425,8 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
>         page->mapping = NULL;
>
>         if (current->reclaim_state)
> -               current->reclaim_state->reclaimed_slab += nr_freed;
> -       memcg_uncharge_slab(page, order, cachep);
> +               current->reclaim_state->reclaimed_slab += 1 << order;
> +       uncharge_slab_page(page, order, cachep);
>         __free_pages(page, order);
>  }
>
> diff --git a/mm/slab.h b/mm/slab.h
> index 4a261c97c138..c9a31120fa1d 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -205,6 +205,12 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
>  void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
>  int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
>
> +static inline int cache_vmstat_idx(struct kmem_cache *s)
> +{
> +       return (s->flags & SLAB_RECLAIM_ACCOUNT) ?
> +               NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
> +}
> +
>  #ifdef CONFIG_MEMCG_KMEM
>
>  /* List of all root caches. */
> @@ -352,6 +358,25 @@ static inline void memcg_link_cache(struct kmem_cache *s,
>
>  #endif /* CONFIG_MEMCG_KMEM */
>
> +static __always_inline int charge_slab_page(struct page *page,
> +                                           gfp_t gfp, int order,
> +                                           struct kmem_cache *s)
> +{
> +       int ret = memcg_charge_slab(page, gfp, order, s);
> +
> +       if (!ret)
> +               mod_lruvec_page_state(page, cache_vmstat_idx(s), 1 << order);
> +
> +       return ret;
> +}
> +
> +static __always_inline void uncharge_slab_page(struct page *page, int order,
> +                                              struct kmem_cache *s)
> +{
> +       mod_lruvec_page_state(page, cache_vmstat_idx(s), -(1 << order));
> +       memcg_uncharge_slab(page, order, s);
> +}
> +
>  static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
>  {
>         struct kmem_cache *cachep;
> diff --git a/mm/slub.c b/mm/slub.c
> index 43c34d54ad86..9ec25a588bdd 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1494,7 +1494,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
>         else
>                 page = __alloc_pages_node(node, flags, order);
>
> -       if (page && memcg_charge_slab(page, flags, order, s)) {
> +       if (page && charge_slab_page(page, flags, order, s)) {
>                 __free_pages(page, order);
>                 page = NULL;
>         }
> @@ -1687,11 +1687,6 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>         if (!page)
>                 return NULL;
>
> -       mod_lruvec_page_state(page,
> -               (s->flags & SLAB_RECLAIM_ACCOUNT) ?
> -               NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
> -               1 << oo_order(oo));
> -
>         inc_slabs_node(s, page_to_nid(page), page->objects);
>
>         return page;
> @@ -1725,18 +1720,13 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
>                         check_object(s, page, p, SLUB_RED_INACTIVE);
>         }
>
> -       mod_lruvec_page_state(page,
> -               (s->flags & SLAB_RECLAIM_ACCOUNT) ?
> -               NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
> -               -pages);
> -
>         __ClearPageSlabPfmemalloc(page);
>         __ClearPageSlab(page);
>
>         page->mapping = NULL;
>         if (current->reclaim_state)
>                 current->reclaim_state->reclaimed_slab += pages;
> -       memcg_uncharge_slab(page, order, s);
> +       uncharge_slab_page(page, order, s);
>         __free_pages(page, order);
>  }
>
> --
> 2.20.1
>

