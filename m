Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id kBTAMThG334776
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:22:59 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBTACiI5255528
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:12:44 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBTA9F8U016695
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:09:15 +1100
From: Balbir Singh <balbir@in.ibm.com>
Date: Fri, 29 Dec 2006 15:39:07 +0530
Message-Id: <20061229100907.13860.88466.sendpatchset@balbir.in.ibm.com>
In-Reply-To: <20061229100839.13860.15525.sendpatchset@balbir.in.ibm.com>
References: <20061229100839.13860.15525.sendpatchset@balbir.in.ibm.com>
Subject: [RFC][PATCH 3/3] Add shared page accounting
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com, akpm@osdl.org, andyw@uk.ibm.com
Cc: linux-mm@kvack.org, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>


This patch adds shared page accounting, a page that is shared between two
or more mm_struct's is accounted as shared. When the _mapcount of a page
reaches 1 (while adding rmap information), it means that the page is now
shared. Using rmap, the other shared mm_struct is found and accounting
is adjusted for both mm_structs. From here on, any other mm_struct
mapping this page, will only increment it's shared rss.  Similarly, when a page
is unshared (_mapcount reaches 0 during page_remove_rmap) accounting is
adjusted by searching for the shared mm_struct.

To account for shared pages two new counters anon_rss_shared and file_rss_shared
have been added to mm_struct.

The patch depends on page_map_lock to ensure that rmap information does not
change, while searching for the shared mm_struct. Pte set and clear has been
moved to after the invocation of page_add_anon/file_rmap() and
page_remove_rmap(). This ensures that we will find the shared mm_struct
(page is found mapped in the mm_struct) when we search for it using rmap.

Signed-off-by: Balbir Singh <balbir@in.ibm.com>
---

 fs/exec.c             |    2 
 fs/proc/task_mmu.c    |    4 -
 include/linux/mm.h    |   25 ++-----
 include/linux/rmap.h  |   37 ++++++++--
 include/linux/sched.h |  118 +++++++++++++++++++++++++++++++++-
 kernel/fork.c         |    2 
 mm/filemap_xip.c      |    2 
 mm/fremap.c           |    8 +-
 mm/memory.c           |   11 +--
 mm/migrate.c          |    2 
 mm/rmap.c             |  173 ++++++++++++++++++++++++++++++++++++++++++++++----
 mm/swapfile.c         |    2 
 12 files changed, 335 insertions(+), 51 deletions(-)

diff -puN mm/rmap.c~add-shared-accounting mm/rmap.c
--- linux-2.6.20-rc2/mm/rmap.c~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/rmap.c	2006-12-29 14:49:31.000000000 +0530
@@ -541,10 +541,15 @@ static void __page_set_anon_rmap(struct 
 void page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
+	int count;
+	struct mm_struct *shared_mm;
 	page_map_lock(page);
-	if (page_mapcount_inc_and_test(page))
+	count = page_mapcount_add_and_return(1, page);
+	if (count == 0)
 		__page_set_anon_rmap(page, vma, address);
-	inc_mm_counter(vma->vm_mm, anon_rss);
+	if (count == 1)
+		shared_mm = find_shared_anon_mm(page, vma->vm_mm);
+	inc_mm_counter_anon_shared(vma->vm_mm, shared_mm, count);
 	page_map_unlock(page);
 }
 
