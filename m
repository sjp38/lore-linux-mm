Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5794F6B00A1
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:05:21 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so28644481pdb.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:05:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id yy3si14146907pbb.193.2015.04.23.14.05.02
        for <linux-mm@kvack.org>;
        Thu, 23 Apr 2015 14:05:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 19/28] mm: store mapcount for compound page separately
Date: Fri, 24 Apr 2015 00:03:54 +0300
Message-Id: <1429823043-157133-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to allow mapping of individual 4k pages of THP compound and
we need a cheap way to find out how many time the compound page is
mapped with PMD -- compound_mapcount() does this.

We use the same approach as with compound page destructor and compound
order: use space in first tail page, ->mapping this time.

page_mapcount() counts both: PTE and PMD mappings of the page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/mm.h       | 25 ++++++++++++--
 include/linux/mm_types.h |  1 +
 include/linux/rmap.h     |  4 +--
 mm/debug.c               |  5 ++-
 mm/huge_memory.c         |  2 +-
 mm/hugetlb.c             |  4 +--
 mm/memory.c              |  2 +-
 mm/migrate.c             |  2 +-
 mm/page_alloc.c          | 14 ++++++--
 mm/rmap.c                | 87 +++++++++++++++++++++++++++++++++++++-----------
 10 files changed, 114 insertions(+), 32 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index dad667d99304..33cb3aa647a6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -393,6 +393,19 @@ static inline int is_vmalloc_or_module_addr(const void *x)
 
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
@@ -405,8 +418,16 @@ static inline void page_mapcount_reset(struct page *page)
 
 static inline int page_mapcount(struct page *page)
 {
+	int ret;
 	VM_BUG_ON_PAGE(PageSlab(page), page);
-	return atomic_read(&page->_mapcount) + 1;
+	ret = atomic_read(&page->_mapcount) + 1;
+	/*
+	 * Positive compound_mapcount() offsets ->_mapcount in every page by
+	 * one. Let's substract it here.
+	 */
+	if (compound_mapcount(page))
+	       ret += compound_mapcount(page) - 1;
+	return ret;
 }
 
 static inline int page_count(struct page *page)
@@ -888,7 +909,7 @@ static inline pgoff_t page_file_index(struct page *page)
  */
 static inline int page_mapped(struct page *page)
 {
-	return atomic_read(&(page)->_mapcount) >= 0;
+	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >= 0;
 }
 
 /*
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 126f481bb95a..c8485fe2381c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -56,6 +56,7 @@ struct page {
 						 * see PAGE_MAPPING_ANON below.
 						 */
 		void *s_mem;			/* slab first object */
+		atomic_t compound_mapcount;	/* first tail page */
 	};
 
 	/* Second double word */
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index e7ecba43ae71..bb16ec73eeb7 100644
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
index 23181f836b62..06adbe3f2100 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -892,7 +892,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	src_page = pmd_page(pmd);
 	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
 	get_page(src_page);
-	page_dup_rmap(src_page);
+	page_dup_rmap(src_page, true);
 	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f27d4edada3a..94d70a16395e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2715,7 +2715,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			entry = huge_ptep_get(src_pte);
 			ptepage = pte_page(entry);
 			get_page(ptepage);
-			page_dup_rmap(ptepage);
+			page_dup_rmap(ptepage, true);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
 		spin_unlock(src_ptl);
@@ -3176,7 +3176,7 @@ retry:
 		ClearPagePrivate(page);
 		hugepage_add_new_anon_rmap(page, vma, address);
 	} else
-		page_dup_rmap(page);
+		page_dup_rmap(page, true);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);
diff --git a/mm/memory.c b/mm/memory.c
index 1bad3766b00c..0b295f7094b1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -864,7 +864,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page);
+		page_dup_rmap(page, false);
 		if (PageAnon(page))
 			rss[MM_ANONPAGES]++;
 		else
diff --git a/mm/migrate.c b/mm/migrate.c
index 9a380238a4d0..b51e88c9dba2 100644
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
index df2e25424b71..ac331be78308 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -378,6 +378,7 @@ void prep_compound_page(struct page *page, unsigned long order)
 		smp_wmb();
 		__SetPageTail(p);
 	}
