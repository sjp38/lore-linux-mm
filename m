Date: Wed, 15 Aug 2001 19:52:30 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: [PATCH] Update zoned code off -ac tree VM
Message-ID: <Pine.LNX.4.21.0108151946470.26574-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Hi, 

The following patch updates the zoned approach code in the -ac VM.

In practice, this change will make deactivation/writeout of pages 
smoother when there is a zone-specific shortage.


diff --exclude-from=/home/marcelo/exclude -Nur linux.orig/mm/page_alloc.c linux/mm/page_alloc.c
--- linux.orig/mm/page_alloc.c	Wed Aug 15 21:01:16 2001
+++ linux/mm/page_alloc.c	Wed Aug 15 21:01:26 2001
@@ -451,7 +451,7 @@
 		 * to give up than to deadlock the kernel looping here.
 		 */
 		if (gfp_mask & __GFP_WAIT) {
-			if (!order || total_free_shortage()) {
+			if (!order || free_shortage()) {
 				int progress = try_to_free_pages(gfp_mask);
 				if (progress || (gfp_mask & __GFP_FS))
 					goto try_again;
diff --exclude-from=/home/marcelo/exclude -Nur linux.orig/mm/vmscan.c linux/mm/vmscan.c
--- linux.orig/mm/vmscan.c	Wed Aug 15 21:01:16 2001
+++ linux/mm/vmscan.c	Wed Aug 15 21:09:51 2001
@@ -27,6 +27,33 @@
 #define MAX(a,b) ((a) > (b) ? (a) : (b))
 
 /*
+ * Estimate whether a zone has enough inactive or free pages..
+ */
+static unsigned int zone_inactive_plenty(zone_t *zone)
+{
+	unsigned int inactive;
+
+	if (!zone->size)
+		return 0;
+		
+	inactive = zone->inactive_dirty_pages;
+	inactive += zone->inactive_clean_pages;
+	inactive += zone->free_pages;
+
+	return (inactive > (zone->size / 3));
+}
+
+static unsigned int zone_free_plenty(zone_t *zone)
+{
+	unsigned int free;
+
+	free = zone->free_pages;
+	free += zone->inactive_clean_pages;
+
+	return free > zone->pages_high*2;
+}
+
+/*
  * The swap-out function returns 1 if it successfully
  * scanned all the pages it was asked to (`count').
  * It returns zero if it couldn't do anything,
@@ -36,17 +63,16 @@
  */
 
 /* mm->page_table_lock is held. mmap_sem is not held */
-static void try_to_swap_out(zone_t *zone, struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, struct page *page)
+static void try_to_swap_out(struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, struct page *page)
 {
 	pte_t pte;
 	swp_entry_t entry;
 
 	/* 
-	 * If we are doing a zone-specific scan, do not
-	 * touch pages from zones which don't have a 
-	 * shortage.
+	 * If we have plenty inactive pages on this 
+	 * zone, skip it.
 	 */
-	if (zone && !zone_inactive_shortage(page->zone))
+	if (zone_inactive_plenty(page->zone))
 		return;
 
 	/* Don't look at this pte if it's been accessed recently. */
@@ -139,7 +165,7 @@
 }
 
 /* mm->page_table_lock is held. mmap_sem is not held */
-static int swap_out_pmd(zone_t *zone, struct mm_struct * mm, struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int count)
+static int swap_out_pmd(struct mm_struct * mm, struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int count)
 {
 	pte_t * pte;
 	unsigned long pmd_end;
@@ -163,7 +189,7 @@
 			struct page *page = pte_page(*pte);
 
 			if (VALID_PAGE(page) && !PageReserved(page)) {
-				try_to_swap_out(zone, mm, vma, address, pte, page);
+				try_to_swap_out(mm, vma, address, pte, page);
 				if (!--count)
 					break;
 			}
@@ -176,7 +202,7 @@
 }
 
 /* mm->page_table_lock is held. mmap_sem is not held */
-static inline int swap_out_pgd(zone_t *zone, struct mm_struct * mm, struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int count)
+static inline int swap_out_pgd( struct mm_struct * mm, struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int count)
 {
 	pmd_t * pmd;
 	unsigned long pgd_end;
@@ -196,7 +222,7 @@
 		end = pgd_end;
 	
 	do {
-		count = swap_out_pmd(zone, mm, vma, pmd, address, end, count);
+		count = swap_out_pmd(mm, vma, pmd, address, end, count);
 		if (!count)
 			break;
 		address = (address + PMD_SIZE) & PMD_MASK;
@@ -206,7 +232,7 @@
 }
 
 /* mm->page_table_lock is held. mmap_sem is not held */
-static int swap_out_vma(zone_t *zone, struct mm_struct * mm, struct vm_area_struct * vma, unsigned long address, int count)
+static int swap_out_vma(struct mm_struct * mm, struct vm_area_struct * vma, unsigned long address, int count)
 {
 	pgd_t *pgdir;
 	unsigned long end;
@@ -221,7 +247,7 @@
 	if (address >= end)
 		BUG();
 	do {
-		count = swap_out_pgd(zone, mm, vma, pgdir, address, end, count);
+		count = swap_out_pgd(mm, vma, pgdir, address, end, count);
 		if (!count)
 			break;
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
@@ -233,7 +259,7 @@
 /*
  * Returns non-zero if we scanned all `count' pages
  */
-static int swap_out_mm(zone_t *zone, struct mm_struct * mm, int count)
+static int swap_out_mm(struct mm_struct * mm, int count)
 {
 	unsigned long address;
 	struct vm_area_struct* vma;
@@ -256,7 +282,7 @@
 			address = vma->vm_start;
 
 		for (;;) {
-			count = swap_out_vma(zone, mm, vma, address, count);
+			count = swap_out_vma(mm, vma, address, count);
 			if (!count)
 				goto out_unlock;
 			vma = vma->vm_next;
@@ -288,7 +314,7 @@
 	return nr;
 }
 
-static void swap_out(zone_t *zone, unsigned int priority, int gfp_mask)
+static void swap_out(unsigned int priority, int gfp_mask)
 {
 	int counter;
 	int retval = 0;
@@ -296,7 +322,7 @@
 
 	/* Always start by trying to penalize the process that is allocating memory */
 	if (mm)
-		retval = swap_out_mm(zone, mm, swap_amount(mm));
+		retval = swap_out_mm(mm, swap_amount(mm));
 
 	/* Then, look at the other mm's */
 	counter = (mmlist_nr << SWAP_MM_SHIFT) >> priority;
@@ -318,7 +344,7 @@
 		spin_unlock(&mmlist_lock);
 
 		/* Walk about 6% of the address space each time */
-		retval |= swap_out_mm(zone, mm, swap_amount(mm));
+		retval |= swap_out_mm(mm, swap_amount(mm));
 		mmput(mm);
 	} while (--counter >= 0);
 	return;
@@ -431,6 +457,27 @@
 	return try_to_free_buffers(page, wait);
 }
 
+static inline int page_dirty(struct page *page)
+{
+	struct buffer_head *tmp, *bh;
+
+	if (PageDirty(page))
+		return 1;
+
+	if (page->mapping && !page->buffers)
+		return 0;
+
+	tmp = bh = page->buffers;
+
+	do {
+		if (tmp->b_state & ((1<<BH_Dirty) | (1<<BH_Lock)))
+			return 1;
+		tmp = tmp->b_this_page;
+	} while (tmp != bh);
+
+	return 0;
+}
+
 /**
  * page_launder - clean dirty inactive pages, move to inactive_clean list
  * @gfp_mask: what operations we are allowed to do
@@ -453,7 +500,7 @@
 #define MAX_LAUNDER 		(4 * (1 << page_cluster))
 #define CAN_DO_FS		(gfp_mask & __GFP_FS)
 #define CAN_DO_IO		(gfp_mask & __GFP_IO)
-int do_page_launder(zone_t *zone, int gfp_mask, int sync)
+int page_launder(int gfp_mask, int sync)
 {
 	int launder_loop, maxscan, cleaned_pages, maxlaunder;
 	struct list_head * page_lru;
@@ -488,15 +535,21 @@
 			continue;
 		}
 
-		/* 
-		 * If we are doing zone-specific laundering, 
-		 * avoid touching pages from zones which do 
-		 * not have a free shortage.
+		/*
+		 * If we have plenty free pages on a zone: 
+		 *
+		 * 1) we avoid a writeout for that page if its dirty.
+		 * 2) if its a buffercache page, and not a pagecache
+		 * one, we skip it since we cannot move it to the 
+		 * inactive clean list --- we have to free it.
 		 */
-		if (zone && !zone_free_shortage(page->zone)) {
-			list_del(page_lru);
-			list_add(page_lru, &inactive_dirty_list);
-			continue;
+
+		if (zone_free_plenty(page->zone)) {
+			if (!page->mapping || page_dirty(page)) {
+				list_del(page_lru);
+				list_add(page_lru, &inactive_dirty_list);
+				continue;
+			}
 		}
 
 		/*
@@ -612,13 +665,9 @@
 			 * If we're freeing buffer cache pages, stop when
 			 * we've got enough free memory.
 			 */
-			if (freed_page) {
-				if (zone) {
-					if (!zone_free_shortage(zone))
-						break;
-				} else if (!free_shortage()) 
-					break;
-			}
+			if (freed_page && !free_shortage())
+				break;
+
 			continue;
 		} else if (page->mapping && !PageDirty(page)) {
 			/*
@@ -656,8 +705,7 @@
 	 * loads, flush out the dirty pages before we have to wait on
 	 * IO.
 	 */
-	if (CAN_DO_IO && !launder_loop && (free_shortage() 
-				|| (zone && zone_free_shortage(zone)))) {
+	if (CAN_DO_IO && !launder_loop && free_shortage()) {
 		launder_loop = 1;
 		/* If we cleaned pages, never do synchronous IO. */
 		if (cleaned_pages)
@@ -673,33 +721,6 @@
 	return cleaned_pages;
 }
 
-int page_launder(int gfp_mask, int sync)
-{
-	int type = 0, ret = 0;
-	pg_data_t *pgdat = pgdat_list;
-	/*
-	 * First do a global scan if there is a 
-	 * global shortage.
-	 */
-	if (free_shortage())
-		ret += do_page_launder(NULL, gfp_mask, sync);
-
-	/*
-	 * Then check if there is any specific zone 
-	 * needs laundering.
-	 */
-	for (type = 0; type < MAX_NR_ZONES; type++) {
-		zone_t *zone = pgdat->node_zones + type;
-		
-		if (zone_free_shortage(zone)) 
-			ret += do_page_launder(zone, gfp_mask, sync);
-	} 
-
-	return ret;
-}
-
-
-
 /**
  * refill_inactive_scan - scan the active list and find pages to deactivate
  * @priority: the priority at which to scan
@@ -710,7 +731,7 @@
  */
 #define too_many_buffers (atomic_read(&buffermem_pages) > \
 		(num_physpages * buffer_mem.borrow_percent / 100))
-int refill_inactive_scan(zone_t *zone, unsigned int priority, int target)
+int refill_inactive_scan(unsigned int priority)
 {
 	struct list_head * page_lru;
 	struct page * page;
@@ -718,13 +739,6 @@
 	int page_active = 0;
 	int nr_deactivated = 0;
 
-	/*
-	 * When we are background aging, we try to increase the page aging
-	 * information in the system.
-	 */
-	if (!target)
-		maxscan = nr_active_pages >> 4;
-
 	/* Take the lock while messing with the list... */
 	spin_lock(&pagemap_lru_lock);
 	while (maxscan-- > 0 && (page_lru = active_list.prev) != &active_list) {
@@ -739,11 +753,10 @@
 		}
 
 		/*
-		 * If we are doing zone-specific scanning, ignore
-		 * pages from zones without shortage.
+		 * Don't deactivate pages from zones which have
+		 * plenty inactive pages.
 		 */
-
-		if (zone && !zone_inactive_shortage(page->zone)) {
+		if (zone_inactive_plenty(page->zone)) {
 			page_active = 1;
 			goto skip_page;
 		}
@@ -795,8 +808,6 @@
 			list_add(page_lru, &active_list);
 		} else {
 			nr_deactivated++;
-			if (target && nr_deactivated >= target)
-				break;
 		}
 	}
 	spin_unlock(&pagemap_lru_lock);
@@ -805,105 +816,80 @@
 }
 
 /*
- * Check if we have are low on free pages globally.
- */
-int free_shortage(void)
-{
-	int freeable = nr_free_pages() + nr_inactive_clean_pages();
-	int freetarget = freepages.high;
-
-	/* Are we low on free pages globally? */
-	if (freeable < freetarget)
-		return freetarget - freeable;
-	return 0;
-}
-
-/*
- *
  * Check if there are zones with a severe shortage of free pages,
  * or if all zones have a minor shortage.
  */
-int total_free_shortage(void)
+int free_shortage(void)
 {
-	int sum = 0;
-	pg_data_t *pgdat = pgdat_list;
-
-	/* Do we have a global free shortage? */
-	if((sum = free_shortage()))
-		return sum;
+	pg_data_t *pgdat;
+	unsigned int global_free = 0;
+	unsigned int global_target = freepages.high;
 
-	/* If not, are we very low on any particular zone? */
+	/* Are we low on free pages anywhere? */
+	pgdat = pgdat_list;
 	do {
 		int i;
 		for(i = 0; i < MAX_NR_ZONES; i++) {
 			zone_t *zone = pgdat->node_zones+ i;
-			if (zone->size && (zone->inactive_clean_pages +
-					zone->free_pages < zone->pages_min)) {
-				sum += zone->pages_min;
-				sum -= zone->free_pages;
-				sum -= zone->inactive_clean_pages;
-			}
-		}
-		pgdat = pgdat->node_next;
-	} while (pgdat);
+			unsigned int free;
 
-	return sum;
-
-}
+			if (!zone->size)
+				continue;
 
-/*
- * How many inactive pages are we short globally?
- */
-int inactive_shortage(void)
-{
-	int shortage = 0;
+			free = zone->free_pages;
+			free += zone->inactive_clean_pages;
 
-	/* Is the inactive dirty list too small? */
+			/* Local shortage? */
+			if (free < zone->pages_low)
+				return 1;
 
-	shortage += freepages.high;
-	shortage += inactive_target;
-	shortage -= nr_free_pages();
-	shortage -= nr_inactive_clean_pages();
-	shortage -= nr_inactive_dirty_pages;
+			global_free += free;
+		}
+		pgdat = pgdat->node_next;
+	} while (pgdat);
 
-	if (shortage > 0)
-		return shortage;
-	return 0;
+	/* Global shortage? */
+	return global_free < global_target;
 }
+
 /*
  * Are we low on inactive pages globally or in any zone?
  */
-int total_inactive_shortage(void)
+int inactive_shortage(void)
 {
-	int shortage = 0;
-	pg_data_t *pgdat = pgdat_list;
-
-	if((shortage = inactive_shortage()))
-		return shortage;
-
-	shortage = 0;	
+	pg_data_t *pgdat;
+	unsigned int global_target = freepages.high + inactive_target;
+	unsigned int global_inactive = 0;
 
+	pgdat = pgdat_list;
 	do {
 		int i;
 		for(i = 0; i < MAX_NR_ZONES; i++) {
-			int zone_shortage;
-			zone_t *zone = pgdat->node_zones+ i;
+			zone_t *zone = pgdat->node_zones + i;
+			unsigned int inactive;
 
 			if (!zone->size)
 				continue;
-			zone_shortage = zone->pages_high;
-			zone_shortage -= zone->inactive_dirty_pages;
-			zone_shortage -= zone->inactive_clean_pages;
-			zone_shortage -= zone->free_pages;
-			if (zone_shortage > 0)
-				shortage += zone_shortage;
+
+			inactive  = zone->inactive_dirty_pages;
+			inactive += zone->inactive_clean_pages;
+			inactive += zone->free_pages;
+
+			/* Local shortage? */
+			if (inactive < zone->pages_high)
+				return 1;
+
+			global_inactive += inactive;
 		}
 		pgdat = pgdat->node_next;
 	} while (pgdat);
 
-	return shortage;
+	/* Global shortage? */
+	return global_inactive < global_target;
 }
 
+#define DEF_PRIORITY (6)
+
 /*
  * Refill_inactive is the function used to scan and age the pages on
  * the active list and in the working set of processes, moving the
@@ -920,96 +906,34 @@
  * deactivate too many pages. To achieve this we simply do less work
  * when called from a user process.
  */
-#define DEF_PRIORITY (6)
-static int refill_inactive_global(unsigned int gfp_mask, int user)
+static int refill_inactive(unsigned int gfp_mask)
 {
-	int count, start_count, maxtry;
+	int progress = 0, maxtry;
 
-	if (user) {
-		count = (1 << page_cluster);
-		maxtry = 6;
-	} else {
-		count = inactive_shortage();
-		maxtry = 1 << DEF_PRIORITY;
-	}
+	maxtry = 1 << DEF_PRIORITY;
 
-	start_count = count;
 	do {
 		if (current->need_resched) {
-			__set_current_state(TASK_RUNNING);
+			 __set_current_state(TASK_RUNNING);
 			schedule();
 			if (!inactive_shortage())
 				return 1;
 		}
 
 		/* Walk the VM space for a bit.. */
-		swap_out(NULL, DEF_PRIORITY, gfp_mask);
+		swap_out(DEF_PRIORITY, gfp_mask);
 
-		count -= refill_inactive_scan(NULL, DEF_PRIORITY, count);
-		if (count <= 0)
-			goto done;
+		/* ..and refill the inactive list */
+		progress += refill_inactive_scan(DEF_PRIORITY);
 
 		if (--maxtry <= 0)
-				return 0;
-		
+			break;
 	} while (inactive_shortage());
 
-done:
-	return (count < start_count);
-}
-
-static int refill_inactive_zone(zone_t *zone, unsigned int gfp_mask, int user) 
-{
-	int count, start_count, maxtry; 
-	
-	count = start_count = zone_inactive_shortage(zone);
-
-	maxtry = (1 << DEF_PRIORITY);
-
-	do {
-		swap_out(zone, DEF_PRIORITY, gfp_mask);
-
-		count -= refill_inactive_scan(zone, DEF_PRIORITY, count);
-
-		if (count <= 0)
-			goto done;
-
-		if (--maxtry <= 0)
-			return 0;
-
-	} while(zone_inactive_shortage(zone));
-done:
-	return (count < start_count);
+	return progress;
 }
 
 
-static int refill_inactive(unsigned int gfp_mask, int user) 
-{
-	int type = 0, ret = 0;
-	pg_data_t *pgdat = pgdat_list;
-	/*
-	 * First do a global scan if there is a 
-	 * global shortage.
-	 */
-	if (inactive_shortage())
-		ret += refill_inactive_global(gfp_mask, user);
-
-	/*
-	 * Then check if there is any specific zone 
-	 * with a shortage and try to refill it if
-	 * so.
-	 */
-	for (type = 0; type < MAX_NR_ZONES; type++) {
-		zone_t *zone = pgdat->node_zones + type;
-		
-		if (zone_inactive_shortage(zone)) 
-			ret += refill_inactive_zone(zone, gfp_mask, user);
-	} 
-
-	return ret;
-}
-
-#define DEF_PRIORITY (6)
 
 static int do_try_to_free_pages(unsigned int gfp_mask, int user)
 {
@@ -1024,9 +948,8 @@
 	 * list, so this is a relatively cheap operation.
 	 */
 
-	ret += page_launder(gfp_mask, user);
-
-	if (total_free_shortage()) {
+	if (free_shortage()) {
+		ret += page_launder(gfp_mask, user);
 		shrink_dcache_memory(0, gfp_mask);
 		shrink_icache_memory(0, gfp_mask);
 		shrink_dqcache_memory(DEF_PRIORITY, gfp_mask);
@@ -1036,7 +959,8 @@
 	 * If needed, we move pages from the active list
 	 * to the inactive list.
 	 */
-	ret += refill_inactive(gfp_mask, user);
+	if (inactive_shortage())
+		ret += refill_inactive(gfp_mask);
 
 	/* 	
 	 * Reclaim unused slab cache if memory is low.
@@ -1091,7 +1015,7 @@
 		static long recalc = 0;
 
 		/* If needed, try to free some memory. */
-		if (total_inactive_shortage() || total_free_shortage()) 
+		if (inactive_shortage() || free_shortage()) 
 			do_try_to_free_pages(GFP_KSWAPD, 0);
 
 		/* Once a second ... */
@@ -1102,7 +1026,7 @@
 			recalculate_vm_stats();
 
 			/* Do background page aging. */
-			refill_inactive_scan(NULL, DEF_PRIORITY, 0);
+			refill_inactive_scan(DEF_PRIORITY);
 		}
 
 		run_task_queue(&tq_disk);
@@ -1118,7 +1042,7 @@
 		 * We go to sleep for one second, but if it's needed
 		 * we'll be woken up earlier...
 		 */
-		if (!total_free_shortage() || !total_inactive_shortage()) {
+		if (!free_shortage() || !inactive_shortage()) {
 			interruptible_sleep_on_timeout(&kswapd_wait, HZ);
 		/*
 		 * If we couldn't free enough memory, we see if it was

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
