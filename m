Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26CBF6B0391
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:23:58 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v67so13759885wrb.4
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:23:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t89si2967027wrc.24.2017.02.10.09.23.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 09:23:52 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC v2 10/10] mm, page_alloc: introduce MIGRATE_MIXED migratetype
Date: Fri, 10 Feb 2017 18:23:43 +0100
Message-Id: <20170210172343.30283-11-vbabka@suse.cz>
In-Reply-To: <20170210172343.30283-1-vbabka@suse.cz>
References: <20170210172343.30283-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

Page mobility grouping tries to minimize the number of pageblocks that contain
non-migratable pages by distinguishing MOVABLE, UNMOVABLE and RECLAIMABLE
pageblock migratetypes. Changing pageblock's migratetype is allowed if an
allocation of different migratetype steals more than half of pages from it.

That means it's possible to have pageblocks that contain some UNMOVABLE and
RECLAIMABLE pages, yet they are marked as MOVABLE, and the next time stealing
happens, another MOVABLE pageblock might get polluted. On the other hand, if we
duly marked all polluted pageblocks (even just by single page) as UNMOVABLE or
RECLAIMABLE, further allocations and freeing of pages would tend to spread over
all of them, and there would be little pressure for them to eventually become
fully free and MOVABLE.

This patch thus introduces a new migratetype MIGRATE_MIXED, which is intended
to mark pageblocks that contain some UNMOVABLE or RECLAIMABLE pages, but not
enough to mark the whole pageblocks as such. These pageblocks become preferred
fallback before UNMOVABLE/RECLAIMABLE allocation steals from a MOVABLE
pageblock, or vice versa. This should help page mobility grouping:

- UNMOVABLE and RECLAIMABLE allocations will try to be satisfied from their
  respective pageblocks. If these are full, polluting other pageblocks is
  limited to MIGRATE_MIXED pageblocks. MIGRATE_MOVABLE pageblocks remain pure.
  If a temporery pressure for UNMOVABLE and RECLAIMABLE pageblocks disappears
  and can be satisfied without fallback, the MIXED pageblocks might eventually
  fully recover from the polluted pages.

- MOVABLE allocations will exhaust MOVABLE pageblocks first, then fallback to
  MIXED as second. This leaves free pages in UNMOVABLE and RECLAIMABLE
  pageblocks as a last resort, so those allocations don't have to fall back
  so much.

Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h |  1 +
 mm/compaction.c        | 14 ++++++++--
 mm/page_alloc.c        | 73 +++++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 71 insertions(+), 17 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fd60a2b2d25d..d9417f5171d8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -41,6 +41,7 @@ enum {
 	MIGRATE_RECLAIMABLE,
 	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
 	MIGRATE_HIGHATOMIC = MIGRATE_PCPTYPES,
+	MIGRATE_MIXED,
 #ifdef CONFIG_CMA
 	/*
 	 * MIGRATE_CMA migration type is designed to mimic the way
diff --git a/mm/compaction.c b/mm/compaction.c
index bb18d21c6a56..d2d7bfeffe7e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1001,6 +1001,9 @@ static bool suitable_migration_source(struct compact_control *cc,
 
 	block_mt = get_pageblock_migratetype(page);
 
+	if (block_mt == MIGRATE_MIXED)
+		return true;
+
 	if (cc->migratetype == MIGRATE_MOVABLE)
 		return is_migrate_movable(block_mt);
 	else
@@ -1011,6 +1014,8 @@ static bool suitable_migration_source(struct compact_control *cc,
 static bool suitable_migration_target(struct compact_control *cc,
 							struct page *page)
 {
+	int block_mt;
+
 	if (cc->ignore_block_suitable)
 		return true;
 
@@ -1025,8 +1030,13 @@ static bool suitable_migration_target(struct compact_control *cc,
 			return false;
 	}
 
-	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (is_migrate_movable(get_pageblock_migratetype(page)))
+	block_mt = get_pageblock_migratetype(page);
+
+	/*
+	 * If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration.
+	 * Allow also mixed pageblocks so we are not so restrictive.
+	 */
+	if (is_migrate_movable(block_mt) || block_mt == MIGRATE_MIXED)
 		return true;
 
 	/* Otherwise skip the block */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5270be8325fd..1a93813e7962 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -234,6 +234,7 @@ char * const migratetype_names[MIGRATE_TYPES] = {
 	"Movable",
 	"Reclaimable",
 	"HighAtomic",
+	"Mixed",
 #ifdef CONFIG_CMA
 	"CMA",
 #endif
@@ -1817,9 +1818,9 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
  * the free lists for the desirable migrate type are depleted
  */
 static int fallbacks[MIGRATE_TYPES][4] = {
-	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_TYPES },
-	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_TYPES },
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_TYPES },
+	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MIXED, MIGRATE_MOVABLE,   MIGRATE_TYPES },
+	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MIXED, MIGRATE_MOVABLE,   MIGRATE_TYPES },
+	[MIGRATE_MOVABLE]     = { MIGRATE_MIXED, MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_TYPES },
 #ifdef CONFIG_CMA
 	[MIGRATE_CMA]         = { MIGRATE_TYPES }, /* Never used */
 #endif
