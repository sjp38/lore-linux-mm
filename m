Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9F56B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:06:42 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k57so3377609wrk.6
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:06:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n68si4042723wmd.35.2017.04.27.08.06.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 08:06:40 -0700 (PDT)
Date: Thu, 27 Apr 2017 17:06:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170427150636.GM4706@dhcp22.suse.cz>
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170411181519.GC21171@dhcp22.suse.cz>
 <20170412013503.GA8448@js1304-desktop>
 <20170413115615.GB11795@dhcp22.suse.cz>
 <20170417020210.GA1351@js1304-desktop>
 <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170425034255.GB32583@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Tue 25-04-17 12:42:57, Joonsoo Kim wrote:
> On Mon, Apr 24, 2017 at 03:09:36PM +0200, Michal Hocko wrote:
> > On Mon 17-04-17 11:02:12, Joonsoo Kim wrote:
> > > On Thu, Apr 13, 2017 at 01:56:15PM +0200, Michal Hocko wrote:
> > > > On Wed 12-04-17 10:35:06, Joonsoo Kim wrote:
[...]
> > not for free. For most common configurations where we have ZONE_DMA,
> > ZONE_DMA32, ZONE_NORMAL and ZONE_MOVABLE all the 3 bits are already
> > consumed so a new zone will need a new one AFAICS.
> 
> Yes, it requires one more bit for a new zone and it's handled by the patch.

I am pretty sure that you are aware that consuming new page flag bits
is usually a no-go and something we try to avoid as much as possible
because we are in a great shortage there. So there really have to be a
_strong_ reason if we go that way. My current understanding that the
whole zone concept is more about a more convenient implementation rather
than a fundamental change which will solve unsolvable problems with the
current approach. More on that below.

[...]
> MOVABLE allocation will fallback as following sequence.
> 
> ZONE_CMA -> ZONE_MOVABLE -> ZONE_HIGHMEM -> ZONE_NORMAL -> ...
> 
> I don't understand what you mean CMA allocation. In MM's context,
> there is no CMA allocation. That is just MOVABLE allocation.
> 
> For device's context, there is CMA allocation. It is range specific
> allocation so it should be succeed for requested range. No fallback is
> allowed in this case.

OK. that answers my question. I guess... My main confusion comes from
__alloc_gigantic_page which shares alloc_contig_range with the cma
allocation. But from what you wrote above and my quick glance over the
code __alloc_gigantic_page simply changes the migrate type of the pfn
range and it doesn't move it to the zone CMA. Right?

[...]
> > > At a glance, special migratetype sound natural. I also did. However,
> > > it's not natural in implementation POV. Zone consists of the same type
> > > of memory (by definition ?) and MM subsystem is implemented with that
> > > assumption. If difference type of memory shares the same zone, it easily
> > > causes the problem and CMA problems are the such case.
> > 
> > But this is not any different from the highmem vs. lowmem problems we
> > already have, no? I have looked at your example in the cover where you
> > mention utilization and the reclaim problems. With the node reclaim we
> > will have pages from all zones on the same LRU(s). isolate_lru_pages
> > will skip those from ZONE_CMA because their zone_idx is higher than
> > gfp_idx(GFP_KERNEL). The same could be achieved by an explicit check for
> > the pageblock migrate type. So the zone doesn't really help much. Or is
> > there some aspect that I am missing?
> 
> Your understanding is correct. It can archieved by an explict check
> for migratetype. And, this is the main reason that we should avoid
> such approach.
> 
> With ZONE approach, all these things are done naturally. We don't need
> any explicit check to anywhere. We already have a code to skip to
> reclaim such pages by checking zone_idx.

Yes, and as we have to filter pages anyway doing so for cma blocks
doesn't sound overly burdensome from the maintenance point of view.
 
> However, with MIGRATETYPE approach, all these things *cannot* be done
> naturally. We need extra checks to all the places (allocator fast
> path, reclaim path, compaction, etc...). It is really error-prone and
> it already causes many problems due to this aspect. For the
> performance wise, this approach is also bad since it requires to check
> migratetype for each pages.
> 
> Moreover, even if we adds extra checks, things cannot be easily
> perfect.

