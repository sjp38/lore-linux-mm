Message-ID: <3911FC01.CEA908A5@norran.net>
Date: Fri, 05 May 2000 00:38:57 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH][RFC] Another shrink_mmap
References: <Pine.LNX.4.21.0005041132410.23740-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Here is an another shrink_mmap.

This time lock handling should be better.

It tries to touch the list as little as possible
Only young pages are moved, probable pages are
replaced by a cursor - makes it possible to release
the pagemap_lru_lock.

And it tries to be quick.

Comments please.

It compiles but I have not dared to run it yet...

(My biggest patch yet, included straight text
 since I do not dare to run it I shouldn't tempt
 you...)

/RogerL

--
Home page:
  http://www.norran.net/nra02596/

---

static zone_t null_zone;

int shrink_mmap(int priority, int gfp_mask, zone_t *zone)
{
	int ret = 0, count;
	LIST_HEAD(young);
	LIST_HEAD(forget);
	struct list_head * page_lru, * cursor, * dispose;
	struct page * page = NULL;
	struct zone_struct * p_zone;
	struct page cursor_page; /* unique by thread, too much on stack? */

	/* This could be removed.
	 * NULL translates to: fulfill all zone requests. */
	if (!zone)
		BUG();

	count = nr_lru_pages >> priority;

	cursor = &cursor_page.lru;
	cursor_page.zone = &null_zone;

	spin_lock(&pagemap_lru_lock);
	/* cursor always part of the list, but not a real page... 
	 * make a special page that points to a special zone
	 *     with zone_wake_kswapd always 0
	 * - some more toughts required... */
	list_add_tail(cursor, &lru_cache);

	for (page_lru = lru_cache.prev;
	     count-- && page_lru != &lru_cache;
	     page_lru = page_lru->prev) {

	  /* Avoid processing our own cursor... 
	   * Note: check not needed with page cursor.
	   * if (page_lru == cursor)
	   *   continue;
	   */

	  page = list_entry(page_lru, struct page, lru);
	  p_zone = page->zone;


	  /* Check if zone has pressure, most pages would continue here.
	   * Also pages from zones that initally was under pressure */
	  if (!p_zone->zone_wake_kswapd)
	    continue;

	  /* Can't do anything about this... */
	  if (!page->buffers && page_count(page) > 1)
	    continue;

	  /* Page not used -> free it 
	   * If it could not be locked it is somehow in use
	   * try another time */
	  if (TryLockPage(page))
	    continue;

	  /* Ok, a possible page.
	  * Note: can't unlock lru if we do we will have
	  * to restart this loop */

	  /* The page is in use, or was used very recently, put it in
	   * &young to make it ulikely that we will try to free it the next
	   * time */
	  dispose = &young;
	  if (test_and_clear_bit(PG_referenced, &page->flags))
	    goto dispose_continue;
		
	  
	  /* cursor takes page_lru's place in lru_list
	   * if disposed later it ends up at the same place!
	   * Note: compilers should be able to optimize this a bit... */
	  list_del(cursor);
	  list_add_tail(cursor, page_lru);
	  list_del(page_lru);
	  spin_unlock(&pagemap_lru_lock);

	  /* Spinlock is released, anything might happen to the list!
	   * But the cursor will remain on spot.
	   * - it will not be deleted from outside,
	   *   no one knows about it.
	   * - it will not be deleted by another shrink_mmap,
           *   zone_wake_kswapd == 0
	   */

	  /* If page is redisposed after attempt, place it at the same spot */
	  dispose = cursor;

	  /* avoid freeing the page while it's locked */
	  get_page(page);

	  /* Is it a buffer page? */
	  if (page->buffers) {
	    if (!try_to_free_buffers(page))
	      goto unlock_continue;
	    /* page was locked, inode can't go away under us */
	    if (!page->mapping) {
	      atomic_dec(&buffermem_pages);
	      goto made_buffer_progress;
	    }
	  }

	  /* Take the pagecache_lock spinlock held to avoid
	     other tasks to notice the page while we are looking at its
	     page count. If it's a pagecache-page we'll free it
	     in one atomic transaction after checking its page count. */
	  spin_lock(&pagecache_lock);

	  /*
	   * We can't free pages unless there's just one user
	   * (count == 2 because we added one ourselves above).
	   */
	  if (page_count(page) != 2)
	    goto cache_unlock_continue;

	  /*
	   * Is it a page swap page? If so, we want to
	   * drop it if it is no longer used, even if it
	   * were to be marked referenced..
	   */
	  if (PageSwapCache(page)) {
	    spin_unlock(&pagecache_lock);
	    __delete_from_swap_cache(page);
	    goto made_inode_progress;
	  }	

	  /* is it a page-cache page? */
	  if (page->mapping) {
	    if (!PageDirty(page) && !pgcache_under_min()) {
	      remove_page_from_inode_queue(page);
	      remove_page_from_hash_queue(page);
	      page->mapping = NULL;
	      spin_unlock(&pagecache_lock);
	      goto made_inode_progress;
	    }
	    goto cache_unlock_continue;
	  }

	  dispose = &forget;
	  printk(KERN_ERR "shrink_mmap: unknown LRU page!\n");
	  
cache_unlock_continue:
	  spin_unlock(&pagecache_lock);
unlock_continue:
	  spin_lock(&pagemap_lru_lock);
	  UnlockPage(page);
	  put_page(page);

dispose_continue:
	  list_add(page_lru, dispose);
	  /* final disposition to other list than lru? */
	  /* then return list index to old lru-list position */
	  if (dispose != cursor)
	    page_lru = cursor;
	  continue;

made_inode_progress:
	  page_cache_release(page);
made_buffer_progress:
	  UnlockPage(page);
	  put_page(page);
	  ret++;
	  spin_lock(&pagemap_lru_lock);
	  /* nr_lru_pages needs the spinlock */
	  nr_lru_pages--;

	  /* Might (and should) have been done by free calls
	   * p_zone->zone_wake_kswapd = 0;
	   */

	  /* If no more pages are needed to release on specifically
	     requested zone concider it done!
	     Note: zone might be NULL to make all requests fulfilled */
	  if (p_zone == zone && !p_zone->zone_wake_kswapd)
	    break;

	  /* Back to cursor position to ensure correct next step */
	  page_lru = cursor;
	}

	list_splice(&young, &lru_cache);
	list_del(cursor);

	spin_unlock(&pagemap_lru_lock);

	return ret;
}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
