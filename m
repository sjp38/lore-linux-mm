Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA29594
	for <linux-mm@kvack.org>; Sat, 2 Jan 1999 15:53:53 -0500
Date: Sat, 2 Jan 1999 21:52:17 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
In-Reply-To: <Pine.LNX.3.96.990102162944.176A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990102213351.344A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2 Jan 1999, Andrea Arcangeli wrote:

> I rediffed my latest swapout stuff against your latest tree (I consider
> your latest patch as test1-pre4, right?).

I developed new exiting stuff this afternoon! The most important thing is
the swapout smart weight code. Basing the priority on the number of
process to try to swapout was really ugly and not smart.

The second change is done over shrink_mmap(), this will cause
shrink_mmap() to care very more about aging. We have only one bit and we
must use it carefully to get not out of cache ;) 

I also added/removed some PG_referenced. But please, don't trust too much
the pg_refernced changes since I have not thought about it too much (maybe
they are not needed?). 

I returned to put the minimum of cache and buffer to 5%. This allow me to
run every trashing memory proggy I can for every time but I still have all
my last command run (free) and filesystem (ls -l) in cache (because the
trashing memory _only_ play with its VM and asks nothing to the kernel of
course). 

Ah and woops, in the last patch I do a mistake and I forget to change
max_cnt to unsigned long. This should be changed also in your tree, Linus. 

This new patch seems to really rocks here and seems _far_ better than
anything I tried before! Steve, could try it and feedback? Thanks ;) 

Please excuse me Linus if I have not yet cleanedup things, but my spare
time is very small and I would _try_ to improve things a bit more
before...

This patch is against 2.2.0-pre4 (the lateest patch posted by Linus here).

Index: linux/include/linux/mm.h
diff -u linux/include/linux/mm.h:1.1.1.3 linux/include/linux/mm.h:1.1.1.1.2.11
--- linux/include/linux/mm.h:1.1.1.3	Sat Jan  2 15:24:18 1999
+++ linux/include/linux/mm.h	Sat Jan  2 21:40:13 1999
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
diff -u linux/mm/filemap.c:1.1.1.8 linux/mm/filemap.c:1.1.1.1.2.35
--- linux/mm/filemap.c:1.1.1.8	Fri Jan  1 19:12:53 1999
+++ linux/mm/filemap.c	Sat Jan  2 21:40:13 1999
@@ -118,6 +122,10 @@
 	__free_page(page);
 }
 
+#define HANDLE_AGING(page)					\
+	if (test_and_clear_bit(PG_referenced, &(page)->flags))	\
+		continue;
+
 int shrink_mmap(int priority, int gfp_mask)
 {
 	static unsigned long clock = 0;
@@ -140,12 +148,11 @@
 			page = page->next_hash;
 			clock = page->map_nr;
 		}
-		
-		if (test_and_clear_bit(PG_referenced, &page->flags))
-			continue;
 
 		/* Decrement count only for non-referenced pages */
-		count--;
+		if (!test_bit(PG_referenced, &page->flags))
+			count--;
+
 		if (PageLocked(page))
 			continue;
 
@@ -160,6 +167,7 @@
 		if (page->buffers) {
 			if (buffer_under_min())
 				continue;
+			HANDLE_AGING(page);
 			if (!try_to_free_buffers(page))
 				continue;
 			return 1;
@@ -167,12 +175,14 @@
 
 		/* is it a swap-cache or page-cache page? */
 		if (page->inode) {
-			if (pgcache_under_min())
-				continue;
 			if (PageSwapCache(page)) {
+				HANDLE_AGING(page);
 				delete_from_swap_cache(page);
 				return 1;
 			}
+			if (pgcache_under_min())
+				continue;
+			HANDLE_AGING(page);
 			remove_inode_page(page);
 			return 1;
 		}
@@ -181,6 +191,8 @@
 	return 0;
 }
 
