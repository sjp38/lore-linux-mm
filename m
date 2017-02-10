Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8D86B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:23:53 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t18so12825354wmt.7
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:23:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c26si2940724wrb.192.2017.02.10.09.23.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 09:23:51 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 07/10] mm, compaction: restrict async compaction to pageblocks of same migratetype
Date: Fri, 10 Feb 2017 18:23:40 +0100
Message-Id: <20170210172343.30283-8-vbabka@suse.cz>
In-Reply-To: <20170210172343.30283-1-vbabka@suse.cz>
References: <20170210172343.30283-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

The migrate scanner in async compaction is currently limited to MIGRATE_MOVABLE
pageblocks. This is a heuristic intended to reduce latency, based on the
assumption that non-MOVABLE pageblocks are unlikely to contain movable pages.

However, with the exception of THP's, most high-order allocations are not
movable. Should the async compaction succeed, this increases the chance that
the non-MOVABLE allocations will fallback to a MOVABLE pageblock, making the
long-term fragmentation worse.

This patch attempts to help the situation by changing async direct compaction
so that the migrate scanner only scans the pageblocks of the requested
migratetype. If it's a non-MOVABLE type and there are such pageblocks that do
contain movable pages, chances are that the allocation can succeed within one
of such pageblocks, removing the need for a fallback. If that fails, the
subsequent sync attempt will ignore this restriction.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 11 +++++++++--
 mm/page_alloc.c | 20 +++++++++++++-------
 2 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index b7094700712b..84ef44c3b1c9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -994,10 +994,17 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 static bool suitable_migration_source(struct compact_control *cc,
 							struct page *page)
 {
-	if (cc->mode != MIGRATE_ASYNC)
+	int block_mt;
+
+	if ((cc->mode != MIGRATE_ASYNC) || !cc->direct_compaction)
 		return true;
 
-	return is_migrate_movable(get_pageblock_migratetype(page));
+	block_mt = get_pageblock_migratetype(page);
+
+	if (cc->migratetype == MIGRATE_MOVABLE)
+		return is_migrate_movable(block_mt);
+	else
+		return block_mt == cc->migratetype;
 }
 
 /* Returns true if the page is within a block suitable for migration to */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a7d33818610f..6d9ba640a12d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3523,6 +3523,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
 {
 	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
+	const bool costly_order = order > PAGE_ALLOC_COSTLY_ORDER;
 	struct page *page = NULL;
 	unsigned int alloc_flags;
 	unsigned long did_some_progress;
@@ -3572,12 +3573,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 	/*
 	 * For costly allocations, try direct compaction first, as it's likely
-	 * that we have enough base pages and don't need to reclaim. Don't try
-	 * that for allocations that are allowed to ignore watermarks, as the
-	 * ALLOC_NO_WATERMARKS attempt didn't yet happen.
+	 * that we have enough base pages and don't need to reclaim. For non-
+	 * movable high-order allocations, do that as well, as compaction will
+	 * try prevent permanent fragmentation by migrating from blocks of the
+	 * same migratetype.
+	 * Don't try this for allocations that are allowed to ignore
+	 * watermarks, as the ALLOC_NO_WATERMARKS attempt didn't yet happen.
 	 */
-	if (can_direct_reclaim && order > PAGE_ALLOC_COSTLY_ORDER &&
-		!gfp_pfmemalloc_allowed(gfp_mask)) {
+	if (can_direct_reclaim &&
+			(costly_order ||
+			   (order > 0 && ac->migratetype != MIGRATE_MOVABLE))
+			&& !gfp_pfmemalloc_allowed(gfp_mask)) {
 		page = __alloc_pages_direct_compact(gfp_mask, order,
 						alloc_flags, ac,
 						INIT_COMPACT_PRIORITY,
@@ -3589,7 +3595,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * Checks for costly allocations with __GFP_NORETRY, which
 		 * includes THP page fault allocations
 		 */
-		if (gfp_mask & __GFP_NORETRY) {
+		if (costly_order && (gfp_mask & __GFP_NORETRY)) {
 			/*
 			 * If compaction is deferred for high-order allocations,
 			 * it is because sync compaction recently failed. If
@@ -3684,7 +3690,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * Do not retry costly high order allocations unless they are
 	 * __GFP_REPEAT
 	 */
-	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
+	if (costly_order && !(gfp_mask & __GFP_REPEAT))
 		goto nopage;
 
 	/* Make sure we know about allocations which stall for too long */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
