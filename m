Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id CB2416B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 02:37:57 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so42895136pac.2
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 23:37:57 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id bu8si11157533pad.7.2015.09.17.23.37.55
        for <linux-mm@kvack.org>;
        Thu, 17 Sep 2015 23:37:56 -0700 (PDT)
Date: Fri, 18 Sep 2015 15:38:35 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 11/12] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
Message-ID: <20150918063835.GB7769@js1304-P5Q-DELUXE>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <20150824122957.GI12432@techsingularity.net>
 <CAAmzW4O7N8NZVE4DS25a4FROem-pJOEYxAsqEBtPsjWuNSZyrQ@mail.gmail.com>
 <20150909123239.GZ12432@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150909123239.GZ12432@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Sep 09, 2015 at 01:32:39PM +0100, Mel Gorman wrote:
> On Tue, Sep 08, 2015 at 05:01:06PM +0900, Joonsoo Kim wrote:
> > 2015-08-24 21:29 GMT+09:00 Mel Gorman <mgorman@techsingularity.net>:
> > > <SNIP>
> > >
> > > +/*
> > > + * Reserve a pageblock for exclusive use of high-order atomic allocations if
> > > + * there are no empty page blocks that contain a page with a suitable order
> > > + */
> > > +static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
> > > +                               unsigned int alloc_order)
> > > +{
> > > +       int mt = get_pageblock_migratetype(page);
> > > +       unsigned long max_managed, flags;
> > > +
> > > +       if (mt == MIGRATE_HIGHATOMIC)
> > > +               return;
> > > +
> > > +       /*
> > > +        * Limit the number reserved to 1 pageblock or roughly 1% of a zone.
> > > +        * Check is race-prone but harmless.
> > > +        */
> > > +       max_managed = (zone->managed_pages / 100) + pageblock_nr_pages;
> > > +       if (zone->nr_reserved_highatomic >= max_managed)
> > > +               return;
> > > +
> > > +       /* Yoink! */
> > > +       spin_lock_irqsave(&zone->lock, flags);
> > > +       zone->nr_reserved_highatomic += pageblock_nr_pages;
> > > +       set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
> > > +       move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
> > > +       spin_unlock_irqrestore(&zone->lock, flags);
> > > +}
> > 
> > It is better to check if migratetype is MIGRATE_ISOLATE or MIGRATE_CMA.
> > There can be race that isolated pageblock is changed to MIGRATE_HIGHATOMIC.
> > 
> 
> Done.
> 
> > > +/*
> > > + * Used when an allocation is about to fail under memory pressure. This
> > > + * potentially hurts the reliability of high-order allocations when under
> > > + * intense memory pressure but failed atomic allocations should be easier
> > > + * to recover from than an OOM.
> > > + */
> > > +static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> > > +{
> > > +       struct zonelist *zonelist = ac->zonelist;
> > > +       unsigned long flags;
> > > +       struct zoneref *z;
> > > +       struct zone *zone;
> > > +       struct page *page;
> > > +       int order;
> > > +
> > > +       for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
> > > +                                                               ac->nodemask) {
> > > +               /* Preserve at least one pageblock */
> > > +               if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
> > > +                       continue;
> > > +
> > > +               spin_lock_irqsave(&zone->lock, flags);
> > > +               for (order = 0; order < MAX_ORDER; order++) {
> > > +                       struct free_area *area = &(zone->free_area[order]);
> > > +
> > > +                       if (list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
> > > +                               continue;
> > > +
> > > +                       page = list_entry(area->free_list[MIGRATE_HIGHATOMIC].next,
> > > +                                               struct page, lru);
> > > +
> > > +                       zone->nr_reserved_highatomic -= pageblock_nr_pages;
> > > +
> > > +                       /*
> > > +                        * Convert to ac->migratetype and avoid the normal
> > > +                        * pageblock stealing heuristics. Minimally, the caller
> > > +                        * is doing the work and needs the pages. More
> > > +                        * importantly, if the block was always converted to
> > > +                        * MIGRATE_UNMOVABLE or another type then the number
> > > +                        * of pageblocks that cannot be completely freed
> > > +                        * may increase.
> > > +                        */
> > > +                       set_pageblock_migratetype(page, ac->migratetype);
> > > +                       move_freepages_block(zone, page, ac->migratetype);
> > > +                       spin_unlock_irqrestore(&zone->lock, flags);
> > > +                       return;
> > > +               }
> > > +               spin_unlock_irqrestore(&zone->lock, flags);
> > > +       }
> > > +}
> > > +
> > >  /* Remove an element from the buddy allocator from the fallback list */
> > >  static inline struct page *
> > >  __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> > > @@ -1645,10 +1725,16 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> > >   * Call me with the zone->lock already held.
> > >   */
> > >  static struct page *__rmqueue(struct zone *zone, unsigned int order,
> > > -                                               int migratetype)
> > > +                               int migratetype, gfp_t gfp_flags)
> > >  {
> > >         struct page *page;
> > >
> > > +       if (unlikely(order && (gfp_flags & __GFP_ATOMIC))) {
> > > +               page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> > > +               if (page)
> > > +                       goto out;
> > > +       }
> > 
> > This hunk only serves for high order allocation so it is better to introduce
> > rmqueue_highorder() and move this hunk to that function and call it in
> > buffered_rmqueue. It makes order-0 request doesn't get worse
> > by adding new branch.
> > 
> 
> The helper is overkill. I can move the check to avoid the branch but it
> duplicates the tracepoint handling which can be easy to miss in the
> future. I'm not convinced it is an overall improvement.
> 
> > And, there is some mismatch that check atomic high-order allocation.
> > In some place, you checked __GFP_ATOMIC, but some other places,
> > you checked ALLOC_HARDER. It is better to use unified one.
> > Introducing helper function may be a good choice.
> > 
> 
> Which cases specifically? In the zone_watermark check, it's because
> there is no GFP flags in that context. They could be passed in but then
> every caller needs to be updated accordingly and overall it gains
> nothing.

You use __GFP_ATOMIC in rmqueue() to allow highatomic reserve.
ALLOC_HARDER is used in watermark check and to reserve highatomic
pageblock after allocation.

ALLOC_HARDER is set if (__GFP_ATOMIC && !__GFP_NOMEMALLOC) *or*
(rt_task && !in_interrupt()). So, later case could pass watermark
check but cannot use HIGHATOMIC reserve. And, it will reserve
highatomic pageblock. When it try to allocate again, it can't use
this reserved pageblock due to GFP flags and this could happens
repeatedly.
And, first case also has a problem. If user requests memory
with __GFP_NOMEMALLOC, it's intend doesn't touch reserved mem,
but, in current patch, it can use highatomic pageblock.

I'm not sure these causes real trouble but unifying it as much as
possible is preferable solution.

Thanks.

> 
> > >         page = __rmqueue_smallest(zone, order, migratetype);
> > >         if (unlikely(!page)) {
> > >                 if (migratetype == MIGRATE_MOVABLE)
> > > @@ -1658,6 +1744,7 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
> > >                         page = __rmqueue_fallback(zone, order, migratetype);
> > >         }
> > >
> > > +out:
> > >         trace_mm_page_alloc_zone_locked(page, order, migratetype);
> > >         return page;
> > >  }
> > > @@ -1675,7 +1762,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
> > >
> > >         spin_lock(&zone->lock);
> > >         for (i = 0; i < count; ++i) {
> > > -               struct page *page = __rmqueue(zone, order, migratetype);
> > > +               struct page *page = __rmqueue(zone, order, migratetype, 0);
> > >                 if (unlikely(page == NULL))
> > >                         break;
> > >
> > > @@ -2090,7 +2177,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
> > >                         WARN_ON_ONCE(order > 1);
> > >                 }
> > >                 spin_lock_irqsave(&zone->lock, flags);
> > > -               page = __rmqueue(zone, order, migratetype);
> > > +               page = __rmqueue(zone, order, migratetype, gfp_flags);
> > >                 spin_unlock(&zone->lock);
> > >                 if (!page)
> > >                         goto failed;
> > > @@ -2200,15 +2287,23 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> > >                         unsigned long mark, int classzone_idx, int alloc_flags,
> > >                         long free_pages)
> > >  {
> > > -       /* free_pages may go negative - that's OK */
> > >         long min = mark;
> > >         int o;
> > >         long free_cma = 0;
> > >
> > > +       /* free_pages may go negative - that's OK */
> > >         free_pages -= (1 << order) - 1;
> > > +
> > >         if (alloc_flags & ALLOC_HIGH)
> > >                 min -= min / 2;
> > > -       if (alloc_flags & ALLOC_HARDER)
> > > +
> > > +       /*
> > > +        * If the caller is not atomic then discount the reserves. This will
> > > +        * over-estimate how the atomic reserve but it avoids a search
> > > +        */
> > > +       if (likely(!(alloc_flags & ALLOC_HARDER)))
> > > +               free_pages -= z->nr_reserved_highatomic;
> > > +       else
> > >                 min -= min / 4;
> > >
> > >  #ifdef CONFIG_CMA
> > > @@ -2397,6 +2492,14 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> > >                 if (page) {
> > >                         if (prep_new_page(page, order, gfp_mask, alloc_flags))
> > >                                 goto try_this_zone;
> > > +
> > > +                       /*
> > > +                        * If this is a high-order atomic allocation then check
> > > +                        * if the pageblock should be reserved for the future
> > > +                        */
> > > +                       if (unlikely(order && (alloc_flags & ALLOC_HARDER)))
> > > +                               reserve_highatomic_pageblock(page, zone, order);
> > > +
> > >                         return page;
> > >                 }
> > >         }
> > > @@ -2664,9 +2767,11 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> > >
> > >         /*
> > >          * If an allocation failed after direct reclaim, it could be because
> > > -        * pages are pinned on the per-cpu lists. Drain them and try again
> > > +        * pages are pinned on the per-cpu lists or in high alloc reserves.
> > > +        * Shrink them them and try again
> > >          */
> > >         if (!page && !drained) {
> > > +               unreserve_highatomic_pageblock(ac);
> > >                 drain_all_pages(NULL);
> > >                 drained = true;
> > >                 goto retry;
> > 
> > In case of high-order request, it can easily fail even after direct reclaim.
> > It can cause ping-pong effect on highatomic pageblock.
> > Unreserve on order-0 request fail is one option to avoid that problem.
> > 
> 
> That is potentially a modification that would be interest to non-atomic
> high-atomic only users which I know you are interested in. However, it is
> both outside the scope of the series and it is a hazardous change because a
> normal high-order allocation that can reclaim can unreserve a block reserved
> for high-order atomic allocations and then the atomic allocations fail.
> That is a sufficiently strong side-effect that it should be a separate
> patch that fixed a measurable problem.
> 
> > Anyway, do you measure fragmentation effect of this patch?
> > 
> 
> Nothing interesting was revealed, the fragmentation effects looked similar
> before and after the series. The number of reserved pageblocks is too
> small to matteer.
> 
> > High-order atomic request is usually unmovable and it would be served
> > by unmovable pageblock. And then, it is changed to highatomic.
> > But, reclaim can be triggered by movable request and this unreserve
> > makes that pageblock to movable type.
> > 
> > So, following sequence of transition will usually happen.
> > 
> > unmovable -> highatomic -> movable
> > 
> > It can reduce number of unmovable pageblock and unmovable
> > allocation can be spread and cause fragmentation. I'd like to see
> > result about fragmentation. Highorder stress benchmark can be
> > one of candidates.
> > 
> 
> Too few to matter. I checked high-order stresses and they appeared fine,
> external fragmentation events were fine.
> 
> -- 
> Mel Gorman
> SUSE Labs
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
