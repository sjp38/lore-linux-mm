Message-ID: <392AA3D5.FD6B5399@norran.net>
Date: Tue, 23 May 2000 17:29:25 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH--] Re: Linux VM/IO balancing (fwd to linux-mm?) (fwd)
References: <Pine.LNX.4.21.0005230934240.19121-100000@duckman.distro.conectiva>
Content-Type: multipart/mixed;
 boundary="------------6AEA0E9B0F30D4BC4EB40ED5"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------6AEA0E9B0F30D4BC4EB40ED5
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

From: Matthew Dillon <dillon@apollo.backplane.com>
>     The algorithm is a *modified* LRU.  Lets say you decide on a weighting
>     betweeen 0 and 10.  When a page is first allocated (either to the
>     buffer cache or for anonymous memory) its statistical weight is
>     set to the middle (5).  If the page is used often the statistical 
>     weight slowly rises to its maximum (10).  If the page remains idle
>     (or was just used once) the statistical weight slowly drops to its
>     minimum (0).


My patches has been approaching this a while... [slowly...]
The currently included patch adds has divided lru in four lists [0..3].
New pages are added at level 1.
Scan is performed - and referenced pages are moved up.

Pages are moved down due to list balancing, but I have been playing with
other ideas.

These patches should be a good continuation point.
Patches are against pre9-3 with Quintela applied.

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------6AEA0E9B0F30D4BC4EB40ED5
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.3.99-pre9.3-q-shrink_mmap.3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.3.99-pre9.3-q-shrink_mmap.3"

diff -aur linux-2.3.99-pre9.3-q/include/linux/mm.h linux/include/linux/mm.h
--- linux-2.3.99-pre9.3-q/include/linux/mm.h	Fri May 12 21:16:14 2000
+++ linux/include/linux/mm.h	Mon May 22 23:30:15 2000
@@ -15,7 +15,7 @@
 extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
-extern struct list_head lru_cache;
+extern struct list_head * new_lru_cache;
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -456,6 +456,8 @@
 extern void remove_inode_page(struct page *);
 extern unsigned long page_unuse(struct page *);
 extern int shrink_mmap(int, int);
+extern int age_mmap(void);
+extern void lru_cache_init(void);
 extern void truncate_inode_pages(struct address_space *, loff_t);
 
 /* generic vm_area_ops exported for stackable file systems */
diff -aur linux-2.3.99-pre9.3-q/include/linux/swap.h linux/include/linux/swap.h
--- linux-2.3.99-pre9.3-q/include/linux/swap.h	Fri May 12 21:16:13 2000
+++ linux/include/linux/swap.h	Mon May 22 23:30:19 2000
@@ -166,7 +166,7 @@
 #define	lru_cache_add(page)			\
 do {						\
 	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &lru_cache);	\
+	list_add(&(page)->lru, new_lru_cache);	\
 	nr_lru_pages++;				\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
diff -aur linux-2.3.99-pre9.3-q/mm/filemap.c linux/mm/filemap.c
--- linux-2.3.99-pre9.3-q/mm/filemap.c	Mon May 22 22:25:51 2000
+++ linux/mm/filemap.c	Tue May 23 16:36:41 2000
@@ -44,7 +44,10 @@
 atomic_t page_cache_size = ATOMIC_INIT(0);
 unsigned int page_hash_bits;
 struct page **page_hash_table;
-struct list_head lru_cache;
+
+#define NR_OF_LRU_LISTS 4
+static struct list_head lru_cache[NR_OF_LRU_LISTS]; // pages removed from low
+struct list_head * new_lru_cache = &lru_cache[1];   // here goes new pages
 
 static spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
 /*
@@ -249,20 +252,19 @@
  * before doing sync writes.  We can only do sync writes if we can
  * wait for IO (__GFP_IO set).
  */
