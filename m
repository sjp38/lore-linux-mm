Date: Tue, 29 Jun 1999 00:48:18 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <Pine.BSO.4.10.9906281648010.24888-100000@funky.monkey.org>
Message-ID: <Pine.LNX.4.10.9906290032460.1588-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 1999, Chuck Lever wrote:

>that doesn't hurt because try_to_free_page() doesn't acquire anything but
>the kernel lock in my patch.  it looks something like:
>
>int try_to_free_pages(unsigned int gfp_mask)
>{
>	int priority = 6;
>	int count = pager_daemon.swap_cluster;
> 
> 	wake_up_process(kswapd_process);
>
>	lock_kernel();
>	do {
>		while (shrink_mmap(priority, gfp_mask)) {
>			if (!--count)
>				goto done;
>		}
>
>		shrink_dcache_memory(priority, gfp_mask);
>	} while (--priority >= 0);
>done:
>	/* maybe slow this thread down while kswapd catches up */
>	if (gfp_mask & __GFP_WAIT) {
>		current->policy |= SCHED_YIELD;
>		schedule();
>	}
>	unlock_kernel();
>	return 1;
>}

How do you get the information about "when" to start the swap activities?
Maybe you have a separate try_to_free_pages() that does the plain-current
try_to_free_pages() and you call it only from kswapd?

My guess is that you'll end with zero cache and you'll have to page-in
from disk like h*ell when you reach swap with a resulting really bad
iteractive behaviour.

I think that being able to swapout from the process context is a very nice
feature because it cause the trashing task to block. This may looks not
very important with the current low_on_memory bit, but here I have a
per-task `trashing_memory' bitflag :).

Anyway we may re-implement recursive semaphores to avoid deadlocking into
the page fault path...

>the eventual goal of my adventure is to drop the kernel lock while doing
>the page COW in do_wp_page, since in 2.3.6+, the COW is again protected
>because of race conditions with kswapd.  this "protection" serializes all

I thought a bit about that as well. I also coded a maybe possible
solution. Look at this snapshot:

Index: linux/mm/memory.c
===================================================================
RCS file: /var/cvs/linux/mm/memory.c,v
retrieving revision 1.1.1.10
retrieving revision 1.1.2.39
diff -u -r1.1.1.10 -r1.1.2.39
--- linux/mm/memory.c	1999/06/28 15:10:09	1.1.1.10
+++ linux/mm/memory.c	1999/06/28 17:08:59	1.1.2.39
@@ -607,16 +618,23 @@
 	struct page * page;
 	
 	new_page = __get_free_page(GFP_USER);
-	/* Did swap_out() unmap the protected page while we slept? */
-	if (pte_val(*page_table) != pte_val(pte))
-		goto end_wp_page;
 	old_page = pte_page(pte);
 	if (MAP_NR(old_page) >= max_mapnr)
 		goto bad_wp_page;
 	tsk->min_flt++;
 	page = mem_map + MAP_NR(old_page);
-	
+
+	lock_page(page);
 	/*
+	 * We can release the big kernel lock here since
+	 * kswapd will see the page locked. -Andrea
+	 */
+	unlock_kernel();
+	/* Did swap_out() unmap the protected page while we slept? */
+	if (pte_val(*page_table) != pte_val(pte))
+		goto end_wp_page;
+
+	/*
 	 * We can avoid the copy if:
 	 * - we're the only user (count == 1)
 	 * - the only other user is the swap cache,
@@ -630,19 +648,15 @@
 			break;
 		if (swap_count(page->offset) != 1)
 			break;
+		lru_unmap_cache(page);
 		delete_from_swap_cache(page);
+		put_page_refcount(page);
 		/* FallThrough */
 	case 1:
 		flush_cache_page(vma, address);
 		set_pte(page_table, pte_mkdirty(pte_mkwrite(pte)));
 		flush_tlb_page(vma, address);
-end_wp_page:
-		/*
-		 * We can release the kernel lock now.. Now swap_out will see
-		 * a dirty page and so won't get confused and flush_tlb_page
-		 * won't SMP race. -Andrea
-		 */
-		unlock_kernel();
+		UnlockPage(page);
 
 		if (new_page)
 			free_page(new_page);
@@ -652,6 +666,7 @@
 	if (!new_page)
 		goto no_new_page;
 
+	lru_unmap_cache(page);
 	if (PageReserved(page))
 		++vma->vm_mm->rss;
 	copy_cow_page(old_page,new_page);
@@ -660,18 +675,26 @@
 	flush_cache_page(vma, address);
 	set_pte(page_table, pte_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot))));
 	flush_tlb_page(vma, address);
-	unlock_kernel();
+	UnlockPage(page);
 	__free_page(page);
 	return 1;
 
 bad_wp_page:
+	unlock_kernel();
 	printk("do_wp_page: bogus page at address %08lx (%08lx)\n",address,old_page);
 	send_sig(SIGKILL, tsk, 1);
-no_new_page:
-	unlock_kernel();
 	if (new_page)
 		free_page(new_page);
 	return 0;
+no_new_page:
+	UnlockPage(page);
+	oom(tsk);
+	return 0;
+end_wp_page:
+	UnlockPage(page);
+	if (new_page)
+		free_page(new_page);
+	return 1;
 }
 
 /*


It's only a partial snapshot, but it should show the picture. Basically I
am locking down the page with the lock held, then when I have the page
locked (I may sleep as well to lock it) I check if kswapd freed the
mapping or if I can go ahead without the big kernel lock. It basically
works but I had not the time to test it carefully yet.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