@@ -1977,7 +1978,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	unsigned int current_order = page_order(page);
 	struct free_area *area;
 	int free_pages, good_pages;
-	int old_block_type;
+	int old_block_type, new_block_type;
 
 	/* Take ownership for orders >= pageblock_order */
 	if (current_order >= pageblock_order) {
@@ -1991,11 +1992,27 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	if (!whole_block) {
 		area = &zone->free_area[current_order];
 		list_move(&page->lru, &area->free_list[start_type]);
-		return;
+		free_pages = 1 << current_order;
+		/* TODO: We didn't scan the block, so be pessimistic */
+		good_pages = 0;
+	} else {
+		free_pages = move_freepages_block(zone, page, start_type,
+							&good_pages);
+		/*
+		 * good_pages is now the number of movable pages, but if we
+		 * want UNMOVABLE or RECLAIMABLE, we consider all non-movable
+		 * as good (but we can't fully distinguish them)
+		 */
+		if (start_type != MIGRATE_MOVABLE)
+			good_pages = pageblock_nr_pages - free_pages -
+								good_pages;
 	}
 
 	free_pages = move_freepages_block(zone, page, start_type,
 						&good_pages);
+
+	new_block_type = old_block_type = get_pageblock_migratetype(page);
+
 	/*
 	 * good_pages is now the number of movable pages, but if we
 	 * want UNMOVABLE or RECLAIMABLE allocation, it's more tricky
@@ -2007,7 +2024,6 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 		 * falling back to RECLAIMABLE or vice versa, be conservative
 		 * as we can't distinguish the exact migratetype.
 		 */
-		old_block_type = get_pageblock_migratetype(page);
 		if (old_block_type == MIGRATE_MOVABLE)
 			good_pages = pageblock_nr_pages
 						- free_pages - good_pages;
@@ -2015,10 +2031,34 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 			good_pages = 0;
 	}
 
-	/* Claim the whole block if over half of it is free or good type */
-	if (free_pages + good_pages >= (1 << (pageblock_order-1)) ||
-			page_group_by_mobility_disabled)
-		set_pageblock_migratetype(page, start_type);
+	if (page_group_by_mobility_disabled) {
+		new_block_type = start_type;
+	} else if (free_pages + good_pages >= (1 << (pageblock_order-1))) {
+		/*
+		 * Claim the whole block if over half of it is free or good
+		 * type. The exception is the transition to MIGRATE_MOVABLE
+		 * where we require it to be fully free so that MIGRATE_MOVABLE
+		 * pageblocks consist of purely movable pages. So if we steal
+		 * less than whole pageblock, mark it as MIGRATE_MIXED.
+		 */
+		if ((start_type == MIGRATE_MOVABLE) &&
+				free_pages + good_pages < pageblock_nr_pages)
+			new_block_type = MIGRATE_MIXED;
+		else
+			new_block_type = start_type;
+	} else {
+		/*
+		 * We didn't steal enough to change the block's migratetype.
+		 * But if we are stealing from a MOVABLE block for a
+		 * non-MOVABLE allocation, mark the block as MIXED.
+		 */
+		if (old_block_type == MIGRATE_MOVABLE
+					&& start_type != MIGRATE_MOVABLE)
+			new_block_type = MIGRATE_MIXED;
+	}
+
+	if (new_block_type != old_block_type)
+		set_pageblock_migratetype(page, new_block_type);
 }
 
 /*
@@ -2560,16 +2600,18 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	rmv_page_order(page);
 
 	/*
-	 * Set the pageblock if the isolated page is at least half of a
-	 * pageblock
+	 * Set the pageblock's migratetype to MIXED if the isolated page is
+	 * at least half of a pageblock, MOVABLE if at least whole pageblock
 	 */
 	if (order >= pageblock_order - 1) {
 		struct page *endpage = page + (1 << order) - 1;
+		int new_mt = (order >= pageblock_order) ?
+					MIGRATE_MOVABLE : MIGRATE_MIXED;
 		for (; page < endpage; page += pageblock_nr_pages) {
 			int mt = get_pageblock_migratetype(page);
-			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
-				set_pageblock_migratetype(page,
-							  MIGRATE_MOVABLE);
+
+			if (!is_migrate_isolate(mt) && !is_migrate_movable(mt))
+				set_pageblock_migratetype(page, new_mt);
 		}
 	}
 
@@ -4252,6 +4294,7 @@ static void show_migration_types(unsigned char type)
 		[MIGRATE_MOVABLE]	= 'M',
 		[MIGRATE_RECLAIMABLE]	= 'E',
 		[MIGRATE_HIGHATOMIC]	= 'H',
+		[MIGRATE_MIXED]		= 'M',
 #ifdef CONFIG_CMA
 		[MIGRATE_CMA]		= 'C',
 #endif
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
