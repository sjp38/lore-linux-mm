Received: by wr-out-0506.google.com with SMTP id 71so2089273wri
        for <linux-mm@kvack.org>; Mon, 12 Feb 2007 21:52:01 -0800 (PST)
Message-ID: <4df04b840702122152o64b2d59cy53afcd43bb24cb7a@mail.gmail.com>
Date: Tue, 13 Feb 2007 13:52:01 +0800
From: "yunfeng zhang" <zyf.zeroos@gmail.com>
Subject: Re: [PATCH 2.6.20-rc5 1/1] MM: enhance Linux swap subsystem
In-Reply-To: <Pine.LNX.4.64.0701312022340.26857@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4df04b840701212309l2a283357jbdaa88794e5208a7@mail.gmail.com>
	 <200701222300.41960.a1426z@gawab.com>
	 <4df04b840701222021w5e1aaab2if2ba7fc38d06d64b@mail.gmail.com>
	 <4df04b840701222108o6992933bied5fff8a525413@mail.gmail.com>
	 <Pine.LNX.4.64.0701242015090.1770@blonde.wat.veritas.com>
	 <4df04b840701301852i41687edfl1462c4ca3344431c@mail.gmail.com>
	 <Pine.LNX.4.64.0701312022340.26857@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

You can apply my previous patch on 2.6.20 by changing

-#define VM_PURE_PRIVATE	0x04000000	/* Is the vma is only belonging to a mm,
to
+#define VM_PURE_PRIVATE	0x08000000	/* Is the vma is only belonging to a mm,

New revision is based on 2.6.20 with my previous patch, major changelogs are
1) pte_unmap pairs on shrink_pvma_scan_ptes and pps_swapoff_scan_ptes.
2) Now, kppsd can be woke up by kswapd.
3) New global variable accelerate_kppsd is appended to accelerate the
   reclamation process when a memory inode is low.


Signed-off-by: Yunfeng Zhang <zyf.zeroos@gmail.com>

Index: linux-2.6.19/Documentation/vm_pps.txt
===================================================================
--- linux-2.6.19.orig/Documentation/vm_pps.txt	2007-02-12
12:45:07.000000000 +0800
+++ linux-2.6.19/Documentation/vm_pps.txt	2007-02-12 15:30:16.490797672 +0800
@@ -143,23 +143,32 @@
 2) mm/memory.c   do_wp_page, handle_pte_fault::unmapped_pte, do_anonymous_page,
    do_swap_page (page-fault)
 3) mm/memory.c   get_user_pages (sometimes core need share PrivatePage with us)
+4) mm/vmscan.c   balance_pgdat  (kswapd/x can do stage 5 of its node pages,
+   while kppsd can do stage 1-4)
+5) mm/vmscan.c   kppsd          (new core daemon -- kppsd, see below)

 There isn't new lock order defined in pps, that is, it's compliable to Linux
-lock order.
+lock order. Locks in shrink_private_vma copied from shrink_list of 2.6.16.29
+(my initial version).
 // }])>

 // Others about pps <([{
 A new kernel thread -- kppsd is introduced in mm/vmscan.c, its task is to
