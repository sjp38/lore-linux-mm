Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 971D86B0269
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:37:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so6414395wme.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:37:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ks9si1044082wjb.15.2016.05.10.00.37.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 00:37:09 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 12/13] mm, compaction: more reliably increase direct compaction priority
Date: Tue, 10 May 2016 09:36:02 +0200
Message-Id: <1462865763-22084-13-git-send-email-vbabka@suse.cz>
In-Reply-To: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

During reclaim/compaction loop, compaction priority can be increased by the
should_compact_retry() function, but the current code is not optimal for
several reasons:

- priority is only increased when compaction_failed() is true, which means
  that compaction has scanned the whole zone. This may not happen even after
  multiple attempts with the lower priority due to parallel activity, so we
  might needlessly struggle on the lower priority.

- should_compact_retry() is only called when should_reclaim_retry() returns
  false. This means that compaction priority cannot get increased as long
  as reclaim makes sufficient progress. Theoretically, reclaim should stop
  retrying for high-order allocations as long as the high-order page doesn't
  exist but due to races, this may result in spurious retries when the
  high-order page momentarily does exist.

We can remove these corner cases by making sure that should_compact_retry() is
always called, and increases compaction priority if possible. Examining further
the compaction result can be done only after reaching the highest priority.
This is a simple solution and we don't need to worry about reaching the highest
priority "too soon" here - when should_compact_retry() is called it means that
the system is already struggling and the allocation is supposed to either try
as hard as possible, or it cannot fail at all. There's not much point staying
at lower priorities with heuristics that may result in only partial compaction.

The only exception here is the COMPACT_SKIPPED result, which means that
compaction could not run at all due to failing order-0 watermarks. In that
case, don't increase compaction priority, and check if compaction could proceed
when everything reclaimable was reclaimed. Before this patch, this was tied to
compaction_withdrawn(), but the other results considered there are in fact only
due to low compaction priority so we can ignore them thanks to the patch.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index aa9c39a7f40a..623027fb8121 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3248,28 +3248,27 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
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
-		if (*compact_priority > 0) {
-			(*compact_priority)--;
-			return true;
-		}
-		return false;
-	}
+	if (compact_result == COMPACT_SKIPPED)
+		return compaction_zonelist_suitable(ac, order, alloc_flags);
 
 	/*
-	 * make sure the compaction wasn't deferred or didn't bail out early
-	 * due to locks contention before we declare that we should give up.
-	 * But do not retry if the given zonelist is not suitable for
-	 * compaction.
+	 * Compaction could have withdrawn early or skip some zones or
+	 * pageblocks. We were asked to retry, which means the allocation
+	 * should try really hard, so increase the priority if possible.
 	 */
-	if (compaction_withdrawn(compact_result))
-		return compaction_zonelist_suitable(ac, order, alloc_flags);
+	if (*compact_priority > 0) {
+		(*compact_priority)--;
+		return true;
+	}
 
 	/*
+	 * The remaining possibility is that compaction made progress and
+	 * created a high-order page, but it was allocated by somebody else.
+	 * To prevent thrashing, limit the number of retries in such case.
 	 * !costly requests are much more important than __GFP_REPEAT
 	 * costly ones because they are de facto nofail and invoke OOM
 	 * killer to move on while costly can fail and users are ready
@@ -3527,6 +3526,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
 {
 	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
+	bool should_retry;
 	struct page *page = NULL;
 	unsigned int alloc_flags;
 	unsigned long did_some_progress;
@@ -3695,22 +3695,22 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	else
 		no_progress_loops++;
 
-	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
-				 did_some_progress > 0, no_progress_loops))
-		goto retry;
-
+	should_retry = should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
+				 did_some_progress > 0, no_progress_loops);
 	/*
 	 * It doesn't make any sense to retry for the compaction if the order-0
 	 * reclaim is not able to make any progress because the current
 	 * implementation of the compaction depends on the sufficient amount
 	 * of free memory (see __compaction_suitable)
 	 */
-	if (did_some_progress > 0 &&
-			should_compact_retry(ac, order, alloc_flags,
+	if (did_some_progress > 0)
+		should_retry |= should_compact_retry(ac, order, alloc_flags,
 				compact_result, &compact_priority,
-				compaction_retries))
+				compaction_retries);
+	if (should_retry)
 		goto retry;
 
+
 	/* Reclaim has failed us, start killing things */
 	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
 	if (page)
-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
