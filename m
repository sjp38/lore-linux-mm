Date: Tue, 11 Apr 2000 18:22:31 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004110245.TAA57888@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004111752550.19969-100000@maclaurin.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Apr 2000, Kanoj Sarcar wrote:

>While forking, a parent might copy a swap handle into the child, but we

That's a bug in fork. Simply let fork to check if the swaphandle is SWAPOK
or not before increasing the swap count. If it's SWAPOK then
swap_duplicate succesfully, otherwise do the swapin using swap cache based
locking as swapin now does in my current tree (check if the pte is changed
before go to increase the swap side and undo the swapcache insertion in
such case and serialize with swapoff and swap_out with page_cache_lock).

>Same problem exists in exit_mmap. In this case, one of the routines inside
>exit_mmap() can very plausibly go to sleep. Eg: file_unmap.

exit_mmap can sleep there. But it have not to hide the mmap as said in
earlier email. It have to zap_page_range and then unlink the vmas all bit
by bit serializing using the vmlist_modify_lock.

>> swap_out() can't grab the mmap_sem for obvious reasons, so if you only
>
>Why not? Of course, not with tasklist_lock held (Hehehe, I am not that 
>stupid :-)). But other mechanisms are possible.

Lock recursion -> deadlock.

	userspace runs
	page fault
		down(&current->mm->mmap_sem);
		try_to_free_pages();
			swap_out();
			down(&current->mm->mmap_sem); <- you deadlocked			

We are serializing swap_out/do_wp_page with the page_cache_lock (in
swapout the page_cache_lock is implied by the vmlist_access_lock).

In the same way I'm serializing swapoff with swapin using swap cache based
on locking and pagetable checks with page_cache_lock acquired and
protecting swapoff with the vmlist_access_lock() that imply the
page_cache_lock.

Using the page_cache_lock and rechecking page table looks the right way to
go to me. It have no design problems that ends in lock recursion.

>Actually, let me put out the patch, for different reasons, IMO, it is the
>right long term solution ...

The patch is welcome indeed. However relying on the mmap_sem looks the
wrong way to me.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
