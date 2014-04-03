Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EB2DA6B003A
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 10:38:13 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so1946191pad.16
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 07:38:13 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bi5si3183435pbb.277.2014.04.03.07.38.12
        for <linux-mm@kvack.org>;
        Thu, 03 Apr 2014 07:38:13 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/5] mm: cleanup follow_page_mask()
Date: Thu,  3 Apr 2014 17:35:20 +0300
Message-Id: <1396535722-31108-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Cleanups:
 - move pte-related code to separate function. It's about half of the
   function;
 - get rid of some goto-logic;
 - use 'return NULL' instead of 'return page' where page can only be
   NULL;

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/gup.c | 231 ++++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 119 insertions(+), 112 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 8f57ce7b7991..6e2cd0ddb79f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -6,105 +6,35 @@
 
 #include "internal.h"
 
-/**
- * follow_page_mask - look up a page descriptor from a user-virtual address
- * @vma: vm_area_struct mapping @address
- * @address: virtual address to look up
- * @flags: flags modifying lookup behaviour
- * @page_mask: on output, *page_mask is set according to the size of the page
- *
- * @flags can have FOLL_ flags set, defined in <linux/mm.h>
- *
- * Returns the mapped (struct page *), %NULL if no mapping exists, or
- * an error pointer if there is a mapping to something not represented
- * by a page descriptor (see also vm_normal_page()).
- */
-struct page *follow_page_mask(struct vm_area_struct *vma,
-			      unsigned long address, unsigned int flags,
-			      unsigned int *page_mask)
+static inline struct page *no_page_table(struct vm_area_struct *vma,
+		unsigned int flags)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *ptep, pte;
-	spinlock_t *ptl;
-	struct page *page;
-	struct mm_struct *mm = vma->vm_mm;
-
-	*page_mask = 0;
-
-	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
-	if (!IS_ERR(page)) {
-		BUG_ON(flags & FOLL_GET);
-		goto out;
-	}
-
-	page = NULL;
-	pgd = pgd_offset(mm, address);
-	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		goto no_page_table;
+	/*
+	 * When core dumping an enormous anonymous area that nobody
+	 * has touched so far, we don't want to allocate unnecessary pages or
+	 * page tables.  Return error instead of NULL to skip handle_mm_fault,
+	 * then get_dump_page() will return NULL to leave a hole in the dump.
+	 * But we can only make this optimization where a hole would surely
+	 * be zero-filled if handle_mm_fault() actually did handle it.
+	 */
+	if ((flags & FOLL_DUMP) && (!vma->vm_ops || !vma->vm_ops->fault))
+		return ERR_PTR(-EFAULT);
+	return NULL;
+}
 
-	pud = pud_offset(pgd, address);
-	if (pud_none(*pud))
-		goto no_page_table;
-	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
-		if (flags & FOLL_GET)
-			goto out;
-		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
-		goto out;
-	}
-	if (unlikely(pud_bad(*pud)))
-		goto no_page_table;
+static struct page *follow_page_pte(struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmd, unsigned int flags)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct page *page;
+	spinlock_t *ptl;
+	pte_t *ptep, pte;
 
-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd))
-		goto no_page_table;
-	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
-		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
-		if (flags & FOLL_GET) {
-			/*
-			 * Refcount on tail pages are not well-defined and
-			 * shouldn't be taken. The caller should handle a NULL
-			 * return when trying to follow tail pages.
-			 */
-			if (PageHead(page))
-				get_page(page);
-			else {
-				page = NULL;
-				goto out;
-			}
-		}
-		goto out;
-	}
-	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
-		goto no_page_table;
-	if (pmd_trans_huge(*pmd)) {
-		if (flags & FOLL_SPLIT) {
-			split_huge_page_pmd(vma, address, pmd);
-			goto split_fallthrough;
-		}
-		ptl = pmd_lock(mm, pmd);
-		if (likely(pmd_trans_huge(*pmd))) {
-			if (unlikely(pmd_trans_splitting(*pmd))) {
-				spin_unlock(ptl);
-				wait_split_huge_page(vma->anon_vma, pmd);
-			} else {
-				page = follow_trans_huge_pmd(vma, address,
-							     pmd, flags);
-				spin_unlock(ptl);
-				*page_mask = HPAGE_PMD_NR - 1;
-				goto out;
-			}
-		} else
-			spin_unlock(ptl);
-		/* fall through */
-	}
-split_fallthrough:
+retry:
 	if (unlikely(pmd_bad(*pmd)))
-		goto no_page_table;
+		return no_page_table(vma, flags);
 
 	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
