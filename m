Date: Wed, 4 Aug 1999 19:07:33 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] minimal page-LRU
In-Reply-To: <Pine.LNX.4.10.9908041310460.2739-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9908041725380.401-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, MOLNAR Ingo <mingo@redhat.com>, "David S. Miller" <davem@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Aug 1999, Andrea Arcangeli wrote:

>tried to stay in sync as much as possible with the current 2.3.12 VM. The
>patch should be the _shorter_ as possible and it should be safe as far as
>the 2.3.12 VM is safe.

Continuing thinking about the code I just found a race condition between
the page-LRU shrink_mmap and truncate_inode_pages() ;).

The SMP race looks like this:

	shrink_mmap cpu 0			truncate_inode_pages cpu 1
	-----------------			--------------------------
	- remove page from lru list
	- release lru lock
						- grab pagecache_lock
						- increase page count
						- lockdown the page
						- flushpage and remove
						  from lru list but the 
						  page was not present
						  any lru lists!!

To fix this race I must simply avoid to release the pagemap_lru lock

	if (the page is not queued in any lru list &&
	    I have not yet locked down the page)

Once I have locked down the page I can also safely relase the lru lock
even if the page is not yet queued in any lru list, since
truncate_inode_pages() will wait me in lock_page() (and if
truncate_inode_pages() is waiting me I'll give up in the page_count()
check that it's done atomically with the pagecache_lock held).

I also need to access the local lru queues with the spinlock held since
truncate_inode_page() may remove the page from my local lru queue while I
am working on the global lru lists.

This fix is incremental with the minimal lru patch against 2.3.12 I posted
some hours ago.

--- 2.3.12-lru1/mm/filemap.c	Wed Aug  4 18:35:59 1999
+++ 2.3.12-lru/mm/filemap.c	Wed Aug  4 18:37:51 1999
@@ -238,35 +238,42 @@
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
+		dispose = lru;
 		if (test_and_clear_bit(PG_referenced, &page->flags))
-		{
 			/* Roll the page at the top of the lru list,
 			 * we could also be more aggressive putting
 			 * the page in the young-dispose-list, so
 			 * avoiding to free young pages in each pass.
 			 */
-			list_add(page_lru, lru);
-			continue;
-		}
-		spin_unlock(&pagemap_lru_lock);
+			goto dispose_continue;
 
 		dispose = &old;
+		/* don't account passes over not DMA pages */
 		if ((gfp_mask & __GFP_DMA) && !PageDMA(page))
 			goto dispose_continue;
 
 		(*count)--;
 
 		dispose = &young;
+		if (TryLockPage(page))
+			goto dispose_continue;
+
+		/* Release the pagemap_lru lock even if the page is not yet
+		   queued in any lru queue since we have just locked down
+		   the page so nobody else may SMP race with us running
+		   a lru_cache_del() (lru_cache_del() always run with the
+		   page locked down ;). */
+		spin_unlock(&pagemap_lru_lock);
+
 		/* avoid unscalable SMP locking */
 		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
+			goto unlock_noput_continue;
 
+		/* Take the pagecache_lock spinlock held to avoid
+		   other tasks to notice the page while we are looking at its
+		   page count. If it's a pagecache-page we'll free it
+		   in one atomic transaction after checking its page count. */
 		spin_lock(&pagecache_lock);
-		if (TryLockPage(page))
-		{
-			spin_unlock(&pagecache_lock);
-			goto dispose_continue;
-		}
 
 		/* avoid freeing the page while it's locked */
 		get_page(page);
@@ -326,11 +333,21 @@
 unlock_continue:
 		UnlockPage(page);
 		put_page(page);
+dispose_relock_continue:
+		/* even if the dispose list is local, a truncate_inode_page()
+		   may remove a page from its queue so always
+		   synchronize with the lru lock while accesing the
+		   page->lru field */
+		spin_lock(&pagemap_lru_lock);
+		list_add(page_lru, dispose);
+		continue;
+
+unlock_noput_continue:
+		UnlockPage(page);
+		goto dispose_relock_continue;
+
 dispose_continue:
-		/* no need of the spinlock to play with the
-		   local dispose lists */
 		list_add(page_lru, dispose);
-		spin_lock(&pagemap_lru_lock);
 	}
 	goto out;
 

Andrea

PS. I also added some more comment ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
