Date: Thu, 6 Apr 2000 18:11:43 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004041915290.1653-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0004061802080.6583-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Apr 2000, Andrea Arcangeli wrote:

> Could you explain me how acquire_swap_entry() can return an invalid swap
> entry (starting with a random page->index of course)? I can't exclude
> there's a bug, but acquire_swap_entry was meant to return only valid
> entries despite of the page->index possible garbage and it seems it's
> doing that.

First off, it doesn't verify that all of the bits which should be clear in
a swap entry actually are -- eg bit 0 (present) can and is getting
set.  It would have to rebuild and compare the swap entry produced by
SWP_ENTRY(type,offset) to be 100% sure that it is a valid swap entry.

And yes, I see what you're doing with the PG_swap_entry code now, although
I'm thinking it might be better done by taking a look at what swap entries
are present in the page tables near the page (since otherwise a pair of
fork()ed process could end up splitting contiguous swap entries if the
swapout is timed just right).  But that's for later...

> >As well as from shrink_mmap.
> 
> I would not be complaining your patch if you would put the clear_bit
> within shrink_mmap :).

Heheh, okay I've moved it there.  Just in case I've also added a
BUG() check in free_pages_okay to make sure there aren't any other places
that have been missed.

		-ben

diff -ur 2.3.99-pre4-4/mm/filemap.c linux-test/mm/filemap.c
--- 2.3.99-pre4-4/mm/filemap.c	Thu Apr  6 15:03:05 2000
+++ linux-test/mm/filemap.c	Thu Apr  6 17:50:39 2000
@@ -300,6 +300,7 @@
 		if (PageSwapCache(page)) {
 			spin_unlock(&pagecache_lock);
 			__delete_from_swap_cache(page);
+			ClearPageSwapEntry(page);
 			goto made_inode_progress;
 		}	
 
diff -ur 2.3.99-pre4-4/mm/page_alloc.c linux-test/mm/page_alloc.c
--- 2.3.99-pre4-4/mm/page_alloc.c	Thu Apr  6 15:03:05 2000
+++ linux-test/mm/page_alloc.c	Thu Apr  6 17:38:10 2000
@@ -110,6 +110,8 @@
 		BUG();
 	if (PageDecrAfter(page))
 		BUG();
+	if (PageSwapEntry(page))
+		BUG();
 
 	zone = page->zone;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
