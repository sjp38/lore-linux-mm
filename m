Date: Mon, 19 Jun 2000 20:57:51 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [itcompilesshipitPATCH] -ac22-riel vm improvement?
Message-ID: <Pine.LNX.4.21.0006192052001.7938-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

the following patch should implement the following things,
but due to lack of a test machine at home and enormous
peer pressure by the #humboltluitjes folks to send this
out _before_ dinner, I can't tell for sure...

- shrink_mmap() deadlock prevention
- uses bdflush/kflushd to sync the dirty buffers in an
  efficient way (only stalls when we really can't keep up)
- uses the memory_pressure() stuff to make sure we don't do
  too much work
- reintroduces the zone->free_pages > zone->pages_high patch

Since all of this patch does no more than simple code reuse of
other parts of the kernel, it should be good enough to give it
a try and tell me if it works :)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.4.0-t1-ac22-riel/mm/filemap.c.orig	Mon Jun 19 18:27:05 2000
+++ linux-2.4.0-t1-ac22-riel/mm/filemap.c	Mon Jun 19 20:49:03 2000
@@ -301,16 +301,19 @@
  */
 int shrink_mmap(int priority, int gfp_mask)
 {
-	int ret = 0, count, nr_dirty;
+	int ret = 0, count, maxscan, nr_dirty, loop = 0;
 	struct list_head * page_lru;
 	struct page * page = NULL;
 	
+shrink_again:
 	count = nr_lru_pages / (priority + 1);
-	nr_dirty = priority;
+	maxscan = nr_lru_pages;
+	nr_dirty = 0;
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	while ((count > 0) && (maxscan-- > 0) && memory_pressure() &&
+			(page_lru = lru_cache.prev) != &lru_cache) {
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
@@ -351,9 +354,12 @@
 		 * of zone - it's old.
 		 */
 		if (page->buffers) {
-			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty-- < 0));
+			int wait = ((gfp_mask & __GFP_IO) ? 0 : -1);
+			nr_dirty++;
 			if (!try_to_free_buffers(page, wait))
 				goto unlock_continue;
+			/* We freed the buffers so it wasn't dirty */
+			nr_dirty--;
 			/* page was locked, inode can't go away under us */
 			if (!page->mapping) {
 				atomic_dec(&buffermem_pages);
@@ -361,6 +367,15 @@
 			}
 		}
 
+		/*
+		 * Are there more than enough free pages in this zone?
+		 * Don't drop the page since it contains useful data.
+		 */
+		if (page->zone->free_pages > page->zone->pages_high) {
+			count++;
+			goto unlock_continue;
+		}
+
 		/* Take the pagecache_lock spinlock held to avoid
 		   other tasks to notice the page while we are looking at its
 		   page count. If it's a pagecache-page we'll free it
@@ -387,6 +402,7 @@
 			}
 			/* PageDeferswap -> we swap out the page now. */
 			if (gfp_mask & __GFP_IO) {
+				nr_dirty++;
 				spin_unlock(&pagecache_lock);
 				/* Do NOT unlock the page ... brw_page does. */
 				ClearPageDirty(page);
@@ -433,6 +449,17 @@
 
 out:
 	spin_unlock(&pagemap_lru_lock);
+
+	/* We scheduled pages for IO? Wake up kflushd. */
+	if (nr_dirty) {
+		if (!loop && !ret && (gfp_mask & __GFP_IO)) {
+			loop = 1;
+			wakeup_bdflush(1);
+			goto shrink_again;
+		} else {
+			wakeup_bdflush(0);
+		}
+	}
 
 	return ret;
 }
--- linux-2.4.0-t1-ac22-riel/mm/vmscan.c.orig	Mon Jun 19 18:27:05 2000
+++ linux-2.4.0-t1-ac22-riel/mm/vmscan.c	Mon Jun 19 19:02:28 2000
@@ -186,9 +186,7 @@
 	flush_tlb_page(vma, address);
 	vmlist_access_unlock(vma->vm_mm);
 
-	/* OK, do a physical asynchronous write to swap.  */
-	// rw_swap_page(WRITE, page, 0);
-	/* Let shrink_mmap handle this swapout. */
+	/* Mark the page for swapout. Shrink_mmap does the hard work. */
 	SetPageDirty(page);
 	UnlockPage(page);
 
@@ -427,6 +425,32 @@
 	return __ret;
 }
 
+/**
+ * memory_pressure - check if the system is under memory pressure
+ *
+ * Returns 1 if the system is low on memory in at least one zone,
+ * 0 otherwise
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
+	} while (pgdat);
+
+	/* Found no zone with memory pressure? */
+	return 0;
+}
+
 /*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
@@ -458,6 +482,8 @@
 				goto done;
 		}
 
+		if (!memory_pressure())
+			return 1;
 
 		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
@@ -512,7 +538,7 @@
 		} else {
 			priority--;
 		}
-	} while (priority >= 0);
+	} while (priority >= 0 && memory_pressure());
 
 	/* Always end on a shrink_mmap.. */
 	while (shrink_mmap(0, gfp_mask)) {
@@ -521,6 +547,9 @@
 			goto done;
 	}
 
+	if (!memory_pressure())
+		ret = 1;
+
 done:
 	return ret;
 }
@@ -563,30 +592,22 @@
 	 */
 	tsk->flags |= PF_MEMALLOC;
 
+	/*
+	 * Kswapd needs to run for the entire lifetime of the system...
+	 */
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
+		if (memory_pressure()) {
+			/* If there is memory pressure, try to free pages. */
+			do_try_to_free_pages(GFP_KSWAPD);
+		} else {
+			/* Else, we sleep and wait for somebody to wake us. */
 			tsk->state = TASK_INTERRUPTIBLE;
 			interruptible_sleep_on(&kswapd_wait);
 		}
+
+		/* Yield if something more important needs to run. */
+		if (tsk->need_resched)
+			schedule();
 	}
 }
 
--- linux-2.4.0-t1-ac22-riel/include/linux/swap.h.orig	Mon Jun 19 19:03:56 2000
+++ linux-2.4.0-t1-ac22-riel/include/linux/swap.h	Mon Jun 19 19:08:00 2000
@@ -87,6 +87,7 @@
 
 /* linux/mm/vmscan.c */
 extern int try_to_free_pages(unsigned int gfp_mask);
+extern int memory_pressure(void);
 
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, struct page *, int);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
