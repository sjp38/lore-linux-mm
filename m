Subject: PATCH: Improvements in shrink_mmap and kswapd (take 2)
References: <ytt3dmcyli7.fsf@serpe.mitica>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "18 Jun 2000 00:45:52 +0200"
Date: 20 Jun 2000 01:15:16 +0200
Message-ID: <yttn1khp8jf.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi

        here appear to give similar results as ac22-riel, but
        shouldn't degenerate in bad behaviour as fast as ac22-riel in
        tests like Zlatko. 

Reports of success/failure are welcome.  Comments are also welcome.

Later, Juan.

take 1 comments:
>         this patch makes kswapd use less resources.  It should solve
> the kswapd eats xx% of my CPU problems.  It appears that it improves
> IO a bit here.  Could people having problems with IO told me if this
> patch improves things, I am interested in knowing that it don't makes
> things worst never.  This patch is stable here.  I am finishing the
> deferred mmaped pages form file writing patch, that should solve
> several other problems.

        This patch implements:

take 2:
------
- against ac22-riel
- fixes the problems with test_and_test_and_clear_bit (thanks Roger
     Larson and Philipp Rumpf)
- Reintroduces the page->zone test dropped in ac21
- call to wakeup_bdflush() at the end of shrink_mmap (thanks Rick Riel)
- the rest of Riel suggestions haven't been introduced, they need
  infraestructure changes in buffer.c that I am studing.

take 1:
------
- never loops infinitely is shrink_mmap (it walks as maximum once per
  page)
- it changes the nr_dirty logic to max_launder_page logic.  We start
  writing async a maximum of max_launder_page (100), and after that
  point we never start more writes for that run of shrink_mmap.  If we
  start max_launder_page writes, we wait at the end of the function if
  possible (i.e __gfp_mask let do that).
- It checks that there is some zone with need of pages before continue
  with the loop.  If there is no pages, stop walking the LRU.
- I have got the patch from Roger Larson for the memory pressure and
  have partially re implemented/increasing it.
- kswapd rewrite in similar way that Roger Larson one.
- added the function memory_pressure that returns 1 if there is
  memory_pressure and 0 if there is no pressure.
- I have got Manfred patch to use test_and_test_and_clear_bit
  optimization in ClearPageReferenced.
- Added ClearPageDirty(page) to __remove_inode_pages to solve the
  ramfs problems.
- Added __lru_cache_del and __lru_cache_add and use them in
  shrink_mmap.
- Makes a cleanup of several cruft in shirk_mmap.


diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/include/asm-i386/bitops.h working/include/asm-i386/bitops.h
--- base/include/asm-i386/bitops.h	Mon Jun 19 23:46:11 2000
+++ working/include/asm-i386/bitops.h	Tue Jun 20 00:12:49 2000
@@ -29,6 +29,7 @@
 extern void change_bit(int nr, volatile void * addr);
 extern int test_and_set_bit(int nr, volatile void * addr);
 extern int test_and_clear_bit(int nr, volatile void * addr);
+extern int test_and_test_and_clear_bit(int nr, volatile void * addr);
 extern int test_and_change_bit(int nr, volatile void * addr);
 extern int __constant_test_bit(int nr, const volatile void * addr);
 extern int __test_bit(int nr, volatile void * addr);
@@ -123,6 +124,15 @@
 (__builtin_constant_p(nr) ? \
  __constant_test_bit((nr),(addr)) : \
  __test_bit((nr),(addr)))
+
+extern __inline__ int test_and_test_and_clear_bit(int nr, volatile void *addr)
+{
+	if(!test_bit(nr,addr))
+		return 0;
+	return test_and_clear_bit(nr,addr);
+}
+
+
 
 /*
  * Find-bit routines..
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/include/linux/mm.h working/include/linux/mm.h
--- base/include/linux/mm.h	Mon Jun 19 23:46:11 2000
+++ working/include/linux/mm.h	Tue Jun 20 00:13:00 2000
@@ -203,7 +203,7 @@
 #define PageReferenced(page)	test_bit(PG_referenced, &(page)->flags)
 #define SetPageReferenced(page)	set_bit(PG_referenced, &(page)->flags)
 #define ClearPageReferenced(page)	clear_bit(PG_referenced, &(page)->flags)
-#define PageTestandClearReferenced(page)	test_and_clear_bit(PG_referenced, &(page)->flags)
+#define PageTestandClearReferenced(page)	test_and_test_and_clear_bit(PG_referenced, &(page)->flags)
 #define PageDecrAfter(page)	test_bit(PG_decr_after, &(page)->flags)
 #define SetPageDecrAfter(page)	set_bit(PG_decr_after, &(page)->flags)
 #define PageTestandClearDecrAfter(page)	test_and_clear_bit(PG_decr_after, &(page)->flags)
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/include/linux/swap.h working/include/linux/swap.h
--- base/include/linux/swap.h	Mon Jun 19 23:46:26 2000
+++ working/include/linux/swap.h	Tue Jun 20 00:04:12 2000
@@ -87,6 +87,7 @@
 
 /* linux/mm/vmscan.c */
 extern int try_to_free_pages(unsigned int gfp_mask);
