Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C61666B0394
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 08:16:24 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d66so1259327wmi.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:16:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m14si16239035wmc.22.2017.03.07.05.16.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 05:16:23 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 4/8] mm, page_alloc: count movable pages when stealing from pageblock
Date: Tue,  7 Mar 2017 14:15:41 +0100
Message-Id: <20170307131545.28577-5-vbabka@suse.cz>
In-Reply-To: <20170307131545.28577-1-vbabka@suse.cz>
References: <20170307131545.28577-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

When stealing pages from pageblock of a different migratetype, we count how
many free pages were stolen, and change the pageblock's migratetype if more
than half of the pageblock was free. This might be too conservative, as there
might be other pages that are not free, but were allocated with the same
migratetype as our allocation requested.

While we cannot determine the migratetype of allocated pages precisely (at
least without the page_owner functionality enabled), we can count pages that
compaction would try to isolate for migration - those are either on LRU or
__PageMovable(). The rest can be assumed to be MIGRATE_RECLAIMABLE or
MIGRATE_UNMOVABLE, which we cannot easily distinguish. This counting can be
done as part of free page stealing with little additional overhead.

The page stealing code is changed so that it considers free pages plus pages
of the "good" migratetype for the decision whether to change pageblock's
migratetype.

The result should be more accurate migratetype of pageblocks wrt the actual
pages in the pageblocks, when stealing from semi-occupied pageblocks. This
should help the efficiency of page grouping by mobility.

In testing based on 4.9 kernel with stress-highalloc from mmtests configured
for order-4 GFP_KERNEL allocations, this patch has reduced the number of
unmovable allocations falling back to movable pageblocks by 47%. The number
of movable allocations falling back to other pageblocks are increased by 55%,
but these events don't cause permanent fragmentation, so the tradeoff should
be positive. Later patches also offset the movable fallback increase to some
extent.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/page-isolation.h |  5 +--
 mm/page_alloc.c                | 71 +++++++++++++++++++++++++++++++++---------
 mm/page_isolation.c            |  5 +--
 3 files changed, 61 insertions(+), 20 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 047d64706f2a..d4cd2014fa6f 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -33,10 +33,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 			 bool skip_hwpoisoned_pages);
 void set_pageblock_migratetype(struct page *page, int migratetype);
 int move_freepages_block(struct zone *zone, struct page *page,
-				int migratetype);
-int move_freepages(struct zone *zone,
-			  struct page *start_page, struct page *end_page,
-			  int migratetype);
+				int migratetype, int *num_movable);
 
 /*
  * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eda7fedf6378..db96d1ebbed8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1836,9 +1836,9 @@ static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
  * Note that start_page and end_pages are not aligned on a pageblock
  * boundary. If alignment is required, use move_freepages_block()
  */
