Date: Sun, 6 Jun 1999 19:46:30 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: [patch] 2.2.9_andrea-VM1.gz
Message-ID: <Pine.LNX.4.10.9906061944290.8652-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

I released this VM patch to fix some problem of 2.2.x. (mainly the VM
issue that may cause people to downgrade to 2.0.x to get rasonable
performances under very high VM load).

Here a detailed description of the changes in patch-order:

o	send SIGKILL instead of SIGBUS when OOM in do_page_fault
o	report the cachesize in SYSRQ+M
o	removed the get_request_wait in ll_rw_block that was unused
o	avoids all not needed run_task_queue() in the functions
	that waits for I/O completation
o	don't account failed WRITEA/READA request in the output/input
	system stats
o	added include of mm.h to buffer.c since it uses PageLocked()
o	readded (original from SCT) the size_buffer_size to take balance
	even using different blocksizes
o	`update` killed. bdflush takes care to flush old buffers
	every `interval' clock ticks
o	increased the timeout of buffers to 1minute and of the superblock
	to 30sec
o	fixed percentage of dirty buffers after which we block for
	kflushd I/O compleation. 1/2 of interesting ram dirty will
	cause us to sleep. 1/4 of interesting ram dirty will
	start kflushd in background
o	free ram must be considered as clean buffers
o	some wait_on.. that should be __wait_on... also some brelse
	should be __brelse
o	the buffer code now uses some helper function to manage the lists
	to make the code readable
o	new mul hashfn suggested by Chuck Lever and Peter Steiner
o	put_last_free now takes care to make the buffer freeable
o	enforced by design that every lru buffer is also hashed into
	the hashqueue
o	invalidate_buffers and set_blocksize rewrote to avoid
	races (refiled buffer issue)
o	set_writetime should be inline and mark_buffer_dirty should
	be exported
o	use of a trashing_IO per-task-bitflag to allow not trashing_IO
	task to write dirty buffer without waiting for kflushd
	IO completation
o	moved the stuff that checks for too_many_dirty_buffers from
	refile_buffer to mark_buffer_dirty
o	removed some not needed intialization to zero since the buffer
	heads are always completly zeroed
o	killed both the swaplockmap and the free_after bit
o	removed the need for locking while handling the async-buffer 
	reuse_list by using oredered writes to memory and xchg
o	removed all cli() in buffer.c with a global spinlock.
	we need a per-pagemap locking, but the spinlock is global
	since it doesn't worth to add a spinlock to the pagemap
	because the async_end_io callback is going to be recalled
	with the _global_ io_request_lock held
o	try_to_free_buffers flushes buffers to disk itself without
	using kflushd
o	show_buffers() runs into an irq and since it browses all
	lru lists it should run only if the big kernel lock
	is not held
o	rewrote buffer hash dynamic resizing
o	zeroed swap information about the mm upon exec
o	avoid starvation of readers during continous write to disk
	like in the `cp /dev/zero /tmp' case
o	reordered the buffer head fields trying to get the accessed
	fileds in the same cacheline (supposing 32byte wide cacheline
	of course) during the buffer loops
o	pagemap-lru handling, all cache/buffer pages are
	placed in a lru queue. There is a lru queue for the swap cache
	and one for the cache/buffers. Mapped swap cache pages
	can then goes into the cache/buffer lru even if they born
	in the swap-cache-lru. This allow us to reach freeable
	pages in O(1) and it kills the clock algorithm of the
	current shrink_mmap. The clock algorithm couldn't assure a fair
	swapout behaviour
o	persistence of data in the swap
o	trashing memory heuristic where not trashing mem tasks
	are allowed to alloc memory without block in freeing pages
o	removed all sysclt limit, almost everything is autobalancing now
o	removed some not needed check from do_wp_page (things can't
	change since they are in the stack, this is been pointed out
	some time ago in linux-mm btw)
o	put_page shouldn't ever be able to see a not null pte
	even sleeping (mm semaphore)
o	I think to have fixed two potential SMP races in do_wp_page.
	do_wp_page currently unlock_kernel() before setting the
	pte dirty. So swap_out may sees the page clean
	and it may get confused for example if the page was a swap 
	cache page where do_wp_page is going to took over it. So swap_out
	may go to unmap/free the page while instead the page is
	a dirty page.
	swap_out may get confused even if do_wp_page is not tooking
	over the swap cache page but it's doing a normal COW with
	a not swap cache page. Doing that swap_out may unmap the page
	for the old mapping. But then after the COW do_wp_page
	will do a second free_page() over the same page referred
	to the same mapping.