+#undef HANDLE_AGING
+
 /*
  * Update a page cache copy, when we're doing a "write()" system call
  * See also "update_vm_cache()".
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
diff -u linux/mm/vmscan.c:1.1.1.9 linux/mm/vmscan.c:1.1.1.1.2.57
--- linux/mm/vmscan.c:1.1.1.9	Sat Jan  2 15:46:20 1999
+++ linux/mm/vmscan.c	Sat Jan  2 21:45:22 1999
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
@@ -162,8 +168,9 @@
 			 * copy in memory, so we add it to the swap
 			 * cache. */
 			if (PageSwapCache(page_map)) {
+				entry = atomic_read(&page_map->count);
 				__free_page(page_map);
-				return (atomic_read(&page_map->count) == 0);
+				return entry;
 			}
 			add_to_swap_cache(page_map, entry);
 			/* We checked we were unlocked way up above, and we
@@ -180,8 +187,9 @@
 		 * asynchronously.  That's no problem, shrink_mmap() can
 		 * correctly clean up the occassional unshared page
 		 * which gets left behind in the swap cache. */
+		entry = atomic_read(&page_map->count);
 		__free_page(page_map);
-		return 1;	/* we slept: the process may not exist any more */
+		return entry;	/* we slept: the process may not exist any more */
 	}
 
 	/* The page was _not_ dirty, but still has a zero age.  It must
@@ -194,8 +202,9 @@
 		set_pte(page_table, __pte(entry));
 		flush_tlb_page(vma, address);
 		swap_duplicate(entry);
+		entry = atomic_read(&page_map->count);
 		__free_page(page_map);
-		return (atomic_read(&page_map->count) == 0);
+		return entry;
 	} 
 	/* 
 	 * A clean page to be discarded?  Must be mmap()ed from
@@ -210,7 +219,7 @@
 	flush_cache_page(vma, address);
 	pte_clear(page_table);
 	flush_tlb_page(vma, address);
-	entry = (atomic_read(&page_map->count) == 1);
+	entry = atomic_read(&page_map->count);
 	__free_page(page_map);
 	return entry;
 }
@@ -230,7 +239,7 @@
  */
 
 static inline int swap_out_pmd(struct task_struct * tsk, struct vm_area_struct * vma,
-	pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+	pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask, unsigned long * counter, unsigned long * next_addr)
 {
 	pte_t * pte;
 	unsigned long pmd_end;
@@ -256,13 +265,19 @@
 		if (result)
 			return result;
 		address += PAGE_SIZE;
+		if (!*counter)
+		{
+			*next_addr = address;
+			return 0;
+		} else
+			(*counter)--;
 		pte++;
 	} while (address < end);
 	return 0;
 }
 
 static inline int swap_out_pgd(struct task_struct * tsk, struct vm_area_struct * vma,
-	pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+	pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask, unsigned long * counter, unsigned long * next_addr)
 {
 	pmd_t * pmd;
 	unsigned long pgd_end;
@@ -282,9 +297,11 @@
 		end = pgd_end;
 	
 	do {
-		int result = swap_out_pmd(tsk, vma, pmd, address, end, gfp_mask);
+		int result = swap_out_pmd(tsk, vma, pmd, address, end, gfp_mask, counter, next_addr);
 		if (result)
 			return result;
+		if (!*counter)
+			return 0;
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address < end);
@@ -292,7 +309,7 @@
 }
 
 static int swap_out_vma(struct task_struct * tsk, struct vm_area_struct * vma,
-	unsigned long address, int gfp_mask)
+	unsigned long address, int gfp_mask, unsigned long * counter, unsigned long * next_addr)
 {
 	pgd_t *pgdir;
 	unsigned long end;
@@ -306,16 +323,19 @@
 
 	end = vma->vm_end;
 	while (address < end) {
-		int result = swap_out_pgd(tsk, vma, pgdir, address, end, gfp_mask);
+		int result = swap_out_pgd(tsk, vma, pgdir, address, end, gfp_mask, counter, next_addr);
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
@@ -334,9 +354,16 @@
 			address = vma->vm_start;
 
 		for (;;) {
-			int result = swap_out_vma(p, vma, address, gfp_mask);
+			unsigned long next_addr;
+			int result = swap_out_vma(p, vma, address, gfp_mask,
+						  counter, &next_addr);
 			if (result)
 				return result;
+			if (!*counter)
+			{
+				p->swap_address = next_addr;
+				return 0;
+			}
 			vma = vma->vm_next;
 			if (!vma)
 				break;
@@ -350,6 +377,19 @@
 	return 0;
 }
 
+static unsigned long total_rss(void)
+{
+	unsigned long total_rss = 0;
+	struct task_struct * p;
+
+	read_lock(&tasklist_lock);
+	for (p = init_task.next_task; p != &init_task; p = p->next_task)
+		total_rss += p->mm->rss;
+	read_unlock(&tasklist_lock);
+
+	return total_rss;
+}
+
 /*
  * Select the task with maximal swap_cnt and try to swap out a page.
  * N.B. This function returns only 0 or 1.  Return values != 1 from
@@ -358,7 +398,10 @@
 static int swap_out(unsigned int priority, int gfp_mask)
 {
 	struct task_struct * p, * pbest;
-	int counter, assign, max_cnt;
+	int assign;
+	unsigned long max_cnt, counter;
+
+	counter = total_rss() >> priority;
 
 	/* 
 	 * We make one or two passes through the task list, indexed by 
@@ -374,13 +417,8 @@
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
+		int retval;
 		assign = 0;
 		max_cnt = 0;
 		pbest = NULL;
@@ -413,8 +451,9 @@
 		 * Nonzero means we cleared out something, but only "1" means
 		 * that we actually free'd up a page as a result.
 		 */
-		if (swap_out_process(pbest, gfp_mask) == 1)
-			return 1;
+		retval = swap_out_process(pbest, gfp_mask, &counter);
+		if (retval)
+			return retval;
 	}
 out:
 	return 0;
@@ -441,42 +480,63 @@
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
 
+			shrink_dcache_memory(priority, gfp_mask);
+			kmem_cache_reap(gfp_mask);
+		} while (--priority >= 0);
+	}
+	return 0;
+}
+
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
@@ -524,6 +584,7 @@
 		current->state = TASK_INTERRUPTIBLE;
 		flush_signals(current);
 		run_task_queue(&tq_disk);
