From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001150203.SAA63864@google.engr.sgi.com>
Subject: Reworked 2.3.39 zone balancing - v1
Date: Fri, 14 Jan 2000 18:03:06 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10001131524580.2250-100000@penguin.transmeta.com> from "Linus Torvalds" at Jan 13, 2000 03:29:51 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@chiara.csoma.elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Okay folks, here's what I have now. I am still testing it, but I am 
sending it out for comments. 

* kswapd uses a list of zones to be balanced. Useful when the number
of zones is high (in numa, or discontigmem machines). Linus, I have
an alternate version where kswapd goes thru all zones in all pgdats
too, let me know if you would prefer that or want to take a look at 
it.

* any deallocator can decide whether freeing a page will benefit a
zone that has fallen below its watermarks by using PG_ZONE_BALANCED().
Thus shm_swap() and try_to_swap_out() use this to prevent "unneeded"
swapouts. Linus, I am open to deleting this check and going with
what you suggested initially. Added due to Andrea's and my concerns,
originally suggested by Ingo.

* Ingo's idea about victimizing young ptes in try_to_swap_out() under
high pressure not yet in this patch, will be added if this version looks
okay.

Comments/feedback welcome.

Kanoj

--- Documentation/vm/balance	Fri Jan 14 16:32:22 2000
+++ Documentation/vm/balance	Fri Jan 14 16:07:28 2000
@@ -0,0 +1,87 @@
+Started Jan 2000 by Kanoj Sarcar <kanoj@sgi.com>
+
+Memory balancing is needed for non __GFP_WAIT as well as for non
+__GFP_IO allocations.
+
+There are two reasons to be requesting non __GFP_WAIT allocations:
+the caller can not sleep (typically intr context), or does not want
+to incur cost overheads of page stealing and possible swap io for
+whatever reasons.
+
+__GFP_IO allocation requests are made to prevent file system deadlocks.
+
+In the absence of non sleepable allocation requests, it seems detrimental
+to be doing balancing. Page reclamation can be kicked off lazily, that
+is, only when needed (aka zone free memory is 0), instead of making it
+a proactive process.
+
+That being said, the kernel should try to fulfill requests for direct
+mapped pages from the direct mapped pool, instead of falling back on
+the dma pool, so as to keep the dma pool filled for dma requests (atomic
+or not). A similar argument applies to highmem and direct mapped pages.
+OTOH, if there is a lot of free dma pages, it is preferable to satisfy
+regular memory requests by allocating one from the dma pool, instead
+of incurring the overhead of regular zone balancing.
+
+In 2.2, memory balancing/page reclamation would kick off only when the
+_total_ number of free pages fell below 1/64 th of total memory. With the
+right ratio of dma and regular memory, it is quite possible that balancing
+would not be done even when the dma zone was completely empty. 2.2 has
+been running production machines of varying memory sizes, and seems to be
+doing fine even with the presence of this problem. In 2.3, due to
+HIGHMEM, this problem is aggravated.
+
+In 2.3, zone balancing can be done in one of two ways: depending on the
+zone size (and possibly of the size of lower class zones), we can decide
+at init time how many free pages we should aim for while balancing any
+zone. The good part is, while balancing, we do not need to look at sizes
+of lower class zones, the bad part is, we might do too frequent balancing
+due to ignoring possibly lower usage in the lower class zones. Also,
+with a slight change in the allocation routine, it is possible to reduce
+the memclass() macro to be a simple equality.
+
+Another possible solution is that we balance only when the free memory
+of a zone _and_ all its lower class zones falls below 1/64th of the
+total memory in the zone and its lower class zones. This fixes the 2.2
+balancing problem, and stays as close to 2.2 behavior as possible. Also,
+the balancing algorithm works the same way on the various architectures,
+which have different numbers and types of zones. If we wanted to get
+fancy, we could assign different weights to free pages in different
+zones in the future.
+
+Note that if the size of the regular zone is huge compared to dma zone,
+it becomes less significant to consider the free dma pages while
+deciding whether to balance the regular zone. The first solution
+becomes more attractive then.
+
+The appended patch implements the second solution. It also "fixes" two
+problems: first, kswapd is woken up as in 2.2 on low memory conditions
+for non-sleepable allocations. Second, the HIGHMEM zone is also balanced,
+so as to give a fighting chance for replace_with_highmem() to get a
+HIGHMEM page, as well as to ensure that HIGHMEM allocations do not
+fall back into regular zone. This also makes sure that HIGHMEM pages
+are not leaked (for example, in situations where a HIGHMEM page is in 
+the swapcache but is not being used by anyone)
+
+kswapd also needs to know about the zones it should balance. kswapd is
+primarily needed in a situation where balancing can not be done, 
+probably because all allocation requests are coming from intr context
+and all process contexts are sleeping. For 2.3, kswapd does not really
+need to balance the highmem zone, since intr context does not request
+highmem pages. So as not to spend too much time searching for the zones
+that need balancing (specially in a numa or discontig machine with multiple
+zones), kswapd expects to see the zones that it needs to balance in a list.
+Page alloc requests add zones to the list, kswapd deletes zones from the
+list once they are balanced (kswapd could also delete zones from the list
+once it has had a go at it, whether the zone ends up balanced or not), and
+kswapd scans the list without the list lock.
+
+Page stealing from process memory and shm is done if stealing the page would
+alleviate memory pressure on any zone in the page's node that has fallen below
+its watermark.
+
+(Good) Ideas that I have heard:
+1. Dynamic experience should influence balancing: number of failed requests
+for a zone can be tracked and fed into the balancing scheme (jalvo@mbay.net)
+2. Implement a replace_with_highmem()-like replace_with_regular() to preserve
+dma pages. (lkd@tantalophile.demon.co.uk)
--- fs/dcache.c	Tue Jan 11 11:00:25 2000
+++ fs/dcache.c	Thu Jan 13 13:59:18 2000
@@ -412,20 +412,18 @@
  */
 int shrink_dcache_memory(int priority, unsigned int gfp_mask, zone_t * zone)
 {
-	if (gfp_mask & __GFP_IO) {
-		int count = 0;
-		lock_kernel();
-		if (priority)
-			count = dentry_stat.nr_unused / priority;
-		prune_dcache(count);
-		unlock_kernel();
-		/* FIXME: kmem_cache_shrink here should tell us
-		   the number of pages freed, and it should
-		   work in a __GFP_DMA/__GFP_HIGHMEM behaviour
-		   to free only the interesting pages in
-		   function of the needs of the current allocation. */
-		kmem_cache_shrink(dentry_cache);
-	}
+	int count = 0;
+	lock_kernel();
+	if (priority)
+		count = dentry_stat.nr_unused / priority;
+	prune_dcache(count);
+	unlock_kernel();
+	/* FIXME: kmem_cache_shrink here should tell us
+	   the number of pages freed, and it should
+	   work in a __GFP_DMA/__GFP_HIGHMEM behaviour
+	   to free only the interesting pages in
+	   function of the needs of the current allocation. */
+	kmem_cache_shrink(dentry_cache);
 
 	return 0;
 }
