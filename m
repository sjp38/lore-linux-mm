Date: Wed, 26 Apr 2000 10:36:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: [patch] 2.3.99-pre6-3 VM fixed
Message-ID: <Pine.LNX.4.21.0004261022260.16202-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hi,

The attached patch should fix most of the VM performance problems
2.3 was having. It does the following things:

- have a global lru queue for shrink_mmap(), so balancing
  between zones is achieved
- protection against memory hogs, by scanning memory hogs
  more agressively than other processes in swap_out()
	- agressiveness (A:B) = sqrt (size A: size B)
              [very rough approximation used in the code]
	- if there is memory pressure, the biggest processes
	  will call swap_out() before doing a memory allocation,
          this will keep enough freeable pages in the LRU queue
	  to make life for kswapd easy and let small processes
	  run fast
- since the memory of memory hogs is scanned more agressively
  and more of the hog's pages end up on the lru queue, page
  aging for the memory hog is better ... this often results in
  better performance for the memory hog too
- the LRU queue aging in shrink_mmap() is improved a bit


The patch runs great in a variety of workloads I've tested here,
but of course I'm not sure if it works as good as it should in
*your* workload, so testing is wanted/needed/appreciated...

TODO:
- make the "anti hog" code sysctl switchable if it turns out
  that performance of some memory hogs gets less because of
  the anti hog measures

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.3.99-pre6-3/mm/filemap.c.orig	Mon Apr 17 12:21:46 2000
+++ linux-2.3.99-pre6-3/mm/filemap.c	Tue Apr 25 18:39:29 2000
@@ -44,6 +44,7 @@
 atomic_t page_cache_size = ATOMIC_INIT(0);
 unsigned int page_hash_bits;
 struct page **page_hash_table;
+struct list_head lru_cache;
 
 spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
 /*
@@ -149,11 +150,16 @@
 
 		/* page wholly truncated - free it */
 		if (offset >= start) {
+			if (TryLockPage(page)) {
+				spin_unlock(&pagecache_lock);
+				get_page(page);
+				wait_on_page(page);
+				put_page(page);
+				goto repeat;
+			}
 			get_page(page);
 			spin_unlock(&pagecache_lock);
 
-			lock_page(page);
-
 			if (!page->buffers || block_flushpage(page, 0))
 				lru_cache_del(page);
 
@@ -191,11 +197,13 @@
 			continue;
 
 		/* partial truncate, clear end of page */
+		if (TryLockPage(page)) {
+			spin_unlock(&pagecache_lock);
+			goto repeat;
+		}
 		get_page(page);
 		spin_unlock(&pagecache_lock);
 
-		lock_page(page);
-
 		memclear_highpage_flush(page, partial, PAGE_CACHE_SIZE-partial);
 		if (page->buffers)
 			block_flushpage(page, partial);
@@ -208,6 +216,9 @@
 		 */
 		UnlockPage(page);
 		page_cache_release(page);
+		get_page(page);
+		wait_on_page(page);
+		put_page(page);
 		goto repeat;
 	}
 	spin_unlock(&pagecache_lock);
