Message-ID: <39750E98.54A4FBE9@norran.net>
Date: Wed, 19 Jul 2000 04:12:40 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH--] test5-pre1 vmfix (rev 2.1) + one rescheduling bugfix?
Content-Type: multipart/mixed;
 boundary="------------7CB5DBEDA0302B78AD73DA44"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------7CB5DBEDA0302B78AD73DA44
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

[Intermediate release - indicator of problem with previous]

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
* Up to 10% better throughput than 2.4.0-test4, YMMV
* Tested mostly with streaming tests. On a non HIGHMEM config.

+ New: zone_wake_kswapd == 2 indicates a situation where
  free_pages < pages_low another alloc is done.
+ New-BUGFIX: runs kswapd while zone_wake_kswapd == 2 or
  low_on_memory (Quintela)
+ New-BUGFIX? checks if __GFP_IO before rescheduling
  (will become separate patch if correct, thanks Quintela)


- Kills mmap002, did not in the previously released that
  should have this problem (but did not) - why? Will
  investigate further...
- Since kswapd does not wake up periodic anymore, the
  latencies might be worse... Will investigate it
  further when other stuff works.

Note: logic of function keep_kswapd_awake has changed.

/RogerL


--
Home page:
  http://www.norran.net/nra02596/
--------------7CB5DBEDA0302B78AD73DA44
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test5-1-vmfix.21"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test5-1-vmfix.21"

--- linux/mm/vmscan.c.orig	Sat Jul 15 23:44:34 2000
+++ linux/mm/vmscan.c	Wed Jul 19 03:44:12 2000
@@ -419,7 +419,7 @@ out:
 }
 
 /*
- * Check if there is any memory pressure (free_pages < pages_low)
+ * Check if there is any memory pressure (zone_wake_kswapd == 2)
  */
 static inline int memory_pressure(void)
 {
@@ -430,7 +430,7 @@ static inline int memory_pressure(void)
 		for(i = 0; i < MAX_NR_ZONES; i++) {
 			zone_t *zone = pgdat->node_zones+ i;
 			if (zone->size &&
-			    zone->free_pages < zone->pages_low)
+			    zone->zone_wake_kswapd == 2)
 				return 1;
 		}
 		pgdat = pgdat->node_next;
@@ -440,24 +440,31 @@ static inline int memory_pressure(void)
 }
 
 /*
- * Check if there recently has been memory pressure (zone_wake_kswapd)
+ * Check if any zone have recently been critical (low_on_memory)
+ * any zone with current memory pressure (zone_wake_kswapd == 2)
+ * all zones have recently had memory_pressure (zone_wake_kswapd)
  */
 static inline int keep_kswapd_awake(void)
 {
+	int all_recent = 1;
 	pg_data_t *pgdat = pgdat_list;
 
 	do {
 		int i;
 		for(i = 0; i < MAX_NR_ZONES; i++) {
 			zone_t *zone = pgdat->node_zones+ i;
-			if (zone->size &&
-			    zone->zone_wake_kswapd)
-				return 1;
+			if (!zone->size) {
+				if (zone->zone_wake_kswapd == 2 ||
+				    zone->low_on_memory)
+					return 1;
+				if (!zone->zone_wake_kswapd)
+					all_recent = 0;
+			}
 		}
 		pgdat = pgdat->node_next;
 	} while (pgdat);
 
-	return 0;
+	return all_recent;
 }
 
 /*
@@ -484,7 +491,7 @@ static int do_try_to_free_pages(unsigned
 
 	priority = 64;
 	do {
-		if (current->need_resched) {
+		if ((gfp_mask & __GFP_IO) && current->need_resched) {
 			schedule();
 			/* time has passed - pressure too? */
 			if (!memory_pressure())
@@ -496,9 +503,7 @@ static int do_try_to_free_pages(unsigned
 				goto done;
 		}
 
