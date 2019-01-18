Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07E258E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:53:21 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i55so5263617ede.14
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:53:20 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id r18-v6si2086662ejf.218.2019.01.18.09.53.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:53:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id AA68F1C35D1
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:53:18 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 09/22] mm, compaction: Use free lists to quickly locate a migration source
Date: Fri, 18 Jan 2019 17:51:23 +0000
Message-Id: <20190118175136.31341-10-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

The migration scanner is a linear scan of a zone with a potentiall large
search space.  Furthermore, many pageblocks are unusable such as those
filled with reserved pages or partially filled with pages that cannot
migrate. These still get scanned in the common case of allocating a THP
and the cost accumulates.

The patch uses a partial search of the free lists to locate a migration
source candidate that is marked as MOVABLE when allocating a THP. It
prefers picking a block with a larger number of free pages already on
the basis that there are fewer pages to migrate to free the entire block.
The lowest PFN found during searches is tracked as the basis of the start
for the linear search after the first search of the free list fails.
After the search, the free list is shuffled so that the next search will
not encounter the same page. If the search fails then the subsequent
searches will be shorter and the linear scanner is used.

If this search fails, or if the request is for a small or
unmovable/reclaimable allocation then the linear scanner is still used. It
is somewhat pointless to use the list search in those cases. Small free
pages must be used for the search and there is no guarantee that movable
pages are located within that block that are contiguous.

                                     5.0.0-rc1              5.0.0-rc1
                                 noboost-v3r10          findmig-v3r15
Amean     fault-both-3      3771.41 (   0.00%)     3390.40 (  10.10%)
Amean     fault-both-5      5409.05 (   0.00%)     5082.28 (   6.04%)
Amean     fault-both-7      7040.74 (   0.00%)     7012.51 (   0.40%)
Amean     fault-both-12    11887.35 (   0.00%)    11346.63 (   4.55%)
Amean     fault-both-18    16718.19 (   0.00%)    15324.19 (   8.34%)
Amean     fault-both-24    21157.19 (   0.00%)    16088.50 *  23.96%*
Amean     fault-both-30    21175.92 (   0.00%)    18723.42 *  11.58%*
Amean     fault-both-32    21339.03 (   0.00%)    18612.01 *  12.78%*

                                5.0.0-rc1              5.0.0-rc1
                            noboost-v3r10          findmig-v3r15
Percentage huge-3        86.50 (   0.00%)       89.83 (   3.85%)
Percentage huge-5        92.52 (   0.00%)       91.96 (  -0.61%)
Percentage huge-7        92.44 (   0.00%)       92.85 (   0.44%)
Percentage huge-12       92.98 (   0.00%)       92.74 (  -0.25%)
Percentage huge-18       91.70 (   0.00%)       91.71 (   0.02%)
Percentage huge-24       91.59 (   0.00%)       92.13 (   0.60%)
Percentage huge-30       90.14 (   0.00%)       93.79 (   4.04%)
Percentage huge-32       90.03 (   0.00%)       91.27 (   1.37%)

This shows an improvement in allocation latencies with similar allocation
success rates.  While not presented, there was a 31% reduction in migration
scanning and a 8% reduction on system CPU usage. A 2-socket machine showed
similar benefits.

[vbabka@suse.cz: Migrate block that was found-fast, some optimisations]
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 176 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 mm/internal.h   |   2 +
 2 files changed, 175 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 3d11c209614a..92d10eb3d1c7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1040,6 +1040,12 @@ static bool suitable_migration_target(struct compact_control *cc,
 	return false;
 }
 
+static inline unsigned int
+freelist_scan_limit(struct compact_control *cc)
+{
+	return (COMPACT_CLUSTER_MAX >> cc->fast_search_fail) + 1;
+}
+
 /*
  * Test whether the free scanner has reached the same or lower pageblock than
  * the migration scanner, and compaction should thus terminate.
@@ -1050,6 +1056,19 @@ static inline bool compact_scanners_met(struct compact_control *cc)
 		<= (cc->migrate_pfn >> pageblock_order);
 }
 
+/* Reorder the free list to reduce repeated future searches */
+static void
+move_freelist_tail(struct list_head *freelist, struct page *freepage)
+{
+	LIST_HEAD(sublist);
+
+	if (!list_is_last(freelist, &freepage->lru)) {
+		list_cut_position(&sublist, freelist, &freepage->lru);
+		if (!list_empty(&sublist))
+			list_splice_tail(&sublist, freelist);
+	}
+}
+
 /*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
@@ -1207,6 +1226,146 @@ typedef enum {
  */
 int sysctl_compact_unevictable_allowed __read_mostly = 1;
 
