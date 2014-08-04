Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6C37C6B005A
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 04:56:17 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so7264374wgh.27
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 01:56:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cy3si19369588wib.92.2014.08.04.01.56.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 01:56:08 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 03/13] mm, compaction: do not count compact_stall if all zones skipped compaction
Date: Mon,  4 Aug 2014 10:55:14 +0200
Message-Id: <1407142524-2025-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
References: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

The compact_stall vmstat counter counts the number of allocations stalled by
direct compaction. It does not count when all attempted zones had deferred
compaction, but it does count when all zones skipped compaction. The skipping
is decided based on very early check of compaction_suitable(), based on
watermarks and memory fragmentation. Therefore it makes sense not to count
skipped compactions as stalls. Moreover, compact_success or compact_fail is
also already not being counted when compaction was skipped, so this patch
changes the compact_stall counting to match the other two.

Additionally, restructure __alloc_pages_direct_compact() code for better
readability.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 76 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 41 insertions(+), 35 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e8affbf..f1586bc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2300,7 +2300,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 {
 	struct zone *last_compact_zone = NULL;
 	unsigned long compact_result;
-
+	struct page *page;
 
 	if (!order)
 		return NULL;
@@ -2312,49 +2312,55 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 						&last_compact_zone);
 	current->flags &= ~PF_MEMALLOC;
 
-	if (compact_result > COMPACT_DEFERRED)
-		count_vm_event(COMPACTSTALL);
-	else
+	switch (compact_result) {
+	case COMPACT_DEFERRED:
 		*deferred_compaction = true;
+		/* fall-through */
+	case COMPACT_SKIPPED:
+		return NULL;
+	default:
+		break;
+	}
 
-	if (compact_result > COMPACT_SKIPPED) {
-		struct page *page;
+	/*
+	 * At least in one zone compaction wasn't deferred or skipped, so let's
+	 * count a compaction stall
+	 */
+	count_vm_event(COMPACTSTALL);
 
-		/* Page migration frees to the PCP lists but we want merging */
-		drain_pages(get_cpu());
-		put_cpu();
+	/* Page migration frees to the PCP lists but we want merging */
+	drain_pages(get_cpu());
+	put_cpu();
 
-		page = get_page_from_freelist(gfp_mask, nodemask,
-				order, zonelist, high_zoneidx,
-				alloc_flags & ~ALLOC_NO_WATERMARKS,
-				preferred_zone, classzone_idx, migratetype);
+	page = get_page_from_freelist(gfp_mask, nodemask,
+			order, zonelist, high_zoneidx,
+			alloc_flags & ~ALLOC_NO_WATERMARKS,
+			preferred_zone, classzone_idx, migratetype);
 
-		if (page) {
-			struct zone *zone = page_zone(page);
+	if (page) {
+		struct zone *zone = page_zone(page);
 
-			zone->compact_blockskip_flush = false;
-			compaction_defer_reset(zone, order, true);
-			count_vm_event(COMPACTSUCCESS);
-			return page;
-		}
+		zone->compact_blockskip_flush = false;
+		compaction_defer_reset(zone, order, true);
+		count_vm_event(COMPACTSUCCESS);
+		return page;
+	}
 
-		/*
-		 * last_compact_zone is where try_to_compact_pages thought
-		 * allocation should succeed, so it did not defer compaction.
-		 * But now we know that it didn't succeed, so we do the defer.
-		 */
-		if (last_compact_zone && mode != MIGRATE_ASYNC)
-			defer_compaction(last_compact_zone, order);
+	/*
+	 * last_compact_zone is where try_to_compact_pages thought allocation
+	 * should succeed, so it did not defer compaction. But here we know
+	 * that it didn't succeed, so we do the defer.
+	 */
+	if (last_compact_zone && mode != MIGRATE_ASYNC)
+		defer_compaction(last_compact_zone, order);
 
-		/*
-		 * It's bad if compaction run occurs and fails.
-		 * The most likely reason is that pages exist,
-		 * but not enough to satisfy watermarks.
-		 */
-		count_vm_event(COMPACTFAIL);
+	/*
+	 * It's bad if compaction run occurs and fails. The most likely reason
+	 * is that pages exist, but not enough to satisfy watermarks.
+	 */
+	count_vm_event(COMPACTFAIL);
 
-		cond_resched();
-	}
+	cond_resched();
 
 	return NULL;
 }
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
