Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1761F6B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 04:26:15 -0400 (EDT)
Received: by obuk4 with SMTP id k4so77597221obu.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 01:26:14 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id jw5si1751271oeb.31.2015.09.08.01.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 01:26:14 -0700 (PDT)
Received: by oiev17 with SMTP id v17so54496186oie.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 01:26:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150824123015.GJ12432@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
	<20150824123015.GJ12432@techsingularity.net>
Date: Tue, 8 Sep 2015 17:26:13 +0900
Message-ID: <CAAmzW4NbjqOpDhNKp7POVLZyaoUJa6YU5-B9Xz2b+crkzD25+g@mail.gmail.com>
Subject: Re: [PATCH 12/12] mm, page_alloc: Only enforce watermarks for order-0 allocations
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2015-08-24 21:30 GMT+09:00 Mel Gorman <mgorman@techsingularity.net>:
> The primary purpose of watermarks is to ensure that reclaim can always
> make forward progress in PF_MEMALLOC context (kswapd and direct reclaim).
> These assume that order-0 allocations are all that is necessary for
> forward progress.
>
> High-order watermarks serve a different purpose. Kswapd had no high-order
> awareness before they were introduced (https://lkml.org/lkml/2004/9/5/9).
> This was particularly important when there were high-order atomic requests.
> The watermarks both gave kswapd awareness and made a reserve for those
> atomic requests.
>
> There are two important side-effects of this. The most important is that
> a non-atomic high-order request can fail even though free pages are available
> and the order-0 watermarks are ok. The second is that high-order watermark
> checks are expensive as the free list counts up to the requested order must
> be examined.
>
> With the introduction of MIGRATE_HIGHATOMIC it is no longer necessary to
> have high-order watermarks. Kswapd and compaction still need high-order
> awareness which is handled by checking that at least one suitable high-order
> page is free.

I still don't think that this one suitable high-order page is enough.
If fragmentation happens, there would be no order-2 freepage. If kswapd
prepares only 1 order-2 freepage, one of two successive process forks
(AFAIK, fork in x86 and ARM require order 2 page) must go to direct reclaim
to make order-2 freepage. Kswapd cannot make order-2 freepage in that
short time. It causes latency to many high-order freepage requestor
in fragmented situation.

> With the patch applied, there was little difference in the allocation
> failure rates as the atomic reserves are small relative to the number of
> allocation attempts. The expected impact is that there will never be an
> allocation failure report that shows suitable pages on the free lists.

Due to highatomic pageblock and freepage count mismatch per allocation
flag, allocation failure with suitable pages can still be possible.

> The one potential side-effect of this is that in a vanilla kernel, the
> watermark checks may have kept a free page for an atomic allocation. Now,
> we are 100% relying on the HighAtomic reserves and an early allocation to
> have allocated them.  If the first high-order atomic allocation is after
> the system is already heavily fragmented then it'll fail.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/page_alloc.c | 38 ++++++++++++++++++++++++--------------
>  1 file changed, 24 insertions(+), 14 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2415f882b89c..35dc578730d1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2280,8 +2280,10 @@ static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>  #endif /* CONFIG_FAIL_PAGE_ALLOC */
>
>  /*
> - * Return true if free pages are above 'mark'. This takes into account the order
> - * of the allocation.
> + * Return true if free base pages are above 'mark'. For high-order checks it
> + * will return true of the order-0 watermark is reached and there is at least
> + * one free page of a suitable size. Checking now avoids taking the zone lock
> + * to check in the allocation paths if no pages are free.
>   */
>  static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>                         unsigned long mark, int classzone_idx, int alloc_flags,
> @@ -2289,7 +2291,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  {
>         long min = mark;
>         int o;
> -       long free_cma = 0;
> +       const bool atomic = (alloc_flags & ALLOC_HARDER);
>
>         /* free_pages may go negative - that's OK */
>         free_pages -= (1 << order) - 1;
> @@ -2301,7 +2303,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>          * If the caller is not atomic then discount the reserves. This will
>          * over-estimate how the atomic reserve but it avoids a search
>          */
> -       if (likely(!(alloc_flags & ALLOC_HARDER)))
> +       if (likely(!atomic))
>                 free_pages -= z->nr_reserved_highatomic;
>         else
>                 min -= min / 4;
> @@ -2309,22 +2311,30 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  #ifdef CONFIG_CMA
>         /* If allocation can't use CMA areas don't use free CMA pages */
>         if (!(alloc_flags & ALLOC_CMA))
> -               free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
> +               free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
>  #endif
>
> -       if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
> +       if (free_pages <= min + z->lowmem_reserve[classzone_idx])
>                 return false;
> -       for (o = 0; o < order; o++) {
> -               /* At the next order, this order's pages become unavailable */
> -               free_pages -= z->free_area[o].nr_free << o;
>
> -               /* Require fewer higher order pages to be free */
> -               min >>= 1;
> +       /* order-0 watermarks are ok */
> +       if (!order)
> +               return true;
> +
> +       /* Check at least one high-order page is free */
> +       for (o = order; o < MAX_ORDER; o++) {
> +               struct free_area *area = &z->free_area[o];
> +               int mt;
> +
> +               if (atomic && area->nr_free)
> +                       return true;

How about checking area->nr_free first?
In both atomic and !atomic case, nr_free == 0 means
there is no appropriate pages.

So,
if (!area->nr_free)
    continue;
if (atomic)
    return true;
...


> -               if (free_pages <= min)
> -                       return false;
> +               for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
> +                       if (!list_empty(&area->free_list[mt]))
> +                               return true;
> +               }

I'm not sure this is really faster than previous.
We need to check three lists on each order.

Think about order-2 case. I guess order-2 is usually on movable
pageblock rather than unmovable pageblock. In this case,
we need to check three lists so cost is more.

And, if system is fragmented and has not enough order-2 freepage,
we need to check 3,4,..., MAX_ORDER-1 to find out that
there is no order-2 freepage. This would be more costly
than previous approach.

Thanks.

>         }
> -       return true;
> +       return false;
>  }
>
>  bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
> --
> 2.4.6
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