+static inline void
+update_fast_start_pfn(struct compact_control *cc, unsigned long pfn)
+{
+	if (cc->fast_start_pfn == ULONG_MAX)
+		return;
+
+	if (!cc->fast_start_pfn)
+		cc->fast_start_pfn = pfn;
+
+	cc->fast_start_pfn = min(cc->fast_start_pfn, pfn);
+}
+
+static inline void
+reinit_migrate_pfn(struct compact_control *cc)
+{
+	if (!cc->fast_start_pfn || cc->fast_start_pfn == ULONG_MAX)
+		return;
+
+	cc->migrate_pfn = cc->fast_start_pfn;
+	cc->fast_start_pfn = ULONG_MAX;
+}
+
+/*
+ * Briefly search the free lists for a migration source that already has
+ * some free pages to reduce the number of pages that need migration
+ * before a pageblock is free.
+ */
+static unsigned long fast_find_migrateblock(struct compact_control *cc)
+{
+	unsigned int limit = freelist_scan_limit(cc);
+	unsigned int nr_scanned = 0;
+	unsigned long distance;
+	unsigned long pfn = cc->migrate_pfn;
+	unsigned long high_pfn;
+	int order;
+
+	/* Skip hints are relied on to avoid repeats on the fast search */
+	if (cc->ignore_skip_hint)
+		return pfn;
+
+	/*
+	 * If the migrate_pfn is not at the start of a zone or the start
+	 * of a pageblock then assume this is a continuation of a previous
+	 * scan restarted due to COMPACT_CLUSTER_MAX.
+	 */
+	if (pfn != cc->zone->zone_start_pfn && pfn != pageblock_start_pfn(pfn))
+		return pfn;
+
+	/*
+	 * For smaller orders, just linearly scan as the number of pages
+	 * to migrate should be relatively small and does not necessarily
+	 * justify freeing up a large block for a small allocation.
+	 */
+	if (cc->order <= PAGE_ALLOC_COSTLY_ORDER)
+		return pfn;
+
+	/*
+	 * Only allow kcompactd and direct requests for movable pages to
+	 * quickly clear out a MOVABLE pageblock for allocation. This
+	 * reduces the risk that a large movable pageblock is freed for
+	 * an unmovable/reclaimable small allocation.
+	 */
+	if (cc->direct_compaction && cc->migratetype != MIGRATE_MOVABLE)
+		return pfn;
+
+	/*
+	 * When starting the migration scanner, pick any pageblock within the
+	 * first half of the search space. Otherwise try and pick a pageblock
+	 * within the first eighth to reduce the chances that a migration
+	 * target later becomes a source.
+	 */
+	distance = (cc->free_pfn - cc->migrate_pfn) >> 1;
+	if (cc->migrate_pfn != cc->zone->zone_start_pfn)
+		distance >>= 2;
+	high_pfn = pageblock_start_pfn(cc->migrate_pfn + distance);
+
+	for (order = cc->order - 1;
+	     order >= PAGE_ALLOC_COSTLY_ORDER && pfn == cc->migrate_pfn && nr_scanned < limit;
+	     order--) {
+		struct free_area *area = &cc->zone->free_area[order];
+		struct list_head *freelist;
+		unsigned long flags;
+		struct page *freepage;
+
+		if (!area->nr_free)
+			continue;
+
+		spin_lock_irqsave(&cc->zone->lock, flags);
+		freelist = &area->free_list[MIGRATE_MOVABLE];
+		list_for_each_entry(freepage, freelist, lru) {
+			unsigned long free_pfn;
+
+			nr_scanned++;
+			free_pfn = page_to_pfn(freepage);
+			if (free_pfn < high_pfn) {
+				update_fast_start_pfn(cc, free_pfn);
+
+				/*
+				 * Avoid if skipped recently. Ideally it would
+				 * move to the tail but even safe iteration of
+				 * the list assumes an entry is deleted, not
+				 * reordered.
+				 */
+				if (get_pageblock_skip(freepage)) {
+					if (list_is_last(freelist, &freepage->lru))
+						break;
+
+					continue;
+				}
+
+				/* Reorder to so a future search skips recent pages */
+				move_freelist_tail(freelist, freepage);
+
+				pfn = pageblock_start_pfn(free_pfn);
+				cc->fast_search_fail = 0;
+				set_pageblock_skip(freepage);
+				break;
+			}
+
+			if (nr_scanned >= limit) {
+				cc->fast_search_fail++;
+				move_freelist_tail(freelist, freepage);
+				break;
+			}
+		}
+		spin_unlock_irqrestore(&cc->zone->lock, flags);
+	}
+
+	cc->total_migrate_scanned += nr_scanned;
+
+	/*
+	 * If fast scanning failed then use a cached entry for a page block
+	 * that had free pages as the basis for starting a linear scan.
+	 */
+	if (pfn == cc->migrate_pfn)
+		reinit_migrate_pfn(cc);
+
+	return pfn;
+}
+
 /*
  * Isolate all pages that can be migrated from the first suitable block,
  * starting at the block pointed to by the migrate scanner pfn within
@@ -1222,16 +1381,25 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	const isolate_mode_t isolate_mode =
 		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
 		(cc->mode != MIGRATE_SYNC ? ISOLATE_ASYNC_MIGRATE : 0);
+	bool fast_find_block;
 
 	/*
 	 * Start at where we last stopped, or beginning of the zone as
-	 * initialized by compact_zone()
+	 * initialized by compact_zone(). The first failure will use
+	 * the lowest PFN as the starting point for linear scanning.
 	 */
