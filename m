Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA23772
	for <linux-mm@kvack.org>; Thu, 16 Jul 1998 08:32:01 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk> 	<m190lxmxmv.fsf@flinx.npwt.net> 	<87lnpxy582.fsf@atlas.CARNet.hr> <199807141732.SAA07242@dax.dcs.ed.ac.uk>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 16 Jul 1998 14:31:47 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Tue, 14 Jul 1998 18:32:45 +0100"
Message-ID: <87iukyugcs.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Well, I've been compiling kernels all day for this. :)  Any information
> you can give will help, but for now it does look as if backing out the
> cache ageing is a necessary first step.
> 

OK, here we go:

Official 2.1.108:

              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU
          200  4552 65.5  5011 20.5  2570 21.1  5643 74.4  4077 14.9  84.8  2.9
                                                           ^^^^      ^^^^^

Patched 2.1.108 (no page aging, no cache limits, modified slab, etc... see below)

              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU
          200  6449 89.7  7450 31.4  2605 22.2  6052 80.5  7269 27.3 105.4  2.9
                                                           ^^^^      ^^^^^

I'm applying patch that produced results above. I don't claim my
work is suitable for anything. It is just part of my Linux MM
exploration, testing and simplifying things.

But, it worked stable and fast for me, last few months, and survived
all torture testing I've been putting on it. YMMV, of course.

Test platform is P166MMX, 64MB RAM, aic7xxx, Fujitsu M2954ESP.
The results are completely reproducable.

Regards,

------------------------------------------------------------

diff -urN --exclude-from=exclude linux-old/Documentation/sysctl/vm.txt linux/Documentation/sysctl/vm.txt
--- linux-old/Documentation/sysctl/vm.txt	Fri Jun 26 19:44:26 1998
+++ linux/Documentation/sysctl/vm.txt	Tue Jul 14 21:32:56 1998
@@ -15,13 +15,9 @@
 
 Currently, these files are in /proc/sys/vm:
 - bdflush
-- buffermem
 - freepages
-- kswapd
 - overcommit_memory
-- pagecache
 - swapctl
-- swapout_interval
 
 ==============================================================
 
@@ -90,80 +86,23 @@
 age_super is for filesystem metadata.
 
 ==============================================================
-buffermem:
 
-The three values in this file correspond to the values in
-the struct buffer_mem. It controls how much memory should
-be used for buffer memory. The percentage is calculated
-as a percentage of total system memory.
-
-The values are:
-min_percent	-- this is the minimum percentage of memory
-		   that should be spent on buffer memory
-borrow_percent  -- when Linux is short on memory, and the
-                   buffer cache uses more memory, free pages
-                   are stolen from it
-max_percent     -- this is the maximum amount of memory that
-                   can be used for buffer memory 
-
-==============================================================
 freepages:
 
 This file contains the values in the struct freepages. That
 struct contains three members: min, low and high.
 
-Although the goal of the Linux memory management subsystem
-is to avoid fragmentation and make large chunks of free
-memory (so that we can hand out DMA buffers and such), there
-still are some page-based limits in the system, mainly to
-make sure we don't waste too much memory trying to get large
-free area's.
-
 The meaning of the numbers is:
 
 freepages.min	When the number of free pages in the system
 		reaches this number, only the kernel can
 		allocate more memory.
-freepages.low	If memory is too fragmented, the swapout
-		daemon is started, except when the number
-		of free pages is larger than freepages.low.
-freepages.high	The swapping daemon exits when memory is
-		sufficiently defragmented, when the number
-		of free pages reaches freepages.high or when
-		it has tried the maximum number of times. 
-
-==============================================================
-
-kswapd:
-
-Kswapd is the kernel swapout daemon. That is, kswapd is that
-piece of the kernel that frees memory when it gets fragmented
-or full. Since every system is different, you'll probably want
-some control over this piece of the system.
-
-The numbers in this page correspond to the numbers in the
-struct pager_daemon {tries_base, tries_min, swap_cluster
-}; The tries_base and swap_cluster probably have the
-largest influence on system performance.
-
-tries_base	The maximum number of pages kswapd tries to
-		free in one round is calculated from this
-		number. Usually this number will be divided
-		by 4 or 8 (see mm/vmscan.c), so it isn't as
-		big as it looks.
-		When you need to increase the bandwidth to/from
-		swap, you'll want to increase this number.
-tries_min	This is the minimum number of times kswapd
-		tries to free a page each time it is called.
-		Basically it's just there to make sure that
-		kswapd frees some pages even when it's being
-		called with minimum priority.
-swap_cluster	This is the number of pages kswapd writes in
-		one turn. You want this large so that kswapd
-		does it's I/O in large chunks and the disk
-		doesn't have to seek often, but you don't want
-		it to be too large since that would flood the
-		request queue.
+freepages.low	When the number of free pages drops below
+		this number, swapping daemon (kswapd) is
+		woken up.
+freepages.high	This is kswapd's target, when there are more
+		free pages than this number, kswapd will stop
+		running.
 
 ==============================================================
 
