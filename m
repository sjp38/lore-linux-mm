Date: Wed, 26 Apr 2000 19:03:19 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: [PATCH] 2.3.99-pre6-7 VM rebalanced
Message-ID: <Pine.LNX.4.21.0004261900250.16202-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

here's the memory rebalancing patch from this morning, with a
few thinkos (missing braces .. oops) fixed, ported to pre6-7,
with a sysctl switch for the anti hog behaviour and somewhat
more heavily tested on a variety of workloads and with different
memory sizes.

HOWEVER, I'm pretty sure that there must be workloads out there
for which performance with this patch will suck. I've tested
stability and performance in my situation, but haven't spent a
lot of time finetuning for the last few percent yet. I'd really
appreciate it if people could take some time and test this patch
with their workloads on their machines ... every situation is
different and I'd like to ensure reasonable behaviour on every
machine.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.3.99-pre6-7/kernel/sysctl.c.orig	Wed Apr 26 18:24:22 2000
+++ linux-2.3.99-pre6-7/kernel/sysctl.c	Wed Apr 26 18:28:55 2000
@@ -46,6 +46,7 @@
 extern int sysctl_overcommit_memory;
 extern int max_threads;
 extern int nr_queued_signals, max_queued_signals;
+extern int hog_protect;
 
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
@@ -228,6 +229,8 @@
 static ctl_table vm_table[] = {
 	{VM_FREEPG, "freepages", 
 	 &freepages, sizeof(freepages_t), 0644, NULL, &proc_dointvec},
+	{VM_SWAPOUT, "hog_protect",
+	 &hog_protect, sizeof(int), 0644, NULL, &proc_dointvec},
 	{VM_BDFLUSH, "bdflush", &bdf_prm, 9*sizeof(int), 0644, NULL,
 	 &proc_dointvec_minmax, &sysctl_intvec, NULL,
 	 &bdflush_min, &bdflush_max},
--- linux-2.3.99-pre6-7/mm/filemap.c.orig	Wed Apr 26 16:47:01 2000
+++ linux-2.3.99-pre6-7/mm/filemap.c	Wed Apr 26 18:29:13 2000
@@ -44,6 +44,7 @@
 atomic_t page_cache_size = ATOMIC_INIT(0);
 unsigned int page_hash_bits;
 struct page **page_hash_table;
+struct list_head lru_cache;
 
 spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
 /*
@@ -161,11 +162,16 @@
 
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
 
@@ -203,11 +209,13 @@
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
@@ -220,6 +228,9 @@
 		 */
 		UnlockPage(page);
 		page_cache_release(page);
+		get_page(page);
+		wait_on_page(page);
+		put_page(page);
 		goto repeat;
 	}
 	spin_unlock(&pagecache_lock);
@@ -227,46 +238,55 @@
 
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
 
-		count--;
-
+		/* The page is in use, or was used very recently, put it in
+		 * &young to make sure that we won't try to free it the next
+		 * time */
 		dispose = &young;
 
-		/* avoid unscalable SMP locking */
+		if (test_and_clear_bit(PG_referenced, &page->flags))
+			goto dispose_continue;
+
+		count--;
 		if (!page->buffers && page_count(page) > 1)
 			goto dispose_continue;
 
+		/* Page not used -> free it; if that fails -> &old */
+		dispose = &old;
 		if (TryLockPage(page))
 			goto dispose_continue;
 
@@ -339,6 +359,7 @@
 		list_add(page_lru, dispose);
 		continue;
 
+		/* we're holding pagemap_lru_lock, so we can just loop again */
 dispose_continue:
 		list_add(page_lru, dispose);
 	}
@@ -354,9 +375,14 @@
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
 
--- linux-2.3.99-pre6-7/mm/page_alloc.c.orig	Wed Apr 26 18:23:04 2000
+++ linux-2.3.99-pre6-7/mm/page_alloc.c	Wed Apr 26 18:36:31 2000
@@ -25,7 +25,7 @@
 #endif
 
 int nr_swap_pages = 0;
-int nr_lru_pages;
+int nr_lru_pages = 0;
 pg_data_t *pgdat_list = (pg_data_t *)0;
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
@@ -273,6 +273,8 @@
 struct page * __alloc_pages(zonelist_t *zonelist, unsigned long order)
 {
 	zone_t **zone = zonelist->zones;
+	int gfp_mask = zonelist->gfp_mask;
+	static int low_on_memory;
 
 	/*
 	 * If this is a recursive call, we'd better
@@ -282,6 +284,11 @@
 	if (current->flags & PF_MEMALLOC)
 		goto allocate_ok;
 
+	/* If we're a memory hog, unmap some pages */
+	if (hog_protect && current->hog && low_on_memory &&
+			(gfp_mask & __GFP_WAIT))
+		swap_out(4, gfp_mask);
+
 	/*
 	 * (If anyone calls gfp from interrupts nonatomically then it
 	 * will sooner or later tripped up by a schedule().)
@@ -299,11 +306,13 @@
 		/* Are we supposed to free memory? Don't make it worse.. */
 		if (!z->zone_wake_kswapd && z->free_pages > z->pages_low) {
 			struct page *page = rmqueue(z, order);
+			low_on_memory = 0;
 			if (page)
 				return page;
 		}
 	}
 