-int shrink_mmap(int priority, int gfp_mask)
+static unsigned long shrink_mmap_referenced_moved; /* debug only? */
+
+static inline int
+ _shrink_mmap(struct list_head *lru_head,
+	      int gfp_mask, int *toscan, int *toskipwait)
 {
-	int ret = 0, count, nr_dirty;
-	struct list_head * page_lru;
+        int ret = 0, count = *toscan, nr_dirty = *toskipwait;
+
+	struct list_head * page_lru = lru_head;
 	struct page * page = NULL;
-	
-	count = nr_lru_pages / (priority + 1);
-	nr_dirty = priority;
 
-	/* we need pagemap_lru_lock for list_del() ... subtle code below */
-	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	while (count > 0 && (page_lru = page_lru->prev) != lru_head) {
 		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
 
 		count--;
 		if (PageTestandClearReferenced(page))
@@ -273,10 +275,12 @@
 		 * immediate tell are untouchable..
 		 */
 		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
+		  continue;
 
+		/* Lock this lru page, reentrant
+		 * will be disposed correctly when unlocked */
 		if (TryLockPage(page))
-			goto dispose_continue;
+			continue;
 
 		/* Release the pagemap_lru lock even if the page is not yet
 		   queued in any lru queue since we have just locked down
@@ -352,26 +356,171 @@
 		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
 		page_cache_release(page);
+		continue;
+
 dispose_continue:
-		list_add(page_lru, &lru_cache);
-	}
-	goto out;
+		/* have the pagemap_lru_lock, lru cannot change */
+		/* Move it to top of this list with referenced cleared
+		 * to give a chance for progress even when running without
+		 * kswapd...
+		 */
+		{
+		  struct list_head * page_lru_to_move = page_lru; 
+		  page_lru = page_lru->next; /* continues with page_lru.prev */
+		  list_del(page_lru_to_move);
+		  list_add(page_lru_to_move, lru_head);
+		  shrink_mmap_referenced_moved++;
+		}
+		continue;
 
 made_inode_progress:
-	page_cache_release(page);
+		page_cache_release(page);
 made_buffer_progress:
-	UnlockPage(page);
-	page_cache_release(page);
-	ret = 1;
+		/* like to have the lru lock before UnlockPage */
+		spin_lock(&pagemap_lru_lock);
+
+		UnlockPage(page);
+
+		/* lru manipulation needs the spin lock */
+		{
+		  struct list_head * page_lru_to_free = page_lru; 
+		  page_lru = page_lru->next; /* continues with page_lru.prev */
+		  list_del(page_lru_to_free);
+		}
+
+		/* nr_lru_pages needs the spinlock */
+		page_cache_release(page);
+		ret++;
+		nr_lru_pages--;
+
+	}
+
+	*toskipwait = nr_dirty;
+	*toscan = count;
+	return ret;
+}
+
+int shrink_mmap(int priority, int gfp_mask)
+{
+	int ret = 0, count, ix, nr_dirty;
+	
+	count = nr_lru_pages >> priority;
+	nr_dirty = 1 << priority; /* magic number */
+
+	/* we need pagemap_lru_lock for list_del() ... subtle code below */
+	/* NOTE: we could have a lock per list... */
 	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
 
-out:
+	for (ix = 0; ix < NR_OF_LRU_LISTS; ix ++)
+	  ret += _shrink_mmap(&lru_cache[ix], gfp_mask, &count, &nr_dirty);
+
 	spin_unlock(&pagemap_lru_lock);
 
 	return ret;
 }