@@ -206,18 +145,6 @@
 
 ==============================================================
 
-pagecache:
-
-This file does exactly the same as buffermem, only this
-file controls the struct page_cache, and thus controls
-the amount of memory allowed for memory mapping of files.
-
-You don't want the minimum level to be too low, otherwise
-your system might thrash when memory is tight or fragmentation
-is high...
-
-==============================================================
-
 swapctl:
 
 This file contains no less than 8 variables.
@@ -273,15 +200,3 @@
 process pages in order to satisfy buffer memory demands, you
 might want to either increase sc_bufferout_weight, or decrease
 the value of sc_pageout_weight.
-
-==============================================================
-
-swapout_interval:
-
-The single value in this file controls the amount of time
-between successive wakeups of kswapd when nr_free_pages is
-between free_pages_low and free_pages_high. The default value
-of HZ/4 is usually right, but when kswapd can't keep up with
-the number of allocations in your system, you might want to
-decrease this number. 
-
diff -urN --exclude-from=exclude linux-old/fs/buffer.c linux/fs/buffer.c
--- linux-old/fs/buffer.c	Fri Jun 26 19:44:35 1998
+++ linux/fs/buffer.c	Tue Jul 14 21:32:56 1998
@@ -704,7 +704,7 @@
 			 * of other sizes, this is necessary now that we
 			 * no longer have the lav code.
 			 */
-			try_to_free_buffer(bh,&bh,1);
+			try_to_free_buffer(bh, &bh);
 			if (!bh)
 				break;
 			continue;
@@ -733,9 +733,7 @@
 	/* We are going to try to locate this much memory. */
 	needed = bdf_prm.b_un.nrefill * size;  
 
