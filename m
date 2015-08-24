Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B34F782F5F
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 22:20:02 -0400 (EDT)
Received: by pdob1 with SMTP id b1so47326262pdo.2
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:02 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id i10si24995471pat.138.2015.08.23.19.19.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 19:20:01 -0700 (PDT)
Received: by padfo6 with SMTP id fo6so5192912pad.3
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:19:59 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 2/9] mm/compaction: introduce compaction depleted state on zone
Date: Mon, 24 Aug 2015 11:19:26 +0900
Message-Id: <1440382773-16070-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
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
 include/linux/mmzone.h |  3 +++
 mm/compaction.c        | 44 +++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 44 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 754c259..700e9b5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -517,6 +517,8 @@ struct zone {
 	unsigned int		compact_considered;
 	unsigned int		compact_defer_shift;
 	int			compact_order_failed;
+	unsigned long		compact_success;
+	unsigned long		compact_depletion_depth;
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
@@ -543,6 +545,7 @@ enum zone_flags {
 					 * many pages under writeback
 					 */
 	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
+	ZONE_COMPACTION_DEPLETED,	/* compaction possiblity depleted */
 };
 
 static inline unsigned long zone_end_pfn(const struct zone *zone)
diff --git a/mm/compaction.c b/mm/compaction.c
index c2d3d6a..de96e9d 100644
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
@@ -223,6 +240,16 @@ static void __reset_isolation_suitable(struct zone *zone)
 	zone->compact_cached_free_pfn = end_pfn;
 	zone->compact_blockskip_flush = false;
 
+	if (compaction_depleted(zone)) {
+		if (test_bit(ZONE_COMPACTION_DEPLETED, &zone->flags))
+			zone->compact_depletion_depth++;
+		else {
+			set_bit(ZONE_COMPACTION_DEPLETED, &zone->flags);
+			zone->compact_depletion_depth = 0;
+		}
+	}
+	zone->compact_success = 0;
+
 	/* Walk the zone and mark every pageblock as suitable for isolation */
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		struct page *page;
@@ -1185,22 +1212,28 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
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
@@ -1440,6 +1473,11 @@ out:
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
