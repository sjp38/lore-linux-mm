Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA16593
	for <linux-mm@kvack.org>; Thu, 31 Dec 1998 13:02:23 -0500
Date: Thu, 31 Dec 1998 19:00:18 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.2.0 Bug summary
In-Reply-To: <199812290146.BAA12687@terrorserver.swansea.linux.org.uk>
Message-ID: <Pine.LNX.3.96.981231182534.658A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@terrorserver.swansea.linux.org.uk>
Cc: linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, Benjamin Redelings I <bredelin@ucsd.edu>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Dec 1998, Alan Cox wrote:

> o	Linus VM is still 20% slower than sct vm on an 8Mb machine
> 	[benchmarks kernel build and netscape]

Today I start playing with Linus's vm in 2.2.0-pre1 and I changed the
semantics of many things and I added heuristic to avoid that one process
trashing memory will hang other "normal" processes. This my new VM I
developed today is _far_ better than sct's ac11 vm and anything I tried
before. I would like if somebody could try it also on low memory machines
and feedback what happens there.  I don't have enough spare time to test
it on many kind of hardware too. 

The same benchmark that was taking 106 sec on clean 2.2.0-pre1 to
dirtifying 160Mbyte of virtual memory (run with 128RAM and 72swap of phis
mem), now runs in 90 sec but this is not the most important thing, the
good point is that the cache/buffer/swap levels now are perfectly stable
and all other processes runs fine and get not out of cache even if there's
a memory trahser running at the same time.

Comments?

Ah, the shrink_mmap limit was wrong since we account only not referenced
pages.

Patch against 2.2.0-pre1:

Index: linux/mm/filemap.c
diff -u linux/mm/filemap.c:1.1.1.7 linux/mm/filemap.c:1.1.1.1.2.29
--- linux/mm/filemap.c:1.1.1.7	Wed Dec 23 15:25:21 1998
+++ linux/mm/filemap.c	Thu Dec 31 17:56:27 1998
@@ -125,7 +129,7 @@
 	struct page * page;
 	int count;
 
-	count = (limit<<1) >> (priority);
+	count = limit >> priority;
 
 	page = mem_map + clock;
 	do {
@@ -182,6 +186,7 @@
 	return 0;
 }
 