-	while ((nr_free_pages > freepages.min*2) &&
-	        (buffermem >> PAGE_SHIFT) * 100 < (buffer_mem.max_percent * num_physpages) &&
-		grow_buffers(GFP_BUFFER, size)) {
+	while ((nr_free_pages > freepages.low) && grow_buffers(GFP_BUFFER, size)) {
 		obtained += PAGE_SIZE;
 		if (obtained >= needed)
 			return;
@@ -1646,8 +1644,7 @@
  * try_to_free_buffer() checks if all the buffers on this particular page
  * are unused, and free's the page if so.
  */
-int try_to_free_buffer(struct buffer_head * bh, struct buffer_head ** bhp,
-		       int priority)
+int try_to_free_buffer(struct buffer_head * bh, struct buffer_head ** bhp)
 {
 	unsigned long page;
 	struct buffer_head * tmp, * p;
@@ -1659,11 +1656,9 @@
 	do {
 		if (!tmp)
 			return 0;
-		if (tmp->b_count || buffer_protected(tmp) ||
-		    buffer_dirty(tmp) || buffer_locked(tmp) ||
-		    buffer_waiting(tmp))
-			return 0;
-		if (priority && buffer_touched(tmp))
+		if (tmp->b_count || buffermem < PAGE_SIZE * freepages.low ||
+		    buffer_protected(tmp) || buffer_dirty(tmp) || buffer_locked(tmp)
+		    || buffer_waiting(tmp) || buffer_touched(tmp))
 			return 0;
 		tmp = tmp->b_this_page;
 	} while (tmp != bh);
diff -urN --exclude-from=exclude linux-old/include/linux/fs.h linux/include/linux/fs.h
--- linux-old/include/linux/fs.h	Thu May 21 01:21:42 1998
+++ linux/include/linux/fs.h	Tue Jul 14 21:32:56 1998
@@ -707,7 +707,7 @@
 
 extern void refile_buffer(struct buffer_head * buf);
 extern void set_writetime(struct buffer_head * buf, int flag);
-extern int try_to_free_buffer(struct buffer_head*, struct buffer_head**, int);
+extern int try_to_free_buffer(struct buffer_head*, struct buffer_head**);
 
 extern int nr_buffers;
 extern int buffermem;
diff -urN --exclude-from=exclude linux-old/include/linux/mm.h linux/include/linux/mm.h
--- linux-old/include/linux/mm.h	Thu Jul  2 20:07:56 1998
+++ linux/include/linux/mm.h	Tue Jul 14 21:32:56 1998
@@ -253,23 +253,6 @@
 
 /* memory.c & swap.c*/
 
-/*
- * This traverses "nr" memory size lists,
- * and returns true if there is enough memory.
- *
- * For example, we want to keep on waking up
- * kswapd every once in a while until the highest
- * memory order has an entry (ie nr == 0), but
- * we want to do it in the background.
- *
- * We want to do it in the foreground only if
- * none of the three highest lists have enough
- * memory. Random number.
- */
-extern int free_memory_available(int nr);
-#define kswapd_continue()	(!free_memory_available(3))
-#define kswapd_wakeup()		(!free_memory_available(0))
-
 #define free_page(addr) free_pages((addr),0)
 extern void FASTCALL(free_pages(unsigned long addr, unsigned long order));
 extern void FASTCALL(__free_page(struct page *));
diff -urN --exclude-from=exclude linux-old/include/linux/swap.h linux/include/linux/swap.h
--- linux-old/include/linux/swap.h	Tue Jun 16 23:29:10 1998
+++ linux/include/linux/swap.h	Tue Jul 14 21:32:56 1998
@@ -50,7 +50,7 @@
 extern int shm_swap (int, int);
 
 /* linux/mm/vmscan.c */
-extern int try_to_free_page(int);
+extern void try_to_free_page(int);
 
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, unsigned long, char *, int);
@@ -92,17 +92,6 @@
  * swap cache stuff (in linux/mm/swap_state.c)
  */
 
-#define SWAP_CACHE_INFO
-
-#ifdef SWAP_CACHE_INFO
-extern unsigned long swap_cache_add_total;
-extern unsigned long swap_cache_add_success;
-extern unsigned long swap_cache_del_total;
-extern unsigned long swap_cache_del_success;
-extern unsigned long swap_cache_find_total;
-extern unsigned long swap_cache_find_success;
-#endif
-
 extern inline unsigned long in_swap_cache(struct page *page)
 {
 	if (PageSwapCache(page))
@@ -126,21 +115,6 @@
 	if (PageFreeAfter(page))
 		count--;
 	return (count > 1);
-}
-
-/*
- * When we're freeing pages from a user application, we want
- * to cluster swapouts too.	-- Rik.
- * linux/mm/page_alloc.c
- */
-static inline int try_to_free_pages(int gfp_mask, int count)
-{
-	int retval = 0;
-	while (count--) {
-		if (try_to_free_page(gfp_mask))
-			retval = 1;
-	}
-	return retval;
 }
 
 /*
diff -urN --exclude-from=exclude linux-old/include/linux/swapctl.h linux/include/linux/swapctl.h
--- linux-old/include/linux/swapctl.h	Thu May 21 01:21:43 1998
+++ linux/include/linux/swapctl.h	Tue Jul 14 21:32:56 1998
@@ -31,16 +31,6 @@
 typedef swapstat_v1 swapstat_t;
 extern swapstat_t swapstats;
 
-typedef struct buffer_mem_v1
-{
-	unsigned int	min_percent;
-	unsigned int	borrow_percent;
-	unsigned int	max_percent;
-} buffer_mem_v1;
-typedef buffer_mem_v1 buffer_mem_t;
-extern buffer_mem_t buffer_mem;
-extern buffer_mem_t page_cache;
-
 typedef struct freepages_v1
 {
 	unsigned int	min;
@@ -49,15 +39,6 @@
 } freepages_v1;
 typedef freepages_v1 freepages_t;
 extern freepages_t freepages;
-
-typedef struct pager_daemon_v1
-{
-	unsigned int	tries_base;
-	unsigned int	tries_min;
-	unsigned int	swap_cluster;
-} pager_daemon_v1;
-typedef pager_daemon_v1 pager_daemon_t;
-extern pager_daemon_t pager_daemon;
 
 #define SC_VERSION	1
 #define SC_MAX_VERSION	1
diff -urN --exclude-from=exclude linux-old/include/linux/sysctl.h linux/include/linux/sysctl.h
--- linux-old/include/linux/sysctl.h	Tue Jun 16 23:29:10 1998
+++ linux/include/linux/sysctl.h	Tue Jul 14 21:32:56 1998
@@ -74,13 +74,9 @@
 enum
 {
 	VM_SWAPCTL=1,		/* struct: Set vm swapping control */
-	VM_SWAPOUT,		/* int: Background pageout interval */
 	VM_FREEPG,		/* struct: Set free page thresholds */
 	VM_BDFLUSH,		/* struct: Control buffer cache flushing */
 	VM_OVERCOMMIT_MEMORY,	/* Turn off the virtual memory safety limit */
-	VM_BUFFERMEM,		/* struct: Set buffer memory thresholds */
-	VM_PAGECACHE,		/* struct: Set cache memory thresholds */
-	VM_PAGERDAEMON,		/* struct: Control kswapd behaviour */
 	VM_PGT_CACHE		/* struct: Set page table cache parameters */
 };
 
diff -urN --exclude-from=exclude linux-old/kernel/sysctl.c linux/kernel/sysctl.c
--- linux-old/kernel/sysctl.c	Tue Jun 16 23:29:11 1998
+++ linux/kernel/sysctl.c	Tue Jul 14 21:32:56 1998
@@ -7,7 +7,7 @@
  * Added hooks for /proc/sys/net (minor, minor patch), 96/4/1, Mike Shaver.
  * Added kernel/java-{interpreter,appletviewer}, 96/5/10, Mike Shaver.
  * Dynamic registration fixes, Stephen Tweedie.
- * Added kswapd-interval, ctrl-alt-del, printk stuff, 1/8/97, Chris Horn.
+ * Added ctrl-alt-del, printk stuff, 1/8/97, Chris Horn.
  * Made sysctl support optional via CONFIG_SYSCTL, 1/10/97, Chris Horn.
  */
 
@@ -37,7 +37,7 @@
 
 /* External variables not in a header file. */
 extern int panic_timeout;
-extern int console_loglevel, C_A_D, swapout_interval;
+extern int console_loglevel, C_A_D;
 extern int bdf_prm[], bdflush_min[], bdflush_max[];
 extern char binfmt_java_interpreter[], binfmt_java_appletviewer[];
 extern int sysctl_overcommit_memory;
@@ -191,21 +191,12 @@
 static ctl_table vm_table[] = {
 	{VM_SWAPCTL, "swapctl", 
 	 &swap_control, sizeof(swap_control_t), 0644, NULL, &proc_dointvec},
-	{VM_SWAPOUT, "swapout_interval",
-	 &swapout_interval, sizeof(int), 0644, NULL, &proc_dointvec},
 	{VM_FREEPG, "freepages", 
 	 &freepages, sizeof(freepages_t), 0644, NULL, &proc_dointvec},
 	{VM_BDFLUSH, "bdflush", &bdf_prm, 9*sizeof(int), 0600, NULL,
-	 &proc_dointvec_minmax, &sysctl_intvec, NULL,
-	 &bdflush_min, &bdflush_max},
+	 &proc_dointvec_minmax, &sysctl_intvec, NULL, &bdflush_min, &bdflush_max},
 	{VM_OVERCOMMIT_MEMORY, "overcommit_memory", &sysctl_overcommit_memory,
 	 sizeof(sysctl_overcommit_memory), 0644, NULL, &proc_dointvec},
-	{VM_BUFFERMEM, "buffermem",
-	 &buffer_mem, sizeof(buffer_mem_t), 0644, NULL, &proc_dointvec},
-	{VM_PAGECACHE, "pagecache",
-	 &page_cache, sizeof(buffer_mem_t), 0644, NULL, &proc_dointvec},
-	{VM_PAGERDAEMON, "kswapd",
-	 &pager_daemon, sizeof(pager_daemon_t), 0644, NULL, &proc_dointvec},
 	{VM_PGT_CACHE, "pagetable_cache", 
 	 &pgt_cache_water, 2*sizeof(int), 0600, NULL, &proc_dointvec},
 	{0}
diff -urN --exclude-from=exclude linux-old/mm/filemap.c linux/mm/filemap.c
--- linux-old/mm/filemap.c	Thu Jul  2 20:07:56 1998
+++ linux/mm/filemap.c	Tue Jul 14 21:32:56 1998
@@ -150,10 +150,6 @@
 				}
 				tmp = tmp->b_this_page;
 			} while (tmp != bh);
