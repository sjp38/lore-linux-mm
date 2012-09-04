Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 408386B006C
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 09:26:54 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M9T00IMTUOEUBH0@mailout1.samsung.com> for
 linux-mm@kvack.org; Tue, 04 Sep 2012 22:26:53 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M9T000YZUO4IJ50@mmp2.samsung.com> for linux-mm@kvack.org;
 Tue, 04 Sep 2012 22:26:52 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v3 4/5] mm: add accounting for CMA pages and use them for
 watermark calculation
Date: Tue, 04 Sep 2012 15:26:24 +0200
Message-id: <1346765185-30977-5-git-send-email-b.zolnierkie@samsung.com>
In-reply-to: <1346765185-30977-1-git-send-email-b.zolnierkie@samsung.com>
References: <1346765185-30977-1-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

From: Marek Szyprowski <m.szyprowski@samsung.com>

During watermark check we need to decrease available free pages number
by free CMA pages number because unmovable allocations cannot use pages
from CMA areas.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/page_alloc.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5bb0cda..2166774 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1628,7 +1628,7 @@ static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
  * of the allocation.
  */
 static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
-		      int classzone_idx, int alloc_flags, long free_pages)
+		      int classzone_idx, int alloc_flags, long free_pages, long free_cma_pages)
 {
 	/* free_pages my go negative - that's OK */
 	long min = mark;
@@ -1641,7 +1641,7 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
 
-	if (free_pages <= min + lowmem_reserve)
+	if (free_pages - free_cma_pages <= min + lowmem_reserve)
 		return false;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
@@ -1674,13 +1674,15 @@ bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		      int classzone_idx, int alloc_flags)
 {
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
-					zone_page_state(z, NR_FREE_PAGES));
+					zone_page_state(z, NR_FREE_PAGES),
+					zone_page_state(z, NR_FREE_CMA_PAGES));
 }
 
 bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
 		      int classzone_idx, int alloc_flags)
 {
 	long free_pages = zone_page_state(z, NR_FREE_PAGES);
+	long free_cma_pages = zone_page_state(z, NR_FREE_CMA_PAGES);
 
 	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
 		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
@@ -1694,7 +1696,7 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
 	 */
 	free_pages -= nr_zone_isolate_freepages(z);
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
-								free_pages);
+					free_pages, free_cma_pages);
 }
 
 #ifdef CONFIG_NUMA
-- 
1.7.11.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