-execute the stages of pps periodically, note an appropriate timeout ticks is
-necessary so we can give application a chance to re-map back its PrivatePage
-from UnmappedPTE to PTE, that is, show their conglomeration affinity.
-
-kppsd can be controlled by new fields -- scan_control::may_reclaim/reclaim_node
-may_reclaim = 1 means starting reclamation (stage 5).  reclaim_node = (node
-number) is used when a memory node is low. Caller should set them to wakeup_sc,
-then wake up kppsd (vmscan.c:balance_pgdat). Note, if kppsd is started due to
-timeout, it doesn't do stage 5 at all (vmscan.c:kppsd). Other alive legacy
-fields are gfp_mask, may_writepage and may_swap.
+execute the stage 1 - 4 of pps periodically, note an appropriate timeout ticks
+(current 2 seconds) is necessary so we can give application a chance to re-map
+back its PrivatePage from UnmappedPTE to PTE, that is, show their
+conglomeration affinity.
+
+shrink_private_vma can be controlled by new fields -- may_reclaim, reclaim_node
+and is_kppsd of scan_control.  may_reclaim = 1 means starting reclamation
+(stage 5). reclaim_node = (node number, -1 means all memory inode) is used when
+a memory node is low. Caller (kswapd/x), typically, set reclaim_node to start
+shrink_private_vma (vmscan.c:balance_pgdat). Note, only to kppsd is_kppsd = 1.
+Other alive legacy fields to pps are gfp_mask, may_writepage and may_swap.
+
+When a memory inode is low, kswapd/x can wake up kppsd by increasing global
+variable accelerate_kppsd (balance_pgdat), which accelerate stage 1 - 4, and
+call shrink_private_vma to do stage 5.

 PPS statistic data is appended to /proc/meminfo entry, its prototype is in
 include/linux/mm.h.
Index: linux-2.6.19/mm/swapfile.c
===================================================================
--- linux-2.6.19.orig/mm/swapfile.c	2007-02-12 12:45:07.000000000 +0800
+++ linux-2.6.19/mm/swapfile.c	2007-02-12 12:45:21.000000000 +0800
@@ -569,6 +569,7 @@
 			}
 		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap(pte);
 	return 0;
 }

Index: linux-2.6.19/mm/vmscan.c
===================================================================
--- linux-2.6.19.orig/mm/vmscan.c	2007-02-12 12:45:07.000000000 +0800
+++ linux-2.6.19/mm/vmscan.c	2007-02-12 15:48:59.217292888 +0800
@@ -70,6 +70,7 @@
 	/* pps control command. See Documentation/vm_pps.txt. */
 	int may_reclaim;
 	int reclaim_node;
