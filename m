Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2CDC26B01B0
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 07:23:34 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5PBNVj7030746
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 25 Jun 2010 20:23:31 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CD98F45DE79
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 20:23:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AAB4245DE6E
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 20:23:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 688551DB803F
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 20:23:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C7821DB803A
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 20:23:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/2] vmscan: don't subtraction of unsined 
In-Reply-To: <20100625201915.8067.A69D9226@jp.fujitsu.com>
References: <20100625201915.8067.A69D9226@jp.fujitsu.com>
Message-Id: <20100625202126.806A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 25 Jun 2010 20:23:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

'slab_reclaimable' and 'nr_pages' are unsigned. so, subtraction is
unsafe.

Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c927948..b1a90f8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2612,6 +2612,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
 	if (slab_reclaimable > zone->min_slab_pages) {
 		unsigned long lru_pages = zone_reclaimable_pages(zone);
+		unsigned long srec_new;
+
 		/*
 		 * shrink_slab() does not currently allow us to determine how
 		 * many pages were freed in this zone. So we take the current
@@ -2622,17 +2624,21 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
-		while (shrink_slab(sc.nr_scanned, gfp_mask, lru_pages) &&
-			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
-				slab_reclaimable - nr_pages)
-			;
+		for (;;) {
+			if (!shrink_slab(sc.nr_scanned, gfp_mask, lru_pages))
+				break;
+			srec_new = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+			if (srec_new + nr_pages <= slab_reclaimable)
+				break;
+		}
 
 		/*
 		 * Update nr_reclaimed by the number of slab pages we
 		 * reclaimed from this zone.
 		 */
-		sc.nr_reclaimed += slab_reclaimable -
-			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+		srec_new = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+		if (srec_new < slab_reclaimable)
+			sc.nr_reclaimed += slab_reclaimable - srec_new;
 	}
 
 	p->reclaim_state = NULL;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
