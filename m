Message-ID: <395D520C.F16DD7D6@norran.net>
Date: Sat, 01 Jul 2000 04:06:04 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] latency improvements, one reschedule moved
Content-Type: multipart/mixed;
 boundary="------------2F7D4E7FA7846DC9387A6BC9"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-sound@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------2F7D4E7FA7846DC9387A6BC9
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi Linus, Paul, Benno, ...,

[patch against  linux-2.4.0-test3-pre2]

I cleaned up kswapd and moved its reschedule point.
Disk performance is close to the same.
Latencies have improved a lot (tested with Bennos latencytest)

* sync is still problematic
* mmap002 (Quintinela) still gives a 212 ms latency 
  (compared to 423 ms for the unpatched...)
* other disk related latencies are down under 30 ms.
  (streaming read, copy, write)
* the number of overruns has dropped considerably!
  (running 4 buffers with a deadline of 23 ms)

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------2F7D4E7FA7846DC9387A6BC9
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test3-pre2-vmscan.latency.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test3-pre2-vmscan.latency.2"

--- linux/mm/vmscan.c.orig	Wed May 31 20:13:37 2000
+++ linux/mm/vmscan.c	Sat Jul  1 03:29:00 2000
@@ -419,6 +419,48 @@
 }
 
 /*
+ * Check if there is any memory pressure (free_pages < pages_low)
+ */
+static inline int memory_pressure(void)
+{
+	pg_data_t *pgdat = pgdat_list;
+
+	do {
+		int i;
+		for(i = 0; i < MAX_NR_ZONES; i++) {
+			zone_t *zone = pgdat->node_zones+ i;
+			if (!zone->size &&
+			    zone->free_pages < zone->pages_low)
+				return 1;
+		}
+		pgdat = pgdat->node_next;
+	} while (pgdat);
+
+	return 0;
+}
+
+/*
+ * Check if there is any memory pressure (free_pages < pages_low)
+ */
+static inline int keep_kswapd_awake(void)
+{
+	pg_data_t *pgdat = pgdat_list;
+
+	do {
+		int i;
+		for(i = 0; i < MAX_NR_ZONES; i++) {
+			zone_t *zone = pgdat->node_zones+ i;
+			if (!zone->size &&
+			    zone->zone_wake_kswapd)
+				return 1;
+		}
+		pgdat = pgdat->node_next;
+	} while (pgdat);
+
+	return 0;
+}
+
+/*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
  * without holding the kernel lock etc.
@@ -442,7 +484,20 @@
 
 	priority = 64;
 	do {
+		/* should __GFP_WAIT be checked? 
+		 * assume not - not WAITING for a free page
+		 * let more important task execute before
+		 * continuing (Note: kswapd does not use it).
+		 */
+	        if (current->need_resched) {
+		  schedule();
+		  /* time has passed - pressure too? */
+		  if (!memory_pressure())
+		      goto done;
+		}
+
 		while (shrink_mmap(priority, gfp_mask)) {
+		        /* check __GFP_WAIT ? see below */
 			if (!--count)
 				goto done;
 		}
@@ -477,16 +532,21 @@
 			if (--swap_count < 0)
 				break;
 
-	} while (--priority >= 0);
+		priority--;
+	} while (priority >= 0);
 
 	/* Always end on a shrink_mmap.. */
 	while (shrink_mmap(0, gfp_mask)) {
+		if (current->need_resched)
+			schedule();
+		if (!memory_pressure())
+			return 1;
 		if (!--count)
 			goto done;
 	}
 	/* We return 1 if we are freed some page */
 	return (count != FREE_COUNT);
-
+ 
 done:
 	return 1;
 }
@@ -530,29 +590,12 @@
 	tsk->flags |= PF_MEMALLOC;
 
 	for (;;) {
-		pg_data_t *pgdat;
-		int something_to_do = 0;
-
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
+	        if (!keep_kswapd_awake()) {
+		  tsk->state = TASK_INTERRUPTIBLE;
+		  interruptible_sleep_on(&kswapd_wait);
 		}
+
+		do_try_to_free_pages(GFP_KSWAPD);
 	}
 }
 

--------------2F7D4E7FA7846DC9387A6BC9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
