Message-ID: <39497D0B.BDF0CDB6@norran.net>
Date: Fri, 16 Jun 2000 03:04:11 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] vmscan.c improvements - slightly less swap, latency, readability
Content-Type: multipart/mixed;
 boundary="------------EF49BBE3C2621E7071D6D6F0"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------EF49BBE3C2621E7071D6D6F0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

Another patch that tries to clean up some stuff.
* readability improvements in kswapd.
* do_try_to_free_pages:
  * loop fewer times
  * quit attempt to free pages if there is no memory pressure.
 => Corrected behaviour, avoiding costly runs of shrink_mmap

Note:
 shrink_mmap is not corrected,
 it can still end up in an almost infinite loop.  

- Not finding any page in requested zones.
- No zones with pressure at call. 

--
Home page:
  http://www.norran.net/nra02596/
--------------EF49BBE3C2621E7071D6D6F0
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test1-ac18-RogerL.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test1-ac18-RogerL.2"

--- linux/mm/vmscan.c.orig	Thu Jun 15 22:56:37 2000
+++ linux/mm/vmscan.c	Fri Jun 16 01:39:00 2000
@@ -427,6 +427,34 @@
 	return __ret;
 }
 
+
+/*
+ * Return value is bit mapped
+ */
+static unsigned analyze_zones_pressure(void)
+{
+  int pressure = 0;
+  pg_data_t *pgdat;
+
+  pgdat = pgdat_list;
+  do {
+    int i;
+
+    for(i = 0; i < MAX_NR_ZONES; i++) {
+      zone_t *zone = pgdat->node_zones+ i;
+      if (!zone->size || !zone->zone_wake_kswapd)
+	continue;
+      pressure = 1; /* existing zone with awake kswapd */
+      if (zone->free_pages < zone->pages_low)
+	return (2 || pressure); /* zone with less that low pages */
+    }
+    pgdat = pgdat->node_next;
+
+  } while (pgdat);
+
+  return pressure;
+}
+
 /*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
@@ -445,16 +473,26 @@
 	int count = FREE_COUNT;
 	int swap_count = 0;
 	int ret = 0;
+	unsigned pressure;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
 	priority = 64;
-	do {
-		while (shrink_mmap(priority, gfp_mask)) {
-			ret = 1;
-			if (!--count)
-				goto done;
+	pressure = analyze_zones_pressure();
+	while (count > 0 && 
+	       pressure) {
+	     
+	        if (shrink_mmap(priority, gfp_mask)) {
+		  ret = 1;
+		  count--;
+		  
+		  /* pressure decreases, recalculate it
+		   * (MUCH cheaper than another shrink_mmap)
+		   */
+		  pressure = analyze_zones_pressure();
+
+		  continue;
 		}
 
 
@@ -474,13 +512,13 @@
 			while (shm_swap(priority, gfp_mask)) {
 				ret = 1;
 				if (!--count)
-					goto done;
+				         goto done;
 			}
 		}
 
 		/*
 		 * Then, try to page stuff out..
-		 *
+		 
 		 * This will not actually free any pages (they get
 		 * put in the swap cache), so we must not count this
 		 * as a "count" success.
@@ -497,17 +535,18 @@
 				break;
 		}
 
-	} while (--priority >= 0);
+		/* simulates shifting priority: pages >> priority
+		 * since current slow count may give huge latencies
+		 */
+		if (priority == 0)
+		  break;
+
+		priority /= 2;
+	};
 
-	/* Always end on a shrink_mmap.. */
-	while (shrink_mmap(0, gfp_mask)) {
-		ret = 1;
-		if (!--count)
-			goto done;
-	}
+ done:
 
-done:
-	return ret;
+	return (ret || !pressure);
 }
 
 DECLARE_WAIT_QUEUE_HEAD(kswapd_wait);
@@ -549,29 +588,19 @@
 	tsk->flags |= PF_MEMALLOC;
 
 	for (;;) {
-		pg_data_t *pgdat;
-		int something_to_do = 0;
+	        unsigned pressure = analyze_zones_pressure();
 
-		pgdat = pgdat_list;
-		do {
-			int i;
-			for(i = 0; i < MAX_NR_ZONES; i++) {
-				zone_t *zone = pgdat->node_zones+ i;
-				if (tsk->need_resched)
-					schedule();
-				if (!zone->size || !zone->zone_wake_kswapd)
-					continue;
-				if (zone->free_pages < zone->pages_low)
-					something_to_do = 1;
-				do_try_to_free_pages(GFP_KSWAPD);
-			}
-			pgdat = pgdat->node_next;
-		} while (pgdat);
-
-		if (!something_to_do) {
-			tsk->state = TASK_INTERRUPTIBLE;
-			interruptible_sleep_on(&kswapd_wait);
+		if (pressure > 1) {
+		  if (tsk->need_resched)
+		    schedule();
 		}
+		else {
+		  tsk->state = TASK_INTERRUPTIBLE;
+		  interruptible_sleep_on(&kswapd_wait);
+		}
+
+		/* woken up - there should be something to do */
+		(void)do_try_to_free_pages(GFP_KSWAPD);
 	}
 }
 


--------------EF49BBE3C2621E7071D6D6F0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
