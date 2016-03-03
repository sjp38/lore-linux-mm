Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E546A828E2
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 12:00:04 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fl4so17743820pad.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 09:00:04 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xe1si21401468pab.53.2016.03.03.08.52.41
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 08:52:41 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 20/29] thp, mlock: do not mlock PTE-mapped file huge pages
Date: Thu,  3 Mar 2016 19:52:10 +0300
Message-Id: <1457023939-98083-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As with anon THP, we only mlock file huge pages if we can prove that the
page is not mapped with PTE. This way we can avoid mlock leak into
non-mlocked vma on split.

We rely on PageDoubleMap() under lock_page() to check if the the page
may be PTE mapped. PG_double_map is set by page_add_file_rmap() when the
page mapped with PTEs.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 13 ++++++++++++-
 mm/huge_memory.c           | 33 +++++++++++++++++++++++++--------
 mm/mmap.c                  |  6 ++++++
 mm/page_alloc.c            |  2 ++
 mm/rmap.c                  | 16 ++++++++++++++--
 5 files changed, 59 insertions(+), 11 deletions(-)

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
index 09c32bc7ff0b..32439a6fdd4f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1397,6 +1397,8 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 		 * We don't mlock() pte-mapped THPs. This way we can avoid
 		 * leaking mlocked pages into non-VM_LOCKED VMAs.
 		 *
+		 * For anon THP:
+		 *
 		 * In most cases the pmd is the only mapping of the page as we
 		 * break COW for the mlock() -- see gup_flags |= FOLL_WRITE for
 		 * writable private mappings in populate_vma_page_range().
@@ -1404,15 +1406,26 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
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
@@ -3004,7 +3017,11 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	ptl = pmd_lock(mm, pmd);
 	if (pmd_trans_huge(*pmd)) {
 		page = pmd_page(*pmd);
-		if (PageMlocked(page))
+		/*
+		 * File pages are munlocked on removing from rmap in
+		 * __split_huge_pmd_locked().
+		 */
+		if (PageMlocked(page) && PageAnon(page))
 			get_page(page);
 		else
 			page = NULL;
diff --git a/mm/mmap.c b/mm/mmap.c
index 2cb88eb252b8..b6aaf3609121 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2577,6 +2577,12 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
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
index 1993894b4219..e3e1c1c592f2 100644
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
index 765e001836dc..bd79e75b0531 100644
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
@@ -1466,8 +1472,14 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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
