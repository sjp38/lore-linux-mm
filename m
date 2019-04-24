Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32FCAC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 17:23:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB1CD205ED
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 17:23:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Vt3p40z+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB1CD205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B9C56B0005; Wed, 24 Apr 2019 13:23:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5696D6B0006; Wed, 24 Apr 2019 13:23:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 457746B0007; Wed, 24 Apr 2019 13:23:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25FCA6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:23:58 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id i80so14984198ybg.22
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:23:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=P/nz9VR/h2t1C0BDhNs/FXtJ48OP3Xb65UuEQTQTNEE=;
        b=a16TQ1BD1sq7qu9WwxY9/D0in2wvr/yT9M2i5AI1jSvgV5GROYu87fcmkSl+6AHJF4
         Ncyeq2iIxfq74Ch0KfVTuxYKjpZNrZ23WoTIKVp1mWiy3AFXxu/Uv+dhr8NbP4Cztyg3
         iPofyZXazCH3L1Nrqtud1b73xUXui6JtbkmN7OoM8/uYc7uvAn9NnvwlHEW+nO5b6mnU
         DBFEEAn6JBCqyzLm2CQQ8hMMQMgdI/QDukJINmWSia7sVxYHOIKs04djiVChRz7136v3
         Z4DkVxI1yAcwAGqf5EeqIGgPqVOnjr/vBJ4kTlsYC88GQaa9GBIgixnuFcHFE9D4h/Zz
         rEyw==
X-Gm-Message-State: APjAAAUhhsoGW+oNKs07N+xc6EB3gvISOF2gkPRKx4fMVSnOLSUl4FKj
	+YyaPrvxWENHEkEc+YzW6Edk/eBkjlFyRF+XiH/T+wWTHmdLsUnAOba3wx5ZZw3iL0RFQprIwvt
	QEgNnyjv/JE+mDAyOaWOAK9B7U3cIw1aBGbooa6QABkP6HXXY9JKHXKAeX10gGCDgLg==
X-Received: by 2002:a25:25d2:: with SMTP id l201mr28338260ybl.257.1556126637831;
        Wed, 24 Apr 2019 10:23:57 -0700 (PDT)
X-Received: by 2002:a25:25d2:: with SMTP id l201mr28338199ybl.257.1556126637106;
        Wed, 24 Apr 2019 10:23:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556126637; cv=none;
        d=google.com; s=arc-20160816;
        b=wa2O0fLEvoF61gOuRNIB8AOykGuxndsMQXGmWbFRtEkcHJBFF75rt9Oa5AKzG8Vzsm
         8Tt8/KBS4S74nm4/zRQai76qiBk+O++m/X3CUJQBVq8B/hvrVrkRd1TFCZ89RD8TCdYg
         XDZNGiAZKUVpb1Vw5s62vcbephWFy6vyWBHb8kEOTeW3h20dXhJrNsmssdZzTezdBs1O
         Ept+xhLJpFi2BpUjnWVaCzCqXNZIy6CpHssi9gSeOo7A8I5SdKnQ3Rj/zMeJzGl9lRv1
         /EX7Xy1hUvDHcYhI6iIYbkrgNrCe/byDCmmZUgGETSyi86mBPnCKsKaOrR9r3m++xg9m
         MdNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=P/nz9VR/h2t1C0BDhNs/FXtJ48OP3Xb65UuEQTQTNEE=;
        b=iiYywu70DWqIFx+jLiw9qu+vS0KDFiCQGFeW7dTyr6ExLeJUmWOdoCqz5+Bh6Srl0n
         uJYiEv0bG0s8DdkSOCl7RizbFfn/V1Zbi25K80R9fsRZTHAF8+Dl4+m9dZzvlkvkmfrD
         n7mt1dT5THyjcl6JF/wiBE3gwaqNz3Kes8xhLuyQCn6pw++3ohvD4IYDJo04jfgwy/oh
         +vDioWld9t4NRQD6+48JG1eIdIH85CztD8E3oZf6Gpg02MuR46NT1ux2sW4wVms//ioV
         lge1AaodUtEZnnZNB9k3xBcBXYywyygeMQc+8kiQOPPHj+Nwhcu9eDdsJg9hxfKvyq1E
         Ln4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Vt3p40z+;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v188sor8640394ywv.185.2019.04.24.10.23.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 10:23:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Vt3p40z+;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=P/nz9VR/h2t1C0BDhNs/FXtJ48OP3Xb65UuEQTQTNEE=;
        b=Vt3p40z+raPN5tAp3qp0BsPy91f6BiaoxxlBm9cRok1FjkccVUaH2Rvmi+1Rgw3NFP
         ZXmxhYzoK7JpHWD35WfNXmv5F0bH7y5z+T26AepQlpLzeVZ2sMslPeU2MGny6G6M8DAY
         N98BT6DMiHguAcXyiAp2920sXzczkW6CDLUgB0d/b5V2ww3yUzBeUoxtrIi0ERuR9MMR
         fPe89YMsDx0QJB7/xMLO5SmUPGXq2VfSWCL0FbvKMP/VLLx0i1xIlLNuaIUjxFHkPTQe
         gZLAIVdspnd+fSTumdyjkQGSb52+fbv6UyvIhSlCXMtoIRB6MttLnw4DfY4Mm+xVXrH6
         7Dmg==
