Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DCEC6B038B
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:23:53 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so10969790wjb.7
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:23:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c129si1971604wmh.166.2017.02.10.09.23.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 09:23:51 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC v2 09/10] mm, page_alloc: disallow migratetype fallback in fastpath
Date: Fri, 10 Feb 2017 18:23:42 +0100
Message-Id: <20170210172343.30283-10-vbabka@suse.cz>
In-Reply-To: <20170210172343.30283-1-vbabka@suse.cz>
References: <20170210172343.30283-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

The previous patch has adjusted async compaction so that it helps against
longterm fragmentation when compacting for a non-MOVABLE high-order allocation.
The goal of this patch is to force such allocations go through compaction
once before being allowed to fallback to a pageblock of different migratetype
(e.g. MOVABLE). In contexts where compaction is not allowed (and for order-0
allocations), this delayed fallback possibility can still help by trying a
different zone where fallback might not be needed and potentially waking up
kswapd earlier.

Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 22 +++++++++++++++++-----
 mm/internal.h   |  2 ++
 mm/page_alloc.c | 15 +++++++++++----
 3 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index cef77a5fffea..bb18d21c6a56 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1357,9 +1357,11 @@ static enum compact_result __compact_finished(struct zone *zone,
 #endif
 		/*
 		 * Job done if allocation would steal freepages from
-		 * other migratetype buddy lists.
+		 * other migratetype buddy lists. This is not allowed
+		 * for async direct compaction.
 		 */
-		if (find_suitable_fallback(area, order, migratetype,
+		if (!cc->prevent_fallback &&
+			find_suitable_fallback(area, order, migratetype,
 						true, &can_steal) != -1) {
 
 			/* movable pages are OK in any pageblock */
@@ -1530,8 +1532,17 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
-	/* Compaction is likely to fail */
-	if (ret == COMPACT_SUCCESS || ret == COMPACT_SKIPPED)
+	/*
+	 * Compaction should not be needed. If we don't allow stealing from
+	 * pageblocks of different migratetype, the watermark checks cannot
+	 * distinguish that, so assume we would need to steal, and leave the
+	 * thorough check to compact_finished().
+	 */
+	if (ret == COMPACT_SUCCESS && !cc->prevent_fallback)
+		return ret;
+
+	/* Compaction is likely to fail due to insufficient free pages */
+	if (ret == COMPACT_SKIPPED)
 		return ret;
 
 	/* huh, compaction_suitable is returning something unexpected */
@@ -1699,7 +1710,8 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 		.direct_compaction = true,
 		.whole_zone = (prio == MIN_COMPACT_PRIORITY),
 		.ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY),
-		.ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY)
+		.ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY),
+		.prevent_fallback = (prio == COMPACT_PRIO_ASYNC)
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
diff --git a/mm/internal.h b/mm/internal.h
index cdb33c957906..1b7a89a9a9d7 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -189,6 +189,7 @@ struct compact_control {
 	bool whole_zone;		/* Whole zone should/has been scanned */
 	bool contended;			/* Signal lock or sched contention */
 	bool finishing_block;		/* Finishing current pageblock */
+	bool prevent_fallback;		/* Stealing migratetypes not allowed */
 };
 
 unsigned long
@@ -467,6 +468,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
 #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
+#define ALLOC_FALLBACK		0x100 /* allow fallback of migratetype */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d9ba640a12d..5270be8325fd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2197,7 +2197,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
  * Call me with the zone->lock already held.
  */
 static struct page *__rmqueue(struct zone *zone, unsigned int order,
-				int migratetype)
+				int migratetype, bool allow_fallback)
 {
 	struct page *page;
 
@@ -2207,7 +2207,8 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 		if (migratetype == MIGRATE_MOVABLE)
 			page = __rmqueue_cma_fallback(zone, order);
 
-		if (!page && __rmqueue_fallback(zone, order, migratetype))
+		if (!page && allow_fallback &&
+				__rmqueue_fallback(zone, order, migratetype))
 			goto retry;
 	}
 
@@ -2228,7 +2229,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
-		struct page *page = __rmqueue(zone, order, migratetype);
+		struct page *page = __rmqueue(zone, order, migratetype, true);
 		if (unlikely(page == NULL))
 			break;
 
@@ -2661,7 +2662,10 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 					trace_mm_page_alloc_zone_locked(page, order, migratetype);
 			}
 			if (!page)
-				page = __rmqueue(zone, order, migratetype);
+				page = __rmqueue(zone, order, migratetype,
+						alloc_flags &
+						(ALLOC_FALLBACK |
+						 ALLOC_NO_WATERMARKS));
 		} while (page && check_new_pages(page, order));
 		spin_unlock(&zone->lock);
 		if (!page)
@@ -3616,6 +3620,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		}
 	}
 
+	/* async direct compaction didn't help, now allow fallback */
+	alloc_flags |= ALLOC_FALLBACK;
+
 retry:
 	/* Ensure kswapd doesn't accidentally go to sleep as long as we loop */
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
