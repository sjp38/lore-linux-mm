Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA22805
	for <linux-mm@kvack.org>; Mon, 21 Dec 1998 08:06:48 -0500
Date: Mon, 21 Dec 1998 14:03:44 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.3.95.981220060902.643A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.981221110323.591D-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Sun, 20 Dec 1998, Linus Torvalds wrote:

>I expect that it needs to be tested in different configurations to find
>the optimal values for various tunables, but hopefully this is it when it
>comes to basic code.

I've done some changes to your code. The most experimental (easily
removable from the patch) is to move the check_pgt_cache() at the top of
the try_to/kswapd engines. This way we' ll trim the page table cache only
when we are low on memory, there's no reason to reclaim memory until there
is other memory unused I think.

The patch add also a bit of stats to the swap cache find case. 

The real difference is to change the priority of try_to_free_pages() to 4
since this way we more probably allow process to continue their work
without to sleep for a lot of time waiting for SYNC I/O completation.

I also revert to shrink_mmap() if the async IO queue request is saturated.

Seems to work fine here...

Index: linux/mm/memory.c
diff -u linux/mm/memory.c:1.1.1.2 linux/mm/memory.c:1.1.1.1.2.6
--- linux/mm/memory.c:1.1.1.2	Fri Nov 27 11:19:10 1998
+++ linux/mm/memory.c	Sun Dec 20 23:42:16 1998
@@ -136,8 +136,10 @@
 	for (i = 0 ; i < USER_PTRS_PER_PGD ; i++)
 		free_one_pgd(page_dir + i);
 
+#if 0 /* let kswapd to do this */
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
+#endif
 	return;
 
 out_bad:
@@ -165,8 +167,10 @@
 		free_one_pgd(page_dir + i);
 	pgd_free(page_dir);
 
+#if 0 /* let kswapd to do this */
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
+#endif
 out:
 	return;
 
Index: linux/mm/swap_state.c
diff -u linux/mm/swap_state.c:1.1.1.3 linux/mm/swap_state.c:1.1.1.1.2.7
--- linux/mm/swap_state.c:1.1.1.3	Sun Dec 20 16:31:12 1998
+++ linux/mm/swap_state.c	Sun Dec 20 16:51:32 1998
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
Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.5 linux/mm/vmscan.c:1.1.1.1.2.33
--- linux/mm/vmscan.c:1.1.1.5	Sun Dec 20 16:31:12 1998
+++ linux/mm/vmscan.c	Mon Dec 21 10:25:22 1998
@@ -447,11 +447,12 @@
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(0);
+	check_pgt_cache();
 
 	/* max one hundreth of a second */
 	end_time = jiffies + (HZ-1)/100;
 	do {
-		int priority = 7;
+		int priority = 6;
 		int count = pager_daemon.swap_cluster;
 
 		switch (kswapd_state) {
@@ -476,6 +477,12 @@
 	return kswapd_state;
 }
 
+static inline void enable_swap_tick(void)
+{
+	timer_table[SWAP_TIMER].expires = jiffies;
+	timer_active |= 1<<SWAP_TIMER;
+}
+
 /*
  * The background pageout daemon.
  * Started as a kernel thread from the init process.
@@ -523,6 +530,7 @@
 		current->state = TASK_INTERRUPTIBLE;
 		flush_signals(current);
 		run_task_queue(&tq_disk);
+		enable_swap_tick();
 		schedule();
 		swapstats.wakeups++;
 		state = kswapd_free_pages(state);
@@ -553,6 +561,7 @@
 
 	lock_kernel();
 
+	check_pgt_cache();
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
@@ -562,7 +571,7 @@
 
 		current->flags |= PF_MEMALLOC;
 	
-		priority = 8;
+		priority = 4;
 		do {
 			free_memory(shrink_mmap(priority, gfp_mask));
 			free_memory(shm_swap(priority, gfp_mask));
@@ -593,7 +602,8 @@
 	if (priority) {
 		p->counter = p->priority << priority;
 		wake_up_process(p);
-	}
+	} else
+		enable_swap_tick();
 }
 
 /* 
@@ -631,9 +641,8 @@
 			want_wakeup = 3;
 	
 		kswapd_wakeup(p,want_wakeup);
-	}
-
-	timer_active |= (1<<SWAP_TIMER);
+	} else
+		enable_swap_tick();
 }
 
 /* 
Index: linux/arch/i386/kernel/process.c
diff -u linux/arch/i386/kernel/process.c:1.1.1.4 linux/arch/i386/kernel/process.c:1.1.1.1.2.32
--- linux/arch/i386/kernel/process.c:1.1.1.4	Thu Dec 17 16:33:27 1998
+++ linux/arch/i386/kernel/process.c	Mon Dec 21 10:35:52 1998
@@ -73,11 +73,11 @@
 
 #ifndef __SMP__
 
+#ifdef CONFIG_APM
 static void hard_idle(void)
 {
 	while (!current->need_resched) {
 		if (boot_cpu_data.hlt_works_ok && !hlt_counter) {
-#ifdef CONFIG_APM
 				/* If the APM BIOS is not enabled, or there
 				 is an error calling the idle routine, we
 				 should hlt if possible.  We need to check
@@ -87,44 +87,50 @@
 			if (!apm_do_idle() && !current->need_resched)
 				__asm__("hlt");
 			end_bh_atomic();
-#else
-			__asm__("hlt");
-#endif
 	        }
  		if (current->need_resched) 
  			break;
 		schedule();
 	}
-#ifdef CONFIG_APM
 	apm_do_busy();
-#endif
 }
+#endif
 
 /*
  * The idle loop on a uniprocessor i386..
  */ 
 static int cpu_idle(void *unused)
 {
+#ifdef CONFIG_APM
 	int work = 1;
 	unsigned long start_idle = 0;
+#endif
+	long * need_resched = &current->need_resched;
 
 	/* endless idle loop with no priority at all */
 	current->priority = 0;
 	current->counter = -100;
 	for (;;) {
+#ifdef CONFIG_APM
 		if (work)
 			start_idle = jiffies;
 
 		if (jiffies - start_idle > HARD_IDLE_TIMEOUT) 
 			hard_idle();
 		else  {
-			if (boot_cpu_data.hlt_works_ok && !hlt_counter && !current->need_resched)
+#endif
+			if (boot_cpu_data.hlt_works_ok && !hlt_counter && !*need_resched)
 		        	__asm__("hlt");
+
+#ifdef CONFIG_APM
 		}
 
-		work = current->need_resched;
+		work = *need_resched;
+#endif
 		schedule();
+#if 0
 		check_pgt_cache();
+#endif
 	}
 }
 
@@ -136,14 +142,18 @@
 
 int cpu_idle(void *unused)
 {
+	long * need_resched = &current->need_resched;
+
 	/* endless idle loop with no priority at all */
 	current->priority = 0;
 	current->counter = -100;
 	while(1) {
-		if (current_cpu_data.hlt_works_ok && !hlt_counter && !current->need_resched)
+		if (current_cpu_data.hlt_works_ok && !hlt_counter && !*need_resched)
 			__asm__("hlt");
 		schedule();
+#if 0
 		check_pgt_cache();
+#endif
 	}
 }
 


Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
