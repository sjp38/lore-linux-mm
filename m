Date: Thu, 30 Mar 2000 18:50:13 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: shrink_mmap SMP race fix
In-Reply-To: <Pine.LNX.4.21.0003301639540.368-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0003301835020.494-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

I also did two incremental locking change (for performance). The old code
was doing:

		if (TryLockPage(page))
			goto dispose_continue;

		/* Release the pagemap_lru lock even if the page is not yet
		   queued in any lru queue since we have just locked down
		   the page so nobody else may SMP race with us running
		   a lru_cache_del() (lru_cache_del() always run with the
		   page locked down ;). */
		spin_unlock(&pagemap_lru_lock);

		/* avoid unscalable SMP locking */
		if (!page->buffers && page_count(page) > 1)
			goto unlock_noput_continue;

We was doing the guess check to avoid unscalable locking in the tight loop
too late (after having just played with the pagemap_lru_lock and the
per-page lock). I moved the unscalable locking change inside the
pagemap_lru_lock critical section so that now no lock get touched in the
tight loop (except for the reference bit).

Then this following section of code was doing:

		/* Take the pagecache_lock spinlock held to avoid
		   other tasks to notice the page while we are looking at its
		   page count. If it's a pagecache-page we'll free it
		   in one atomic transaction after checking its page count. */
		spin_lock(&pagecache_lock);

		/* avoid freeing the page while it's locked */
		get_page(page);

		/* Is it a buffer page? */
		if (page->buffers) {
			spin_unlock(&pagecache_lock);
			if (!try_to_free_buffers(page))
				goto unlock_continue;
			/* page was locked, inode can't go away under us */
			if (!page->mapping) {
				atomic_dec(&buffermem_pages);
				goto made_buffer_progress;
			}
			spin_lock(&pagecache_lock);
		}

and as far I can tell we can instead move the spin_lock(&pagecache_lock)
_after_ the page->buffers path and to increase the per-page counter
(get_page(page)) without any lock acquired (removing a not necessary
lock/unlock in the buffer freeing path). We are allowed to check the 
page->buffer with only the per-page lock held (nobody can drop
page->buffers from under us if we hold the lock on the page).

This is the incremental cleanup:

--- 2.3.99-pre3aa1-alpha/mm/filemap.c.~1~	Thu Mar 30 16:10:38 2000
+++ 2.3.99-pre3aa1-alpha/mm/filemap.c	Thu Mar 30 18:24:29 2000
@@ -250,6 +250,11 @@
 		count--;
 
 		dispose = &young;
+
+		/* avoid unscalable SMP locking */
+		if (!page->buffers && page_count(page) > 1)
+			goto dispose_continue;
+
 		if (TryLockPage(page))
 			goto dispose_continue;
 
@@ -260,22 +265,11 @@
 		   page locked down ;). */
 		spin_unlock(&pagemap_lru_lock);
 
-		/* avoid unscalable SMP locking */
-		if (!page->buffers && page_count(page) > 1)
-			goto unlock_noput_continue;
-
-		/* Take the pagecache_lock spinlock held to avoid
-		   other tasks to notice the page while we are looking at its
-		   page count. If it's a pagecache-page we'll free it
-		   in one atomic transaction after checking its page count. */
-		spin_lock(&pagecache_lock);
-
 		/* avoid freeing the page while it's locked */
 		get_page(page);
 
 		/* Is it a buffer page? */
 		if (page->buffers) {
-			spin_unlock(&pagecache_lock);
 			if (!try_to_free_buffers(page))
 				goto unlock_continue;
 			/* page was locked, inode can't go away under us */
@@ -283,9 +277,14 @@
 				atomic_dec(&buffermem_pages);
 				goto made_buffer_progress;
 			}
-			spin_lock(&pagecache_lock);
 		}
 
+		/* Take the pagecache_lock spinlock held to avoid
+		   other tasks to notice the page while we are looking at its
+		   page count. If it's a pagecache-page we'll free it
+		   in one atomic transaction after checking its page count. */
+		spin_lock(&pagecache_lock);
+
 		/*
 		 * We can't free pages unless there's just one user
 		 * (count == 2 because we added one ourselves above).
@@ -326,12 +325,6 @@
 		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
 		put_page(page);
-		list_add(page_lru, dispose);
-		continue;
-
-unlock_noput_continue:
-		spin_lock(&pagemap_lru_lock);
-		UnlockPage(page);
 		list_add(page_lru, dispose);
 		continue;
 

It's running without problems here so far.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