--- fs/inode.c	Tue Jan 11 11:00:25 2000
+++ fs/inode.c	Thu Jan 13 13:59:34 2000
@@ -398,20 +398,17 @@
 
 int shrink_icache_memory(int priority, int gfp_mask, zone_t *zone)
 {
-	if (gfp_mask & __GFP_IO)
-	{
-		int count = 0;
+	int count = 0;
 		
-		if (priority)
-			count = inodes_stat.nr_unused / priority;
-		prune_icache(count);
-		/* FIXME: kmem_cache_shrink here should tell us
-		   the number of pages freed, and it should
-		   work in a __GFP_DMA/__GFP_HIGHMEM behaviour
-		   to free only the interesting pages in
-		   function of the needs of the current allocation. */
-		kmem_cache_shrink(inode_cachep);
-	}
+	if (priority)
+		count = inodes_stat.nr_unused / priority;
+	prune_icache(count);
+	/* FIXME: kmem_cache_shrink here should tell us
+	   the number of pages freed, and it should
+	   work in a __GFP_DMA/__GFP_HIGHMEM behaviour
+	   to free only the interesting pages in
+	   function of the needs of the current allocation. */
+	kmem_cache_shrink(inode_cachep);
 
 	return 0;
 }
--- include/linux/mmzone.h	Tue Jan 11 11:00:28 2000
+++ include/linux/mmzone.h	Fri Jan 14 15:59:18 2000
@@ -7,6 +7,7 @@
 #include <linux/config.h>
 #include <linux/spinlock.h>
 #include <linux/list.h>