+	int is_kppsd;
 };

 /*
@@ -1101,9 +1102,9 @@
 	return ret;
 }

-// pps fields.
+// pps fields, see Documentation/vm_pps.txt.
 static wait_queue_head_t kppsd_wait;
-static struct scan_control wakeup_sc;
+static int accelerate_kppsd = 0;
 struct pps_info pps_info = {
 	.total = ATOMIC_INIT(0),
 	.pte_count = ATOMIC_INIT(0), // stage 1 and 2.
@@ -1118,24 +1119,22 @@
 	struct page* pages[MAX_SERIES_LENGTH];
 	int series_length;
 	int series_stage;
-} series;
+};

-static int get_series_stage(pte_t* pte, int index)
+static int get_series_stage(struct series_t* series, pte_t* pte, int index)
 {
-	series.orig_ptes[index] = *pte;
-	series.ptes[index] = pte;
-	if (pte_present(series.orig_ptes[index])) {
-		struct page* page = pfn_to_page(pte_pfn(series.orig_ptes[index]));
-		series.pages[index] = page;
+	series->orig_ptes[index] = *pte;
+	series->ptes[index] = pte;
+	struct page* page = pfn_to_page(pte_pfn(series->orig_ptes[index]));
+	series->pages[index] = page;
+	if (pte_present(series->orig_ptes[index])) {
 		if (page == ZERO_PAGE(addr)) // reserved page is exclusive from us.
 			return 7;
-		if (pte_young(series.orig_ptes[index])) {
+		if (pte_young(series->orig_ptes[index])) {
 			return 1;
 		} else
 			return 2;
-	} else if (pte_unmapped(series.orig_ptes[index])) {
-		struct page* page = pfn_to_page(pte_pfn(series.orig_ptes[index]));
-		series.pages[index] = page;
+	} else if (pte_unmapped(series->orig_ptes[index])) {
 		if (!PageSwapCache(page))
 			return 3;
 		else {
@@ -1148,19 +1147,20 @@
 		return 6;
 }

-static void find_series(pte_t** start, unsigned long* addr, unsigned long end)
+static void find_series(struct series_t* series, pte_t** start, unsigned long*
+		addr, unsigned long end)
 {
 	int i;
-	int series_stage = get_series_stage((*start)++, 0);
+	int series_stage = get_series_stage(series, (*start)++, 0);
 	*addr += PAGE_SIZE;

 	for (i = 1; i < MAX_SERIES_LENGTH && *addr < end; i++, (*start)++,
 		*addr += PAGE_SIZE) {
-		if (series_stage != get_series_stage(*start, i))
+		if (series_stage != get_series_stage(series, *start, i))
 			break;
 	}
-	series.series_stage = series_stage;
-	series.series_length = i;
+	series->series_stage = series_stage;
+	series->series_length = i;
 }

 struct delay_tlb_task delay_tlb_tasks[32] = { [0 ... 31] = {0} };
@@ -1284,9 +1284,9 @@
 	goto fill_it;
 }

-static void shrink_pvma_scan_ptes(struct scan_control* sc, struct mm_struct*
-		mm, struct vm_area_struct* vma, pmd_t* pmd, unsigned long addr,
-		unsigned long end)
+static unsigned long shrink_pvma_scan_ptes(struct scan_control* sc, struct
+		mm_struct* mm, struct vm_area_struct* vma, pmd_t* pmd, unsigned
+		long addr, unsigned long end)
 {
 	int i, statistic;
 	spinlock_t* ptl = pte_lockptr(mm, pmd);
@@ -1295,32 +1295,43 @@
 	struct pagevec freed_pvec;
 	int may_enter_fs = (sc->gfp_mask & (__GFP_FS | __GFP_IO));
 	struct address_space* mapping = &swapper_space;
+	unsigned long nr_reclaimed = 0;
+	struct series_t series;

 	pagevec_init(&freed_pvec, 1);
 	do {
 		memset(&series, 0, sizeof(struct series_t));
-		find_series(&pte, &addr, end);
+		find_series(&series, &pte, &addr, end);
 		if (sc->may_reclaim == 0 && series.series_stage == 5)
 			continue;
+		if (!sc->is_kppsd && series.series_stage != 5)
+			continue;
 		switch (series.series_stage) {
 		case 1: // PTE -- untouched PTE.
 		for (i = 0; i < series.series_length; i++) {
 			struct page* page = series.pages[i];
-			lock_page(page);
+			if (TestSetPageLocked(page))
+				continue;
 			spin_lock(ptl);
-			if (unlikely(pte_same(*series.ptes[i],
-					series.orig_ptes[i]))) {
-				if (pte_dirty(*series.ptes[i]))
-				    set_page_dirty(page);
-				set_pte_at(mm, addr + i * PAGE_SIZE,
-					series.ptes[i],
-					pte_mkold(pte_mkclean(*series.ptes[i])));
+			// To get dirty bit from pte safely, using the idea of
+			// dftlb of stage 2.
+			pte_t pte_new = series.orig_ptes[i];
+			pte_new = pte_mkold(pte_mkclean(series.orig_ptes[i]));
+			if (cmpxchg(&series.ptes[i]->pte_low,
+						series.orig_ptes[i].pte_low,
+						pte_new.pte_low) !=
+				series.orig_ptes[i].pte_low) {
+				spin_unlock(ptl);
+				unlock_page(page);
+				continue;
 			}
+			if (pte_dirty(series.orig_ptes[i]))
+				set_page_dirty(page);
 			spin_unlock(ptl);
 			unlock_page(page);
 		}
 		fill_in_tlb_tasks(vma, addr, addr + (PAGE_SIZE *
-			    series.series_length));
+					series.series_length));
 		break;
 		case 2: // untouched PTE -- UnmappedPTE.
 		/*
@@ -1335,37 +1346,39 @@
 		spin_lock(ptl);
 		statistic = 0;
 		for (i = 0; i < series.series_length; i++) {
-			if (unlikely(pte_same(*series.ptes[i],
-					series.orig_ptes[i]))) {
-				pte_t pte_unmapped = series.orig_ptes[i];
-				pte_unmapped.pte_low &= ~_PAGE_PRESENT;
-				pte_unmapped.pte_low |= _PAGE_UNMAPPED;
-				if (cmpxchg(&series.ptes[i]->pte_low,
-					    series.orig_ptes[i].pte_low,
-					    pte_unmapped.pte_low) !=
-					series.orig_ptes[i].pte_low)
-					continue;
-				page_remove_rmap(series.pages[i], vma);
-				anon_rss--;
-				statistic++;
-			}
+			pte_t pte_unmapped = series.orig_ptes[i];
+			pte_unmapped.pte_low &= ~_PAGE_PRESENT;
+			pte_unmapped.pte_low |= _PAGE_UNMAPPED;
+			if (cmpxchg(&series.ptes[i]->pte_low,
+						series.orig_ptes[i].pte_low,
+						pte_unmapped.pte_low) !=
+				series.orig_ptes[i].pte_low)
+				continue;
+			page_remove_rmap(series.pages[i], vma);
+			anon_rss--;
+			statistic++;
 		}
 		atomic_add(statistic, &pps_info.unmapped_count);
 		atomic_sub(statistic, &pps_info.pte_count);
 		spin_unlock(ptl);
-		break;
+		if (!accelerate_kppsd)
+			break;
 		case 3: // Attach SwapPage to PrivatePage.
 		/*
 		 * A better arithmetic should be applied to Linux SwapDevice to
 		 * allocate fake continual SwapPages which are close to each
 		 * other, the offset between two close SwapPages is less than 8.
+		 *
+		 * We can re-allocate SwapPages here if process private pages
+		 * are pure private.
 		 */
 		if (sc->may_swap) {
 			for (i = 0; i < series.series_length; i++) {
-				lock_page(series.pages[i]);
+				if (TestSetPageLocked(series.pages[i]))
+					continue;
 				if (!PageSwapCache(series.pages[i])) {
 					if (!add_to_swap(series.pages[i],
-						    GFP_ATOMIC)) {
+								GFP_ATOMIC)) {
 						unlock_page(series.pages[i]);
 						break;
 					}
@@ -1373,45 +1386,49 @@
 				unlock_page(series.pages[i]);
 			}
 		}
