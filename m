Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA23057
	for <linux-mm@kvack.org>; Fri, 1 Jan 1999 15:03:04 -0500
Date: Fri, 1 Jan 1999 21:02:29 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
In-Reply-To: <Pine.LNX.3.96.990101171008.1145B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990101203728.301B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I rediffed my VM patch against test1-patch-2.2.0-pre3.gz. I also fixed
some bug (not totally critical but..) pointed out by Linus in my last
code. I also changed the shrink_mmap(0) to shrink_mmap(priority) because
it was completly sucking a lot performance. There is no need to do a
shrink_mmap(0) for example if the cache/buffer are under min. In such case
we must allow the swap_out() to grow the cache before start shrinking it.

So basically this new patch is _far_ more efficient than the last
one (I never seen so good/stable/fast behavior before!).

This my new patch is against testing/test1-patch-2.2.0-pre3.gz that is
against v2.1/2.2.0-pre2 that is against patch-2.2.0-pre1-vs-2.1.132.gz
(where is this last one now?).

Ah, from testing/test1-patch-2.2.0-pre3.gz was missing the trashing memory
initialization that will allow every process to do a fast start.

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
 
Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.8 linux/mm/vmscan.c:1.1.1.1.2.49
--- linux/mm/vmscan.c:1.1.1.8	Fri Jan  1 19:12:54 1999
+++ linux/mm/vmscan.c	Fri Jan  1 20:29:19 1999
@@ -162,8 +162,9 @@
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
@@ -180,8 +181,9 @@
 		 * asynchronously.  That's no problem, shrink_mmap() can
 		 * correctly clean up the occassional unshared page
 		 * which gets left behind in the swap cache. */
+		entry = atomic_read(&page_map->count);
 		__free_page(page_map);
-		return 1;	/* we slept: the process may not exist any more */
+		return entry;	/* we slept: the process may not exist any more */
 	}
 
 	/* The page was _not_ dirty, but still has a zero age.  It must
@@ -194,8 +196,9 @@
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
@@ -210,7 +213,7 @@
 	flush_cache_page(vma, address);
 	pte_clear(page_table);
 	flush_tlb_page(vma, address);
-	entry = (atomic_read(&page_map->count) == 1);
+	entry = atomic_read(&page_map->count);
 	__free_page(page_map);
 	return entry;
 }
@@ -369,8 +372,14 @@
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
@@ -382,15 +391,8 @@
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
@@ -404,14 +406,13 @@
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
@@ -438,44 +439,74 @@
        printk ("Starting kswapd v%.*s\n", i, s);
 }
 
-#define free_memory(fn) \
-	count++; do { if (!--count) goto done; } while (fn)
+static int do_free_user_and_cache(int priority, int gfp_mask)
+{
+	switch (swap_out(priority, gfp_mask))
+	{
+	default:
+		shrink_mmap(priority, gfp_mask);
+		/*
+		 * We done at least some swapping progress so return 1 in
+		 * this case. -arca
+		 */
+		return 1;
+	case 0:
+		/* swap_out() failed to swapout */
+		if (shrink_mmap(priority, gfp_mask))
+			return 1;
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
 
-	/* Always trim SLAB caches when memory gets low. */
-	kmem_cache_reap(0);
+	kmem_cache_reap(gfp_mask);
 
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
+
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
@@ -542,35 +574,23 @@
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
@@ -593,7 +613,8 @@
 	if (priority) {
 		p->counter = p->priority << priority;
 		wake_up_process(p);
-	}
+	} else
+		enable_swap_tick();
 }
 
 /* 
@@ -631,9 +652,8 @@
 			want_wakeup = 3;
 	
 		kswapd_wakeup(p,want_wakeup);
-	}
-
-	timer_active |= (1<<SWAP_TIMER);
+	} else
+		enable_swap_tick();
 }
 
 /* 
@@ -642,7 +662,6 @@
 
 void init_swap_timer(void)
 {
-	timer_table[SWAP_TIMER].expires = jiffies;
 	timer_table[SWAP_TIMER].fn = swap_tick;
-	timer_active |= (1<<SWAP_TIMER);
+	enable_swap_tick();
 }
Index: linux/mm/swap_state.c
diff -u linux/mm/swap_state.c:1.1.1.4 linux/mm/swap_state.c:1.1.1.1.2.9
--- linux/mm/swap_state.c:1.1.1.4	Fri Jan  1 19:12:54 1999
+++ linux/mm/swap_state.c	Fri Jan  1 19:25:33 1999
@@ -262,6 +262,9 @@
 struct page * lookup_swap_cache(unsigned long entry)
 {
 	struct page *found;
+#ifdef	SWAP_CACHE_INFO
+	swap_cache_find_total++;
+#endif
 	
 	while (1) {
 		found = find_page(&swapper_inode, entry);
@@ -269,8 +272,12 @@
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




If this patch is decreasing performance for you (eventually due too much
memory swapped out) you can try this incremental patch (I never tried here
btw):

Index: mm//vmscan.c
===================================================================
RCS file: /var/cvs/linux/mm/vmscan.c,v
retrieving revision 1.1.1.1.2.49
diff -u -r1.1.1.1.2.49 vmscan.c
--- vmscan.c	1999/01/01 19:29:19	1.1.1.1.2.49
+++ linux/mm/vmscan.c	1999/01/01 19:51:22
@@ -441,6 +441,9 @@
 
 static int do_free_user_and_cache(int priority, int gfp_mask)
 {
+	if (shrink_mmap(priority, gfp_mask))
+		return 1;
+
 	switch (swap_out(priority, gfp_mask))
 	{
 	default:



I written a swap benchmark that is dirtifying 160Mbyte of VM. For the
first loop 2.2-pre1 was taking 106 sec, for the second loop 120 and
then worse.

test1-pre3 + my new patch in this email, instead takes 120 sec in the
first loop (since it's allocating it's probably slowed down a bit by the
trashing_memory heuristic, and that's right), then it takes 90 sec in the
second loop and 77 sec in the third loop!! and the system was far to be
idle (as when I measured 2.2-pre1), but I was using it without special
regards and was perfectly usable (2.2-pre1 was unusable instead).

Comments?

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