+
+/* called with pagemap_lru_lock locked! */
+
+struct age_pyramid
+{
+  int number_of;
+  int moved_up;
+  int moved_down;
+};
+
+static inline void
+ _age_mmap_list(struct list_head *page_lru_head,
+		struct list_head *dispose_up,
+		struct list_head *dispose_down,
+		struct age_pyramid *statistics)
+{
+  struct list_head * page_lru = page_lru_head;
+  struct list_head * dispose = NULL;
+  struct page * page;
+
+  int balance = nr_lru_pages / NR_OF_LRU_LISTS;
+
+  statistics->number_of = 0;
+  statistics->moved_up = 0;
+  statistics->moved_down = 0;
+
+  while ((page_lru = page_lru->prev) != page_lru_head) {
+    page = list_entry(page_lru, struct page, lru);
+
+    balance--;
+      
+    if (PageTestandClearReferenced(page)) {
+      dispose = dispose_up;
+      statistics->moved_up++;
+    }
+    else if (balance < 0) {
+      dispose = dispose_down;
+      statistics->moved_down++;
+    }
+    else {
+      statistics->number_of++;
+    }
+
+    /* dispose the page */
+    if (dispose)
+    {
+      struct list_head * page_lru_to_move = page_lru; 
+      page_lru = page_lru->next; /* continues with page_lru.prev */
+      list_del(page_lru_to_move);
+      list_add(page_lru_to_move, dispose);
+    }
+  }
+}
+
+int age_mmap(void)
+{
+	LIST_HEAD(referenced);
+
+	struct list_head * dispose_up;
+
+	int moved_pre, ix;
+	struct age_pyramid stat[NR_OF_LRU_LISTS];
+
+	spin_lock(&pagemap_lru_lock);
+
+	/* Scanned in shrink_mmap ? */
+	moved_pre = shrink_mmap_referenced_moved;
+	shrink_mmap_referenced_moved = 0;
+
+	/* Scan new list first */
+	dispose_up = &referenced;
+	for (ix = NR_OF_LRU_LISTS - 1; ix > 0; ix--) {
+	  _age_mmap_list(&lru_cache[ix],
+			 dispose_up,
+			 &lru_cache[ix - 1],
+			 &stat[ix]);
+	  dispose_up = &lru_cache[ix];
+	}
+	_age_mmap_list(&lru_cache[ix], dispose_up, NULL, &stat[ix]);
+
+	/* referenced pages in top list go top of lru_cache (same list) */
+	list_splice(&referenced, &lru_cache[NR_OF_LRU_LISTS - 1]);
+
+	spin_unlock(&pagemap_lru_lock);
+
+	printk(KERN_DEBUG "age_mmap: [%4d %4d<%4d>%4d %4d<%4d>%4d %4d<%4d>%4d / %6d]\n",
+	       moved_pre,
+	       stat[0].moved_down, stat[0].number_of, stat[0].moved_up,
+	       stat[1].moved_down, stat[1].number_of, stat[1].moved_up,
+	       stat[2].moved_down, stat[2].number_of, stat[2].moved_up,
+	       nr_lru_pages);
+
+	return 0; /* until it is known what to return... */
+}
+ 
+
+void lru_cache_init(void)
+{
+  int ix;
+  for (ix = 0; ix < NR_OF_LRU_LISTS; ix++)
+	INIT_LIST_HEAD(&lru_cache[ix]);
+}
+
 
 static inline struct page * __find_page_nolock(struct address_space *mapping, unsigned long offset, struct page *page)
 {
diff -aur linux-2.3.99-pre9.3-q/mm/page_alloc.c linux/mm/page_alloc.c
--- linux-2.3.99-pre9.3-q/mm/page_alloc.c	Fri May 12 20:21:20 2000
+++ linux/mm/page_alloc.c	Mon May 22 22:37:55 2000
@@ -497,7 +497,8 @@
 	freepages.min += i;
 	freepages.low += i * 2;
 	freepages.high += i * 3;
-	memlist_init(&lru_cache);
+
+	lru_cache_init();
 
 	/*
 	 * Some architectures (with lots of mem and discontinous memory
diff -aur linux-2.3.99-pre9.3-q/mm/vmscan.c linux/mm/vmscan.c
--- linux-2.3.99-pre9.3-q/mm/vmscan.c	Mon May 22 22:25:51 2000
+++ linux/mm/vmscan.c	Tue May 23 00:11:23 2000
@@ -363,7 +363,7 @@
 	 * Think of swap_cnt as a "shadow rss" - it tells us which process
 	 * we want to page out (always try largest first).
 	 */
-	counter = (nr_threads << 2) >> (priority >> 2);
+	counter = (nr_threads << 1) >> (priority >> 1);
 	if (counter < 1)
 		counter = 1;
 
@@ -435,17 +435,15 @@
 {
 	int priority;
 	int count = FREE_COUNT;
-	int swap_count;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
-	priority = 64;
+	priority = 6;
 	do {
-		while (shrink_mmap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
+	        count -= shrink_mmap(priority, gfp_mask);
+		if (count <= 0)
+		  goto done;
 
 
 		/* Try to get rid of some shared memory pages.. */
@@ -472,18 +470,20 @@
 		 * put in the swap cache), so we must not count this
 		 * as a "count" success.
 		 */
-		swap_count = SWAP_COUNT;
-		while (swap_out(priority, gfp_mask))
-			if (--swap_count < 0)
-				break;
+		{
+			int swap_count = SWAP_COUNT;
+			while (swap_out(priority, gfp_mask))
+				if (--swap_count < 0)
+					break;
+		}
 
 	} while (--priority >= 0);
 
 	/* Always end on a shrink_mmap.. */
-	while (shrink_mmap(0, gfp_mask)) {
-		if (!--count)
-			goto done;
-	}
+	count -= shrink_mmap(0, gfp_mask);
+	if (count <= 0)
+	  goto done;
+
 	/* We return 1 if we are freed some page */
 	return (count != FREE_COUNT);
 
@@ -543,15 +543,52 @@
 				if (!zone->size || !zone->zone_wake_kswapd)
 					continue;
 				if (zone->free_pages < zone->pages_low)
-					something_to_do = 1;
-				do_try_to_free_pages(GFP_KSWAPD);
+					something_to_do += 100;
+
+				something_to_do += 1;
+
+				printk(KERN_DEBUG
+				       "kswapd: low memory zone: %s (%ld)\n",
+				       zone->name, zone->free_pages
+				       );
 			}
 			pgdat = pgdat->node_next;
 		} while (pgdat);
 
-		if (!something_to_do) {
+		if (something_to_do) {
+		  do_try_to_free_pages(GFP_KSWAPD);
+		  run_task_queue(&tq_disk);
+		  printk(KERN_DEBUG "kswapd: to do %d - done\n", something_to_do);
+		}
+
+		/* Always sleep - give requestors a chance to use
+		 * freed pages. Even low prio ones - they might be
+		 * the only ones.
+		 */
+
+		/* Do not depend on kswapd.. it should be able to sleep
+		 * sleep time is possible to trim:
+		 * - function of pages aged?
+		 * - function of something_to_do?
+		 * - free_pages?
+		 * right now 1s periods, wakeup possible */
+		if (something_to_do < MAX_NR_ZONES/2 + 1)
+		{
+			static long aging_time = 0L;
+			if (aging_time == 0L) {
+			  aging_time = 1L*HZ;
+			}
+
 			tsk->state = TASK_INTERRUPTIBLE;
-			interruptible_sleep_on(&kswapd_wait);
+			aging_time = interruptible_sleep_on_timeout(&kswapd_wait, 1*HZ);
+
+			/* age after wakeup, slept at least one jiffie or have
+			 * been waken up - a lot might have happened.
+			 */
+			(void)age_mmap();
+		}
+		else if (tsk->need_resched) {
+		        schedule();
 		}
 	}
 }

--------------6AEA0E9B0F30D4BC4EB40ED5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
