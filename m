Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD3BA6B0265
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 01:45:40 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k64so11488611itb.5
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 22:45:40 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id r137si1970919itr.96.2016.10.06.22.45.39
        for <linux-mm@kvack.org>;
        Thu, 06 Oct 2016 22:45:40 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 3/4] mm: unreserve highatomic free pages fully before OOM
Date: Fri,  7 Oct 2016 14:45:35 +0900
Message-Id: <1475819136-24358-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1475819136-24358-1-git-send-email-minchan@kernel.org>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Minchan Kim <minchan@kernel.org>

After fixing the race of highatomic page count, I still encounter
OOM with many free memory reserved as highatomic.

One of reason in my testing was we unreserve free pages only if
reclaim has progress. Otherwise, we cannot have chance to unreseve.

Other problem after fixing it was it doesn't guarantee every pages
unreserving of highatomic pageblock because it just release *a*
pageblock which could have few free pages so other context could
steal it easily so that the process stucked with direct reclaim
finally can encounter OOM although there are free pages which can
be unreserved.

This patch changes the logic so that it unreserves pageblocks with
no_progress_loop proportionally. IOW, in first retrial of reclaim,
it will try to unreserve a pageblock. In second retrial of reclaim,
it will try to unreserve 1/MAX_RECLAIM_RETRIES * reserved_pageblock
and finally all reserved pageblock before the OOM.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c | 57 ++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 44 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d110cd640264..eeb047bb0e9d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -71,6 +71,12 @@
 #include <asm/div64.h>
 #include "internal.h"
 
+/*
+ * Maximum number of reclaim retries without any progress before OOM killer
+ * is consider as the only way to move forward.
+ */
+#define MAX_RECLAIM_RETRIES 16
+
 /* prevent >1 _updater_ of zone percpu pageset ->high and ->batch fields */
 static DEFINE_MUTEX(pcp_batch_high_lock);
 #define MIN_PERCPU_PAGELIST_FRACTION	(8)
@@ -2107,7 +2113,8 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
  * intense memory pressure but failed atomic allocations should be easier
  * to recover from than an OOM.
  */
-static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
+static int unreserve_highatomic_pageblock(const struct alloc_context *ac,
+						int no_progress_loops)
 {
 	struct zonelist *zonelist = ac->zonelist;
 	unsigned long flags;
@@ -2115,15 +2122,40 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 	struct zone *zone;
 	struct page *page;
 	int order;
+	int unreserved_pages = 0;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
 								ac->nodemask) {
-		/* Preserve at least one pageblock */
-		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
+		unsigned long unreserve_pages_max;
+
+		/*
+		 * Try to preserve at least one pageblock but use up before
+		 * OOM kill.
+		 */
+		if (no_progress_loops < MAX_RECLAIM_RETRIES &&
+			zone->nr_reserved_highatomic <= pageblock_nr_pages)
 			continue;
 
 		spin_lock_irqsave(&zone->lock, flags);
-		for (order = 0; order < MAX_ORDER; order++) {
+		if (no_progress_loops < MAX_RECLAIM_RETRIES) {
+			unreserve_pages_max = no_progress_loops *
+					zone->nr_reserved_highatomic /
+					MAX_RECLAIM_RETRIES;
+			unreserve_pages_max = max(unreserve_pages_max,
+						pageblock_nr_pages);
+		} else {
+			/*
+			 * By race with page free functions, !highatomic
+			 * pageblocks can have a free page in highatomic
+			 * migratetype free list. So if we are about to
+			 * kill some process, unreserve every free pages
+			 * in highorderatomic.
+			 */
+			unreserve_pages_max = -1UL;
+		}
+
+		for (order = 0; order < MAX_ORDER &&
+				unreserve_pages_max > 0; order++) {
 			struct free_area *area = &(zone->free_area[order]);
 
 			page = list_first_entry_or_null(
@@ -2151,6 +2183,9 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 				zone->nr_reserved_highatomic -= min(
 						pageblock_nr_pages,
 						zone->nr_reserved_highatomic);
+				unreserve_pages_max -= min(pageblock_nr_pages,
+					zone->nr_reserved_highatomic);
+				unreserved_pages += 1 << page_order(page);
 			}
 
 			/*
@@ -2164,11 +2199,11 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 			 */
 			set_pageblock_migratetype(page, ac->migratetype);
 			move_freepages_block(zone, page, ac->migratetype);
-			spin_unlock_irqrestore(&zone->lock, flags);
-			return;
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
+
+	return unreserved_pages;
 }
 
 /* Remove an element from the buddy allocator from the fallback list */
@@ -3370,7 +3405,6 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	 * Shrink them them and try again
 	 */
 	if (!page && !drained) {
-		unreserve_highatomic_pageblock(ac);
 		drain_all_pages(NULL);
 		drained = true;
 		goto retry;
@@ -3449,12 +3483,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 }
 
 /*
- * Maximum number of reclaim retries without any progress before OOM killer
- * is consider as the only way to move forward.
- */
-#define MAX_RECLAIM_RETRIES 16
-
-/*
  * Checks whether it makes sense to retry the reclaim to make a forward progress
  * for the given allocation request.
  * The reclaim feedback represented by did_some_progress (any progress during
@@ -3490,6 +3518,9 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 	if (*no_progress_loops > MAX_RECLAIM_RETRIES)
 		return false;
 
+	if (unreserve_highatomic_pageblock(ac, *no_progress_loops))
+		return true;
+
 	/*
 	 * Keep reclaiming pages while there is a chance this will lead
 	 * somewhere.  If none of the target zones can satisfy our allocation
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
