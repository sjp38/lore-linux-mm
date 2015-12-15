Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id CDDED6B0259
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 13:20:14 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id n186so177498336wmn.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 10:20:14 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id v195si6070829wmv.20.2015.12.15.10.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 10:20:10 -0800 (PST)
Received: by mail-wm0-f52.google.com with SMTP id n186so177495863wmn.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 10:20:10 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] mm: use watermak checks for __GFP_REPEAT high order allocations
Date: Tue, 15 Dec 2015 19:19:46 +0100
Message-Id: <1450203586-10959-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__alloc_pages_slowpath retries costly allocations until at least
order worth of pages were reclaimed or the watermark check for at least
one zone would succeed after all reclaiming all pages if the reclaim
hasn't made any progress.

The first condition was added by a41f24ea9fd6 ("page allocator: smarter
retry of costly-order allocations) and it assumed that lumpy reclaim
could have created a page of the sufficient order. Lumpy reclaim,
has been removed quite some time ago so the assumption doesn't hold
anymore. It would be more appropriate to check the compaction progress
instead but this patch simply removes the check and relies solely
on the watermark check.

To prevent from too many retries the no_progress_loops is not reseted after
a reclaim which made progress because we cannot assume it helped high
order situation. Only costly allocation requests depended on
pages_reclaimed so we can drop it.

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 34 +++++++++++++++-------------------
 1 file changed, 15 insertions(+), 19 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b2de8c8761ad..268de1654128 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2994,17 +2994,17 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
  * Checks whether it makes sense to retry the reclaim to make a forward progress
  * for the given allocation request.
  * The reclaim feedback represented by did_some_progress (any progress during
- * the last reclaim round), pages_reclaimed (cumulative number of reclaimed
- * pages) and no_progress_loops (number of reclaim rounds without any progress
- * in a row) is considered as well as the reclaimable pages on the applicable
- * zone list (with a backoff mechanism which is a function of no_progress_loops).
+ * the last reclaim round) and no_progress_loops (number of reclaim rounds without
+ * any progress in a row) is considered as well as the reclaimable pages on the
+ * applicable zone list (with a backoff mechanism which is a function of
+ * no_progress_loops).
  *
  * Returns true if a retry is viable or false to enter the oom path.
  */
 static inline bool
 should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		     struct alloc_context *ac, int alloc_flags,
-		     bool did_some_progress, unsigned long pages_reclaimed,
+		     bool did_some_progress,
 		     int no_progress_loops)
 {
 	struct zone *zone;
@@ -3018,13 +3018,8 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		return false;
 
 	/* Do not retry high order allocations unless they are __GFP_REPEAT */
-	if (order > PAGE_ALLOC_COSTLY_ORDER) {
-		if (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order))
-			return false;
-
-		if (did_some_progress)
-			return true;
-	}
+	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
+		return false;
 
 	/*
 	 * Keep reclaiming pages while there is a chance this will lead somewhere.
@@ -3090,7 +3085,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
 	struct page *page = NULL;
 	int alloc_flags;
-	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
@@ -3255,16 +3249,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_NORETRY)
 		goto noretry;
 
-	if (did_some_progress) {
+	/*
+	 * Costly allocations might have made a progress but this doesn't mean
+	 * their order will become available due to high fragmentation so do
+	 * not reset the no progress counter for them
+	 */
+	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
 		no_progress_loops = 0;
-		pages_reclaimed += did_some_progress;
-	} else {
+	else
 		no_progress_loops++;
-	}
 
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
-				 did_some_progress > 0, pages_reclaimed,
-				 no_progress_loops))
+				 did_some_progress > 0, no_progress_loops))
 		goto retry;
 
 	/* Reclaim has failed us, start killing things */
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