-
-			/* Refuse to swap out all buffer pages */
-			if ((buffermem >> PAGE_SHIFT) * 100 < (buffer_mem.min_percent * num_physpages))
-				goto next;
 		}
 
 		/* We can't throw away shared pages, but we do mark
@@ -164,15 +160,11 @@
 
 		switch (atomic_read(&page->count)) {
 			case 1:
+				/* If it has been referenced recently, don't free it */
+				if (test_and_clear_bit(PG_referenced, &page->flags))
+					break;
 				/* is it a swap-cache or page-cache page? */
 				if (page->inode) {
-					if (test_and_clear_bit(PG_referenced, &page->flags)) {
-						touch_page(page);
-						break;
-					}
-					age_page(page);
-					if (page->age || page_cache_size * 100 < (page_cache.min_percent * num_physpages))
-						break;
 					if (PageSwapCache(page)) {
 						delete_from_swap_cache(page);
 						return 1;
@@ -182,13 +174,8 @@
 					__free_page(page);
 					return 1;
 				}
-				/* It's not a cache page, so we don't do aging.
-				 * If it has been referenced recently, don't free it */
-				if (test_and_clear_bit(PG_referenced, &page->flags))
-					break;
-
 				/* is it a buffer cache page? */
-				if ((gfp_mask & __GFP_IO) && bh && try_to_free_buffer(bh, &bh, 6))
+				if ((gfp_mask & __GFP_IO) && bh && try_to_free_buffer(bh, &bh))
 					return 1;
 				break;
 
diff -urN --exclude-from=exclude linux-old/mm/page_alloc.c linux/mm/page_alloc.c
--- linux-old/mm/page_alloc.c	Fri Jun 26 19:44:38 1998
+++ linux/mm/page_alloc.c	Tue Jul 14 21:32:56 1998
@@ -100,53 +100,6 @@
  */
 spinlock_t page_alloc_lock = SPIN_LOCK_UNLOCKED;
 
-/*
- * This routine is used by the kernel swap daemon to determine
- * whether we have "enough" free pages. It is fairly arbitrary,
- * but this had better return false if any reasonable "get_free_page()"
- * allocation could currently fail..
- *
- * This will return zero if no list was found, non-zero
- * if there was memory (the bigger, the better).
- */
-int free_memory_available(int nr)
-{
-	int retval = 0;
-	unsigned long flags;
-	struct free_area_struct * list;
-
-	/*
-	 * If we have more than about 3% to 5% of all memory free,
-	 * consider it to be good enough for anything.
-	 * It may not be, due to fragmentation, but we
-	 * don't want to keep on forever trying to find
-	 * free unfragmented memory.
-	 * Added low/high water marks to avoid thrashing -- Rik.
-	 */
-	if (nr_free_pages > (nr ? freepages.low : freepages.high))
-		return nr+1;
-
-	list = free_area + NR_MEM_LISTS;
-	spin_lock_irqsave(&page_alloc_lock, flags);
-	/* We fall through the loop if the list contains one
-	 * item. -- thanks to Colin Plumb <colin@nyx.net>
-	 */
-	do {
-		list--;
-		/* Empty list? Bad - we need more memory */
-		if (list->next == memory_head(list))
-			break;
-		/* One item on the list? Look further */
-		if (list->next->next == memory_head(list))
-			continue;
-		/* More than one item? We're ok */
-		retval = nr + 1;
-		break;
-	} while (--nr >= 0);
-	spin_unlock_irqrestore(&page_alloc_lock, flags);
-	return retval;
-}
-
 static inline void free_pages_ok(unsigned long map_nr, unsigned long order)
 {
 	struct free_area_struct *area = free_area + order;
@@ -215,30 +168,6 @@
  */
 #define MARK_USED(index, order, area) \
 	change_bit((index) >> (1+(order)), (area)->map)
-#define CAN_DMA(x) (PageDMA(x))
-#define ADDRESS(x) (PAGE_OFFSET + ((x) << PAGE_SHIFT))
-#define RMQUEUE(order, maxorder, dma) \
-do { struct free_area_struct * area = free_area+order; \
-     unsigned long new_order = order; \
-	do { struct page *prev = memory_head(area), *ret = prev->next; \
-		while (memory_head(area) != ret) { \
-			if (new_order >= maxorder && ret->next == prev) \
-				break; \
-			if (!dma || CAN_DMA(ret)) { \
-				unsigned long map_nr = ret->map_nr; \
-				(prev->next = ret->next)->prev = prev; \
-				MARK_USED(map_nr, new_order, area); \
-				nr_free_pages -= 1 << order; \
-				EXPAND(ret, map_nr, order, new_order, area); \
-				spin_unlock_irqrestore(&page_alloc_lock, flags); \
-				return ADDRESS(map_nr); \
-			} \
-			prev = ret; \
-			ret = ret->next; \
-		} \
-		new_order++; area++; \
-	} while (new_order < NR_MEM_LISTS); \
-} while (0)
 
 #define EXPAND(map,index,low,high,area) \
 do { unsigned long size = 1 << high; \
@@ -255,18 +184,11 @@
 
 unsigned long __get_free_pages(int gfp_mask, unsigned long order)
 {
-	unsigned long flags, maxorder;
+	unsigned long flags, new_order, extra = 0;
+	struct free_area_struct *area;
 
 	if (order >= NR_MEM_LISTS)
-		goto nopage;
-
-	/*
-	 * "maxorder" is the highest order number that we're allowed
-	 * to empty in order to find a free page..
-	 */
-	maxorder = NR_MEM_LISTS-1;
-	if (gfp_mask & __GFP_HIGH)
-		maxorder = NR_MEM_LISTS;
+		return 0;
 
 	if (in_interrupt() && (gfp_mask & __GFP_WAIT)) {
 		static int count = 0;
@@ -277,18 +199,39 @@
 		}
 	}
 
-	for (;;) {
-		spin_lock_irqsave(&page_alloc_lock, flags);
-		RMQUEUE(order, maxorder, (gfp_mask & GFP_DMA));
-		spin_unlock_irqrestore(&page_alloc_lock, flags);
-		if (!(gfp_mask & __GFP_WAIT))
-			break;
-		if (!try_to_free_pages(gfp_mask, SWAP_CLUSTER_MAX))
-			break;
-		gfp_mask &= ~__GFP_WAIT;	/* go through this only once */
-		maxorder = NR_MEM_LISTS;	/* Allow anything this time */
+ repeat:
+	if ((gfp_mask & __GFP_WAIT))
+		if (extra || (nr_free_pages < freepages.min && !(gfp_mask & __GFP_MED)))
+			while (nr_free_pages + atomic_read(&nr_async_pages) <
+			       freepages.low + extra)
+				try_to_free_page(gfp_mask);
+	new_order = order;
+	area = free_area + order;
+	spin_lock_irqsave(&page_alloc_lock, flags);
+	do {
+		struct page *prev = memory_head(area), *ret;
+
+		while (memory_head(area) != (ret = prev->next)) {
+			if (!(gfp_mask & GFP_DMA) || PageDMA(ret)) {
+				unsigned long map_nr = ret->map_nr;
+
+				(prev->next = ret->next)->prev = prev;
+				MARK_USED(map_nr, new_order, area);
+				nr_free_pages -= 1 << order;
+				EXPAND(ret, map_nr, order, new_order, area);
+				spin_unlock_irqrestore(&page_alloc_lock, flags);
+				return PAGE_OFFSET + (map_nr << PAGE_SHIFT);
+			}
+			prev = ret;
+		}
+		new_order++;
+		area++;
+	} while (new_order < NR_MEM_LISTS);
+	spin_unlock_irqrestore(&page_alloc_lock, flags);
+	if (gfp_mask & __GFP_WAIT) {
+		extra += SWAP_CLUSTER_MAX;
+		goto repeat;
 	}
-nopage:
 	return 0;
 }
 
@@ -315,9 +258,6 @@
 	}
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
 	printk("= %lukB)\n", total);
-#ifdef SWAP_CACHE_INFO
-	show_swap_cache_info();
-#endif	
 }
 
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
@@ -340,14 +280,14 @@
 	 * that we don't waste too much memory on large systems.
 	 * This is totally arbitrary.
 	 */
-	i = (end_mem - PAGE_OFFSET) >> (PAGE_SHIFT+7);
+	i = (end_mem - PAGE_OFFSET) >> (PAGE_SHIFT + 7);
 	if (i < 48)
 		i = 48;
 	if (i > 256)
 		i = 256;
 	freepages.min = i;
 	freepages.low = i << 1;
-	freepages.high = freepages.low + i;
+	freepages.high = i << 2;
 	mem_map = (mem_map_t *) LONG_ALIGN(start_mem);
 	p = mem_map + MAP_NR(end_mem);
 	start_mem = LONG_ALIGN((unsigned long) p);
diff -urN --exclude-from=exclude linux-old/mm/slab.c linux/mm/slab.c
--- linux-old/mm/slab.c	Fri Jun 26 19:44:38 1998
+++ linux/mm/slab.c	Tue Jul 14 21:32:56 1998
@@ -308,12 +308,12 @@
 #define	SLAB_MAX_GFP_ORDER	5	/* 32 pages */
 
 /* the 'preferred' minimum num of objs per slab - maybe less for large objs */
-#define	SLAB_MIN_OBJS_PER_SLAB	4
+#define	SLAB_MIN_OBJS_PER_SLAB	1
 
 /* If the num of objs per slab is <= SLAB_MIN_OBJS_PER_SLAB,
  * then the page order must be less than this before trying the next order.
  */
-#define	SLAB_BREAK_GFP_ORDER	2
+#define	SLAB_BREAK_GFP_ORDER	1
 
 /* Macros for storing/retrieving the cachep and or slab from the
  * global 'mem_map'.  With off-slab bufctls, these are used to find the
diff -urN --exclude-from=exclude linux-old/mm/swap.c linux/mm/swap.c
--- linux-old/mm/swap.c	Fri Jun 26 19:44:38 1998
+++ linux/mm/swap.c	Tue Jul 14 21:32:56 1998
@@ -10,7 +10,6 @@
  * linux/Documentation/sysctl/vm.txt.
  * Started 18.12.91
  * Swap aging added 23.2.95, Stephen Tweedie.
- * Buffermem limits added 12.3.98, Rik van Riel.
  */
 
 #include <linux/mm.h>
@@ -36,8 +35,8 @@
 /*
  * We identify three levels of free memory.  We never let free mem
  * fall below the freepages.min except for atomic allocations.  We
- * start background swapping if we fall below freepages.high free
- * pages, and we begin intensive swapping below freepages.low.
+ * start background swapping if we fall below freepages.low free
+ * pages, and we begin intensive swapping below freepages.min.
  *
  * These values are there to keep GCC from complaining. Actual
  * initialization is done in mm/page_alloc.c or arch/sparc(64)/mm/init.c.
@@ -45,7 +44,7 @@
 freepages_t freepages = {
 	48,	/* freepages.min */
 	96,	/* freepages.low */
-	144	/* freepages.high */
+	192	/* freepages.high */
 };
 
 /* We track the number of pages currently being asynchronously swapped
@@ -65,21 +64,3 @@
 };
 
 swapstat_t swapstats = {0};
-
-buffer_mem_t buffer_mem = {
-	3,	/* minimum percent buffer */
-	10,	/* borrow percent buffer */
-	30	/* maximum percent buffer */
-};
-
-buffer_mem_t page_cache = {
-	10,	/* minimum percent page cache */
-	30,	/* borrow percent page cache */
-	75	/* maximum */
-};
-
-pager_daemon_t pager_daemon = {
-	512,	/* base number for calculating the number of tries */
-	SWAP_CLUSTER_MAX,	/* minimum number of tries */
-	SWAP_CLUSTER_MAX,	/* do swap I/O in clusters of this size */
-};
diff -urN --exclude-from=exclude linux-old/mm/swap_state.c linux/mm/swap_state.c
--- linux-old/mm/swap_state.c	Tue Mar 10 19:51:02 1998
+++ linux/mm/swap_state.c	Tue Jul 14 21:32:56 1998
@@ -24,14 +24,6 @@
 #include <asm/bitops.h>
 #include <asm/pgtable.h>
 
