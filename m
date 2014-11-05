Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 530986B00A5
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:47 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so872320pdb.39
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:47 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id uv6si3082252pbc.255.2014.11.05.06.50.44
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:45 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 06/19] mm: store mapcount for compound page separate
Date: Wed,  5 Nov 2014 16:49:41 +0200
Message-Id: <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to allow mapping of individual 4k pages of THP compound and
we need a cheap way to find out how many time the compound page is
mapped with PMD -- compound_mapcount() does this.

page_mapcount() counts both: PTE and PMD mappings of the page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h   | 17 +++++++++++++++--
 include/linux/rmap.h |  4 ++--
 mm/huge_memory.c     | 23 ++++++++++++++---------
 mm/hugetlb.c         |  4 ++--
 mm/memory.c          |  2 +-
 mm/migrate.c         |  2 +-
 mm/page_alloc.c      | 13 ++++++++++---
 mm/rmap.c            | 50 +++++++++++++++++++++++++++++++++++++++++++-------
 8 files changed, 88 insertions(+), 27 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1825c468f158..aef03acff228 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -435,6 +435,19 @@ static inline struct page *compound_head(struct page *page)
 	return page;
 }
 
+static inline atomic_t *compound_mapcount_ptr(struct page *page)
+{
+	return (atomic_t *)&page[1].mapping;
+}
+
+static inline int compound_mapcount(struct page *page)
+{
+	if (!PageCompound(page))
+		return 0;
+	page = compound_head(page);
+	return atomic_read(compound_mapcount_ptr(page)) + 1;
+}
+
 /*
  * The atomic page->_mapcount, starts from -1: so that transitions
  * both from it and to it can be tracked, using atomic_inc_and_test
@@ -447,7 +460,7 @@ static inline void page_mapcount_reset(struct page *page)
 
 static inline int page_mapcount(struct page *page)
 {
-	return atomic_read(&(page)->_mapcount) + 1;
+	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) + 1;
 }
 
 static inline int page_count(struct page *page)
@@ -1017,7 +1030,7 @@ static inline pgoff_t page_file_index(struct page *page)
  */
 static inline int page_mapped(struct page *page)
 {
-	return atomic_read(&(page)->_mapcount) >= 0;
+	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >= 0;
 }
 
 /*
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index ef09ca48c789..a9499ad8c037 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -180,9 +180,9 @@ void hugepage_add_anon_rmap(struct page *, struct vm_area_struct *,
 void hugepage_add_new_anon_rmap(struct page *, struct vm_area_struct *,
 				unsigned long);
 
-static inline void page_dup_rmap(struct page *page)
+static inline void page_dup_rmap(struct page *page, bool compound)
 {
-	atomic_inc(&page->_mapcount);
+	atomic_inc(compound ? compound_mapcount_ptr(page) : &page->_mapcount);
 }
 
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9c53800c4eea..869f9bcf481e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -904,7 +904,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	src_page = pmd_page(pmd);
 	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
 	get_page(src_page);
-	page_dup_rmap(src_page);
+	page_dup_rmap(src_page, true);
 	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
@@ -1763,8 +1763,8 @@ static void __split_huge_page_refcount(struct page *page,
 		struct page *page_tail = page + i;
 
 		/* tail_page->_mapcount cannot change */
-		BUG_ON(page_mapcount(page_tail) < 0);
-		tail_count += page_mapcount(page_tail);
+		BUG_ON(atomic_read(&page_tail->_mapcount) + 1 < 0);
+		tail_count += atomic_read(&page_tail->_mapcount) + 1;
 		/* check for overflow */
 		BUG_ON(tail_count < 0);
 		BUG_ON(atomic_read(&page_tail->_count) != 0);
