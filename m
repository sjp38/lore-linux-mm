Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 73EEE6B0075
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:06:49 -0400 (EDT)
Received: by wgen6 with SMTP id n6so126457584wge.3
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:06:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w9si14206388wif.30.2015.04.27.12.06.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 12:06:39 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 7/9] mm: page_alloc: inline should_alloc_retry()
Date: Mon, 27 Apr 2015 15:05:53 -0400
Message-Id: <1430161555-6058-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The should_alloc_retry() function was meant to encapsulate retry
conditions of the allocator slowpath, but there are still checks
remaining in the main function, and much of how the retrying is
performed also depends on the OOM killer progress.  The physical
separation of those conditions make the code hard to follow.

Inline the should_alloc_retry() checks.  Notes:

- The __GFP_NOFAIL check is already done in __alloc_pages_may_oom(),
  replace it with looping on OOM killer progress

- The pm_suspended_storage() check is meant to skip the OOM killer
  when reclaim has no IO available, move to __alloc_pages_may_oom()

- The order <= PAGE_ALLOC_COSTLY order is re-united with its original
  counterpart of checking whether reclaim actually made any progress

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/page_alloc.c | 104 +++++++++++++++++---------------------------------------
 1 file changed, 32 insertions(+), 72 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cdb786b..3b4e4f81 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2322,48 +2322,6 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 		show_mem(filter);
 }
 
-static inline int
-should_alloc_retry(gfp_t gfp_mask, unsigned int order,
-				unsigned long did_some_progress,
-				unsigned long pages_reclaimed)
-{
-	/* Do not loop if specifically requested */
-	if (gfp_mask & __GFP_NORETRY)
-		return 0;
-
-	/* Always retry if specifically requested */
-	if (gfp_mask & __GFP_NOFAIL)
-		return 1;
-
-	/*
-	 * Suspend converts GFP_KERNEL to __GFP_WAIT which can prevent reclaim
-	 * making forward progress without invoking OOM. Suspend also disables
-	 * storage devices so kswapd will not help. Bail if we are suspending.
-	 */
-	if (!did_some_progress && pm_suspended_storage())
-		return 0;
-
-	/*
-	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
-	 * means __GFP_NOFAIL, but that may not be true in other
-	 * implementations.
-	 */
-	if (order <= PAGE_ALLOC_COSTLY_ORDER)
-		return 1;
-
-	/*
-	 * For order > PAGE_ALLOC_COSTLY_ORDER, if __GFP_REPEAT is
-	 * specified, then we retry until we no longer reclaim any pages
-	 * (above), or we've reclaimed an order of pages at least as
-	 * large as the allocation's order. In both cases, if the
-	 * allocation still fails, we stop retrying.
-	 */
-	if (gfp_mask & __GFP_REPEAT && pages_reclaimed < (1 << order))
-		return 1;
-
-	return 0;
-}
-
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	const struct alloc_context *ac, unsigned long *did_some_progress)
@@ -2402,16 +2360,18 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		/* The OOM killer does not needlessly kill tasks for lowmem */
 		if (ac->high_zoneidx < ZONE_NORMAL)
 			goto out;
-		/* The OOM killer does not compensate for light reclaim */
+		/* The OOM killer does not compensate for IO-less reclaim */
 		if (!(gfp_mask & __GFP_FS)) {
 			/*
 			 * XXX: Page reclaim didn't yield anything,
 			 * and the OOM killer can't be invoked, but
-			 * keep looping as per should_alloc_retry().
+			 * keep looping as per tradition.
 			 */
 			*did_some_progress = 1;
 			goto out;
 		}
+		if (pm_suspended_storage())
+			goto out;
 		/* The OOM killer may not free memory on a specific node */
 		if (gfp_mask & __GFP_THISNODE)
 			goto out;
@@ -2794,40 +2754,40 @@ retry:
 	if (page)
 		goto got_pg;
 
-	/* Check if we should retry the allocation */
+	/* Do not loop if specifically requested */
+	if (gfp_mask & __GFP_NORETRY)
+		goto noretry;
+
+	/* Keep reclaiming pages as long as there is reasonable progress */
 	pages_reclaimed += did_some_progress;
-	if (should_alloc_retry(gfp_mask, order, did_some_progress,
-						pages_reclaimed)) {
-		/*
-		 * If we fail to make progress by freeing individual
-		 * pages, but the allocation wants us to keep going,
-		 * start OOM killing tasks.
-		 */
-		if (!did_some_progress) {
-			page = __alloc_pages_may_oom(gfp_mask, order, ac,
-							&did_some_progress);
-			if (page)
-				goto got_pg;
-			if (!did_some_progress)
-				goto nopage;
-		}
+	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
+	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto retry;
-	} else {
-		/*
-		 * High-order allocations do not necessarily loop after
-		 * direct reclaim and reclaim/compaction depends on compaction
-		 * being called after reclaim so call directly if necessary
-		 */
-		page = __alloc_pages_direct_compact(gfp_mask, order,
-					alloc_flags, ac, migration_mode,
-					&contended_compaction,
-					&deferred_compaction);
-		if (page)
-			goto got_pg;
 	}
 
+	/* Reclaim has failed us, start killing things */
+	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
+	if (page)
+		goto got_pg;
+
+	/* Retry as long as the OOM killer is making progress */
+	if (did_some_progress)
+		goto retry;
+
+noretry:
+	/*
+	 * High-order allocations do not necessarily loop after
+	 * direct reclaim and reclaim/compaction depends on compaction
+	 * being called after reclaim so call directly if necessary
+	 */
+	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags,
+					    ac, migration_mode,
+					    &contended_compaction,
+					    &deferred_compaction);
+	if (page)
+		goto got_pg;
 nopage:
 	warn_alloc_failed(gfp_mask, order, NULL);
 got_pg:
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