-#ifdef SWAP_CACHE_INFO
-unsigned long swap_cache_add_total = 0;
-unsigned long swap_cache_add_success = 0;
-unsigned long swap_cache_del_total = 0;
-unsigned long swap_cache_del_success = 0;
-unsigned long swap_cache_find_total = 0;
-unsigned long swap_cache_find_success = 0;
-
 /* 
  * Keep a reserved false inode which we will use to mark pages in the
  * page cache are acting as swap cache instead of file cache. 
@@ -43,21 +35,8 @@
  */
 struct inode swapper_inode;
 
-
-void show_swap_cache_info(void)
-{
-	printk("Swap cache: add %ld/%ld, delete %ld/%ld, find %ld/%ld\n",
-		swap_cache_add_total, swap_cache_add_success, 
-		swap_cache_del_total, swap_cache_del_success,
-		swap_cache_find_total, swap_cache_find_success);
-}
-#endif
-
 int add_to_swap_cache(struct page *page, unsigned long entry)
 {
-#ifdef SWAP_CACHE_INFO
-	swap_cache_add_total++;
-#endif
 #ifdef DEBUG_SWAP
 	printk("DebugVM: add_to_swap_cache(%08lx count %d, entry %08lx)\n",
 	       page_address(page), atomic_read(&page->count), entry);
@@ -78,9 +57,6 @@
 	page->offset = entry;
 	add_page_to_hash_queue(page, &swapper_inode, entry);
 	add_page_to_inode_queue(&swapper_inode, page);
-#ifdef SWAP_CACHE_INFO
-	swap_cache_add_success++;
-#endif
 	return 1;
 }
 
