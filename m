Message-ID: <3973AF65.F3372E@norran.net>
Date: Tue, 18 Jul 2000 03:14:13 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] test5-pre1 vmfix (rev 8)
Content-Type: multipart/mixed;
 boundary="------------FDA74AD99A03F4965B626A7B"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------FDA74AD99A03F4965B626A7B
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

Since I am responsible for messing up some aspects of vm
(when fixing others)
here is a patch that tries to solve the introduced problems.

* no more periodic wake up of kswapd - not needed anymore
* no more freeing all zones to (free_pages > pages_high)
* always wakes kswapd up after try_to_free_pages
* kswapd starts when all zones gets zone_wake_kswapd
  (runs once for each zone that hits zone_wake_kswapd)
* removed test for more than pages_high in alloc_pages,
  zones will mostly be in the range [pages_high...pages_low]
* I get 10% better throughput than 2.4.0-test4, YMMV

Note: logic of function keep_kswapd_awake has changed.

/RogerL


--
Home page:
  http://www.norran.net/nra02596/
--------------FDA74AD99A03F4965B626A7B
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test5-1-vmfix.8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test5-1-vmfix.8"

--- linux/mm/vmscan.c.orig	Sat Jul 15 23:44:34 2000
+++ linux/mm/vmscan.c	Tue Jul 18 02:08:48 2000
@@ -440,7 +440,7 @@ static inline int memory_pressure(void)
 }
 
 /*
- * Check if there recently has been memory pressure (zone_wake_kswapd)
+ * Check if all zones have recently had memory_pressure (zone_wake_kswapd)
  */
 static inline int keep_kswapd_awake(void)
 {
@@ -451,13 +451,13 @@ static inline int keep_kswapd_awake(void
 		for(i = 0; i < MAX_NR_ZONES; i++) {
 			zone_t *zone = pgdat->node_zones+ i;
 			if (zone->size &&
-			    zone->zone_wake_kswapd)
-				return 1;
+			    !zone->zone_wake_kswapd)
+				return 0;
 		}
 		pgdat = pgdat->node_next;
 	} while (pgdat);
 
-	return 0;
+	return 1;
 }
 
 /*
@@ -496,9 +496,7 @@ static int do_try_to_free_pages(unsigned
 				goto done;
 		}
 
-		/* not (been) low on memory - it is
-		 * pointless to try to swap out.
-		 */
+		/* check if mission completed */
 		if (!keep_kswapd_awake())
 			goto done;
 
@@ -596,10 +594,7 @@ int kswapd(void *unused)
 
 	for (;;) {
 		if (!keep_kswapd_awake()) {
-			/* wake up regulary to do an early attempt too free
-			 * pages - pages will not actually be freed.
-			 */
-			interruptible_sleep_on_timeout(&kswapd_wait, HZ);
+			interruptible_sleep_on(&kswapd_wait);
 		}
 
 		do_try_to_free_pages(GFP_KSWAPD);
@@ -631,18 +626,18 @@ int try_to_free_pages(unsigned int gfp_m
 		retval = do_try_to_free_pages(gfp_mask);
 		current->flags &= ~PF_MEMALLOC;
 	}
-	else {
-		/* make sure kswapd runs */
-		if (waitqueue_active(&kswapd_wait))
-			wake_up_interruptible(&kswapd_wait);
-	}
+
+	/* someone needed memory that kswapd had not provided
+	 * make sure kswapd runs, should not happen often */
+	if (waitqueue_active(&kswapd_wait))
+		wake_up_interruptible(&kswapd_wait);
 
 	return retval;
 }
 
 static int __init kswapd_init(void)
 {
-	printk("Starting kswapd v1.6\n");
+	printk("Starting kswapd v1.7\n");
 	swap_setup();
 	kernel_thread(kswapd, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
 	return 0;
--- linux/mm/page_alloc.c.orig	Sat Jul 15 23:44:46 2000
+++ linux/mm/page_alloc.c	Tue Jul 18 02:19:30 2000
@@ -217,7 +217,7 @@ static struct page * rmqueue(zone_t *zon
  */
 struct page * __alloc_pages(zonelist_t *zonelist, unsigned long order)
 {
-	zone_t **zone = zonelist->zones;
+	zone_t **zone;
 	extern wait_queue_head_t kswapd_wait;
 
 	/*
@@ -228,21 +228,6 @@ struct page * __alloc_pages(zonelist_t *
 	 * in a higher zone fails.
 	 */
 
-	for (;;) {
-		zone_t *z = *(zone++);
-		if (!z)
-			break;
-		if (!z->size)
-			BUG();
-
-		/* If there are zones with a lot of free memory allocate from them */
-		if (z->free_pages > z->pages_high) {
-			struct page *page = rmqueue(z, order);
-			if (page)
-				return page;
-		}
-	}
-
 	zone = zonelist->zones;
 	for (;;) {
 		zone_t *z = *(zone++);
@@ -263,6 +248,21 @@ struct page * __alloc_pages(zonelist_t *
 				return page;
 		}
 	}
+
+	/* Three possibilities to get here
+	 * - Previous alloc_pages resulted in last zone set to have
+	 *   zone_wake_kswapd and start it. kswapd has not been able
+	 *   to release enough pages so that one zone does not have
+	 *   zone_wake_kswapd set.
+	 * - Different sets of zones (zonelist)
+	 *   previous did not have all zones with zone_wake_kswapd but
+	 *   this one has... should kswapd be woken up? it will run once.
+	 * - SMP race, kswapd went to sleep slightly after it as running
+	 *   in 'if (waitqueue_active(...))' above.
+	 * + anyway the test is very cheap to do...
+	 */
+	if (waitqueue_active(&kswapd_wait))
+		wake_up_interruptible(&kswapd_wait);
 
 	/*
 	 * Ok, we don't have any zones that don't need some

--------------FDA74AD99A03F4965B626A7B--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