-
 	pte = *ptep;
 	if (!pte_present(pte)) {
 		swp_entry_t entry;
@@ -122,12 +52,14 @@ split_fallthrough:
 			goto no_page;
 		pte_unmap_unlock(ptep, ptl);
 		migration_entry_wait(mm, pmd, address);
-		goto split_fallthrough;
+		goto retry;
 	}
 	if ((flags & FOLL_NUMA) && pte_numa(pte))
 		goto no_page;
-	if ((flags & FOLL_WRITE) && !pte_write(pte))
-		goto unlock;
+	if ((flags & FOLL_WRITE) && !pte_write(pte)) {
+		pte_unmap_unlock(ptep, ptl);
+		return NULL;
+	}
 
 	page = vm_normal_page(vma, address, pte);
 	if (unlikely(!page)) {
@@ -172,11 +104,8 @@ split_fallthrough:
 			unlock_page(page);
 		}
 	}
-unlock:
 	pte_unmap_unlock(ptep, ptl);
-out:
 	return page;
-
 bad_page:
 	pte_unmap_unlock(ptep, ptl);
 	return ERR_PTR(-EFAULT);
@@ -184,21 +113,99 @@ bad_page:
 no_page:
 	pte_unmap_unlock(ptep, ptl);
 	if (!pte_none(pte))
+		return NULL;
+	return no_page_table(vma, flags);
+}
+
+/**
+ * follow_page_mask - look up a page descriptor from a user-virtual address
+ * @vma: vm_area_struct mapping @address
+ * @address: virtual address to look up
+ * @flags: flags modifying lookup behaviour
+ * @page_mask: on output, *page_mask is set according to the size of the page
+ *
+ * @flags can have FOLL_ flags set, defined in <linux/mm.h>
+ *
+ * Returns the mapped (struct page *), %NULL if no mapping exists, or
+ * an error pointer if there is a mapping to something not represented
+ * by a page descriptor (see also vm_normal_page()).
+ */
+struct page *follow_page_mask(struct vm_area_struct *vma,
+			      unsigned long address, unsigned int flags,
+			      unsigned int *page_mask)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	spinlock_t *ptl;
+	struct page *page;
+	struct mm_struct *mm = vma->vm_mm;
+
+	*page_mask = 0;
+
+	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
+	if (!IS_ERR(page)) {
+		BUG_ON(flags & FOLL_GET);
 		return page;
+	}
 
-no_page_table:
-	/*
-	 * When core dumping an enormous anonymous area that nobody
-	 * has touched so far, we don't want to allocate unnecessary pages or
-	 * page tables.  Return error instead of NULL to skip handle_mm_fault,
-	 * then get_dump_page() will return NULL to leave a hole in the dump.
-	 * But we can only make this optimization where a hole would surely
-	 * be zero-filled if handle_mm_fault() actually did handle it.
-	 */
-	if ((flags & FOLL_DUMP) &&
-	    (!vma->vm_ops || !vma->vm_ops->fault))
-		return ERR_PTR(-EFAULT);
-	return page;
+	pgd = pgd_offset(mm, address);
+	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
+		return no_page_table(vma, flags);
+
+	pud = pud_offset(pgd, address);
+	if (pud_none(*pud))
+		return no_page_table(vma, flags);
+	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
+		if (flags & FOLL_GET)
+			return NULL;
+		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
+		return page;
+	}
+	if (unlikely(pud_bad(*pud)))
+		return no_page_table(vma, flags);
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd))
+		return no_page_table(vma, flags);
+	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
+		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
+		if (flags & FOLL_GET) {
+			/*
+			 * Refcount on tail pages are not well-defined and
+			 * shouldn't be taken. The caller should handle a NULL
+			 * return when trying to follow tail pages.
+			 */
+			if (PageHead(page))
+				get_page(page);
+			else
+				page = NULL;
+		}
+		return page;
+	}
+	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
+		return no_page_table(vma, flags);
+	if (pmd_trans_huge(*pmd)) {
+		if (flags & FOLL_SPLIT) {
+			split_huge_page_pmd(vma, address, pmd);
+			return follow_page_pte(vma, address, pmd, flags);
+		}
+		ptl = pmd_lock(mm, pmd);
+		if (likely(pmd_trans_huge(*pmd))) {
+			if (unlikely(pmd_trans_splitting(*pmd))) {
+				spin_unlock(ptl);
+				wait_split_huge_page(vma->anon_vma, pmd);
+			} else {
+				page = follow_trans_huge_pmd(vma, address,
+							     pmd, flags);
+				spin_unlock(ptl);
+				*page_mask = HPAGE_PMD_NR - 1;
+				return page;
+			}
+		} else
+			spin_unlock(ptl);
+	}
+	return follow_page_pte(vma, address, pmd, flags);
 }
 
 static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long addr)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
