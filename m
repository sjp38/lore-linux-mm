Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA01981
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 18:05:49 -0500
Date: Tue, 12 Jan 1999 00:03:02 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
In-Reply-To: <Pine.LNX.3.96.990111202801.565A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990111234054.5378A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

I've seen pre7 now and I produced arca-vm-18 against it.

In arca-vm-18 I avoided the swaping readahead if we would be forced to do
_sync_ IO in the readahead. This make tons of sense to me. 

I also reverted my trashing heuristic to a per-process thing. The point of
the heuristic is not to penalyze processes. The pint is to _not_ penalyze
processes that are not eating memory. Making it a static variable make
sense of course but it's a completly different thing. And I think that
having only a few processes that are in the free-pages-path will improve
global performances. 

Here arca-vm-18 against 2.2.0-pre7 in the testing directory (sent me by
email by Steve).

Note: it's still very interesting how arca-vm-17 is performing since here
I am following pre5/pre7/arca-vm-17 style of freeing every time only
SWAP_CLUSTER_MAX pages. Here this change decrease a _lot_ swapout
performances, but I don't know if the global system is faster... I am only
running a trashing-swapout-benchmarking application, and I am not
benchmarking how the rest of the system is responsive...

Another thing that would be interesting could be to change
SWAPFILE_CLUSTER to 256 as in clean pre7. I think it's not needed because
I am not hearing disk seeks under heavy swapping but may I guess there is
some reason is 256 in pre7 ;)?

Index: linux/include/linux/mm.h
diff -u linux/include/linux/mm.h:1.1.1.6 linux/include/linux/mm.h:1.1.1.1.2.18
--- linux/include/linux/mm.h:1.1.1.6	Mon Jan 11 22:23:57 1999
+++ linux/include/linux/mm.h	Mon Jan 11 22:56:08 1999
@@ -118,7 +118,6 @@
 	unsigned long offset;
 	struct page *next_hash;
 	atomic_t count;
-	unsigned int unused;
 	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
 	struct wait_queue *wait;
 	struct page **pprev_hash;
@@ -302,8 +301,7 @@
 
 /* filemap.c */
 extern void remove_inode_page(struct page *);
-extern unsigned long page_unuse(struct page *);
-extern int shrink_mmap(int, int);
+extern int FASTCALL(shrink_mmap(int, int));
 extern void truncate_inode_pages(struct inode *, unsigned long);
 extern unsigned long get_cached_page(struct inode *, unsigned long, int);
 extern void put_cached_page(unsigned long);
Index: linux/include/linux/sched.h
diff -u linux/include/linux/sched.h:1.1.1.6 linux/include/linux/sched.h:1.1.1.1.2.11
--- linux/include/linux/sched.h:1.1.1.6	Mon Jan 11 22:24:03 1999
+++ linux/include/linux/sched.h	Mon Jan 11 23:29:36 1999
@@ -270,6 +275,7 @@
 /* mm fault and swap info: this can arguably be seen as either mm-specific or thread-specific */
 	unsigned long min_flt, maj_flt, nswap, cmin_flt, cmaj_flt, cnswap;
 	int swappable:1;
+	int trashing:1;
 	unsigned long swap_address;
 	unsigned long swap_cnt;		/* number of pages to swap on next pass */
 /* process credentials */
@@ -355,7 +361,7 @@
 /* utime */	{0,0,0,0},0, \
 /* per CPU times */ {0, }, {0, }, \
 /* flt */	0,0,0,0,0,0, \
-/* swp */	0,0,0, \
+/* swp */	0,0,0,0, \
 /* process credentials */					\
 /* uid etc */	0,0,0,0,0,0,0,0,				\
 /* suppl grps*/ 0, {0,},					\
Index: linux/kernel/fork.c
diff -u linux/kernel/fork.c:1.1.1.6 linux/kernel/fork.c:1.1.1.1.2.10
--- linux/kernel/fork.c:1.1.1.6	Mon Jan 11 22:24:21 1999
+++ linux/kernel/fork.c	Mon Jan 11 22:56:09 1999
@@ -511,6 +514,7 @@
 
 	p->did_exec = 0;
 	p->swappable = 0;
+	p->trashing = 0;
 	p->state = TASK_UNINTERRUPTIBLE;
 
 	copy_flags(clone_flags, p);
