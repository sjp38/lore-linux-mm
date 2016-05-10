Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D53F6B025F
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:37:20 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so3935979lfc.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:37:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kb10si979528wjc.225.2016.05.10.00.37.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 00:37:07 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 04/13] mm, page_alloc: restructure direct compaction handling in slowpath
Date: Tue, 10 May 2016 09:35:54 +0200
Message-Id: <1462865763-22084-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

The retry loop in __alloc_pages_slowpath is supposed to keep trying reclaim
and compaction (and OOM), until either the allocation succeeds, or returns
with failure. Success here is more probable when reclaim precedes compaction,
as certain watermarks have to be met for compaction to even try, and more free
pages increase the probability of compaction success. On the other hand,
starting with light async compaction (if the watermarks allow it), can be
more efficient, especially for smaller orders, if there's enough free memory
which is just fragmented.

Thus, the current code starts with compaction before reclaim, and to make sure
that the last reclaim is always followed by a final compaction, there's another
direct compaction call at the end of the loop. This makes the code hard to
follow and adds some duplicated handling of migration_mode decisions. It's also
somewhat inefficient that even if reclaim or compaction decides not to retry,
the final compaction is still attempted. Some gfp flags combination also
shortcut these retry decisions by "goto noretry;", making it even harder to
follow.

This patch attempts to restructure the code with only minimal functional
changes. The call to the first compaction and THP-specific checks are now
placed above the retry loop, and the "noretry" direct compaction is removed.

The initial compaction is additionally restricted only to costly orders, as we
can expect smaller orders to be held back by watermarks, and only larger orders
to suffer primarily from fragmentation. This better matches the checks in
reclaim's shrink_zones().

There are two other smaller functional changes. One is that the upgrade from
async migration to light sync migration will always occur after the initial
compaction. This is how it has been until recent patch "mm, oom: protect
!costly allocations some more", which introduced upgrading the mode based on
COMPACT_COMPLETE result, but kept the final compaction always upgraded, which
made it even more special. It's better to return to the simpler handling for
now, as migration modes will be further modified later in the series.

The second change is that once both reclaim and compaction declare it's not
worth to retry the reclaim/compact loop, there is no final compaction attempt.
As argued above, this is intentional. If that final compaction were to succeed,
it would be due to a wrong retry decision, or simply a race with somebody else
freeing memory for us.

The main outcome of this patch should be simpler code. Logically, the initial
compaction without reclaim is the exceptional case to the reclaim/compaction
scheme, but prior to the patch, it was the last loop iteration that was
exceptional. Now the code matches the logic better. The change also enable the
following patches.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 107 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 55 insertions(+), 52 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7249949d65ca..88d680b3e7b6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3555,7 +3555,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct page *page = NULL;
 	unsigned int alloc_flags;
 	unsigned long did_some_progress;
-	enum migrate_mode migration_mode = MIGRATE_ASYNC;
+	enum migrate_mode migration_mode = MIGRATE_SYNC_LIGHT;
 	enum compact_result compact_result;
 	int compaction_retries = 0;
 	int no_progress_loops = 0;
@@ -3598,6 +3598,50 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto got_pg;
 
+	/*
+	 * For costly allocations, try direct compaction first, as it's likely
+	 * that we have enough base pages and don't need to reclaim.
+	 */
+	if (can_direct_reclaim && order > PAGE_ALLOC_COSTLY_ORDER) {
+		page = __alloc_pages_direct_compact(gfp_mask, order,
+						alloc_flags, ac,
+						MIGRATE_ASYNC,
+						&compact_result);
+		if (page)
+			goto got_pg;
+
+		/* Checks for THP-specific high-order allocations */
+		if (is_thp_gfp_mask(gfp_mask)) {
+			/*
+			 * If compaction is deferred for high-order allocations,
+			 * it is because sync compaction recently failed. If
+			 * this is the case and the caller requested a THP
+			 * allocation, we do not want to heavily disrupt the
+			 * system, so we fail the allocation instead of entering
+			 * direct reclaim.
+			 */
+			if (compact_result == COMPACT_DEFERRED)
+				goto nopage;
+
+			/*
+			 * Compaction is contended so rather back off than cause
+			 * excessive stalls.
+			 */
+			if (compact_result == COMPACT_CONTENDED)
+				goto nopage;
+
+			/*
+			 * It can become very expensive to allocate transparent
+			 * hugepages at fault, so use asynchronous memory
+			 * compaction for THP unless it is khugepaged trying to
+			 * collapse. All other requests should tolerate at
+			 * least light sync migration.
+			 */
+			if (!(current->flags & PF_KTHREAD))
+				migration_mode = MIGRATE_ASYNC;
+		}
+	}
+
 retry:
 	/* Ensure kswapd doesn't accidentaly go to sleep as long as we loop */
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
@@ -3646,55 +3690,33 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
 		goto nopage;
 
-	/*
-	 * Try direct compaction. The first pass is asynchronous. Subsequent
-	 * attempts after direct reclaim are synchronous
-	 */
+
+	/* Try direct reclaim and then allocating */
+	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
+							&did_some_progress);
+	if (page)
+		goto got_pg;
+
+	/* Try direct compaction and then allocating */
 	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
 					migration_mode,
 					&compact_result);
 	if (page)
 		goto got_pg;
 
-	/* Checks for THP-specific high-order allocations */
-	if (is_thp_gfp_mask(gfp_mask)) {
-		/*
-		 * If compaction is deferred for high-order allocations, it is
-		 * because sync compaction recently failed. If this is the case
-		 * and the caller requested a THP allocation, we do not want
-		 * to heavily disrupt the system, so we fail the allocation
-		 * instead of entering direct reclaim.
-		 */
-		if (compact_result == COMPACT_DEFERRED)
-			goto nopage;
-
-		/*
-		 * Compaction is contended so rather back off than cause
-		 * excessive stalls.
-		 */
-		if(compact_result == COMPACT_CONTENDED)
-			goto nopage;
-	}
-
 	if (order && compaction_made_progress(compact_result))
 		compaction_retries++;
 
-	/* Try direct reclaim and then allocating */
-	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
-							&did_some_progress);
-	if (page)
-		goto got_pg;
-
 	/* Do not loop if specifically requested */
 	if (gfp_mask & __GFP_NORETRY)
-		goto noretry;
+		goto nopage;
 
 	/*
 	 * Do not retry costly high order allocations unless they are
 	 * __GFP_REPEAT
 	 */
 	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
-		goto noretry;
+		goto nopage;
 
 	/*
 	 * Costly allocations might have made a progress but this doesn't mean
@@ -3733,25 +3755,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto retry;
 	}
 
-noretry:
-	/*
-	 * High-order allocations do not necessarily loop after direct reclaim
-	 * and reclaim/compaction depends on compaction being called after
-	 * reclaim so call directly if necessary.
-	 * It can become very expensive to allocate transparent hugepages at
-	 * fault, so use asynchronous memory compaction for THP unless it is
-	 * khugepaged trying to collapse. All other requests should tolerate
-	 * at least light sync migration.
-	 */
-	if (is_thp_gfp_mask(gfp_mask) && !(current->flags & PF_KTHREAD))
-		migration_mode = MIGRATE_ASYNC;
-	else
-		migration_mode = MIGRATE_SYNC_LIGHT;
-	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags,
-					    ac, migration_mode,
-					    &compact_result);
-	if (page)
-		goto got_pg;
 nopage:
 	warn_alloc_failed(gfp_mask, order, NULL);
 got_pg:
-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