@@ -215,46 +226,61 @@
 
 int shrink_mmap(int priority, int gfp_mask, zone_t *zone)
 {
-	int ret = 0, count;
+	int ret = 0, loop = 0, count;
 	LIST_HEAD(young);
 	LIST_HEAD(old);
 	LIST_HEAD(forget);
 	struct list_head * page_lru, * dispose;
-	struct page * page;
-
+	struct page * page = NULL;
+	struct zone_struct * p_zone;
+	int maxloop = 256 >> priority;
+	
 	if (!zone)
 		BUG();
 
-	count = nr_lru_pages / (priority+1);
+	/* the first term should be very small when nr_lru_pages is small */
+	/*
+	count = (10 * nr_lru_pages * nr_lru_pages) / num_physpages;
+	count += nr_lru_pages;
+	count >>= priority;
+	*/
+	count = nr_lru_pages >> priority;
+	if (!count)
+		return ret;
 
 	spin_lock(&pagemap_lru_lock);
-
-	while (count > 0 && (page_lru = zone->lru_cache.prev) != &zone->lru_cache) {
+again:
+	/* we need pagemap_lru_lock for list_del() ... subtle code below */
+	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
+		p_zone = page->zone;
 
-		dispose = &zone->lru_cache;
-		if (test_and_clear_bit(PG_referenced, &page->flags))
-			/* Roll the page at the top of the lru list,
-			 * we could also be more aggressive putting
-			 * the page in the young-dispose-list, so
-			 * avoiding to free young pages in each pass.
-			 */
-			goto dispose_continue;
-
+		/*
+		 * These two tests are there to make sure we don't free too
+		 * many pages from the "wrong" zone. We free some anyway,
+		 * they are the least recently used pages in the system.
+		 * When we don't free them, leave them in &old.
+		 */
 		dispose = &old;
-		/* don't account passes over not DMA pages */
-		if (zone && (!memclass(page->zone, zone)))
+		if (p_zone != zone && (loop > (maxloop / 4) ||
+				p_zone->free_pages > p_zone->pages_high))
 			goto dispose_continue;
 
+		/* The page is in use, or was used very recently, put it in
+		 * &young to make sure that we won't try to free it the next
+		 * time */
 		count--;
-
 		dispose = &young;
-
-		/* avoid unscalable SMP locking */
 		if (!page->buffers && page_count(page) > 1)
 			goto dispose_continue;
 
+		/* Only count pages that have a chance of being freeable */
+		if (test_and_clear_bit(PG_referenced, &page->flags))
+			goto dispose_continue;
+
+		/* Page not used -> free it; if that fails -> &old */
+		dispose = &old;
 		if (TryLockPage(page))
 			goto dispose_continue;
 
@@ -327,6 +353,7 @@
 		list_add(page_lru, dispose);
 		continue;
 
+		/* we're holding pagemap_lru_lock, so we can just loop again */
 dispose_continue:
 		list_add(page_lru, dispose);
 	}
@@ -342,9 +369,14 @@
 	/* nr_lru_pages needs the spinlock */
 	nr_lru_pages--;
 
+	loop++;
+	/* wrong zone?  not looped too often?    roll again... */
+	if (page->zone != zone && loop < maxloop)
+		goto again;
+
 out:
-	list_splice(&young, &zone->lru_cache);
-	list_splice(&old, zone->lru_cache.prev);
+	list_splice(&young, &lru_cache);
+	list_splice(&old, lru_cache.prev);
 
 	spin_unlock(&pagemap_lru_lock);
 
--- linux-2.3.99-pre6-3/mm/page_alloc.c.orig	Mon Apr 17 12:21:46 2000
+++ linux-2.3.99-pre6-3/mm/page_alloc.c	Wed Apr 26 08:35:01 2000
@@ -25,7 +25,7 @@
 #endif
 
 int nr_swap_pages = 0;
-int nr_lru_pages;
+int nr_lru_pages = 0;
 pg_data_t *pgdat_list = (pg_data_t *)0;
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
@@ -33,6 +33,7 @@
 static int zone_balance_min[MAX_NR_ZONES] = { 10 , 10, 10, };
 static int zone_balance_max[MAX_NR_ZONES] = { 255 , 255, 255, };
 
+extern int swap_out(unsigned int, int);
 /*
  * Free_page() adds the page to the free lists. This is optimized for
  * fast normal cases (no error jumps taken normally).
@@ -273,6 +274,7 @@
 struct page * __alloc_pages(zonelist_t *zonelist, unsigned long order)
 {
 	zone_t **zone = zonelist->zones;
+	int gfp_mask = zonelist->gfp_mask;
 
 	/*
 	 * If this is a recursive call, we'd better
@@ -282,6 +284,13 @@
 	if (current->flags & PF_MEMALLOC)
 		goto allocate_ok;
 
+	/* If we're a memory hog, unmap some pages */
+	if (current->hog && (gfp_mask & __GFP_WAIT)) {
+		zone_t *z = *zone;
+	       	if (z->zone_wake_kswapd)
+			swap_out(6, gfp_mask);
+	}
+
 	/*
 	 * (If anyone calls gfp from interrupts nonatomically then it
 	 * will sooner or later tripped up by a schedule().)
@@ -530,6 +539,7 @@
 	freepages.min += i;
 	freepages.low += i * 2;
 	freepages.high += i * 3;
+	memlist_init(&lru_cache);
 
 	/*
 	 * Some architectures (with lots of mem and discontinous memory
@@ -609,7 +619,6 @@
 			unsigned long bitmap_size;
 
 			memlist_init(&zone->free_area[i].free_list);
-			memlist_init(&zone->lru_cache);
 			mask += mask;
 			size = (size + ~mask) & mask;
 			bitmap_size = size >> i;
--- linux-2.3.99-pre6-3/mm/vmscan.c.orig	Mon Apr 17 12:21:46 2000
+++ linux-2.3.99-pre6-3/mm/vmscan.c	Wed Apr 26 07:39:53 2000
@@ -34,7 +34,7 @@
  * using a process that no longer actually exists (it might
  * have died while we slept).
  */
-static int try_to_swap_out(struct vm_area_struct* vma, unsigned long address, pte_t * page_table, int gfp_mask)
+static int try_to_swap_out(struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, int gfp_mask)
 {
 	pte_t pte;
 	swp_entry_t entry;
@@ -48,6 +48,7 @@
 	if ((page-mem_map >= max_mapnr) || PageReserved(page))
 		goto out_failed;
 
+	mm->swap_cnt--;
 	/* Don't look at this pte if it's been accessed recently. */
 	if (pte_young(pte)) {
 		/*
@@ -194,7 +195,7 @@
  * (C) 1993 Kai Petzke, wpp@marie.physik.tu-berlin.de
  */
 
-static inline int swap_out_pmd(struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+static inline int swap_out_pmd(struct mm_struct * mm, struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
 {
 	pte_t * pte;
 	unsigned long pmd_end;
@@ -216,16 +217,18 @@
 	do {
 		int result;
 		vma->vm_mm->swap_address = address + PAGE_SIZE;
-		result = try_to_swap_out(vma, address, pte, gfp_mask);
+		result = try_to_swap_out(mm, vma, address, pte, gfp_mask);
 		if (result)
 			return result;
+		if (!mm->swap_cnt)
+			return 0;
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
 	return 0;
 }
 
-static inline int swap_out_pgd(struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+static inline int swap_out_pgd(struct mm_struct * mm, struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
 {
 	pmd_t * pmd;
 	unsigned long pgd_end;
@@ -245,16 +248,18 @@
 		end = pgd_end;
 	
 	do {
-		int result = swap_out_pmd(vma, pmd, address, end, gfp_mask);
+		int result = swap_out_pmd(mm, vma, pmd, address, end, gfp_mask);
 		if (result)
 			return result;
+		if (!mm->swap_cnt)
+			return 0;
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
 	return 0;
 }
 
-static int swap_out_vma(struct vm_area_struct * vma, unsigned long address, int gfp_mask)
+static int swap_out_vma(struct mm_struct * mm, struct vm_area_struct * vma, unsigned long address, int gfp_mask)
 {
 	pgd_t *pgdir;
 	unsigned long end;
@@ -269,9 +274,11 @@
 	if (address >= end)
 		BUG();
 	do {
-		int result = swap_out_pgd(vma, pgdir, address, end, gfp_mask);
+		int result = swap_out_pgd(mm, vma, pgdir, address, end, gfp_mask);
 		if (result)
 			return result;
+		if (!mm->swap_cnt)
+			return 0;
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		pgdir++;
 	} while (address && (address < end));
@@ -299,7 +306,7 @@
 			address = vma->vm_start;
 
 		for (;;) {
-			int result = swap_out_vma(vma, address, gfp_mask);
+			int result = swap_out_vma(mm, vma, address, gfp_mask);
 			if (result)
 				return result;
 			vma = vma->vm_next;
@@ -321,7 +328,7 @@
  * N.B. This function returns only 0 or 1.  Return values != 1 from
  * the lower level routines result in continued processing.
  */
-static int swap_out(unsigned int priority, int gfp_mask)
+int swap_out(unsigned int priority, int gfp_mask)
 {
 	struct task_struct * p;
 	int counter;
@@ -369,9 +376,28 @@
 				pid = p->pid;
 			}
 		}
-		read_unlock(&tasklist_lock);
-		if (assign == 1)
+		if (assign == 1) {
+			/* we just assigned swap_cnt, normalise values */
 			assign = 2;
+			p = init_task.next_task;
+			for (; p != &init_task; p = p->next_task) {
+				int i = 0;
+				struct mm_struct *mm = p->mm;
+				if (!p->swappable || !mm || mm->rss <= 0)
+					continue;
+				/* small processes are swapped out less */
+				while ((mm->swap_cnt << 2 * (i + 1) < max_cnt))
+					i++;
+				mm->swap_cnt >>= i;
+				mm->swap_cnt += i; /* in case we reach 0 */
+				/* we're big -> hog treatment */
+				if (!i)
+					p->hog = 1;
+				else
+					p->hog = 0;
+			}
+		}
+		read_unlock(&tasklist_lock);
 		if (!best) {
 			if (!assign) {
 				assign = 1;
@@ -412,13 +438,16 @@
 {
 	int priority;
 	int count = SWAP_CLUSTER_MAX;
+	int swapcount = SWAP_CLUSTER_MAX;
+	int ret;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
 	priority = 6;
 	do {
-		while (shrink_mmap(priority, gfp_mask, zone)) {
+free_more:
+		while ((ret = shrink_mmap(priority, gfp_mask, zone))) {
 			if (!--count)
 				goto done;
 		}
@@ -441,9 +470,13 @@
 			}
 		}
 
-		/* Then, try to page stuff out.. */
+		/* Then, try to page stuff out..
+		 * We use swapcount here because this doesn't actually
+		 * free pages */
 		while (swap_out(priority, gfp_mask)) {
-			if (!--count)
+			if (!--swapcount)
+				if (count)
+					goto free_more;
 				goto done;
 		}
 	} while (--priority >= 0);
--- linux-2.3.99-pre6-3/include/linux/mm.h.orig	Mon Apr 17 12:22:22 2000
+++ linux-2.3.99-pre6-3/include/linux/mm.h	Wed Apr 26 07:40:34 2000
@@ -15,6 +15,7 @@
 extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
+extern struct list_head lru_cache;
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
--- linux-2.3.99-pre6-3/include/linux/mmzone.h.orig	Mon Apr 17 12:22:22 2000
+++ linux-2.3.99-pre6-3/include/linux/mmzone.h	Sat Apr 22 16:13:02 2000
@@ -31,7 +31,6 @@
 	char			low_on_memory;
 	char			zone_wake_kswapd;
 	unsigned long		pages_min, pages_low, pages_high;
-	struct list_head	lru_cache;
 
 	/*
 	 * free areas of different sizes
--- linux-2.3.99-pre6-3/include/linux/sched.h.orig	Mon Apr 17 12:22:23 2000
+++ linux-2.3.99-pre6-3/include/linux/sched.h	Wed Apr 26 07:26:57 2000
@@ -321,6 +321,7 @@
 /* mm fault and swap info: this can arguably be seen as either mm-specific or thread-specific */
 	unsigned long min_flt, maj_flt, nswap, cmin_flt, cmaj_flt, cnswap;
 	int swappable:1;
+	int hog:1;
 /* process credentials */
 	uid_t uid,euid,suid,fsuid;
 	gid_t gid,egid,sgid,fsgid;
--- linux-2.3.99-pre6-3/include/linux/swap.h.orig	Mon Apr 17 12:22:23 2000
+++ linux-2.3.99-pre6-3/include/linux/swap.h	Sat Apr 22 16:19:38 2000
@@ -166,7 +166,7 @@
 #define	lru_cache_add(page)			\
 do {						\
 	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &page->zone->lru_cache);	\
+	list_add(&(page)->lru, &lru_cache);	\
 	nr_lru_pages++;				\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
