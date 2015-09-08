Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 981226B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 04:01:07 -0400 (EDT)
Received: by oibi136 with SMTP id i136so54384613oib.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 01:01:07 -0700 (PDT)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id uq5si1710555obc.23.2015.09.08.01.01.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 01:01:06 -0700 (PDT)
Received: by obqa2 with SMTP id a2so76924940obq.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 01:01:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150824122957.GI12432@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
	<20150824122957.GI12432@techsingularity.net>
Date: Tue, 8 Sep 2015 17:01:06 +0900
Message-ID: <CAAmzW4O7N8NZVE4DS25a4FROem-pJOEYxAsqEBtPsjWuNSZyrQ@mail.gmail.com>
Subject: Re: [PATCH 11/12] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2015-08-24 21:29 GMT+09:00 Mel Gorman <mgorman@techsingularity.net>:
> High-order watermark checking exists for two reasons --  kswapd high-order
> awareness and protection for high-order atomic requests. Historically the
> kernel depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order
> free pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
> that reserves pageblocks for high-order atomic allocations on demand and
> avoids using those blocks for order-0 allocations. This is more flexible
> and reliable than MIGRATE_RESERVE was.
>
> A MIGRATE_HIGHORDER pageblock is created when a high-order allocation
> request steals a pageblock but limits the total number to 1% of the zone.
> Callers that speculatively abuse atomic allocations for long-lived
> high-order allocations to access the reserve will quickly fail. Note that
> SLUB is currently not such an abuser as it reclaims at least once.  It is
> possible that the pageblock stolen has few suitable high-order pages and
> will need to steal again in the near future but there would need to be
> strong justification to search all pageblocks for an ideal candidate.
>
> The pageblocks are unreserved if an allocation fails after a direct
> reclaim attempt.
>
> The watermark checks account for the reserved pageblocks when the allocation
> request is not a high-order atomic allocation.
>
> The reserved pageblocks can not be used for order-0 allocations. This may
> allow temporary wastage until a failed reclaim reassigns the pageblock. This
> is deliberate as the intent of the reservation is to satisfy a limited
> number of atomic high-order short-lived requests if the system requires them.
>
> The stutter benchmark was used to evaluate this but while it was running
> there was a systemtap script that randomly allocated between 1 high-order
> page and 12.5% of memory's worth of order-3 pages using GFP_ATOMIC. This
> is much larger than the potential reserve and it does not attempt to be
> realistic.  It is intended to stress random high-order allocations from
> an unknown source, show that there is a reduction in failures without
> introducing an anomaly where atomic allocations are more reliable than
> regular allocations.  The amount of memory reserved varied throughout the
> workload as reserves were created and reclaimed under memory pressure. The
> allocation failures once the workload warmed up were as follows;
>
> 4.2-rc5-vanilla         70%
> 4.2-rc5-atomic-reserve  56%
>
> The failure rate was also measured while building multiple kernels. The
> failure rate was 14% but is 6% with this patch applied.
>
> Overall, this is a small reduction but the reserves are small relative to the
> number of allocation requests. In early versions of the patch, the failure
> rate reduced by a much larger amount but that required much larger reserves
> and perversely made atomic allocations seem more reliable than regular allocations.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  include/linux/mmzone.h |   6 ++-
>  mm/page_alloc.c        | 117 ++++++++++++++++++++++++++++++++++++++++++++++---
>  mm/vmstat.c            |   1 +
>  3 files changed, 116 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index cf643539d640..a9805a85940a 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -39,6 +39,8 @@ enum {
>         MIGRATE_UNMOVABLE,
>         MIGRATE_MOVABLE,
>         MIGRATE_RECLAIMABLE,
> +       MIGRATE_PCPTYPES,       /* the number of types on the pcp lists */
> +       MIGRATE_HIGHATOMIC = MIGRATE_PCPTYPES,
>  #ifdef CONFIG_CMA
>         /*
>          * MIGRATE_CMA migration type is designed to mimic the way
> @@ -61,8 +63,6 @@ enum {
>         MIGRATE_TYPES
>  };
>
> -#define MIGRATE_PCPTYPES (MIGRATE_RECLAIMABLE+1)
> -
>  #ifdef CONFIG_CMA
>  #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
>  #else
> @@ -330,6 +330,8 @@ struct zone {
>         /* zone watermarks, access with *_wmark_pages(zone) macros */
>         unsigned long watermark[NR_WMARK];
>
> +       unsigned long nr_reserved_highatomic;
> +
>         /*
>          * We don't know if the memory that we're going to allocate will be freeable
>          * or/and it will be released eventually, so to avoid totally wasting several
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d5ce050ebe4f..2415f882b89c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1589,6 +1589,86 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
>         return -1;
>  }
>
> +/*
> + * Reserve a pageblock for exclusive use of high-order atomic allocations if
> + * there are no empty page blocks that contain a page with a suitable order
> + */
> +static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
> +                               unsigned int alloc_order)
> +{
> +       int mt = get_pageblock_migratetype(page);
> +       unsigned long max_managed, flags;
> +
> +       if (mt == MIGRATE_HIGHATOMIC)
> +               return;
> +
> +       /*
> +        * Limit the number reserved to 1 pageblock or roughly 1% of a zone.
> +        * Check is race-prone but harmless.
> +        */
> +       max_managed = (zone->managed_pages / 100) + pageblock_nr_pages;
> +       if (zone->nr_reserved_highatomic >= max_managed)
> +               return;
> +
> +       /* Yoink! */
> +       spin_lock_irqsave(&zone->lock, flags);
> +       zone->nr_reserved_highatomic += pageblock_nr_pages;
> +       set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
> +       move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
> +       spin_unlock_irqrestore(&zone->lock, flags);
> +}

