Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EC9FC6B006A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 03:38:15 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o687cBtW005073
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 8 Jul 2010 16:38:12 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B12CD45DE58
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 16:38:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C98945DE53
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 16:38:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 568F3E08006
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 16:38:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 058371DB8019
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 16:38:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH v2 1/2] vmscan: don't subtraction of unsined
Message-Id: <20100708163401.CD34.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  8 Jul 2010 16:38:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

'slab_reclaimable' and 'nr_pages' are unsigned. so, subtraction is
unsafe.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Christoph Lameter <cl@linux-foundation.org>
---
 mm/vmscan.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c7e57c..8715da1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2588,7 +2588,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		.swappiness = vm_swappiness,
 		.order = order,
 	};
-	unsigned long slab_reclaimable;
+	unsigned long n, m;
 
 	disable_swap_token();
 	cond_resched();
@@ -2615,8 +2615,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
 	}
 
-	slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-	if (slab_reclaimable > zone->min_slab_pages) {
+	n = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+	if (n > zone->min_slab_pages) {
 		/*
 		 * shrink_slab() does not currently allow us to determine how
 		 * many pages were freed in this zone. So we take the current
@@ -2628,16 +2628,16 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * take a long time.
 		 */
 		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
-			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
-				slab_reclaimable - nr_pages)
+		       (zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages > n))
 			;
 
 		/*
 		 * Update nr_reclaimed by the number of slab pages we
 		 * reclaimed from this zone.
 		 */
-		sc.nr_reclaimed += slab_reclaimable -
-			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+		m = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+		if (m < n)
+			sc.nr_reclaimed += n - m;
 	}
 
 	p->reclaim_state = NULL;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
