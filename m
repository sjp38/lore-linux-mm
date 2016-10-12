Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 186146B0261
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:33:43 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id gg9so33968956pac.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 22:33:43 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id x62si6023807pfa.106.2016.10.11.22.33.41
        for <linux-mm@kvack.org>;
        Tue, 11 Oct 2016 22:33:42 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 4/4] mm: make unreserve highatomic functions reliable
Date: Wed, 12 Oct 2016 14:33:36 +0900
Message-Id: <1476250416-22733-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1476250416-22733-1-git-send-email-minchan@kernel.org>
References: <1476250416-22733-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

Currently, unreserve_highatomic_pageblock bails out if it found
highatomic pageblock regardless of really moving free pages
from the one so that it could mitigate unreserve logic's goal
which saves OOM of a process.

This patch makes unreserve functions bail out only if it moves
some pages out of !highatomic free list to avoid such false
positive.

Another potential problem is that by race between page freeing and
reserve highatomic function, pages could be in highatomic free list
even though the pageblock is !high atomic migratetype. In that case,
unreserve_highatomic_pageblock can be void if count of highatomic
reserve is less than pageblock_nr_pages. We could solve it simply
via draining all of reserved pages before the OOM. It would have
a safeguard role to exhuast reserved pages before converging to OOM.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a7472426663f..565589eae6a2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2079,8 +2079,12 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
  * potentially hurts the reliability of high-order allocations when under
  * intense memory pressure but failed atomic allocations should be easier
  * to recover from than an OOM.
+ *
+ * If @drain is true, try to move all of reserved pages out of highatomic
+ * free list.
  */
-static bool unreserve_highatomic_pageblock(const struct alloc_context *ac)
+static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
+						bool drain)
 {
 	struct zonelist *zonelist = ac->zonelist;
 	unsigned long flags;
@@ -2092,8 +2096,12 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac)
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
 								ac->nodemask) {
-		/* Preserve at least one pageblock */
-		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
+		/*
+		 * Preserve at least one pageblock unless memory pressure
+		 * is really high.
+		 */
+		if (!drain && zone->nr_reserved_highatomic <=
+					pageblock_nr_pages)
 			continue;
 
 		spin_lock_irqsave(&zone->lock, flags);
@@ -2138,8 +2146,10 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac)
 			 */
 			set_pageblock_migratetype(page, ac->migratetype);
 			ret = move_freepages_block(zone, page, ac->migratetype);
-			spin_unlock_irqrestore(&zone->lock, flags);
-			return ret;
+			if (!drain && ret) {
+				spin_unlock_irqrestore(&zone->lock, flags);
+				return ret;
+			}
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
@@ -3343,7 +3353,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	 * Shrink them them and try again
 	 */
 	if (!page && !drained) {
-		unreserve_highatomic_pageblock(ac);
+		unreserve_highatomic_pageblock(ac, false);
 		drain_all_pages(NULL);
 		drained = true;
 		goto retry;
@@ -3462,7 +3472,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 	 */
 	if (*no_progress_loops > MAX_RECLAIM_RETRIES) {
 		/* Before OOM, exhaust highatomic_reserve */
-		if (unreserve_highatomic_pageblock(ac))
+		if (unreserve_highatomic_pageblock(ac, true))
 			return true;
 		return false;
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