This is the relevant part of my patch (ignore the lru_unmap_cache):

 	case 1:
-		/* We can release the kernel lock now.. */
-		unlock_kernel();
-
 		flush_cache_page(vma, address);
 		set_pte(page_table, pte_mkdirty(pte_mkwrite(pte)));
+
+		/*
+		 * We can release the kernel lock now.. Now swap_out will see
+		 * a dirty page and so won't get confused. -Andrea
+		 */
+		unlock_kernel();
+
 		flush_tlb_page(vma, address);
-end_wp_page:
 		if (new_page)
 			free_page(new_page);
 		return 1;
 	}
 		
-	unlock_kernel();
 	if (!new_page)
-		return 0;
+		goto no_new_page;
 
-	if (PageReserved(mem_map + MAP_NR(old_page)))
+	lru_unmap_cache(page_map);
+	if (PageReserved(page_map))
 		++vma->vm_mm->rss;
 	copy_cow_page(old_page,new_page);
 	flush_page_to_ram(old_page);
 	flush_page_to_ram(new_page);
 	flush_cache_page(vma, address);
 	set_pte(page_table, pte_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot))));
-	free_page(old_page);
+	unlock_kernel();
+	__free_page(page_map);
 	flush_tlb_page(vma, address);
 	return 1;

o	the end_wp_page path forgot to unlock_kernel() before return
o	no need to reset the referenced bit on every free_page anymore.
	I reset the bit only before adding the cache page to the lru
	list.
o	shm now does async swapout using the swap cache to resolve
	the synchronization between read/writes/swapout
o	get_swap_page searches for an empty cluster of swap
	before accepting a fragmented cluster, this additional
	logic won't harm performances since most of the time
	we just know where to swapout a page (persistence issue).
o	fixed some minor bug in the si->lowest_bit/highest_bit handling
	(the swap_free part of the fix is been originally
	pointed out from Mark Hemment)
o	avoid running wake_up_process on a running task (kswapd) otherwise
	reschedule_idle may generate useless rescheduling

I guess it should compile/work also on Alpha, except for the spin_trylock
bit that in Alpha UP seems wrong to me, this patch should fix the Alpha
bit:

Index: linux/include/asm-alpha/spinlock.h
===================================================================
RCS file: /var/cvs/linux/include/asm-alpha/spinlock.h,v
retrieving revision 1.1.1.1
retrieving revision 1.1.2.2
diff -u -r1.1.1.1 -r1.1.2.2
--- linux/include/asm-alpha/spinlock.h	1999/01/18 01:27:22	1.1.1.1
+++ linux/include/asm-alpha/spinlock.h	1999/05/29 17:04:31	1.1.2.2
@@ -18,11 +18,11 @@
   #define SPIN_LOCK_UNLOCKED (spinlock_t) { 0 }
 #endif
 
-#define spin_lock_init(lock)			((void) 0)
-#define spin_lock(lock)				((void) 0)
-#define spin_trylock(lock)			((void) 0)
-#define spin_unlock_wait(lock)			((void) 0)
-#define spin_unlock(lock)			((void) 0)
+#define spin_lock_init(lock)			do { } while(0)
+#define spin_lock(lock)				do { } while(0)
+#define spin_trylock(lock)			(1)
+#define spin_unlock_wait(lock)			do { } while(0)
+#define spin_unlock(lock)			do { } while(0)
 #define spin_lock_irq(lock)			cli()
 #define spin_unlock_irq(lock)			sti()

You can donwload the VM patch against 2.2.9 from here:
 
	ftp://e-mind.com/pub/andrea/kernel-patches/2.2.9_andrea-VM1.gz

As usual you are suggested to download from the mirrors though 8^):

	ftp://ftp.suse.com/pub/people/andrea/kernel-patches/2.2.9_andrea-VM1.gz
	(USA, Thanks to SuSE -> http://www.suse.com/, large bandwith)

	ftp://ftp.linux.it/pub/People/andrea/kernel-patches/2.2.9_andrea-VM1.gz
	(Italy, Thanks to linux.it guys)

	ftp://master.softaplic.com.br/pub/andrea/kernel-patches/2.2.9_andrea-VM1.gz
	(Brazil, Thanks to Edesio Costa e Silva <edesio@acm.org>, 2MBits/sec)

Comments as always are welcome :).

Andrea Arcangeli

PS. The equivalent patch for 2.3.x is just in Linus's mailbox.

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
