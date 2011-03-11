Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 606EB8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 16:03:28 -0500 (EST)
Received: by qyk2 with SMTP id 2so6928584qyk.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:03:26 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 21:03:26 +0000
Message-ID: <AANLkTimUaYZreB9uV3TmNy+293tPDeST9QgC7-uAQNWx@mail.gmail.com>
Subject: [RFC][PATCH 20/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/mm/memory.c b/mm/memory.c
index 5823698..dc4964e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -433,9 +433,9 @@ int __pte_alloc(struct mm_struct *mm, struct
vm_area_struct *vma,
    return 0;
 }

-int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address, gfp_t gfp_mask)
 {
-   pte_t *new = pte_alloc_one_kernel(&init_mm, address);
+   pte_t *new = __pte_alloc_one_kernel(&init_mm, address, gfp_mask);
    if (!new)
        return -ENOMEM;

@@ -3343,9 +3343,10 @@ int handle_mm_fault(struct mm_struct *mm,
struct vm_area_struct *vma,
  * Allocate page upper directory.
  * We've already handled the fast-path in-line.
  */
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address,
+       gfp_t gfp_mask)
 {
-   pud_t *new = pud_alloc_one(mm, address);
+   pud_t *new = __pud_alloc_one(mm, address, gfp_mask);
    if (!new)
        return -ENOMEM;

@@ -3366,9 +3367,10 @@ int __pud_alloc(struct mm_struct *mm, pgd_t
*pgd, unsigned long address)
  * Allocate page middle directory.
  * We've already handled the fast-path in-line.
  */
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address,
+       gfp_t gfp_mask)
 {
-   pmd_t *new = pmd_alloc_one(mm, address);
+   pmd_t *new = __pmd_alloc_one(mm, address, gfp_mask);
    if (!new)
        return -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
