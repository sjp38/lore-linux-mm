Message-ID: <3976205E.4C604102@norran.net>
Date: Wed, 19 Jul 2000 23:40:47 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] test5-1 vmfix-3.0
Content-Type: multipart/mixed;
 boundary="------------ACE2215AD47539991BF58E24"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>, Zdenek Kabelac <kabi+www@fi.muni.cz>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------ACE2215AD47539991BF58E24
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

Another attempt.

With this patch I get noticeable improvements in streaming write +16%!
(streaming write throughput is close to streaming read :-)

dbench results are mixed - slightly worse than plain test5-1...
It now survives mmap002, as opposed to vmfix-2.x :-)  there were
bugs of cause.

* Basic idea in this patch is to keep free pages of zones in the
  range [pages_high ... pages_low]. Kswapd will only run until
  one zone gets pages_high. In this situation pages from all zones
  are free able.
* In addition kswapd will run if any zone has less than pages_low.

* Actually implemented by using three values in zone_wake_kswapd
  0 = zone initially above pages_high, allocs allowed until zone
      gets < pages_low
  1 = zone < pages_low
 -1 = additional alloc done after zone become < pages_low
 Most of the time there will only be one zone to with
 zone_wake_kswapd zero. This zone will get the allocs until it
 also gets < pages_low, then kswapd starts and runs until any
 zone gets > pages_high - it will probably be another zone. Now
 that one gets the allocs, ...

* There are some additional stuff that needs cleaning / further
  investigations.


/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------ACE2215AD47539991BF58E24
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test5-1-vmfix.30"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test5-1-vmfix.30"

--- linux/mm/vmscan.c.orig	Sat Jul 15 23:44:34 2000
+++ linux/mm/vmscan.c	Wed Jul 19 20:27:20 2000
@@ -419,7 +419,7 @@ out:
 }
 
 /*
- * Check if there is any memory pressure (free_pages < pages_low)
+ * Check if there is any memory pressure (zone_wake_kswapd < 0)
  */
 static inline int memory_pressure(void)
 {
@@ -430,7 +430,7 @@ static inline int memory_pressure(void)
 		for(i = 0; i < MAX_NR_ZONES; i++) {
 			zone_t *zone = pgdat->node_zones+ i;
 			if (zone->size &&
-			    zone->free_pages < zone->pages_low)
+			    zone->zone_wake_kswapd < 0)
 				return 1;
 		}
 		pgdat = pgdat->node_next;
@@ -440,24 +440,31 @@ static inline int memory_pressure(void)
 }
 
 /*
- * Check if there recently has been memory pressure (zone_wake_kswapd)
+ * Check if any zone have recently been critical (low_on_memory)
+ * any zone with current memory pressure (zone_wake_kswapd < 0)
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
+			if (zone->size) {
+				if (zone->zone_wake_kswapd < 0 ||
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
@@ -496,9 +503,6 @@ static int do_try_to_free_pages(unsigned
 				goto done;
 		}
 
-		/* not (been) low on memory - it is
-		 * pointless to try to swap out.
-		 */
 		if (!keep_kswapd_awake())
 			goto done;
 
