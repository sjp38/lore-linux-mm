From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199912151950.LAA59879@google.engr.sgi.com>
Subject: [RFC] [RFT] [PATCH] memory zone balancing
Date: Wed, 15 Dec 1999 11:50:40 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Hi,

Could people try out this patch against 2.3.33 and send comments/feedback.

The patch cleans up the way we do memory balancing in the core page alloc
and free routines. 

Thanks.

Kanoj

--- /usr/tmp/p_rdiff_a000os/dcache.c	Wed Dec 15 11:37:12 1999
+++ fs/dcache.c	Tue Dec 14 21:44:20 1999
@@ -410,7 +410,7 @@
  *  ...
  *   6 - base-level: try to shrink a bit.
  */
-int shrink_dcache_memory(int priority, unsigned int gfp_mask)
+int shrink_dcache_memory(int priority, unsigned int gfp_mask, zone_t * zone)
 {
 	if (gfp_mask & __GFP_IO) {
 		int count = 0;
--- /usr/tmp/p_rdiff_a000p1/inode.c	Wed Dec 15 11:37:20 1999
+++ fs/inode.c	Tue Dec 14 21:45:14 1999
@@ -392,7 +392,7 @@
 	dispose_list(freeable);
 }
 
-int shrink_icache_memory(int priority, int gfp_mask)
+int shrink_icache_memory(int priority, int gfp_mask, zone_t *zone)
 {
 	if (gfp_mask & __GFP_IO)
 	{
--- /usr/tmp/p_rdiff_a000pA/dcache.h	Wed Dec 15 11:37:28 1999
+++ include/linux/dcache.h	Tue Dec 14 22:10:55 1999
@@ -136,13 +136,13 @@
 extern int d_invalidate(struct dentry *);
 
 #define shrink_dcache() prune_dcache(0)
-
+struct zone_struct;
 /* dcache memory management */
-extern int shrink_dcache_memory(int, unsigned int);
+extern int shrink_dcache_memory(int, unsigned int, struct zone_struct *);
 extern void prune_dcache(int);
 
 /* icache memory management (defined in linux/fs/inode.c) */
-extern int shrink_icache_memory(int, int);
+extern int shrink_icache_memory(int, int, struct zone_struct *);
 extern void prune_icache(int);
 
 /* only used at mount-time */
--- /usr/tmp/p_rdiff_a000pJ/mm.h	Wed Dec 15 11:37:36 1999
+++ include/linux/mm.h	Wed Dec 15 11:12:36 1999
@@ -183,7 +183,6 @@
 #define ClearPageError(page)	clear_bit(PG_error, &(page)->flags)
 #define PageReferenced(page)	test_bit(PG_referenced, &(page)->flags)
 #define PageDecrAfter(page)	test_bit(PG_decr_after, &(page)->flags)
-#define PageDMA(page)		(contig_page_data.node_zones + ZONE_DMA == (page)->zone)
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
 #define PageSwapCache(page)	test_bit(PG_swap_cache, &(page)->flags)
 #define PageReserved(page)	test_bit(PG_reserved, &(page)->flags)
@@ -434,10 +433,11 @@
 extern int do_munmap(unsigned long, size_t);
 extern unsigned long do_brk(unsigned long, unsigned long);
 
+struct zone_t;
 /* filemap.c */
 extern void remove_inode_page(struct page *);
 extern unsigned long page_unuse(struct page *);
-extern int shrink_mmap(int, int);
+extern int shrink_mmap(int, int, zone_t *);
 extern void truncate_inode_pages(struct inode *, loff_t);
 
 /*
--- /usr/tmp/p_rdiff_a000pS/swap.h	Wed Dec 15 11:37:43 1999
+++ include/linux/swap.h	Tue Dec 14 22:11:01 1999
@@ -78,14 +78,15 @@
 struct vm_area_struct;
 struct sysinfo;
 
+struct zone_t;
 /* linux/ipc/shm.c */
-extern int shm_swap (int, int);
+extern int shm_swap (int, int, zone_t *);
 
 /* linux/mm/swap.c */
 extern void swap_setup (void);
 
 /* linux/mm/vmscan.c */
-extern int try_to_free_pages(unsigned int gfp_mask);
+extern int try_to_free_pages(unsigned int gfp_mask, zone_t *zone);
 
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, struct page *, int);
--- /usr/tmp/p_rdiff_a000p-/shm.c	Wed Dec 15 11:37:52 1999
+++ ipc/shm.c	Wed Dec 15 02:24:27 1999
@@ -799,7 +799,7 @@
 static unsigned long swap_id = 0; /* currently being swapped */
 static unsigned long swap_idx = 0; /* next to swap */
 
-int shm_swap (int prio, int gfp_mask)
+int shm_swap (int prio, int gfp_mask, zone_t *zone)
 {
 	pte_t page;
 	struct shmid_kernel *shp;
@@ -849,9 +849,7 @@
 	if (!pte_present(page))
 		goto check_table;
 	page_map = pte_page(page);
-	if ((gfp_mask & __GFP_DMA) && !PageDMA(page_map))
-		goto check_table;
-	if (!(gfp_mask & __GFP_HIGHMEM) && PageHighMem(page_map))
+	if (zone && (page_map->zone != zone))
 		goto check_table;
 	swap_attempts++;
 
--- /usr/tmp/p_rdiff_a000pi/util.c	Wed Dec 15 11:38:00 1999
+++ ipc/util.c	Tue Dec 14 21:46:31 1999
@@ -214,7 +214,7 @@
     return;
 }
 
-int shm_swap (int prio, int gfp_mask)
+int shm_swap (int prio, int gfp_mask, zone_t *zone)
 {
     return 0;
 }
--- /usr/tmp/p_rdiff_a000pr/filemap.c	Wed Dec 15 11:38:14 1999
+++ mm/filemap.c	Wed Dec 15 00:23:44 1999
@@ -211,7 +211,7 @@
 	spin_unlock(&pagecache_lock);
 }
 
-int shrink_mmap(int priority, int gfp_mask)
+int shrink_mmap(int priority, int gfp_mask, zone_t *zone)
 {
 	int ret = 0, count;
 	LIST_HEAD(young);
@@ -239,9 +239,7 @@
 
 		dispose = &old;
 		/* don't account passes over not DMA pages */
-		if ((gfp_mask & __GFP_DMA) && !PageDMA(page))
-			goto dispose_continue;
-		if (!(gfp_mask & __GFP_HIGHMEM) && PageHighMem(page))
+		if (zone && (page->zone != zone))
 			goto dispose_continue;
 
 		count--;
--- /usr/tmp/p_rdiff_a000q0/page_alloc.c	Wed Dec 15 11:38:22 1999
+++ mm/page_alloc.c	Wed Dec 15 03:01:00 1999
@@ -224,7 +224,7 @@
 		return 1;
 
 	current->flags |= PF_MEMALLOC;
-	freed = try_to_free_pages(gfp_mask);
+	freed = try_to_free_pages(gfp_mask, zone);
 	current->flags &= ~PF_MEMALLOC;
 
 	if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
@@ -264,7 +264,7 @@
 		return 1;
 
 	current->flags |= PF_MEMALLOC;
-	freed = try_to_free_pages(gfp_mask);
+	freed = try_to_free_pages(gfp_mask, 0);
 	current->flags &= ~PF_MEMALLOC;
 
 	if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
@@ -340,7 +340,7 @@
  * The main chunk of the balancing code is in this offline branch:
  */
 balance:
-	if (!balance_memory(gfp_mask))
+	if (!zone_balance_memory(z, gfp_mask))
 		goto nopage;
 	goto ready;
 }
@@ -533,9 +533,9 @@
 		i = 10;
 	if (i > 256)
 		i = 256;
-	freepages.min = i;
-	freepages.low = i * 2;
-	freepages.high = i * 3;
+	freepages.min += i;
+	freepages.low += i * 2;
+	freepages.high += i * 3;
 
 	/*
 	 * Some architectures (with lots of mem and discontinous memory
@@ -565,10 +565,9 @@
 	offset = lmem_map - mem_map;	
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		zone_t *zone = pgdat->node_zones + j;
-		unsigned long mask = -1;
-		unsigned long size;
+		unsigned long mask, size;
 
-		size = zones_size[j];
+		mask = size = zones_size[j];
 
 		printk("zone(%ld): %ld pages.\n", j, size);
 		zone->size = size;
@@ -578,13 +577,13 @@
 			continue;
 
 		zone->offset = offset;
-		/*
-		 * It's unnecessery to balance the high memory zone
-		 */
-		if (j != ZONE_HIGHMEM) {
-			zone->pages_low = freepages.low;
-			zone->pages_high = freepages.high;
-		}
+		mask = mask >> 7;
+		if (mask < 10)
+			mask = 10;
+		if (mask > 256)
+			mask = 256;
+		zone->pages_low = mask * 2;
+		zone->pages_high = mask * 3;
 		zone->low_on_memory = 0;
 
 		for (i = 0; i < size; i++) {
@@ -597,6 +596,7 @@
 		}
 
 		offset += size;
+		mask = -1;
 		for (i = 0; i < MAX_ORDER; i++) {
 			unsigned long bitmap_size;
 
--- /usr/tmp/p_rdiff_a000q9/slab.c	Wed Dec 15 11:38:38 1999
+++ mm/slab.c	Wed Dec 15 11:25:44 1999
@@ -503,6 +503,11 @@
 {
 	void	*addr;
 
+	/*
+	 * If we requested dmaable memory, we will get it. Even if we 
+	 * did not request dmaable memory, we might get it, but that
+	 * would be relatively rare and ignorable.
+	 */
 	*dma = flags & SLAB_DMA;
 	addr = (void*) __get_free_pages(flags, cachep->c_gfporder);
 	/* Assume that now we have the pages no one else can legally
@@ -511,18 +516,6 @@
 	 * it is a named-page or buffer-page.  The members it tests are
 	 * of no interest here.....
 	 */
-	if (!*dma && addr) {
-		/* Need to check if can dma. */
-		struct page *page = mem_map + MAP_NR(addr);
-		*dma = 1<<cachep->c_gfporder;
-		while ((*dma)--) {
-			if (!PageDMA(page)) {
-				*dma = 0;
-				break;
-			}
-			page++;
-		}
-	}
 	return addr;
 }
 
--- /usr/tmp/p_rdiff_a000qI/vmscan.c	Wed Dec 15 11:38:48 1999
+++ mm/vmscan.c	Wed Dec 15 02:23:07 1999
@@ -33,7 +33,7 @@
  * using a process that no longer actually exists (it might
  * have died while we slept).
  */
-static int try_to_swap_out(struct vm_area_struct* vma, unsigned long address, pte_t * page_table, int gfp_mask)
+static int try_to_swap_out(struct vm_area_struct* vma, unsigned long address, pte_t * page_table, int gfp_mask, zone_t *zone)
 {
 	pte_t pte;
 	swp_entry_t entry;
@@ -60,8 +60,7 @@
 
 	if (PageReserved(page)
 	    || PageLocked(page)
-	    || ((gfp_mask & __GFP_DMA) && !PageDMA(page))
-	    || (!(gfp_mask & __GFP_HIGHMEM) && PageHighMem(page)))
+	    || (zone && (page->zone != zone)))
 		goto out_failed;
 
 	/*
@@ -195,7 +194,7 @@
  * (C) 1993 Kai Petzke, wpp@marie.physik.tu-berlin.de
  */
 
-static inline int swap_out_pmd(struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+static inline int swap_out_pmd(struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask, zone_t *zone)
 {
 	pte_t * pte;
 	unsigned long pmd_end;
@@ -217,7 +216,7 @@
 	do {
 		int result;
 		vma->vm_mm->swap_address = address + PAGE_SIZE;
-		result = try_to_swap_out(vma, address, pte, gfp_mask);
+		result = try_to_swap_out(vma, address, pte, gfp_mask, zone);
 		if (result)
 			return result;
 		address += PAGE_SIZE;
@@ -226,7 +225,7 @@
 	return 0;
 }
 
-static inline int swap_out_pgd(struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+static inline int swap_out_pgd(struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask, zone_t *zone)
 {
 	pmd_t * pmd;
 	unsigned long pgd_end;
@@ -246,7 +245,7 @@
 		end = pgd_end;
 	
 	do {
-		int result = swap_out_pmd(vma, pmd, address, end, gfp_mask);
+		int result = swap_out_pmd(vma, pmd, address, end, gfp_mask, zone);
 		if (result)
 			return result;
 		address = (address + PMD_SIZE) & PMD_MASK;
@@ -255,7 +254,7 @@
 	return 0;
 }
 
-static int swap_out_vma(struct vm_area_struct * vma, unsigned long address, int gfp_mask)
+static int swap_out_vma(struct vm_area_struct * vma, unsigned long address, int gfp_mask, zone_t *zone)
 {
 	pgd_t *pgdir;
 	unsigned long end;
@@ -270,7 +269,7 @@
 	if (address >= end)
 		BUG();
 	do {
-		int result = swap_out_pgd(vma, pgdir, address, end, gfp_mask);
+		int result = swap_out_pgd(vma, pgdir, address, end, gfp_mask, zone);
 		if (result)
 			return result;
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
@@ -279,7 +278,7 @@
 	return 0;
 }
 
-static int swap_out_mm(struct mm_struct * mm, int gfp_mask)
+static int swap_out_mm(struct mm_struct * mm, int gfp_mask, zone_t *zone)
 {
 	unsigned long address;
 	struct vm_area_struct* vma;
@@ -300,7 +299,7 @@
 			address = vma->vm_start;
 
 		for (;;) {
-			int result = swap_out_vma(vma, address, gfp_mask);
+			int result = swap_out_vma(vma, address, gfp_mask, zone);
 			if (result)
 				return result;
 			vma = vma->vm_next;
@@ -322,7 +321,7 @@
  * N.B. This function returns only 0 or 1.  Return values != 1 from
  * the lower level routines result in continued processing.
  */
-static int swap_out(unsigned int priority, int gfp_mask)
+static int swap_out(unsigned int priority, int gfp_mask, zone_t *zone)
 {
 	struct task_struct * p;
 	int counter;
@@ -383,7 +382,7 @@
 			int ret;
 
 			atomic_inc(&best->mm_count);
-			ret = swap_out_mm(best, gfp_mask);
+			ret = swap_out_mm(best, gfp_mask, zone);
 			mmdrop(best);
 
 			if (!ret)
@@ -409,7 +408,7 @@
  * cluster them so that we get good swap-out behaviour. See
  * the "free_memory()" macro for details.
  */
-static int do_try_to_free_pages(unsigned int gfp_mask)
+static int do_try_to_free_pages(unsigned int gfp_mask, zone_t *zone)
 {
 	int priority;
 	int count = SWAP_CLUSTER_MAX;
@@ -419,7 +418,7 @@
 
 	priority = 6;
 	do {
-		while (shrink_mmap(priority, gfp_mask)) {
+		while (shrink_mmap(priority, gfp_mask, zone)) {
 			if (!--count)
 				goto done;
 		}
@@ -427,14 +426,14 @@
 		/* don't be too light against the d/i cache since
 		   shrink_mmap() almost never fail when there's
 		   really plenty of memory free. */
-		count -= shrink_dcache_memory(priority, gfp_mask);
-		count -= shrink_icache_memory(priority, gfp_mask);
+		count -= shrink_dcache_memory(priority, gfp_mask, zone);
+		count -= shrink_icache_memory(priority, gfp_mask, zone);
 		if (count <= 0)
 			goto done;
 
 		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
-			while (shm_swap(priority, gfp_mask)) {
+			while (shm_swap(priority, gfp_mask, zone)) {
 				if (!--count)
 					goto done;
 			}
@@ -441,7 +440,7 @@
 		}
 
 		/* Then, try to page stuff out.. */
-		while (swap_out(priority, gfp_mask)) {
+		while (swap_out(priority, gfp_mask, zone)) {
 			if (!--count)
 				goto done;
 		}
@@ -505,7 +504,7 @@
 			   allocations (not GFP_HIGHMEM ones). */
 			if (nr_free_buffer_pages() >= freepages.high)
 				break;
-			if (!do_try_to_free_pages(GFP_KSWAPD))
+			if (!do_try_to_free_pages(GFP_KSWAPD, 0))
 				break;
 			run_task_queue(&tq_disk);
 		} while (!tsk->need_resched);
@@ -529,13 +528,13 @@
  * can be done by just dropping cached pages without having
  * any deadlock issues.
  */
-int try_to_free_pages(unsigned int gfp_mask)
+int try_to_free_pages(unsigned int gfp_mask, zone_t *zone)
 {
 	int retval = 1;
 
 	wake_up_process(kswapd_process);
 	if (gfp_mask & __GFP_WAIT)
-		retval = do_try_to_free_pages(gfp_mask);
+		retval = do_try_to_free_pages(gfp_mask, zone);
 	return retval;
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