+	atomic_set(compound_mapcount_ptr(page), -1);
 }
 
 static inline void prep_zero_page(struct page *page, unsigned int order,
@@ -656,7 +657,7 @@ static inline int free_pages_check(struct page *page)
 	const char *bad_reason = NULL;
 	unsigned long bad_flags = 0;
 
-	if (unlikely(page_mapcount(page)))
+	if (unlikely(atomic_read(&page->_mapcount) != -1))
 		bad_reason = "nonzero mapcount";
 	if (unlikely(page->mapping != NULL))
 		bad_reason = "non-NULL mapping";
@@ -765,7 +766,14 @@ static void free_one_page(struct zone *zone,
 
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
@@ -940,7 +948,7 @@ static inline int check_new_page(struct page *page)
 	const char *bad_reason = NULL;
 	unsigned long bad_flags = 0;
 
-	if (unlikely(page_mapcount(page)))
+	if (unlikely(atomic_read(&page->_mapcount) != -1))
 		bad_reason = "nonzero mapcount";
 	if (unlikely(page->mapping != NULL))
 		bad_reason = "non-NULL mapping";
diff --git a/mm/rmap.c b/mm/rmap.c
index 1636a96e5f71..047953145710 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1030,7 +1030,7 @@ static void __page_check_anon_rmap(struct page *page,
 	 * over the call to page_add_new_anon_rmap.
 	 */
 	BUG_ON(page_anon_vma(page)->root != vma->anon_vma->root);
-	BUG_ON(page->index != linear_page_index(vma, address));
+	BUG_ON(page_to_pgoff(page) != linear_page_index(vma, address));
 #endif
 }
 
@@ -1059,9 +1059,26 @@ void page_add_anon_rmap(struct page *page,
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
@@ -1070,9 +1087,17 @@ void do_page_add_anon_rmap(struct page *page,
 		 * disabled.
 		 */
 		if (compound) {
+			int i;
 			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
+			/*
+			 * While compound_mapcount() is positive we keep *one*
+			 * mapcount reference in all subpages. It's required
+			 * for atomic removal from rmap.
+			 */
+			for (i = 0; i < nr; i++)
+				atomic_set(&page[i]._mapcount, 0);
 		}
 		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	}
@@ -1080,6 +1105,7 @@ void do_page_add_anon_rmap(struct page *page,
 		return;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
+
 	/* address might be in next vma when migration races vma_adjust */
 	if (first)
 		__page_set_anon_rmap(page, vma, address,
@@ -1105,10 +1131,25 @@ void page_add_new_anon_rmap(struct page *page,
 
 	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
 	SetPageSwapBacked(page);
-	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (compound) {
+		int i;
+
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		/* increment count (starts at -1) */
+		atomic_set(compound_mapcount_ptr(page), 0);
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		/*
+		 * While compound_mapcount() is positive we keep *one* mapcount
+		 * reference in all subpages. It's required for atomic removal
+		 * from rmap.
+		 */
+		for (i = 0; i < nr; i++)
+			atomic_set(&page[i]._mapcount, 0);
+	} else {
+		/* Anon THP always mapped first with PMD */
+		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+		/* increment count (starts at -1) */
+		atomic_set(&page->_mapcount, 0);
 	}
 	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	__page_set_anon_rmap(page, vma, address, 1);
@@ -1138,12 +1179,15 @@ static void page_remove_file_rmap(struct page *page)
 
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
@@ -1168,8 +1212,6 @@ out:
  */
 void page_remove_rmap(struct page *page, bool compound)
 {
-	int nr = compound ? hpage_nr_pages(page) : 1;
-
 	if (!PageAnon(page)) {
 		VM_BUG_ON_PAGE(compound && !PageHuge(page), page);
 		page_remove_file_rmap(page);
@@ -1177,8 +1219,20 @@ void page_remove_rmap(struct page *page, bool compound)
 	}
 
 	/* page still mapped by someone else? */
-	if (!atomic_add_negative(-1, &page->_mapcount))
+	if (compound) {
+		int i;
+
+		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
+			return;
+		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		for (i = 0; i < hpage_nr_pages(page); i++)
+			page_remove_rmap(page + i, false);
 		return;
+	} else {
+		if (!atomic_add_negative(-1, &page->_mapcount))
+			return;
+	}
 
 	/* Hugepages are not counted in NR_ANON_PAGES for now. */
 	if (unlikely(PageHuge(page)))
@@ -1189,12 +1243,7 @@ void page_remove_rmap(struct page *page, bool compound)
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
@@ -1635,7 +1684,7 @@ void hugepage_add_anon_rmap(struct page *page,
 	BUG_ON(!PageLocked(page));
 	BUG_ON(!anon_vma);
 	/* address might be in next vma when migration races vma_adjust */
-	first = atomic_inc_and_test(&page->_mapcount);
+	first = atomic_inc_and_test(compound_mapcount_ptr(page));
 	if (first)
 		__hugepage_set_anon_rmap(page, vma, address, 0);
 }
@@ -1644,7 +1693,7 @@ void hugepage_add_new_anon_rmap(struct page *page,
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