@@ -516,12 +520,10 @@ static int do_try_to_free_pages(unsigned
 			 * In the inner funtions there is a comment:
 			 * "To help debugging, a zero exit status indicates
 			 *  all slabs were released." (-arca?)
-			 * lets handle it in a primitive but working way...
+			 * remove it... to visualize the problem.
 			 *	if (count <= 0)
 			 *		goto done;
 			 */
-			if (!keep_kswapd_awake())
-				goto done;
 
 			while (shm_swap(priority, gfp_mask)) {
 				if (!--count)
@@ -596,10 +598,7 @@ int kswapd(void *unused)
 
 	for (;;) {
 		if (!keep_kswapd_awake()) {
-			/* wake up regulary to do an early attempt too free
-			 * pages - pages will not actually be freed.
-			 */
-			interruptible_sleep_on_timeout(&kswapd_wait, HZ);
+			interruptible_sleep_on(&kswapd_wait);
 		}
 
 		do_try_to_free_pages(GFP_KSWAPD);
@@ -628,24 +627,30 @@ int try_to_free_pages(unsigned int gfp_m
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
+++ linux/mm/page_alloc.c	Wed Jul 19 19:48:57 2000
@@ -30,7 +30,7 @@ pg_data_t *pgdat_list;
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
 static int zone_balance_ratio[MAX_NR_ZONES] = { 128, 128, 128, };
-static int zone_balance_min[MAX_NR_ZONES] = { 10 , 10, 10, };
+static int zone_balance_min[MAX_NR_ZONES] = {  10 , 10, 10, };
 static int zone_balance_max[MAX_NR_ZONES] = { 255 , 255, 255, };
 
 /*
@@ -141,8 +141,13 @@ void __free_pages_ok (struct page *page,
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 
+
 	if (zone->free_pages > zone->pages_high) {
-		zone->zone_wake_kswapd = 0;
+	  zone->zone_wake_kswapd = 0;
+	}
+	else if (zone->zone_wake_kswapd < 0 &&
+		 zone->free_pages > zone->pages_low) {
+		zone->zone_wake_kswapd = 1;
 		zone->low_on_memory = 0;
 	}
 }
@@ -217,7 +222,7 @@ static struct page * rmqueue(zone_t *zon
  */
 struct page * __alloc_pages(zonelist_t *zonelist, unsigned long order)
 {
-	zone_t **zone = zonelist->zones;
+	zone_t **zone;
 	extern wait_queue_head_t kswapd_wait;
 
 	/*
@@ -228,21 +233,6 @@ struct page * __alloc_pages(zonelist_t *
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
@@ -256,6 +246,16 @@ struct page * __alloc_pages(zonelist_t *
 			struct page *page = rmqueue(z, order);
 			if (z->free_pages < z->pages_low) {
 				z->zone_wake_kswapd = 1;
+
+				/* Usually zone_wake_kswapd is set to -1
+				 * on second alloc below pages_low
+				 * but if this was a big one
+				 * - do not let it pass unnoticed 
+				 */
+				if (z->free_pages < z->pages_low - MAX_ORDER) {
+					z->zone_wake_kswapd = -1;
+				}
+
 				if (waitqueue_active(&kswapd_wait))
 					wake_up_interruptible(&kswapd_wait);
 			}
@@ -264,6 +264,21 @@ struct page * __alloc_pages(zonelist_t *
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
@@ -275,8 +290,17 @@ struct page * __alloc_pages(zonelist_t *
 			break;
 		if (!z->low_on_memory) {
 			struct page *page = rmqueue(z, order);
-			if (z->free_pages < z->pages_min)
-				z->low_on_memory = 1;
+			if (z->free_pages < z->pages_low) {
+				z->zone_wake_kswapd = -1;
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
@@ -385,7 +409,10 @@ void show_free_areas_core(int nid)
 		zone_t *zone = NODE_DATA(nid)->node_zones + type;
  		unsigned long nr, total, flags;
 
-		printk("  %s: ", zone->name);
+		printk("  %s %ld (%ld %ld %ld) %d %d: ",
+		       zone->name, zone->free_pages,
+		       zone->pages_min, zone->pages_low, zone->pages_high,
+		       zone->zone_wake_kswapd, zone->low_on_memory);
 
 		total = 0;
 		if (zone->size) {
@@ -573,8 +600,8 @@ void __init free_area_init_core(int nid,
 		else if (mask > zone_balance_max[j])
 			mask = zone_balance_max[j];
 		zone->pages_min = mask;
-		zone->pages_low = mask*2;
-		zone->pages_high = mask*3;
+		zone->pages_low = mask*3;
+		zone->pages_high = mask*4;
 		zone->low_on_memory = 0;
 		zone->zone_wake_kswapd = 0;
 		zone->zone_mem_map = mem_map + offset;

--------------ACE2215AD47539991BF58E24--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
