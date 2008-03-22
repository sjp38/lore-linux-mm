Date: Sat, 22 Mar 2008 19:45:54 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [for -mm][PATCH][1/2] page reclaim throttle take3 
Message-Id: <20080322192928.B30B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi

this is latest version of page reclaim throttle patch series.
I explain performance result by another mail.
(now, I working on increase coverage of mesurement that patch)

at least, In some measurements, a considerably good result has come out. 


---------------------------------------------------------------------
changelog
========================================
  v2 -> v3:
     o use wake_up() instead wake_up_all()
     o max reclaimers can be changed Kconfig option and sysctl.
     o some cleanups

  v1 -> v2:
     o make per zone throttle 


description
========================================
current VM implementation doesn't has limit of # of parallel reclaim.
when heavy workload, it bring to 2 bad things
  - heavy lock contention
  - unnecessary swap out

Dec 2007, KAMEZA Hiroyuki proposed the patch of page 
reclaim throttle and explain it improve reclaim time.
	http://marc.info/?l=linux-mm&m=119667465917215&w=2

but unfortunately it works only memcgroup reclaim.
Today, I implement it again for support global reclaim and mesure it.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/mmzone.h |    2 +
 mm/Kconfig             |   10 ++++++
 mm/page_alloc.c        |    4 ++
 mm/vmscan.c            |   73 ++++++++++++++++++++++++++++++++++++++++---------
 4 files changed, 76 insertions(+), 13 deletions(-)

Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h	2008-03-14 21:51:36.000000000 +0900
+++ b/include/linux/mmzone.h	2008-03-14 21:58:52.000000000 +0900
@@ -335,6 +335,8 @@ struct zone {
 	unsigned long		spanned_pages;	/* total size, including holes */
 	unsigned long		present_pages;	/* amount of memory (excluding holes) */
 
+	atomic_t		nr_reclaimers;
+	wait_queue_head_t	reclaim_throttle_waitq;
 	/*
 	 * rarely used fields:
 	 */
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2008-03-14 21:52:19.000000000 +0900
+++ b/mm/page_alloc.c	2008-03-14 21:58:52.000000000 +0900
@@ -3473,6 +3473,10 @@ static void __paginginit free_area_init_
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
--- a/mm/vmscan.c	2008-03-14 21:52:18.000000000 +0900
+++ b/mm/vmscan.c	2008-03-21 22:35:14.000000000 +0900
@@ -1190,13 +1190,30 @@ static void shrink_active_list(unsigned 
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static unsigned long shrink_zone(int priority, struct zone *zone,
-				struct scan_control *sc)
+static int shrink_zone(int priority, struct zone *zone,
+		       struct scan_control *sc, unsigned long *ret_reclaimed)
 {
 	unsigned long nr_active;
 	unsigned long nr_inactive;
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
+	unsigned long start_time = jiffies;
+	int ret = 0;
+
+	wait_event(zone->reclaim_throttle_waitq,
+		   atomic_add_unless(&zone->nr_reclaimers, 1,
+				     CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE));
+
+	/* more reclaim until needed? */
+	if (scan_global_lru(sc) &&
+	    !(current->flags & PF_KSWAPD) &&
+	    time_after(jiffies, start_time + HZ/10)) {
+		if (zone_watermark_ok(zone, sc->order, 4*zone->pages_high,
+				      MAX_NR_ZONES-1, 0)) {
+			ret = -EAGAIN;
+			goto out;
+		}
+	}
 
 	if (scan_global_lru(sc)) {
 		/*
@@ -1248,9 +1265,13 @@ static unsigned long shrink_zone(int pri
 								sc);
 		}
 	}
-
+out:
+	*ret_reclaimed += nr_reclaimed;
+	atomic_dec(&zone->nr_reclaimers);
+	wake_up(&zone->reclaim_throttle_waitq);
 	throttle_vm_writeout(sc->gfp_mask);
-	return nr_reclaimed;
+
+	return ret;
 }
 
 /*
@@ -1269,13 +1290,13 @@ static unsigned long shrink_zone(int pri
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
-					struct scan_control *sc)
+static int shrink_zones(int priority, struct zonelist *zonelist,
+			struct scan_control *sc, unsigned long *ret_reclaimed)
 {
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
-	unsigned long nr_reclaimed = 0;
 	struct zoneref *z;
 	struct zone *zone;
+	int ret;
 
 	sc->all_unreclaimable = 1;
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
@@ -1304,10 +1325,14 @@ static unsigned long shrink_zones(int pr
 							priority);
 		}
 
-		nr_reclaimed += shrink_zone(priority, zone, sc);
+		ret = shrink_zone(priority, zone, sc, ret_reclaimed);
+		if (ret == -EAGAIN)
+			goto out;
 	}
+	ret = 0;
 
-	return nr_reclaimed;
+out:
+	return ret;
 }
  
 /*
@@ -1335,6 +1360,8 @@ static unsigned long do_try_to_free_page
 	struct zoneref *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
+ 	unsigned long last_check_time = jiffies;
+ 	int err;
 
 	if (scan_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
@@ -1357,7 +1384,12 @@ static unsigned long do_try_to_free_page
 		sc->nr_io_pages = 0;
 		if (!priority)
 			disable_swap_token();
-		nr_reclaimed += shrink_zones(priority, zonelist, sc);
+ 		err = shrink_zones(priority, zonelist, sc, &nr_reclaimed);
+ 		if (err == -EAGAIN) {
+ 			ret = 1;
+ 			goto out;
+ 		}
+
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1390,8 +1422,23 @@ static unsigned long do_try_to_free_page
 
 		/* Take a nap, wait for some writeback to complete */
 		if (sc->nr_scanned && priority < DEF_PRIORITY - 2 &&
-				sc->nr_io_pages > sc->swap_cluster_max)
+		    sc->nr_io_pages > sc->swap_cluster_max)
 			congestion_wait(WRITE, HZ/10);
+
+		if (scan_global_lru(sc) &&
+		    time_after(jiffies, last_check_time+HZ)) {
+			last_check_time = jiffies;
+
+			/* more reclaim until needed? */
+			for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+				if (zone_watermark_ok(zone, sc->order,
+						      4 * zone->pages_high,
+						      high_zoneidx, 0)) {
+					ret = 1;
+					goto out;
+				}
+			}
+		}
 	}
 	/* top priority shrink_caches still had more to do? don't OOM, then */
 	if (!sc->all_unreclaimable && scan_global_lru(sc))
@@ -1589,7 +1636,7 @@ loop_again:
 			 */
 			if (!zone_watermark_ok(zone, order, 8*zone->pages_high,
 						end_zone, 0))
-				nr_reclaimed += shrink_zone(priority, zone, &sc);
+				shrink_zone(priority,zone, &sc, &nr_reclaimed);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
@@ -2034,7 +2081,7 @@ static int __zone_reclaim(struct zone *z
 		priority = ZONE_RECLAIM_PRIORITY;
 		do {
 			note_zone_scanning_priority(zone, priority);
-			nr_reclaimed += shrink_zone(priority, zone, &sc);
+			shrink_zone(priority, zone, &sc, &nr_reclaimed);
 			priority--;
 		} while (priority >= 0 && nr_reclaimed < nr_pages);
 	}
Index: b/mm/Kconfig
===================================================================
--- a/mm/Kconfig	2008-03-14 21:52:16.000000000 +0900
+++ b/mm/Kconfig	2008-03-14 22:25:02.000000000 +0900
@@ -193,3 +193,13 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config NR_MAX_RECLAIM_TASKS_PER_ZONE
+	int "maximum number of reclaiming tasks at the same time"
+	default 3
+	help
+	  This value determines the number of threads which can do page reclaim
+	  in a zone simultaneously. If this is too big, performance under heavy memory
+	  pressure will decrease.
+	  If unsure, use default.
+


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
