Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBB16B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 09:11:44 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id d186so14085020lfg.7
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 06:11:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ni8si4914546wjb.46.2016.10.11.06.11.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 06:11:42 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 6/4] mm, page_alloc: introduce MIGRATE_MIXED migratetype
Date: Tue, 11 Oct 2016 15:11:30 +0200
Message-Id: <20161011131130.9634-1-vbabka@suse.cz>
In-Reply-To: <20160929210548.26196-1-vbabka@suse.cz>
References: <20160929210548.26196-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

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

This is not a new idea, but maybe it's time to give it a shot. Perhaps it will
have to be complemented by compaction migrate scanner recovering pageblocks
from one migratetype to another depending on how many free pages and migratable
pages it finds in them. The fallback events have limited information and
unpredictable timing.

 include/linux/mmzone.h |  1 +
 mm/compaction.c        | 14 +++++++++--
 mm/page_alloc.c        | 63 ++++++++++++++++++++++++++++++++++++--------------
 3 files changed, 59 insertions(+), 19 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9cd3ee58ab2b..e4e0a1f64801 100644
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
index eb4ccd403543..79bff09a5cac 100644
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
index 2ccd80079d22..6c5bc6a7858c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -229,6 +229,7 @@ char * const migratetype_names[MIGRATE_TYPES] = {
 	"Movable",
 	"Reclaimable",
 	"HighAtomic",
+	"Mixed",
 #ifdef CONFIG_CMA
 	"CMA",
 #endif
@@ -1814,9 +1815,9 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
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
@@ -1937,13 +1938,12 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
 	 * but, below check doesn't guarantee it and that is just heuristic
 	 * so could be changed anytime.
 	 */
-	if (order >= pageblock_order)
+	if (order >= pageblock_order || page_group_by_mobility_disabled)
 		return true;
 
 	if (order >= pageblock_order / 2 ||
 		start_mt == MIGRATE_RECLAIMABLE ||
-		start_mt == MIGRATE_UNMOVABLE ||
-		page_group_by_mobility_disabled)
+		start_mt == MIGRATE_UNMOVABLE)
 		return true;
 
 	return false;
@@ -1962,6 +1962,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	unsigned int current_order = page_order(page);
 	struct free_area *area;
 	int pages;
+	int old_block_type, new_block_type;
 
 	/* Take ownership for orders >= pageblock_order */
 	if (current_order >= pageblock_order) {
@@ -1975,15 +1976,40 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	if (!whole_block) {
 		area = &zone->free_area[current_order];
 		list_move(&page->lru, &area->free_list[start_type]);
-		return;
+		pages = 1 << current_order;
+	} else {
+		pages = move_freepages_block(zone, page, start_type);
 	}
 
-	pages = move_freepages_block(zone, page, start_type);
+	new_block_type = old_block_type = get_pageblock_migratetype(page);
+	if (page_group_by_mobility_disabled)
+		new_block_type = start_type;
 
-	/* Claim the whole block if over half of it is free */
-	if (pages >= (1 << (pageblock_order-1)) ||
-			page_group_by_mobility_disabled)
-		set_pageblock_migratetype(page, start_type);
+	if (pages >= (1 << (pageblock_order-1))) {
+		/*
+		 * Claim the whole block if over half of it is free. The
+		 * exception is the transition to MIGRATE_MOVABLE where we
+		 * require it to be fully free so that MIGRATE_MOVABLE
+		 * pageblocks consist of purely movable pages. So if we steal
+		 * less than whole pageblock, mark it as MIGRATE_MIXED.
+		 */
+		if (start_type == MIGRATE_MOVABLE)
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
@@ -2526,16 +2552,18 @@ int __isolate_free_page(struct page *page, unsigned int order)
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
 
@@ -4213,6 +4241,7 @@ static void show_migration_types(unsigned char type)
 		[MIGRATE_MOVABLE]	= 'M',
 		[MIGRATE_RECLAIMABLE]	= 'E',
 		[MIGRATE_HIGHATOMIC]	= 'H',
+		[MIGRATE_MIXED]		= 'M',
 #ifdef CONFIG_CMA
 		[MIGRATE_CMA]		= 'C',
 #endif
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
