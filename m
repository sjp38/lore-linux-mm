Received: from norran.net (roger@t1o43p44.telia.com [194.22.195.44])
	by d1o43.telia.com (8.8.8/8.8.8) with ESMTP id WAA21382
	for <linux-mm@kvack.org>; Thu, 22 Jun 2000 22:09:30 +0200 (CEST)
Message-ID: <395271CE.3188D809@norran.net>
Date: Thu, 22 Jun 2000 22:06:39 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] zoned and jiffies based vm
Content-Type: multipart/mixed;
 boundary="------------FC9B9294940EC90FB1E783B9"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------FC9B9294940EC90FB1E783B9
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

This is an attempt to try to solve the performance and CPU usage
problems in vm subsystem.

During the development of this patch I have found some interesting
things:

* Most read pages will end up as Referenced even if the PG_referenced
  bit is cleared when inserted into LRU - this is probably due to the
  pages being read ahead, and thus later referred...

Improvements/bugs in patch:

* does not handle age wrap of really old pages.

* does not use reused pointer.

* could use another counter (incremented at use) or
  mechanism instead (function that ages all pages at once).

* I am not sure how it will handle mmap002, forgot to run it before
  connecting to internet...

I am sending it as is since I will be away this weekend...

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------FC9B9294940EC90FB1E783B9
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test2-pre6-roger.jiffiesvm"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test2-pre6-roger.jiffiesvm"

diff -aur linux/include/linux/mm.h roger/include/linux/mm.h
--- linux/include/linux/mm.h	Fri May 12 21:16:14 2000
+++ roger/include/linux/mm.h	Thu Jun 22 21:35:33 2000
@@ -148,6 +148,8 @@
 	atomic_t count;
 	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
 	struct list_head lru;
+        unsigned long lru_born; /* at jiffies */
+        long lru_reused;         /* no of times reused */
 	wait_queue_head_t wait;
 	struct page **pprev_hash;
 	struct buffer_head * buffers;
@@ -196,7 +198,8 @@
 #define SetPageError(page)	set_bit(PG_error, &(page)->flags)
 #define ClearPageError(page)	clear_bit(PG_error, &(page)->flags)
 #define PageReferenced(page)	test_bit(PG_referenced, &(page)->flags)
-#define SetPageReferenced(page)	set_bit(PG_referenced, &(page)->flags)
+#define SetPageReferenced(page)	{(page)->lru_born = jiffies; set_bit(PG_referenced, &(page)->flags);}
+#define ClearPageReferenced(page)	clear_bit(PG_referenced, &(page)->flags)
 #define PageTestandClearReferenced(page)	test_and_clear_bit(PG_referenced, &(page)->flags)
 #define PageDecrAfter(page)	test_bit(PG_decr_after, &(page)->flags)
 #define SetPageDecrAfter(page)	set_bit(PG_decr_after, &(page)->flags)
diff -aur linux/include/linux/mmzone.h roger/include/linux/mmzone.h
--- linux/include/linux/mmzone.h	Fri May 12 21:16:13 2000
+++ roger/include/linux/mmzone.h	Thu Jun 22 21:35:33 2000
@@ -32,6 +32,9 @@
 	char			zone_wake_kswapd;
 	unsigned long		pages_min, pages_low, pages_high;
 
+        int                     nr_lru_pages;
+        struct list_head        lru_cache;
+
 	/*
 	 * free areas of different sizes
 	 */
diff -aur linux/include/linux/swap.h roger/include/linux/swap.h
--- linux/include/linux/swap.h	Fri May 12 21:16:13 2000
+++ roger/include/linux/swap.h	Thu Jun 22 21:35:33 2000
@@ -67,7 +67,6 @@
 FASTCALL(unsigned int nr_free_pages(void));
 FASTCALL(unsigned int nr_free_buffer_pages(void));
 FASTCALL(unsigned int nr_free_highpages(void));
