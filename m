Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 5D4CF6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 06:38:22 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 5 Aug 2013 15:58:44 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 73F201258053
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 16:07:43 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r75AdG4Z41549896
	for <linux-mm@kvack.org>; Mon, 5 Aug 2013 16:09:17 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r75Ac83u023069
	for <linux-mm@kvack.org>; Mon, 5 Aug 2013 16:08:08 +0530
Date: Mon, 5 Aug 2013 18:34:56 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130805103456.GB1039@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 02, 2013 at 11:37:26AM -0400, Johannes Weiner wrote:
>Each zone that holds userspace pages of one workload must be aged at a
>speed proportional to the zone size.  Otherwise, the time an
>individual page gets to stay in memory depends on the zone it happened
>to be allocated in.  Asymmetry in the zone aging creates rather
>unpredictable aging behavior and results in the wrong pages being
>reclaimed, activated etc.
>
>But exactly this happens right now because of the way the page
>allocator and kswapd interact.  The page allocator uses per-node lists
>of all zones in the system, ordered by preference, when allocating a
>new page.  When the first iteration does not yield any results, kswapd
>is woken up and the allocator retries.  Due to the way kswapd reclaims
>zones below the high watermark while a zone can be allocated from when
>it is above the low watermark, the allocator may keep kswapd running
>while kswapd reclaim ensures that the page allocator can keep
>allocating from the first zone in the zonelist for extended periods of
>time.  Meanwhile the other zones rarely see new allocations and thus
>get aged much slower in comparison.
>
>The result is that the occasional page placed in lower zones gets
>relatively more time in memory, even gets promoted to the active list
>after its peers have long been evicted.  Meanwhile, the bulk of the
>working set may be thrashing on the preferred zone even though there
>may be significant amounts of memory available in the lower zones.
>
>Even the most basic test -- repeatedly reading a file slightly bigger
>than memory -- shows how broken the zone aging is.  In this scenario,
>no single page should be able stay in memory long enough to get
>referenced twice and activated, but activation happens in spades:
>
>  $ grep active_file /proc/zoneinfo
>      nr_inactive_file 0
>      nr_active_file 0
>      nr_inactive_file 0
>      nr_active_file 8
>      nr_inactive_file 1582
>      nr_active_file 11994
>  $ cat data data data data >/dev/null
>  $ grep active_file /proc/zoneinfo
>      nr_inactive_file 0
>      nr_active_file 70
>      nr_inactive_file 258753
>      nr_active_file 443214
>      nr_inactive_file 149793
>      nr_active_file 12021
>
>Fix this with a very simple round robin allocator.  Each zone is
>allowed a batch of allocations that is proportional to the zone's
>size, after which it is treated as full.  The batch counters are reset
>when all zones have been tried and the allocator enters the slowpath
>and kicks off kswapd reclaim.  Allocation and reclaim is now fairly
>spread out to all available/allowable zones:
>
>  $ grep active_file /proc/zoneinfo
>      nr_inactive_file 0
>      nr_active_file 0
>      nr_inactive_file 174
>      nr_active_file 4865
>      nr_inactive_file 53
>      nr_active_file 860
>  $ cat data data data data >/dev/null
>  $ grep active_file /proc/zoneinfo
>      nr_inactive_file 0
>      nr_active_file 0
>      nr_inactive_file 666622
>      nr_active_file 4988
>      nr_inactive_file 190969
>      nr_active_file 937
>

Why round robin allocator don't consume ZONE_DMA?