I see this point and I agree that using a specific zone might be a
_nicer_ solution in the end but you have to consider another aspects as
well. The main one I am worried about is a long term maintainability.
We are really out of page flags and consuming one for a rather specific
usecase is not good. Look at ZONE_DMA. I am pretty sure that almost
no sane HW needs 16MB zone anymore, yet we have hard time to get rid
of it and so we have that memory laying around unused all the time
and blocking one page flag bit. CMA falls into a similar category
AFAIU. I wouldn't be all that surprised if a future HW will not need CMA
allocations in few years, yet we will have to fight to get rid of it
like we do with ZONE_DMA. And not only that. We will also have to fight
finding page flags for other more general usecases in the meantime.

> See 3) Atomic allocation failure problem. It's inherent
> problem if we have different types of memory in a single zone.
> We possibly can make things perfect even with MIGRATETYPE approach,
> however, it requires additional checks in hotpath than current. It's
> expensive and undesirable. It will make future maintenance of MM code
> much difficult.

I believe that the overhead in the hot path is not such a big deal. We
have means to make it 0 when CMA is not used by jumplabels. I assume
that the vast majority of systems will not use CMA. Those systems which
use CMA should be able to cope with some slight overhead IMHO.

I agree that the code maintenance cost is not free. And that is a valid
concern. CMA maintenance will not be for free in either case, though (if
for nothing else the page flags space mentioned above). Let's see what
what this means for mm/page_alloc.c

 mm/page_alloc.c | 220 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 109 insertions(+), 111 deletions(-)

Not very convincing at first glance but this can be quite misleading as
you have already mentioned because you have moved a lot of code to to
init path. So let's just focus on the allocator hot paths

@@ -800,7 +805,7 @@ static inline void __free_one_page(struct page *page,
 
 	VM_BUG_ON(migratetype == -1);
 	if (likely(!is_migrate_isolate(migratetype)))
-		__mod_zone_freepage_state(zone, 1 << order, migratetype);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
 
 	VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
@@ -1804,25 +1831,11 @@ static int fallbacks[MIGRATE_TYPES][4] = {
 	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_TYPES },
 	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_TYPES },
 	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_TYPES },
-#ifdef CONFIG_CMA
-	[MIGRATE_CMA]         = { MIGRATE_TYPES }, /* Never used */
-#endif
 #ifdef CONFIG_MEMORY_ISOLATION
 	[MIGRATE_ISOLATE]     = { MIGRATE_TYPES }, /* Never used */
 #endif
 };
 
-#ifdef CONFIG_CMA
-static struct page *__rmqueue_cma_fallback(struct zone *zone,
-					unsigned int order)
-{
-	return __rmqueue_smallest(zone, order, MIGRATE_CMA);
-}
-#else
-static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
-					unsigned int order) { return NULL; }
-#endif
-
 /*
  * Move the free pages in a range to the free lists of the requested type.
  * Note that start_page and end_pages are not aligned on a pageblock
@@ -2090,8 +2103,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 
 	/* Yoink! */
 	mt = get_pageblock_migratetype(page);
-	if (!is_migrate_highatomic(mt) && !is_migrate_isolate(mt)
-	    && !is_migrate_cma(mt)) {
+	if (!is_migrate_highatomic(mt) && !is_migrate_isolate(mt)) {
 		zone->nr_reserved_highatomic += pageblock_nr_pages;
 		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
 		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC, NULL);
@@ -2235,13 +2247,8 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 
 retry:
 	page = __rmqueue_smallest(zone, order, migratetype);
-	if (unlikely(!page)) {
-		if (migratetype == MIGRATE_MOVABLE)
-			page = __rmqueue_cma_fallback(zone, order);
-
-		if (!page && __rmqueue_fallback(zone, order, migratetype))
-			goto retry;
-	}
+	if (unlikely(!page) && __rmqueue_fallback(zone, order, migratetype))
+		goto retry;
 
 	trace_mm_page_alloc_zone_locked(page, order, migratetype);
 	return page;
@@ -2283,9 +2290,6 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			list_add_tail(&page->lru, list);
 		list = &page->lru;
 		alloced++;
-		if (is_migrate_cma(get_pcppage_migratetype(page)))
-			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
-					      -(1 << order));
 	}
 
 	/*
@@ -2636,10 +2640,10 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		 * exists.
 		 */
 		watermark = min_wmark_pages(zone) + (1UL << order);
-		if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
+		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 			return 0;
 
