Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B59D66B0258
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 18:06:40 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id u190so63941967pfb.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 15:06:40 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id qc8si7506542pac.39.2016.03.11.14.59.35
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 14:59:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 16/25] thp, mlock: do not mlock PTE-mapped file huge pages
Date: Sat, 12 Mar 2016 01:59:08 +0300
Message-Id: <1457737157-38573-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As with anon THP, we only mlock file huge pages if we can prove that the
page is not mapped with PTE. This way we can avoid mlock leak into
non-mlocked vma on split.

We rely on PageDoubleMap() under lock_page() to check if the the page
may be PTE mapped. PG_double_map is set by page_add_file_rmap() when the
page mapped with PTEs.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 13 ++++++++++++-
 mm/huge_memory.c           | 27 ++++++++++++++++++++-------
 mm/mmap.c                  |  6 ++++++
 mm/page_alloc.c            |  2 ++
 mm/rmap.c                  | 16 ++++++++++++++--
 5 files changed, 54 insertions(+), 10 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index f4ed4f1b0c77..517707ae8cd1 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -544,6 +544,17 @@ static inline int PageDoubleMap(struct page *page)
 	return PageHead(page) && test_bit(PG_double_map, &page[1].flags);
 }
 
+static inline void SetPageDoubleMap(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+	set_bit(PG_double_map, &page[1].flags);
+}
+
+static inline void ClearPageDoubleMap(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+	clear_bit(PG_double_map, &page[1].flags);
+}
 static inline int TestSetPageDoubleMap(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHead(page), page);
@@ -560,7 +571,7 @@ static inline int TestClearPageDoubleMap(struct page *page)
 TESTPAGEFLAG_FALSE(TransHuge)
 TESTPAGEFLAG_FALSE(TransCompound)
 TESTPAGEFLAG_FALSE(TransTail)
-TESTPAGEFLAG_FALSE(DoubleMap)
+PAGEFLAG_FALSE(DoubleMap)
 	TESTSETFLAG_FALSE(DoubleMap)
 	TESTCLEARFLAG_FALSE(DoubleMap)
 #endif
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ba5fdf654f27..a2680b2112e4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1427,6 +1427,8 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 		 * We don't mlock() pte-mapped THPs. This way we can avoid
 		 * leaking mlocked pages into non-VM_LOCKED VMAs.
 		 *
+		 * For anon THP:
+		 *
 		 * In most cases the pmd is the only mapping of the page as we
 		 * break COW for the mlock() -- see gup_flags |= FOLL_WRITE for
 		 * writable private mappings in populate_vma_page_range().
@@ -1434,15 +1436,26 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 		 * The only scenario when we have the page shared here is if we
 		 * mlocking read-only mapping shared over fork(). We skip
 		 * mlocking such pages.
+		 *
+		 * For file THP:
+		 *
+		 * We can expect PageDoubleMap() to be stable under page lock:
+		 * for file pages we set it in page_add_file_rmap(), which
+		 * requires page to be locked.
 		 */
-		if (compound_mapcount(page) == 1 && !PageDoubleMap(page) &&
-				page->mapping && trylock_page(page)) {
-			lru_add_drain();
-			if (page->mapping)
-				mlock_vma_page(page);
-			unlock_page(page);
-		}
+
+		if (PageAnon(page) && compound_mapcount(page) != 1)
+			goto skip_mlock;
+		if (PageDoubleMap(page) || !page->mapping)
+			goto skip_mlock;
+		if (!trylock_page(page))
+			goto skip_mlock;
+		lru_add_drain();
+		if (page->mapping && !PageDoubleMap(page))
+			mlock_vma_page(page);
+		unlock_page(page);
 	}
+skip_mlock:
 	page += (addr & ~HPAGE_PMD_MASK) >> PAGE_SHIFT;
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 	if (flags & FOLL_GET)
diff --git a/mm/mmap.c b/mm/mmap.c
index 94979671b42c..1786d0b0244f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2576,6 +2576,12 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 		/* drop PG_Mlocked flag for over-mapped range */
 		for (tmp = vma; tmp->vm_start >= start + size;
 				tmp = tmp->vm_next) {
+			/*
+			 * Split pmd and munlock page on the border
+			 * of the range.
+			 */
+			vma_adjust_trans_huge(tmp, start, start + size, 0);
+
 			munlock_vma_pages_range(tmp,
 					max(tmp->vm_start, start),
 					min(tmp->vm_end, start + size));
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d6f042673e01..bce8b320fcce 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1009,6 +1009,8 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 
 	if (PageAnon(page))
 		page->mapping = NULL;
+	if (compound)
+		ClearPageDoubleMap(page);
 	bad += free_pages_check(page);
 	for (i = 1; i < (1 << order); i++) {
 		if (compound)
diff --git a/mm/rmap.c b/mm/rmap.c
index 359ec5cff9b0..f48258a78c8a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1298,6 +1298,12 @@ void page_add_file_rmap(struct page *page, bool compound)
 			goto out;
 		__inc_zone_page_state(page, NR_FILE_THP_MAPPED);
 	} else {
+		if (PageTransCompound(page)) {
+			VM_BUG_ON_PAGE(!PageLocked(page), page);
+			SetPageDoubleMap(compound_head(page));
+			if (PageMlocked(page))
+				clear_page_mlock(compound_head(page));
+		}
 		if (!atomic_inc_and_test(&page->_mapcount))
 			goto out;
 	}
@@ -1472,8 +1478,14 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	 */
 	if (!(flags & TTU_IGNORE_MLOCK)) {
 		if (vma->vm_flags & VM_LOCKED) {
-			/* Holding pte lock, we do *not* need mmap_sem here */
-			mlock_vma_page(page);
+			/* PTE-mapped THP are never mlocked */
+			if (!PageTransCompound(page)) {
+				/*
+				 * Holding pte lock, we do *not* need
+				 * mmap_sem here
+				 */
+				mlock_vma_page(page);
+			}
 			ret = SWAP_MLOCK;
 			goto out_unmap;
 		}
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