+extern int memory_pressure(void);
 
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, struct page *, int);
@@ -173,11 +174,17 @@
 /*
  * Helper macros for lru_pages handling.
  */
-#define	lru_cache_add(page)			\
+
+#define	__lru_cache_add(page)			\
 do {						\
-	spin_lock(&pagemap_lru_lock);		\
 	list_add(&(page)->lru, &lru_cache);	\
 	nr_lru_pages++;				\
+} while (0)
+
+#define	lru_cache_add(page)			\
+do {						\
+	spin_lock(&pagemap_lru_lock);		\
+	__lru_cache_add(page);			\
 	page->age = PG_AGE_START;		\
 	ClearPageReferenced(page);		\
 	SetPageActive(page);			\
@@ -187,7 +194,6 @@
 #define	__lru_cache_del(page)			\
 do {						\
 	list_del(&(page)->lru);			\
-	ClearPageActive(page);			\
 	nr_lru_pages--;				\
 } while (0)
 
@@ -196,6 +202,7 @@
 	if (!PageLocked(page))			\
 		BUG();				\
 	spin_lock(&pagemap_lru_lock);		\
+	ClearPageActive(page);			\
 	__lru_cache_del(page);			\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/filemap.c working/mm/filemap.c
--- base/mm/filemap.c	Mon Jun 19 23:35:41 2000
+++ working/mm/filemap.c	Tue Jun 20 00:31:46 2000
@@ -65,8 +65,8 @@
 		(*p)->pprev_hash = &page->next_hash;
 	*p = page;
 	page->pprev_hash = p;
-	if (page->buffers)
-		PAGE_BUG(page);
+//	if (page->buffers)
+//		PAGE_BUG(page);
 }
 
 static inline void remove_page_from_hash_queue(struct page * page)
@@ -102,6 +102,7 @@
 	if (page->buffers)
 		BUG();
 
+	ClearPageDirty(page);
 	remove_page_from_inode_queue(page);
 	remove_page_from_hash_queue(page);
 	page->mapping = NULL;
@@ -294,36 +295,55 @@
 	spin_unlock(&pagecache_lock);
 }
 
-/*
- * nr_dirty represents the number of dirty pages that we will write async
- * before doing sync writes.  We can only do sync writes if we can
- * wait for IO (__GFP_IO set).
+/**
+ * shrink_mmap - Tries to free memory
+ * @priority: how hard we will try to free pages (0 hardest)
+ * @gfp_mask: Restrictions to free pages
+ *
+ * This function walks the lru list searching for free pages. It
+ * returns 1 to indicate success and 0 in the opposite case. It gets a
+ * lock in the pagemap_lru_lock and the pagecache_lock.  
+ */
+/* nr_to_examinate counts the number of pages that we will read as
+ * maximum as each call.  This means that we don't loop.
  */