-		__mod_zone_freepage_state(zone, -(1UL << order), mt);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
 	}
 
 	/* Remove page from free list */
@@ -2655,8 +2659,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages) {
 			int mt = get_pageblock_migratetype(page);
-			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)
-			    && !is_migrate_highatomic(mt))
+			if (!is_migrate_isolate(mt) &&
+				!is_migrate_highatomic(mt))
 				set_pageblock_migratetype(page,
 							  MIGRATE_MOVABLE);
 		}
@@ -2783,8 +2787,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 	spin_unlock(&zone->lock);
 	if (!page)
 		goto failed;
-	__mod_zone_freepage_state(zone, -(1 << order),
-				  get_pcppage_migratetype(page));
+	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
 
 	__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 	zone_statistics(preferred_zone, zone);
@@ -2907,12 +2910,6 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 	else
 		min -= min / 4;
 
-#ifdef CONFIG_CMA
-	/* If allocation can't use CMA areas don't use free CMA pages */
-	if (!(alloc_flags & ALLOC_CMA))
-		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
-#endif
-
 	/*
 	 * Check watermarks for an order-0 allocation request. If these
 	 * are not met, then a high-order request also cannot go ahead
@@ -2940,13 +2937,6 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 			if (!list_empty(&area->free_list[mt]))
 				return true;
 		}
-
-#ifdef CONFIG_CMA
-		if ((alloc_flags & ALLOC_CMA) &&
-		    !list_empty(&area->free_list[MIGRATE_CMA])) {
-			return true;
-		}
-#endif
 	}
 	return false;
 }
@@ -2962,13 +2952,6 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
 		unsigned long mark, int classzone_idx, unsigned int alloc_flags)
 {
 	long free_pages = zone_page_state(z, NR_FREE_PAGES);
-	long cma_pages = 0;
-
-#ifdef CONFIG_CMA
-	/* If allocation can't use CMA areas don't use free CMA pages */
-	if (!(alloc_flags & ALLOC_CMA))
-		cma_pages = zone_page_state(z, NR_FREE_CMA_PAGES);
-#endif
 
 	/*
 	 * Fast check for order-0 only. If this fails then the reserves
@@ -2977,7 +2960,7 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
 	 * the caller is !atomic then it'll uselessly search the free
 	 * list. That corner case is then slower but it is harmless.
 	 */
-	if (!order && (free_pages - cma_pages) > mark + z->lowmem_reserve[classzone_idx])
+	if (!order && free_pages > mark + z->lowmem_reserve[classzone_idx])
 		return true;
 
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
@@ -3547,10 +3530,6 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	} else if (unlikely(rt_task(current)) && !in_interrupt())
 		alloc_flags |= ALLOC_HARDER;
 
-#ifdef CONFIG_CMA
-	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-#endif
 	return alloc_flags;
 }
 
@@ -3972,9 +3951,6 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 	if (should_fail_alloc_page(gfp_mask, order))
 		return false;
 
-	if (IS_ENABLED(CONFIG_CMA) && ac->migratetype == MIGRATE_MOVABLE)
-		*alloc_flags |= ALLOC_CMA;
-
 	return true;
 }
 
This looks like a nice clean up. Those ifdefs are ugly as hell. One
could argue that some of that could be cleaned up by simply adding some
helpers (with a jump label to reduce the overhead), though. But is this
really strong enough reason to bring the whole zone in? I am not really
convinced to be honest.
 
[...]

> > Please do _not_ take this as a NAK from me. At least not at this time. I
> > am still trying to understand all the consequences but my intuition
> > tells me that building on top of highmem like approach will turn out to
> > be problematic in future (as we have already seen with the highmem and
> > movable zones) so this needs a very prudent consideration.
> 
> I can understand that you are prudent to this issue. However, it takes more
> than two years and many people already expressed that ZONE approach is the
> way to go.

I can see a single Acked-by and one Reviewed-by. It would be much more
convincing to see much larger support. Do not take me wrong I am not
trying to undermine the feedback so far but we should be clear about one
thing. CMA is mostly motivated by the industry which tries to overcome
HW limitations which can change in future very easily. I would rather
see good enough solution for something like that than a nicer solution
which is pushing additional burden on more general usecases.

That being said, I would like to see a much larger consensus in the MM
community before a new zone is merged. I am staying very skeptical this
is the right direction though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