-int move_freepages(struct zone *zone,
+static int move_freepages(struct zone *zone,
 			  struct page *start_page, struct page *end_page,
-			  int migratetype)
+			  int migratetype, int *num_movable)
 {
 	struct page *page;
 	unsigned int order;
@@ -1855,6 +1855,9 @@ int move_freepages(struct zone *zone,
 	VM_BUG_ON(page_zone(start_page) != page_zone(end_page));
 #endif
 
+	if (num_movable)
+		*num_movable = 0;
+
 	for (page = start_page; page <= end_page;) {
 		if (!pfn_valid_within(page_to_pfn(page))) {
 			page++;
@@ -1865,6 +1868,15 @@ int move_freepages(struct zone *zone,
 		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
 
 		if (!PageBuddy(page)) {
+			/*
+			 * We assume that pages that could be isolated for
+			 * migration are movable. But we don't actually try
+			 * isolating, as that would be expensive.
+			 */
+			if (num_movable &&
+					(PageLRU(page) || __PageMovable(page)))
+				(*num_movable)++;
+
 			page++;
 			continue;
 		}
@@ -1880,7 +1892,7 @@ int move_freepages(struct zone *zone,
 }
 
 int move_freepages_block(struct zone *zone, struct page *page,
-				int migratetype)
+				int migratetype, int *num_movable)
 {
 	unsigned long start_pfn, end_pfn;
 	struct page *start_page, *end_page;
@@ -1897,7 +1909,8 @@ int move_freepages_block(struct zone *zone, struct page *page,
 	if (!zone_spans_pfn(zone, end_pfn))
 		return 0;
 
-	return move_freepages(zone, start_page, end_page, migratetype);
+	return move_freepages(zone, start_page, end_page, migratetype,
+								num_movable);
 }
 
 static void change_pageblock_range(struct page *pageblock_page,
@@ -1947,22 +1960,26 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
 /*
  * This function implements actual steal behaviour. If order is large enough,
  * we can steal whole pageblock. If not, we first move freepages in this
- * pageblock and check whether half of pages are moved or not. If half of
- * pages are moved, we can change migratetype of pageblock and permanently
- * use it's pages as requested migratetype in the future.
+ * pageblock to our migratetype and determine how many already-allocated pages
+ * are there in the pageblock with a compatible migratetype. If at least half
+ * of pages are free or compatible, we can change migratetype of the pageblock
+ * itself, so pages freed in the future will be put on the correct free list.
  */
 static void steal_suitable_fallback(struct zone *zone, struct page *page,
 					int start_type, bool whole_block)
 {
 	unsigned int current_order = page_order(page);
 	struct free_area *area;
-	int pages;
+	int free_pages, movable_pages, alike_pages;
+	int old_block_type;
+
+	old_block_type = get_pageblock_migratetype(page);
 
 	/*
 	 * This can happen due to races and we want to prevent broken
 	 * highatomic accounting.
 	 */
-	if (is_migrate_highatomic_page(page))
+	if (is_migrate_highatomic(old_block_type))
 		goto single_page;
 
 	/* Take ownership for orders >= pageblock_order */
@@ -1975,10 +1992,35 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	if (!whole_block)
 		goto single_page;
 
-	pages = move_freepages_block(zone, page, start_type);
+	free_pages = move_freepages_block(zone, page, start_type,
+						&movable_pages);
+	/*
+	 * Determine how many pages are compatible with our allocation.
+	 * For movable allocation, it's the number of movable pages which
+	 * we just obtained. For other types it's a bit more tricky.
+	 */
+	if (start_type == MIGRATE_MOVABLE) {
+		alike_pages = movable_pages;
+	} else {
+		/*
+		 * If we are falling back a RECLAIMABLE or UNMOVABLE allocation
+		 * to MOVABLE pageblock, consider all non-movable pages as
+		 * compatible. If it's UNMOVABLE falling back to RECLAIMABLE or
+		 * vice versa, be conservative since we can't distinguish the
+		 * exact migratetype of non-movable pages.
+		 */
+		if (old_block_type == MIGRATE_MOVABLE)
+			alike_pages = pageblock_nr_pages
+						- (free_pages + movable_pages);
+		else
+			alike_pages = 0;
+	}
 
-	/* Claim the whole block if over half of it is free */
-	if (pages >= (1 << (pageblock_order-1)) ||
+	/*
+	 * If a sufficient number of pages in the block are either free or of
+	 * comparable migratability as our allocation, claim the whole block.
+	 */
+	if (free_pages + alike_pages >= (1 << (pageblock_order-1)) ||
 			page_group_by_mobility_disabled)
 		set_pageblock_migratetype(page, start_type);
 
@@ -2056,7 +2098,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 	    && !is_migrate_cma(mt)) {
 		zone->nr_reserved_highatomic += pageblock_nr_pages;
 		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
-		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
+		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC, NULL);
 	}
 
 out_unlock:
@@ -2133,7 +2175,8 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 			 * may increase.
 			 */
 			set_pageblock_migratetype(page, ac->migratetype);
-			ret = move_freepages_block(zone, page, ac->migratetype);
+			ret = move_freepages_block(zone, page, ac->migratetype,
+									NULL);
 			if (ret) {
 				spin_unlock_irqrestore(&zone->lock, flags);
 				return ret;
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 7927bbb54a4e..5092e4ef00c8 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -66,7 +66,8 @@ static int set_migratetype_isolate(struct page *page,
 
 		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 		zone->nr_isolate_pageblock++;
-		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
+		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE,
+									NULL);
 
 		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
 	}
@@ -120,7 +121,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	 * pageblock scanning for freepage moving.
 	 */
 	if (!isolated_page) {
-		nr_pages = move_freepages_block(zone, page, migratetype);
+		nr_pages = move_freepages_block(zone, page, migratetype, NULL);
 		__mod_zone_freepage_state(zone, nr_pages, migratetype);
 	}
 	set_pageblock_migratetype(page, migratetype);
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