-		/* not (been) low on memory - it is
-		 * pointless to try to swap out.
-		 */
+		/* check if mission completed */
 		if (!keep_kswapd_awake())
 			goto done;
 
@@ -596,10 +601,7 @@ int kswapd(void *unused)
 
 	for (;;) {
 		if (!keep_kswapd_awake()) {
-			/* wake up regulary to do an early attempt too free
-			 * pages - pages will not actually be freed.
-			 */
-			interruptible_sleep_on_timeout(&kswapd_wait, HZ);
+			interruptible_sleep_on(&kswapd_wait);
 		}
 
 		do_try_to_free_pages(GFP_KSWAPD);
@@ -628,24 +630,30 @@ int try_to_free_pages(unsigned int gfp_m
 	if (gfp_mask & __GFP_WAIT) {
 		current->state = TASK_RUNNING;
 		current->flags |= PF_MEMALLOC;
-		retval = do_try_to_free_pages(gfp_mask);
+		do {
+			retval = do_try_to_free_pages(gfp_mask);
+		} while (!retval);
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
 }
 
 module_init(kswapd_init)
+
+
+
+
--- linux/mm/page_alloc.c.orig	Sat Jul 15 23:44:46 2000
+++ linux/mm/page_alloc.c	Wed Jul 19 03:45:36 2000
@@ -141,9 +141,12 @@ void __free_pages_ok (struct page *page,
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 
-	if (zone->free_pages > zone->pages_high) {
-		zone->zone_wake_kswapd = 0;
-		zone->low_on_memory = 0;
+	if (zone->free_pages > zone->pages_low) {
+		zone->zone_wake_kswapd = 1;
+		if (zone->free_pages > zone->pages_high) {
+			zone->zone_wake_kswapd = 0;
+			zone->low_on_memory = 0;
+		}
 	}
 }
 
@@ -217,7 +220,7 @@ static struct page * rmqueue(zone_t *zon
  */
 struct page * __alloc_pages(zonelist_t *zonelist, unsigned long order)
 {
-	zone_t **zone = zonelist->zones;
+	zone_t **zone;
 	extern wait_queue_head_t kswapd_wait;
 
 	/*
@@ -228,21 +231,6 @@ struct page * __alloc_pages(zonelist_t *
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
@@ -256,6 +244,16 @@ struct page * __alloc_pages(zonelist_t *
 			struct page *page = rmqueue(z, order);
 			if (z->free_pages < z->pages_low) {
 				z->zone_wake_kswapd = 1;
+
+				/* Usually zone_wake_kswapd is set to 2 
+				 * on second alloc below pages_low
+				 * but if this was a big one
+				 * - do not let it pass unnoticed 
+				 */
+				if (z->free_pages < z->pages_low - MAX_ORDER) {
+					z->zone_wake_kswapd = 2;
+				}
+
 				if (waitqueue_active(&kswapd_wait))
 					wake_up_interruptible(&kswapd_wait);
 			}
@@ -264,6 +262,21 @@ struct page * __alloc_pages(zonelist_t *
 		}
 	}
 
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
+
 	/*
 	 * Ok, we don't have any zones that don't need some
 	 * balancing.. See if we have any that aren't critical..
@@ -275,8 +288,17 @@ struct page * __alloc_pages(zonelist_t *
 			break;
 		if (!z->low_on_memory) {
 			struct page *page = rmqueue(z, order);
-			if (z->free_pages < z->pages_min)
-				z->low_on_memory = 1;
+			if (z->free_pages < z->pages_low) {
+				z->zone_wake_kswapd = 2; /* future: ++ */
+
+				if (z->free_pages < z->pages_min)
+					z->low_on_memory = 1;
+
+				/* make kswapd notice new condition */
+				if (waitqueue_active(&kswapd_wait))
+					wake_up_interruptible(&kswapd_wait);
+			}
+
 			if (page)
 				return page;
 		}

--------------7CB5DBEDA0302B78AD73DA44--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
