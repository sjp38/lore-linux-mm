Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 66D2D9003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:00:43 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so80961607wib.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 01:00:43 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id eo8si12020855wib.7.2015.07.20.01.00.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 01:00:25 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 079CA98B57
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:00:25 +0000 (UTC)
From: Mel Gorman <mgorman@suse.com>
Subject: [PATCH 09/10] mm, page_alloc: Reserve pageblocks for high-order atomic allocations on demand
Date: Mon, 20 Jul 2015 09:00:18 +0100
Message-Id: <1437379219-9160-10-git-send-email-mgorman@suse.com>
In-Reply-To: <1437379219-9160-1-git-send-email-mgorman@suse.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Mel Gorman <mgorman@suse.de>

High-order watermark checking exists for two reasons --  kswapd high-order
awareness and protection for high-order atomic requests. Historically we
depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order free
pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
that reserves pageblocks for high-order atomic allocations. This is expected
to be more reliable than MIGRATE_RESERVE was.

A MIGRATE_HIGHORDER pageblock is created when an allocation request steals
a pageblock but limits the total number to 10% of the zone.

The pageblocks are unreserved if an allocation fails after a direct
reclaim attempt.

The watermark checks account for the reserved pageblocks when the allocation
request is not a high-order atomic allocation.

The stutter benchmark was used to evaluate this but while it was running
there was a systemtap script that randomly allocated between 1 and 1G worth
of order-3 pages using GFP_ATOMIC. In kernel 4.2-rc1 running this workload
on a single-node machine there were 339574 allocation failures. With this
patch applied there were 28798 failures -- a 92% reduction. On a 4-node
machine, allocation failures went from 76917 to 0 failures.

There are minor theoritical side-effects. If the system is intensively
making large numbers of long-lived high-order atomic allocations then
there will be a lot of reserved pageblocks. This may push some workloads
into reclaim until the number of reserved pageblocks is reduced again. This
problem was not observed in reclaim intensive workloads but such workloads
are also not atomic high-order intensive.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |   6 ++-
 mm/page_alloc.c        | 114 ++++++++++++++++++++++++++++++++++++++++++++++---
 mm/vmstat.c            |   1 +
 3 files changed, 112 insertions(+), 9 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0faa196eb10a..73a148ee79e3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -39,6 +39,8 @@ enum {
 	MIGRATE_UNMOVABLE,
 	MIGRATE_MOVABLE,
 	MIGRATE_RECLAIMABLE,
+	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
+	MIGRATE_HIGHATOMIC = MIGRATE_PCPTYPES,
 #ifdef CONFIG_CMA
 	/*
 	 * MIGRATE_CMA migration type is designed to mimic the way
@@ -61,8 +63,6 @@ enum {
 	MIGRATE_TYPES
 };
 
-#define MIGRATE_PCPTYPES (MIGRATE_RECLAIMABLE+1)
-
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
 #else
@@ -335,6 +335,8 @@ struct zone {
 	/* zone watermarks, access with *_wmark_pages(zone) macros */
 	unsigned long watermark[NR_WMARK];
 
+	unsigned long nr_reserved_highatomic;
+
 	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
 	 * or/and it will be released eventually, so to avoid totally wasting several
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3249b0d9879e..e5755390a5e5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1568,6 +1568,76 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 	return -1;
 }
 
