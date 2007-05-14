From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070514173259.6787.58533.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/2] Only check absolute watermarks for ALLOC_HIGH and ALLOC_HARDER allocations
Date: Mon, 14 May 2007 18:32:59 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nicolas.mailhot@laposte.net, clameter@sgi.com, apw@shadowen.org
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

zone_watermark_ok() checks if there are enough free pages including a reserve.
High-order allocations additionally check if there are enough free high-order
pages in relation to the watermark adjusted based on the requested size. If
there are not enough free high-order pages available, 0 is returned so that
the caller enters direct reclaim.

ALLOC_HIGH and ALLOC_HARDER allocations are allowed to dip further into
the reserves but also take into account if the number of free high-order
pages meet the adjusted watermarks. As these allocations cannot sleep,
they cannot enter direct reclaim so the allocation can fail even though
the pages are available and the number of free pages is well above the
watermark for order-0.

This patch alters the behaviour of zone_watermark_ok() slightly. Watermarks
are still obeyed but when an allocator is flagged ALLOC_HIGH or ALLOC_HARDER,
we only check that there is sufficient memory over the reserve to satisfy
the allocation, allocation size is ignored.  This patch also documents
better what zone_watermark_ok() is doing.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 page_alloc.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-001_kswapd_minorder/mm/page_alloc.c linux-2.6.21-mm2-005_nowait_nowatermark/mm/page_alloc.c
--- linux-2.6.21-mm2-001_kswapd_minorder/mm/page_alloc.c	2007-05-14 17:11:37.000000000 +0100
+++ linux-2.6.21-mm2-005_nowait_nowatermark/mm/page_alloc.c	2007-05-14 17:12:40.000000000 +0100
@@ -1280,13 +1280,34 @@ int zone_watermark_ok(struct zone *z, in
 	long free_pages = zone_page_state(z, NR_FREE_PAGES) - (1 << order) + 1;
 	int o;
 
+	/*
+	 * Allow ALLOC_HIGH and ALLOC_HARDER to dip further into reserves
+	 * ALLOC_HIGH              => Reduce the required reserve by a half
+	 * ALLOC_HARDER            => Reduce the required reserve by a quarter
+	 * ALLOC_HIGH|ALLOC_HARDER => Reduce the required reserve by 5/8ths
+	 */
 	if (alloc_flags & ALLOC_HIGH)
 		min -= min / 2;
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
 
+	/* Ensure there are sufficient total pages less the reserve. */
 	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
 		return 0;
+	
+	/*
+	 * If the allocation is flagged ALLOC_HARDER or ALLOC_HIGH, the
+	 * caller cannot enter direct reclaim, so allow them to take a page
+	 * if one exists as the absolute reserves have been met.
+	 */
+	if (alloc_flags & (ALLOC_HARDER | ALLOC_HIGH))
+		return 1;
+
+	/*
+	 * For higher order allocations that can sleep, check that there
+	 * are enough free high-order pages above a reserve adjusted
+	 * based on the requested order.
+	 */
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
 		free_pages -= z->free_area[o].nr_free << o;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
