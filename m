Subject: PATCH: Cleaning up of the function shrink_mmap (WIP)
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 23 May 2000 04:02:55 +0200
Message-ID: <yttaehiqb00.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi
        in this patch (Work in progress) I am cleaning up the
function shrink_mmap.  This is a work in progress, I am 
trying to solve the slowdown than happen when the page cache becomes
very big and we need to wait (too much) before to be able to continue.
You can see the effect easily with a program like mmap002 or a dd of a
big file and one vmstat 1 in other window.  The slowdown happen when
the system is using all the memory (120MB in a 128MB system) for
page_cache, in that moment, you can see in the window of the vmstat
that it takes as much as 5/6 seconds to write the next line (I have
vmstat 1 command).  To the moment no success finding the cause of the
slowdown.

The patch applies in top of pre9-3 + my patch wait_buffers_03.patch.
(You can get the patches from
http://carpanta.dc.fi.udc.es/~quintela/kernel). 

The patch does:
- define __lru_cache_add, to be able to manipulate the lru_cache list
  without having to worry about the nr_lru_pages counter.
- It documents a bit shrink_mmap and reformat all the comments in a
  consistent way, and update the comments when needed.
- It changes the meaning of my nr_dirty from my previous patch to mean
  wait each priority pages, not _all_ the pages except the first
  priority ones.
- It returns the counter in do_try_to_free pages to the value in
  vanilla pre9-3, this change made it to scan _all_ pages in the last
  16 priorities.
- minor cleanup in the return case of that function.

Comment and suggestions about where can be the cause of the slowdown
are welcome and appreciated.

Later, Juan.

PD. Linus, if you want a separate patch with only the bits relative a my
    previous patch, or other modification, ask for it.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/include/linux/swap.h prueba/include/linux/swap.h
--- base/include/linux/swap.h	Mon May 22 14:12:56 2000
+++ prueba/include/linux/swap.h	Tue May 23 01:22:48 2000
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
 
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/filemap.c prueba/mm/filemap.c
--- base/mm/filemap.c	Mon May 22 16:57:34 2000
+++ prueba/mm/filemap.c	Tue May 23 03:36:49 2000
@@ -233,7 +233,15 @@
 	}
 	spin_unlock(&pagecache_lock);
 }
-
+/**
+ * shrink_mmap - Tries to free memory
+ * @priority: how hard we will try to free pages (0 hardest)
+ * @gfp_mask: Restrictions to free pages
+ *
+ * This function walks the lru list searching for free pages. It
+ * returns 1 to indicate success and 0 in the opposite case. It gets a
+ * lock in the pagemap_lru_lock and the pagecache_lock.  
+ */
 /*
  * nr_dirty represents the number of dirty pages that we will write async
  * before doing sync writes.  We can only do sync writes if we can
@@ -241,38 +249,37 @@
  */
 int shrink_mmap(int priority, int gfp_mask)
 {
-	int ret = 0, count, nr_dirty;
-	struct list_head * page_lru;
 	struct page * page = NULL;
-	
-	count = nr_lru_pages / (priority + 1);
-	nr_dirty = priority;
+	int count = nr_lru_pages / (priority + 1);
+	int nr_dirty = priority;
 
-	/* we need pagemap_lru_lock for list_del() ... subtle code below */
+	/* we need pagemap_lru_lock for __lru_cache_*() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
-		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
+	while (count > 0 && (lru_cache.prev != &lru_cache)) {
+		page = list_entry(lru_cache.prev, struct page, lru);
+		__lru_cache_del(page);
 
 		count--;
 		if (PageTestandClearReferenced(page))
-			goto dispose_continue;
+			goto return_page_continue;
 
 		/*
 		 * Avoid unscalable SMP locking for pages we can
 		 * immediate tell are untouchable..
 		 */
 		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
+			goto return_page_continue;
 
 		if (TryLockPage(page))
-			goto dispose_continue;
+			goto return_page_continue;
 
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
@@ -284,6 +291,9 @@
 		 */
 		if (page->buffers) {
 			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty-- < 0));
+			if (wait)
+				nr_dirty = priority;
+
 			if (!try_to_free_buffers(page, wait))
 				goto unlock_continue;
 			/* page was locked, inode can't go away under us */
@@ -293,10 +303,13 @@
 			}
 		}
 
-		/* Take the pagecache_lock spinlock held to avoid
-		   other tasks to notice the page while we are looking at its
-		   page count. If it's a pagecache-page we'll free it
-		   in one atomic transaction after checking its page count. */
+		/*
+		 * Take the pagecache_lock spinlock held to avoid
+		 * other tasks to notice the page while we are looking
+		 * at its page count. If it's a pagecache-page we'll
+		 * free it in one atomic transaction after checking
+		 * its page count. 
+		 */
 		spin_lock(&pagecache_lock);
 
 		/*
@@ -342,25 +355,20 @@
 		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
 		page_cache_release(page);
-dispose_continue:
-		list_add(page_lru, &lru_cache);
+return_page_continue:
+		__lru_cache_add(page);
 	}
-	goto out;
+	spin_unlock(&pagemap_lru_lock);
+
+	return 0;
 
 made_inode_progress:
 	page_cache_release(page);
 made_buffer_progress:
 	UnlockPage(page);
 	page_cache_release(page);
-	ret = 1;
-	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
-
-out:
-	spin_unlock(&pagemap_lru_lock);
 
-	return ret;
+	return 1;
 }
 
 static inline struct page * __find_page_nolock(struct address_space *mapping, unsigned long offset, struct page *page)
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/vmscan.c prueba/mm/vmscan.c
--- base/mm/vmscan.c	Mon May 22 16:57:34 2000
+++ prueba/mm/vmscan.c	Tue May 23 01:21:09 2000
@@ -363,7 +363,7 @@
 	 * Think of swap_cnt as a "shadow rss" - it tells us which process
 	 * we want to page out (always try largest first).
 	 */
-	counter = (nr_threads << 2) >> (priority >> 2);
+	counter = (nr_threads << 1) >> (priority >> 1);
 	if (counter < 1)
 		counter = 1;
 
@@ -485,10 +485,8 @@
 			goto done;
 	}
 	/* We return 1 if we are freed some page */
-	return (count != FREE_COUNT);
-
 done:
-	return 1;
+	return (count < FREE_COUNT);
 }
 
 DECLARE_WAIT_QUEUE_HEAD(kswapd_wait);


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