+/*
+ * Reserve a pageblock for exclusive use of high-order atomic allocations if
+ * there are no empty page blocks that contain a page with a suitable order
+ */
+static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
+				unsigned int alloc_order)
+{
+	int mt = get_pageblock_migratetype(page);
+	unsigned long max_managed, flags;
+
+	if (mt == MIGRATE_HIGHATOMIC)
+		return;
+
+	/*
+	 * Limit the number reserved to 1 pageblock or roughly 10% of a zone.
+	 * Check is race-prone but harmless.
+	 */
+	max_managed = (zone->managed_pages / 10) + pageblock_nr_pages;
+	if (zone->nr_reserved_highatomic >= max_managed)
+		return;
+
+	/* Yoink! */
+	spin_lock_irqsave(&zone->lock, flags);
+	zone->nr_reserved_highatomic += pageblock_nr_pages;
+	set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
+	move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
+
+/*
+ * Used when an allocation is about to fail under memory pressure. This
+ * potentially hurts the reliability of high-order allocations when under
+ * intense memory pressure but failed atomic allocations should be easier
+ * to recover from than an OOM.
+ */
+static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
+{
+	struct zonelist *zonelist = ac->zonelist;
+	unsigned long flags;
+	struct zoneref *z;
+	struct zone *zone;
+	struct page *page;
+	int order;
+
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
+								ac->nodemask) {
+		/* Preserve at least one pageblock */
+		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
+			continue;
+
+		spin_lock_irqsave(&zone->lock, flags);
+		for (order = 0; order < MAX_ORDER; order++) {
+			struct free_area *area = &(zone->free_area[order]);
+
+			if (list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
+				continue;
+
+			page = list_entry(area->free_list[MIGRATE_HIGHATOMIC].next,
+						struct page, lru);
+
+			zone->nr_reserved_highatomic -= pageblock_nr_pages;
+			set_pageblock_migratetype(page, ac->migratetype);
+			move_freepages_block(zone, page, ac->migratetype);
+			spin_unlock_irqrestore(&zone->lock, flags);
+			return;
+		}
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+}
+
 /* Remove an element from the buddy allocator from the fallback list */
 static inline struct page *
 __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
@@ -1619,15 +1689,26 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 	return NULL;
 }
 
+static inline bool gfp_mask_atomic(gfp_t gfp_mask)
+{
+	return !(gfp_mask & (__GFP_WAIT | __GFP_NO_KSWAPD));
+}
+
 /*
  * Do the hard work of removing an element from the buddy allocator.
  * Call me with the zone->lock already held.
  */
 static struct page *__rmqueue(struct zone *zone, unsigned int order,
-						int migratetype)
+				int migratetype, gfp_t gfp_flags)
 {
 	struct page *page;
 
+	if (unlikely(order && gfp_mask_atomic(gfp_flags))) {
+		page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
+		if (page)
+			goto out;
+	}
+
 	page = __rmqueue_smallest(zone, order, migratetype);
 	if (unlikely(!page)) {
 		if (migratetype == MIGRATE_MOVABLE)
@@ -1637,6 +1718,7 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 			page = __rmqueue_fallback(zone, order, migratetype);
 	}
 
+out:
 	trace_mm_page_alloc_zone_locked(page, order, migratetype);
 	return page;
 }
@@ -1654,7 +1736,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
-		struct page *page = __rmqueue(zone, order, migratetype);
+		struct page *page = __rmqueue(zone, order, migratetype, 0);
 		if (unlikely(page == NULL))
 			break;
 
@@ -2065,7 +2147,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 			WARN_ON_ONCE(order > 1);
 		}
 		spin_lock_irqsave(&zone->lock, flags);
-		page = __rmqueue(zone, order, migratetype);
+		page = __rmqueue(zone, order, migratetype, gfp_flags);
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
@@ -2175,15 +2257,23 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 			unsigned long mark, int classzone_idx, int alloc_flags,
 			long free_pages)
 {
-	/* free_pages may go negative - that's OK */
 	long min = mark;
 	int o;
 	long free_cma = 0;
 
+	/* free_pages may go negative - that's OK */
 	free_pages -= (1 << order) - 1;
+
 	if (alloc_flags & ALLOC_HIGH)
 		min -= min / 2;
-	if (alloc_flags & ALLOC_HARDER)
+
+	/*
+	 * If the caller is not atomic then discount the reserves. This will
+	 * over-estimate how the atomic reserve but it avoids a search
+	 */
+	if (likely(!(alloc_flags & ALLOC_HARDER)))
+		free_pages -= z->nr_reserved_highatomic;
+	else
 		min -= min / 4;
 
 #ifdef CONFIG_CMA
@@ -2372,6 +2462,14 @@ try_this_zone:
 		if (page) {
 			if (prep_new_page(page, order, gfp_mask, alloc_flags))
 				goto try_this_zone;
+
+			/*
+			 * If this is a high-order atomic allocation then check
+			 * if the pageblock should be reserved for the future
+			 */
+			if (unlikely(order && (alloc_flags & ALLOC_HARDER)))
+				reserve_highatomic_pageblock(page, zone, order);
+
 			return page;
 		}
 	}
@@ -2639,9 +2737,11 @@ retry:
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
-	 * pages are pinned on the per-cpu lists. Drain them and try again
+	 * pages are pinned on the per-cpu lists or in high alloc reserves.
+	 * Shrink them them and try again
 	 */
 	if (!page && !drained) {
+		unreserve_highatomic_pageblock(ac);
 		drain_all_pages(NULL);
 		drained = true;
 		goto retry;
@@ -2686,7 +2786,7 @@ static inline int
 gfp_to_alloc_flags(gfp_t gfp_mask)
 {
 	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
-	const bool atomic = !(gfp_mask & (__GFP_WAIT | __GFP_NO_KSWAPD));
+	const bool atomic = gfp_mask_atomic(gfp_mask);
 
 	/* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch. */
 	BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t) ALLOC_HIGH);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 49963aa2dff3..3427a155f85e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -901,6 +901,7 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
 	"Unmovable",
 	"Reclaimable",
 	"Movable",
+	"HighAtomic",
 #ifdef CONFIG_CMA
 	"CMA",
 #endif
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
