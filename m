Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA07994
	for <linux-mm@kvack.org>; Mon, 4 Jan 1999 13:11:18 -0500
Date: Mon, 4 Jan 1999 19:08:00 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
In-Reply-To: <Pine.LNX.3.96.990103034429.312B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990104183954.1944B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have a new revolutionary patch. The main thing is that I killed kswapd
just to make Rik happy ;).

Ah and my last patches had a little bug that was sure hurting performances
against Linus's VM since I was stopping kswapd when nr_free_pages >
freepages.high was true and not as right Linus was doing when
nr_free_pages > freepages.high + swap_cluster. So I was causing a lot of
kswapd wakeup.

There was also a not improved thing in the trashing_memory heuristic, that
is to remove the trashing bit only if PF_MEMALLOC is not set.

Ah and the swapout code seems to like a linear and not exponential
priority handling. Probably it likes more to succeed than shrink_mmap().

If you'll try it let me know. I am interested about the image load test
(that should be the most near to the real world). 

With this patch the swapout performances are doubled. The swapout
benchmark that was used to take 100 sec with my old code and with Linus's
VM, now run in 50sec! Now I go to 6Mbyte at sec (3so and 3si) instead of
3Mbyte sec (1.5so, 1.5si). 6mbyte/sec is the performance reported by
hdparm -t btw ;). And all the system is perfectly fluid (far more fuild
than with the old code). I open an xterm without wait seconds. The cache
get not kiked out. It seems really great here. When the system goes OOM it
seems to recover fine.

Here arca-vm-6 against 2.2.0-pre4:

Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.9 linux/mm/vmscan.c:1.1.1.1.2.62
--- linux/mm/vmscan.c:1.1.1.9	Sat Jan  2 15:46:20 1999
+++ linux/mm/vmscan.c	Mon Jan  4 18:42:54 1999
@@ -10,6 +10,12 @@
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
  */
 
+/*
+ * Revisioned the page freeing algorithm (do_free_user_and_cache), and
+ * developed a smart mechanism to handle the swapout weight. Removed kswapd.
+ * Copyright (C) 1998  Andrea Arcangeli
+ */
+
 #include <linux/slab.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
@@ -20,13 +26,6 @@
 
 #include <asm/pgtable.h>
 
-/* 
- * The wait queue for waking up the pageout daemon:
- */
-static struct task_struct * kswapd_task = NULL;
-
-static void init_swap_timer(void);
-
 /*
  * The swap-out functions return 1 if they successfully
  * threw something out, and we got a free page. It returns
@@ -163,7 +162,7 @@
 			 * cache. */
 			if (PageSwapCache(page_map)) {
 				__free_page(page_map);
-				return (atomic_read(&page_map->count) == 0);
+				return 1;
 			}
 			add_to_swap_cache(page_map, entry);
 			/* We checked we were unlocked way up above, and we
@@ -195,7 +194,7 @@
 		flush_tlb_page(vma, address);
 		swap_duplicate(entry);
 		__free_page(page_map);
-		return (atomic_read(&page_map->count) == 0);
+		return 1;
 	} 
 	/* 
 	 * A clean page to be discarded?  Must be mmap()ed from
@@ -210,9 +209,8 @@
 	flush_cache_page(vma, address);
 	pte_clear(page_table);
 	flush_tlb_page(vma, address);
-	entry = (atomic_read(&page_map->count) == 1);
 	__free_page(page_map);
-	return entry;
+	return 1;
 }
 
 /*
@@ -230,7 +228,7 @@
  */
 
 static inline int swap_out_pmd(struct task_struct * tsk, struct vm_area_struct * vma,
-	pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+	pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask, unsigned long * counter)
 {
 	pte_t * pte;
 	unsigned long pmd_end;
@@ -251,18 +249,20 @@
 
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
@@ -282,9 +282,11 @@
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
@@ -292,7 +294,7 @@
 }
 
 static int swap_out_vma(struct task_struct * tsk, struct vm_area_struct * vma,
-	unsigned long address, int gfp_mask)
+	unsigned long address, int gfp_mask, unsigned long * counter)
 {
 	pgd_t *pgdir;
 	unsigned long end;
@@ -306,16 +308,19 @@
 
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
@@ -334,9 +339,12 @@
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
@@ -350,6 +358,25 @@
 	return 0;
 }
 