@@ -168,14 +144,9 @@
 
 long find_in_swap_cache(struct page *page)
 {
-#ifdef SWAP_CACHE_INFO
-	swap_cache_find_total++;
-#endif
 	if (PageSwapCache (page))  {
 		long entry = page->offset;
-#ifdef SWAP_CACHE_INFO
-		swap_cache_find_success++;
-#endif	
+
 		remove_from_swap_cache (page);
 		return entry;
 	}
@@ -184,14 +155,8 @@
 
 int delete_from_swap_cache(struct page *page)
 {
-#ifdef SWAP_CACHE_INFO
-	swap_cache_del_total++;
-#endif	
 	if (PageSwapCache (page))  {
 		long entry = page->offset;
-#ifdef SWAP_CACHE_INFO
-		swap_cache_del_success++;
-#endif
 #ifdef DEBUG_SWAP
 		printk("DebugVM: delete_from_swap_cache(%08lx count %d, "
 		       "entry %08lx)\n",
@@ -297,4 +262,3 @@
 #endif
 	return new_page;
 }
-
diff -urN --exclude-from=exclude linux-old/mm/vmscan.c linux/mm/vmscan.c
--- linux-old/mm/vmscan.c	Fri Jun 26 19:44:38 1998
+++ linux/mm/vmscan.c	Tue Jul 14 21:32:56 1998
@@ -29,17 +29,6 @@
 #include <asm/pgtable.h>
 
 /* 
- * When are we next due for a page scan? 
- */
-static unsigned long next_swap_jiffies = 0;
-
-/* 
- * How often do we do a pageout scan during normal conditions?
- * Default is four times a second.
- */
-int swapout_interval = HZ / 4;
-
-/* 
  * The wait queue for waking up the pageout daemon:
  */
 static struct wait_queue * kswapd_wait = NULL;
@@ -444,61 +433,39 @@
  * to be.  This works out OK, because we now do proper aging on page
  * contents. 
  */
-static inline int do_try_to_free_page(int gfp_mask)
+void try_to_free_page(int gfp_mask)
 {
 	static int state = 0;
-	int i=6;
-	int stop;
+	int prio = 6;
+
+	lock_kernel();
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
-	/* We try harder if we are waiting .. */
-	stop = 3;
-	if (gfp_mask & __GFP_WAIT)
-		stop = 0;
-	if (((buffermem >> PAGE_SHIFT) * 100 > buffer_mem.borrow_percent * num_physpages)
-		   || (page_cache_size * 100 > page_cache.borrow_percent * num_physpages))
-		state = 0;
-
-	switch (state) {
-		do {
+	for (prio = 6; prio >= 0; prio--) {
+		switch (state) {
 		case 0:
-			if (shrink_mmap(i, gfp_mask))
-				return 1;
+			if (shrink_mmap(prio, gfp_mask))
+				goto out;
 			state = 1;
 		case 1:
-			if ((gfp_mask & __GFP_IO) && shm_swap(i, gfp_mask))
-				return 1;
+			if ((gfp_mask & __GFP_IO) && shm_swap(prio, gfp_mask))
+				goto out;
 			state = 2;
 		case 2:
-			if (swap_out(i, gfp_mask))
-				return 1;
+			if (swap_out(prio, gfp_mask))
+				goto out;
 			state = 3;
 		case 3:
-			shrink_dcache_memory(i, gfp_mask);
+			shrink_dcache_memory(prio, gfp_mask);
 			state = 0;
-		i--;
-		} while ((i - stop) >= 0);
-	}
-	return 0;
-}
-
-/*
- * This is REALLY ugly.
- *
- * We need to make the locks finer granularity, but right
- * now we need this so that we can do page allocations
- * without holding the kernel lock etc.
- */
-int try_to_free_page(int gfp_mask)
-{
-	int retval;
-
-	lock_kernel();
-	retval = do_try_to_free_page(gfp_mask);
-	unlock_kernel();
-	return retval;
+		}
+  	}
+ out:
+  	unlock_kernel();
+	if (atomic_read(&nr_async_pages) >= SWAP_CLUSTER_MAX)
+		run_task_queue(&tq_disk);
 }
 
 /*
@@ -547,54 +514,16 @@
 
 	init_swap_timer();
 	add_wait_queue(&kswapd_wait, &wait);
-	while (1) {
-		int tries;
-		int tried = 0;
-
+	for (;;) {
 		current->state = TASK_INTERRUPTIBLE;
 		flush_signals(current);
-		run_task_queue(&tq_disk);
 		schedule();
 		swapstats.wakeups++;
 
-		/*
-		 * Do the background pageout: be
-		 * more aggressive if we're really
-		 * low on free memory.
-		 *
-		 * We try page_daemon.tries_base times, divided by
-		 * an 'urgency factor'. In practice this will mean
-		 * a value of pager_daemon.tries_base / 8 or 4 = 64
-		 * or 128 pages at a time.
-		 * This gives us 64 (or 128) * 4k * 4 (times/sec) =
-		 * 1 (or 2) MB/s swapping bandwidth in low-priority
-		 * background paging. This number rises to 8 MB/s
-		 * when the priority is highest (but then we'll be
-		 * woken up more often and the rate will be even
-		 * higher).
-		 */
-		tries = pager_daemon.tries_base >> free_memory_available(3);
-	
-		while (tries--) {
-			int gfp_mask;
-
-			if (++tried > pager_daemon.tries_min && free_memory_available(0))
-				break;
-			gfp_mask = __GFP_IO;
-			try_to_free_page(gfp_mask);
-			/*
-			 * Syncing large chunks is faster than swapping
-			 * synchronously (less head movement). -- Rik.
-			 */
-			if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster)
-				run_task_queue(&tq_disk);
-
-		}
-	}
-	/* As if we could ever get here - maybe we want to make this killable */
-	remove_wait_queue(&kswapd_wait, &wait);
-	unlock_kernel();
-	return 0;
+		while (nr_free_pages + atomic_read(&nr_async_pages) < freepages.high)
+			try_to_free_page(nr_free_pages < freepages.min ?
+					 (__GFP_IO | __GFP_WAIT) : __GFP_IO);
+  	}
 }
 
 /* 
@@ -602,38 +531,9 @@
  */
 void swap_tick(void)
 {
-	unsigned long now, want;
-	int want_wakeup = 0;
-
-	want = next_swap_jiffies;
-	now = jiffies;
-
-	/*
-	 * Examine the memory queues. Mark memory low
-	 * if there is nothing available in the three
-	 * highest queues.
-	 *
-	 * Schedule for wakeup if there isn't lots
-	 * of free memory.
-	 */
-	switch (free_memory_available(3)) {
-	case 0:
-		want = now;
-		/* Fall through */
-	case 1 ... 3:
-		want_wakeup = 1;
-	default:
-	}
- 
-	if ((long) (now - want) >= 0) {
-		if (want_wakeup || (num_physpages * buffer_mem.max_percent) < (buffermem >> PAGE_SHIFT) * 100
-				|| (num_physpages * page_cache.max_percent < page_cache_size * 100)) {
-			/* Set the next wake-up time */
-			next_swap_jiffies = now + swapout_interval;
-			wake_up(&kswapd_wait);
-		}
-	}
-	timer_active |= (1<<SWAP_TIMER);
+	if (nr_free_pages < freepages.low)
+		wake_up(&kswapd_wait);
+	timer_active |= (1 << SWAP_TIMER);
 }
 
 /* 
@@ -644,5 +544,5 @@
 {
 	timer_table[SWAP_TIMER].expires = 0;
 	timer_table[SWAP_TIMER].fn = swap_tick;
-	timer_active |= (1<<SWAP_TIMER);
+	timer_active |= (1 << SWAP_TIMER);
 }

-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
Unix _IS_ user friendly - it's just selective about who its friends are!
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
