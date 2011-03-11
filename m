Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4BCB78D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:57:51 -0500 (EST)
Received: by qwa26 with SMTP id 26so103632qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:57:49 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:57:49 +0000
Message-ID: <AANLkTimS=u5ht+-uA83v3EzX6YYq37M=5-DUqSLJeoni@mail.gmail.com>
Subject: [RFC][PATCH 12/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/tile/include/asm/pgalloc.h b/arch/tile/include/asm/pgalloc.h
index cf52791..c5b17a6 100644
--- a/arch/tile/include/asm/pgalloc.h
+++ b/arch/tile/include/asm/pgalloc.h
@@ -74,9 +74,16 @@ extern void pte_free(struct mm_struct *mm, struct page *pte);
 #define pmd_pgtable(pmd) pmd_page(pmd)

 static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+       gfp_t gfp_mask)
+{
+   return pfn_to_kaddr(page_to_pfn(__pte_alloc_one(mm, address, gfp_mask)));
+}
+
+static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-   return pfn_to_kaddr(page_to_pfn(pte_alloc_one(mm, address)));
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
@@ -108,6 +115,8 @@ void shatter_pmd(pmd_t *pmd);
 #define L1_USER_PGTABLE_ORDER L2_USER_PGTABLE_ORDER
 #define pud_populate(mm, pud, pmd) \
   pmd_populate_kernel((mm), (pmd_t *)(pud), (pte_t *)(pmd))
+#define __pmd_alloc_one(mm, addr, mask) \
+  ((pmd_t *)page_to_virt(__pte_alloc_one((mm), (addr), (mask))))
 #define pmd_alloc_one(mm, addr) \
   ((pmd_t *)page_to_virt(pte_alloc_one((mm), (addr))))
 #define pmd_free(mm, pmdp) \
diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 1f5430c..7875a32 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -218,9 +218,10 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)

 #define L2_USER_PGTABLE_PAGES (1 << L2_USER_PGTABLE_ORDER)

-struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+struct page *
+__pte_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
 {
-   gfp_t flags = GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO|__GFP_COMP;
+   gfp_t flags = gfp_mask|__GFP_REPEAT|__GFP_ZERO|__GFP_COMP;
    struct page *p;

 #ifdef CONFIG_HIGHPTE
@@ -235,6 +236,11 @@ struct page *pte_alloc_one(struct mm_struct *mm,
unsigned long address)
    return p;
 }

+struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+{
+   return __pte_alloc_one(mm, address, GFP_KERNEL);
+}
+
 /*
  * Free page immediately (used in __pte_alloc if we raced with another
  * process).  We have to correct whatever pte_alloc_one() did before

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
