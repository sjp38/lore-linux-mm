Subject: Re: PATCH: Work in progress cleaning shrink_mmap
References: <yttu2g0zf7l.fsf@vexeta.dc.fi.udc.es>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "15 May 2000 05:04:30 +0200"
Date: 15 May 2000 05:06:55 +0200
Message-ID: <yttln1czf3k.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "juan" == Juan J Quintela <quintela@fi.udc.es> writes:

Hi
        I forget to send the patch the first time.

juan> Well, that have been my findings to the moment.  Any comments about
juan> the patch of my findings are welcome.

Later, Juan.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-1/include/linux/swap.h testing/include/linux/swap.h
--- pre9-1/include/linux/swap.h	Sun May 14 20:20:53 2000
+++ testing/include/linux/swap.h	Mon May 15 01:50:46 2000
@@ -163,11 +163,16 @@
 /*
  * Helper macros for lru_pages handling.
  */
-#define	lru_cache_add(page)			\
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
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
 
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-1/mm/filemap.c testing/mm/filemap.c
--- pre9-1/mm/filemap.c	Fri May 12 23:46:46 2000
+++ testing/mm/filemap.c	Mon May 15 04:47:04 2000
@@ -244,41 +244,41 @@
 	spin_unlock(&pagecache_lock);
 }
 
+/**
+ * shrink_mmap - Tries to free memory
+ * @priority: how hard we will try to free pages (0 hardest)
+ * @gfp_mask: Restrictions to free pages
+ *
+ * Put something Here
+ */
+
 int shrink_mmap(int priority, int gfp_mask)
 {
-	int ret = 0, count;
-	LIST_HEAD(old);
-	struct list_head * page_lru, * dispose;
+	int count;
+	struct list_head * page_lru;
 	struct page * page = NULL;
 	
 	count = nr_lru_pages / (priority + 1);
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	page_lru = lru_cache.prev;
+	while (count > 0 && (page_lru != &lru_cache)) {
 		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
 
-		dispose = &lru_cache;
-		if (PageTestandClearReferenced(page))
+		/*
+		 * We clear the referenced bit and move the page to
+		 *  the end of the LRU list
+		 */
+		if (PageTestandClearReferenced(page)) {
+			__lru_cache_del(page);
+			__lru_cache_add(page);
 			goto dispose_continue;
+		}
 
 		count--;
 
 		/*
-		 * I'm ambivalent on this one.. Should we try to
-		 * maintain LRU on the LRU list, and put pages that
-		 * are old at the end of the queue, even if that
-		 * means that we'll re-scan then again soon and
-		 * often waste CPU time? Or should be just let any
-		 * pages we do not want to touch now for one reason
-		 * or another percolate to be "young"?
-		 *
-		dispose = &old;
-		 *
-		 */
-
-		/*
 		 * Avoid unscalable SMP locking for pages we can
 		 * immediate tell are untouchable..
 		 */
@@ -288,11 +288,12 @@
 		if (TryLockPage(page))
 			goto dispose_continue;
 
-		/* Release the pagemap_lru lock even if the page is not yet
-		   queued in any lru queue since we have just locked down
-		   the page so nobody else may SMP race with us running
-		   a lru_cache_del() (lru_cache_del() always run with the
-		   page locked down ;). */
+		/*
+		 * Release the pagemap_lru lock since we have just
+		 * locked down the page so nobody else may SMP race
+		 * with us running a lru_cache_del() (lru_cache_del()
+		 * always run with the page locked down ;). 
+		 */
 		spin_unlock(&pagemap_lru_lock);
 
 		/* avoid freeing the page while it's locked */
@@ -312,10 +313,13 @@
 			}
 		}
 
-		/* Take the pagecache_lock spinlock held to avoid
-		   other tasks to notice the page while we are looking at its
-		   page count. If it's a pagecache-page we'll free it
-		   in one atomic transaction after checking its page count. */
+		/*
+		 * Take the pagecache_lock spinlock held to avoid
+		 * other tasks to notice the page while we are
+		 * looking at its page count. If it's a
+		 * pagecache-page we'll free it in one atomic
+		 * transaction after checking its page count. 
+		 */
 		spin_lock(&pagecache_lock);
 
 		/*
@@ -328,7 +332,7 @@
 		/*
 		 * Is it a page swap page? If so, we want to
 		 * drop it if it is no longer used, even if it
-		 * were to be marked referenced..
+		 * were to be marked referenced.
 		 */
 		if (PageSwapCache(page)) {
 			spin_unlock(&pagecache_lock);
@@ -362,26 +366,19 @@
 		UnlockPage(page);
 		page_cache_release(page);
 dispose_continue:
-		list_add(page_lru, dispose);
+		page_lru = page_lru->prev;
 	}
-	goto out;
+	spin_unlock(&pagemap_lru_lock);
+
+	return 0;
 
 made_inode_progress:
 	page_cache_release(page);
 made_buffer_progress:
+	lru_cache_del(page);
 	UnlockPage(page);
 	page_cache_release(page);
-	ret = 1;
-	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
-
-out:
-	list_splice(&old, lru_cache.prev);
-
-	spin_unlock(&pagemap_lru_lock);
-
-	return ret;
+	return 1;
 }
 
 static inline struct page * __find_page_nolock(struct address_space *mapping, unsigned long offset, struct page *page)
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-1/mm/vmscan.c testing/mm/vmscan.c
--- pre9-1/mm/vmscan.c	Sun May 14 00:58:25 2000
+++ testing/mm/vmscan.c	Mon May 15 04:47:12 2000
@@ -429,12 +429,13 @@
  * Don't try _too_ hard, though. We don't want to have bad
  * latency.
  */
-#define FREE_COUNT	8
-#define SWAP_COUNT	8
+#define FREE_COUNT	16
+#define SWAP_COUNT	16
 static int do_try_to_free_pages(unsigned int gfp_mask)
 {
 	int priority;
 	int count = FREE_COUNT;
+	int swap_count;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
@@ -470,12 +471,11 @@
 		 * This will not actually free any pages (they get
 		 * put in the swap cache), so we must not count this
 		 * as a "count" success.
-		 */
-		{
-			int swap_count = SWAP_COUNT;
-			while (swap_out(priority, gfp_mask))
-				if (--swap_count < 0)
-					break;
+		 */ 
+		swap_count = SWAP_COUNT;
+		while (swap_out(priority, gfp_mask)) {
+			if (--swap_count < 0)
+				break;
 		}
 	} while (--priority >= 0);
 



-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
