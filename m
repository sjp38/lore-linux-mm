Message-ID: <3970EEB9.F27DB35C@norran.net>
Date: Sun, 16 Jul 2000 01:07:37 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] test5-1 vm fix
Content-Type: multipart/mixed;
 boundary="------------DFBE1F8495F7A6A3807CCD28"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------DFBE1F8495F7A6A3807CCD28
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

Since I am responsible for messing up some aspects of vm
(when fixing others)
here is a patch that tries to solve the introduced problems.

* no more periodic wake up of kswapd - not needed anymore
* no more freeing all zones to (free_pages > pages_high)
* always wakes kswapd up after try_to_free_pages
* always wakes kswapd up when (free_pages < pages_low)
* remove keep_kswapd_awake() function - not needed anymore

/RogerL

Note: Includes Riels "[PATCH] 2.4.0-test4 kswapd rebalancing fix"

--
Home page:
  http://www.norran.net/nra02596/
--------------DFBE1F8495F7A6A3807CCD28
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test5-1-vmfix.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test5-1-vmfix.2"

--- linux/mm/vmscan.c.orig	Sat Jul 15 23:44:34 2000
+++ linux/mm/vmscan.c	Sun Jul 16 00:57:00 2000
@@ -439,26 +439,6 @@ static inline int memory_pressure(void)
 	return 0;
 }
 
-/*
- * Check if there recently has been memory pressure (zone_wake_kswapd)
- */
-static inline int keep_kswapd_awake(void)
-{
-	pg_data_t *pgdat = pgdat_list;
-
-	do {
-		int i;
-		for(i = 0; i < MAX_NR_ZONES; i++) {
-			zone_t *zone = pgdat->node_zones+ i;
-			if (zone->size &&
-			    zone->zone_wake_kswapd)
-				return 1;
-		}
-		pgdat = pgdat->node_next;
-	} while (pgdat);
-
-	return 0;
-}
 
 /*
  * We need to make the locks finer granularity, but right
@@ -499,7 +479,7 @@ static int do_try_to_free_pages(unsigned
 		/* not (been) low on memory - it is
 		 * pointless to try to swap out.
 		 */
-		if (!keep_kswapd_awake())
+		if (!memory_pressure())
 			goto done;
 
 		/* Try to get rid of some shared memory pages.. */
@@ -520,7 +500,7 @@ static int do_try_to_free_pages(unsigned
 			 *	if (count <= 0)
 			 *		goto done;
 			 */
-			if (!keep_kswapd_awake())
+			if (!memory_pressure())
 				goto done;
 
 			while (shm_swap(priority, gfp_mask)) {
@@ -595,11 +575,8 @@ int kswapd(void *unused)
 	tsk->flags |= PF_MEMALLOC;
 
 	for (;;) {
-		if (!keep_kswapd_awake()) {
-			/* wake up regulary to do an early attempt too free
-			 * pages - pages will not actually be freed.
-			 */
-			interruptible_sleep_on_timeout(&kswapd_wait, HZ);
+		if (!memory_pressure()) {
+			interruptible_sleep_on(&kswapd_wait);
 		}
 
 		do_try_to_free_pages(GFP_KSWAPD);
@@ -631,18 +608,18 @@ int try_to_free_pages(unsigned int gfp_m
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
+	  wake_up_interruptible(&kswapd_wait);
 
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
+++ linux/mm/page_alloc.c	Sat Jul 15 23:55:55 2000
@@ -275,8 +275,16 @@ struct page * __alloc_pages(zonelist_t *
 			break;
 		if (!z->low_on_memory) {
 			struct page *page = rmqueue(z, order);
-			if (z->free_pages < z->pages_min)
+			if (z->free_pages < z->pages_min) {
 				z->low_on_memory = 1;
+				/* Suppose all zones have zone_wake_kswapd set
+				 * but kswapd has stopped running due to
+				 * no memory_pressure()
+				 */
+				z->zone_wake_kswapd = 1; /* should be set already */
+				if (waitqueue_active(&kswapd_wait))
+					wake_up_interruptible(&kswapd_wait);
+			}
 			if (page)
 				return page;
 		}

--------------DFBE1F8495F7A6A3807CCD28--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