+static inline unsigned long calc_swapout_weight(int priority)
+{
+	struct task_struct * p;
+	unsigned long total_vm = 0;
+
+	read_lock(&tasklist_lock);
+	for_each_task(p)
+	{
+		if (!p->swappable)
+			continue;
+		if (p->mm->rss == 0)
+			continue;
+		total_vm += p->mm->total_vm;
+	}
+	read_unlock(&tasklist_lock);
+
+	return total_vm / (priority+1);
+}
+
 /*
  * Select the task with maximal swap_cnt and try to swap out a page.
  * N.B. This function returns only 0 or 1.  Return values != 1 from
@@ -358,8 +385,11 @@
 static int swap_out(unsigned int priority, int gfp_mask)
 {
 	struct task_struct * p, * pbest;
-	int counter, assign, max_cnt;
+	int assign;
+	unsigned long counter, max_cnt;
 
+	counter = calc_swapout_weight(priority);
+
 	/* 
 	 * We make one or two passes through the task list, indexed by 
 	 * assign = {0, 1}:
@@ -374,23 +404,17 @@
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
+	while (counter != 0) {
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
-	 		if (p->mm->rss <= 0)
+	 		if (p->mm->rss == 0)
 				continue;
 			/* Refresh swap_cnt? */
 			if (assign)
@@ -410,127 +434,51 @@
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
 	return 0;
 }
 
-/*
- * Before we start the kernel thread, print out the 
- * kswapd initialization message (otherwise the init message 
- * may be printed in the middle of another driver's init 
- * message).  It looks very bad when that happens.
- */
-void __init kswapd_setup(void)
+static int do_free_user_and_cache(int priority, int gfp_mask)
 {
-       int i;
-       char *revision="$Revision: 1.5 $", *s, *e;
+	if (shrink_mmap(priority, gfp_mask))
+		return 1;
 
-       swap_setup();
-       
-       if ((s = strchr(revision, ':')) &&
-           (e = strchr(s, '$')))
-               s++, i = e - s;
-       else
-               s = revision, i = -1;
-       printk ("Starting kswapd v%.*s\n", i, s);
-}
-
-#define free_memory(fn) \
-	count++; do { if (!--count) goto done; } while (fn)
-
-static int kswapd_free_pages(int kswapd_state)
-{
-	unsigned long end_time;
-
-	/* Always trim SLAB caches when memory gets low. */
-	kmem_cache_reap(0);
-
-	/* max one hundreth of a second */
-	end_time = jiffies + (HZ-1)/100;
-	do {
-		int priority = 8;
-		int count = pager_daemon.swap_cluster;
+	if (swap_out(priority, gfp_mask & ~__GFP_WAIT))
+		/*
+		 * We done at least some swapping progress so return 1 in
+		 * this case. -arca
+		 */
+		return 1;
 
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
-			break;
-	} while (time_before_eq(jiffies,end_time));
-	return kswapd_state;
+	return 0;
 }
 
-/*
- * The background pageout daemon.
- * Started as a kernel thread from the init process.
- */
-int kswapd(void *unused)
+static int do_free_page(int * state, int gfp_mask)
 {
-	current->session = 1;
-	current->pgrp = 1;
-	strcpy(current->comm, "kswapd");
-	sigfillset(&current->blocked);
-	
-	/*
-	 *	As a kernel thread we want to tamper with system buffers
-	 *	and other internals and thus be subject to the SMP locking
-	 *	rules. (On a uniprocessor box this does nothing).
-	 */
-	lock_kernel();
+	int priority = 6;
 
-	/*
-	 * Set the base priority to something smaller than a
-	 * regular process. We will scale up the priority
-	 * dynamically depending on how much memory we need.
-	 */
-	current->priority = (DEF_PRIORITY * 2) / 3;
-
-	/*
-	 * Tell the memory management that we're a "memory allocator",
-	 * and that if we need more memory we should get access to it
-	 * regardless (see "try_to_free_pages()"). "kswapd" should
-	 * never get caught in the normal page freeing logic.
-	 *
-	 * (Kswapd normally doesn't need memory anyway, but sometimes
-	 * you need a small amount of memory in order to be able to
-	 * page out something else, and this flag essentially protects
-	 * us from recursively trying to free more memory as we're
-	 * trying to free the first piece of memory in the first place).
-	 */
-	current->flags |= PF_MEMALLOC;
+	switch (*state) {
+		do {
+		case 0:
+			if (do_free_user_and_cache(priority, gfp_mask))
+				return 1;
+			*state = 1;
+		case 1:
+			if (shm_swap(priority, gfp_mask))
+				return 1;
+			*state = 0;
 
-	init_swap_timer();
-	kswapd_task = current;
-	while (1) {
-		int state = 0;
-
-		current->state = TASK_INTERRUPTIBLE;
-		flush_signals(current);
-		run_task_queue(&tq_disk);
-		schedule();
-		swapstats.wakeups++;
-		state = kswapd_free_pages(state);
+			shrink_dcache_memory(priority, gfp_mask);
+			kmem_cache_reap(gfp_mask);
+		} while (--priority >= 0);
 	}
-	/* As if we could ever get here - maybe we want to make this killable */
-	kswapd_task = NULL;
-	unlock_kernel();
 	return 0;
 }
 
@@ -543,107 +491,26 @@
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
 
 	return retval;
-}
-
-/*
- * Wake up kswapd according to the priority
- *	0 - no wakeup
- *	1 - wake up as a low-priority process
- *	2 - wake up as a normal process
- *	3 - wake up as an almost real-time process
- *
- * This plays mind-games with the "goodness()"
- * function in kernel/sched.c.
- */
-static inline void kswapd_wakeup(struct task_struct *p, int priority)
-{
-	if (priority) {
-		p->counter = p->priority << priority;
-		wake_up_process(p);
-	}
-}
-
-/* 
- * The swap_tick function gets called on every clock tick.
- */
-void swap_tick(void)
-{
-	struct task_struct *p = kswapd_task;
-
-	/*
-	 * Only bother to try to wake kswapd up
-	 * if the task exists and can be woken.
-	 */
-	if (p && (p->state & TASK_INTERRUPTIBLE)) {
-		unsigned int pages;
-		int want_wakeup;
-
-		/*
-		 * Schedule for wakeup if there isn't lots
-		 * of free memory or if there is too much
-		 * of it used for buffers or pgcache.
-		 *
-		 * "want_wakeup" is our priority: 0 means
-		 * not to wake anything up, while 3 means
-		 * that we'd better give kswapd a realtime
-		 * priority.
-		 */
-		want_wakeup = 0;
-		pages = nr_free_pages;
-		if (pages < freepages.high)
-			want_wakeup = 1;
-		if (pages < freepages.low)
-			want_wakeup = 2;
-		if (pages < freepages.min)
-			want_wakeup = 3;
-	
-		kswapd_wakeup(p,want_wakeup);
-	}
-
-	timer_active |= (1<<SWAP_TIMER);
-}
-
-/* 
- * Initialise the swap timer
- */
-
-void init_swap_timer(void)
-{
-	timer_table[SWAP_TIMER].expires = jiffies;
-	timer_table[SWAP_TIMER].fn = swap_tick;
-	timer_active |= (1<<SWAP_TIMER);
 }