It is better to check if migratetype is MIGRATE_ISOLATE or MIGRATE_CMA.
There can be race that isolated pageblock is changed to MIGRATE_HIGHATOMIC.

> +/*
> + * Used when an allocation is about to fail under memory pressure. This
> + * potentially hurts the reliability of high-order allocations when under
> + * intense memory pressure but failed atomic allocations should be easier
> + * to recover from than an OOM.
> + */
> +static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> +{
> +       struct zonelist *zonelist = ac->zonelist;
> +       unsigned long flags;
> +       struct zoneref *z;
> +       struct zone *zone;
> +       struct page *page;
> +       int order;
> +
> +       for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
> +                                                               ac->nodemask) {
> +               /* Preserve at least one pageblock */
> +               if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
> +                       continue;
> +
> +               spin_lock_irqsave(&zone->lock, flags);
> +               for (order = 0; order < MAX_ORDER; order++) {
> +                       struct free_area *area = &(zone->free_area[order]);
> +
> +                       if (list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
> +                               continue;
> +
> +                       page = list_entry(area->free_list[MIGRATE_HIGHATOMIC].next,
> +                                               struct page, lru);
> +
> +                       zone->nr_reserved_highatomic -= pageblock_nr_pages;
> +
> +                       /*
> +                        * Convert to ac->migratetype and avoid the normal
> +                        * pageblock stealing heuristics. Minimally, the caller
> +                        * is doing the work and needs the pages. More
> +                        * importantly, if the block was always converted to
> +                        * MIGRATE_UNMOVABLE or another type then the number
> +                        * of pageblocks that cannot be completely freed
> +                        * may increase.
> +                        */
> +                       set_pageblock_migratetype(page, ac->migratetype);
> +                       move_freepages_block(zone, page, ac->migratetype);
> +                       spin_unlock_irqrestore(&zone->lock, flags);
> +                       return;
> +               }
> +               spin_unlock_irqrestore(&zone->lock, flags);
> +       }
> +}
> +
>  /* Remove an element from the buddy allocator from the fallback list */
>  static inline struct page *
>  __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> @@ -1645,10 +1725,16 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>   * Call me with the zone->lock already held.
>   */
>  static struct page *__rmqueue(struct zone *zone, unsigned int order,
> -                                               int migratetype)
> +                               int migratetype, gfp_t gfp_flags)
>  {
>         struct page *page;
>
> +       if (unlikely(order && (gfp_flags & __GFP_ATOMIC))) {
> +               page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> +               if (page)
> +                       goto out;
> +       }

This hunk only serves for high order allocation so it is better to introduce
rmqueue_highorder() and move this hunk to that function and call it in
buffered_rmqueue. It makes order-0 request doesn't get worse
by adding new branch.

And, there is some mismatch that check atomic high-order allocation.
In some place, you checked __GFP_ATOMIC, but some other places,
you checked ALLOC_HARDER. It is better to use unified one.
Introducing helper function may be a good choice.

>         page = __rmqueue_smallest(zone, order, migratetype);
>         if (unlikely(!page)) {
>                 if (migratetype == MIGRATE_MOVABLE)
> @@ -1658,6 +1744,7 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
>                         page = __rmqueue_fallback(zone, order, migratetype);
>         }
>
> +out:
>         trace_mm_page_alloc_zone_locked(page, order, migratetype);
>         return page;
>  }
> @@ -1675,7 +1762,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>
>         spin_lock(&zone->lock);
>         for (i = 0; i < count; ++i) {
> -               struct page *page = __rmqueue(zone, order, migratetype);
> +               struct page *page = __rmqueue(zone, order, migratetype, 0);
>                 if (unlikely(page == NULL))
>                         break;
>
> @@ -2090,7 +2177,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>                         WARN_ON_ONCE(order > 1);
>                 }
>                 spin_lock_irqsave(&zone->lock, flags);
> -               page = __rmqueue(zone, order, migratetype);
> +               page = __rmqueue(zone, order, migratetype, gfp_flags);
>                 spin_unlock(&zone->lock);
>                 if (!page)
>                         goto failed;
> @@ -2200,15 +2287,23 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>                         unsigned long mark, int classzone_idx, int alloc_flags,
>                         long free_pages)
>  {
> -       /* free_pages may go negative - that's OK */
>         long min = mark;
>         int o;
>         long free_cma = 0;
>
> +       /* free_pages may go negative - that's OK */
>         free_pages -= (1 << order) - 1;
> +
>         if (alloc_flags & ALLOC_HIGH)
>                 min -= min / 2;
> -       if (alloc_flags & ALLOC_HARDER)
> +
> +       /*
> +        * If the caller is not atomic then discount the reserves. This will
> +        * over-estimate how the atomic reserve but it avoids a search
> +        */
> +       if (likely(!(alloc_flags & ALLOC_HARDER)))
> +               free_pages -= z->nr_reserved_highatomic;
> +       else
>                 min -= min / 4;
>
>  #ifdef CONFIG_CMA
> @@ -2397,6 +2492,14 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>                 if (page) {
>                         if (prep_new_page(page, order, gfp_mask, alloc_flags))
>                                 goto try_this_zone;
> +
> +                       /*
> +                        * If this is a high-order atomic allocation then check
> +                        * if the pageblock should be reserved for the future
> +                        */
> +                       if (unlikely(order && (alloc_flags & ALLOC_HARDER)))
> +                               reserve_highatomic_pageblock(page, zone, order);
> +
>                         return page;
>                 }
>         }
> @@ -2664,9 +2767,11 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>
>         /*
>          * If an allocation failed after direct reclaim, it could be because
> -        * pages are pinned on the per-cpu lists. Drain them and try again
> +        * pages are pinned on the per-cpu lists or in high alloc reserves.
> +        * Shrink them them and try again
>          */
>         if (!page && !drained) {
> +               unreserve_highatomic_pageblock(ac);
>                 drain_all_pages(NULL);
>                 drained = true;
>                 goto retry;

In case of high-order request, it can easily fail even after direct reclaim.
It can cause ping-pong effect on highatomic pageblock.
Unreserve on order-0 request fail is one option to avoid that problem.

Anyway, do you measure fragmentation effect of this patch?

High-order atomic request is usually unmovable and it would be served
by unmovable pageblock. And then, it is changed to highatomic.
But, reclaim can be triggered by movable request and this unreserve
makes that pageblock to movable type.

So, following sequence of transition will usually happen.

unmovable -> highatomic -> movable

It can reduce number of unmovable pageblock and unmovable
allocation can be spread and cause fragmentation. I'd like to see
result about fragmentation. Highorder stress benchmark can be
one of candidates.

Thanks.

> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 49963aa2dff3..3427a155f85e 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -901,6 +901,7 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
>         "Unmovable",
>         "Reclaimable",
>         "Movable",
> +       "HighAtomic",
>  #ifdef CONFIG_CMA
>         "CMA",
>  #endif
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
