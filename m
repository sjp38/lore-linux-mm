Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA20197
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 15:57:45 -0500
Date: Wed, 13 Jan 1999 21:47:45 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] arca-vm-19 [Re: Results: Zlatko's new vm patch]
In-Reply-To: <369ABFB4.C420E5AE@netplus.net>
Message-ID: <Pine.LNX.3.96.990113213203.1822B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu
Cc: Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

I produced a new arca-vm-19. I would like if you could try it. I don't
know if it will work well as previous one...

You could try it on 128Mbyte:

1. with the bootup pager settings (8 2 2 5 32 128 256).
2. after `echo 10 2 2 5 32 128 256 >/proc/sys/vm/pager`
3. after `echo 8 2 2 10 32 128 256 >/proc/sys/vm/pager`
4. after `echo 8 2 2 5 32 32 256 >/proc/sys/vm/pager`
5. after `echo 8 2 2 5 32 128 512 >/proc/sys/vm/pager`
6. after `echo 8 2 2 5 64 128 512 >/proc/sys/vm/pager`

NOTENOTE: if the performances of `1.' are worse than arca-vm-18, don't
_waste_ time trying other pager settings of course ;). 

Again the main differeces is free_user_and_cache() implementation. Now I
try to balance the swap cache to the 5% of total memeory during heavy
swapping activities. I do that growing the cache slowly from the point
shrink_mmap start failing. This _seems_ to work pretty well (the cache
levels seems more balanced than arca-vm-18). But again I based the
behavior on an fixed number (this time tunable via sysctl). I tried
inventing some new autotuning algorithm but it seems that everything I
done was performing worse than both arca-vm-18 and arca-vm-19 (the new
below).

Andrea Arcangeli

arca-vm-19 against pre7.gz (in the testing directory), I hope to have
included everything in this diff...

Index: linux/mm/filemap.c
diff -u linux/mm/filemap.c:1.1.1.9 linux/mm/filemap.c:1.1.1.1.2.46
--- linux/mm/filemap.c:1.1.1.9	Thu Jan  7 12:21:35 1999
+++ linux/mm/filemap.c	Wed Jan 13 21:23:38 1999
@@ -121,14 +125,11 @@
 int shrink_mmap(int priority, int gfp_mask)
 {
 	static unsigned long clock = 0;
-	unsigned long limit = num_physpages;
 	struct page * page;
-	int count;
-
-	count = (limit << 1) >> priority;
+	unsigned long count = num_physpages / (priority+1);
 
 	page = mem_map + clock;
-	do {
+	while (count-- != 0) {
 		int referenced;
 
 		/* This works even in the presence of PageSkip because
@@ -147,7 +148,6 @@
 			clock = page->map_nr;
 		}
 		
-		count--;
 		referenced = test_and_clear_bit(PG_referenced, &page->flags);
 
 		if (PageLocked(page))
@@ -160,21 +160,6 @@
 		if (atomic_read(&page->count) != 1)
 			continue;
 
-		/*
-		 * Is it a page swap page? If so, we want to
-		 * drop it if it is no longer used, even if it
-		 * were to be marked referenced..
-		 */
-		if (PageSwapCache(page)) {
-			if (referenced && swap_count(page->offset) != 1)
-				continue;
-			delete_from_swap_cache(page);
-			return 1;
-		}	
-
-		if (referenced)
-			continue;
-
 		/* Is it a buffer page? */
 		if (page->buffers) {
 			if (buffer_under_min())
@@ -184,6 +169,14 @@
 			return 1;
 		}
 
+		if (referenced)
+			continue;
+
+		if (PageSwapCache(page)) {
+			delete_from_swap_cache(page);
+			return 1;
+		}	
+
 		/* is it a page-cache page? */
 		if (page->inode) {
 			if (pgcache_under_min())
@@ -191,8 +184,7 @@
 			remove_inode_page(page);
 			return 1;
 		}
-
-	} while (count > 0);
+	}
 	return 0;
 }
 
Index: linux/mm/mmap.c
diff -u linux/mm/mmap.c:1.1.1.2 linux/mm/mmap.c:1.1.1.1.2.12
--- linux/mm/mmap.c:1.1.1.2	Fri Nov 27 11:19:10 1998
+++ linux/mm/mmap.c	Wed Jan 13 21:23:38 1999
@@ -66,7 +66,7 @@
 	free += page_cache_size;
 	free += nr_free_pages;
 	free += nr_swap_pages;
-	free -= (page_cache.min_percent + buffer_mem.min_percent + 2)*num_physpages/100; 
+	free -= (pager_daemon.cache_min_percent + pager_daemon.buffer_min_percent + 2)*num_physpages/100; 
 	return free > pages;
 }
 
Index: linux/mm/page_alloc.c
diff -u linux/mm/page_alloc.c:1.1.1.8 linux/mm/page_alloc.c:1.1.1.1.2.30
--- linux/mm/page_alloc.c:1.1.1.8	Mon Jan 11 22:24:23 1999
+++ linux/mm/page_alloc.c	Wed Jan 13 21:23:38 1999
@@ -124,7 +124,6 @@
 	if (!PageReserved(page) && atomic_dec_and_test(&page->count)) {
 		if (PageSwapCache(page))
 			panic ("Freeing swap cache page");
-		page->flags &= ~(1 << PG_referenced);
 		free_pages_ok(page->map_nr, 0);
 		return;
 	}
@@ -141,7 +140,6 @@
 		if (atomic_dec_and_test(&map->count)) {
 			if (PageSwapCache(map))
 				panic ("Freeing swap cache pages");
-			map->flags &= ~(1 << PG_referenced);
 			free_pages_ok(map_nr, order);
 			return;
 		}
@@ -212,19 +210,18 @@
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
@@ -353,10 +350,10 @@
 	unsigned long offset = SWP_OFFSET(entry);
 	struct swap_info_struct *swapdev = SWP_TYPE(entry) + swap_info;
 	
-	offset = (offset >> page_cluster) << page_cluster;
-	
 	for (i = 1 << page_cluster; i > 0; i--) {
-	      if (offset >= swapdev->max)
+	      if (offset >= swapdev->max ||
+		  /* don't block on I/O for doing readahead -arca */
+		  atomic_read(&nr_async_pages) > pager_daemon.max_async_pages)
 		      return;
 	      if (!swapdev->swap_map[offset] ||
 		  swapdev->swap_map[offset] == SWAP_MAP_BAD ||
Index: linux/mm/page_io.c
diff -u linux/mm/page_io.c:1.1.1.4 linux/mm/page_io.c:1.1.1.1.2.6
--- linux/mm/page_io.c:1.1.1.4	Tue Dec 29 01:39:20 1998
+++ linux/mm/page_io.c	Wed Jan 13 00:00:04 1999
@@ -58,7 +58,7 @@
 	}
 
 	/* Don't allow too many pending pages in flight.. */
-	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
+	if (atomic_read(&nr_async_pages) > pager_daemon.max_async_pages)
 		wait = 1;
 
 	p = &swap_info[type];
Index: linux/mm/swap.c
diff -u linux/mm/swap.c:1.1.1.6 linux/mm/swap.c:1.1.1.1.2.13
--- linux/mm/swap.c:1.1.1.6	Mon Jan 11 22:24:24 1999
+++ linux/mm/swap.c	Wed Jan 13 21:23:38 1999
@@ -40,41 +40,18 @@
 };
 
 /* How many pages do we try to swap or page in/out together? */
-int page_cluster = 4; /* Default value modified in swap_setup() */
+int page_cluster = 5; /* Default readahead 32 pages every time */
 
 /* We track the number of pages currently being asynchronously swapped
    out, so that we don't try to swap TOO many pages out at once */
 atomic_t nr_async_pages = ATOMIC_INIT(0);
 
-buffer_mem_t buffer_mem = {
+pager_daemon_t pager_daemon = {
+	8,	/* starting priority of try_to_free_pages() */
 	2,	/* minimum percent buffer */
-	10,	/* borrow percent buffer */
-	60	/* maximum percent buffer */
-};
-
-buffer_mem_t page_cache = {
 	2,	/* minimum percent page cache */
-	15,	/* borrow percent page cache */
-	75	/* maximum */
-};
-
-pager_daemon_t pager_daemon = {
-	512,	/* base number for calculating the number of tries */
-	SWAP_CLUSTER_MAX,	/* minimum number of tries */
-	SWAP_CLUSTER_MAX,	/* do swap I/O in clusters of this size */
+	5,	/* minimum percent swap page cache */
+	32,	/* number of tries we do on every try_to_free_pages() */
+	128,	/* do swap I/O in clusters of this size */
+	256	/* max number of async swapped-out pages on the fly */
 };
-
-/*
- * Perform any setup for the swap system
- */
-
-void __init swap_setup(void)
-{
-	/* Use a smaller cluster for memory <16MB or <32MB */
-	if (num_physpages < ((16 * 1024 * 1024) >> PAGE_SHIFT))
-		page_cluster = 2;
-	else if (num_physpages < ((32 * 1024 * 1024) >> PAGE_SHIFT))
-		page_cluster = 3;
-	else
-		page_cluster = 4;
-}
Index: linux/mm/swapfile.c
diff -u linux/mm/swapfile.c:1.1.1.3 linux/mm/swapfile.c:1.1.1.1.2.6
--- linux/mm/swapfile.c:1.1.1.3	Mon Jan 11 22:24:24 1999
+++ linux/mm/swapfile.c	Wed Jan 13 00:00:04 1999
@@ -23,7 +23,6 @@
 
 struct swap_info_struct swap_info[MAX_SWAPFILES];
 
-#define SWAPFILE_CLUSTER 256
 
 static inline int scan_swap_map(struct swap_info_struct *si)
 {
@@ -31,7 +30,7 @@
 	/* 
 	 * We try to cluster swap pages by allocating them
 	 * sequentially in swap.  Once we've allocated
-	 * SWAPFILE_CLUSTER pages this way, however, we resort to
+	 * SWAP_CLUSTER pages this way, however, we resort to
 	 * first-free allocation, starting a new cluster.  This
 	 * prevents us from scattering swap pages all over the entire
 	 * swap partition, so that we reduce overall disk seek times
@@ -47,7 +46,7 @@
 			goto got_page;
 		}
 	}
-	si->cluster_nr = SWAPFILE_CLUSTER;
+	si->cluster_nr = SWAP_CLUSTER;
 	for (offset = si->lowest_bit; offset <= si->highest_bit ; offset++) {
 		if (si->swap_map[offset])
 			continue;
Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.12 linux/mm/vmscan.c:1.1.1.1.2.91
--- linux/mm/vmscan.c:1.1.1.12	Mon Jan 11 22:24:24 1999
+++ linux/mm/vmscan.c	Wed Jan 13 21:23:38 1999
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
@@ -71,6 +78,21 @@
 	 * memory, and we should just continue our scan.
 	 */
 	if (PageSwapCache(page_map)) {
+		if (pte_write(pte))
+		{
+			struct page *found;
+			printk ("VM: Found a writable swap-cached page!\n");
+			/* Try to diagnose the problem ... */
+			found = find_page(&swapper_inode, page_map->offset);
+			if (found) {
+				printk("page=%p@%08lx, found=%p, count=%d\n",
+				       page_map, page_map->offset,
+				       found, atomic_read(&found->count));
+				__free_page(found);
+			} else 
+				printk ("Spurious, page not in cache\n");
+			return 0;
+		}
 		entry = page_map->offset;
 		swap_duplicate(entry);
 		set_pte(page_table, __pte(entry));
@@ -199,7 +221,7 @@
 
 	do {
 		int result;
-		tsk->swap_address = address + PAGE_SIZE;
+		tsk->mm->swap_address = address + PAGE_SIZE;
 		result = try_to_swap_out(tsk, vma, address, pte, gfp_mask);
 		if (result)
 			return result;
@@ -271,7 +293,7 @@
 	/*
 	 * Go through process' page directory.
 	 */
-	address = p->swap_address;
+	address = p->mm->swap_address;
 
 	/*
 	 * Find the proper vm-area
@@ -293,8 +315,8 @@
 	}
 
 	/* We didn't find anything for the process */
-	p->swap_cnt = 0;
-	p->swap_address = 0;
+	p->mm->swap_cnt = 0;
+	p->mm->swap_address = 0;
 	return 0;
 }
 
@@ -306,7 +328,8 @@
 static int swap_out(unsigned int priority, int gfp_mask)
 {
 	struct task_struct * p, * pbest;
-	int counter, assign, max_cnt;
+	int counter, assign;
+	unsigned long max_cnt;
 
 	/* 
 	 * We make one or two passes through the task list, indexed by 
@@ -325,7 +348,7 @@
 	counter = nr_tasks / (priority+1);
 	if (counter < 1)
 		counter = 1;
-	if (counter > nr_tasks)
+	else if (counter > nr_tasks)
 		counter = nr_tasks;
 
 	for (; counter >= 0; counter--) {
@@ -338,13 +361,13 @@
 		for (; p != &init_task; p = p->next_task) {
 			if (!p->swappable)
 				continue;
-	 		if (p->mm->rss <= 0)
+	 		if (p->mm->rss == 0)
 				continue;
 			/* Refresh swap_cnt? */
 			if (assign)
-				p->swap_cnt = p->mm->rss;
-			if (p->swap_cnt > max_cnt) {
-				max_cnt = p->swap_cnt;
+				p->mm->swap_cnt = p->mm->rss;
+			if (p->mm->swap_cnt > max_cnt) {
+				max_cnt = p->mm->swap_cnt;
 				pbest = p;
 			}
 		}
@@ -375,8 +398,6 @@
        int i;
        char *revision="$Revision: 1.5 $", *s, *e;
 
-       swap_setup();
-       
        if ((s = strchr(revision, ':')) &&
            (e = strchr(s, '$')))
                s++, i = e - s;
@@ -430,7 +451,7 @@
 			break;
 		current->state = TASK_INTERRUPTIBLE;
 		run_task_queue(&tq_disk);
-		schedule_timeout(HZ);
+		schedule_timeout(swapout_interval);
 
 		/*
 		 * kswapd isn't even meant to keep up with anything,
@@ -438,13 +459,36 @@
 		 * point is to make sure that the system doesn't stay
 		 * forever in a really bad memory squeeze.
 		 */
-		if (nr_free_pages < freepages.high)
+		if (nr_free_pages < freepages.min)
 			try_to_free_pages(GFP_KSWAPD);
 	}
 
 	return 0;
 }
 
+static int free_user_and_cache(int priority, int gfp_mask)
+{
+	int freed, swapped = 0;
+	static int grow_swap_cache_mode = 0;
+
+	if (!grow_swap_cache_mode)
+	{
+		freed = shrink_mmap(priority, gfp_mask);
+		if (!freed)
+		{
+			grow_swap_cache_mode = 1;
+			swapped = swap_out(priority, gfp_mask);
+		}
+	} else {
+		if (!swpcache_under_min())
+			grow_swap_cache_mode = 0;
+		swapped = swap_out(priority, gfp_mask);
+		freed = shrink_mmap(priority, gfp_mask);
+	}
+
+	return freed || swapped;
+}
+
 /*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
@@ -457,34 +501,33 @@
 int try_to_free_pages(unsigned int gfp_mask)
 {
 	int priority;
-	int count = SWAP_CLUSTER_MAX;
+	static int state = 0;
+	int count = pager_daemon.tries;
 
 	lock_kernel();
-
-	/* Always trim SLAB caches when memory gets low. */
-	kmem_cache_reap(gfp_mask);
-
-	priority = 6;
-	do {
-		while (shrink_mmap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
 
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
+	priority = pager_daemon.priority;
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
diff -u linux/kernel/sysctl.c:1.1.1.6 linux/kernel/sysctl.c:1.1.1.1.2.12
--- linux/kernel/sysctl.c:1.1.1.6	Mon Jan 11 22:24:22 1999
+++ linux/kernel/sysctl.c	Wed Jan 13 21:23:38 1999
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
@@ -223,11 +225,7 @@
 	 &bdflush_min, &bdflush_max},
 	{VM_OVERCOMMIT_MEMORY, "overcommit_memory", &sysctl_overcommit_memory,
 	 sizeof(sysctl_overcommit_memory), 0644, NULL, &proc_dointvec},
-	{VM_BUFFERMEM, "buffermem",
-	 &buffer_mem, sizeof(buffer_mem_t), 0644, NULL, &proc_dointvec},
-	{VM_PAGECACHE, "pagecache",
-	 &page_cache, sizeof(buffer_mem_t), 0644, NULL, &proc_dointvec},
-	{VM_PAGERDAEMON, "kswapd",
+	{VM_PAGERDAEMON, "pager",
 	 &pager_daemon, sizeof(pager_daemon_t), 0644, NULL, &proc_dointvec},
 	{VM_PGT_CACHE, "pagetable_cache", 
 	 &pgt_cache_water, 2*sizeof(int), 0600, NULL, &proc_dointvec},
Index: linux/include/linux/mm.h
diff -u linux/include/linux/mm.h:1.1.1.6 linux/include/linux/mm.h:1.1.1.1.2.20
--- linux/include/linux/mm.h:1.1.1.6	Mon Jan 11 22:23:57 1999
+++ linux/include/linux/mm.h	Wed Jan 13 21:23:36 1999
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
@@ -387,9 +385,11 @@
 }
 
 #define buffer_under_min()	((buffermem >> PAGE_SHIFT) * 100 < \
-				buffer_mem.min_percent * num_physpages)
-#define pgcache_under_min()	(page_cache_size * 100 < \
-				page_cache.min_percent * num_physpages)
+				pager_daemon.buffer_min_percent * num_physpages)
+#define pgcache_under_min()	((page_cache_size-swapper_inode.i_nrpages) * 100 < \
+				pager_daemon.cache_min_percent * num_physpages)
+#define swpcache_under_min()	(swapper_inode.i_nrpages * 100 < \
+				pager_daemon.swap_min_percent * num_physpages)
 
 #endif /* __KERNEL__ */
 
Index: linux/include/linux/sched.h
diff -u linux/include/linux/sched.h:1.1.1.6 linux/include/linux/sched.h:1.1.1.1.2.12
--- linux/include/linux/sched.h:1.1.1.6	Mon Jan 11 22:24:03 1999
+++ linux/include/linux/sched.h	Wed Jan 13 00:00:03 1999
@@ -169,6 +174,7 @@
 	unsigned long rss, total_vm, locked_vm;
 	unsigned long def_flags;
 	unsigned long cpu_vm_mask;
+	unsigned long swap_cnt, swap_address;
 	/*
 	 * This is an architecture-specific pointer: the portable
 	 * part of Linux does not know about any segments.
@@ -177,15 +183,17 @@
 };
 
 #define INIT_MM {					\
-		&init_mmap, NULL, swapper_pg_dir, 	\
+		&init_mmap, NULL, swapper_pg_dir,	\
 		ATOMIC_INIT(1), 1,			\
 		MUTEX,					\
 		0,					\
 		0, 0, 0, 0,				\
-		0, 0, 0, 				\
+		0, 0, 0,				\
 		0, 0, 0, 0,				\
 		0, 0, 0,				\
-		0, 0, NULL }
+		0, 0,					\
+		0, 0,					\
+		NULL }
 
 struct signal_struct {
 	atomic_t		count;
@@ -270,8 +278,7 @@
 /* mm fault and swap info: this can arguably be seen as either mm-specific or thread-specific */
 	unsigned long min_flt, maj_flt, nswap, cmin_flt, cmaj_flt, cnswap;
 	int swappable:1;
-	unsigned long swap_address;
-	unsigned long swap_cnt;		/* number of pages to swap on next pass */
+	int trashing:1;
 /* process credentials */
 	uid_t uid,euid,suid,fsuid;
 	gid_t gid,egid,sgid,fsgid;
@@ -355,7 +362,7 @@
 /* utime */	{0,0,0,0},0, \
 /* per CPU times */ {0, }, {0, }, \
 /* flt */	0,0,0,0,0,0, \
-/* swp */	0,0,0, \
+/* swp */	0,0, \
 /* process credentials */					\
 /* uid etc */	0,0,0,0,0,0,0,0,				\
 /* suppl grps*/ 0, {0,},					\
Index: linux/include/linux/swapctl.h
diff -u linux/include/linux/swapctl.h:1.1.1.4 linux/include/linux/swapctl.h:1.1.1.1.2.5
--- linux/include/linux/swapctl.h:1.1.1.4	Mon Jan 11 22:24:05 1999
+++ linux/include/linux/swapctl.h	Wed Jan 13 21:23:36 1999
@@ -4,32 +4,24 @@
 #include <asm/page.h>
 #include <linux/fs.h>
 
-typedef struct buffer_mem_v1
+typedef struct freepages_s
 {
-	unsigned int	min_percent;
-	unsigned int	borrow_percent;
-	unsigned int	max_percent;
-} buffer_mem_v1;
-typedef buffer_mem_v1 buffer_mem_t;
-extern buffer_mem_t buffer_mem;
-extern buffer_mem_t page_cache;
-
-typedef struct freepages_v1
-{
 	unsigned int	min;
 	unsigned int	low;
 	unsigned int	high;
-} freepages_v1;
-typedef freepages_v1 freepages_t;
+} freepages_t;
 extern freepages_t freepages;
 
-typedef struct pager_daemon_v1
+typedef struct pager_daemon_s
 {
-	unsigned int	tries_base;
-	unsigned int	tries_min;
+	unsigned int	priority;
+	unsigned int	buffer_min_percent;
+	unsigned int	cache_min_percent;
+	unsigned int	swap_min_percent;
+	unsigned int	tries;
 	unsigned int	swap_cluster;
-} pager_daemon_v1;
-typedef pager_daemon_v1 pager_daemon_t;
+	unsigned int	max_async_pages;
+} pager_daemon_t;
 extern pager_daemon_t pager_daemon;
 
 #endif /* _LINUX_SWAPCTL_H */
Index: linux/include/linux/swap.h
diff -u linux/include/linux/swap.h:1.1.1.6 linux/include/linux/swap.h:1.1.1.1.2.17
--- linux/include/linux/swap.h:1.1.1.6	Mon Jan 11 22:24:05 1999
+++ linux/include/linux/swap.h	Wed Jan 13 21:28:52 1999
@@ -33,7 +33,7 @@
 #define SWP_USED	1
 #define SWP_WRITEOK	3
 
-#define SWAP_CLUSTER_MAX 32
+#define SWAP_CLUSTER	(pager_daemon.swap_cluster)
 
 #define SWAP_MAP_MAX	0x7fff
 #define SWAP_MAP_BAD	0x8000
@@ -68,9 +68,6 @@
 
 /* linux/ipc/shm.c */
 extern int shm_swap (int, int);
-
-/* linux/mm/swap.c */
-extern void swap_setup (void);
 
 /* linux/mm/vmscan.c */
 extern int try_to_free_pages(unsigned int gfp_mask);

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
