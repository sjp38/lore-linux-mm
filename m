Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.8/8.13.6) with ESMTP id kBTMB42S5726320
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:11:36 -0100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBTACOJ5118498
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:12:35 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBTA8t9c018930
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:08:55 +1100
From: Balbir Singh <balbir@in.ibm.com>
Date: Fri, 29 Dec 2006 15:38:50 +0530
Message-Id: <20061229100850.13860.69089.sendpatchset@balbir.in.ibm.com>
In-Reply-To: <20061229100839.13860.15525.sendpatchset@balbir.in.ibm.com>
References: <20061229100839.13860.15525.sendpatchset@balbir.in.ibm.com>
Subject: [RFC][PATCH 1/3] Add back rmap lock
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com, akpm@osdl.org, andyw@uk.ibm.com
Cc: linux-mm@kvack.org, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>


This patch adds back the rmap lock that was removed by a patch posted
to lkml at http://lkml.org/lkml/2004/7/12/241. The rmap lock is needed to
ensure that rmap information does not change as a page is being shared or
unshared.

Signed-off-by: Balbir Singh <balbir@in.ibm.com>
---

 include/linux/mm.h         |   67 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h   |    8 ++++-
 include/linux/page-flags.h |    1 
 include/linux/rmap.h       |   24 ++++++++++++++--
 init/Kconfig               |   11 +++++++
 mm/filemap_xip.c           |    2 -
 mm/page_alloc.c            |    9 ++++--
 mm/rmap.c                  |   44 ++++++++++++++++++++---------
 mm/vmscan.c                |   28 +++++++++++++++---
 9 files changed, 169 insertions(+), 25 deletions(-)

diff -puN include/linux/page-flags.h~add-page-map-lock include/linux/page-flags.h
--- linux-2.6.20-rc2/include/linux/page-flags.h~add-page-map-lock	2006-12-29 14:48:07.000000000 +0530
+++ linux-2.6.20-rc2-balbir/include/linux/page-flags.h	2006-12-29 14:48:07.000000000 +0530
@@ -90,6 +90,7 @@
 #define PG_reclaim		17	/* To be reclaimed asap */
 #define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
+#define PG_maplock		20	/* Lock rmap operations */
 
 
 #if (BITS_PER_LONG > 32)
diff -puN include/linux/rmap.h~add-page-map-lock include/linux/rmap.h
--- linux-2.6.20-rc2/include/linux/rmap.h~add-page-map-lock	2006-12-29 14:48:07.000000000 +0530
+++ linux-2.6.20-rc2-balbir/include/linux/rmap.h	2006-12-29 14:48:07.000000000 +0530
@@ -8,6 +8,24 @@
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/spinlock.h>
+#include <linux/bit_spinlock.h>
+
+#ifdef CONFIG_SHARED_PAGE_ACCOUNTING
+#define page_map_lock(page) \
+	bit_spin_lock(PG_maplock, (unsigned long *)&(page)->flags)
+#define page_map_unlock(page) \
+	bit_spin_unlock(PG_maplock, (unsigned long *)&(page)->flags)
+#define page_check_address_pte_trylock(ptl) \
+	spin_trylock(ptl)
+#else
+#define page_map_lock(page)   do {} while(0)
+#define page_map_unlock(page) do {} while(0)
+#define page_check_address_pte_trylock(ptl)	\
+({						\
+ 	spin_lock(ptl);				\
+	1;					\
+})
+#endif /* CONFIG_SHARED_PAGE_ACCOUNTING */
 
 /*
  * The anon_vma heads a list of private "related" vmas, to scan if
@@ -83,7 +101,9 @@ void page_remove_rmap(struct page *, str
  */
 static inline void page_dup_rmap(struct page *page)
 {
-	atomic_inc(&page->_mapcount);
+	page_map_lock(page);
+	page_mapcount_inc(page);
+	page_map_unlock(page);
 }
 
 /*
@@ -96,7 +116,7 @@ int try_to_unmap(struct page *, int igno
  * Called from mm/filemap_xip.c to unmap empty zero page
  */
 pte_t *page_check_address(struct page *, struct mm_struct *,
-				unsigned long, spinlock_t **);
+				unsigned long, spinlock_t **, bool);
 
 /*
  * Used by swapoff to help locate where page is expected in vma.
diff -puN mm/rmap.c~add-page-map-lock mm/rmap.c
--- linux-2.6.20-rc2/mm/rmap.c~add-page-map-lock	2006-12-29 14:48:07.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/rmap.c	2006-12-29 14:48:07.000000000 +0530
@@ -243,7 +243,8 @@ unsigned long page_address_in_vma(struct
  * On success returns with pte mapped and locked.
  */
 pte_t *page_check_address(struct page *page, struct mm_struct *mm,
-			  unsigned long address, spinlock_t **ptlp)
+			  unsigned long address, spinlock_t **ptlp,
+			  bool trylock)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -271,12 +272,20 @@ pte_t *page_check_address(struct page *p
 	}
 
 	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