@@ -1781,8 +1781,7 @@ static void __split_huge_page_refcount(struct page *page,
 		 * atomic_set() here would be safe on all archs (and
 		 * not only on x86), it's safer to use atomic_add().
 		 */
-		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
-			   &page_tail->_count);
+		atomic_add(page_mapcount(page_tail) + 1, &page_tail->_count);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb__after_atomic();
@@ -1819,15 +1818,18 @@ static void __split_huge_page_refcount(struct page *page,
 		 * status is achieved setting a reserved bit in the
 		 * pmd, not by clearing the present bit.
 		*/
-		page_tail->_mapcount = page->_mapcount;
+		atomic_set(&page_tail->_mapcount, compound_mapcount(page) - 1);
 
-		BUG_ON(page_tail->mapping);
-		page_tail->mapping = page->mapping;
+		/* ->mapping in first tail page is compound_mapcount */
+		if (i != 1) {
+			BUG_ON(page_tail->mapping);
+			page_tail->mapping = page->mapping;
+			BUG_ON(!PageAnon(page_tail));
+		}
 
 		page_tail->index = page->index + i;
 		page_cpupid_xchg_last(page_tail, page_cpupid_last(page));
 
-		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
 		BUG_ON(!PageDirty(page_tail));
 		BUG_ON(!PageSwapBacked(page_tail));
@@ -1837,6 +1839,9 @@ static void __split_huge_page_refcount(struct page *page,
 	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
+	page->_mapcount = *compound_mapcount_ptr(page);
+	page[1].mapping = page->mapping;
+
 	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
 
 	ClearPageCompound(page);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index dad8e0732922..445db64a8b08 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2603,7 +2603,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			entry = huge_ptep_get(src_pte);
 			ptepage = pte_page(entry);
 			get_page(ptepage);
-			page_dup_rmap(ptepage);
+			page_dup_rmap(ptepage, true);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
 		spin_unlock(src_ptl);
@@ -3058,7 +3058,7 @@ retry:
 		ClearPagePrivate(page);
 		hugepage_add_new_anon_rmap(page, vma, address);
 	} else
-		page_dup_rmap(page);
+		page_dup_rmap(page, true);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);
diff --git a/mm/memory.c b/mm/memory.c
index 6f84c8a51cc0..1b17a72dc93f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -872,7 +872,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page);
+		page_dup_rmap(page, false);
 		if (PageAnon(page))
 			rss[MM_ANONPAGES]++;
 		else
diff --git a/mm/migrate.c b/mm/migrate.c
index 6b9413df1661..f1a12ced2531 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -161,7 +161,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		if (PageAnon(new))
 			hugepage_add_anon_rmap(new, vma, addr);
 		else
-			page_dup_rmap(new);
+			page_dup_rmap(new, false);
 	} else if (PageAnon(new))
 		page_add_anon_rmap(new, vma, addr, false);
 	else
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d0e3d2fee585..b19d1e69ca12 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -369,6 +369,7 @@ void prep_compound_page(struct page *page, unsigned long order)
 
 	set_compound_page_dtor(page, free_compound_page);
 	set_compound_order(page, order);
+	atomic_set(compound_mapcount_ptr(page), -1);
 	__SetPageHead(page);
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
@@ -643,7 +644,9 @@ static inline int free_pages_check(struct page *page)
 
 	if (unlikely(page_mapcount(page)))
 		bad_reason = "nonzero mapcount";
-	if (unlikely(page->mapping != NULL))
+	if (unlikely(compound_mapcount(page)))
+		bad_reason = "nonzero compound_mapcount";
+	if (unlikely(page->mapping != NULL) && !PageTail(page))
 		bad_reason = "non-NULL mapping";
 	if (unlikely(atomic_read(&page->_count) != 0))
 		bad_reason = "nonzero _count";
@@ -760,6 +763,8 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 		bad += free_pages_check(page + i);
 	if (bad)
 		return false;
