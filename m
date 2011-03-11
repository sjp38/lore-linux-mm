Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 945848D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:46:22 -0500 (EST)
Received: by qyk30 with SMTP id 30so3208327qyk.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:46:20 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:46:20 +0000
Message-ID: <AANLkTimPAVODeoz2-=T2FoqJ5ofswOyVpeKHs1ZF2ibD@mail.gmail.com>
Subject: [RFC][PATCH 04/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Changes for MIPS architecture.

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index 881d18b..e386a44 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -64,14 +64,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
    free_pages((unsigned long)pgd, PGD_ORDER);
 }

+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+   unsigned long address, gfp_t gfp_mask)
+{
+   return (pte_t *)
__get_free_pages(gfp_mask|__GFP_REPEAT|__GFP_ZERO, PTE_ORDER);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
    unsigned long address)
 {
-   pte_t *pte;
-
-   pte = (pte_t *)
__get_free_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, PTE_ORDER);
-
-   return pte;
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline struct page *pte_alloc_one(struct mm_struct *mm,
@@ -106,16 +108,22 @@ do {                          \

 #ifndef __PAGETABLE_PMD_FOLDED

-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
 {
    pmd_t *pmd;

-   pmd = (pmd_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT, PMD_ORDER);
+   pmd = (pmd_t *) __get_free_pages(gfp_mask|__GFP_REPEAT, PMD_ORDER);
    if (pmd)
        pmd_init((unsigned long)pmd, (unsigned long)invalid_pte_table);
    return pmd;
 }

+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+{
+   return __pmd_alloc_one(mm, address, GFP_KERNEL);
+}
+
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
    free_pages((unsigned long)pmd, PMD_ORDER);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