+/* nr_writes counts the number of writes that we have started to the
+ * moment. We limitate the number of writes in each round to
+ * max_page_launder. ToDo: Make that variable tunable through sysctl.
+ */
+const int max_page_launder = 100;
+
 int shrink_mmap(int priority, int gfp_mask)
 {
-	int ret = 0, count, nr_dirty;
 	struct list_head * page_lru;
 	struct page * page = NULL;
-	
-	count = nr_lru_pages / (priority + 1);
-	nr_dirty = priority;
+	int ret;
+	int nr_to_examinate = nr_lru_pages;
+	int nr_writes = 0;
+	int count = nr_lru_pages / (priority + 1);
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
 	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+		/* We exit if we have examinated all the LRU pages */
+		if(!nr_to_examinate--)
+			break;
+
+		/* if there is no zone low on memory we return */
+		if(!memory_pressure())
+			break;
+
 		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
+		__lru_cache_del(page);
 
 		if (PageTestandClearReferenced(page)) {
-			page->age += PG_AGE_ADV;
-			if (page->age > PG_AGE_MAX)
-				page->age = PG_AGE_MAX;
-			goto dispose_continue;
+			page->age = min(PG_AGE_MAX, page->age + PG_AGE_ADV);
+			goto reinsert_page_continue;
 		}
 		page->age -= min(PG_AGE_DECL, page->age);
 
 		if (page->age)
-			goto dispose_continue;
+			goto reinsert_page_continue;
 
 		count--;
 		/*
@@ -331,16 +351,18 @@
 		 * immediate tell are untouchable..
 		 */
 		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
+			goto reinsert_page_continue;
 
 		if (TryLockPage(page))
-			goto dispose_continue;
+			goto reinsert_page_continue;
 
-		/* Release the pagemap_lru lock even if the page is not yet
-		   queued in any lru queue since we have just locked down
-		   the page so nobody else may SMP race with us running
-		   a lru_cache_del() (lru_cache_del() always run with the
-		   page locked down ;). */
+		/* 
+		 * Release the pagemap_lru lock even if the page is
+		 * not yet queued in any lru queue since we have just
+		 * locked down the page so nobody else may SMP race
+		 * with us running a lru_cache_del() (lru_cache_del()
+		 * always run with the page locked down ;). 
+		 */
 		spin_unlock(&pagemap_lru_lock);
 
 		/* avoid freeing the page while it's locked */
@@ -351,20 +373,34 @@
 		 * of zone - it's old.
 		 */
 		if (page->buffers) {
-			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty-- < 0));
-			if (!try_to_free_buffers(page, wait))
+ 			if (nr_writes < max_page_launder) {
+ 				nr_writes++;
+ 				if (!try_to_free_buffers(page, 0))
+ 					goto unlock_continue;
+ 				/* page was locked, inode can't go away under us */
+				if (!page->mapping) {
+ 					atomic_dec(&buffermem_pages);
+ 					goto made_buffer_progress;
+ 				}
+ 			} else 
 				goto unlock_continue;
-			/* page was locked, inode can't go away under us */
-			if (!page->mapping) {
-				atomic_dec(&buffermem_pages);
-				goto made_buffer_progress;
-			}
 		}
-
-		/* Take the pagecache_lock spinlock held to avoid
-		   other tasks to notice the page while we are looking at its
-		   page count. If it's a pagecache-page we'll free it
-		   in one atomic transaction after checking its page count. */
+		/*
+		 * Page is from a zone we don't care about.
+		 * Don't drop page cache entries in vain.
+		 */
+		if (page->zone->free_pages > page->zone->pages_high) {
+			/* the page from the wrong zone doesn't count */
+			count++;
+			goto unlock_continue;
+		}
+		/* 
+		 * Take the pagecache_lock spinlock held to avoid
+		 * other tasks to notice the page while we are
+		 * looking at its page count. If it's a
+		 * pagecache-page we'll free it in one atomic
+		 * transaction after checking its page count. 
+		 */
 		spin_lock(&pagecache_lock);
 
 		/*
@@ -386,14 +422,15 @@
 				goto made_inode_progress;
 			}
 			/* PageDeferswap -> we swap out the page now. */
-			if (gfp_mask & __GFP_IO) {
+			if ((gfp_mask & __GFP_IO) && (nr_writes < max_page_launder)) {
 				spin_unlock(&pagecache_lock);
+				nr_writes++;
 				/* Do NOT unlock the page ... brw_page does. */
 				ClearPageDirty(page);
 				rw_swap_page(WRITE, page, 0);
 				spin_lock(&pagemap_lru_lock);
 				page_cache_release(page);
-				goto dispose_continue;
+				goto reinsert_page_continue;
 			}
 			goto cache_unlock_continue;
 		}
@@ -416,23 +453,23 @@
 		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
 		page_cache_release(page);
-dispose_continue:
-		list_add(page_lru, &lru_cache);
+reinsert_page_continue:
+		__lru_cache_add(page);
 	}
