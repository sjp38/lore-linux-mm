Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB7B36B0392
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:46:34 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id q39so9391434wrb.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:46:34 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z23si4006859wrb.20.2017.02.28.13.46.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 13:46:33 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 9/9] mm: remove unnecessary back-off function when retrying page reclaim
Date: Tue, 28 Feb 2017 16:40:07 -0500
Message-Id: <20170228214007.5621-10-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-1-hannes@cmpxchg.org>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jia He <hejianet@gmail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The backoff mechanism is not needed. If we have MAX_RECLAIM_RETRIES
loops without progress, we'll OOM anyway; backing off might cut one or
two iterations off that in the rare OOM case. If we have intermittent
success reclaiming a few pages, the backoff function gets reset also,
and so is of little help in these scenarios.

We might want a backoff function for when there IS progress, but not
enough to be satisfactory. But this isn't that. Remove it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9ac639864bed..223644afed28 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3511,11 +3511,10 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 /*
  * Checks whether it makes sense to retry the reclaim to make a forward progress
  * for the given allocation request.
- * The reclaim feedback represented by did_some_progress (any progress during
- * the last reclaim round) and no_progress_loops (number of reclaim rounds without
- * any progress in a row) is considered as well as the reclaimable pages on the
- * applicable zone list (with a backoff mechanism which is a function of
- * no_progress_loops).
+ *
+ * We give up when we either have tried MAX_RECLAIM_RETRIES in a row
+ * without success, or when we couldn't even meet the watermark if we
+ * reclaimed all remaining pages on the LRU lists.
  *
  * Returns true if a retry is viable or false to enter the oom path.
  */
@@ -3560,13 +3559,11 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		bool wmark;
 
 		available = reclaimable = zone_reclaimable_pages(zone);
-		available -= DIV_ROUND_UP((*no_progress_loops) * available,
-					  MAX_RECLAIM_RETRIES);
 		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
 
 		/*
-		 * Would the allocation succeed if we reclaimed the whole
-		 * available?
+		 * Would the allocation succeed if we reclaimed all
+		 * reclaimable pages?
 		 */
 		wmark = __zone_watermark_ok(zone, order, min_wmark,
 				ac_classzone_idx(ac), alloc_flags, available);
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
