Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 4C4DD6B0088
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:36:59 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 18/34] mm: page allocator: Do not call direct reclaim for THP allocations while compaction is deferred
Date: Thu, 19 Jul 2012 15:36:28 +0100
Message-Id: <1342708604-26540-19-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit 66199712e9eef5aede09dbcd9dfff87798a66917 upstream.

Stable note: Not tracked in Buzilla. This was part of a series that
	reduced interactivity stalls experienced when THP was enabled.

If compaction is deferred, direct reclaim is used to try free enough
pages for the allocation to succeed. For small high-orders, this has
a reasonable chance of success. However, if the caller has specified
__GFP_NO_KSWAPD to limit the disruption to the system, it makes more
sense to fail the allocation rather than stall the caller in direct
reclaim. This patch skips direct reclaim if compaction is deferred
and the caller specifies __GFP_NO_KSWAPD.

Async compaction only considers a subset of pages so it is possible for
compaction to be deferred prematurely and not enter direct reclaim even
in cases where it should. To compensate for this, this patch also defers
compaction only if sync compaction failed.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Rik van Riel<riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andy Isaacson <adi@hexapodia.org>
Cc: Nai Xia <nai.xia@gmail.com>
Cc: Johannes Weiner <jweiner@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 mm/page_alloc.c |   45 +++++++++++++++++++++++++++++++++++----------
 1 file changed, 35 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e568b80..257acae 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1897,14 +1897,20 @@ static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, unsigned long *did_some_progress,
-	bool sync_migration)
+	int migratetype, bool sync_migration,
+	bool *deferred_compaction,
+	unsigned long *did_some_progress)
 {
 	struct page *page;
 
-	if (!order || compaction_deferred(preferred_zone))
+	if (!order)
 		return NULL;
 
+	if (compaction_deferred(preferred_zone)) {
+		*deferred_compaction = true;
+		return NULL;
+	}
+
 	current->flags |= PF_MEMALLOC;
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
 						nodemask, sync_migration);
@@ -1932,7 +1938,13 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		 * but not enough to satisfy watermarks.
 		 */
 		count_vm_event(COMPACTFAIL);
-		defer_compaction(preferred_zone);
+
+		/*
+		 * As async compaction considers a subset of pageblocks, only
+		 * defer if the failure was a sync compaction failure.
+		 */
+		if (sync_migration)
+			defer_compaction(preferred_zone);
 
 		cond_resched();
 	}
@@ -1944,8 +1956,9 @@ static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, unsigned long *did_some_progress,
-	bool sync_migration)
+	int migratetype, bool sync_migration,
+	bool *deferred_compaction,
+	unsigned long *did_some_progress)
 {
 	return NULL;
 }
@@ -2095,6 +2108,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
 	bool sync_migration = false;
+	bool deferred_compaction = false;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -2175,12 +2189,22 @@ rebalance:
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, &did_some_progress,
-					sync_migration);
+					migratetype, sync_migration,
+					&deferred_compaction,
+					&did_some_progress);
 	if (page)
 		goto got_pg;
 	sync_migration = true;
 
+	/*
+	 * If compaction is deferred for high-order allocations, it is because
+	 * sync compaction recently failed. In this is the case and the caller
+	 * has requested the system not be heavily disrupted, fail the
+	 * allocation now instead of entering direct reclaim
+	 */
+	if (deferred_compaction && (gfp_mask & __GFP_NO_KSWAPD))
+		goto nopage;
+
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
 					zonelist, high_zoneidx,
@@ -2243,8 +2267,9 @@ rebalance:
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, &did_some_progress,
-					sync_migration);
+					migratetype, sync_migration,
+					&deferred_compaction,
+					&did_some_progress);
 		if (page)
 			goto got_pg;
 	}
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
