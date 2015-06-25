Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 68A696B007B
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 20:43:13 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so19348834pdb.1
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 17:43:13 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id fk1si42151599pbd.164.2015.06.24.17.42.59
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 17:43:00 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 06/10] mm/compaction: introduce compaction depleted state on zone
Date: Thu, 25 Jun 2015 09:45:17 +0900
Message-Id: <1435193121-25880-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Further compaction attempt is deferred when some of compaction attempts
already fails. But, after some number of trial are skipped, compaction
restarts work to check whether compaction is now possible or not. It
scans whole range of zone to determine this possibility and if compaction
possibility doesn't recover, this whole range scan is quite big overhead.
As a first step to reduce this overhead, this patch implement compaction
depleted state on zone.

The way to determine depletion of compaction possility is checking number
of success on previous compaction attempt. If number of successful
compaction is below than specified threshold, we guess that compaction
will not successful next time so mark the zone as compaction depleted.
In this patch, threshold is choosed by 1 to imitate current compaction
deferring algorithm. In the following patch, compaction algorithm will be
changed and this threshold is also adjusted to that change.

In this patch, only state definition is implemented. There is no action
for this new state so no functional change. But, following patch will
add some handling for this new state.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h |  2 ++
 mm/compaction.c        | 38 +++++++++++++++++++++++++++++++++++---
 2 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 754c259..bd9f1a5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -517,6 +517,7 @@ struct zone {
 	unsigned int		compact_considered;
 	unsigned int		compact_defer_shift;
 	int			compact_order_failed;
+	unsigned long		compact_success;
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
@@ -543,6 +544,7 @@ enum zone_flags {
 					 * many pages under writeback
 					 */
 	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
+	ZONE_COMPACTION_DEPLETED,	/* compaction possiblity depleted */
 };
 
 static inline unsigned long zone_end_pfn(const struct zone *zone)
diff --git a/mm/compaction.c b/mm/compaction.c
index 8d1b3b5..9f259b9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -129,6 +129,23 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
+#define COMPACT_MIN_DEPLETE_THRESHOLD 1UL
+
+static bool compaction_depleted(struct zone *zone)
+{
+	unsigned long threshold;
+	unsigned long success = zone->compact_success;
+
+	/*
+	 * Now, to imitate current compaction deferring approach,
+	 * choose threshold to 1. It will be changed in the future.
+	 */
+	threshold = COMPACT_MIN_DEPLETE_THRESHOLD;
+	if (success >= threshold)
+		return false;
+
+	return true;
+}
 
 /*
  * Compaction is deferred when compaction fails to result in a page
@@ -226,6 +243,10 @@ static void __reset_isolation_suitable(struct zone *zone)
 	zone->compact_cached_free_pfn = end_pfn;
 	zone->compact_blockskip_flush = false;
 
+	if (compaction_depleted(zone))
+		set_bit(ZONE_COMPACTION_DEPLETED, &zone->flags);
+	zone->compact_success = 0;
+
 	/* Walk the zone and mark every pageblock as suitable for isolation */
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		struct page *page;
@@ -1197,22 +1218,28 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 		bool can_steal;
 
 		/* Job done if page is free of the right migratetype */
-		if (!list_empty(&area->free_list[migratetype]))
+		if (!list_empty(&area->free_list[migratetype])) {
+			zone->compact_success++;
 			return COMPACT_PARTIAL;
+		}
 
 #ifdef CONFIG_CMA
 		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
 		if (migratetype == MIGRATE_MOVABLE &&
-			!list_empty(&area->free_list[MIGRATE_CMA]))
+			!list_empty(&area->free_list[MIGRATE_CMA])) {
+			zone->compact_success++;
 			return COMPACT_PARTIAL;
+		}
 #endif
 		/*
 		 * Job done if allocation would steal freepages from
 		 * other migratetype buddy lists.
 		 */
 		if (find_suitable_fallback(area, order, migratetype,
-						true, &can_steal) != -1)
+						true, &can_steal) != -1) {
+			zone->compact_success++;
 			return COMPACT_PARTIAL;
+		}
 	}
 
 	return COMPACT_NO_SUITABLE_PAGE;
@@ -1452,6 +1479,11 @@ out:
 	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync, ret);
 
+	if (test_bit(ZONE_COMPACTION_DEPLETED, &zone->flags)) {
+		if (!compaction_depleted(zone))
+			clear_bit(ZONE_COMPACTION_DEPLETED, &zone->flags);
+	}
+
 	return ret;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