+	low_on_memory = 1;
 	/*
 	 * Ok, no obvious zones were available, start
 	 * balancing things a bit..
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
--- linux-2.3.99-pre6-7/mm/vmscan.c.orig	Wed Apr 26 18:23:09 2000
+++ linux-2.3.99-pre6-7/mm/vmscan.c	Wed Apr 26 18:32:48 2000
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
@@ -356,6 +363,7 @@
 		p = init_task.next_task;
 		for (; p != &init_task; p = p->next_task) {
 			struct mm_struct *mm = p->mm;
+			p->hog = 0;
 			if (!p->swappable || !mm)
 				continue;
 	 		if (mm->rss <= 0)
@@ -369,9 +377,28 @@
 				pid = p->pid;
 			}
 		}
+		if (assign == 1) {
+		    /* we just assigned swap_cnt, normalise values */
+		    assign = 2;
+		    if (hog_protect) {
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
+				mm->swap_cnt += i; /* if swap_cnt reaches 0 */
+				/* we're big -> hog treatment */
+				if (!i)
+					p->hog = 1;
+			}
+		    }
+		}
 		read_unlock(&tasklist_lock);
-		if (assign == 1)
-			assign = 2;
 		if (!best) {
 			if (!assign) {
 				assign = 1;
@@ -412,13 +439,15 @@
 {
 	int priority;
 	int count = SWAP_CLUSTER_MAX;
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
@@ -441,7 +470,9 @@
 			}
 		}
 
-		/* Then, try to page stuff out.. */
+		/* Then, try to page stuff out..
+		 * We use swapcount here because this doesn't actually
+		 * free pages */
 		while (swap_out(priority, gfp_mask)) {
 			if (!--count)
 				goto done;
--- linux-2.3.99-pre6-7/mm/swap.c.orig	Wed Apr 26 18:30:32 2000
+++ linux-2.3.99-pre6-7/mm/swap.c	Wed Apr 26 18:31:00 2000
@@ -42,6 +42,9 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster = 4; /* Default value modified in swap_setup() */
 
+/* Do we protect the system from memory hogs and hogs from themselves? */
+int hog_protect = 1;
+
 /* We track the number of pages currently being asynchronously swapped
    out, so that we don't try to swap TOO many pages out at once */
 atomic_t nr_async_pages = ATOMIC_INIT(0);
--- linux-2.3.99-pre6-7/include/linux/mm.h.orig	Wed Apr 26 18:23:15 2000
+++ linux-2.3.99-pre6-7/include/linux/mm.h	Wed Apr 26 18:29:53 2000
@@ -15,6 +15,8 @@
 extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
+extern struct list_head lru_cache;
+extern int hog_protect;
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
--- linux-2.3.99-pre6-7/include/linux/mmzone.h.orig	Wed Apr 26 18:23:21 2000
+++ linux-2.3.99-pre6-7/include/linux/mmzone.h	Wed Apr 26 18:29:13 2000
@@ -31,7 +31,6 @@
 	char			low_on_memory;
 	char			zone_wake_kswapd;
 	unsigned long		pages_min, pages_low, pages_high;
-	struct list_head	lru_cache;
 
 	/*
 	 * free areas of different sizes
--- linux-2.3.99-pre6-7/include/linux/sched.h.orig	Wed Apr 26 16:47:01 2000
+++ linux-2.3.99-pre6-7/include/linux/sched.h	Wed Apr 26 18:29:13 2000
@@ -310,6 +310,7 @@
 /* mm fault and swap info: this can arguably be seen as either mm-specific or thread-specific */
 	unsigned long min_flt, maj_flt, nswap, cmin_flt, cmaj_flt, cnswap;
 	int swappable:1;
+	int hog:1;
 /* process credentials */
 	uid_t uid,euid,suid,fsuid;
 	gid_t gid,egid,sgid,fsgid;
--- linux-2.3.99-pre6-7/include/linux/swap.h.orig	Wed Apr 26 16:47:01 2000
+++ linux-2.3.99-pre6-7/include/linux/swap.h	Wed Apr 26 18:36:20 2000
@@ -87,6 +87,7 @@
 
 /* linux/mm/vmscan.c */
 extern int try_to_free_pages(unsigned int gfp_mask, zone_t *zone);
+extern int swap_out(unsigned int gfp_mask, int priority);
 
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, struct page *, int);
@@ -167,7 +168,7 @@
 #define	lru_cache_add(page)			\
 do {						\
 	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &page->zone->lru_cache);	\
+	list_add(&(page)->lru, &lru_cache);	\
 	nr_lru_pages++;				\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
--- linux-2.3.99-pre6-7/include/linux/sysctl.h.orig	Wed Apr 26 18:24:11 2000
+++ linux-2.3.99-pre6-7/include/linux/sysctl.h	Wed Apr 26 18:25:41 2000
@@ -119,7 +119,7 @@
 enum
 {
 	VM_SWAPCTL=1,		/* struct: Set vm swapping control */
-	VM_SWAPOUT=2,		/* int: Background pageout interval */
+	VM_SWAPOUT=2,		/* int: Linear or sqrt() swapout for hogs */
 	VM_FREEPG=3,		/* struct: Set free page thresholds */
 	VM_BDFLUSH=4,		/* struct: Control buffer cache flushing */
 	VM_OVERCOMMIT_MEMORY=5,	/* Turn off the virtual memory safety limit */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
