Date: Sun, 15 Sep 2002 23:32:21 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH](1/2) rmap14 for ac  (was: Re: 2.5.34-mm4)
In-Reply-To: <1032140016.26857.24.camel@irongate.swansea.linux.org.uk>
Message-ID: <Pine.LNX.4.44L.0209152330020.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, lkml@conectiva.com.br
List-ID: <linux-mm.kvack.org>

On 16 Sep 2002, Alan Cox wrote:

> So send me rmap-14a patches by all means

Here they come.  This first patch updates 2.4.20-pre5-ac6 to
rmap14. An incremental patch to rmap14a + misc bugfixes will
be in your mailbox in a few minutes...

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://distro.conectiva.com/
Spamtraps of the month:  september@surriel.com trac@trac.org


--- linux-2.4.19-pre2-ac3/mm/filemap.c.rmap13b	2002-08-15 23:53:06.000000000 -0300
+++ linux-2.4.19-pre2-ac3/mm/filemap.c	2002-08-15 23:56:37.000000000 -0300
@@ -237,12 +237,11 @@

 static void truncate_complete_page(struct page *page)
 {
-	/* Page has already been removed from processes, by vmtruncate()  */
-	if (page->pte_chain)
-		BUG();
-
-	/* Leave it on the LRU if it gets converted into anonymous buffers */
-	if (!page->buffers || do_flushpage(page, 0))
+	/*
+	 * Leave it on the LRU if it gets converted into anonymous buffers
+	 * or anonymous process memory.
+	 */
+	if ((!page->buffers || do_flushpage(page, 0)) && !page->pte_chain)
 		lru_cache_del(page);

 	/*
--- linux-2.4.19-pre2-ac3/mm/memory.c.rmap13b	2002-08-15 23:53:14.000000000 -0300
+++ linux-2.4.19-pre2-ac3/mm/memory.c	2002-08-15 23:59:04.000000000 -0300
@@ -380,49 +380,65 @@
 	return freed;
 }

-/*
- * remove user pages in a given range.
+#define ZAP_BLOCK_SIZE	(256 * PAGE_SIZE)
+
+/**
+ * zap_page_range - remove user pages in a given range
+ * @mm: mm_struct containing the applicable pages
+ * @address: starting address of pages to zap
+ * @size: number of bytes to zap
  */
 void zap_page_range(struct mm_struct *mm, unsigned long address, unsigned long size)
 {
 	mmu_gather_t *tlb;
 	pgd_t * dir;
-	unsigned long start = address, end = address + size;
-	int freed = 0;
-
-	dir = pgd_offset(mm, address);
-
+	unsigned long start, end, addr, block;
+	int freed;
+
 	/*
-	 * This is a long-lived spinlock. That's fine.
-	 * There's no contention, because the page table
-	 * lock only protects against kswapd anyway, and
-	 * even if kswapd happened to be looking at this
-	 * process we _want_ it to get stuck.
+	 * Break the work up into blocks of ZAP_BLOCK_SIZE pages:
+	 * this decreases lock-hold time for the page_table_lock
+	 * dramatically, which could otherwise be held for a very
+	 * long time.  This decreases lock contention and increases
+	 * periods of preemptibility.
 	 */
-	if (address >= end)
-		BUG();
-	spin_lock(&mm->page_table_lock);
-	flush_cache_range(mm, address, end);
-	tlb = tlb_gather_mmu(mm);
+	while (size) {
+		if (size > ZAP_BLOCK_SIZE)
+			block = ZAP_BLOCK_SIZE;
+		else
+			block = size;
+
+		freed = 0;
+		start = addr = address;
+		end = address + block;
+		dir = pgd_offset(mm, address);

-	do {
-		freed += zap_pmd_range(tlb, dir, address, end - address);
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
+		BUG_ON(address >= end);

-	/* this will flush any remaining tlb entries */
-	tlb_finish_mmu(tlb, start, end);
+		spin_lock(&mm->page_table_lock);
+		flush_cache_range(mm, start, end);
+		tlb = tlb_gather_mmu(mm);

-	/*
-	 * Update rss for the mm_struct (not necessarily current->mm)
-	 * Notice that rss is an unsigned long.
-	 */
-	if (mm->rss > freed)
-		mm->rss -= freed;
-	else
-		mm->rss = 0;
-	spin_unlock(&mm->page_table_lock);
+		do {
+			freed += zap_pmd_range(tlb, dir, addr, end - addr);
+			addr = (addr + PGDIR_SIZE) & PGDIR_MASK;
+			dir++;
+		} while (addr && (addr < end));
+
+		/* this will flush any remaining tlb entries */
+		tlb_finish_mmu(tlb, start, end);
+
+		/* Update rss for the mm_struct (need not be current->mm) */
+		if (mm->rss > freed)
+			mm->rss -= freed;
+		else
+			mm->rss = 0;
+
+		spin_unlock(&mm->page_table_lock);
+
+		address += block;
+		size -= block;
+	}
 }

 /*
@@ -873,18 +889,19 @@
 static inline int remap_pmd_range(struct mm_struct *mm, pmd_t * pmd, unsigned long address, unsigned long size,
 	unsigned long phys_addr, pgprot_t prot)
 {
-	unsigned long end;
+	unsigned long base, end;

+	base = address & PGDIR_MASK;
 	address &= ~PGDIR_MASK;
 	end = address + size;
 	if (end > PGDIR_SIZE)
 		end = PGDIR_SIZE;
 	phys_addr -= address;
 	do {
-		pte_t * pte = pte_alloc(mm, pmd, address);
+		pte_t * pte = pte_alloc(mm, pmd, address + base);
 		if (!pte)
 			return -ENOMEM;
-		remap_pte_range(pte, address, end - address, address + phys_addr, prot);
+		remap_pte_range(pte, base + address, end - address, address + phys_addr, prot);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
--- linux-2.4.19-pre2-ac3/mm/vmscan.c.rmap13b	2002-08-15 23:53:26.000000000 -0300
+++ linux-2.4.19-pre2-ac3/mm/vmscan.c	2002-08-15 23:59:04.000000000 -0300
@@ -195,6 +195,7 @@
  * page_launder_zone - clean dirty inactive pages, move to inactive_clean list
  * @zone: zone to free pages in
  * @gfp_mask: what operations we are allowed to do
+ * @full_flush: full-out page flushing, if we couldn't get enough clean pages
  *
  * This function is called when we are low on free / inactive_clean
  * pages, its purpose is to refill the free/clean list as efficiently
@@ -208,19 +209,30 @@
  * This code is heavily inspired by the FreeBSD source code. Thanks
  * go out to Matthew Dillon.
  */
-#define	CAN_DO_FS	((gfp_mask & __GFP_FS) && should_write)
-int page_launder_zone(zone_t * zone, int gfp_mask, int priority)
+int page_launder_zone(zone_t * zone, int gfp_mask, int full_flush)
 {
-	int maxscan, cleaned_pages, target;
-	struct list_head * entry;
+	int maxscan, cleaned_pages, target, maxlaunder, iopages;
+	struct list_head * entry, * next;

 	target = free_plenty(zone);
-	cleaned_pages = 0;
+	cleaned_pages = iopages = 0;
+
+	/* If we can get away with it, only flush 2 MB worth of dirty pages */
+	if (full_flush)
+		maxlaunder = 1000000;
+	else {
+		maxlaunder = min_t(int, 512, zone->inactive_dirty_pages / 4);
+		maxlaunder = max(maxlaunder, free_plenty(zone));
+	}

 	/* The main launder loop. */
+rescan:
 	spin_lock(&pagemap_lru_lock);
-	maxscan = zone->inactive_dirty_pages >> priority;
-	while (maxscan-- && !list_empty(&zone->inactive_dirty_list)) {
+	maxscan = zone->inactive_dirty_pages;
+	entry = zone->inactive_dirty_list.prev;
+	next = entry->prev;
+	while (maxscan-- && !list_empty(&zone->inactive_dirty_list) &&
+			next != &zone->inactive_dirty_list) {
 		struct page * page;

 		/* Low latency reschedule point */
@@ -231,14 +243,20 @@
 			continue;
 		}

-		entry = zone->inactive_dirty_list.prev;
+		entry = next;
+		next = entry->prev;
 		page = list_entry(entry, struct page, lru);

+		/* This page was removed while we looked the other way. */
+		if (!PageInactiveDirty(page))
+			goto rescan;
+
 		if (cleaned_pages > target)
 			break;

-		list_del(entry);
-		list_add(entry, &zone->inactive_dirty_list);
+		/* Stop doing IO if we've laundered too many pages already. */
+		if (maxlaunder < 0)
+			gfp_mask &= ~(__GFP_IO|__GFP_FS);

 		/* Wrong page on list?! (list corruption, should not happen) */
 		if (!PageInactiveDirty(page)) {
@@ -257,7 +275,6 @@

 		/*
 		 * The page is locked. IO in progress?
-		 * Move it to the back of the list.
 		 * Acquire PG_locked early in order to safely
 		 * access page->mapping.
 		 */
@@ -341,10 +358,16 @@
 				spin_unlock(&pagemap_lru_lock);

 				writepage(page);
+				maxlaunder--;
 				page_cache_release(page);

 				spin_lock(&pagemap_lru_lock);
 				continue;
+			} else {
+				UnlockPage(page);
+				list_del(entry);
+				list_add(entry, &zone->inactive_dirty_list);
+				continue;
 			}
 		}

@@ -391,6 +414,7 @@
 				/* failed to drop the buffers so stop here */
 				UnlockPage(page);
 				page_cache_release(page);
+				maxlaunder--;

 				spin_lock(&pagemap_lru_lock);
 				continue;
@@ -443,21 +467,19 @@
  */
 int page_launder(int gfp_mask)
 {
-	int maxtry = 1 << DEF_PRIORITY;
 	struct zone_struct * zone;
 	int freed = 0;

 	/* Global balancing while we have a global shortage. */
-	while (maxtry-- && free_high(ALL_ZONES) >= 0) {
+	if (free_high(ALL_ZONES) >= 0)
 		for_each_zone(zone)
 			if (free_plenty(zone) >= 0)
-				freed += page_launder_zone(zone, gfp_mask, 6);
-	}
+				freed += page_launder_zone(zone, gfp_mask, 0);

 	/* Clean up the remaining zones with a serious shortage, if any. */
 	for_each_zone(zone)
 		if (free_min(zone) >= 0)
-			freed += page_launder_zone(zone, gfp_mask, 0);
+			freed += page_launder_zone(zone, gfp_mask, 1);

 	return freed;
 }
@@ -814,6 +836,7 @@
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	schedule_timeout(HZ / 4);
 	kswapd_overloaded = 0;
+	wmb();
 	return;
 }

--- linux-2.4.19-pre2-ac3/include/linux/mm.h.rmap13b	2002-08-15 23:52:54.000000000 -0300
+++ linux-2.4.19-pre2-ac3/include/linux/mm.h	2002-08-16 00:01:31.000000000 -0300
@@ -344,15 +344,19 @@
 	 * busywait with less bus contention for a good time to
 	 * attempt to acquire the lock bit.
 	 */
+#ifdef CONFIG_SMP
 	while (test_and_set_bit(PG_chainlock, &page->flags)) {
 		while (test_bit(PG_chainlock, &page->flags))
 			cpu_relax();
 	}
+#endif
 }

 static inline void pte_chain_unlock(struct page *page)
 {
+#ifdef CONFIG_SMP
 	clear_bit(PG_chainlock, &page->flags);
+#endif
 }

 /*
--- linux-2.4.19-pre2-ac3/include/linux/mmzone.h.rmap13b	2002-08-15 23:53:00.000000000 -0300
+++ linux-2.4.19-pre2-ac3/include/linux/mmzone.h	2002-08-16 00:01:31.000000000 -0300
@@ -27,8 +27,6 @@
 struct pglist_data;
 struct pte_chain;

-#define MAX_CHUNKS_PER_NODE 8
-
 /*
  * On machines where it is needed (eg PCs) we divide physical memory
  * into multiple physical zones. On a PC we have 3 zones:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