Index: linux/mm/page_alloc.c
diff -u linux/mm/page_alloc.c:1.1.1.5 linux/mm/page_alloc.c:1.1.1.1.2.14
--- linux/mm/page_alloc.c:1.1.1.5	Sun Jan  3 20:42:44 1999
+++ linux/mm/page_alloc.c	Mon Jan  4 18:42:54 1999
@@ -260,7 +260,8 @@
 		if (nr_free_pages > freepages.min) {
 			if (!current->trashing_memory)
 				goto ok_to_allocate;
-			if (nr_free_pages > freepages.low) {
+			if (!(current->flags & PF_MEMALLOC) &&
+			    nr_free_pages > freepages.low) {
 				current->trashing_memory = 0;
 				goto ok_to_allocate;
 			}
@@ -271,7 +272,7 @@
 		 * memory.
 		 */
 		current->trashing_memory = 1;
-		if (!try_to_free_pages(gfp_mask, SWAP_CLUSTER_MAX) && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
+		if (!try_to_free_pages(gfp_mask, freepages.high - nr_free_pages + 1<<order) && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
 			goto nopage;
 	}
 ok_to_allocate:
Index: linux/init/main.c
diff -u linux/init/main.c:1.1.1.5 linux/init/main.c:1.1.1.1.2.9
--- linux/init/main.c:1.1.1.5	Tue Dec 29 01:39:16 1998
+++ linux/init/main.c	Mon Jan  4 18:42:54 1999
@@ -63,8 +63,6 @@
 
 static int init(void *);
 extern int bdflush(void *);
-extern int kswapd(void *);
-extern void kswapd_setup(void);
 
 extern void init_IRQ(void);
 extern void init_modules(void);
@@ -1269,9 +1267,6 @@
 
 	/* Launch bdflush from here, instead of the old syscall way. */
 	kernel_thread(bdflush, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
-	/* Start the background pageout daemon. */
-	kswapd_setup();
-	kernel_thread(kswapd, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
 
 #if CONFIG_AP1000
 	/* Start the async paging daemon. */
Index: linux/include/linux/mm.h
diff -u linux/include/linux/mm.h:1.1.1.3 linux/include/linux/mm.h:1.1.1.1.2.13
--- linux/include/linux/mm.h:1.1.1.3	Sat Jan  2 15:24:18 1999
+++ linux/include/linux/mm.h	Mon Jan  4 18:42:52 1999
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
Index: linux/include/linux/swap.h
diff -u linux/include/linux/swap.h:1.1.1.4 linux/include/linux/swap.h:1.1.1.1.2.9
--- linux/include/linux/swap.h:1.1.1.4	Tue Dec 29 01:39:03 1998
+++ linux/include/linux/swap.h	Tue Dec 29 02:19:08 1998
@@ -167,9 +167,11 @@
 	count = atomic_read(&page->count);
 	if (PageSwapCache(page))
 	{
+#if 0
 		/* PARANOID */
 		if (page->inode != &swapper_inode)
 			panic("swap cache page has wrong inode\n");
+#endif
 		count += swap_count(page->offset) - 2;
 	}
 	if (PageFreeAfter(page))


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
