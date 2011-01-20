Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 301938D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 07:36:52 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p0KCaLA9012617
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 23:36:21 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0KCaiT01523824
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 23:36:44 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0KCahYb022917
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 23:36:44 +1100
Subject: [REPOST] [PATCH 2/3] Refactor zone_reclaim code (v3)
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 20 Jan 2011 18:06:39 +0530
Message-ID: <20110120123628.30481.4569.stgit@localhost6.localdomain6>
In-Reply-To: <20110120123039.30481.81151.stgit@localhost6.localdomain6>
References: <20110120123039.30481.81151.stgit@localhost6.localdomain6>
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
---
 mm/vmscan.c |   35 +++++++++++++++++++++++------------
 1 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e841cae..3b25423 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2815,6 +2815,27 @@ static long zone_pagecache_reclaimable(struct zone *zone)
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
@@ -2823,7 +2844,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
-	int priority;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
@@ -2847,17 +2867,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
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
