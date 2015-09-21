Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id EBDE86B025D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:53:05 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so109992222wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:53:05 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id k14si30234883wjr.21.2015.09.21.03.52.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 03:52:45 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 8211F99043
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:52:45 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 09/10] mm, page_alloc: Reserve pageblocks for high-order atomic allocations on demand
Date: Mon, 21 Sep 2015 11:52:41 +0100
Message-Id: <1442832762-7247-10-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

High-order watermark checking exists for two reasons --  kswapd high-order
awareness and protection for high-order atomic requests. Historically the
kernel depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order
free pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
that reserves pageblocks for high-order atomic allocations on demand and
avoids using those blocks for order-0 allocations. This is more flexible
and reliable than MIGRATE_RESERVE was.

A MIGRATE_HIGHORDER pageblock is created when an atomic high-order allocation
request steals a pageblock but limits the total number to 1% of the zone.
Callers that speculatively abuse atomic allocations for long-lived
high-order allocations to access the reserve will quickly fail. Note that
SLUB is currently not such an abuser as it reclaims at least once.  It is
possible that the pageblock stolen has few suitable high-order pages and
will need to steal again in the near future but there would need to be
strong justification to search all pageblocks for an ideal candidate.

The pageblocks are unreserved if an allocation fails after a direct
reclaim attempt.

The watermark checks account for the reserved pageblocks when the allocation
request is not a high-order atomic allocation.

The reserved pageblocks can not be used for order-0 allocations. This may
allow temporary wastage until a failed reclaim reassigns the pageblock. This
is deliberate as the intent of the reservation is to satisfy a limited
number of atomic high-order short-lived requests if the system requires them.

The stutter benchmark was used to evaluate this but while it was running
there was a systemtap script that randomly allocated between 1 high-order
page and 12.5% of memory's worth of order-3 pages using GFP_ATOMIC. This
is much larger than the potential reserve and it does not attempt to be
realistic.  It is intended to stress random high-order allocations from
an unknown source, show that there is a reduction in failures without
introducing an anomaly where atomic allocations are more reliable than
regular allocations.  The amount of memory reserved varied throughout the
workload as reserves were created and reclaimed under memory pressure. The
allocation failures once the workload warmed up were as follows;

4.2-rc5-vanilla		70%
4.2-rc5-atomic-reserve	56%

The failure rate was also measured while building multiple kernels. The
failure rate was 14% but is 6% with this patch applied.

Overall, this is a small reduction but the reserves are small relative
to the number of allocation requests. In early versions of the patch,
the failure rate reduced by a much larger amount but that required much
larger reserves and perversely made atomic allocations seem more reliable
than regular allocations.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h |   6 ++-
 mm/page_alloc.c        | 125 +++++++++++++++++++++++++++++++++++++++++++++----
 mm/vmstat.c            |   1 +
 3 files changed, 122 insertions(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 40a856d28764..ad8cf52de55b 100644
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
@@ -334,6 +334,8 @@ struct zone {
 	/* zone watermarks, access with *_wmark_pages(zone) macros */
 	unsigned long watermark[NR_WMARK];
 
+	unsigned long nr_reserved_highatomic;
+
 	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
 	 * or/and it will be released eventually, so to avoid totally wasting several
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ae01a2c1e863..811d6fc4ad5d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1615,6 +1615,88 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 	return -1;
 }
 
+/*
+ * Reserve a pageblock for exclusive use of high-order atomic allocations if
+ * there are no empty page blocks that contain a page with a suitable order
+ */
+static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
+				unsigned int alloc_order)
+{
+	int mt;
+	unsigned long max_managed, flags;
+
+	/*
+	 * Limit the number reserved to 1 pageblock or roughly 1% of a zone.
+	 * Check is race-prone but harmless.
+	 */
+	max_managed = (zone->managed_pages / 100) + pageblock_nr_pages;
+	if (zone->nr_reserved_highatomic >= max_managed)
+		return;
+
+	/* Yoink! */
+	spin_lock_irqsave(&zone->lock, flags);
+
+	mt = get_pageblock_migratetype(page);
+	if (mt != MIGRATE_HIGHATOMIC &&
+			!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {
+		zone->nr_reserved_highatomic += pageblock_nr_pages;
+		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
+		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
+	}
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
+
+			/*
+			 * Convert to ac->migratetype and avoid the normal
+			 * pageblock stealing heuristics. Minimally, the caller
+			 * is doing the work and needs the pages. More
+			 * importantly, if the block was always converted to
+			 * MIGRATE_UNMOVABLE or another type then the number
+			 * of pageblocks that cannot be completely freed
+			 * may increase.
+			 */
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
@@ -1670,7 +1752,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
  * Call me with the zone->lock already held.
  */
 static struct page *__rmqueue(struct zone *zone, unsigned int order,
-						int migratetype)
+				int migratetype, gfp_t gfp_flags)
 {
 	struct page *page;
 
@@ -1700,7 +1782,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
-		struct page *page = __rmqueue(zone, order, migratetype);
+		struct page *page = __rmqueue(zone, order, migratetype, 0);
 		if (unlikely(page == NULL))
 			break;
 
@@ -2072,7 +2154,7 @@ int split_free_page(struct page *page)
 static inline
 struct page *buffered_rmqueue(struct zone *preferred_zone,
 			struct zone *zone, unsigned int order,
-			gfp_t gfp_flags, int migratetype)
+			gfp_t gfp_flags, int alloc_flags, int migratetype)
 {
 	unsigned long flags;
 	struct page *page;
@@ -2115,7 +2197,15 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 			WARN_ON_ONCE(order > 1);
 		}
 		spin_lock_irqsave(&zone->lock, flags);
-		page = __rmqueue(zone, order, migratetype);
+
+		page = NULL;
+		if (unlikely(order) && (alloc_flags & ALLOC_HARDER)) {
+			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
+			if (page)
+				trace_mm_page_alloc_zone_locked(page, order, migratetype);
+		}
+
+		page = __rmqueue(zone, order, migratetype, gfp_flags);
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
@@ -2225,15 +2315,24 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
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
+	 * If the caller does not have rights to ALLOC_HARDER then subtract
+	 * the high-atomic reserves. This will over-estimate the size of the
+	 * atomic reserve but it avoids a search.
+	 */
+	if (likely(!(alloc_flags & ALLOC_HARDER)))
+		free_pages -= z->nr_reserved_highatomic;
+	else
 		min -= min / 4;
 
 #ifdef CONFIG_CMA
@@ -2418,10 +2517,18 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 
 try_this_zone:
 		page = buffered_rmqueue(ac->preferred_zone, zone, order,
-						gfp_mask, ac->migratetype);
+				gfp_mask, alloc_flags, ac->migratetype);
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
@@ -2694,9 +2801,11 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 
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
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