+	if (trylock) {
+		if (!page_check_address_pte_trylock(ptl))
+			goto out;
+	} else {
+		spin_lock(ptl);
+	}
+
 	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
 		*ptlp = ptl;
 		return pte;
 	}
-	pte_unmap_unlock(pte, ptl);
+	spin_unlock(ptl);
+out:
+	pte_unmap(pte);
 	return NULL;
 }
 
@@ -297,7 +306,7 @@ static int page_referenced_one(struct pa
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl);
+	pte = page_check_address(page, mm, address, &ptl, true);
 	if (!pte)
 		goto out;
 
@@ -441,7 +450,7 @@ static int page_mkclean_one(struct page 
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl);
+	pte = page_check_address(page, mm, address, &ptl, false);
 	if (!pte)
 		goto out;
 
@@ -532,9 +541,10 @@ static void __page_set_anon_rmap(struct 
 void page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
-	if (atomic_inc_and_test(&page->_mapcount))
+	page_map_lock(page);
+	if (page_mapcount_inc_and_test(page))
 		__page_set_anon_rmap(page, vma, address);
-	/* else checking page index and mapping is racy */
+	page_map_unlock(page);
 }
 
 /*
@@ -549,8 +559,10 @@ void page_add_anon_rmap(struct page *pag
 void page_add_new_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
-	atomic_set(&page->_mapcount, 0); /* elevate count by 1 (starts at -1) */
+	page_map_lock(page);
+	page_mapcount_set(page, 0); /* elevate count by 1 (starts at -1) */
 	__page_set_anon_rmap(page, vma, address);
