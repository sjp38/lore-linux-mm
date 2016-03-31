Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B9C066B025F
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 04:51:07 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id p65so104883437wmp.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 01:51:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id di9si10594351wjb.191.2016.03.31.01.51.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 01:51:01 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 1/4] mm, compaction: wrap calculating first and last pfn of pageblock
Date: Thu, 31 Mar 2016 10:50:33 +0200
Message-Id: <1459414236-9219-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
References: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

Compaction code has accumulated numerous instances of manual calculations of
the first (inclusive) and last (exclusive) pfn of a pageblock (or a smaller
block of given order), given a pfn within the pageblock. Wrap these
calculations by introducing pageblock_start_pfn(pfn) and pageblock_end_pfn(pfn)
macros.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 33 +++++++++++++++++++--------------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index ccf97b02b85f..3319145a387d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -42,6 +42,11 @@ static inline void count_compact_events(enum vm_event_item item, long delta)
 #define CREATE_TRACE_POINTS
 #include <trace/events/compaction.h>
 
+#define block_start_pfn(pfn, order)	round_down(pfn, 1UL << (order))
+#define block_end_pfn(pfn, order)	ALIGN((pfn) + 1, 1UL << (order))
+#define pageblock_start_pfn(pfn)	block_start_pfn(pfn, pageblock_order)
+#define pageblock_end_pfn(pfn)		block_end_pfn(pfn, pageblock_order)
+
 static unsigned long release_freepages(struct list_head *freelist)
 {
 	struct page *page, *next;
@@ -161,7 +166,7 @@ static void reset_cached_positions(struct zone *zone)
 	zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
 	zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
 	zone->compact_cached_free_pfn =
-			round_down(zone_end_pfn(zone) - 1, pageblock_nr_pages);
+				pageblock_start_pfn(zone_end_pfn(zone) - 1);
 }
 
 /*
@@ -519,10 +524,10 @@ isolate_freepages_range(struct compact_control *cc,
 	LIST_HEAD(freelist);
 
 	pfn = start_pfn;
-	block_start_pfn = pfn & ~(pageblock_nr_pages - 1);
+	block_start_pfn = pageblock_start_pfn(pfn);
 	if (block_start_pfn < cc->zone->zone_start_pfn)
 		block_start_pfn = cc->zone->zone_start_pfn;
-	block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+	block_end_pfn = pageblock_end_pfn(pfn);
 
 	for (; pfn < end_pfn; pfn += isolated,
 				block_start_pfn = block_end_pfn,
@@ -538,8 +543,8 @@ isolate_freepages_range(struct compact_control *cc,
 		 * scanning range to right one.
 		 */
 		if (pfn >= block_end_pfn) {
-			block_start_pfn = pfn & ~(pageblock_nr_pages - 1);
-			block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+			block_start_pfn = pageblock_start_pfn(pfn);
+			block_end_pfn = pageblock_end_pfn(pfn);
 			block_end_pfn = min(block_end_pfn, end_pfn);
 		}
 
@@ -834,10 +839,10 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 
 	/* Scan block by block. First and last block may be incomplete */
 	pfn = start_pfn;
-	block_start_pfn = pfn & ~(pageblock_nr_pages - 1);
+	block_start_pfn = pageblock_start_pfn(pfn);
 	if (block_start_pfn < cc->zone->zone_start_pfn)
 		block_start_pfn = cc->zone->zone_start_pfn;
-	block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+	block_end_pfn = pageblock_end_pfn(pfn);
 
 	for (; pfn < end_pfn; pfn = block_end_pfn,
 				block_start_pfn = block_end_pfn,
@@ -932,10 +937,10 @@ static void isolate_freepages(struct compact_control *cc)
 	 * is using.
 	 */
 	isolate_start_pfn = cc->free_pfn;
-	block_start_pfn = cc->free_pfn & ~(pageblock_nr_pages-1);
+	block_start_pfn = pageblock_start_pfn(cc->free_pfn);
 	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
 						zone_end_pfn(zone));
-	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
+	low_pfn = pageblock_start_pfn(cc->migrate_pfn);
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
@@ -1089,12 +1094,12 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	 * initialized by compact_zone()
 	 */
 	low_pfn = cc->migrate_pfn;
-	block_start_pfn = cc->migrate_pfn & ~(pageblock_nr_pages - 1);
+	block_start_pfn = pageblock_start_pfn(low_pfn);
 	if (block_start_pfn < zone->zone_start_pfn)
 		block_start_pfn = zone->zone_start_pfn;
 
 	/* Only scan within a pageblock boundary */
-	block_end_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages);
+	block_end_pfn = pageblock_end_pfn(low_pfn);
 
 	/*
 	 * Iterate over whole pageblocks until we find the first suitable.
@@ -1351,7 +1356,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
 	cc->free_pfn = zone->compact_cached_free_pfn;
 	if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
-		cc->free_pfn = round_down(end_pfn - 1, pageblock_nr_pages);
+		cc->free_pfn = pageblock_start_pfn(end_pfn - 1);
 		zone->compact_cached_free_pfn = cc->free_pfn;
 	}
 	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn >= end_pfn) {
@@ -1419,7 +1424,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		if (cc->order > 0 && cc->last_migrated_pfn) {
 			int cpu;
 			unsigned long current_block_start =
-				cc->migrate_pfn & ~((1UL << cc->order) - 1);
+				block_start_pfn(cc->migrate_pfn, cc->order);
 
 			if (cc->last_migrated_pfn < current_block_start) {
 				cpu = get_cpu();
@@ -1444,7 +1449,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		cc->nr_freepages = 0;
 		VM_BUG_ON(free_pfn == 0);
 		/* The cached pfn is always the first in a pageblock */
-		free_pfn &= ~(pageblock_nr_pages-1);
+		free_pfn = pageblock_start_pfn(free_pfn);
 		/*
 		 * Only go back, not forward. The cached pfn might have been
 		 * already reset to zone end in compact_finished()
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
