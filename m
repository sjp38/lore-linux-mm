Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E3EE1900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 13:07:10 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so11165035pad.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 10:07:10 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id tz6si1776637pab.216.2015.06.03.10.07.01
        for <linux-mm@kvack.org>;
        Wed, 03 Jun 2015 10:07:01 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 26/36] mm: rework mapcount accounting to enable 4k mapping of THPs
Date: Wed,  3 Jun 2015 20:05:57 +0300
Message-Id: <1433351167-125878-27-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to allow mapping of individual 4k pages of THP compound.
It means we need to track mapcount on per small page basis.

Straight-forward approach is to use ->_mapcount in all subpages to track
how many time this subpage is mapped with PMDs or PTEs combined. But
this is rather expensive: mapping or unmapping of a THP page with PMD
would require HPAGE_PMD_NR atomic operations instead of single we have
now.

The idea is to store separately how many times the page was mapped as
whole -- compound_mapcount. This frees up ->_mapcount in subpages to
track PTE mapcount.

We use the same approach as with compound page destructor and compound
order to store compound_mapcount: use space in first tail page,
->mapping this time.

Any time we map/unmap whole compound page (THP or hugetlb) -- we
increment/decrement compound_mapcount. When we map part of compound page
with PTE we operate on ->_mapcount of the subpage.

page_mapcount() counts both: PTE and PMD mappings of the page.

Basically, we have mapcount for a subpage spread over two counters.
It makes tricky to detect when last mapcount for a page goes away.

We introduced PageDoubleMap() for this. When we split THP PMD for the
first time and there's other PMD mapping left we offset up ->_mapcount
in all subpages by one and set PG_double_map on the compound page.
These additional references go away with last compound_mapcount.

This approach provides a way to detect when last mapcount goes away on
per small page basis without introducing new overhead for most common
cases.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h         | 26 +++++++++++-
 include/linux/mm_types.h   |  1 +
 include/linux/page-flags.h | 37 +++++++++++++++++
 include/linux/rmap.h       |  4 +-
 mm/debug.c                 |  5 ++-
 mm/huge_memory.c           |  2 +-
 mm/hugetlb.c               |  4 +-
 mm/memory.c                |  2 +-
 mm/migrate.c               |  2 +-
 mm/page_alloc.c            | 14 +++++--
 mm/rmap.c                  | 98 +++++++++++++++++++++++++++++++++++-----------
 11 files changed, 160 insertions(+), 35 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 31cd5be081cf..22cd540104ec 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -403,6 +403,19 @@ static inline int is_vmalloc_or_module_addr(const void *x)
 
 extern void kvfree(const void *addr);
 
+static inline atomic_t *compound_mapcount_ptr(struct page *page)
+{
+	return &page[1].compound_mapcount;
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
@@ -415,8 +428,17 @@ static inline void page_mapcount_reset(struct page *page)
 
 static inline int page_mapcount(struct page *page)
 {
+	int ret;
 	VM_BUG_ON_PAGE(PageSlab(page), page);
-	return atomic_read(&page->_mapcount) + 1;
+
+	ret = atomic_read(&page->_mapcount) + 1;
+	if (PageCompound(page)) {
+		page = compound_head(page);
+		ret += compound_mapcount(page);
+		if (PageDoubleMap(page))
+			ret--;
+	}
+	return ret;
 }
 
 static inline int page_count(struct page *page)
@@ -898,7 +920,7 @@ static inline pgoff_t page_file_index(struct page *page)
  */
 static inline int page_mapped(struct page *page)
 {
-	return atomic_read(&(page)->_mapcount) >= 0;
+	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >= 0;
 }
 
 /*
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4b51a59160ab..4d182cd14c1f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -56,6 +56,7 @@ struct page {
 						 * see PAGE_MAPPING_ANON below.
 						 */
 		void *s_mem;			/* slab first object */
+		atomic_t compound_mapcount;	/* first tail page */
 	};
 
 	/* Second double word */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 74b7cece1dfa..a8d47c1edf6a 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -127,6 +127,9 @@ enum pageflags {
 
 	/* SLOB */
 	PG_slob_free = PG_private,
+
+	/* THP. Stored in first tail page's flags */
+	PG_double_map = PG_private_2,
 };
 
 #ifndef __GENERATING_BOUNDS_H
