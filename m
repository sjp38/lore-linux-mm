Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA28200
	for <linux-mm@kvack.org>; Sat, 2 Jan 1999 10:39:51 -0500
Date: Sat, 2 Jan 1999 16:38:17 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
In-Reply-To: <Pine.LNX.3.95.990101225111.16066K-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990102162944.176A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Jan 1999, Linus Torvalds wrote:

> The other thing I'd like to hear is how pre3 looks with this patch, which
> should behave basically like Andrea's latest patch but without the
> obfuscation he put into his patch..

I rediffed my latest swapout stuff against your latest tree (I consider
your latest patch as test1-pre4, right?).

Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.9 linux/mm/vmscan.c:1.1.1.1.2.52
--- linux/mm/vmscan.c:1.1.1.9	Sat Jan  2 15:46:20 1999
+++ linux/mm/vmscan.c	Sat Jan  2 15:53:33 1999
@@ -10,6 +10,11 @@
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
  */
 
+/*
+ * Revisioned the page freeing algorithm: do_free_user_and_cache().
+ * Copyright (C) 1998  Andrea Arcangeli
+ */
+
 #include <linux/slab.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
@@ -162,8 +167,9 @@
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
@@ -180,8 +186,9 @@
 		 * asynchronously.  That's no problem, shrink_mmap() can
 		 * correctly clean up the occassional unshared page
 		 * which gets left behind in the swap cache. */
+		entry = atomic_read(&page_map->count);
 		__free_page(page_map);
-		return 1;	/* we slept: the process may not exist any more */
+		return entry;	/* we slept: the process may not exist any more */
 	}
 
 	/* The page was _not_ dirty, but still has a zero age.  It must
@@ -194,8 +201,9 @@
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
@@ -210,7 +218,7 @@
 	flush_cache_page(vma, address);
 	pte_clear(page_table);
 	flush_tlb_page(vma, address);
-	entry = (atomic_read(&page_map->count) == 1);
+	entry = atomic_read(&page_map->count);
 	__free_page(page_map);
 	return entry;
 }
@@ -381,6 +389,7 @@
 		counter = nr_tasks;
 
 	for (; counter >= 0; counter--) {
+		int retval;
 		assign = 0;
 		max_cnt = 0;
 		pbest = NULL;
@@ -413,8 +422,9 @@
 		 * Nonzero means we cleared out something, but only "1" means
 		 * that we actually free'd up a page as a result.
 		 */
-		if (swap_out_process(pbest, gfp_mask) == 1)
-			return 1;
+		retval = swap_out_process(pbest, gfp_mask);
+		if (retval)
+			return retval;
 	}
 out:
 	return 0;
@@ -441,42 +451,64 @@
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
+			*state = 2;
+		case 2:
+			shrink_dcache_memory(priority, gfp_mask);
+			kmem_cache_reap(gfp_mask);
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
@@ -524,6 +556,7 @@
 		current->state = TASK_INTERRUPTIBLE;
 		flush_signals(current);
 		run_task_queue(&tq_disk);
+		enable_swap_tick();
 		schedule();
 		swapstats.wakeups++;
 		state = kswapd_free_pages(state);
@@ -543,35 +576,23 @@
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
@@ -594,7 +615,8 @@
 	if (priority) {
 		p->counter = p->priority << priority;
 		wake_up_process(p);
-	}
+	} else
+		enable_swap_tick();
 }
 
 /* 
@@ -632,9 +654,8 @@
 			want_wakeup = 3;
 	
 		kswapd_wakeup(p,want_wakeup);
-	}
-
-	timer_active |= (1<<SWAP_TIMER);
+	} else
+		enable_swap_tick();
 }
 
 /* 
@@ -643,7 +664,6 @@
 
 void init_swap_timer(void)
 {
-	timer_table[SWAP_TIMER].expires = jiffies;
 	timer_table[SWAP_TIMER].fn = swap_tick;
-	timer_active |= (1<<SWAP_TIMER);
+	enable_swap_tick();
 }



The try_to_swap_out() changes (entry = atomic_read()) are really not
important for the performance. We could always return 1 instead of
atomic_read() and consider the retval 1 from swap_out() as every current
retval >1. Since I can't see a big performance impact by atomic_read() I
left it here since it will give us more info than returning a plain 1 and
so knowing only that we have succesfully unliked a page from the user
process memory. 

I have also a new experimental patch against the one above, that here
improve a _lot_ the swapout performance. The benchmark that dirtify 160
Mbyte in loop was used to take near 106 sec and now takes 89sec. It will
also avoid all not trashing process to be swapped out.

I don't consider this production code though but I am interested if
somebody will try it ;):

Index: mm//vmscan.c
===================================================================
RCS file: /var/cvs/linux/mm/vmscan.c,v
retrieving revision 1.1.1.1.2.52
diff -u -r1.1.1.1.2.52 vmscan.c
--- vmscan.c	1999/01/02 14:53:33	1.1.1.1.2.52
+++ linux/mm/vmscan.c	1999/01/02 15:19:21
@@ -353,7 +353,6 @@
 	}
 
 	/* We didn't find anything for the process */
-	p->swap_cnt = 0;
 	p->swap_address = 0;
 	return 0;
 }
@@ -423,6 +422,14 @@
 		 * that we actually free'd up a page as a result.
 		 */
 		retval = swap_out_process(pbest, gfp_mask);
+		/*
+		 * Don't play with other tasks next time if the huge one
+		 * is been swapedin in the meantime. This can be considered
+		 * a bit experimental, but it seems to improve a lot the
+		 * swapout performances here. -arca
+		 */
+		p->swap_cnt = p->mm->rss;
+
 		if (retval)
 			return retval;
 	}
 

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
