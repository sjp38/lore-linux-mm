Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C1C608D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 16:05:37 -0500 (EST)
Received: by qyk2 with SMTP id 2so6930026qyk.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:05:29 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 21:05:29 +0000
Message-ID: <AANLkTikzOCzG_CPBBx3yr0v7QrQGfdkZeBv1pWMcF5MR@mail.gmail.com>
Subject: [RFC][PATCH 22/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
index 96a8d92..0e46e47 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -39,9 +39,15 @@ pgd_populate(struct mm_struct *mm, pgd_t *
pgd_entry, pud_t * pud)
    pgd_val(*pgd_entry) = __pa(pud);
 }

+static inline pud_t *
+__pud_alloc_one(struct mm_struct *mm, unsigned long addr, gfp_t gfp_mask)
+{
+   return quicklist_alloc(0, gfp_mask, NULL);
+}
+
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-   return quicklist_alloc(0, GFP_KERNEL, NULL);
+   return __pud_alloc_one(mm, addr, GFP_KERNEL);
 }

 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -57,9 +63,15 @@ pud_populate(struct mm_struct *mm, pud_t *
pud_entry, pmd_t * pmd)
    pud_val(*pud_entry) = __pa(pmd);
 }

+static inline pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long addr, gfp_t gfp_mask)
+{
+   return quicklist_alloc(0, gfp_mask, NULL);
+}
+
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-   return quicklist_alloc(0, GFP_KERNEL, NULL);
+   return __pmd_alloc_one(mm, addr, GFP_KERNEL);
 }

 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -95,10 +107,16 @@ static inline pgtable_t pte_alloc_one(struct
mm_struct *mm, unsigned long addr)
    return page;
 }

+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+                     unsigned long addr, gfp_t gfp_mask)
+{
+   return quicklist_alloc(0, gfp_mask, NULL);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
                      unsigned long addr)
 {
-   return quicklist_alloc(0, GFP_KERNEL, NULL);
+   return __pte_alloc_one_kernel(mm, addr, GFP_KERNEL);
 }

 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
