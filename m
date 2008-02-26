Date: Tue, 26 Feb 2008 11:32:38 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH] page reclaim throttle take2 
Message-Id: <20080226104647.FF26.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi

this patch is page reclaim improvement.

o previous discussion:
	http://marc.info/?l=linux-mm&m=120339997125985&w=2

o test method
  $ ./hackbench 120 process 1000

o test result (average of 5 times measure)

limit   hackbench     sys-time     major-fault   max-spent-time 
        time(s)       (s)                        in shrink_zone()
                                                 (jiffies)
--------------------------------------------------------------------
3       42.06         378.70       5336          6306


o reason why restrict parallel reclaim 3 task per zone

we tested various parameter.
  - restrict 1 is best major fault.
    but worst max spent time.
  - restrict 3 is best max spent reclaim time and hackbench result.

I think "restrict 3" cause most good experience.


limit      hackbench     sys-time     major-fault   max-spent-time 
           time(s)       (s)                        in shrink_zone()
                                                    (jiffies)
--------------------------------------------------------------------
1          48.50         283.89       3690          9057
2          44.43         350.94       5245          7159
3          42.06         378.70       5336          6306
4          48.84         401.87       5474          6669
unlimited  282.30        1248.47      29026          -



Please any comments!



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: Rik van Riel <riel@redhat.com>
CC: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
CC: Nick Piggin <npiggin@suse.de>


