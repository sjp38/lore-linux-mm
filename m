Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 29F748E021D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 18:04:56 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so3351131edt.23
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:04:56 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id i3si1022936edk.411.2018.12.14.15.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 15:04:54 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id E9E3398473
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 23:04:53 +0000 (UTC)
Date: Fri, 14 Dec 2018 23:04:49 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 10/14] mm, compaction: Use free lists to quickly locate a
 migration source
Message-ID: <20181214230449.GA29005@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181214230310.572-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

The migration scanner is a linear scan of a zone which is a potentially
very large search space. Furthermore, many pageblocks are unusable such
as those filled with reserved pages or partially filled with pages that
cannot migrate. These still get scanned in the common case of allocating
a THP and the cost accumulates.

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
is somewhat pointless to use the list search in these cases. Small free
pages must be used for the search and there is no guarantee that movable
pages are located within that block that are contiguous.

                                    4.20.0-rc6             4.20.0-rc6
                                  noboost-v1r4           findmig-v1r4
Amean     fault-both-3      3753.53 (   0.00%)     3545.40 (   5.54%)
Amean     fault-both-5      5396.32 (   0.00%)     5431.98 (  -0.66%)
Amean     fault-both-7      7393.46 (   0.00%)     7185.11 (   2.82%)
Amean     fault-both-12    12155.50 (   0.00%)    11424.68 (   6.01%)
Amean     fault-both-18    16445.96 (   0.00%)    14170.10 *  13.84%*
Amean     fault-both-24    20465.03 (   0.00%)    16143.57 *  21.12%*
Amean     fault-both-30    20813.54 (   0.00%)    19207.96 (   7.71%)
Amean     fault-both-32    22384.02 (   0.00%)    20051.01 *  10.42%*

Compaction migrate scanned    60836989    51005450
Compaction free scanned      890084421   780359464

This is showing a 16% reduction in migration scanning with some mild
improvements on latency. A 2-socket machine showed similar reductions
of scan rates in percentage terms.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 179 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 mm/internal.h   |   2 +
 2 files changed, 179 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 8ba9b3b479e3..65c7ab1847a0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1041,6 +1041,12 @@ static bool suitable_migration_target(struct compact_control *cc,
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
@@ -1051,6 +1057,19 @@ static inline bool compact_scanners_met(struct compact_control *cc)
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
@@ -1208,6 +1227,160 @@ typedef enum {
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
+		unsigned long nr_skipped = 0;
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
+				 * Avoid if skipped recently. Move to the tail
+				 * of the list so it will not be found again
+				 * soon
+				 */
+				if (get_pageblock_skip(freepage)) {
+
+					if (list_is_last(freelist, &freepage->lru))
+						break;
+
+					nr_skipped++;
+					list_del(&freepage->lru);
+					list_add_tail(&freepage->lru, freelist);
+					if (nr_skipped > 2)
+						break;
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
+			/*
+			 * If low PFNs are being found and discarded then
+			 * limit the scan as fast searching is finding
+			 * poor candidates.
+			 */
+			if (free_pfn < cc->migrate_pfn)
+				limit >>= 1;
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
@@ -1226,9 +1399,10 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 
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
@@ -1551,6 +1725,7 @@ static enum compact_result compact_zone(struct compact_control *cc)
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