+	spin_unlock(&pagemap_lru_lock);
+	ret = 0;
 	goto out;
 
 made_inode_progress:
 	page_cache_release(page);
 made_buffer_progress:
+	ClearPageActive(page);
 	UnlockPage(page);
 	page_cache_release(page);
 	ret = 1;
-	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
-
 out:
-	spin_unlock(&pagemap_lru_lock);
+	if (nr_writes >= (max_page_launder/2))
+		wakeup_bdflush(gfp_mask & __GFP_IO);
 
 	return ret;
 }
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/swap_state.c working/mm/swap_state.c
--- base/mm/swap_state.c	Mon Jun 19 23:35:41 2000
+++ working/mm/swap_state.c	Tue Jun 20 00:04:12 2000
@@ -73,7 +73,6 @@
 		PAGE_BUG(page);
 
 	PageClearSwapCache(page);
-	ClearPageDirty(page);
 	remove_inode_page(page);
 }
 
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/vmscan.c working/mm/vmscan.c
--- base/mm/vmscan.c	Mon Jun 19 23:35:41 2000
+++ working/mm/vmscan.c	Tue Jun 20 00:08:27 2000
@@ -179,16 +179,14 @@
 
 	/* Add it to the swap cache */
 	add_to_swap_cache(page, entry);
+	set_pte(page_table, swp_entry_to_pte(entry));
 
 	/* Put the swap entry into the pte after the page is in swapcache */
 	vma->vm_mm->rss--;
-	set_pte(page_table, swp_entry_to_pte(entry));
 	flush_tlb_page(vma, address);
 	vmlist_access_unlock(vma->vm_mm);
 
-	/* OK, do a physical asynchronous write to swap.  */
-	// rw_swap_page(WRITE, page, 0);
-	/* Let shrink_mmap handle this swapout. */
+	/* Set page for deferred swap */
 	SetPageDirty(page);
 	UnlockPage(page);
 
@@ -427,6 +425,32 @@
 	return __ret;
 }
 
+/**
+ * memory_pressure - Is the system under memory pressure
+ *
+ * Returns 1 if the system is low on memory in any of its zones,
+ * otherwise returns 0.
+ */
+int memory_pressure(void)
+{
+	pg_data_t *pgdat = pgdat_list;
+
+	do {
+		int i;
+		for(i = 0; i < MAX_NR_ZONES; i++) {
+			zone_t *zone = pgdat->node_zones + i;
+			if (!zone->size || !zone->zone_wake_kswapd)
+				continue;
+			if (zone->free_pages < zone->pages_low)
+				return 1; 
+		}
+		pgdat = pgdat->node_next;
+		
+	} while (pgdat);
+	
+	return 0;
+}
+
 /*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
@@ -445,7 +469,6 @@
 	int count = FREE_COUNT;
 	int swap_count = 0;
 	int made_progress = 0;
-	int ret = 0;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
@@ -458,6 +481,8 @@
 				goto done;
 		}
 
+		if (!memory_pressure())
+			return 1;
 
 		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
@@ -506,9 +531,11 @@
 		 * potentially upset the balance between shrink_mmap and
 		 * swap_out.
 		 */
+
+		if (!memory_pressure())
+			return 1;
 		if (made_progress) {
 			made_progress = 0;
-			ret = 1;
 		} else {
 			priority--;
 		}
@@ -516,13 +543,12 @@
 
 	/* Always end on a shrink_mmap.. */
 	while (shrink_mmap(0, gfp_mask)) {
-		ret = 1;
 		if (!--count)
 			goto done;
 	}
 
 done:
-	return ret;
+	return (count < FREE_COUNT);
 }
 
 DECLARE_WAIT_QUEUE_HEAD(kswapd_wait);
@@ -564,26 +590,14 @@
 	tsk->flags |= PF_MEMALLOC;
 
 	for (;;) {
-		pg_data_t *pgdat;
-		int something_to_do = 0;
+		int pressure = memory_pressure();
 
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
+		if (tsk->need_resched)
+			schedule();
 
-		if (!something_to_do) {
+		if(pressure)
+			do_try_to_free_pages(GFP_KSWAPD);
+		else {
 			tsk->state = TASK_INTERRUPTIBLE;
 			interruptible_sleep_on(&kswapd_wait);
 		}


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
