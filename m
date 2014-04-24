Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 234AE6B0036
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 16:49:50 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so2369857pbb.33
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 13:49:49 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id ci3si3375103pad.4.2014.04.24.13.49.48
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 13:49:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 2/5] mm: extract in_gate_area() case from __get_user_pages()
Date: Thu, 24 Apr 2014 23:45:15 +0300
Message-Id: <1398372318-26612-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1398372318-26612-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1398372318-26612-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The case is special and disturb from reading main __get_user_pages()
code path. Let's move it to separate function.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/gup.c | 90 ++++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 48 insertions(+), 42 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 2de1afaee435..7a1c4133b464 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -213,6 +213,50 @@ static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long add
 	       stack_guard_page_end(vma, addr+PAGE_SIZE);
 }
 
+static int get_gate_page(struct mm_struct *mm, unsigned long address,
+		unsigned int gup_flags, struct vm_area_struct **vma,
+		struct page **page)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	int ret = -EFAULT;
+
+	/* user gate pages are read-only */
+	if (gup_flags & FOLL_WRITE)
+		return -EFAULT;
+	if (address > TASK_SIZE)
+		pgd = pgd_offset_k(address);
+	else
+		pgd = pgd_offset_gate(mm, address);
+	BUG_ON(pgd_none(*pgd));
+	pud = pud_offset(pgd, address);
+	BUG_ON(pud_none(*pud));
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd))
+		return -EFAULT;
+	VM_BUG_ON(pmd_trans_huge(*pmd));
+	pte = pte_offset_map(pmd, address);
+	if (pte_none(*pte))
+		goto unmap;
+	*vma = get_gate_vma(mm);
+	if (!page)
+		goto out;
+	*page = vm_normal_page(*vma, address, *pte);
+	if (!*page) {
+		if ((gup_flags & FOLL_DUMP) || !is_zero_pfn(pte_pfn(*pte)))
+			goto unmap;
+		*page = pte_page(*pte);
+	}
+	get_page(*page);
+out:
+	ret = 0;
+unmap:
+	pte_unmap(pte);
+	return ret;
+}
+
 /**
  * __get_user_pages() - pin user pages in memory
  * @tsk:	task_struct of target task
@@ -295,49 +339,11 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 
 		vma = find_extend_vma(mm, start);
 		if (!vma && in_gate_area(mm, start)) {
-			unsigned long pg = start & PAGE_MASK;
-			pgd_t *pgd;
-			pud_t *pud;
-			pmd_t *pmd;
-			pte_t *pte;
-
-			/* user gate pages are read-only */
-			if (gup_flags & FOLL_WRITE)
-				goto efault;
-			if (pg > TASK_SIZE)
-				pgd = pgd_offset_k(pg);
-			else
-				pgd = pgd_offset_gate(mm, pg);
-			BUG_ON(pgd_none(*pgd));
-			pud = pud_offset(pgd, pg);
-			BUG_ON(pud_none(*pud));
-			pmd = pmd_offset(pud, pg);
-			if (pmd_none(*pmd))
+			int ret;
+			ret = get_gate_page(mm, start & PAGE_MASK, gup_flags,
+					&vma, pages ? &pages[i] : NULL);
+			if (ret)
 				goto efault;
-			VM_BUG_ON(pmd_trans_huge(*pmd));
-			pte = pte_offset_map(pmd, pg);
-			if (pte_none(*pte)) {
-				pte_unmap(pte);
-				goto efault;
-			}
-			vma = get_gate_vma(mm);
-			if (pages) {
-				struct page *page;
-
-				page = vm_normal_page(vma, start, *pte);
-				if (!page) {
-					if (!(gup_flags & FOLL_DUMP) &&
-					     is_zero_pfn(pte_pfn(*pte)))
-						page = pte_page(*pte);
-					else {
-						pte_unmap(pte);
-						goto efault;
-					}
-				}
-				pages[i] = page;
-				get_page(page);
-			}
-			pte_unmap(pte);
 			page_mask = 0;
 			goto next_page;
 		}
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
