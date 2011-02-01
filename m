Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B962A8D0048
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 11:55:37 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id p11GtWxm003489
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 22:25:32 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p11GtWco2334900
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 22:25:32 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p11GtV1f008594
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 22:25:32 +0530
Subject: [PATCH 2/3][RESEND] Refactor zone_reclaim code (v4)
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 01 Feb 2011 22:25:25 +0530
Message-ID: <20110201165513.12377.41627.stgit@localhost6.localdomain6>
In-Reply-To: <20110201165329.12377.13683.stgit@localhost6.localdomain6>
References: <20110201165329.12377.13683.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Changelog v3
1. Renamed zone_reclaim_unmapped_pages to zone_reclaim_pages

Refactor zone_reclaim, move reusable functionality outside
of zone_reclaim. Make zone_reclaim_unmapped_pages modular

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
---
 mm/vmscan.c |   35 +++++++++++++++++++++++------------
 1 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5899f2f..02cc82e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2943,6 +2943,27 @@ static long zone_pagecache_reclaimable(struct zone *zone)
 }
 
 /*
+ * Helper function to reclaim unmapped pages, we might add something
+ * similar to this for slab cache as well. Currently this function
+ * is shared with __zone_reclaim()
+ */
+static inline void
+zone_reclaim_pages(struct zone *zone, struct scan_control *sc,
+				unsigned long nr_pages)
+{
+	int priority;
+	/*
+	 * Free memory by calling shrink zone with increasing
+	 * priorities until we have enough memory freed.
+	 */
+	priority = ZONE_RECLAIM_PRIORITY;
+	do {
+		shrink_zone(priority, zone, sc);
+		priority--;
+	} while (priority >= 0 && sc->nr_reclaimed < nr_pages);
+}
+
+/*
  * Try to free up some pages from this zone through reclaim.
  */
 static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
@@ -2951,7 +2972,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
-	int priority;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
@@ -2975,17 +2995,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	if (zone_pagecache_reclaimable(zone) > zone->min_unmapped_pages) {
-		/*
-		 * Free memory by calling shrink zone with increasing
-		 * priorities until we have enough memory freed.
-		 */
-		priority = ZONE_RECLAIM_PRIORITY;
-		do {
-			shrink_zone(priority, zone, &sc);
-			priority--;
-		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
-	}
+	if (zone_pagecache_reclaimable(zone) > zone->min_unmapped_pages)
+		zone_reclaim_pages(zone, &sc, nr_pages);
 
 	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
 	if (nr_slab_pages0 > zone->min_slab_pages) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