-		break;
+		if (!accelerate_kppsd)
+			break;
 		case 4: // SwapPage isn't consistent with PrivatePage.
 		/*
 		 * A mini version pageout().
 		 *
 		 * Current swap space can't commit multiple pages together:(
 		 */
-		if (sc->may_writepage && may_enter_fs) {
-			for (i = 0; i < series.series_length; i++) {
-				struct page* page = series.pages[i];
-				int res;
+		if (!(sc->may_writepage && may_enter_fs))
+			break;
+		for (i = 0; i < series.series_length; i++) {
+			struct page* page = series.pages[i];
+			int res;

-				if (!may_write_to_queue(mapping->backing_dev_info))
-					break;
-				lock_page(page);
-				if (!PageDirty(page) || PageWriteback(page)) {
-					unlock_page(page);
-					continue;
-				}
-				clear_page_dirty_for_io(page);
-				struct writeback_control wbc = {
-					.sync_mode = WB_SYNC_NONE,
-					.nr_to_write = SWAP_CLUSTER_MAX,
-					.nonblocking = 1,
-					.for_reclaim = 1,
-				};
-				page_cache_get(page);
-				SetPageReclaim(page);
-				res = swap_writepage(page, &wbc);
-				if (res < 0) {
-					handle_write_error(mapping, page, res);
-					ClearPageReclaim(page);
-					page_cache_release(page);
-					break;
-				}
-				if (!PageWriteback(page))
-					ClearPageReclaim(page);
+			if (!may_write_to_queue(mapping->backing_dev_info))
+				break;
+			if (TestSetPageLocked(page))
+				continue;
+			if (!PageDirty(page) || PageWriteback(page)) {
+				unlock_page(page);
+				continue;
+			}
+			clear_page_dirty_for_io(page);
+			struct writeback_control wbc = {
+				.sync_mode = WB_SYNC_NONE,
+				.nr_to_write = SWAP_CLUSTER_MAX,
+				.range_start = 0,
+				.range_end = LLONG_MAX,
+				.nonblocking = 1,
+				.for_reclaim = 1,
+			};
+			page_cache_get(page);
+			SetPageReclaim(page);
+			res = swap_writepage(page, &wbc);
+			if (res < 0) {
+				handle_write_error(mapping, page, res);
+				ClearPageReclaim(page);
 				page_cache_release(page);
+				break;
 			}
+			if (!PageWriteback(page))
+				ClearPageReclaim(page);
+			page_cache_release(page);
 		}
 		break;
 		case 5: // UnmappedPTE -- SwappedPTE, reclaim PrivatePage.
@@ -1419,10 +1436,11 @@
 		for (i = 0; i < series.series_length; i++) {
 			struct page* page = series.pages[i];
 			if (!(page_to_nid(page) == sc->reclaim_node ||
-				    sc->reclaim_node == -1))
+						sc->reclaim_node == -1))
 				continue;

-			lock_page(page);
+			if (TestSetPageLocked(page))
+				continue;
 			spin_lock(ptl);
 			if (!pte_same(*series.ptes[i], series.orig_ptes[i]) ||
 					/* We're racing with get_user_pages. */
@@ -1449,6 +1467,7 @@
 		atomic_add(statistic, &pps_info.swapped_count);
 		atomic_sub(statistic, &pps_info.unmapped_count);
 		atomic_sub(statistic, &pps_info.total);
+		nr_reclaimed += statistic;
 		break;
 		case 6:
 		// NULL operation!
@@ -1456,58 +1475,67 @@
 		}
 	} while (addr < end);
 	add_mm_counter(mm, anon_rss, anon_rss);