---
 include/linux/mmzone.h |    3 +
 mm/page_alloc.c        |    4 +
 mm/vmscan.c            |  101 ++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 99 insertions(+), 9 deletions(-)

Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h	2008-02-25 21:37:49.000000000 +0900
+++ b/include/linux/mmzone.h	2008-02-26 10:12:12.000000000 +0900
@@ -335,6 +335,9 @@ struct zone {
 	unsigned long		spanned_pages;	/* total size, including holes */
 	unsigned long		present_pages;	/* amount of memory (excluding holes) */
 
+
+	atomic_t		nr_reclaimers;
+	wait_queue_head_t	reclaim_throttle_waitq;
 	/*
 	 * rarely used fields:
 	 */
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2008-02-25 21:37:49.000000000 +0900
+++ b/mm/page_alloc.c	2008-02-26 10:12:12.000000000 +0900
@@ -3466,6 +3466,10 @@ static void __meminit free_area_init_cor
 		zone->nr_scan_inactive = 0;
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
+
+		zone->nr_reclaimers = ATOMIC_INIT(0);
+		init_waitqueue_head(&zone->reclaim_throttle_waitq);
+
 		if (!size)
 			continue;
 
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c	2008-02-25 21:37:49.000000000 +0900
+++ b/mm/vmscan.c	2008-02-26 10:59:38.000000000 +0900
@@ -1252,6 +1252,55 @@ static unsigned long shrink_zone(int pri
 	return nr_reclaimed;
 }
 
+
+#define RECLAIM_LIMIT (3)
+
+static int do_shrink_zone_throttled(int priority, struct zone *zone,
+				    struct scan_control *sc,
+				    unsigned long *ret_reclaimed)
+{
+	u64 start_time;
+	int ret = 0;
+
+	start_time = jiffies_64;
+
+	wait_event(zone->reclaim_throttle_waitq,
+		   atomic_add_unless(&zone->nr_reclaimers, 1, RECLAIM_LIMIT));
+
+	/* more reclaim until needed? */
+	if (scan_global_lru(sc) &&
+	    !(current->flags & PF_KSWAPD) &&
+	    time_after64(jiffies, start_time + HZ/10)) {
+		if (zone_watermark_ok(zone, sc->order, 4*zone->pages_high,
+				      MAX_NR_ZONES-1, 0)) {
+			ret = -EAGAIN;
+			goto out;
+		}
+	}
+
+	*ret_reclaimed += shrink_zone(priority, zone, sc);
+
+out:
+	atomic_dec(&zone->nr_reclaimers);
+	wake_up_all(&zone->reclaim_throttle_waitq);
+
+	return ret;
+}
+
+static unsigned long shrink_zone_throttled(int priority, struct zone *zone,
+					   struct scan_control *sc)
+{
+	unsigned long nr_reclaimed = 0;
+	int ret;
+
+	ret = do_shrink_zone_throttled(priority, zone, sc, &nr_reclaimed);
+
+	if (ret == -EAGAIN)
+		nr_reclaimed = 1;
+
+	return nr_reclaimed;
+}
+
 /*
  * This is the direct reclaim path, for page-allocating processes.  We only
  * try to reclaim pages from zones which will satisfy the caller's allocation
@@ -1268,12 +1317,11 @@ static unsigned long shrink_zone(int pri
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static unsigned long shrink_zones(int priority, struct zone **zones,
-					struct scan_control *sc)
+static int shrink_zones(int priority, struct zone **zones,
+			struct scan_control *sc, unsigned long *ret_reclaimed)
 {
-	unsigned long nr_reclaimed = 0;
 	int i;
-
+	int ret;
 
 	sc->all_unreclaimable = 1;
 	for (i = 0; zones[i] != NULL; i++) {
@@ -1304,10 +1352,15 @@ static unsigned long shrink_zones(int pr
 							priority);
 		}
 
-		nr_reclaimed += shrink_zone(priority, zone, sc);
+		ret = do_shrink_zone_throttled(priority, zone, sc,
+					       ret_reclaimed);
+		if (ret == -EAGAIN)
+			goto out;
 	}
+	ret = 0;
 
-	return nr_reclaimed;
+out:
+	return ret;
 }
  
 /*
@@ -1333,6 +1386,9 @@ static unsigned long do_try_to_free_page
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
 	int i;
+	unsigned long start_time = jiffies;
+	unsigned long last_check_time = jiffies;
+	int err;
 
 	if (scan_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
@@ -1356,7 +1412,12 @@ static unsigned long do_try_to_free_page
 		sc->nr_io_pages = 0;
 		if (!priority)
 			disable_swap_token();
-		nr_reclaimed += shrink_zones(priority, zones, sc);
+		err = shrink_zones(priority, zones, sc, &nr_reclaimed);
+		if (err == -EAGAIN) {
+			ret = 1;
+			goto out;
+		}
+
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1389,8 +1450,28 @@ static unsigned long do_try_to_free_page
 
 		/* Take a nap, wait for some writeback to complete */
 		if (sc->nr_scanned && priority < DEF_PRIORITY - 2 &&
-				sc->nr_io_pages > sc->swap_cluster_max)
+		    sc->nr_io_pages > sc->swap_cluster_max) {
 			congestion_wait(WRITE, HZ/10);
+
+		}
+
+		if (scan_global_lru(sc) &&
+		    time_after(jiffies, start_time+HZ) &&
+		    time_after(jiffies, last_check_time+HZ/10)) {
+			last_check_time = jiffies;
+
+			/* more reclaim until needed? */
+			for (i = 0; zones[i] != NULL; i++) {
+				struct zone *zone = zones[i];
+
+				if (zone_watermark_ok(zone, sc->order,
+						      4*zone->pages_high,
+						      zone_idx(zones[0]), 0)) {
+					ret = 1;
+					goto out;
+				}
+			}
+		}
 	}
 	/* top priority shrink_caches still had more to do? don't OOM, then */
 	if (!sc->all_unreclaimable && scan_global_lru(sc))
@@ -1588,7 +1669,9 @@ loop_again:
 			 */
 			if (!zone_watermark_ok(zone, order, 8*zone->pages_high,
 						end_zone, 0))
-				nr_reclaimed += shrink_zone(priority, zone, &sc);
+				nr_reclaimed += shrink_zone_throttled(priority,
+								      zone,
+								      &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
