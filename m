Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1496B008C
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 13:37:00 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 6/7] mm: page allocator: Limit when direct reclaim is used when compaction is deferred
Date: Mon, 21 Nov 2011 18:36:47 +0000
Message-Id: <1321900608-27687-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1321900608-27687-1-git-send-email-mgorman@suse.de>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, LKML <linux-kernel@vger.kernel.org>

If compaction is deferred, we enter direct reclaim to try reclaim the
pages that way. For small high-orders, this has a reasonable chance
of success. However, if the caller as specified __GFP_NO_KSWAPD to
limit the disruption to the system, it makes more sense to fail the
allocation rather than stall the caller in direct reclaim. This patch
will skip direct reclaim if compaction is deferred and the caller
specifies __GFP_NO_KSWAPD.

Async compaction only considers a subset of pages so it is possible for
compaction to be deferred prematurely and not enter direct reclaim even
in cases where it should. To compensate for this, this patch also defers
compaction only if sync compaction failed.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |   45 +++++++++++++++++++++++++++++++++++----------
 1 files changed, 35 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..d979376 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1886,14 +1886,20 @@ static struct page *
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
@@ -1921,7 +1927,13 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
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
@@ -1933,8 +1945,9 @@ static inline struct page *
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
@@ -2084,6 +2097,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
 	bool sync_migration = false;
+	bool deferred_compaction = false;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -2164,12 +2178,22 @@ rebalance:
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
@@ -2232,8 +2256,9 @@ rebalance:
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
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
