Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA31245
	for <linux-mm@kvack.org>; Sat, 2 Jan 1999 22:01:15 -0500
Date: Sun, 3 Jan 1999 03:59:51 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
In-Reply-To: <Pine.LNX.3.96.990102213351.344A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990103034429.312B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2 Jan 1999, Andrea Arcangeli wrote:

> is the swapout smart weight code. Basing the priority on the number of
> process to try to swapout was really ugly and not smart. 

But I done two mistakes in it. Benjamin pointed out after one msec that
there was no need for putting the address on the stack, and looking a
_bit_ more at swap_out_pmd() I noticed that the old code was just updating
swap_address, woops ;).

I noticed the second very more important mistakes running at 8Mbyte
because the trashing memory proggy was segfaulting. The bug was to base
the maximal weight of swap_out() on the total_rss and not on the sum of
the total_vm of all processes. With 8Mbyte all my processes got swapped
out and so swap_out stopped working ;). It's fixed now...

> The second change is done over shrink_mmap(), this will cause
> shrink_mmap() to care very more about aging. We have only one bit and we
> must use it carefully to get not out of cache ;) 

This change is pretty buggy too. The only good thing was to not care
about the pgcache min limits before to shrink the _swap_cache_. Now I also
changed pgcache_under_min to don't care about the swapcache size (now the
swap cache is a bit more fast-variable/crazy).

> I also added/removed some PG_referenced. But please, don't trust too much
> the pg_refernced changes since I have not thought about it too much (maybe
> they are not needed?). 

Hmm I guess at least the brw_page set_bit was not needed because before to
run such function is been run or a __find_page() or an add_to_...cache().

> Ah and woops, in the last patch I do a mistake and I forget to change
> max_cnt to unsigned long. This should be changed also in your tree, Linus. 

Also some count should be moved from int to unsigned long to handle huge
RAM sizes.

> This new patch seems to really rocks here and seems _far_ better than
> anything I tried before! Steve, could try it and feedback? Thanks ;) 

Here Steve's feedback:

                      128MB       8MB
                      -------     -------
Your previous patch:  132 sec     218 sec
This patch         :  118 sec     226 sec       