+		enable_swap_tick();
 		schedule();
 		swapstats.wakeups++;
 		state = kswapd_free_pages(state);
@@ -543,35 +604,23 @@
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
@@ -594,7 +643,8 @@
 	if (priority) {
 		p->counter = p->priority << priority;
 		wake_up_process(p);
-	}
+	} else
+		enable_swap_tick();
 }
 
 /* 
@@ -632,9 +682,8 @@
 			want_wakeup = 3;
 	
 		kswapd_wakeup(p,want_wakeup);
-	}
-
-	timer_active |= (1<<SWAP_TIMER);
+	} else
+		enable_swap_tick();
 }
 
 /* 
@@ -643,7 +692,6 @@
 
 void init_swap_timer(void)
 {
-	timer_table[SWAP_TIMER].expires = jiffies;
 	timer_table[SWAP_TIMER].fn = swap_tick;
-	timer_active |= (1<<SWAP_TIMER);
+	enable_swap_tick();
 }
Index: linux/fs/buffer.c
diff -u linux/fs/buffer.c:1.1.1.5 linux/fs/buffer.c:1.1.1.1.2.6
--- linux/fs/buffer.c:1.1.1.5	Fri Jan  1 19:10:20 1999
+++ linux/fs/buffer.c	Sat Jan  2 21:40:07 1999
@@ -1263,6 +1263,7 @@
 		panic("brw_page: page not locked for I/O");
 	clear_bit(PG_uptodate, &page->flags);
 	clear_bit(PG_error, &page->flags);
+	set_bit(PG_referenced, &page->flags);
 	/*
 	 * Allocate async buffer heads pointing to this page, just for I/O.
 	 * They do _not_ show up in the buffer hash table!


Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
