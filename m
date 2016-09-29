Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36C676B0253
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 17:05:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w72so4195084wmf.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 14:05:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f13si16689711wjz.114.2016.09.29.14.05.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 14:05:57 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 3/4] mm, compaction: restrict async compaction to matching migratetype
Date: Thu, 29 Sep 2016 23:05:47 +0200
Message-Id: <20160929210548.26196-4-vbabka@suse.cz>
In-Reply-To: <20160929210548.26196-1-vbabka@suse.cz>
References: <20160928014148.GA21007@cmpxchg.org>
 <20160929210548.26196-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

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

Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 11 +++++++++--
 mm/page_alloc.c | 20 +++++++++++++-------
 2 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 823538353b80..eb4ccd403543 100644
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
index fab8b6913179..0c00beec9336 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3492,6 +3492,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
 {
 	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
+	const bool costly_order = order > PAGE_ALLOC_COSTLY_ORDER;
 	struct page *page = NULL;
 	unsigned int alloc_flags;
 	unsigned long did_some_progress;
@@ -3539,12 +3540,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
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
@@ -3556,7 +3562,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * Checks for costly allocations with __GFP_NORETRY, which
 		 * includes THP page fault allocations
 		 */
-		if (gfp_mask & __GFP_NORETRY) {
+		if (costly_order && (gfp_mask & __GFP_NORETRY)) {
 			/*
 			 * If compaction is deferred for high-order allocations,
 			 * it is because sync compaction recently failed. If
@@ -3651,7 +3657,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * Do not retry costly high order allocations unless they are
 	 * __GFP_REPEAT
 	 */
-	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
+	if (costly_order && !(gfp_mask & __GFP_REPEAT))
 		goto nopage;
 
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