-extern int nr_lru_pages;
 extern atomic_t nr_async_pages;
 extern struct address_space swapper_space;
 extern atomic_t page_cache_size;
@@ -165,16 +164,19 @@
  */
 #define	lru_cache_add(page)			\
 do {						\
+        zone_t *zone = (page)->zone;            \
 	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &lru_cache);	\
-	nr_lru_pages++;				\
+	list_add(&(page)->lru, &zone->lru_cache);	\
+        page->lru_born = jiffies;               \
+        page->lru_reused = 1;                   \
+	zone->nr_lru_pages++;				\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
 
 #define	__lru_cache_del(page)			\
 do {						\
 	list_del(&(page)->lru);			\
-	nr_lru_pages--;				\
+	(page)->zone->nr_lru_pages--;		\
 } while (0)
 
 #define	lru_cache_del(page)			\
diff -aur linux/mm/filemap.c roger/mm/filemap.c
--- linux/mm/filemap.c	Wed May 31 20:13:36 2000
+++ roger/mm/filemap.c	Thu Jun 22 21:35:05 2000
@@ -44,7 +44,7 @@
 atomic_t page_cache_size = ATOMIC_INIT(0);
 unsigned int page_hash_bits;
 struct page **page_hash_table;
-struct list_head lru_cache;
+long lru_pensionable_age = 60*HZ; 
 
 static spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
 /*
@@ -249,25 +249,109 @@
  * before doing sync writes.  We can only do sync writes if we can
  * wait for IO (__GFP_IO set).
  */
