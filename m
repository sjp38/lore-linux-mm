Message-ID: <391B71BE.6302F9BD@norran.net>
Date: Fri, 12 May 2000 04:51:42 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [RFC][PATCH] shrink_mmap avoid list_del (Was: Re: [PATCH] Recent VM
 fiasco - fixed)
References: <Pine.LNX.4.10.10005111700520.1319-100000@penguin.transmeta.com>
Content-Type: multipart/mixed;
 boundary="------------E9FBE4D31EDAFD1C39BE086D"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------E9FBE4D31EDAFD1C39BE086D
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

I tried to find a way to walk the lru list without list_del.

Here is my patch:
- not compiled nor run (low on HD...)

Could something like this be used?
If no, why not?

/RogerL


Linus Torvalds wrote:
> 
> On Thu, 11 May 2000, Simon Kirby wrote:
> >
> > Hrm!  pre7 release seems to be even better.  113 vmstat-line-seconds now
> > (yes, I know this isn't a very scientific testing method :)).  Second try
> > was 114 vmstat-line-seconds.  classzone-27 did it in 107, so that's not
> > very far off!  Also, it swapped much less this time, and used less CPU.
> > vmstat output attached.
> 
> The final pre7 did something that I'm not entirely excited about, but that
> kind of makes sense at least from a CPU standpoint (as the SGI people have
> repeated multiple times). What the real pre7 does is to just move any page
> that has problems getting free'd to the head of the LRU list, so that we
> won't try it immediately the next time. This way we don't test the same
> pages over and over again when they are either shared, in the wrong zone,
> or have dirty/locked buffers.
> 
> It means that the "LRU" is less LRU, but you could see it as a "how hard
> do we want to free this" pressure-based system that really a least
> recently _used_ system. And it avoids the "repeat the whole thing on the
> same page" issue. And it looks like it behaves reasonably well, while
> saving a lot of CPU.
> 
> Knock wood.
> 
> I'm still considering the pre7 as more a "ok, I tried to get rid of the
> cruft" thing. Most of the special case code that has accumulated lately is
> gone. We can start adding stuff back now, I'm happy that the basics are
> reasonably clean.
> 
> I think Ingo already posted a very valid concern about high-memory
> machines, and there are other issues we should look at. I just want to be
> in a position where we can look at the code and say "we do X because Y",
> rather than a collection of random tweaks that just happens to work.
> 
>                 Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--------------E9FBE4D31EDAFD1C39BE086D
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.3.99-pre7-9-shrink_mmap.1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.3.99-pre7-9-shrink_mmap.1"

diff -Naur linux-2.3-pre9--/mm/filemap.c linux-2.3/mm/filemap.c
--- linux-2.3-pre9--/mm/filemap.c	Fri May 12 02:42:19 2000
+++ linux-2.3/mm/filemap.c	Fri May 12 04:28:30 2000
@@ -236,7 +236,6 @@
 int shrink_mmap(int priority, int gfp_mask)
 {
 	int ret = 0, count;
-	LIST_HEAD(old);
 	struct list_head * page_lru, * dispose;
 	struct page * page = NULL;
 	
@@ -244,26 +243,29 @@
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	page_lru = &lru_cache;
+	while (count > 0 && (page_lru = page_lru->prev) != &lru_cache) {
 		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
 
 		dispose = &lru_cache;
 		if (PageTestandClearReferenced(page))
 			goto dispose_continue;
 
 		count--;
-		dispose = &old;
+
+		dispose = NULL;
 
 		/*
 		 * Avoid unscalable SMP locking for pages we can
 		 * immediate tell are untouchable..
 		 */
 		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
+			continue;
 
+		/* Lock this lru page, reentrant
+		 * will be disposed correctly when unlocked */
 		if (TryLockPage(page))
-			goto dispose_continue;
+			continue;
 
 		/* Release the pagemap_lru lock even if the page is not yet
 		   queued in any lru queue since we have just locked down
@@ -281,7 +283,7 @@
 		 */
 		if (page->buffers) {
 			if (!try_to_free_buffers(page))
-				goto unlock_continue;
+				goto page_unlock_continue;
 			/* page was locked, inode can't go away under us */
 			if (!page->mapping) {
 				atomic_dec(&buffermem_pages);
@@ -336,27 +338,43 @@
 
 cache_unlock_continue:
 		spin_unlock(&pagecache_lock);
-unlock_continue:
+page_unlock_continue:
 		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
 		put_page(page);
+		continue;
+
 dispose_continue:
-		list_add(page_lru, dispose);
-	}
-	goto out;
+		/* have the pagemap_lru_lock, lru cannot change */
+		{
+		  struct list_head * page_lru_to_move = page_lru; 
+		  page_lru = page_lru->next; /* continues with page_lru.prev */
+		  list_del(page_lru_to_move);
+		  list_add(page_lru_to_move, dispose);
+		}
+		continue;
 
 made_inode_progress:
-	page_cache_release(page);
+		page_cache_release(page);
 made_buffer_progress:
-	UnlockPage(page);
-	put_page(page);
-	ret = 1;
-	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
+		/* like to have the lru lock before UnlockPage */
+		spin_lock(&pagemap_lru_lock);
 
-out:
-	list_splice(&old, lru_cache.prev);
+		UnlockPage(page);
+		put_page(page);
+		ret++;
+
+		/* lru manipulation needs the spin lock */
+		{
+		  struct list_head * page_lru_to_free = page_lru; 
+		  page_lru = page_lru->next; /* continues with page_lru.prev */
+		  list_del(page_lru_to_free);
+		}
+
+		/* nr_lru_pages needs the spinlock */
+		nr_lru_pages--;
+
+	}
 
 	spin_unlock(&pagemap_lru_lock);
 
diff -Naur linux-2.3-pre9--/mm/vmscan.c linux-2.3/mm/vmscan.c
--- linux-2.3-pre9--/mm/vmscan.c	Fri May 12 02:42:19 2000
+++ linux-2.3/mm/vmscan.c	Fri May 12 04:32:16 2000
@@ -443,10 +443,9 @@
 
 	priority = 6;
 	do {
-		while (shrink_mmap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
+	        count -= shrink_mmap(priority, gfp_mask);
+		if (count <= 0)
+		  goto done;
 
 		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
@@ -481,10 +480,9 @@
 	} while (--priority >= 0);
 
 	/* Always end on a shrink_mmap.. */
-	while (shrink_mmap(0, gfp_mask)) {
-		if (!--count)
-			goto done;
-	}
+	count -= shrink_mmap(priority, gfp_mask);
+	if (count <= 0)
+	  goto done;
 
 	return 0;
 

--------------E9FBE4D31EDAFD1C39BE086D--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
