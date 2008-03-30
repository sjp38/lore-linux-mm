Date: Sun, 30 Mar 2008 20:00:46 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH][-mm][1/2] core of page reclaim throttle
In-Reply-To: <20080330171224.89D8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080330171152.89D5.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080330171224.89D8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080330195858.89F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

> The end of last year, KAMEZA Hiroyuki proposed the patch of page 
> reclaim throttle and explain it improve reclaim time.
> 	http://marc.info/?l=linux-mm&m=119667465917215&w=2

Agghh!

I misspelt Kamezawa-san's name. 
I resend this patch. sorry.


-------------------------------------------------------------------

background
=====================================
current VM implementation doesn't has limit of # of parallel reclaim.
when heavy workload, it bring to 2 bad things
  - heavy lock contention
  - unnecessary swap out

The end of last year, KAMEZAWA Hiroyuki proposed the patch of page 
reclaim throttle and explain it improve reclaim time.
	http://marc.info/?l=linux-mm&m=119667465917215&w=2

but unfortunately it works only memcgroup reclaim.
Today, I implement it again for support global reclaim and mesure it.


benefit
=====================================
<<1. fix the bug of incorrect OOM killer>>

if do following commanc, sometimes OOM killer happened.
(OOM happend about 10%)

 $ ./hackbench 125 process 1000

because following bad scenario happend.

   1. memory shortage happend.
   2. many task call shrink_zone at the same time.
   3. all page are isolated from LRU at the same time.
   4. the last task can't isolate any page from LRU.
   5. it cause reclaim failure.
   6. it cause OOM killer.

my patch is directly solution for that problem.


<<2. performance improvement>>
I mesure various parameter of hackbench.

result number mean seconds (i.e. smaller is better)

    num_group    2.6.25-rc5-mm1        my-patch
   ----------------------------------------------
      80              26.22             25.61 
      85              27.31             27.28 
      90              29.23             28.81 
      95              30.73             30.17 
     100              32.02             32.38 
     105              33.97             31.99 
     110              35.37             33.04 
     115              36.96             36.02 
     120              74.05             37.33 
     125              41.07(*)          38.88 
     130              86.92             51.64 
     135             234.62             57.09 
     140             291.95             83.76 
     145             425.35             92.01 
     150             766.92            128.27


(*) sometimes OOM happend, please don't think this is nice result.

