Message-ID: <3919DF13.B84422A8@norran.net>
Date: Thu, 11 May 2000 00:13:39 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [plastic bag] Re: A possible winner in pre7-8
References: <Pine.LNX.4.10.10005082332560.773-100000@penguin.transmeta.com>
			<3917C33F.1FA1BAD4@sgi.com> <yttln1jtyqg.fsf@vexeta.dc.fi.udc.es> <3918C28B.3B820E6F@norran.net>
Content-Type: multipart/mixed;
 boundary="------------3AB7DAA966C49C2E8FC113BC"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>, Rajagopal Ananthanarayanan <ananth@sgi.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------3AB7DAA966C49C2E8FC113BC
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Ok,

Here is the file too...

/RogerL

Roger Larsson wrote:
> 
> Hi all,
> 
> Since everyone is testing shrink_mmap...
> 
> Here is my latest version.
> 
> (Currently I have some problems with pre-version
>  I am kind of out of synch...)
> 
> It should compile, but it is not tested:
> - lack of HD, courage, backups...
> 
> /RogerL
> 
> "Juan J. Quintela" wrote:
> >
> > >>>>> "rajagopal" == Rajagopal Ananthanarayanan <ananth@sgi.com> writes:
> >
> > Hi
> >
> > rajagopal> Interesting! This stuff is coming out faster than I can patch.
> > rajagopal> In any case, good news about pre7-8: not only does dbench run without
> > rajagopal> errors, but it runs well. Let's hope that others (Juan & Benjamin to name two)
> > rajagopal> see similar results.
> >
> > No way, here my tests run two iterations, and in the second iteration
> > init was killed, and the system become unresponsive (headless machine,
> > you know....).  I have no time now to do a more detailed report, more
> > information later today.
> >
> > Later, Juan.
> >
> > --
> > In theory, practice and theory are the same, but in practice they
> > are different -- Larry McVoy
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux.eu.org/Linux-MM/
> 
> --
> Home page:
>   http://www.norran.net/nra02596/
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--------------3AB7DAA966C49C2E8FC113BC
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.3-shrink_mmap.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.3-shrink_mmap.2"

--- linux-2.3-pre6/mm/filemap.c	Sat May  6 02:20:17 2000
+++ linux-2.3/mm/filemap.c	Tue May  9 02:35:04 2000
@@ -236,153 +233,228 @@
 	spin_unlock(&pagecache_lock);
 }
 