X-Google-Smtp-Source: APXvYqwEAA+o9fjHgMNik2D6cPaCQj9XkIZYRv4qFpJW86ir8ocBUPoF/b5vAbPPEayUA5pmG8gBqteUMCjnR8DZbCI=
X-Received: by 2002:a81:480d:: with SMTP id v13mr13052602ywa.489.1556126636403;
 Wed, 24 Apr 2019 10:23:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190423213133.3551969-1-guro@fb.com> <20190423213133.3551969-5-guro@fb.com>
In-Reply-To: <20190423213133.3551969-5-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 24 Apr 2019 10:23:45 -0700
Message-ID: <CALvZod6A43nQgkYj38K4h_ZYLSmYp0xJwO7n44kGJx2Ut7-EVg@mail.gmail.com>
Subject: Re: [PATCH v2 4/6] mm: unify SLAB and SLUB page accounting
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

Hi Roman,

On Tue, Apr 23, 2019 at 9:30 PM Roman Gushchin <guro@fb.com> wrote:
>
> Currently the page accounting code is duplicated in SLAB and SLUB
> internals. Let's move it into new (un)charge_slab_page helpers
> in the slab_common.c file. These helpers will be responsible
> for statistics (global and memcg-aware) and memcg charging.
> So they are replacing direct memcg_(un)charge_slab() calls.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> ---
>  mm/slab.c | 19 +++----------------
>  mm/slab.h | 22 ++++++++++++++++++++++
>  mm/slub.c | 14 ++------------
>  3 files changed, 27 insertions(+), 28 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 14466a73d057..53e6b2687102 100644
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
> index 4a261c97c138..0f5c5444acf1 100644
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
> @@ -352,6 +358,22 @@ static inline void memcg_link_cache(struct kmem_cache *s,
>
>  #endif /* CONFIG_MEMCG_KMEM */
>
> +static __always_inline int charge_slab_page(struct page *page,
> +                                           gfp_t gfp, int order,
> +                                           struct kmem_cache *s)
> +{
> +       memcg_charge_slab(page, gfp, order, s);

This does not seem right. Why the return of memcg_charge_slab is ignored?


> +       mod_lruvec_page_state(page, cache_vmstat_idx(s), 1 << order);
> +       return 0;
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
> index 195f61785c7d..90563c0b3b5f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1499,7 +1499,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
>         else
>                 page = __alloc_pages_node(node, flags, order);
>
> -       if (page && memcg_charge_slab(page, flags, order, s)) {
> +       if (page && charge_slab_page(page, flags, order, s)) {
>                 __free_pages(page, order);
>                 page = NULL;
>         }
> @@ -1692,11 +1692,6 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
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
> @@ -1730,18 +1725,13 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
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