Index: linux/kernel/sysctl.c
diff -u linux/kernel/sysctl.c:1.1.1.6 linux/kernel/sysctl.c:1.1.1.1.2.11
--- linux/kernel/sysctl.c:1.1.1.6	Mon Jan 11 22:24:22 1999
+++ linux/kernel/sysctl.c	Mon Jan 11 22:56:09 1999
@@ -32,7 +32,7 @@
 
 /* External variables not in a header file. */
 extern int panic_timeout;
-extern int console_loglevel, C_A_D;
+extern int console_loglevel, C_A_D, swapout_interval;
 extern int bdf_prm[], bdflush_min[], bdflush_max[];
 extern char binfmt_java_interpreter[], binfmt_java_appletviewer[];
 extern int sysctl_overcommit_memory;
@@ -216,6 +216,8 @@
 };
 
 static ctl_table vm_table[] = {
+	{VM_SWAPOUT, "swapout_interval",
+	 &swapout_interval, sizeof(int), 0644, NULL, &proc_dointvec},
 	{VM_FREEPG, "freepages", 
 	 &freepages, sizeof(freepages_t), 0644, NULL, &proc_dointvec},
 	{VM_BDFLUSH, "bdflush", &bdf_prm, 9*sizeof(int), 0600, NULL,
Index: linux/mm/filemap.c
diff -u linux/mm/filemap.c:1.1.1.9 linux/mm/filemap.c:1.1.1.1.2.44
--- linux/mm/filemap.c:1.1.1.9	Thu Jan  7 12:21:35 1999
+++ linux/mm/filemap.c	Sat Jan  9 19:30:01 1999
@@ -122,13 +126,13 @@
 {
 	static unsigned long clock = 0;
 	unsigned long limit = num_physpages;
+	unsigned long count;
 	struct page * page;
-	int count;
 
 	count = (limit << 1) >> priority;
 
 	page = mem_map + clock;
-	do {
+	while (count-- != 0) {
 		int referenced;
 
 		/* This works even in the presence of PageSkip because
@@ -147,7 +151,6 @@
 			clock = page->map_nr;
 		}
 		
-		count--;
 		referenced = test_and_clear_bit(PG_referenced, &page->flags);
 
 		if (PageLocked(page))
@@ -191,8 +194,7 @@
 			remove_inode_page(page);
 			return 1;
 		}
-
-	} while (count > 0);
+	}
 	return 0;
 }
 
Index: linux/mm/page_alloc.c
diff -u linux/mm/page_alloc.c:1.1.1.8 linux/mm/page_alloc.c:1.1.1.1.2.28
--- linux/mm/page_alloc.c:1.1.1.8	Mon Jan 11 22:24:23 1999
+++ linux/mm/page_alloc.c	Mon Jan 11 22:56:09 1999
@@ -212,19 +212,18 @@
 		 * further thought.
 		 */
 		if (!(current->flags & PF_MEMALLOC)) {
-			static int trashing = 0;
 			int freed;
 
 			if (nr_free_pages > freepages.min) {
-				if (!trashing)
+				if (!current->trashing)
 					goto ok_to_allocate;
 				if (nr_free_pages > freepages.low) {
-					trashing = 0;
+					current->trashing = 0;
 					goto ok_to_allocate;
 				}
 			}
 
-			trashing = 1;
+			current->trashing = 1;
 			current->flags |= PF_MEMALLOC;
 			freed = try_to_free_pages(gfp_mask);
 			current->flags &= ~PF_MEMALLOC;
@@ -356,7 +355,9 @@
 	offset = (offset >> page_cluster) << page_cluster;
 	
 	for (i = 1 << page_cluster; i > 0; i--) {
-	      if (offset >= swapdev->max)
+	      if (offset >= swapdev->max ||
+		  /* don't block on I/O for doing readahead -arca */
+		  atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
 		      return;
 	      if (!swapdev->swap_map[offset] ||
 		  swapdev->swap_map[offset] == SWAP_MAP_BAD ||
Index: linux/mm/swapfile.c
diff -u linux/mm/swapfile.c:1.1.1.3 linux/mm/swapfile.c:1.1.1.1.2.4
--- linux/mm/swapfile.c:1.1.1.3	Mon Jan 11 22:24:24 1999
+++ linux/mm/swapfile.c	Mon Jan 11 22:56:09 1999
@@ -23,7 +23,7 @@
 
 struct swap_info_struct swap_info[MAX_SWAPFILES];
 
-#define SWAPFILE_CLUSTER 256
+#define SWAPFILE_CLUSTER	SWAP_CLUSTER_MAX
 
 static inline int scan_swap_map(struct swap_info_struct *si)
 {
Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.12 linux/mm/vmscan.c:1.1.1.1.2.87
--- linux/mm/vmscan.c:1.1.1.12	Mon Jan 11 22:24:24 1999
+++ linux/mm/vmscan.c	Mon Jan 11 22:56:09 1999
@@ -10,6 +10,11 @@
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
  */
 
+/*
+ * free_user_and_cache() and always async swapout original idea.
+ * Copyright (C) 1999  Andrea Arcangeli
+ */
+
 #include <linux/slab.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
@@ -20,6 +25,8 @@
 
 #include <asm/pgtable.h>
 
+int swapout_interval = HZ;
+
 /*
  * The swap-out functions return 1 if they successfully
  * threw something out, and we got a free page. It returns
@@ -306,7 +313,8 @@
 static int swap_out(unsigned int priority, int gfp_mask)
 {
 	struct task_struct * p, * pbest;
-	int counter, assign, max_cnt;
+	int counter, assign;
+	unsigned long max_cnt;
 
 	/* 
 	 * We make one or two passes through the task list, indexed by 
@@ -325,7 +333,7 @@
 	counter = nr_tasks / (priority+1);
 	if (counter < 1)
 		counter = 1;
-	if (counter > nr_tasks)
+	else if (counter > nr_tasks)
 		counter = nr_tasks;
 
 	for (; counter >= 0; counter--) {
@@ -338,7 +346,7 @@
 		for (; p != &init_task; p = p->next_task) {
 			if (!p->swappable)
 				continue;
-	 		if (p->mm->rss <= 0)
+	 		if (p->mm->rss == 0)
 				continue;
 			/* Refresh swap_cnt? */
 			if (assign)
@@ -430,7 +438,7 @@
 			break;
 		current->state = TASK_INTERRUPTIBLE;
 		run_task_queue(&tq_disk);
-		schedule_timeout(HZ);
+		schedule_timeout(swapout_interval);
 
 		/*
 		 * kswapd isn't even meant to keep up with anything,
@@ -445,6 +453,29 @@
 	return 0;
 }
 
+static int free_user_and_cache(int priority, int gfp_mask)
+{
+	static unsigned long grow_swap_cache = 0;
+
+	if (!shrink_mmap(priority, gfp_mask))
+		grow_swap_cache = 1;
+
+	switch (grow_swap_cache)
+	{
+	case 0:
+		return 1;
+	default:
+		if (grow_swap_cache++ >= freepages.high)
+			grow_swap_cache = 0;
+	}
+
+	if (swap_out(priority, gfp_mask))
+		return 1;
+
+	grow_swap_cache = 0;
+	return 0;
+}
+
 /*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
@@ -457,34 +488,33 @@
 int try_to_free_pages(unsigned int gfp_mask)
 {
 	int priority;
+	static int state = 0;
 	int count = SWAP_CLUSTER_MAX;
 
 	lock_kernel();
 
-	/* Always trim SLAB caches when memory gets low. */
-	kmem_cache_reap(gfp_mask);
-
 	priority = 6;
-	do {
-		while (shrink_mmap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
-
-		/* Try to get rid of some shared memory pages.. */
-		while (shm_swap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
-	
-		/* Then, try to page stuff out.. */
-		while (swap_out(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
+	switch (state)
+	{
+		do {
+		case 0:
+			while (free_user_and_cache(priority, gfp_mask)) {
+				if (!--count)
+					goto done;
+			}
+			state = 1;
+		case 1:
+			/* Try to get rid of some shared memory pages.. */
+			while (shm_swap(priority, gfp_mask)) {
+				if (!--count)
+					goto done;
+			}
+			state = 0;
 
-		shrink_dcache_memory(priority, gfp_mask);
-	} while (--priority >= 0);
+			kmem_cache_reap(gfp_mask);
+			shrink_dcache_memory(priority, gfp_mask);
+		} while (--priority >= 0);
+	}
 done:
 	unlock_kernel();
 

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