+	page_map_unlock(page);
 }
 
 /**
@@ -561,8 +573,10 @@ void page_add_new_anon_rmap(struct page 
  */
 void page_add_file_rmap(struct page *page)
 {
-	if (atomic_inc_and_test(&page->_mapcount))
+	page_map_lock(page);
+	if (page_mapcount_inc_and_test(page))
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
+	page_map_unlock(page);
 }
 
 /**
@@ -573,7 +587,8 @@ void page_add_file_rmap(struct page *pag
  */
 void page_remove_rmap(struct page *page, struct vm_area_struct *vma)
 {
-	if (atomic_add_negative(-1, &page->_mapcount)) {
+	page_map_lock(page);
+	if (page_mapcount_add_negative(-1, page)) {
 		if (unlikely(page_mapcount(page) < 0)) {
 			printk (KERN_EMERG "Eeek! page_mapcount(page) went negative! (%d)\n", page_mapcount(page));
 			printk (KERN_EMERG "  page pfn = %lx\n", page_to_pfn(page));
@@ -602,6 +617,7 @@ void page_remove_rmap(struct page *page,
 		__dec_zone_page_state(page,
 				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
 	}
+	page_map_unlock(page);
 }
 
 /*
@@ -622,7 +638,7 @@ static int try_to_unmap_one(struct page 
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl);
+	pte = page_check_address(page, mm, address, &ptl, true);
 	if (!pte)
 		goto out;
 
@@ -861,6 +877,7 @@ static int try_to_unmap_file(struct page
 	 * The mapcount of the page we came in with is irrelevant,
 	 * but even so use it as a guide to how hard we should try?
 	 */
+	page_map_unlock(page);
 	mapcount = page_mapcount(page);
 	if (!mapcount)
 		goto out;
@@ -882,7 +899,7 @@ static int try_to_unmap_file(struct page
 				cursor += CLUSTER_SIZE;
 				vma->vm_private_data = (void *) cursor;
 				if ((int)mapcount <= 0)
-					goto out;
+					goto relock;
 			}
 			vma->vm_private_data = (void *) max_nl_cursor;
 		}
@@ -897,6 +914,8 @@ static int try_to_unmap_file(struct page
 	 */
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_private_data = NULL;
+relock:
+	page_map_lock(page);
 out:
 	spin_unlock(&mapping->i_mmap_lock);
 	return ret;
@@ -929,4 +948,3 @@ int try_to_unmap(struct page *page, int 
 		ret = SWAP_SUCCESS;
 	return ret;
 }
-
diff -puN mm/vmscan.c~add-page-map-lock mm/vmscan.c
--- linux-2.6.20-rc2/mm/vmscan.c~add-page-map-lock	2006-12-29 14:48:07.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/vmscan.c	2006-12-29 14:48:07.000000000 +0530
@@ -472,6 +472,7 @@ static unsigned long shrink_page_list(st
 		VM_BUG_ON(PageActive(page));
 
 		sc->nr_scanned++;
+		page_map_lock(page);
 
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
@@ -485,17 +486,22 @@ static unsigned long shrink_page_list(st
 
 		referenced = page_referenced(page, 1);
 		/* In active use or really unfreeable?  Activate it. */
-		if (referenced && page_mapping_inuse(page))
+		if (referenced && page_mapping_inuse(page)) {
+			page_map_unlock(page);
 			goto activate_locked;
+		}
 
 #ifdef CONFIG_SWAP
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page))
+		if (PageAnon(page) && !PageSwapCache(page)) {
+			page_map_unlock(page);
 			if (!add_to_swap(page, GFP_ATOMIC))
 				goto activate_locked;
+			page_map_lock(page);
+		}
 #endif /* CONFIG_SWAP */
 
 		mapping = page_mapping(page);
@@ -509,13 +515,16 @@ static unsigned long shrink_page_list(st
 		if (page_mapped(page) && mapping) {
 			switch (try_to_unmap(page, 0)) {
 			case SWAP_FAIL:
+				page_map_unlock(page);
 				goto activate_locked;
 			case SWAP_AGAIN:
+				page_map_unlock(page);
 				goto keep_locked;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
 		}
+		page_map_unlock(page);
 
 		if (PageDirty(page)) {
 			if (referenced)
@@ -833,12 +842,21 @@ force_reclaim_mapped:
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
 		if (page_mapped(page)) {
-			if (!reclaim_mapped ||
-			    (total_swap_pages == 0 && PageAnon(page)) ||
-			    page_referenced(page, 0)) {
+			if (!reclaim_mapped) {
 				list_add(&page->lru, &l_active);
 				continue;
 			}
+			page_map_lock(page);
+			if (page_referenced(page, 0)) {
+				page_map_unlock(page);
+				list_add(&page->lru, &l_active);
+				continue;
+			}
+			page_map_unlock(page);
+		}
+		if (total_swap_pages == 0 && PageAnon(page)) {
+			list_add(&page->lru, &l_active);
+			continue;
 		}
 		list_add(&page->lru, &l_inactive);
 	}
diff -puN include/linux/mm.h~add-page-map-lock include/linux/mm.h
--- linux-2.6.20-rc2/include/linux/mm.h~add-page-map-lock	2006-12-29 14:48:07.000000000 +0530
+++ linux-2.6.20-rc2-balbir/include/linux/mm.h	2006-12-29 14:48:07.000000000 +0530
@@ -602,6 +602,52 @@ static inline pgoff_t page_index(struct 
 	return page->index;
 }
 
+#ifdef CONFIG_SHARED_PAGE_ACCOUNTING
+/*
+ * Under SHARED_PAGE_ACCOUNTING, all these operations take place under
+ * the rmap page lock (page_map_*lock)
+ */
+static inline void reset_page_mapcount(struct page *page)
+{
+	(page)->_mapcount = -1;
+}
+
+static inline int page_mapcount(struct page *page)
+{
+	return (page)->_mapcount + 1;
+}
+
+/*
+ * Return true if this page is mapped into pagetables.
+ */
+static inline int page_mapped(struct page *page)
+{
+	return (page)->_mapcount >= 0;
+}
+
+static inline int page_mapcount_inc_and_test(struct page *page)
+{
+	page->_mapcount++;
+	return (page->_mapcount == 0);
+}
+
+static inline void page_mapcount_inc(struct page *page)
+{
+	page->_mapcount++;
+}
+
+static inline int page_mapcount_add_negative(int val, struct page *page)
+{
+	page->_mapcount += val;
+	return (page->_mapcount < 0);
+}
+
+static inline void page_mapcount_set(struct page *page, int val)
+{
+	page->_mapcount = val;
+}
+
+#else
 /*
  * The atomic page->_mapcount, like _count, starts from -1:
  * so that transitions both from it and to it can be tracked,
@@ -625,6 +671,27 @@ static inline int page_mapped(struct pag
 	return atomic_read(&(page)->_mapcount) >= 0;
 }
 
+static inline int page_mapcount_inc_and_test(struct page *page)
+{
+	return atomic_inc_and_test(&(page)->_mapcount);
+}
+
+static inline void page_mapcount_inc(struct page *page)
+{
+	atomic_inc(&(page)->_mapcount);
+}
+
+static inline int page_mapcount_add_negative(int val, struct page *page)
+{
+	return atomic_add_negative(val, &(page)->_mapcount);
+}
+
+static inline int page_mapcount_set(struct page *page, int val)
+{
+	atomic_set(&(page)->_mapcount, val);
+}
+#endif
+
 /*
  * Error return values for the *_nopage functions
  */
diff -puN mm/page_alloc.c~add-page-map-lock mm/page_alloc.c
--- linux-2.6.20-rc2/mm/page_alloc.c~add-page-map-lock	2006-12-29 14:48:07.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/page_alloc.c	2006-12-29 14:48:07.000000000 +0530
@@ -199,7 +199,8 @@ static void bad_page(struct page *page)
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
-			1 << PG_buddy );
+			1 << PG_buddy 	  |
+			1 << PG_maplock);
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
@@ -434,7 +435,8 @@ static inline int free_pages_check(struc
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy	 |
+			1 << PG_maplock))))
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
@@ -584,7 +586,8 @@ static int prep_new_page(struct page *pa
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy	 |
+			1 << PG_maplock))))
 		bad_page(page);
 
 	/*
diff -puN include/linux/mm_types.h~add-page-map-lock include/linux/mm_types.h
--- linux-2.6.20-rc2/include/linux/mm_types.h~add-page-map-lock	2006-12-29 14:48:07.000000000 +0530
+++ linux-2.6.20-rc2-balbir/include/linux/mm_types.h	2006-12-29 14:48:07.000000000 +0530
@@ -8,6 +8,12 @@
 
 struct address_space;
 
+#ifdef CONFIG_SHARED_PAGE_ACCOUNTING
+typedef long 		mapcount_t;
+#else
+typedef atomic_t 	mapcount_t;
+#endif
+
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -19,7 +25,7 @@ struct page {
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	atomic_t _count;		/* Usage count, see below. */
-	atomic_t _mapcount;		/* Count of ptes mapped in mms,
+	mapcount_t _mapcount;		/* Count of ptes mapped in mms,
 					 * to show when page is mapped
 					 * & limit reverse map searches.
 					 */