+#if 0
 /*
  * This is called from try_to_swap_out() when we try to get rid of some
  * pages..  If we're unmapping the last occurrence of this page, we also
@@ -201,6 +206,7 @@
 	remove_inode_page(page);
 	return 1;
 }
+#endif
 
 /*
  * Update a page cache copy, when we're doing a "write()" system call
Index: linux/mm/page_alloc.c
diff -u linux/mm/page_alloc.c:1.1.1.3 linux/mm/page_alloc.c:1.1.1.1.2.11
--- linux/mm/page_alloc.c:1.1.1.3	Sun Dec 20 16:31:11 1998
+++ linux/mm/page_alloc.c	Thu Dec 31 17:56:27 1998
@@ -241,7 +241,29 @@
 			goto nopage;
 		}
 
-		if (freepages.min > nr_free_pages) {
+		if (freepages.high < nr_free_pages)
+		{
+			if (current->trashing_memory)
+			{
+				current->trashing_memory = 0;
+#if 0
+				printk("trashing end for %s\n", current->comm);
+#endif
+			}
+		} else if (freepages.min > nr_free_pages) {
+			if (!current->trashing_memory)
+			{
+				current->trashing_memory = 1;
+#if 0
+				printk("trashing start for %s\n", current->comm);
+#endif
+			}
+		}
+
+		/*
+		 * Block the process that is trashing memory. -arca
+		 */
+		if (current->trashing_memory) {
 			int freed;
 			freed = try_to_free_pages(gfp_mask, SWAP_CLUSTER_MAX);
 			/*
Index: linux/mm/swap_state.c
diff -u linux/mm/swap_state.c:1.1.1.3 linux/mm/swap_state.c:1.1.1.1.2.8
--- linux/mm/swap_state.c:1.1.1.3	Sun Dec 20 16:31:12 1998
+++ linux/mm/swap_state.c	Tue Dec 22 18:42:03 1998
@@ -248,7 +248,7 @@
 		delete_from_swap_cache(page);
 	}
 	
-	free_page(addr);
+	__free_page(page);
 }
 
 
@@ -261,6 +261,9 @@
 struct page * lookup_swap_cache(unsigned long entry)
 {
 	struct page *found;
+#ifdef	SWAP_CACHE_INFO
+	swap_cache_find_total++;
+#endif
 	
 	while (1) {
 		found = find_page(&swapper_inode, entry);
@@ -268,8 +271,12 @@
 			return 0;
 		if (found->inode != &swapper_inode || !PageSwapCache(found))
 			goto out_bad;
-		if (!PageLocked(found))
+		if (!PageLocked(found)) {
+#ifdef	SWAP_CACHE_INFO
+			swap_cache_find_success++;
+#endif
 			return found;
+		}
 		__free_page(found);
 		__wait_on_page(found);
 	}
Index: linux/mm/vmalloc.c
diff -u linux/mm/vmalloc.c:1.1.1.2 linux/mm/vmalloc.c:1.1.1.1.2.2
--- linux/mm/vmalloc.c:1.1.1.2	Fri Nov 27 11:19:11 1998
+++ linux/mm/vmalloc.c	Fri Nov 27 11:41:42 1998
@@ -185,7 +185,8 @@
 	for (p = &vmlist ; (tmp = *p) ; p = &tmp->next) {
 		if (tmp->addr == addr) {
 			*p = tmp->next;
-			vmfree_area_pages(VMALLOC_VMADDR(tmp->addr), tmp->size);
+			vmfree_area_pages(VMALLOC_VMADDR(tmp->addr),
+					  tmp->size - PAGE_SIZE);
 			kfree(tmp);
 			return;
 		}
Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.6 linux/mm/vmscan.c:1.1.1.1.2.43
--- linux/mm/vmscan.c:1.1.1.6	Tue Dec 22 11:56:28 1998
+++ linux/mm/vmscan.c	Thu Dec 31 17:56:27 1998
@@ -162,8 +162,8 @@
 			 * copy in memory, so we add it to the swap
 			 * cache. */
 			if (PageSwapCache(page_map)) {
-				free_page(page);
-				return (atomic_read(&page_map->count) == 0);
+				__free_page(page_map);
+				return atomic_read(&page_map->count) + 1;
 			}
 			add_to_swap_cache(page_map, entry);
 			/* We checked we were unlocked way up above, and we
@@ -180,8 +180,8 @@
 		 * asynchronously.  That's no problem, shrink_mmap() can
 		 * correctly clean up the occassional unshared page
 		 * which gets left behind in the swap cache. */
-		free_page(page);
-		return 1;	/* we slept: the process may not exist any more */
+		__free_page(page_map);
+		return atomic_read(&page_map->count) + 1;	/* we slept: the process may not exist any more */
 	}
 
 	/* The page was _not_ dirty, but still has a zero age.  It must
@@ -194,8 +194,8 @@
 		set_pte(page_table, __pte(entry));
 		flush_tlb_page(vma, address);
 		swap_duplicate(entry);
-		free_page(page);
-		return (atomic_read(&page_map->count) == 0);
+		__free_page(page_map);
+		return atomic_read(&page_map->count) + 1;
 	} 
 	/* 
 	 * A clean page to be discarded?  Must be mmap()ed from
@@ -210,9 +210,8 @@
 	flush_cache_page(vma, address);
 	pte_clear(page_table);
 	flush_tlb_page(vma, address);
-	entry = (atomic_read(&page_map->count) == 1);
 	__free_page(page_map);
-	return entry;
+	return atomic_read(&page_map->count) + 1;
 }
 
 /*
@@ -369,8 +368,14 @@
 	 * swapped out.  If the swap-out fails, we clear swap_cnt so the 
 	 * task won't be selected again until all others have been tried.
 	 */