+	pte_unmap(pte);
 	if (pagevec_count(&freed_pvec))
 		__pagevec_release_nonlru(&freed_pvec);
+	return nr_reclaimed;
 }

-static void shrink_pvma_pmd_range(struct scan_control* sc, struct mm_struct*
-		mm, struct vm_area_struct* vma, pud_t* pud, unsigned long addr,
-		unsigned long end)
+static unsigned long shrink_pvma_pmd_range(struct scan_control* sc, struct
+		mm_struct* mm, struct vm_area_struct* vma, pud_t* pud, unsigned
+		long addr, unsigned long end)
 {
 	unsigned long next;
+	unsigned long nr_reclaimed = 0;
 	pmd_t* pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		shrink_pvma_scan_ptes(sc, mm, vma, pmd, addr, next);
+		nr_reclaimed += shrink_pvma_scan_ptes(sc, mm, vma, pmd, addr, next);
 	} while (pmd++, addr = next, addr != end);
+	return nr_reclaimed;
 }

-static void shrink_pvma_pud_range(struct scan_control* sc, struct mm_struct*
-		mm, struct vm_area_struct* vma, pgd_t* pgd, unsigned long addr,
-		unsigned long end)
+static unsigned long shrink_pvma_pud_range(struct scan_control* sc, struct
+		mm_struct* mm, struct vm_area_struct* vma, pgd_t* pgd, unsigned
+		long addr, unsigned long end)
 {
 	unsigned long next;
+	unsigned long nr_reclaimed = 0;
 	pud_t* pud = pud_offset(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		shrink_pvma_pmd_range(sc, mm, vma, pud, addr, next);
+		nr_reclaimed += shrink_pvma_pmd_range(sc, mm, vma, pud, addr, next);
 	} while (pud++, addr = next, addr != end);
+	return nr_reclaimed;
 }