+int shrink_zone_mmap(zone_t *zone, int priority, int gfp_mask, int *recomend);
+
 int shrink_mmap(int priority, int gfp_mask)
 {
+  int ret = 0, modify_pensionable_age = 1;
+
+  /*
+   * alternative... from page_alloc.c
+   *
+   * for (i = 0; i < NUMNODES; i++)
+   *   for (zone = NODE_DATA(i)->node_zones;
+   *	 zone < NODE_DATA(i)->node_zones + MAX_NR_ZONES;
+   *     zone++)
+   */
+
+  pg_data_t *pgdat = pgdat_list;
+
+  do {
+    int i;
+    for(i = 0; i < MAX_NR_ZONES; i++) {
+      zone_t *zone = pgdat->node_zones+ i;
+      
+      /*
+       * do stuff, if from a zone we care about
+       */
+      if (zone->zone_wake_kswapd) {
+	int recomend;
+	ret += shrink_zone_mmap(zone, priority, gfp_mask, &recomend);
+
+	if (recomend < modify_pensionable_age) {
+	  modify_pensionable_age = recomend;
+	}
+      }
+
+    }
+    pgdat = pgdat->node_next;
+  } while (pgdat);
+
+  /* all pages in all zones with pressure scanned, time to modify */
+  if (modify_pensionable_age < 0) {
+    lru_pensionable_age /= 2;
+  }
+  else if (modify_pensionable_age > 0) {
+    lru_pensionable_age += HZ;
+  }
+
+  return ret;
+}
+
+int shrink_zone_mmap(zone_t *zone, int priority, int gfp_mask, int *recomend)
+{
 	int ret = 0, count, nr_dirty;
+	long page_age = 0;
+	int pages_scanned = 0;
 	struct list_head * page_lru;
 	struct page * page = NULL;
+
+	/* debug */
+	int  pages_referenced = 0;
+	long page_age_sum = 0;
+	long page_age_min = +24*60*60*HZ;
+	long page_age_max = -24*60*60*HZ;
 	
-	count = nr_lru_pages / (priority + 1);
+	count = zone->nr_lru_pages / (priority + 1);
 	nr_dirty = priority;
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	while (count > 0 && zone->zone_wake_kswapd &&
+	       (page_lru = zone->lru_cache.prev) != &zone->lru_cache) {
+
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
-		if (PageTestandClearReferenced(page))
-			goto dispose_continue;
+		/* debug, lru_born is set when marked as referenced */
+		if (PageTestandClearReferenced(page)) {
+		        page->lru_reused++;
+			pages_referenced++;
+		}
+
+		page_age = (long)(jiffies - page->lru_born);
+		pages_scanned++;
+
+		/* debug vars */
+		if (page_age < page_age_min) page_age_min = page_age;
+		if (page_age > page_age_max) page_age_max = page_age;
+		page_age_sum += page_age;
+
+		if (pages_scanned > zone->nr_lru_pages) {
+
+		  list_add(page_lru, &zone->lru_cache); /* goto dispose_continue */
+		  /* all pages scanned without result, indicate to caller */
+		  *recomend = -1;
+
+		  page_age = -1;
+		  goto out;
+		}
+
+		if (page_age < lru_pensionable_age)
+		  goto dispose_continue;
 
 		count--;
+
 		/*
 		 * Avoid unscalable SMP locking for pages we can
 		 * immediate tell are untouchable..
@@ -327,13 +411,6 @@
 			goto made_inode_progress;
 		}	
 
-		/*
-		 * Page is from a zone we don't care about.
-		 * Don't drop page cache entries in vain.
-		 */
-		if (page->zone->free_pages > page->zone->pages_high)
-			goto cache_unlock_continue;
-
 		/* is it a page-cache page? */
 		if (page->mapping) {
 			if (!PageDirty(page) && !pgcache_under_min()) {
@@ -345,6 +422,20 @@
 		}
 
 		printk(KERN_ERR "shrink_mmap: unknown LRU page!\n");
+		goto cache_unlock_continue;
+
+
+made_inode_progress:
+		page_cache_release(page);
+made_buffer_progress:
+		UnlockPage(page);
+		page_cache_release(page);
+		ret++;
+		spin_lock(&pagemap_lru_lock);
+		/* nr_lru_pages needs the spinlock */
+		zone->nr_lru_pages--;
+
+		continue;
 
 cache_unlock_continue:
 		spin_unlock(&pagecache_lock);
@@ -353,22 +444,22 @@
 		UnlockPage(page);
 		page_cache_release(page);
 dispose_continue:
-		list_add(page_lru, &lru_cache);
+		list_add(page_lru, &zone->lru_cache);
 	}
-	goto out;
 
-made_inode_progress:
-	page_cache_release(page);
-made_buffer_progress:
-	UnlockPage(page);
-	page_cache_release(page);
-	ret = 1;
-	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
+	if (zone->zone_wake_kswapd)
+	  *recomend = 0;
+	else
+	  *recomend = +1;
 
 out:
 	spin_unlock(&pagemap_lru_lock);
+
+	printk(KERN_DEBUG "lru %s %3d(%3d) %5ld>%5ld [%5ld %5ld %5ld]\n",
+	       zone->name,
+	       ret, pages_scanned,
+	       page_age, lru_pensionable_age,
+	       page_age_min, page_age_sum / pages_scanned, page_age_max);
 
 	return ret;
 }
diff -aur linux/mm/page_alloc.c roger/mm/page_alloc.c
--- linux/mm/page_alloc.c	Fri May 12 20:21:20 2000
+++ roger/mm/page_alloc.c	Thu Jun 22 21:35:05 2000
@@ -25,7 +25,6 @@
 #endif
 
 int nr_swap_pages;
-int nr_lru_pages;
 pg_data_t *pgdat_list;
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
@@ -313,6 +312,22 @@
 }
 
 /*
+ * Total amount of free (allocatable) RAM:
+ */
+unsigned int nr_lru_pages (void)
+{
+	unsigned int sum;
+	zone_t *zone;
+	int i;
+
+	sum = 0;
+	for (i = 0; i < NUMNODES; i++)
+		for (zone = NODE_DATA(i)->node_zones; zone < NODE_DATA(i)->node_zones + MAX_NR_ZONES; zone++)
+			sum += zone->nr_lru_pages;
+	return sum;
+}
+
+/*
  * Amount of free RAM allocatable as buffer memory:
  */
 unsigned int nr_free_buffer_pages (void)
