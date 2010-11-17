Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 65F706B012F
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 11:23:19 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 7/8] mm: compaction: Use the LRU to get a hint on where compaction should start
Date: Wed, 17 Nov 2010 16:22:48 +0000
Message-Id: <1290010969-26721-8-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The end of the LRU stores the oldest known page. Compaction on the other
hand always starts scanning from the start of the zone. This patch uses
the LRU to hint to compaction where it should start scanning from. This
means that compaction will at least start with some old pages reducing
the impact on running processes and reducing the amount of scanning. The
check it makes is racy as the LRU lock is not taken but it should be
harmless as we are not manipulating the lists without the lock.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    2 ++
 mm/compaction.c        |   42 +++++++++++++++++++++++++++++++++++++-----
 mm/vmscan.c            |    2 --
 3 files changed, 39 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 39c24eb..2b7e237 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -142,6 +142,8 @@ enum lru_list {
 
 #define for_each_evictable_lru(l) for (l = 0; l <= LRU_ACTIVE_FILE; l++)
 
+#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
+
 static inline int is_file_lru(enum lru_list l)
 {
 	return (l == LRU_INACTIVE_FILE || l == LRU_ACTIVE_FILE);
diff --git a/mm/compaction.c b/mm/compaction.c
index 686db84..03bd878 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -37,6 +37,9 @@ struct compact_control {
 					 * are scanned for pages to migrate and
 					 * migration is asynchronous
 					 */
+	unsigned long abort_migrate_pfn;/* Finish compaction when the migration
+					 * scanner reaches this PFN
+					 */
 
 	/* Account for isolated anon and file pages */
 	unsigned long nr_anon;
@@ -380,6 +383,10 @@ static int compact_finished(struct zone *zone,
 	if (cc->free_pfn <= cc->migrate_pfn)
 		return COMPACT_COMPLETE;
 
+	/* Compaction run completes if migration reaches abort_migrate_pfn */
+	if (cc->abort_migrate_pfn && cc->migrate_pfn >= cc->abort_migrate_pfn)
+		return COMPACT_COMPLETE;
+
 	/* Compaction run is not finished if the watermark is not met */
 	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
 		return COMPACT_CONTINUE;
@@ -450,10 +457,17 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		;
 	}
 
-	/* Setup to move all movable pages to the end of the zone */
-	cc->migrate_pfn = zone->zone_start_pfn;
-	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
-	cc->free_pfn &= ~(pageblock_nr_pages-1);
+	/*
+	 * Setup to move all movable pages to the end of the zone. If the
+	 * caller does not specify starting points for the scanners,
+	 * initialise them
+	 */
+	if (!cc->migrate_pfn)
+		cc->migrate_pfn = zone->zone_start_pfn;
+	if (!cc->free_pfn) {
+		cc->free_pfn = zone->zone_start_pfn + zone->spanned_pages;
+		cc->free_pfn &= ~(pageblock_nr_pages-1);
+	}
 
 	migrate_prep_local();
 
@@ -512,6 +526,8 @@ static unsigned long compact_zone_order(struct zone *zone,
 unsigned long reclaimcompact_zone_order(struct zone *zone,
 						int order, gfp_t gfp_mask)
 {
+	unsigned long start_migrate_pfn, ret;
+	struct page *anon_page, *file_page;
 	struct compact_control cc = {
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
@@ -523,7 +539,23 @@ unsigned long reclaimcompact_zone_order(struct zone *zone,
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
 
-	return compact_zone(zone, &cc);
+	/* Get a hint on where to start compacting from the LRU */
+	anon_page = lru_to_page(&zone->lru[LRU_BASE + LRU_INACTIVE_ANON].list);
+	file_page = lru_to_page(&zone->lru[LRU_BASE + LRU_INACTIVE_FILE].list);
+	cc.migrate_pfn = min(page_to_pfn(anon_page), page_to_pfn(file_page));
+	cc.migrate_pfn = ALIGN(cc.migrate_pfn, pageblock_nr_pages);
+	start_migrate_pfn = cc.migrate_pfn;
+
+	ret = compact_zone(zone, &cc);
+
+	/* Restart migration from the start of zone if the hint did not work */
+	if (!zone_watermark_ok(zone, cc.order, low_wmark_pages(zone), 0, 0)) {
+		cc.migrate_pfn = 0;
+		cc.abort_migrate_pfn = start_migrate_pfn;
+		ret = compact_zone(zone, &cc);
+	}
+
+	return ret;
 }
 
 int sysctl_extfrag_threshold = 500;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ca108ce..9a0fa57 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -113,8 +113,6 @@ struct scan_control {
 	nodemask_t	*nodemask;
 };
 
-#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
-
 #ifdef ARCH_HAS_PREFETCH
 #define prefetch_prev_lru_page(_page, _base, _field)			\
 	do {								\
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