-	low_pfn = cc->migrate_pfn;
+	low_pfn = fast_find_migrateblock(cc);
 	block_start_pfn = pageblock_start_pfn(low_pfn);
 	if (block_start_pfn < zone->zone_start_pfn)
 		block_start_pfn = zone->zone_start_pfn;
 
+	/*
+	 * fast_find_migrateblock marks a pageblock skipped so to avoid
+	 * the isolation_suitable check below, check whether the fast
+	 * search was successful.
+	 */
+	fast_find_block = low_pfn != cc->migrate_pfn && !cc->fast_search_fail;
+
 	/* Only scan within a pageblock boundary */
 	block_end_pfn = pageblock_end_pfn(low_pfn);
 
@@ -1240,6 +1408,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	 * Do not cross the free scanner.
 	 */
 	for (; block_end_pfn <= cc->free_pfn;
+			fast_find_block = false,
 			low_pfn = block_end_pfn,
 			block_start_pfn = block_end_pfn,
 			block_end_pfn += pageblock_nr_pages) {
@@ -1259,7 +1428,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 
 		/* If isolation recently failed, do not retry */
-		if (!isolation_suitable(cc, page))
+		if (!isolation_suitable(cc, page) && !fast_find_block)
 			continue;
 
 		/*
@@ -1550,6 +1719,7 @@ static enum compact_result compact_zone(struct compact_control *cc)
 	 * want to compact the whole zone), but check that it is initialised
 	 * by ensuring the values are within zone boundaries.
 	 */
+	cc->fast_start_pfn = 0;
 	if (cc->whole_zone) {
 		cc->migrate_pfn = start_pfn;
 		cc->free_pfn = pageblock_start_pfn(end_pfn - 1);
diff --git a/mm/internal.h b/mm/internal.h
index 9b32f4cab0ae..983cb975545f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -188,9 +188,11 @@ struct compact_control {
 	unsigned int nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	unsigned long fast_start_pfn;	/* a pfn to start linear scan from */
 	struct zone *zone;
 	unsigned long total_migrate_scanned;
 	unsigned long total_free_scanned;
+	unsigned int fast_search_fail;	/* failures to use free list searches */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* migratetype of direct compactor */
-- 
2.16.4
