Message-ID: <39638C9B.64AB2544@norran.net>
Date: Wed, 05 Jul 2000 21:29:31 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH really] latency improvements, one reschedule moved
References: <395D520C.F16DD7D6@norran.net> <39628664.7756172A@norran.net>
Content-Type: multipart/mixed;
 boundary="------------B3EDE4D65735D303C5A84519"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-audio-dev@ginette.musique.umontreal.ca" <linux-audio-dev@ginette.musique.umontreal.ca>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------B3EDE4D65735D303C5A84519
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Again... :-(

Patch included this time...

/RogerL


Roger Larsson wrote:
> 
> Hi Linus,
> 
> Cleaned up and corrected some bugs...
> (memory_pressure... !
>  unintended reschedule removed)
> 
> Sadly the performance went down - slightly.
> Latency looks even nicer. Still some spikes.
> [sync and mmap002 behaviour not corrected]
> 
> /RogerL
> 
> Roger Larsson wrote:
> >
> > Hi Linus,
> >
> > [patch against  linux-2.4.0-test3-pre2]
> >
> > I cleaned up kswapd and moved its reschedule point.
> > Disk performance is close to the same.
> > Latencies have improved a lot (tested with Bennos latencytest)
> >
> > * sync is still problematic
> > * mmap002 (Quintinela) still gives a 212 ms latency
> >   (compared to 423 ms for the unpatched...)
> > * other disk related latencies are down under 30 ms.
> >   (streaming read, copy, write)
> > * the number of overruns has dropped considerably!
> >   (running 4 buffers with a deadline of 23 ms)
> >
> > /RogerL
> >
> > --
> > Home page:
> >   http://www.norran.net/nra02596/
> >
> >   ------------------------------------------------------------------------
> >                                               Name: patch-2.4.0-test3-pre2-vmscan.latency.2
> >    patch-2.4.0-test3-pre2-vmscan.latency.2    Type: Plain Text (text/plain)
> >                                           Encoding: 7bit
> 
> --
> Home page:
>   http://www.norran.net/nra02596/
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--------------B3EDE4D65735D303C5A84519
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test3-pre2-vmscan.latency.5"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test3-pre2-vmscan.latency.5"

diff -aurp linux-2.4.0-test3-pre2/mm/vmscan.c linux/mm/vmscan.c
--- linux-2.4.0-test3-pre2/mm/vmscan.c	Wed May 31 20:13:37 2000
+++ linux/mm/vmscan.c	Wed Jul  5 00:52:59 2000
@@ -419,6 +419,48 @@ out:
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
+			if (zone->size &&
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
+			if (zone->size &&
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
@@ -442,11 +484,28 @@ static int do_try_to_free_pages(unsigned
 
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
 			if (!--count)
 				goto done;
 		}
 
+		/* not (been) low on memory - it is
+		 * pointless to try to swap out.
+		 */
+		if (!keep_kswapd_awake())
+		      goto done;
 
 		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
@@ -457,8 +516,18 @@ static int do_try_to_free_pages(unsigned
 			 */
 			count -= shrink_dcache_memory(priority, gfp_mask);
 			count -= shrink_icache_memory(priority, gfp_mask);
-			if (count <= 0)
-				goto done;
+			/*
+			 * Not currently working, see fixme in shrink_?cache_memory
+			 * In the inner funtions there is a comment:
+			 * "To help debugging, a zero exit status indicates
+			 *  all slabs were released." (-arca?)
+			 * lets handle it in a primitive but working way...
+			 *	if (count <= 0)
+			 *		goto done;
+			 */
+			if (!keep_kswapd_awake())
+			  goto done;
+
 			while (shm_swap(priority, gfp_mask)) {
 				if (!--count)
 					goto done;
@@ -477,7 +546,8 @@ static int do_try_to_free_pages(unsigned
 			if (--swap_count < 0)
 				break;
 
-	} while (--priority >= 0);
+		priority--;
+	} while (priority >= 0);
 
 	/* Always end on a shrink_mmap.. */
 	while (shrink_mmap(0, gfp_mask)) {
@@ -486,7 +556,7 @@ static int do_try_to_free_pages(unsigned
 	}
 	/* We return 1 if we are freed some page */
 	return (count != FREE_COUNT);
-
+ 
 done:
 	return 1;
 }
@@ -530,29 +600,14 @@ int kswapd(void *unused)
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
+		  /* wake up regulary to do an early attempt too free
+		   * pages - pages will not actually be freed.
+		   */
+		  interruptible_sleep_on_timeout(&kswapd_wait, HZ);
 		}
+
+		do_try_to_free_pages(GFP_KSWAPD);
 	}
 }
 
@@ -580,6 +635,12 @@ int try_to_free_pages(unsigned int gfp_m
 		retval = do_try_to_free_pages(gfp_mask);
 		current->flags &= ~PF_MEMALLOC;
 	}
+	else {
+	        /* make sure kswapd runs */
+	        if (waitqueue_active(&kswapd_wait))
+		        wake_up_interruptible(&kswapd_wait);
+	}
+
 	return retval;
 }
 

--------------B3EDE4D65735D303C5A84519--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