-	counter = ((PAGEOUT_WEIGHT * nr_tasks) >> 10) >> priority;
+	counter = nr_tasks / (priority+1);
+	if (counter < 1)
+		counter = 1;
+	if (counter > nr_tasks)
+		counter = nr_tasks;
+
 	for (; counter >= 0; counter--) {
+		int retval;
 		assign = 0;
 		max_cnt = 0;
 		pbest = NULL;
@@ -382,15 +387,8 @@
 				continue;
 	 		if (p->mm->rss <= 0)
 				continue;
-			if (assign) {
-				/* 
-				 * If we didn't select a task on pass 1, 
-				 * assign each task a new swap_cnt.
-				 * Normalise the number of pages swapped
-				 * by multiplying by (RSS / 1MB)
-				 */
-				p->swap_cnt = AGE_CLUSTER_SIZE(p->mm->rss);
-			}
+			if (assign)
+				p->swap_cnt = p->mm->rss;
 			if (p->swap_cnt > max_cnt) {
 				max_cnt = p->swap_cnt;
 				pbest = p;
@@ -404,14 +402,13 @@
 			}
 			goto out;
 		}
-		pbest->swap_cnt--;
-
 		/*
 		 * Nonzero means we cleared out something, but only "1" means
 		 * that we actually free'd up a page as a result.
 		 */
-		if (swap_out_process(pbest, gfp_mask) == 1)
-				return 1;
+		retval = swap_out_process(pbest, gfp_mask);
+		if (retval)
+			return retval;
 	}
 out:
 	return 0;
@@ -438,44 +435,78 @@
        printk ("Starting kswapd v%.*s\n", i, s);
 }
 
-#define free_memory(fn) \
-	count++; do { if (!--count) goto done; } while (fn)
+static int do_free_user_and_cache(int priority, int gfp_mask)
+{
+	switch (swap_out(priority, gfp_mask))
+	{
+	default:
+		shrink_mmap(0, gfp_mask);
+		/*
+		 * We done at least some swapping progress so return 1 in
+		 * this case. -arca
+		 */
+		return 1;
+	case 0:
+		/* swap_out() failed to swapout */
+		if (shrink_mmap(priority, gfp_mask))
+		{
+			printk("swapout 0 shrink 1\n");
+			return 1;
+		}
+		printk("swapout 0 shrink 0\n");
+		return 0;
+	case 1:
+		/* this would be the best but should not happen right now */
+		printk(KERN_DEBUG
+		       "do_free_user_and_cache: swapout returned 1\n");
+		return 1;
+	}
+}
 
-static int kswapd_free_pages(int kswapd_state)
+static int do_free_page(int * state, int gfp_mask)
 {
-	unsigned long end_time;
+	int priority = 6;
+
+	kmem_cache_reap(gfp_mask);
 
-	/* Always trim SLAB caches when memory gets low. */
-	kmem_cache_reap(0);
+	switch (*state) {
+		do {
+		default:
+			if (do_free_user_and_cache(priority, gfp_mask))
+				return 1;
+			*state = 1;
+		case 1:
+			if (shm_swap(priority, gfp_mask))
+				return 1;
+			*state = 2;
+		case 2:
+			shrink_dcache_memory(priority, gfp_mask);
+			*state = 0;
+		} while (--priority >= 0);
+	}
+	return 0;
+}
 