+
+static zone_t null_zone;
+
+/*
+ * Precondition:
+ *   lru sorted as least recently used
+ *   PG_referenced updated from pte_young(pte) to PG_referenced
+ *   pages continouosly scanned and resorted due to PG_referenced
+ * Parameters:
+ *   zone==NULL 
+ *     try to free pages belonging to any zone with zone_wake_kswapd
+ *   zone!=NULL 
+ *     try harder (x2) when this zone is low_on_memory (>priority)
+ *     relax when this zone has not zone_wake_kswapd (<priority)
+ */
 int shrink_mmap(int priority, int gfp_mask, zone_t *zone)
 {
-	int ret = 0, loop = 0, count;
+	int ret = 0, zone_ret = 0;
+	int attempt = 0, count;
 	LIST_HEAD(young);
-	LIST_HEAD(old);
 	LIST_HEAD(forget);
-	struct list_head * page_lru, * dispose;
+	struct list_head * page_lru, * cursor, * dispose;
 	struct page * page = NULL;
 	struct zone_struct * p_zone;
-	int maxloop = 256 >> priority;
-	
-	if (!zone)
-		BUG();
-
-	count = nr_lru_pages >> priority;
-	if (!count)
-		return ret;
-
-	spin_lock(&pagemap_lru_lock);
-again:
-	/* we need pagemap_lru_lock for list_del() ... subtle code below */
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
-		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
-		p_zone = page->zone;
-
-		/*
-		 * These two tests are there to make sure we don't free too
-		 * many pages from the "wrong" zone. We free some anyway,
-		 * they are the least recently used pages in the system.
-		 * When we don't free them, leave them in &old.
-		 */
-		dispose = &old;
-		if (p_zone != zone && (loop > (maxloop / 4) ||
-				p_zone->free_pages > p_zone->pages_high))
-			goto dispose_continue;
-
-		/* The page is in use, or was used very recently, put it in
-		 * &young to make sure that we won't try to free it the next
-		 * time */
-		dispose = &young;
-
-		if (test_and_clear_bit(PG_referenced, &page->flags))
-			goto dispose_continue;
-
-		count--;
-		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
-
-		/* Page not used -> free it; if that fails -> &old */
-		dispose = &old;
-		if (TryLockPage(page))
-			goto dispose_continue;
-
-		/* Release the pagemap_lru lock even if the page is not yet
-		   queued in any lru queue since we have just locked down
-		   the page so nobody else may SMP race with us running
-		   a lru_cache_del() (lru_cache_del() always run with the
-		   page locked down ;). */
-		spin_unlock(&pagemap_lru_lock);
-
-		/* avoid freeing the page while it's locked */
-		get_page(page);
-
-		/* Is it a buffer page? */
-		if (page->buffers) {
-			if (!try_to_free_buffers(page))
-				goto unlock_continue;
-			/* page was locked, inode can't go away under us */
-			if (!page->mapping) {
-				atomic_dec(&buffermem_pages);
-				goto made_buffer_progress;
-			}
-		}
-
-		/* Take the pagecache_lock spinlock held to avoid
-		   other tasks to notice the page while we are looking at its
-		   page count. If it's a pagecache-page we'll free it
-		   in one atomic transaction after checking its page count. */
-		spin_lock(&pagecache_lock);
+	struct page cursor_page; /* unique by thread, too much on stack? */
 
-		/*
-		 * We can't free pages unless there's just one user
-		 * (count == 2 because we added one ourselves above).
-		 */
-		if (page_count(page) != 2)
-			goto cache_unlock_continue;
-
-		/*
-		 * Is it a page swap page? If so, we want to
-		 * drop it if it is no longer used, even if it
-		 * were to be marked referenced..
-		 */
-		if (PageSwapCache(page)) {
-			spin_unlock(&pagecache_lock);
-			__delete_from_swap_cache(page);
-			goto made_inode_progress;
-		}	
-
-		/* is it a page-cache page? */
-		if (page->mapping) {
-			if (!PageDirty(page) && !pgcache_under_min()) {
-				remove_page_from_inode_queue(page);
-				remove_page_from_hash_queue(page);
-				page->mapping = NULL;
-				spin_unlock(&pagecache_lock);
-				goto made_inode_progress;
-			}
-			goto cache_unlock_continue;
-		}
-
-		dispose = &forget;
-		printk(KERN_ERR "shrink_mmap: unknown LRU page!\n");
+	/* Initialize the cursor (fake) page */
+	cursor = &cursor_page.lru;
+	cursor_page.zone = &null_zone;
 
+	spin_lock(&pagemap_lru_lock);
+	/* cursor always part of the list, but not a real page... 
+	 * make a special page that points to a special zone
+	 *     with zone_wake_kswapd always 0
+	 * - some more toughts required... */
+	list_add_tail(cursor, &lru_cache);
+
+ again:
+	attempt++;
+
+	if (priority == 0)
+	  count = -1 >> 1; /* maxint => do not count, search to end of list */
+	else
+	  count = nr_lru_pages >> priority;
+
+	for (page_lru = lru_cache.prev;
+	     count-- && page_lru != &lru_cache;
+	     page_lru = page_lru->prev) {
+
+	  /* Avoid processing our own cursor... 
+	   * Note: check not needed with page cursor.
+	   * if (page_lru == cursor)
+	   *   continue;
+	   */
+
+	  page = list_entry(page_lru, struct page, lru);
+	  p_zone = page->zone;
+
+
+	  /* Check if zone has pressure, most pages would continue here.
+	   * Also pages from zones that initally was under pressure */
+	  if (!p_zone->zone_wake_kswapd)
+	    continue;
+
+	  /* Can't do anything about this... */
+	  if (!page->buffers && page_count(page) > 1)
+	    continue;
+
+	  /* Page not used -> free it 
+	   * If it could not be locked it is somehow in use
+	   * try another time */
+	  if (TryLockPage(page))
+	    continue;
+
+	  /* Ok, a possible page.
+	  * Note: can't unlock lru if we do we will have
+	  * to restart this loop */
+
+	  /* The page is in use, or was used very recently, put it in
+	   * &young to make it ulikely that we will try to free it the next
+	   * time.
+	   * Note 1: Currently only try_to_swap and __find_page_nolock
+	   * will set this bit - how does mmaped pages get referenced?
+	   * [not in lru? - I do not know enough :-( ... yet :-) ]
+	   * Note 2: all pages need to be searched at once to get
+	   * a better lru aproximation.
+	   */
+	  dispose = &young;
+	  if (test_and_clear_bit(PG_referenced, &page->flags))
+	    goto dispose_continue;
+		
+	  
+	  /* cursor takes page_lru's place in lru_list
+	   * if disposed later it ends up at the same place!
+	   * Note: compilers should be able to optimize this a bit... */
+	  list_del(cursor);
+	  list_add_tail(cursor, page_lru);
+	  list_del(page_lru);
+	  spin_unlock(&pagemap_lru_lock);
+
+	  /* Spinlock is released, anything might happen to the list!
+	   * But the cursor will remain on spot.
+	   * - it will not be deleted from outside,
+	   *   no one knows about it.
+	   * - it will not be deleted by another shrink_mmap,
+           *   zone_wake_kswapd == 0
+	   */
+
+	  /* If page is redisposed after attempt, place it at the same spot */
+	  dispose = cursor;
+
+	  /* avoid freeing the page while it's locked */
+	  get_page(page);
+
+	  /* Is it a buffer page? */
+	  if (page->buffers) {
+	    if (!try_to_free_buffers(page))
+	      goto unlock_continue;
+	    /* page was locked, inode can't go away under us */
+	    if (!page->mapping) {
+	      atomic_dec(&buffermem_pages);
+	      goto made_buffer_progress;
+	    }
+	  }
+
+	  /* Take the pagecache_lock spinlock held to avoid
+	     other tasks to notice the page while we are looking at its
+	     page count. If it's a pagecache-page we'll free it
+	     in one atomic transaction after checking its page count. */
+	  spin_lock(&pagecache_lock);
+
+	  /*
+	   * We can't free pages unless there's just one user
+	   * (count == 2 because we added one ourselves above).
+	   */
+	  if (page_count(page) != 2)
+	    goto cache_unlock_continue;
+
+	  /*
+	   * Is it a page swap page? If so, we want to
+	   * drop it if it is no longer used, even if it
+	   * were to be marked referenced..
+	   */
+	  if (PageSwapCache(page)) {
+	    spin_unlock(&pagecache_lock);
+	    __delete_from_swap_cache(page);
+	    goto made_inode_progress;
+	  }	
+
+	  /* is it a page-cache page? */
+	  if (page->mapping) {
+	    if (!PageDirty(page) && !pgcache_under_min()) {
+	      remove_page_from_inode_queue(page);
+	      remove_page_from_hash_queue(page);
+	      page->mapping = NULL;
+	      spin_unlock(&pagecache_lock);
+	      goto made_inode_progress;
+	    }
+	    goto cache_unlock_continue;
+	  }
+
+	  dispose = &forget;
+	  printk(KERN_ERR "shrink_mmap: unknown LRU page!\n");
+	  
 cache_unlock_continue:
-		spin_unlock(&pagecache_lock);
+	  spin_unlock(&pagecache_lock);
 unlock_continue:
-		spin_lock(&pagemap_lru_lock);
-		UnlockPage(page);
-		put_page(page);
-		list_add(page_lru, dispose);
-		continue;
+	  spin_lock(&pagemap_lru_lock);
+	  UnlockPage(page);
+	  put_page(page);
 
-		/* we're holding pagemap_lru_lock, so we can just loop again */
 dispose_continue:
-		list_add(page_lru, dispose);
-	}
-	goto out;
+	  list_add(page_lru, dispose);
+	  /* final disposition to other list than lru? */
+	  /* then return list index to old lru-list position */
+	  if (dispose != cursor)
+	    page_lru = cursor;
+	  continue;
 
 made_inode_progress:
-	page_cache_release(page);
+	  page_cache_release(page);
 made_buffer_progress:
-	UnlockPage(page);
-	put_page(page);
-	ret = 1;
-	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
+	  UnlockPage(page);
+	  put_page(page);
+	  ret++;
+	  spin_lock(&pagemap_lru_lock);
+	  /* nr_lru_pages needs the spinlock */
+	  nr_lru_pages--;
+
+	  /* Might (and should) have been done by free calls
+	   * p_zone->zone_wake_kswapd = 0;
+	   */
+
+	  /* If no more pages are needed to release on specifically
+	     requested zone concider it done!
+	     Note: zone might be NULL to make all requests fulfilled */
+	  if (p_zone == zone) {
+	    zone_ret++;
+	    if (!p_zone->zone_wake_kswapd)
+	      break;
+	  }
 
-	loop++;
-	/* wrong zone?  not looped too often?    roll again... */
-	if (page->zone != zone && loop < maxloop)
-		goto again;
+	  /* Back to cursor position to ensure correct next step */
+	  page_lru = cursor;
+	}
 
-out:
+	/* cursor may be at top of lru list, insert young
+	 * pages at top - may be scanned next turn...
+	 */
 	list_splice(&young, &lru_cache);
-	list_splice(&old, lru_cache.prev);
+
+	/* if zone request not fulfilled, try harder */
+	if (zone) {
+	  if (zone->low_on_memory) {
+	    if (attempt < 2)
+	      goto again;
+	  }
+	  ret = zone_ret;
+	}
+	  
+	  
+	list_del(cursor);
 
 	spin_unlock(&pagemap_lru_lock);
 

--------------3AB7DAA966C49C2E8FC113BC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
