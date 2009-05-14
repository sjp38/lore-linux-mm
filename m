Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C16E56B0199
	for <linux-mm@kvack.org>; Thu, 14 May 2009 07:11:55 -0400 (EDT)
Received: by pxi37 with SMTP id 37so628983pxi.12
        for <linux-mm@kvack.org>; Thu, 14 May 2009 04:12:05 -0700 (PDT)
Date: Thu, 14 May 2009 20:11:50 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] mmtom: Prevent shrinking of active anon lru list in case of
 no swap space V2
Message-Id: <20090514201150.8536f86e.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


Changelog since V2
 o Add new function - can_reclaim_anon : it tests anon_list can be reclaim 

Changelog since V1 
 o Use nr_swap_pages <= 0 in shrink_active_list to prevent scanning  of active anon list.

Now shrink_active_list is called several places.
But if we don't have a swap space, we can't reclaim anon pages.
So, we don't need deactivating anon pages in anon lru list.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>	

---
 mm/vmscan.c |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2f9d555..d7e8242 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1339,8 +1339,7 @@ static int inactive_anon_is_low_global(struct zone *zone)
  * @zone: zone to check
  * @sc:   scan control of this context
  *
- * Returns true if the zone does not have enough inactive anon pages,
- * meaning some active anon pages need to be deactivated.
+ * Returns true if the zone does not have enough inactive anon pages.
  */
 static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
 {
@@ -1389,6 +1388,20 @@ static int inactive_file_is_low(struct zone *zone, struct scan_control *sc)
 	return low;
 }
 
+/*
+ * can_reclaim_anon - check if anonymous pages need to be deactivated
+ * @zone: zone to check
+ * @sc:   scan control of this context
+ * 
+ * Returns true if the zone does not have enough inactive anon pages
+ * and have enough swap sppce, meaning some active anon pages need to
+ * be deactivated.
+ */
+static int can_reclaim_anon(struct zone *zone, struct scan_control *sc)
+{
+	return (inactive_anon_is_low(zone, sc) && nr_swap_pages <= 0);
+}
+
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	struct zone *zone, struct scan_control *sc, int priority)
 {
@@ -1399,7 +1412,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 		return 0;
 	}
 
-	if (lru == LRU_ACTIVE_ANON && inactive_anon_is_low(zone, sc)) {
+	if (lru == LRU_ACTIVE_ANON && can_reclaim_anon(zone, sc)) {
 		shrink_active_list(nr_to_scan, zone, sc, priority, file);
 		return 0;
 	}
@@ -1577,7 +1590,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_anon_is_low(zone, sc))
+	if (can_reclaim_anon(zone, sc))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);
@@ -1880,7 +1893,7 @@ loop_again:
 			 * Do some background aging of the anon list, to give
 			 * pages a chance to be referenced before reclaiming.
 			 */
-			if (inactive_anon_is_low(zone, &sc))
+			if (can_reclaim_anon(zone, &sc))
 				shrink_active_list(SWAP_CLUSTER_MAX, zone,
 							&sc, priority, 0);
 
-- 
1.5.4.3


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