@@ -575,10 +580,23 @@ void page_add_new_anon_rmap(struct page 
  */
 void page_add_file_rmap(struct page *page, struct mm_struct *mm)
 {
+	int count;
+	struct mm_struct *shared_mm;
 	page_map_lock(page);
-	if (page_mapcount_inc_and_test(page))
+	count = page_mapcount_add_and_return(1, page);
+	if (count == 0)
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-	inc_mm_counter(mm, file_rss);
+	/*
+	 * ZERO_PAGE(vaddr), does not really use the vaddr
+	 * parameter
+	 */
+	if (page == ZERO_PAGE(0))
+		inc_mm_counter(mm, file_rss_shared);
+	else {
+		if (count == 1)
+			shared_mm = find_shared_file_mm(page, mm);
+		inc_mm_counter_file_shared(mm, shared_mm, count);
+	}
 	page_map_unlock(page);
 }
 
@@ -591,8 +609,12 @@ void page_add_file_rmap(struct page *pag
 void page_remove_rmap(struct page *page, struct vm_area_struct *vma)
 {
 	int anon = PageAnon(page);
+	int count;
+	struct mm_struct *shared_mm;
+
 	page_map_lock(page);
-	if (page_mapcount_add_negative(-1, page)) {
+	count = page_mapcount_add_and_return(-1, page);
+	if (count < 0) {
 		if (unlikely(page_mapcount(page) < 0)) {
 			printk (KERN_EMERG "Eeek! page_mapcount(page) went negative! (%d)\n", page_mapcount(page));
 			printk (KERN_EMERG "  page pfn = %lx\n", page_to_pfn(page));
@@ -621,10 +643,20 @@ void page_remove_rmap(struct page *page,
 		__dec_zone_page_state(page,
 				anon ? NR_ANON_PAGES : NR_FILE_MAPPED);
 	}
-	if (anon)
-		dec_mm_counter(vma->vm_mm, anon_rss);
-	else
-		dec_mm_counter(vma->vm_mm, file_rss);
+	if (anon) {
+		if (count == 0)
+			shared_mm = find_shared_anon_mm(page, vma->vm_mm);
+		dec_mm_counter_anon_shared(vma->vm_mm, shared_mm, count);
+	} else {
+		if (page == ZERO_PAGE(0))
+			dec_mm_counter(vma->vm_mm, file_rss_shared);
+		else {
+			if (count == 0)
+				shared_mm = find_shared_file_mm(page,
+								vma->vm_mm);
+			dec_mm_counter_file_shared(vma->vm_mm, shared_mm, count);
+		}
+	}
 	page_map_unlock(page);
 }
 
@@ -671,6 +703,7 @@ static int try_to_unmap_one(struct page 
 
 	/* Update high watermark before we lower rss */
 	update_hiwater_rss(mm);
+	page_remove_rmap(page, vma);
 
 	if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
@@ -709,7 +742,6 @@ static int try_to_unmap_one(struct page 
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 #endif
 
-	page_remove_rmap(page, vma);
 	page_cache_release(page);
 
 out_unmap:
@@ -784,6 +816,7 @@ static void try_to_unmap_cluster(unsigne
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
 
+		page_remove_rmap(page, vma);
 		if (ptep_clear_flush_young(vma, address, pte))
 			continue;
 
@@ -799,7 +832,6 @@ static void try_to_unmap_cluster(unsigne
 		if (pte_dirty(pteval))
 			set_page_dirty(page);
 
-		page_remove_rmap(page, vma);
 		page_cache_release(page);
 		(*mapcount)--;
 	}
@@ -951,3 +983,122 @@ int try_to_unmap(struct page *page, int 
 		ret = SWAP_SUCCESS;
 	return ret;
 }
+
+#ifdef CONFIG_SHARED_PAGE_ACCOUNTING
+/*
+ * This routine should be called with the pte lock held
+ */
+static int page_in_vma(struct vm_area_struct *vma, struct page *page,
+			int linear)
+{
+	int ret = 0;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	unsigned long address;
+
+	if (linear) {
+		address = vma_address(page, vma);
+		if (address == -EFAULT)
+			return 0;
+	} else {
+		address = vma->vm_start;
+	}
+
+	pgd = pgd_offset(vma->vm_mm, address);
+	if (!pgd_present(*pgd))
+		return 0;
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return 0;
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
+		return 0;
+
+	pte = pte_offset_map(pmd, address);
+	if (linear) {
+		if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
+			ret = 1;
+		}
+	} else {
+		unsigned long end = vma->vm_end;
+
+		for (; address < end; address += PAGE_SIZE) {
+			if (page_to_pfn(page) == pte_pfn(*pte)) {
+				ret = 1;
+				break;
+			}
+		}
+	}
+	pte_unmap(pte);
+
+	return ret;
+}
+
+/*
+ * This routine should be called with the page_map_lock() held
+ */
+struct mm_struct *find_shared_anon_mm(struct page *page, struct mm_struct *mm)
+{
+	struct mm_struct *oth_mm = NULL;
+
+	struct anon_vma *anon_vma;
+	struct vm_area_struct *vma;
+
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return NULL;
+	/*
+	 * Search through anon_vma's
+	 */
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		if ((vma->vm_mm != mm) && page_in_vma(vma, page, 1)) {
+			oth_mm = vma->vm_mm;
+			break;
+		}
+	}
+	spin_unlock(&anon_vma->lock);
+
+	return oth_mm;
+}
+
+/*
+ * This routine should be called with the page_map_lock() held
+ */
+struct mm_struct *find_shared_file_mm(struct page *page, struct mm_struct *mm)
+{
+	struct mm_struct *oth_mm = NULL;
+
+	/*
+	 * TODO: Can we hold i_mmap_lock and is it safe to use
+	 * page_mapping() here?
+	 */
+	struct address_space *mapping = page_mapping(page);
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+
+	if (!mapping)
+		return NULL;
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)
+		if ((vma->vm_mm != mm) && page_in_vma(vma, page, 1)) {
+			oth_mm = vma->vm_mm;
+			break;
+		}
+
+	if (mm || list_empty(&mapping->i_mmap_nonlinear))
+		goto done;
+
+	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
+		if ((vma->vm_mm != mm) && page_in_vma(vma, page, 1)) {
+			oth_mm = vma->vm_mm;
+			break;
+		}
+done:
+	spin_unlock(&mapping->i_mmap_lock);
+	return oth_mm;
+}
+#endif /* CONFIG_SHARED_PAGE_ACCOUNTING */
diff -puN include/linux/sched.h~add-shared-accounting include/linux/sched.h
--- linux-2.6.20-rc2/include/linux/sched.h~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/include/linux/sched.h	2006-12-29 14:49:31.000000000 +0530
@@ -295,8 +295,22 @@ typedef unsigned long mm_counter_t;
 
 #endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
 
-#define get_mm_rss(mm)					\
-	(get_mm_counter(mm, file_rss) + get_mm_counter(mm, anon_rss))
+#ifdef CONFIG_SHARED_PAGE_ACCOUNTING
+#define get_mm_rss_shared(mm)			\
+	(get_mm_counter(mm, file_rss_shared) +	\
+	 get_mm_counter(mm, anon_rss_shared))
+#define get_mm_rss_unshared(mm)			\
+	(get_mm_counter(mm, file_rss) +		\
+	 get_mm_counter(mm, anon_rss))
+#else
+#define get_mm_rss_shared(mm) get_mm_counter(mm, file_rss)
+#define get_mm_rss_unshared(mm) get_mm_counter(mm, anon_rss)
+#endif /* CONFIG_SHARED_PAGE_ACCOUNTING */
+
+#define get_mm_rss(mm)							\
+	(get_mm_counter(mm, file_rss) + get_mm_counter(mm, anon_rss) + 	\
+	 get_mm_counter(mm, file_rss_shared) + 				\
+	 get_mm_counter(mm, anon_rss_shared))
 #define update_hiwater_rss(mm)	do {			\
 	unsigned long _rss = get_mm_rss(mm);		\
 	if ((mm)->hiwater_rss < _rss)			\
@@ -336,6 +350,8 @@ struct mm_struct {
 	 */
 	mm_counter_t _file_rss;
 	mm_counter_t _anon_rss;
+	mm_counter_t _file_rss_shared;
+	mm_counter_t _anon_rss_shared;
 
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
@@ -375,6 +391,104 @@ struct mm_struct {
 	struct kioctx		*ioctx_list;
 };
 
+#ifdef CONFIG_SHARED_PAGE_ACCOUNTING
+static inline void inc_mm_counter_anon_shared(struct mm_struct *mm,
+						struct mm_struct *shared_mm,
+						int count)
+{
+	if (count == 1) {	/* This page is now being shared */
+		if (shared_mm) {
+			inc_mm_counter(mm, anon_rss_shared);
+			inc_mm_counter(shared_mm, anon_rss_shared);
+			dec_mm_counter(shared_mm, anon_rss);
+		} else  /* this page cannot be shared via rmap */
+			inc_mm_counter(mm, anon_rss_shared);
+	} else if (count > 1)
+		inc_mm_counter(mm, anon_rss_shared);
+	else
+		inc_mm_counter(mm, anon_rss);
+}
+
+static inline void inc_mm_counter_file_shared(struct mm_struct *mm,
+						struct mm_struct *shared_mm,
+						int count)
+{
+	if (count == 1) {	/* This page is now being shared */
+		if (shared_mm) {
+			inc_mm_counter(mm, file_rss_shared);
+			inc_mm_counter(shared_mm, file_rss_shared);
+			dec_mm_counter(shared_mm, file_rss);
+		} else /* cannot be shared with rmap, bump shared count */
+			inc_mm_counter(mm, file_rss_shared);
+	} else if (count > 1)
+		inc_mm_counter(mm, file_rss_shared);
+	else
+		inc_mm_counter(mm, file_rss);
+}
+
+static inline void dec_mm_counter_anon_shared(struct mm_struct *mm,
+						struct mm_struct *shared_mm,
+						int count)
+{
+	if (count == 0) {	/* This page is now being unshared */
+		if (shared_mm) {
+			dec_mm_counter(mm, anon_rss_shared);
+			dec_mm_counter(shared_mm, anon_rss_shared);
+			inc_mm_counter(shared_mm, anon_rss);
+		} else
+			dec_mm_counter(mm, anon_rss_shared);
+	} else if (count > 0)
+		dec_mm_counter(mm, anon_rss_shared);
+	else
+		dec_mm_counter(mm, anon_rss);
+}
+
+static inline void dec_mm_counter_file_shared(struct mm_struct *mm,
+						struct mm_struct *shared_mm,
+						int count)
+{
+	if (count == 0) {	/* This page is now being shared */
+		if (shared_mm) {
+			dec_mm_counter(mm, file_rss_shared);
+			dec_mm_counter(shared_mm, file_rss_shared);
+			inc_mm_counter(shared_mm, file_rss);
+		} else
+			dec_mm_counter(mm, file_rss_shared);
+	} else if (count > 0)
+		dec_mm_counter(mm, file_rss_shared);
+	else
+		dec_mm_counter(mm, file_rss);
+}
+#else
+static inline void inc_mm_counter_anon_shared(struct mm_struct *mm,
+						struct mm_struct *shared_mm,
+						int count)
+{
+	inc_mm_counter(mm, anon_rss);
+}
+
+static inline void inc_mm_counter_file_shared(struct mm_struct *mm,
+						struct mm_struct *shared_mm,
+						int count)
+{
+	inc_mm_counter(mm, file_rss);
+}
+
+static inline void dec_mm_counter_anon_shared(struct mm_struct *mm,
+						struct mm_struct *shared_mm,
+						int count)
+{
+	dec_mm_counter(mm, anon_rss);
+}
+
+static inline void dec_mm_counter_file_shared(struct mm_struct *mm,
+						struct mm_struct *shared_mm,
+						int count)
+{
+	dec_mm_counter(mm, file_rss);
+}
+#endif /* CONFIG_SHARED_PAGE_ACCOUNTING */
+
 struct sighand_struct {
 	atomic_t		count;
 	struct k_sigaction	action[_NSIG];
diff -puN include/linux/rmap.h~add-shared-accounting include/linux/rmap.h
--- linux-2.6.20-rc2/include/linux/rmap.h~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/include/linux/rmap.h	2006-12-29 14:49:31.000000000 +0530
@@ -9,6 +9,7 @@
 #include <linux/mm.h>
 #include <linux/spinlock.h>
 #include <linux/bit_spinlock.h>
+#include <linux/sched.h>
 
 #ifdef CONFIG_SHARED_PAGE_ACCOUNTING
 #define page_map_lock(page) \
@@ -99,14 +100,21 @@ void page_remove_rmap(struct page *, str
  * For copy_page_range only: minimal extract from page_add_rmap,
  * avoiding unnecessary tests (already checked) so it's quicker.
  */
-static inline void page_dup_rmap(struct page *page, struct mm_struct *mm)
+static inline void page_dup_rmap(struct page *page, struct mm_struct *src_mm,
+					struct mm_struct *dst_mm)
 {
+	int count;
+	int anon = PageAnon(page);
 	page_map_lock(page);
-	page_mapcount_inc(page);
-	if (PageAnon(page))
-		inc_mm_counter(mm, anon_rss);
-	else
-		inc_mm_counter(mm, file_rss);
+	count = page_mapcount_add_and_return(1, page);
+	if (anon)
+		inc_mm_counter_anon_shared(dst_mm, src_mm, count);
+	else {
+		if (page == ZERO_PAGE(0))
+			inc_mm_counter(dst_mm, file_rss_shared);
+		else
+			inc_mm_counter_file_shared(dst_mm, src_mm, count);
+	}
 	page_map_unlock(page);
 }
 
@@ -135,6 +143,23 @@ unsigned long page_address_in_vma(struct
  */
 int page_mkclean(struct page *);
 
+#ifdef CONFIG_SHARED_PAGE_ACCOUNTING
+struct mm_struct *find_shared_anon_mm(struct page *page, struct mm_struct *mm);
+struct mm_struct *find_shared_file_mm(struct page *page, struct mm_struct *mm);
+#else
+static inline struct mm_struct *find_shared_anon_mm(struct page *page,
+							struct mm_struct *mm)
+{
+	return NULL;
+}
+
+static inline struct mm_struct *find_shared_file_mm(struct page *page,
+							struct mm_struct *mm)
+{
+	return NULL;
+}
+#endif  /* CONFIG_SHARED_PAGE_ACCOUNTING */
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)
diff -puN kernel/fork.c~add-shared-accounting kernel/fork.c
--- linux-2.6.20-rc2/kernel/fork.c~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/kernel/fork.c	2006-12-29 14:49:31.000000000 +0530
@@ -335,6 +335,8 @@ static struct mm_struct * mm_init(struct
 	mm->nr_ptes = 0;
 	set_mm_counter(mm, file_rss, 0);
 	set_mm_counter(mm, anon_rss, 0);
+	set_mm_counter(mm, file_rss_shared, 0);
+	set_mm_counter(mm, anon_rss_shared, 0);
 	spin_lock_init(&mm->page_table_lock);
 	rwlock_init(&mm->ioctx_list_lock);
 	mm->ioctx_list = NULL;
diff -puN include/linux/mm.h~add-shared-accounting include/linux/mm.h
--- linux-2.6.20-rc2/include/linux/mm.h~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/include/linux/mm.h	2006-12-29 14:49:31.000000000 +0530
@@ -625,10 +625,10 @@ static inline int page_mapped(struct pag
 	return (page)->_mapcount >= 0;
 }
 
-static inline int page_mapcount_inc_and_test(struct page *page)
+static inline int page_mapcount_add_and_return(int val, struct page *page)
 {
-	page->_mapcount++;
-	return (page->_mapcount == 0);
+	page->_mapcount += val;
+	return page->_mapcount;
 }
 
 static inline void page_mapcount_inc(struct page *page)
@@ -636,12 +636,6 @@ static inline void page_mapcount_inc(str
 	page->_mapcount++;
 }
 
-static inline int page_mapcount_add_negative(int val, struct page *page)
-{
-	page->_mapcount += val;
-	return (page->_mapcount < 0);
-}
-
 static inline void page_mapcount_set(struct page *page, int val)
 {
 	page->_mapcount = val;
@@ -651,7 +645,7 @@ static inline void page_mapcount_set(str
 /*
  * The atomic page->_mapcount, like _count, starts from -1:
  * so that transitions both from it and to it can be tracked,
- * using atomic_inc_and_test and atomic_add_negative(-1).
+ * using atomic_inc_and_return and atomic_add_negative(-1).
  */
 static inline void reset_page_mapcount(struct page *page)
 {
@@ -671,9 +665,9 @@ static inline int page_mapped(struct pag
 	return atomic_read(&(page)->_mapcount) >= 0;
 }
 
-static inline int page_mapcount_inc_and_test(struct page *page)
+static inline int page_mapcount_add_and_return(int val, struct page *page)
 {
-	return atomic_inc_and_test(&(page)->_mapcount);
+	return atomic_add_return(val, &(page)->_mapcount);
 }
 
 static inline void page_mapcount_inc(struct page *page)
@@ -681,12 +675,7 @@ static inline void page_mapcount_inc(str
 	atomic_inc(&(page)->_mapcount);
 }
 
-static inline int page_mapcount_add_negative(int val, struct page *page)
-{
-	return atomic_add_negative(val, &(page)->_mapcount);
-}
-
-static inline int page_mapcount_set(struct page *page, int val)
+static inline void page_mapcount_set(struct page *page, int val)
 {
 	atomic_set(&(page)->_mapcount, val);
 }
diff -puN fs/exec.c~add-shared-accounting fs/exec.c
--- linux-2.6.20-rc2/fs/exec.c~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/fs/exec.c	2006-12-29 14:49:31.000000000 +0530
@@ -322,9 +322,9 @@ void install_arg_page(struct vm_area_str
 		goto out;
 	}
 	lru_cache_add_active(page);
+	page_add_new_anon_rmap(page, vma, address);
 	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
-	page_add_new_anon_rmap(page, vma, address);
 	pte_unmap_unlock(pte, ptl);
 
 	/* no need for flush_tlb */
diff -puN mm/fremap.c~add-shared-accounting mm/fremap.c
--- linux-2.6.20-rc2/mm/fremap.c~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/fremap.c	2006-12-29 14:49:31.000000000 +0530
@@ -27,13 +27,15 @@ static int zap_pte(struct mm_struct *mm,
 	struct page *page = NULL;
 
 	if (pte_present(pte)) {
+		page = vm_normal_page(vma, addr, pte);
+		if (page)
+			page_remove_rmap(page, vma);
+
 		flush_cache_page(vma, addr, pte_pfn(pte));
 		pte = ptep_clear_flush(vma, addr, ptep);
-		page = vm_normal_page(vma, addr, pte);
 		if (page) {
 			if (pte_dirty(pte))
 				set_page_dirty(page);
-			page_remove_rmap(page, vma);
 			page_cache_release(page);
 		}
 	} else {
@@ -79,9 +81,9 @@ int install_page(struct mm_struct *mm, s
 		zap_pte(mm, vma, addr, pte);
 
 	flush_icache_page(vma, page);
+	page_add_file_rmap(page, mm);
 	pte_val = mk_pte(page, prot);
 	set_pte_at(mm, addr, pte, pte_val);
-	page_add_file_rmap(page, mm);
 	update_mmu_cache(vma, addr, pte_val);
 	lazy_mmu_prot_update(pte_val);
 	err = 0;
diff -puN mm/memory.c~add-shared-accounting mm/memory.c
--- linux-2.6.20-rc2/mm/memory.c~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/memory.c	2006-12-29 14:49:31.000000000 +0530
@@ -473,7 +473,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page, dst_mm);
+		page_dup_rmap(page, src_mm, dst_mm);
 	}
 
 out_set_pte:
@@ -648,6 +648,8 @@ static unsigned long zap_pte_range(struc
 				     page->index > details->last_index))
 					continue;
 			}
+			if (page)
+				page_remove_rmap(page, vma);
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
 			tlb_remove_tlb_entry(tlb, pte, addr);
@@ -664,7 +666,6 @@ static unsigned long zap_pte_range(struc
 				if (pte_young(ptent))
 					mark_page_accessed(page);
 			}
-			page_remove_rmap(page, vma);
 			tlb_remove_page(tlb, page);
 			continue;
 		}
@@ -1579,10 +1580,10 @@ gotten:
 		 * thread doing COW.
 		 */
 		ptep_clear_flush(vma, address, page_table);
+		page_add_new_anon_rmap(new_page, vma, address);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		lru_cache_add_active(new_page);
-		page_add_new_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
 		new_page = old_page;
@@ -2020,8 +2021,8 @@ static int do_swap_page(struct mm_struct
 	}
 
 	flush_icache_page(vma, page);
-	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
+	set_pte_at(mm, address, page_table, pte);
 
 	swap_free(entry);
 	if (vm_swap_full())
@@ -2221,7 +2222,6 @@ retry:
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			lru_cache_add_active(new_page);
 			page_add_new_anon_rmap(new_page, vma, address);
@@ -2232,6 +2232,7 @@ retry:
 				get_page(dirty_page);
 			}
 		}
+		set_pte_at(mm, address, page_table, entry);
 	} else {
 		/* One of our sibling threads was faster, back out. */
 		page_cache_release(new_page);
diff -puN mm/migrate.c~add-shared-accounting mm/migrate.c
--- linux-2.6.20-rc2/mm/migrate.c~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/migrate.c	2006-12-29 14:49:31.000000000 +0530
@@ -172,13 +172,13 @@ static void remove_migration_pte(struct 
 	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
 	if (is_write_migration_entry(entry))
 		pte = pte_mkwrite(pte);
-	set_pte_at(mm, addr, ptep, pte);
 
 	if (PageAnon(new))
 		page_add_anon_rmap(new, vma, addr);
 	else
 		page_add_file_rmap(new, mm);
 
+	set_pte_at(mm, addr, ptep, pte);
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, pte);
 	lazy_mmu_prot_update(pte);
diff -puN mm/swapfile.c~add-shared-accounting mm/swapfile.c
--- linux-2.6.20-rc2/mm/swapfile.c~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/swapfile.c	2006-12-29 14:49:31.000000000 +0530
@@ -504,9 +504,9 @@ static void unuse_pte(struct vm_area_str
 		unsigned long addr, swp_entry_t entry, struct page *page)
 {
 	get_page(page);
+	page_add_anon_rmap(page, vma, addr);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
-	page_add_anon_rmap(page, vma, addr);
 	swap_free(entry);
 	/*
 	 * Move the page to the active list so it is not
diff -puN mm/filemap_xip.c~add-shared-accounting mm/filemap_xip.c
--- linux-2.6.20-rc2/mm/filemap_xip.c~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/filemap_xip.c	2006-12-29 14:49:31.000000000 +0530
@@ -186,10 +186,10 @@ __xip_unmap (struct address_space * mapp
 		page = ZERO_PAGE(address);
 		pte = page_check_address(page, mm, address, &ptl, false);
 		if (pte) {
+			page_remove_rmap(page, vma);
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush(vma, address, pte);
-			page_remove_rmap(page, vma);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			page_cache_release(page);
diff -puN fs/proc/task_mmu.c~add-shared-accounting fs/proc/task_mmu.c
--- linux-2.6.20-rc2/fs/proc/task_mmu.c~add-shared-accounting	2006-12-29 14:49:31.000000000 +0530
+++ linux-2.6.20-rc2-balbir/fs/proc/task_mmu.c	2006-12-29 14:49:31.000000000 +0530
@@ -63,11 +63,11 @@ unsigned long task_vsize(struct mm_struc
 int task_statm(struct mm_struct *mm, int *shared, int *text,
 	       int *data, int *resident)
 {
-	*shared = get_mm_counter(mm, file_rss);
+	*shared = get_mm_rss_shared(mm);
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
 	*data = mm->total_vm - mm->shared_vm;
-	*resident = *shared + get_mm_counter(mm, anon_rss);
+	*resident = *shared + get_mm_rss_unshared(mm);
 	return mm->total_vm;
 }
 
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