+#include <asm/bitops.h>
 
 /*
  * Free memory management - zoned buddy allocator.
@@ -37,6 +38,7 @@
 	int low_on_memory;
 	unsigned long pages_low, pages_high;
 	struct pglist_data *zone_pgdat;
+	struct list_head balance_list;
 
 	/*
 	 * free areas of different sizes
@@ -80,13 +82,24 @@
 	struct page *node_mem_map;
 	unsigned long *valid_addr_bitmap;
 	struct bootmem_data *bdata;
+	unsigned int balance_mask;
 } pg_data_t;
 
 extern int numnodes;
+extern struct list_head global_balance_list;
 
+#define zone_index(zone)	((zone) - (zone)->zone_pgdat->node_zones)
+#define zone_mask(zone)		(1 << zone_index(zone))
 #define memclass(pgzone, tzone)	(((pgzone)->zone_pgdat == (tzone)->zone_pgdat) \
-			&& (((pgzone) - (pgzone)->zone_pgdat->node_zones) <= \
-			((tzone) - (pgzone)->zone_pgdat->node_zones)))
+				&& (zone_index(pgzone) <= zone_index(tzone)))
+#define MARK_ZONE_UNBALANCED(zone) \
+		set_bit(zone_index(zone), &(zone)->zone_pgdat->balance_mask)
+#define MARK_ZONE_BALANCED(zone) \
+		clear_bit(zone_index(zone), &(zone)->zone_pgdat->balance_mask)
+#define PG_ZONE_BALANCED(zone) \
+			(zone_mask(zone) > (zone)->zone_pgdat->balance_mask)
+
+extern int zone_balance_memory(zone_t *zone, int gfp_mask);
 
 #ifndef CONFIG_DISCONTIGMEM
 
--- ipc/shm.c	Tue Jan 11 11:00:31 2000
+++ ipc/shm.c	Fri Jan 14 14:57:55 2000
@@ -958,7 +958,7 @@
 	if (!pte_present(page))
 		goto check_table;
 	page_map = pte_page(page);
-	if (zone && (!memclass(page_map->zone, zone)))
+	if (PG_ZONE_BALANCED(page_map->zone))
 		goto check_table;
 	swap_attempts++;
 
--- mm/page_alloc.c	Tue Jan 11 11:00:31 2000
+++ mm/page_alloc.c	Fri Jan 14 15:32:40 2000
@@ -6,6 +6,7 @@
  *  Support of BIGMEM added by Gerhard Wichert, Siemens AG, July 1999
  *  Reshaped it to be a zoned allocator, Ingo Molnar, Red Hat, 1999
  *  Discontiguous memory support, Kanoj Sarcar, SGI, Nov 1999
+ *  Zone balancing, Kanoj Sarcar, SGI, Jan 2000
  */
 
 #include <linux/config.h>
@@ -194,26 +195,84 @@
 	return NULL;
 }
 
+static spinlock_t balance_lock = SPIN_LOCK_UNLOCKED;
+
+static inline void del_balance_list(zone_t *zone, int gfp_mask)
+{
+	unsigned long flags;
+
+	/*
+	 * Only kswapd deletes.
+	 */
+	if (gfp_mask != GFP_KSWAPD) return;
+	spin_lock_irqsave(&balance_lock, flags);
+	if (!list_empty(&zone->balance_list)) {
+		list_del(&zone->balance_list);
+		INIT_LIST_HEAD(&zone->balance_list);
+	}
+	spin_unlock_irqrestore(&balance_lock, flags);
+}
+
+static inline void add_balance_list(zone_t *zone, int gfp_mask)
+{
+	unsigned long flags;
+
+	/*
+	 * kswapd never adds.
+	 */
+	if (gfp_mask == GFP_KSWAPD) return;
+	spin_lock_irqsave(&balance_lock, flags);
+	if (list_empty(&zone->balance_list)) {
+		list_add_tail(&zone->balance_list, &global_balance_list);
+	}
+	spin_unlock_irqrestore(&balance_lock, flags);
+}
+
+static inline unsigned long classfree(zone_t *zone)
+{
+	unsigned long free = 0;
+	zone_t *z = zone->zone_pgdat->node_zones;
+
+	while (z != zone) {
+		free += z->free_pages;
+		z++;
+	}
+	free += zone->free_pages;
+	return(free);
+}
+
 #define ZONE_BALANCED(zone) \
 	(((zone)->free_pages > (zone)->pages_low) && (!(zone)->low_on_memory))
 