diff -puN init/Kconfig~add-page-map-lock init/Kconfig
--- linux-2.6.20-rc2/init/Kconfig~add-page-map-lock	2006-12-29 14:48:07.000000000 +0530
+++ linux-2.6.20-rc2-balbir/init/Kconfig	2006-12-29 14:48:07.000000000 +0530
@@ -280,6 +280,17 @@ config RELAY
 
 	  If unsure, say N.
 
+config SHARED_PAGE_ACCOUNTING
+	bool "Enable support for accounting shared pages in RSS"
+	help
+	  This option enables accounting of pages shared among several
+	  processes in the system.
+	  The RSS (Resident Set Size) of a process is tracked for shared
+	  pages, to enable finer accounting of pages used by a process.
+	  The accounting is more accurate and comes with a certain overhead
+
+	  If unsure, say N
+
 source "usr/Kconfig"
 
 config CC_OPTIMIZE_FOR_SIZE
diff -puN mm/page-writeback.c~add-page-map-lock mm/page-writeback.c
diff -puN mm/filemap_xip.c~add-page-map-lock mm/filemap_xip.c
--- linux-2.6.20-rc2/mm/filemap_xip.c~add-page-map-lock	2006-12-29 14:48:07.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/filemap_xip.c	2006-12-29 14:48:07.000000000 +0530
@@ -184,7 +184,7 @@ __xip_unmap (struct address_space * mapp
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 		page = ZERO_PAGE(address);
-		pte = page_check_address(page, mm, address, &ptl);
+		pte = page_check_address(page, mm, address, &ptl, false);
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
_

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
