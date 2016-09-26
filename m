Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD546B0277
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 12:20:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so89153705wmg.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 09:20:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gy8si20069348wjc.213.2016.09.26.09.20.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 09:20:33 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/4] mm, page_alloc: pull no_progress_loops update to should_reclaim_retry()
Date: Mon, 26 Sep 2016 18:20:23 +0200
Message-Id: <20160926162025.21555-3-vbabka@suse.cz>
In-Reply-To: <20160926162025.21555-1-vbabka@suse.cz>
References: <20160926162025.21555-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>

The should_reclaim_retry() makes decisions based on no_progress_loops, so it
makes sense to also update the counter there. It will be also consistent with
should_compact_retry() and compaction_retries. No functional change.

[hillf.zj@alibaba-inc.com: fix missing pointer dereferences]
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/page_alloc.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0fd29731ab35..8ed4f506ae0b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3404,16 +3404,26 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 static inline bool
 should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		     struct alloc_context *ac, int alloc_flags,
-		     bool did_some_progress, int no_progress_loops)
+		     bool did_some_progress, int *no_progress_loops)
 {
 	struct zone *zone;
 	struct zoneref *z;
 
 	/*
+	 * Costly allocations might have made a progress but this doesn't mean
+	 * their order will become available due to high fragmentation so
+	 * always increment the no progress counter for them
+	 */
+	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
+		*no_progress_loops = 0;
+	else
+		(*no_progress_loops)++;
+
+	/*
 	 * Make sure we converge to OOM if we cannot make any progress
 	 * several times in the row.
 	 */
-	if (no_progress_loops > MAX_RECLAIM_RETRIES)
+	if (*no_progress_loops > MAX_RECLAIM_RETRIES)
 		return false;
 
 	/*
@@ -3428,7 +3438,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		unsigned long reclaimable;
 
 		available = reclaimable = zone_reclaimable_pages(zone);
-		available -= DIV_ROUND_UP(no_progress_loops * available,
+		available -= DIV_ROUND_UP((*no_progress_loops) * available,
 					  MAX_RECLAIM_RETRIES);
 		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
 
@@ -3650,18 +3660,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
 		goto nopage;
 
-	/*
-	 * Costly allocations might have made a progress but this doesn't mean
-	 * their order will become available due to high fragmentation so
-	 * always increment the no progress counter for them
-	 */
-	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
-		no_progress_loops = 0;
-	else
-		no_progress_loops++;
-
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
-				 did_some_progress > 0, no_progress_loops))
+				 did_some_progress > 0, &no_progress_loops))
 		goto retry;
 
 	/*
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
