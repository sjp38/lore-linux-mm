Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C68B6B038A
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:23:54 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o16so13778802wra.2
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:23:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 204si1979875wmk.136.2017.02.10.09.23.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 09:23:52 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 04/10] mm, page_alloc: count movable pages when stealing from pageblock
Date: Fri, 10 Feb 2017 18:23:37 +0100
Message-Id: <20170210172343.30283-5-vbabka@suse.cz>
In-Reply-To: <20170210172343.30283-1-vbabka@suse.cz>
References: <20170210172343.30283-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

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

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/page-isolation.h |  5 +---
 mm/page_alloc.c                | 54 +++++++++++++++++++++++++++++++++---------
 mm/page_isolation.c            |  5 ++--
 3 files changed, 47 insertions(+), 17 deletions(-)

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
index 314e6b9ddbc4..a7d33818610f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1844,9 +1844,9 @@ static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
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
@@ -1863,6 +1863,9 @@ int move_freepages(struct zone *zone,
 	VM_BUG_ON(page_zone(start_page) != page_zone(end_page));
 #endif
 
+	if (num_movable)
+		*num_movable = 0;
+
 	for (page = start_page; page <= end_page;) {
 		/* Make sure we are not inadvertently changing nodes */
 		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
@@ -1873,6 +1876,14 @@ int move_freepages(struct zone *zone,
 		}
 
 		if (!PageBuddy(page)) {
+			/*
+			 * We assume that pages that could be isolated for
+			 * migration are movable. But we don't actually try
+			 * isolating, as that would be expensive.
+			 */
+			if (num_movable && (PageLRU(page) || __PageMovable(page)))
+				(*num_movable)++;
+
 			page++;
 			continue;
 		}
@@ -1888,7 +1899,7 @@ int move_freepages(struct zone *zone,
 }
 
 int move_freepages_block(struct zone *zone, struct page *page,
-				int migratetype)
+				int migratetype, int *num_movable)
 {
 	unsigned long start_pfn, end_pfn;
 	struct page *start_page, *end_page;
@@ -1905,7 +1916,8 @@ int move_freepages_block(struct zone *zone, struct page *page,
 	if (!zone_spans_pfn(zone, end_pfn))
 		return 0;
 
-	return move_freepages(zone, start_page, end_page, migratetype);
+	return move_freepages(zone, start_page, end_page, migratetype,
+								num_movable);
 }
 
 static void change_pageblock_range(struct page *pageblock_page,
@@ -1960,11 +1972,12 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
  * use it's pages as requested migratetype in the future.
  */
 static void steal_suitable_fallback(struct zone *zone, struct page *page,
-					 int start_type, bool whole_block)
+					int start_type, bool whole_block)
 {
 	unsigned int current_order = page_order(page);
 	struct free_area *area;
-	int pages;
+	int free_pages, good_pages;
+	int old_block_type;
 
 	/* Take ownership for orders >= pageblock_order */
 	if (current_order >= pageblock_order) {
@@ -1981,10 +1994,29 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 		return;
 	}
 
-	pages = move_freepages_block(zone, page, start_type);
+	free_pages = move_freepages_block(zone, page, start_type,
+						&good_pages);
+	/*
+	 * good_pages is now the number of movable pages, but if we
+	 * want UNMOVABLE or RECLAIMABLE allocation, it's more tricky
+	 */
+	if (start_type != MIGRATE_MOVABLE) {
+		/*
+		 * If we are falling back to MIGRATE_MOVABLE pageblock,
+		 * treat all non-movable pages as good. If it's UNMOVABLE
+		 * falling back to RECLAIMABLE or vice versa, be conservative
+		 * as we can't distinguish the exact migratetype.
+		 */
+		old_block_type = get_pageblock_migratetype(page);
+		if (old_block_type == MIGRATE_MOVABLE)
+			good_pages = pageblock_nr_pages
+						- free_pages - good_pages;
+		else
+			good_pages = 0;
+	}
 
-	/* Claim the whole block if over half of it is free */
-	if (pages >= (1 << (pageblock_order-1)) ||
+	/* Claim the whole block if over half of it is free or good type */
+	if (free_pages + good_pages >= (1 << (pageblock_order-1)) ||
 			page_group_by_mobility_disabled)
 		set_pageblock_migratetype(page, start_type);
 }
@@ -2056,7 +2088,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 			!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {
 		zone->nr_reserved_highatomic += pageblock_nr_pages;
 		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
-		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
+		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC, NULL);
 	}
 
 out_unlock:
@@ -2113,7 +2145,7 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 			 * may increase.
 			 */
 			set_pageblock_migratetype(page, ac->migratetype);
-			move_freepages_block(zone, page, ac->migratetype);
+			move_freepages_block(zone, page, ac->migratetype, NULL);
 			spin_unlock_irqrestore(&zone->lock, flags);
 			return;
 		}
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index a5594bfcc5ed..29c2f9b9aba7 100644
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