+static int kswapd_free_pages(int kswapd_state)
+{
 	/* max one hundreth of a second */
-	end_time = jiffies + (HZ-1)/100;
-	do {
-		int priority = 5;
-		int count = pager_daemon.swap_cluster;
+	unsigned long end_time = jiffies + (HZ-1)/100;
 
-		switch (kswapd_state) {
-			do {
-			default:
-				free_memory(shrink_mmap(priority, 0));
-				kswapd_state++;
-			case 1:
-				free_memory(shm_swap(priority, 0));
-				kswapd_state++;
-			case 2:
-				free_memory(swap_out(priority, 0));
-				shrink_dcache_memory(priority, 0);
-				kswapd_state = 0;
-			} while (--priority >= 0);
-			return kswapd_state;
-		}
-done:
-		if (nr_free_pages > freepages.high + pager_daemon.swap_cluster)
+	do {
+		do_free_page(&kswapd_state, 0);
+		if (nr_free_pages > freepages.high)
 			break;
 	} while (time_before_eq(jiffies,end_time));
+	/* take kswapd_state on the stack to save some byte of memory */
 	return kswapd_state;
 }
 
+static inline void enable_swap_tick(void)
+{
+	timer_table[SWAP_TIMER].expires = jiffies+(HZ+99)/100;
+	timer_active |= 1<<SWAP_TIMER;
+}
+
 /*
  * The background pageout daemon.
  * Started as a kernel thread from the init process.
@@ -523,6 +554,7 @@
 		current->state = TASK_INTERRUPTIBLE;
 		flush_signals(current);
 		run_task_queue(&tq_disk);
+		enable_swap_tick();
 		schedule();
 		swapstats.wakeups++;
 		state = kswapd_free_pages(state);
@@ -542,35 +574,24 @@
  * if we need more memory as part of a swap-out effort we
  * will just silently return "success" to tell the page
  * allocator to accept the allocation.
- *
- * We want to try to free "count" pages, and we need to 
- * cluster them so that we get good swap-out behaviour. See
- * the "free_memory()" macro for details.
  */
 int try_to_free_pages(unsigned int gfp_mask, int count)
 {
-	int retval;
-
+	int retval = 1;
 	lock_kernel();
 
-	/* Always trim SLAB caches when memory gets low. */
-	kmem_cache_reap(gfp_mask);
-
-	retval = 1;
 	if (!(current->flags & PF_MEMALLOC)) {
-		int priority;
+		static int state = 0;
 
 		current->flags |= PF_MEMALLOC;
 	
-		priority = 5;
-		do {
-			free_memory(shrink_mmap(priority, gfp_mask));
-			free_memory(shm_swap(priority, gfp_mask));
-			free_memory(swap_out(priority, gfp_mask));
-			shrink_dcache_memory(priority, gfp_mask);
-		} while (--priority >= 0);
-		retval = 0;
-done:
+		while (count--)
+			if (!do_free_page(&state, gfp_mask))
+			{
+				retval = 0;
+				break;
+			}
+
 		current->flags &= ~PF_MEMALLOC;
 	}
 	unlock_kernel();
@@ -593,7 +614,8 @@
 	if (priority) {
 		p->counter = p->priority << priority;
 		wake_up_process(p);
-	}
+	} else
+		enable_swap_tick();
 }
 
 /* 
@@ -631,9 +653,8 @@
 			want_wakeup = 3;
 	
 		kswapd_wakeup(p,want_wakeup);
-	}
-
-	timer_active |= (1<<SWAP_TIMER);
+	} else
+		enable_swap_tick();
 }
 
 /* 
Index: linux/kernel/fork.c
diff -u linux/kernel/fork.c:1.1.1.3 linux/kernel/fork.c:1.1.1.1.2.6
--- linux/kernel/fork.c:1.1.1.3	Thu Dec  3 12:55:12 1998
+++ linux/kernel/fork.c	Thu Dec 31 17:56:28 1998
@@ -567,6 +570,7 @@
 
 	/* ok, now we should be set up.. */
 	p->swappable = 1;
+	p->trashing_memory = 0;
 	p->exit_signal = clone_flags & CSIGNAL;
 	p->pdeath_signal = 0;
 
Index: linux/include/linux/sched.h
diff -u linux/include/linux/sched.h:1.1.1.2 linux/include/linux/sched.h:1.1.1.1.2.7
--- linux/include/linux/sched.h:1.1.1.2	Tue Dec 29 01:39:00 1998
+++ linux/include/linux/sched.h	Thu Dec 31 17:56:29 1998
@@ -268,6 +273,7 @@
 /* mm fault and swap info: this can arguably be seen as either mm-specific or thread-specific */
 	unsigned long min_flt, maj_flt, nswap, cmin_flt, cmaj_flt, cnswap;
 	int swappable:1;
+	int trashing_memory:1;
 	unsigned long swap_address;
 	unsigned long old_maj_flt;	/* old value of maj_flt */
 	unsigned long dec_flt;		/* page fault count of the last time */
@@ -353,7 +359,7 @@
 /* utime */	{0,0,0,0},0, \
 /* per CPU times */ {0, }, {0, }, \
 /* flt */	0,0,0,0,0,0, \
-/* swp */	0,0,0,0,0, \
+/* swp */	0,0,0,0,0,0, \
 /* process credentials */					\
 /* uid etc */	0,0,0,0,0,0,0,0,				\
 /* suppl grps*/ 0, {0,},					\





--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
