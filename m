Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5BCBB6B0038
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 10:38:13 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so1952943pab.10
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 07:38:13 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bi5si3183435pbb.277.2014.04.03.07.38.12
        for <linux-mm@kvack.org>;
        Thu, 03 Apr 2014 07:38:12 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/5] mm: extract in_gate_area() case from __get_user_pages()
Date: Thu,  3 Apr 2014 17:35:19 +0300
Message-Id: <1396535722-31108-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The case is special and disturb from reading main __get_user_pages()
code path. Let's move it to separate function.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/gup.c | 95 +++++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 52 insertions(+), 43 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index eca5c3188cef..8f57ce7b7991 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -207,6 +207,53 @@ static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long add
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
+	int ret = 0;
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
+	if (pte_none(*pte)) {
+		ret = -EFAULT;
+		goto out;
+	}
+	*vma = get_gate_vma(mm);
+	if (!page)
+		goto out;
+	*page = vm_normal_page(*vma, address, *pte);
+	if (!*page)
+		goto out;
+	if ((gup_flags & FOLL_DUMP) || !is_zero_pfn(pte_pfn(*pte))) {
+		*page = NULL;
+		ret = -EFAULT;
+		goto out;
+	}
+	*page = pte_page(*pte);
+	get_page(*page);
+out:
+	pte_unmap(pte);
+	return 0;
+}
+
 /**
  * __get_user_pages() - pin user pages in memory
  * @tsk:	task_struct of target task
@@ -298,49 +345,11 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 
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
-				return i ? : -EFAULT;
-			if (pg > TASK_SIZE)
-				pgd = pgd_offset_k(pg);
-			else
-				pgd = pgd_offset_gate(mm, pg);
-			BUG_ON(pgd_none(*pgd));
-			pud = pud_offset(pgd, pg);
-			BUG_ON(pud_none(*pud));
-			pmd = pmd_offset(pud, pg);
-			if (pmd_none(*pmd))
-				return i ? : -EFAULT;
-			VM_BUG_ON(pmd_trans_huge(*pmd));
-			pte = pte_offset_map(pmd, pg);
-			if (pte_none(*pte)) {
-				pte_unmap(pte);
-				return i ? : -EFAULT;
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
-						return i ? : -EFAULT;
-					}
-				}
-				pages[i] = page;
-				get_page(page);
-			}
-			pte_unmap(pte);
+			int ret;
+			ret = get_gate_page(mm, start & PAGE_MASK, gup_flags,
+					&vma, pages ? &pages[i] : NULL);
+			if (ret)
+				return i ? : ret;
 			page_mask = 0;
 			goto next_page;
 		}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