+	if (order)
+		page[1].mapping = NULL;
 
 	if (!PageHighMem(page)) {
 		debug_check_no_locks_freed(page_address(page),
@@ -6632,10 +6637,12 @@ static void dump_page_flags(unsigned long flags)
 void dump_page_badflags(struct page *page, const char *reason,
 		unsigned long badflags)
 {
-	printk(KERN_ALERT
-	       "page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
+	pr_alert("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
 		page, atomic_read(&page->_count), page_mapcount(page),
 		page->mapping, page->index);
+	if (PageCompound(page))
+		printk(" compound_mapcount: %d", compound_mapcount(page));
+	printk("\n");
 	dump_page_flags(page->flags);
 	if (reason)
 		pr_alert("page dumped because: %s\n", reason);
diff --git a/mm/rmap.c b/mm/rmap.c
index f706a6af1801..eecc9301847d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -986,9 +986,30 @@ void page_add_anon_rmap(struct page *page,
 void do_page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address, int flags)
 {
-	int first = atomic_inc_and_test(&page->_mapcount);
+	bool compound = flags & RMAP_COMPOUND;
+	bool first;
+
+	VM_BUG_ON_PAGE(!PageLocked(compound_head(page)), page);
+
+	if (PageTransCompound(page)) {
+		struct page *head_page = compound_head(page);
+
+		if (compound) {
+			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+			first = atomic_inc_and_test(compound_mapcount_ptr(page));
+		} else {
+			/* Anon THP always mapped first with PMD */
+			first = 0;
+			VM_BUG_ON_PAGE(!compound_mapcount(head_page),
+					head_page);
+			atomic_inc(&page->_mapcount);
+		}
+	} else {
+		VM_BUG_ON_PAGE(compound, page);
+		first = atomic_inc_and_test(&page->_mapcount);
+	}
+
 	if (first) {
-		bool compound = flags & RMAP_COMPOUND;
 		int nr = compound ? hpage_nr_pages(page) : 1;
 		/*
 		 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
@@ -1006,7 +1027,6 @@ void do_page_add_anon_rmap(struct page *page,
 	if (unlikely(PageKsm(page)))
 		return;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	/* address might be in next vma when migration races vma_adjust */
 	if (first)
 		__page_set_anon_rmap(page, vma, address,
@@ -1032,10 +1052,19 @@ void page_add_new_anon_rmap(struct page *page,
 
 	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	SetPageSwapBacked(page);
-	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (compound) {
+		atomic_t *compound_mapcount;
+
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		compound_mapcount = (atomic_t *)&page[1].mapping;
+		/* increment count (starts at -1) */
+		atomic_set(compound_mapcount, 0);
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	} else {
+		/* Anon THP always mapped first with PMD */
+		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+		/* increment count (starts at -1) */
+		atomic_set(&page->_mapcount, 0);
 	}
 	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	__page_set_anon_rmap(page, vma, address, 1);
@@ -1081,7 +1110,9 @@ void page_remove_rmap(struct page *page, bool compound)
 		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 
 	/* page still mapped by someone else? */
-	if (!atomic_add_negative(-1, &page->_mapcount))
+	if (!atomic_add_negative(-1, compound ?
+				compound_mapcount_ptr(page) :
+				&page->_mapcount))
 		goto out;
 
 	/*
@@ -1098,9 +1129,14 @@ void page_remove_rmap(struct page *page, bool compound)
 	if (anon) {
 		int nr = compound ? hpage_nr_pages(page) : 1;
 		if (compound) {
+			int i;
 			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 			__dec_zone_page_state(page,
 					NR_ANON_TRANSPARENT_HUGEPAGES);
+			/* The page can be mapped with ptes */
+			for (i = 0; i < HPAGE_PMD_NR; i++)
+				if (page_mapcount(page + i))
+					nr--;
 		}
 		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
 	} else {
@@ -1749,7 +1785,7 @@ void hugepage_add_anon_rmap(struct page *page,
 	BUG_ON(!PageLocked(page));
 	BUG_ON(!anon_vma);
 	/* address might be in next vma when migration races vma_adjust */
-	first = atomic_inc_and_test(&page->_mapcount);
+	first = atomic_inc_and_test(compound_mapcount_ptr(page));
 	if (first)
 		__hugepage_set_anon_rmap(page, vma, address, 0);
 }
@@ -1758,7 +1794,7 @@ void hugepage_add_new_anon_rmap(struct page *page,
 			struct vm_area_struct *vma, unsigned long address)
 {
 	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-	atomic_set(&page->_mapcount, 0);
+	atomic_set(compound_mapcount_ptr(page), 0);
 	__hugepage_set_anon_rmap(page, vma, address, 1);
 }
 #endif /* CONFIG_HUGETLB_PAGE */
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
