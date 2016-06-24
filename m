Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC14828E4
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:55:24 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so72910408lfg.2
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 02:55:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ll9si6090107wjb.43.2016.06.24.02.55.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 02:55:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 12/17] mm, compaction: more reliably increase direct compaction priority
Date: Fri, 24 Jun 2016 11:54:32 +0200
Message-Id: <20160624095437.16385-13-vbabka@suse.cz>
In-Reply-To: <20160624095437.16385-1-vbabka@suse.cz>
References: <20160624095437.16385-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

During reclaim/compaction loop, compaction priority can be increased by the
should_compact_retry() function, but the current code is not optimal. Priority
is only increased when compaction_failed() is true, which means that compaction
has scanned the whole zone. This may not happen even after multiple attempts
with the lower priority due to parallel activity, so we might needlessly
struggle on the lower priority and possibly run out of compaction retry
attempts in the process.

We can remove these corner cases by increasing compaction priority regardless
of compaction_failed(). Examining further the compaction result can be
postponed only after reaching the highest priority. This is a simple solution
and we don't need to worry about reaching the highest priority "too soon" here,
because hen should_compact_retry() is called it means that the system is
already struggling and the allocation is supposed to either try as hard as
possible, or it cannot fail at all. There's not much point staying at lower
priorities with heuristics that may result in only partial compaction.
Also we now count compaction retries only after reaching the highest priority.

The only exception here is the COMPACT_SKIPPED result, which means that
compaction could not run at all due to being below order-0 watermarks. In that
case, don't increase compaction priority, and check if compaction could proceed
when everything reclaimable was reclaimed. Before this patch, this was tied to
compaction_withdrawn(), but the other results considered there are in fact only
possible due to low compaction priority so we can ignore them thanks to the
patch. Since there are no other callers of compaction_withdrawn(), change its
semantics to remove the low priority scenarios.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/compaction.h | 28 ++-----------------------
 mm/page_alloc.c            | 51 ++++++++++++++++++++++++++--------------------
 2 files changed, 31 insertions(+), 48 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 869b594cf4ff..a6b3d5d2ae53 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -106,8 +106,8 @@ static inline bool compaction_failed(enum compact_result result)
 }
 
 /*
- * Compaction  has backed off for some reason. It might be throttling or
- * lock contention. Retrying is still worthwhile.
+ * Compaction has backed off because it cannot proceed until there is enough
+ * free memory. Retrying is still worthwhile after reclaim.
  */
 static inline bool compaction_withdrawn(enum compact_result result)
 {
@@ -118,30 +118,6 @@ static inline bool compaction_withdrawn(enum compact_result result)
 	if (result == COMPACT_SKIPPED)
 		return true;
 
-	/*
-	 * If compaction is deferred for high-order allocations, it is
-	 * because sync compaction recently failed. If this is the case
-	 * and the caller requested a THP allocation, we do not want
-	 * to heavily disrupt the system, so we fail the allocation
-	 * instead of entering direct reclaim.
-	 */
-	if (result == COMPACT_DEFERRED)
-		return true;
-
-	/*
-	 * If compaction in async mode encounters contention or blocks higher
-	 * priority task we back off early rather than cause stalls.
-	 */
-	if (result == COMPACT_CONTENDED)
-		return true;
-
-	/*
-	 * Page scanners have met but we haven't scanned full zones so this
-	 * is a back off in fact.
-	 */
-	if (result == COMPACT_PARTIAL_SKIPPED)
-		return true;
-
 	return false;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 204cc988fd64..e1efdc8d2a52 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3217,7 +3217,7 @@ static inline bool
 should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 		     enum compact_result compact_result,
 		     enum compact_priority *compact_priority,
-		     int compaction_retries)
+		     int *compaction_retries)
 {
 	int max_retries = MAX_COMPACT_RETRIES;
 
@@ -3225,28 +3225,35 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 		return false;
 
 	/*
-	 * compaction considers all the zone as desperately out of memory
-	 * so it doesn't really make much sense to retry except when the
-	 * failure could be caused by insufficient priority
+	 * Compaction backed off due to watermark checks for order-0
+	 * so the regular reclaim has to try harder and reclaim something
+	 * Retry only if it looks like reclaim might have a chance.
 	 */
-	if (compaction_failed(compact_result)) {
-		if (*compact_priority > MIN_COMPACT_PRIORITY) {
-			(*compact_priority)--;
-			return true;
-		}
-		return false;
+	if (compaction_withdrawn(compact_result))
+		return compaction_zonelist_suitable(ac, order, alloc_flags);
+
+	/*
+	 * Compaction could have withdrawn early or skip some zones or
+	 * pageblocks. We were asked to retry, which means the allocation
+	 * should try really hard, so increase the priority if possible.
+	 */
+	if (*compact_priority > MIN_COMPACT_PRIORITY) {
+		(*compact_priority)--;
+		return true;
 	}
 
 	/*
-	 * make sure the compaction wasn't deferred or didn't bail out early
-	 * due to locks contention before we declare that we should give up.
-	 * But do not retry if the given zonelist is not suitable for
-	 * compaction.
+	 * Compaction considers all the zones as unfixably fragmented and we
+	 * are on the highest priority, which means it can't be due to
+	 * heuristics and it doesn't really make much sense to retry.
 	 */
-	if (compaction_withdrawn(compact_result))
-		return compaction_zonelist_suitable(ac, order, alloc_flags);
+	if (compaction_failed(compact_result))
+		return false;
 
 	/*
+	 * The remaining possibility is that compaction made progress and
+	 * created a high-order page, but it was allocated by somebody else.
+	 * To prevent thrashing, limit the number of retries in such case.
 	 * !costly requests are much more important than __GFP_REPEAT
 	 * costly ones because they are de facto nofail and invoke OOM
 	 * killer to move on while costly can fail and users are ready
@@ -3254,9 +3261,12 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	 * would need much more detailed feedback from compaction to
 	 * make a better decision.
 	 */
+	if (compaction_made_progress(compact_result))
+		(*compaction_retries)++;
+
 	if (order > PAGE_ALLOC_COSTLY_ORDER)
 		max_retries /= 4;
-	if (compaction_retries <= max_retries)
+	if (*compaction_retries <= max_retries)
 		return true;
 
 	return false;
@@ -3275,7 +3285,7 @@ static inline bool
 should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_flags,
 		     enum compact_result compact_result,
 		     enum compact_priority *compact_priority,
-		     int compaction_retries)
+		     int *compaction_retries)
 {
 	struct zone *zone;
 	struct zoneref *z;
@@ -3672,9 +3682,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto got_pg;
 
-	if (order && compaction_made_progress(compact_result))
-		compaction_retries++;
-
 	/* Do not loop if specifically requested */
 	if (gfp_mask & __GFP_NORETRY)
 		goto nopage;
@@ -3709,7 +3716,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (did_some_progress > 0 &&
 			should_compact_retry(ac, order, alloc_flags,
 				compact_result, &compact_priority,
-				compaction_retries))
+				&compaction_retries))
 		goto retry;
 
 	/* Reclaim has failed us, start killing things */
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
