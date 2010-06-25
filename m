Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C46D26B01B0
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 07:21:26 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5PBLOrW011976
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 25 Jun 2010 20:21:24 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 06CF445DE70
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 20:21:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D58CC45DE6E
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 20:21:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BB9C9E38005
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 20:21:23 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6ED33E38007
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 20:21:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/2] vmscan: shrink_slab() require number of lru_pages, not page order
Message-Id: <20100625201915.8067.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 25 Jun 2010 20:21:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Fix simple argument error. Usually 'order' is very small value than
lru_pages. then it can makes unnecessary icache dropping.

Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0ebfe12..c927948 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2611,6 +2611,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
 	slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
 	if (slab_reclaimable > zone->min_slab_pages) {
+		unsigned long lru_pages = zone_reclaimable_pages(zone);
 		/*
 		 * shrink_slab() does not currently allow us to determine how
 		 * many pages were freed in this zone. So we take the current
@@ -2621,7 +2622,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
-		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
+		while (shrink_slab(sc.nr_scanned, gfp_mask, lru_pages) &&
 			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
 				slab_reclaimable - nr_pages)
 			;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