@@ -593,10 +596,44 @@ static inline int PageTransTail(struct page *page)
 	return PageTail(page);
 }
 
+/*
+ * PageDoubleMap indicates that the compound page is mapped with PTEs as well
+ * as PMDs.
+ *
+ * This is required for optimization of rmap oprations for THP: we can postpone
+ * per small page mapcount accounting (and its overhead from atomic operations)
+ * until the first PMD split.
+ *
+ * For the page PageDoubleMap means ->_mapcount in all sub-pages is offset up
+ * by one. This reference will go away with last compound_mapcount.
+ *
+ * See also __split_huge_pmd_locked() and page_remove_anon_compound_rmap().
+ */
+static inline int PageDoubleMap(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+	return page[1].flags & PG_double_map;
+}
+
+static inline int TestSetPageDoubleMap(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+	return test_and_set_bit(PG_double_map, &page[1].flags);
+}
+
+static inline void ClearPageDoubleMap(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+	clear_bit(PG_double_map, &page[1].flags);
+}
+
 #else
 TESTPAGEFLAG_FALSE(TransHuge)
 TESTPAGEFLAG_FALSE(TransCompound)
 TESTPAGEFLAG_FALSE(TransTail)
+TESTPAGEFLAG_FALSE(DoubleMap)
+	TESTSETFLAG_FALSE(DoubleMap)
+	CLEARPAGEFLAG_NOOP(DoubleMap)
 #endif
 
 /*
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 2bc86dc14305..1757854cd35c 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -181,9 +181,9 @@ void hugepage_add_anon_rmap(struct page *, struct vm_area_struct *,
 void hugepage_add_new_anon_rmap(struct page *, struct vm_area_struct *,
 				unsigned long);
 
-static inline void page_dup_rmap(struct page *page)
+static inline void page_dup_rmap(struct page *page, bool compound)
 {
-	atomic_inc(&page->_mapcount);
+	atomic_inc(compound ? compound_mapcount_ptr(page) : &page->_mapcount);
 }
 
 /*
diff --git a/mm/debug.c b/mm/debug.c
index 9dfcd77e7354..4a82f639b964 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -80,9 +80,12 @@ static void dump_flags(unsigned long flags,
 void dump_page_badflags(struct page *page, const char *reason,
 		unsigned long badflags)
 {
-	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
+	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
 		  page, atomic_read(&page->_count), page_mapcount(page),
 		  page->mapping, page->index);
+	if (PageCompound(page))
+		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
+	pr_cont("\n");
 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS);
 	dump_flags(page->flags, pageflag_names, ARRAY_SIZE(pageflag_names));
 	if (reason)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index efe52b5bd979..5b0a13d2f28c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -917,7 +917,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	src_page = pmd_page(pmd);
 	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
 	get_page(src_page);
-	page_dup_rmap(src_page);
+	page_dup_rmap(src_page, true);
 	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9d44d8f17760..f1e6ff471729 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2742,7 +2742,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			entry = huge_ptep_get(src_pte);
 			ptepage = pte_page(entry);
 			get_page(ptepage);
-			page_dup_rmap(ptepage);
+			page_dup_rmap(ptepage, true);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
 		spin_unlock(src_ptl);
@@ -3203,7 +3203,7 @@ retry:
 		ClearPagePrivate(page);
 		hugepage_add_new_anon_rmap(page, vma, address);
 	} else
-		page_dup_rmap(page);
+		page_dup_rmap(page, true);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);
diff --git a/mm/memory.c b/mm/memory.c
index ff2e8ed5b82a..cdc20d674675 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -867,7 +867,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page);
+		page_dup_rmap(page, false);
 		if (PageAnon(page))
 			rss[MM_ANONPAGES]++;
 		else
diff --git a/mm/migrate.c b/mm/migrate.c
index 9cabb25fb16e..dfd24cb7afc6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -164,7 +164,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		if (PageAnon(new))
 			hugepage_add_anon_rmap(new, vma, addr);
 		else
-			page_dup_rmap(new);
+			page_dup_rmap(new, false);
 	} else if (PageAnon(new))
 		page_add_anon_rmap(new, vma, addr, false);
 	else
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1f9ffbb087cb..6e3b42763894 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -452,6 +452,7 @@ void prep_compound_page(struct page *page, unsigned long order)
 		smp_wmb();
 		__SetPageTail(p);
 	}
+	atomic_set(compound_mapcount_ptr(page), -1);
 }
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
@@ -716,7 +717,7 @@ static inline int free_pages_check(struct page *page)
 	const char *bad_reason = NULL;
 	unsigned long bad_flags = 0;
 
-	if (unlikely(page_mapcount(page)))
+	if (unlikely(atomic_read(&page->_mapcount) != -1))
 		bad_reason = "nonzero mapcount";
 	if (unlikely(page->mapping != NULL))
 		bad_reason = "non-NULL mapping";
@@ -825,7 +826,14 @@ static void free_one_page(struct zone *zone,
 
 static int free_tail_pages_check(struct page *head_page, struct page *page)
 {
-	if (page->mapping != TAIL_MAPPING) {
+	/* mapping in first tail page is used for compound_mapcount() */
+	if (page - head_page == 1) {
+		if (unlikely(compound_mapcount(page))) {
+			bad_page(page, "nonzero compound_mapcount", 0);
+			page->mapping = NULL;
+			return 1;
+		}
+	} else if (page->mapping != TAIL_MAPPING) {
 		bad_page(page, "corrupted mapping in tail page", 0);
 		page->mapping = NULL;
 		return 1;
@@ -1288,7 +1296,7 @@ static inline int check_new_page(struct page *page)
 	const char *bad_reason = NULL;
 	unsigned long bad_flags = 0;
 
-	if (unlikely(page_mapcount(page)))
+	if (unlikely(atomic_read(&page->_mapcount) != -1))
 		bad_reason = "nonzero mapcount";
 	if (unlikely(page->mapping != NULL))
 		bad_reason = "non-NULL mapping";
diff --git a/mm/rmap.c b/mm/rmap.c
index 0e3851661487..2bfa15faff1e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1035,7 +1035,7 @@ static void __page_check_anon_rmap(struct page *page,
 	 * over the call to page_add_new_anon_rmap.
 	 */
 	BUG_ON(page_anon_vma(page)->root != vma->anon_vma->root);
-	BUG_ON(page->index != linear_page_index(vma, address));
+	BUG_ON(page_to_pgoff(page) != linear_page_index(vma, address));
 #endif
 }
 
@@ -1065,9 +1065,26 @@ void page_add_anon_rmap(struct page *page,
 void do_page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address, int flags)
 {
-	int first = atomic_inc_and_test(&page->_mapcount);
+	bool compound = flags & RMAP_COMPOUND;
+	bool first;
+
+	if (PageTransCompound(page)) {
+		VM_BUG_ON_PAGE(!PageLocked(page), page);
+		if (compound) {
+			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+			first = atomic_inc_and_test(compound_mapcount_ptr(page));
+		} else {
+			/* Anon THP always mapped first with PMD */
+			first = 0;
+			VM_BUG_ON_PAGE(!page_mapcount(page), page);
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
@@ -1086,6 +1103,7 @@ void do_page_add_anon_rmap(struct page *page,
 		return;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
+
 	/* address might be in next vma when migration races vma_adjust */
 	if (first)
 		__page_set_anon_rmap(page, vma, address,
@@ -1112,10 +1130,16 @@ void page_add_new_anon_rmap(struct page *page,
 
 	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
 	SetPageSwapBacked(page);
-	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (compound) {
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		/* increment count (starts at -1) */
+		atomic_set(compound_mapcount_ptr(page), 0);
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	} else {
+		/* Anon THP always mapped first with PMD */
+		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+		/* increment count (starts at -1) */
+		atomic_set(&page->_mapcount, 0);
 	}
 	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	__page_set_anon_rmap(page, vma, address, 1);
@@ -1145,12 +1169,15 @@ static void page_remove_file_rmap(struct page *page)
 
 	memcg = mem_cgroup_begin_page_stat(page);
 
-	/* page still mapped by someone else? */
-	if (!atomic_add_negative(-1, &page->_mapcount))
+	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
+	if (unlikely(PageHuge(page))) {
+		/* hugetlb pages are always mapped with pmds */
+		atomic_dec(compound_mapcount_ptr(page));
 		goto out;
+	}
 
-	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
-	if (unlikely(PageHuge(page)))
+	/* page still mapped by someone else? */
+	if (!atomic_add_negative(-1, &page->_mapcount))
 		goto out;
 
 	/*
@@ -1167,6 +1194,41 @@ out:
 	mem_cgroup_end_page_stat(memcg);
 }
 
+static void page_remove_anon_compound_rmap(struct page *page)
+{
+	int i, nr;
+
+	if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
+		return;
+
+	/* Hugepages are not counted in NR_ANON_PAGES for now. */
+	if (unlikely(PageHuge(page)))
+		return;
+
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		return;
+
+	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+
+	if (PageDoubleMap(page)) {
+		nr = 0;
+		ClearPageDoubleMap(page);
+		/*
+		 * Subpages can be mapped with PTEs too. Check how many of
+		 * themi are still mapped.
+		 */
+		for (i = 0; i < HPAGE_PMD_NR; i++) {
+			if (atomic_add_negative(-1, &page[i]._mapcount))
+				nr++;
+		}
+	} else {
+		nr = HPAGE_PMD_NR;
+	}
+
+	if (nr)
+		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
+}
+
 /**
  * page_remove_rmap - take down pte mapping from a page
  * @page:	page to remove mapping from
@@ -1176,33 +1238,25 @@ out:
  */
 void page_remove_rmap(struct page *page, bool compound)
 {
-	int nr = compound ? hpage_nr_pages(page) : 1;
-
 	if (!PageAnon(page)) {
 		VM_BUG_ON_PAGE(compound && !PageHuge(page), page);
 		page_remove_file_rmap(page);
 		return;
 	}
 
+	if (compound)
+		return page_remove_anon_compound_rmap(page);
+
 	/* page still mapped by someone else? */
 	if (!atomic_add_negative(-1, &page->_mapcount))
 		return;
 
-	/* Hugepages are not counted in NR_ANON_PAGES for now. */
-	if (unlikely(PageHuge(page)))
-		return;
-
 	/*
 	 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	if (compound) {
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
-	}
-
-	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
+	__dec_zone_page_state(page, NR_ANON_PAGES);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
@@ -1643,7 +1697,7 @@ void hugepage_add_anon_rmap(struct page *page,
 	BUG_ON(!PageLocked(page));
 	BUG_ON(!anon_vma);
 	/* address might be in next vma when migration races vma_adjust */
-	first = atomic_inc_and_test(&page->_mapcount);
+	first = atomic_inc_and_test(compound_mapcount_ptr(page));
 	if (first)
 		__hugepage_set_anon_rmap(page, vma, address, 0);
 }
@@ -1652,7 +1706,7 @@ void hugepage_add_new_anon_rmap(struct page *page,
 			struct vm_area_struct *vma, unsigned long address)
 {
 	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-	atomic_set(&page->_mapcount, 0);
+	atomic_set(compound_mapcount_ptr(page), 0);
 	__hugepage_set_anon_rmap(page, vma, address, 1);
 }
 #endif /* CONFIG_HUGETLB_PAGE */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