>When zone_reclaim_mode is enabled, allocations will now spread out to
>all zones on the local node, not just the first preferred zone (which
>on a 4G node might be a tiny Normal zone).
>
>Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>Tested-by: Zlatko Calusic <zcalusic@bitsync.net>
>---
> include/linux/mmzone.h |  1 +
> mm/page_alloc.c        | 69 ++++++++++++++++++++++++++++++++++++++++++--------
> 2 files changed, 60 insertions(+), 10 deletions(-)
>
>diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>index af4a3b7..dcad2ab 100644
>--- a/include/linux/mmzone.h
>+++ b/include/linux/mmzone.h
>@@ -352,6 +352,7 @@ struct zone {
> 	 * free areas of different sizes
> 	 */
> 	spinlock_t		lock;
>+	int			alloc_batch;
> 	int                     all_unreclaimable; /* All pages pinned */
> #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> 	/* Set to true when the PG_migrate_skip bits should be cleared */
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 3b27d3e..b2cdfd0 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -1817,6 +1817,11 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
> 	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
> }
>
>+static bool zone_local(struct zone *local_zone, struct zone *zone)
>+{
>+	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
>+}
>+
> static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
> {
> 	return node_isset(local_zone->node, zone->zone_pgdat->reclaim_nodes);
>@@ -1854,6 +1859,11 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
> {
> }
>
>+static bool zone_local(struct zone *local_zone, struct zone *zone)
>+{
>+	return true;
>+}
>+
> static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
> {
> 	return true;
>@@ -1901,6 +1911,26 @@ zonelist_scan:
> 		if (alloc_flags & ALLOC_NO_WATERMARKS)
> 			goto try_this_zone;
> 		/*
>+		 * Distribute pages in proportion to the individual
>+		 * zone size to ensure fair page aging.  The zone a
>+		 * page was allocated in should have no effect on the
>+		 * time the page has in memory before being reclaimed.
>+		 *
>+		 * When zone_reclaim_mode is enabled, try to stay in
>+		 * local zones in the fastpath.  If that fails, the
>+		 * slowpath is entered, which will do another pass
>+		 * starting with the local zones, but ultimately fall
>+		 * back to remote zones that do not partake in the
>+		 * fairness round-robin cycle of this zonelist.
>+		 */
>+		if (alloc_flags & ALLOC_WMARK_LOW) {
>+			if (zone->alloc_batch <= 0)
>+				continue;
>+			if (zone_reclaim_mode &&
>+			    !zone_local(preferred_zone, zone))
>+				continue;
>+		}
>+		/*
> 		 * When allocating a page cache page for writing, we
> 		 * want to get it from a zone that is within its dirty
> 		 * limit, such that no single zone holds more than its
>@@ -2006,7 +2036,8 @@ this_zone_full:
> 		goto zonelist_scan;
> 	}
>
>-	if (page)
>+	if (page) {
>+		zone->alloc_batch -= 1U << order;
> 		/*
> 		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
> 		 * necessary to allocate the page. The expectation is
>@@ -2015,6 +2046,7 @@ this_zone_full:
> 		 * for !PFMEMALLOC purposes.
> 		 */
> 		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
>+	}
>
> 	return page;
> }
>@@ -2346,16 +2378,28 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
> 	return page;
> }
>
>-static inline
>-void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
>-						enum zone_type high_zoneidx,
>-						enum zone_type classzone_idx)
>+static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
>+			     struct zonelist *zonelist,
>+			     enum zone_type high_zoneidx,
>+			     struct zone *preferred_zone)
> {
> 	struct zoneref *z;
> 	struct zone *zone;
>
>-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
>-		wakeup_kswapd(zone, order, classzone_idx);
>+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>+		if (!(gfp_mask & __GFP_NO_KSWAPD))
>+			wakeup_kswapd(zone, order, zone_idx(preferred_zone));
>+		/*
>+		 * Only reset the batches of zones that were actually
>+		 * considered in the fast path, we don't want to
>+		 * thrash fairness information for zones that are not
>+		 * actually part of this zonelist's round-robin cycle.
>+		 */
>+		if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
>+			continue;
>+		zone->alloc_batch = high_wmark_pages(zone) -
>+			low_wmark_pages(zone);
>+	}
> }
>
> static inline int
>@@ -2451,9 +2495,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> 		goto nopage;
>
> restart:
>-	if (!(gfp_mask & __GFP_NO_KSWAPD))
>-		wake_all_kswapd(order, zonelist, high_zoneidx,
>-						zone_idx(preferred_zone));
>+	prepare_slowpath(gfp_mask, order, zonelist,
>+			 high_zoneidx, preferred_zone);
>
> 	/*
> 	 * OK, we're below the kswapd watermark and have kicked background
>@@ -4754,6 +4797,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
> 		zone_seqlock_init(zone);
> 		zone->zone_pgdat = pgdat;
>
>+		/* For bootup, initialized properly in watermark setup */
>+		zone->alloc_batch = zone->managed_pages;
>+
> 		zone_pcp_init(zone);
> 		lruvec_init(&zone->lruvec);
> 		if (!size)
>@@ -5525,6 +5571,9 @@ static void __setup_per_zone_wmarks(void)
> 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
> 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
>
>+		zone->alloc_batch = high_wmark_pages(zone) -
>+			low_wmark_pages(zone);
>+
> 		setup_zone_migrate_reserve(zone);
> 		spin_unlock_irqrestore(&zone->lock, flags);
> 	}
>-- 
>1.8.3.2
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