Even if `This patch' was pretty buggy (as pointed out above) it was going
sligtly _faster_. I guess the reason for the 8Mbyte slowdown was the
s/rss/total_vm/ thing (but I am not 100% sure). 

I fixed the bugs and so I repost the fixed diff against pre4. I also
cleaned up a bit some thing...

Index: linux/include/linux/mm.h
diff -u linux/include/linux/mm.h:1.1.1.3 linux/include/linux/mm.h:1.1.1.1.2.12
--- linux/include/linux/mm.h:1.1.1.3	Sat Jan  2 15:24:18 1999
+++ linux/include/linux/mm.h	Sun Jan  3 03:43:52 1999
@@ -118,7 +118,6 @@
 	unsigned long offset;
 	struct page *next_hash;
 	atomic_t count;
-	unsigned int unused;
 	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
 	struct wait_queue *wait;
 	struct page **pprev_hash;
@@ -295,8 +294,7 @@
 
 /* filemap.c */
 extern void remove_inode_page(struct page *);
-extern unsigned long page_unuse(struct page *);
-extern int shrink_mmap(int, int);
+extern int FASTCALL(shrink_mmap(int, int));
 extern void truncate_inode_pages(struct inode *, unsigned long);
 extern unsigned long get_cached_page(struct inode *, unsigned long, int);
 extern void put_cached_page(unsigned long);
@@ -379,8 +377,8 @@
 
 #define buffer_under_min()	((buffermem >> PAGE_SHIFT) * 100 < \
 				buffer_mem.min_percent * num_physpages)
-#define pgcache_under_min()	(page_cache_size * 100 < \
-				page_cache.min_percent * num_physpages)
+#define pgcache_under_min()	((page_cache_size-swapper_inode.i_nrpages)*100\
+				< page_cache.min_percent * num_physpages)
 
 #endif /* __KERNEL__ */
 
Index: linux/include/linux/pagemap.h
diff -u linux/include/linux/pagemap.h:1.1.1.1 linux/include/linux/pagemap.h:1.1.1.1.2.1
--- linux/include/linux/pagemap.h:1.1.1.1	Fri Nov 20 00:01:16 1998
+++ linux/include/linux/pagemap.h	Sat Jan  2 21:40:13 1999
@@ -77,6 +77,7 @@
 		*page->pprev_hash = page->next_hash;
 		page->pprev_hash = NULL;
 	}
+	clear_bit(PG_referenced, &page->flags);
 	page_cache_size--;
 }
 
Index: linux/mm/filemap.c
diff -u linux/mm/filemap.c:1.1.1.8 linux/mm/filemap.c:1.1.1.1.2.36
--- linux/mm/filemap.c:1.1.1.8	Fri Jan  1 19:12:53 1999
+++ linux/mm/filemap.c	Sun Jan  3 03:13:09 1999
@@ -122,13 +126,14 @@
 {
 	static unsigned long clock = 0;
 	unsigned long limit = num_physpages;
+	unsigned long count;
 	struct page * page;
-	int count;
 
 	count = limit >> priority;
 
 	page = mem_map + clock;
-	do {
+	while (count != 0)
+	{
 		page++;
 		clock++;
 		if (clock >= max_mapnr) {
@@ -167,17 +172,17 @@
 
 		/* is it a swap-cache or page-cache page? */
 		if (page->inode) {
-			if (pgcache_under_min())
-				continue;
 			if (PageSwapCache(page)) {
 				delete_from_swap_cache(page);
 				return 1;
 			}
+			if (pgcache_under_min())
+				continue;
 			remove_inode_page(page);
 			return 1;
 		}
 
-	} while (count > 0);
+	}
 	return 0;
 }
 
Index: linux/mm/swap.c
diff -u linux/mm/swap.c:1.1.1.5 linux/mm/swap.c:1.1.1.1.2.8
--- linux/mm/swap.c:1.1.1.5	Sat Jan  2 15:24:40 1999
+++ linux/mm/swap.c	Sat Jan  2 21:40:13 1999
@@ -64,13 +64,13 @@
 swapstat_t swapstats = {0};
 
 buffer_mem_t buffer_mem = {
-	2,	/* minimum percent buffer */
+	5,	/* minimum percent buffer */
 	10,	/* borrow percent buffer */
 	60	/* maximum percent buffer */
 };
 
 buffer_mem_t page_cache = {
-	2,	/* minimum percent page cache */
+	5,	/* minimum percent page cache */
 	15,	/* borrow percent page cache */
 	75	/* maximum */
 };
Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.9 linux/mm/vmscan.c:1.1.1.1.2.59
--- linux/mm/vmscan.c:1.1.1.9	Sat Jan  2 15:46:20 1999
+++ linux/mm/vmscan.c	Sun Jan  3 03:43:54 1999
@@ -10,6 +10,12 @@
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
  */
 
+/*
+ * Revisioned the page freeing algorithm (do_free_user_and_cache), and
+ * developed a smart mechanism to handle the swapout weight.
+ * Copyright (C) 1998  Andrea Arcangeli
+ */
+
 #include <linux/slab.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
@@ -163,7 +169,7 @@
 			 * cache. */
 			if (PageSwapCache(page_map)) {
 				__free_page(page_map);
-				return (atomic_read(&page_map->count) == 0);
+				return 1;
 			}
 			add_to_swap_cache(page_map, entry);
 			/* We checked we were unlocked way up above, and we
@@ -195,7 +201,7 @@
 		flush_tlb_page(vma, address);
 		swap_duplicate(entry);
 		__free_page(page_map);
-		return (atomic_read(&page_map->count) == 0);
+		return 1;
 	} 
 	/* 
 	 * A clean page to be discarded?  Must be mmap()ed from
@@ -210,9 +216,8 @@
 	flush_cache_page(vma, address);
 	pte_clear(page_table);
 	flush_tlb_page(vma, address);
-	entry = (atomic_read(&page_map->count) == 1);
 	__free_page(page_map);
-	return entry;
+	return 1;
 }
 
 /*
@@ -230,7 +235,7 @@
  */
 
 static inline int swap_out_pmd(struct task_struct * tsk, struct vm_area_struct * vma,
-	pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+	pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask, unsigned long * counter)
 {
 	pte_t * pte;
 	unsigned long pmd_end;
@@ -251,18 +256,20 @@
 
 	do {
 		int result;
-		tsk->swap_address = address + PAGE_SIZE;
 		result = try_to_swap_out(tsk, vma, address, pte, gfp_mask);
+		address += PAGE_SIZE;
+		tsk->swap_address = address;
 		if (result)
 			return result;
-		address += PAGE_SIZE;
+		if (!--*counter)
+			return 0;
 		pte++;
 	} while (address < end);
 	return 0;
 }
 
 static inline int swap_out_pgd(struct task_struct * tsk, struct vm_area_struct * vma,
-	pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+	pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask, unsigned long * counter)
 {
 	pmd_t * pmd;
 	unsigned long pgd_end;
@@ -282,9 +289,11 @@
 		end = pgd_end;
 	
 	do {
-		int result = swap_out_pmd(tsk, vma, pmd, address, end, gfp_mask);
+		int result = swap_out_pmd(tsk, vma, pmd, address, end, gfp_mask, counter);
 		if (result)
 			return result;
+		if (!*counter)
+			return 0;
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address < end);
@@ -292,7 +301,7 @@
 }
 
 static int swap_out_vma(struct task_struct * tsk, struct vm_area_struct * vma,
-	unsigned long address, int gfp_mask)
+	unsigned long address, int gfp_mask, unsigned long * counter)
 {
 	pgd_t *pgdir;
 	unsigned long end;
@@ -306,16 +315,19 @@
 
 	end = vma->vm_end;
 	while (address < end) {
-		int result = swap_out_pgd(tsk, vma, pgdir, address, end, gfp_mask);
+		int result = swap_out_pgd(tsk, vma, pgdir, address, end, gfp_mask, counter);
 		if (result)
 			return result;
+		if (!*counter)
+			return 0;
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		pgdir++;
 	}
 	return 0;
 }
 
-static int swap_out_process(struct task_struct * p, int gfp_mask)
+static int swap_out_process(struct task_struct * p, int gfp_mask,
+			    unsigned long * counter)
 {
 	unsigned long address;
 	struct vm_area_struct* vma;
@@ -334,9 +346,12 @@
 			address = vma->vm_start;
 
 		for (;;) {
-			int result = swap_out_vma(p, vma, address, gfp_mask);
+			int result = swap_out_vma(p, vma, address, gfp_mask,
+						  counter);
 			if (result)
 				return result;
+			if (!*counter)
+				return 0;
 			vma = vma->vm_next;
 			if (!vma)
 				break;
@@ -350,6 +365,19 @@
 	return 0;
 }
 
+static unsigned long get_total_vm(void)
+{
+	unsigned long total_vm = 0;
+	struct task_struct * p;
+
+	read_lock(&tasklist_lock);
+	for_each_task(p)
+		total_vm += p->mm->total_vm;
+	read_unlock(&tasklist_lock);
+
+	return total_vm;
+}
+
 /*
  * Select the task with maximal swap_cnt and try to swap out a page.
  * N.B. This function returns only 0 or 1.  Return values != 1 from
@@ -358,8 +386,11 @@
 static int swap_out(unsigned int priority, int gfp_mask)
 {
 	struct task_struct * p, * pbest;
-	int counter, assign, max_cnt;
+	int assign;
+	unsigned long counter, max_cnt;
 
+	counter = get_total_vm() >> priority;
+
 	/* 
 	 * We make one or two passes through the task list, indexed by 
 	 * assign = {0, 1}:
@@ -374,20 +405,14 @@
 	 * Think of swap_cnt as a "shadow rss" - it tells us which process
 	 * we want to page out (always try largest first).
 	 */
-	counter = nr_tasks / (priority+1);
-	if (counter < 1)
-		counter = 1;
-	if (counter > nr_tasks)
-		counter = nr_tasks;
-
-	for (; counter >= 0; counter--) {
+	while (counter > 0) {
 		assign = 0;
 		max_cnt = 0;
 		pbest = NULL;
 	select:
 		read_lock(&tasklist_lock);
-		p = init_task.next_task;
-		for (; p != &init_task; p = p->next_task) {
+		for_each_task(p)
+		{
 			if (!p->swappable)
 				continue;
 	 		if (p->mm->rss <= 0)
@@ -410,10 +435,11 @@
 		}
 
 		/*
-		 * Nonzero means we cleared out something, but only "1" means
-		 * that we actually free'd up a page as a result.
+		 * Nonzero means we cleared out something, and "1" means
+		 * that we actually moved a page from the process memory
+		 * to the swap cache (it's not been freed yet).
 		 */
-		if (swap_out_process(pbest, gfp_mask) == 1)
+		if (swap_out_process(pbest, gfp_mask, &counter))
 			return 1;
 	}
 out:
@@ -441,42 +467,63 @@
        printk ("Starting kswapd v%.*s\n", i, s);
 }
 
-#define free_memory(fn) \
-	count++; do { if (!--count) goto done; } while (fn)
+static int do_free_user_and_cache(int priority, int gfp_mask)
+{
+	if (shrink_mmap(priority, gfp_mask))
+		return 1;
 
-static int kswapd_free_pages(int kswapd_state)
+	if (swap_out(priority, gfp_mask))
+		/*
+		 * We done at least some swapping progress so return 1 in
+		 * this case. -arca
+		 */
+		return 1;
+
+	return 0;
+}
+
+static int do_free_page(int * state, int gfp_mask)
 {
-	unsigned long end_time;
+	int priority = 8;
 
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
+			*state = 0;
+
+			shrink_dcache_memory(priority, gfp_mask);
+			kmem_cache_reap(gfp_mask);
+		} while (--priority >= 0);
+	}
+	return 0;
+}
 
+static int kswapd_free_pages(int kswapd_state)
+{
 	/* max one hundreth of a second */
-	end_time = jiffies + (HZ-1)/100;
-	do {
-		int priority = 8;
-		int count = pager_daemon.swap_cluster;
+	unsigned long end_time = jiffies + (HZ-1)/100;
 
-		switch (kswapd_state) {
-			do {
-			default:
-				free_memory(shrink_mmap(priority, 0));
-				free_memory(swap_out(priority, 0));
-				kswapd_state++;
-			case 1:
-				free_memory(shm_swap(priority, 0));
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
@@ -524,6 +571,7 @@
 		current->state = TASK_INTERRUPTIBLE;
 		flush_signals(current);
 		run_task_queue(&tq_disk);
+		enable_swap_tick();
 		schedule();
 		swapstats.wakeups++;
 		state = kswapd_free_pages(state);
@@ -543,35 +591,23 @@
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
-
 		current->flags |= PF_MEMALLOC;
-	
-		priority = 8;
-		do {
-			free_memory(shrink_mmap(priority, gfp_mask));
-			free_memory(shm_swap(priority, gfp_mask));
-			free_memory(swap_out(priority, gfp_mask));
-			shrink_dcache_memory(priority, gfp_mask);
-		} while (--priority >= 0);
-		retval = 0;
-done:
+		while (count--)
+		{
+			static int state = 0;
+			if (!do_free_page(&state, gfp_mask))
+			{
+				retval = 0;
+				break;
+			}
+		}
 		current->flags &= ~PF_MEMALLOC;
 	}
 	unlock_kernel();
@@ -594,7 +630,8 @@
 	if (priority) {
 		p->counter = p->priority << priority;
 		wake_up_process(p);
-	}
+	} else
+		enable_swap_tick();
 }
 
 /* 
@@ -632,9 +669,8 @@
 			want_wakeup = 3;
 	
 		kswapd_wakeup(p,want_wakeup);
-	}
-
-	timer_active |= (1<<SWAP_TIMER);
+	} else
+		enable_swap_tick();
 }
 
 /* 
@@ -643,7 +679,6 @@
 
 void init_swap_timer(void)
 {
-	timer_table[SWAP_TIMER].expires = jiffies;
 	timer_table[SWAP_TIMER].fn = swap_tick;
-	timer_active |= (1<<SWAP_TIMER);
+	enable_swap_tick();
 }



As usual if you Steve or other will try this I am interested about numbers
;). Thanks.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