-static inline int zone_balance_memory (zone_t *zone, int gfp_mask)
+int zone_balance_memory (zone_t *zone, int gfp_mask)
 {
 	int freed;
+	unsigned long flags;
+	unsigned long free = classfree(zone);
 
-	if (zone->free_pages >= zone->pages_low) {
-		if (!zone->low_on_memory)
+	spin_lock_irqsave(&zone->lock, flags);
+	if (free >= zone->pages_low) {
+		if (!zone->low_on_memory) {
+			spin_unlock_irqrestore(&zone->lock, flags);
 			return 1;
+		}
 		/*
 		 * Simple hysteresis: exit 'low memory mode' if
 		 * the upper limit has been reached:
 		 */
-		if (zone->free_pages >= zone->pages_high) {
+		if (free >= zone->pages_high) {
 			zone->low_on_memory = 0;
+			del_balance_list(zone, gfp_mask);
+			MARK_ZONE_BALANCED(zone);
+			spin_unlock_irqrestore(&zone->lock, flags);
 			return 1;
 		}
-	} else
+	} else {
+		add_balance_list(zone, gfp_mask);
+		MARK_ZONE_UNBALANCED(zone);
 		zone->low_on_memory = 1;
+	}
+	spin_unlock_irqrestore(&zone->lock, flags);
 
 	/*
 	 * In the atomic allocation case we only 'kick' the
@@ -220,12 +279,7 @@
 	 * state machine, but do not try to free pages
 	 * ourselves.
 	 */
-	if (!(gfp_mask & __GFP_WAIT))
-		return 1;
-
-	current->flags |= PF_MEMALLOC;
 	freed = try_to_free_pages(gfp_mask, zone);
-	current->flags &= ~PF_MEMALLOC;
 
 	if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
 		return 0;
@@ -232,6 +286,7 @@
 	return 1;
 }
 
+#if 0
 /*
  * We are still balancing memory in a global way:
  */
@@ -260,17 +315,13 @@
 	 * state machine, but do not try to free pages
 	 * ourselves.
 	 */
-	if (!(gfp_mask & __GFP_WAIT))
-		return 1;
-
-	current->flags |= PF_MEMALLOC;
 	freed = try_to_free_pages(gfp_mask, zone);
-	current->flags &= ~PF_MEMALLOC;
 
 	if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
 		return 0;
 	return 1;
 }
+#endif
 
 /*
  * This is the 'heart' of the zoned buddy allocator:
@@ -340,7 +391,7 @@
  * The main chunk of the balancing code is in this offline branch:
  */
 balance:
-	if (!balance_memory(z, gfp_mask))
+	if (!zone_balance_memory(z, gfp_mask))
 		goto nopage;
 	goto ready;
 }
@@ -513,6 +564,7 @@
 	unsigned long i, j;
 	unsigned long map_size;
 	unsigned int totalpages, offset;