my patch get performance improvement at any parameter.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/mmzone.h |    2 +
 include/linux/sched.h  |    1 
 mm/Kconfig             |   10 +++++
 mm/page_alloc.c        |    4 ++
 mm/vmscan.c            |   89 ++++++++++++++++++++++++++++++++++++++++++-------
 5 files changed, 94 insertions(+), 12 deletions(-)

Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h	2008-03-27 13:35:03.000000000 +0900
+++ b/include/linux/mmzone.h	2008-03-27 15:55:50.000000000 +0900
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
--- a/mm/page_alloc.c	2008-03-27 13:35:03.000000000 +0900
+++ b/mm/page_alloc.c	2008-03-27 13:35:16.000000000 +0900
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
--- a/mm/vmscan.c	2008-03-27 13:35:03.000000000 +0900
+++ b/mm/vmscan.c	2008-03-27 19:41:50.000000000 +0900
@@ -124,6 +124,7 @@ struct scan_control {
 int vm_swappiness = 60;
 long vm_total_pages;	/* The total number of pages which the VM controls */
 
+#define MAX_RECLAIM_TASKS CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
@@ -1190,14 +1191,42 @@ static void shrink_active_list(unsigned 
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
+	atomic_long_t last_checked = ATOMIC_LONG_INIT(INITIAL_JIFFIES);
+	int ret = 0;
+	int throttle_on = 0;
 
+	/* avoid recursing wait_evnet */
+	if (current->flags & PF_RECLAIMING)
+		goto shrink_it;
+
+	throttle_on = 1;
+	current->flags |= PF_RECLAIMING;
+	wait_event(zone->reclaim_throttle_waitq,
+		   atomic_add_unless(&zone->nr_reclaimers, 1,
+				     MAX_RECLAIM_TASKS));
+
+	/* reclaim still necessary? */
+	if (scan_global_lru(sc) &&
+	    !(current->flags & PF_KSWAPD) &&
+	    time_after(jiffies, start_time+HZ) &&
+	    time_after(jiffies, (ulong)atomic_long_read(&last_checked)+HZ/10)) {
+		if (zone_watermark_ok(zone, sc->order, 4*zone->pages_high,
+				      gfp_zone(sc->gfp_mask), 0)) {
+			ret = -EAGAIN;
+			goto out;
+		}
+		atomic_long_set(&last_checked, jiffies);
+	}
+
+shrink_it:
 	if (scan_global_lru(sc)) {
 		/*
 		 * Add one to nr_to_scan just to make sure that the kernel
@@ -1249,8 +1278,17 @@ static unsigned long shrink_zone(int pri
 		}
 	}
 
+out:
+	if (throttle_on) {
+		current->flags &= ~PF_RECLAIMING;
+		atomic_dec(&zone->nr_reclaimers);
+		wake_up(&zone->reclaim_throttle_waitq);
+	}
+
+	*ret_reclaimed += nr_reclaimed;
 	throttle_vm_writeout(sc->gfp_mask);
-	return nr_reclaimed;
+
+	return ret;
 }
 
 /*
@@ -1269,13 +1307,13 @@ static unsigned long shrink_zone(int pri
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
@@ -1304,10 +1342,14 @@ static unsigned long shrink_zones(int pr
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
@@ -1335,6 +1377,8 @@ static unsigned long do_try_to_free_page
 	struct zoneref *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
+	unsigned long last_check_time = jiffies;
+	int err;
 
 	if (scan_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
@@ -1357,7 +1401,12 @@ static unsigned long do_try_to_free_page
 		sc->nr_io_pages = 0;
 		if (!priority)
 			disable_swap_token();
-		nr_reclaimed += shrink_zones(priority, zonelist, sc);
+		err = shrink_zones(priority, zonelist, sc, &nr_reclaimed);
+		if (err == -EAGAIN) {
+			ret = 1;
+			goto out;
+		}
+
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1390,8 +1439,24 @@ static unsigned long do_try_to_free_page
 
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
+			/* reclaim still necessary? */
+			for_each_zone_zonelist(zone, z, zonelist,
+					       high_zoneidx) {
+				if (zone_watermark_ok(zone, sc->order,
+						      4*zone->pages_high,
+						      high_zoneidx, 0)) {
+					ret = 1;
+					goto out;
+				}
+			}
+		}
 	}
 	/* top priority shrink_caches still had more to do? don't OOM, then */
 	if (!sc->all_unreclaimable && scan_global_lru(sc))
@@ -1589,7 +1654,7 @@ loop_again:
 			 */
 			if (!zone_watermark_ok(zone, order, 8*zone->pages_high,
 						end_zone, 0))
-				nr_reclaimed += shrink_zone(priority, zone, &sc);
+				shrink_zone(priority, zone, &sc, &nr_reclaimed);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
@@ -2034,7 +2099,7 @@ static int __zone_reclaim(struct zone *z
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
--- a/mm/Kconfig	2008-03-27 13:35:03.000000000 +0900
+++ b/mm/Kconfig	2008-03-27 13:35:16.000000000 +0900
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
Index: b/include/linux/sched.h
===================================================================
--- a/include/linux/sched.h	2008-03-27 13:35:03.000000000 +0900
+++ b/include/linux/sched.h	2008-03-27 13:35:16.000000000 +0900
@@ -1475,6 +1475,7 @@ static inline void put_task_struct(struc
 #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
 #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezeable */
+#define PF_RECLAIMING   0x80000000      /* The task have page reclaim throttling ticket */
 
 /*
  * Only the _current_ task can read/write to tsk->flags, but other




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