@@ -321,10 +336,10 @@
 	zone_t *zone;
 	int i;
 
-	sum = nr_lru_pages;
+	sum = 0;
 	for (i = 0; i < NUMNODES; i++)
 		for (zone = NODE_DATA(i)->node_zones; zone <= NODE_DATA(i)->node_zones+ZONE_NORMAL; zone++)
-			sum += zone->free_pages;
+			sum += zone->free_pages + zone->nr_lru_pages;
 	return sum;
 }
 
@@ -356,7 +371,7 @@
 
 	printk("( Free: %d, lru_cache: %d (%d %d %d) )\n",
 		nr_free_pages(),
-		nr_lru_pages,
+		nr_lru_pages(),
 		freepages.min,
 		freepages.low,
 		freepages.high);
@@ -497,7 +512,6 @@
 	freepages.min += i;
 	freepages.low += i * 2;
 	freepages.high += i * 3;
-	memlist_init(&lru_cache);
 
 	/*
 	 * Some architectures (with lots of mem and discontinous memory
@@ -543,6 +557,10 @@
 		zone->lock = SPIN_LOCK_UNLOCKED;
 		zone->zone_pgdat = pgdat;
 		zone->free_pages = 0;
+
+		zone->nr_lru_pages = 0;
+		memlist_init(&zone->lru_cache);
+
 		if (!size)
 			continue;
 
diff -aur linux/mm/vmscan.c roger/mm/vmscan.c
--- linux/mm/vmscan.c	Wed May 31 20:13:37 2000
+++ roger/mm/vmscan.c	Thu Jun 22 21:35:05 2000
@@ -436,14 +436,16 @@
 	int priority;
 	int count = FREE_COUNT;
 	int swap_count;
+	int progress;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
 	priority = 64;
 	do {
-		while (shrink_mmap(priority, gfp_mask)) {
-			if (!--count)
+		while ((progress = shrink_mmap(priority, gfp_mask)) > 0) {
+		        count -= progress;
+			if (count <= 0)
 				goto done;
 		}
 
@@ -480,8 +482,9 @@
 	} while (--priority >= 0);
 
 	/* Always end on a shrink_mmap.. */
-	while (shrink_mmap(0, gfp_mask)) {
-		if (!--count)
+	while ((progress = shrink_mmap(0, gfp_mask)) > 0) {
+	        count -= progress;
+		if (count <= 0)
 			goto done;
 	}
 	/* We return 1 if we are freed some page */
@@ -491,6 +494,27 @@
 	return 1;
 }
 
+
+static int memory_pressure()
+{
+  pg_data_t *pgdat;
+
+  pgdat = pgdat_list;
+  do {
+    int i;
+    for(i = 0; i < MAX_NR_ZONES; i++) {
+      zone_t *zone = pgdat->node_zones+ i;
+      if (zone->size &&
+	  zone->free_pages < zone->pages_low) {
+	return 1;
+      }
+    }
+    pgdat = pgdat->node_next;
+  } while (pgdat);
+
+  return 0;
+}
+
 DECLARE_WAIT_QUEUE_HEAD(kswapd_wait);
 
 /*
@@ -530,29 +554,16 @@
 	tsk->flags |= PF_MEMALLOC;
 
 	for (;;) {
-		pg_data_t *pgdat;
-		int something_to_do = 0;
+	  if (memory_pressure()) {
+	    do_try_to_free_pages(GFP_KSWAPD);
 
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
-		}
+	    if (tsk->need_resched)
+	      schedule();
+	  }
+	  else {
+	    tsk->state = TASK_INTERRUPTIBLE;
+	    interruptible_sleep_on(&kswapd_wait);
+	  }
 	}
 }
 

--------------FC9B9294940EC90FB1E783B9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