+	unsigned int cumulative = 0;
 
 	totalpages = 0;
 	for (i = 0; i < MAX_NR_ZONES; i++) {
@@ -565,7 +617,7 @@
 	offset = lmem_map - mem_map;	
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		zone_t *zone = pgdat->node_zones + j;
-		unsigned long mask = -1;
+		unsigned long mask;
 		unsigned long size;
 
 		size = zones_size[j];
@@ -579,14 +631,13 @@
 			continue;
 
 		zone->offset = offset;
-		/*
-		 * It's unnecessery to balance the high memory zone
-		 */
-		if (j != ZONE_HIGHMEM) {
-			zone->pages_low = freepages.low;
-			zone->pages_high = freepages.high;
-		}
+		cumulative += size;
+		mask = (cumulative >> 7);
+		if (mask < 1) mask = 1;
+		zone->pages_low = mask*2;
+		zone->pages_high = mask*3;
 		zone->low_on_memory = 0;
+		INIT_LIST_HEAD(&zone->balance_list);
 
 		for (i = 0; i < size; i++) {
 			struct page *page = mem_map + offset + i;
@@ -598,6 +649,7 @@
 		}
 
 		offset += size;
+		mask = -1;
 		for (i = 0; i < MAX_ORDER; i++) {
 			unsigned long bitmap_size;
 
--- mm/vmscan.c	Tue Jan 11 11:00:31 2000
+++ mm/vmscan.c	Fri Jan 14 15:00:39 2000
@@ -8,6 +8,7 @@
  *  Removed kswapd_ctl limits, and swap out as many pages as needed
  *  to bring the system back to freepages.high: 2.4.97, Rik van Riel.
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
+ *  Zone balancing, Kanoj Sarcar, SGI, Jan 2000
  */
 
 #include <linux/slab.h>
@@ -58,9 +59,7 @@
 		goto out_failed;
 	}
 
-	if (PageReserved(page)
-	    || PageLocked(page)
-	    || (zone && (!memclass(page->zone, zone))))
+	if (PageReserved(page) || PageLocked(page) || PG_ZONE_BALANCED(page->zone))
 		goto out_failed;
 
 	/*
@@ -424,16 +423,19 @@
 				goto done;
 		}
 
-		/* don't be too light against the d/i cache since
-		   shrink_mmap() almost never fail when there's
-		   really plenty of memory free. */
-		count -= shrink_dcache_memory(priority, gfp_mask, zone);
-		count -= shrink_icache_memory(priority, gfp_mask, zone);
-		if (count <= 0)
-			goto done;
-
-		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
+
+			/* 
+			 * don't be too light against the d/i cache since
+		   	 * shrink_mmap() almost never fail when there's
+		   	 * really plenty of memory free. 
+			 */
+			count -= shrink_dcache_memory(priority, gfp_mask, zone);
+			count -= shrink_icache_memory(priority, gfp_mask, zone);
+			if (count <= 0)
+				goto done;
+
+			/* Try to get rid of some shared memory pages.. */
 			while (shm_swap(priority, gfp_mask, zone)) {
 				if (!--count)
 					goto done;
@@ -467,8 +469,13 @@
  * If there are applications that are active memory-allocators
  * (most normal use), this basically shouldn't matter.
  */
+
+struct list_head global_balance_list = LIST_HEAD_INIT(global_balance_list);
+
 int kswapd(void *unused)
 {
+	zone_t	*zone;
+	struct list_head *lhd;
 	struct task_struct *tsk = current;
 
 	kswapd_process = tsk;
@@ -489,7 +496,6 @@
 	 * us from recursively trying to free more memory as we're
 	 * trying to free the first piece of memory in the first place).
 	 */
-	tsk->flags |= PF_MEMALLOC;
 
 	while (1) {
 		/*
@@ -503,10 +509,18 @@
 		do {
 			/* kswapd is critical to provide GFP_ATOMIC
 			   allocations (not GFP_HIGHMEM ones). */
-			if (nr_free_buffer_pages() >= freepages.high)
-				break;
-			if (!do_try_to_free_pages(GFP_KSWAPD, 0))
-				break;
+			/*
+			 * kswapd can scan the chain witout lock since
+			 * it is the only chain deleter. New elements
+			 * are added at end of list.
+			 */
+			lhd = global_balance_list.next;
+			while (lhd != &global_balance_list) {
+				zone = list_entry(lhd, zone_t, balance_list);
+				lhd = lhd->next;
+				zone_balance_memory(zone, GFP_KSWAPD);
+			}
+			tsk->flags |= PF_MEMALLOC;
 			run_task_queue(&tq_disk);
 		} while (!tsk->need_resched);
 		tsk->state = TASK_INTERRUPTIBLE;
@@ -533,9 +547,13 @@
 {
 	int retval = 1;
 
-	wake_up_process(kswapd_process);
-	if (gfp_mask & __GFP_WAIT)
+	if (gfp_mask != GFP_KSWAPD)
+		wake_up_process(kswapd_process);
+	if (gfp_mask & __GFP_WAIT) {
+		current->flags |= PF_MEMALLOC;
 		retval = do_try_to_free_pages(gfp_mask, zone);
+		current->flags &= ~PF_MEMALLOC;
+	}
 	return retval;
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
