Received: from norran.net (roger@t8o43p54.telia.com [194.237.168.234])
	by d1o43.telia.com (8.8.8/8.8.8) with ESMTP id BAA24814
	for <linux-mm@kvack.org>; Fri, 9 Jun 2000 01:55:28 +0200 (CEST)
Message-ID: <394031EB.BA9EEA@norran.net>
Date: Fri, 09 Jun 2000 01:53:15 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: reduce swap due to shrink_mmap failures
Content-Type: multipart/mixed;
 boundary="------------D3C4FF966BDBAF0EBEBF59AD"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------D3C4FF966BDBAF0EBEBF59AD
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

This is an improved version that reduces failures
due to calling it with no zones with pressure...

It has some problems related to latency
(as normal kernel) probably due to the maximum of
64 loops in do_try_to_free_pages...
[might it be time to back off some of earlier patches?]

It has survived several memory tests (mmap002)
and with good performance in more normal situations.
[it could 'scan' more before giving up in shrink_mmap]

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------D3C4FF966BDBAF0EBEBF59AD
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test1-ac10-rogerl.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test1-ac10-rogerl.2"

--- /usr/src/linux/mm/filemap.c.ac10	Wed Jun  7 23:42:27 2000
+++ /usr/src/linux/mm/filemap.c	Fri Jun  9 00:14:48 2000
@@ -301,7 +301,7 @@
  */
 int shrink_mmap(int priority, int gfp_mask)
 {
-	int ret = 0, count, nr_dirty;
+	int ret = 0, count, nr_dirty, scan = 0;
 	struct list_head * page_lru;
 	struct page * page = NULL;
 	
@@ -310,20 +310,44 @@
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	page_lru = &lru_cache;
+	while (count > 0) {
+                page_lru = page_lru->prev;
+                if (page_lru == &lru_cache) {
+		  /* one whole run, ALL lru pages aged */
+		  scan++;
+		  if (scan < 2)
+		    continue;
+		  else
+		    /* a) no freeable pages in LRU
+		     * b) no zone with preasure
+		     */
+		    break;
+		}
+
 		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
 
 		if (PageTestandClearReferenced(page)) {
 			page->age += PG_AGE_ADV;
 			if (page->age > PG_AGE_MAX)
 				page->age = PG_AGE_MAX;
-			goto dispose_continue;
+			continue;
 		}
+
+		/*
+		 * Page is from a zone we don't care about.
+		 * Don't drop page cache entries in vain.
+		 * Note: placement allows pages to gain age during
+		 * fast scan, but not loose - avoids all pages
+		 * becoming zero.
+		 */
+		if (page->zone->free_pages > page->zone->pages_high)
+			continue;
+
 		page->age -= min(PG_AGE_DECL, page->age);
 
 		if (page->age)
-			goto dispose_continue;
+			continue;
 
 		count--;
 		/*
@@ -331,10 +355,34 @@
 		 * immediate tell are untouchable..
 		 */
 		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
+			continue;
 
 		if (TryLockPage(page))
-			goto dispose_continue;
+			continue;
+
+		/* Move header before unlock...
+		 * NOTE: the page to scan might move on while having
+		 * pagemap_lru unlocked. Avoid rescanning pages
+		 * by moving head and removing current.
+		 */
+
+		/*
+		 * Equivalent code follows
+		 *
+		 *   list_del(&lru_cache);
+		 *   list_add_tail(&lru_cache, page_lru);
+		 *   list_del(page_lru);
+		 */
+		if (lru_cache.prev == page_lru) {
+		  /* Handle case with only one page on lru...
+		   * also optimize if first page checked is suitable.
+		   */
+		  list_del(page_lru);
+		}
+		else {
+		  list_del(&lru_cache);
+		  __list_add(&lru_cache, page_lru->prev, page_lru->next);
+		}
 
 		/* Release the pagemap_lru lock even if the page is not yet
 		   queued in any lru queue since we have just locked down
@@ -361,13 +409,6 @@
 			}
 		}
 
-		/*
-		 * Page is from a zone we don't care about.
-		 * Don't drop page cache entries in vain.
-		 */
-		if (page->zone->free_pages > page->zone->pages_high)
-			goto unlock_continue;
-
 		/* Take the pagecache_lock spinlock held to avoid
 		   other tasks to notice the page while we are looking at its
 		   page count. If it's a pagecache-page we'll free it
@@ -424,7 +465,11 @@
 		UnlockPage(page);
 		page_cache_release(page);
 dispose_continue:
+		/* page_lru was deleted from list. Reinsert it at _new_
+		 * lru_cache location
+		 */
 		list_add(page_lru, &lru_cache);
+		page_lru =  &lru_cache;
 	}
 	goto out;
 
--- /usr/src/linux/mm/vmscan.c.ac10	Wed Jun  7 23:42:18 2000
+++ /usr/src/linux/mm/vmscan.c	Fri Jun  9 01:22:05 2000
@@ -427,6 +427,31 @@
 	return __ret;
 }
 
+/* return value is bit mapped */
+static int analyze_zones_pressure(void)
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
@@ -445,18 +470,26 @@
 	int count = FREE_COUNT;
 	int swap_count = 0;
 	int ret = 0;
+	int pressure;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
-	priority = 64;
+	priority = 64; /* NOT good for latency - might loop 64 times... */
 	do {
+	        pressure = analyze_zones_pressure();
+		if (!pressure)
+		  break;
+
 		while (shrink_mmap(priority, gfp_mask)) {
 			ret = 1;
 			if (!--count)
 				goto done;
 		}
 
+		pressure = analyze_zones_pressure();
+		if (!pressure)
+		  break;
 
 		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
@@ -465,6 +498,7 @@
 		   	 * shrink_mmap() almost never fail when there's
 		   	 * really plenty of memory free. 
 			 */
+		  /* Note: these functions has FIXME comments... */
 			count -= shrink_dcache_memory(priority, gfp_mask);
 			count -= shrink_icache_memory(priority, gfp_mask);
 			if (count <= 0) {
@@ -478,6 +512,10 @@
 			}
 		}
 
+		pressure = analyze_zones_pressure();
+		if (!pressure)
+		  break;
+
 		/*
 		 * Then, try to page stuff out..
 		 *
@@ -499,8 +537,10 @@
 
 	} while (--priority >= 0);
 
+	pressure = analyze_zones_pressure();
+
 	/* Always end on a shrink_mmap.. */
-	while (shrink_mmap(0, gfp_mask)) {
+	while (pressure && shrink_mmap(0, gfp_mask)) {
 		ret = 1;
 		if (!--count)
 			goto done;
@@ -549,26 +589,23 @@
 	tsk->flags |= PF_MEMALLOC;
 
 	for (;;) {
-		pg_data_t *pgdat;
-		int something_to_do = 0;
+	        int pressure = analyze_zones_pressure();
 
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
+		/* Need to free pages?
+		 * Will actually run fewer times than previous version!
+		 * (It did run once per zone with waken kswapd)
+		 */
+		if (pressure) { 
+		  do_try_to_free_pages(GFP_KSWAPD);
+		}
 
-		if (!something_to_do) {
+		/* In a hurry? */
+		if (pressure > 1) {
+		        if (tsk->need_resched) {
+		           schedule();
+			}
+		}
+		else {
 			tsk->state = TASK_INTERRUPTIBLE;
 			interruptible_sleep_on(&kswapd_wait);
 		}

--------------D3C4FF966BDBAF0EBEBF59AD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
