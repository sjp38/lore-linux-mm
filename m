Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE4B6B012E
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 11:22:58 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 6/8] mm: compaction: Perform a faster scan in try_to_compact_pages()
Date: Wed, 17 Nov 2010 16:22:47 +0000
Message-Id: <1290010969-26721-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

try_to_compact_pages() is the faster compaction option available to the
allocator. It is optimistically called before direct reclaim is entered.
As there is a higher chance try_to_compact_pages() will fail than direct
reclaim, it's important to complete the work as quickly as possible to
minimise stalls.

This patch introduces a migrate_fast_scan to memory compaction. When set
by try_to_compact_pages(), only MIGRATE_MOVABLE pageblocks are considered
as migration candidates and migration is asynchronous. This reduces stalls
when allocating huge pages while not impairing allocation success rates as
the direct reclaim path will perform the full compaction.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/compaction.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 75d46d8..686db84 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -33,7 +33,10 @@ struct compact_control {
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
-	bool sync;			/* Synchronous migration */
+	bool migrate_fast_scan;		/* If true, only MIGRATE_MOVABLE blocks
+					 * are scanned for pages to migrate and
+					 * migration is asynchronous
+					 */
 
 	/* Account for isolated anon and file pages */
 	unsigned long nr_anon;
@@ -240,6 +243,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
 	unsigned long low_pfn, end_pfn;
+	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
 
@@ -280,6 +284,17 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		if (PageBuddy(page))
 			continue;
 
+		/* When fast scanning, only scan in MOVABLE blocks */
+		pageblock_nr = low_pfn >> pageblock_order;
+		if (cc->migrate_fast_scan &&
+				last_pageblock_nr != pageblock_nr &&
+				get_pageblock_migratetype(page) != MIGRATE_MOVABLE) {
+			low_pfn += pageblock_nr_pages;
+			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
+			last_pageblock_nr = pageblock_nr;
+			continue;
+		}
+
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
 			continue;
@@ -451,7 +466,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		nr_migrate = cc->nr_migratepages;
 		migrate_pages(&cc->migratepages, compaction_alloc,
 				(unsigned long)cc, false,
-				cc->sync);
+				cc->migrate_fast_scan ? false : true);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
@@ -485,8 +500,8 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.nr_migratepages = 0,
 		.order = order,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
+		.migrate_fast_scan = true,
 		.zone = zone,
-		.sync = false,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -502,8 +517,8 @@ unsigned long reclaimcompact_zone_order(struct zone *zone,
 		.nr_migratepages = 0,
 		.order = order,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
+		.migrate_fast_scan = false,
 		.zone = zone,
-		.sync = true,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