-static void shrink_pvma_pgd_range(struct scan_control* sc, struct mm_struct*
-		mm, struct vm_area_struct* vma)
+static unsigned long shrink_pvma_pgd_range(struct scan_control* sc, struct
+		mm_struct* mm, struct vm_area_struct* vma)
 {
 	unsigned long next;
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
+	unsigned long nr_reclaimed = 0;
 	pgd_t* pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		shrink_pvma_pud_range(sc, mm, vma, pgd, addr, next);
+		nr_reclaimed += shrink_pvma_pud_range(sc, mm, vma, pgd, addr, next);
 	} while (pgd++, addr = next, addr != end);
+	return nr_reclaimed;
 }

-static void shrink_private_vma(struct scan_control* sc)
+static unsigned long shrink_private_vma(struct scan_control* sc)
 {
 	struct vm_area_struct* vma;
 	struct list_head *pos;
 	struct mm_struct *prev, *mm;
+	unsigned long nr_reclaimed = 0;

 	prev = mm = &init_mm;
 	pos = &init_mm.mmlist;
@@ -1520,22 +1548,25 @@
 		spin_unlock(&mmlist_lock);
 		mmput(prev);
 		prev = mm;
-		start_tlb_tasks(mm);
+		if (sc->is_kppsd)
+			start_tlb_tasks(mm);
 		if (down_read_trylock(&mm->mmap_sem)) {
 			for (vma = mm->mmap; vma != NULL; vma = vma->vm_next) {
 				if (!(vma->vm_flags & VM_PURE_PRIVATE))
 					continue;
 				if (vma->vm_flags & VM_LOCKED)
 					continue;
-				shrink_pvma_pgd_range(sc, mm, vma);
+				nr_reclaimed += shrink_pvma_pgd_range(sc, mm, vma);
 			}
 			up_read(&mm->mmap_sem);
 		}
-		end_tlb_tasks();
+		if (sc->is_kppsd)
+			end_tlb_tasks();
 		spin_lock(&mmlist_lock);
 	}
 	spin_unlock(&mmlist_lock);
 	mmput(prev);
+	return nr_reclaimed;
 }

 /*
@@ -1585,10 +1616,12 @@
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);

-	wakeup_sc = sc;
-	wakeup_sc.may_reclaim = 1;
-	wakeup_sc.reclaim_node = pgdat->node_id;
-	wake_up_interruptible(&kppsd_wait);
+	accelerate_kppsd++;
+	wake_up(&kppsd_wait);
+	sc.may_reclaim = 1;
+	sc.reclaim_node = pgdat->node_id;
+	sc.is_kppsd = 0;
+	nr_reclaimed += shrink_private_vma(&sc);

 	for (i = 0; i < pgdat->nr_zones; i++)
 		temp_priority[i] = DEF_PRIORITY;
@@ -2173,26 +2206,24 @@
 static int kppsd(void* p)
 {
 	struct task_struct *tsk = current;
-	int timeout;
 	DEFINE_WAIT(wait);
 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE;
 	struct scan_control default_sc;
 	default_sc.gfp_mask = GFP_KERNEL;
-	default_sc.may_writepage = 1;
 	default_sc.may_swap = 1;
 	default_sc.may_reclaim = 0;
 	default_sc.reclaim_node = -1;
+	default_sc.is_kppsd = 1;

 	while (1) {
 		try_to_freeze();
-		prepare_to_wait(&kppsd_wait, &wait, TASK_INTERRUPTIBLE);
-		timeout = schedule_timeout(2000);
-		finish_wait(&kppsd_wait, &wait);
-
-		if (timeout)
-			shrink_private_vma(&wakeup_sc);
-		else
-			shrink_private_vma(&default_sc);
+		accelerate_kppsd >>= 1;
+		wait_event_timeout(kppsd_wait, accelerate_kppsd != 0,
+				msecs_to_jiffies(2000));
+		default_sc.may_writepage = !laptop_mode;
+		if (accelerate_kppsd)
+			default_sc.may_writepage = 1;
+		shrink_private_vma(&default_sc);
 	}
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
