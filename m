Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C268A8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:48:50 -0500 (EST)
Received: by qwa26 with SMTP id 26so97406qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:48:48 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:48:48 +0000
Message-ID: <AANLkTi=EBZG0BSJwaM5-1L4CSESYZHfKmODfXpK9VES6@mail.gmail.com>
Subject: [RFC][PATCH 05/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

PARISC changes

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/parisc/include/asm/pgalloc.h
b/arch/parisc/include/asm/pgalloc.h
index fc987a1..b09e358 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -61,15 +61,21 @@ static inline void pgd_populate(struct mm_struct
*mm, pgd_t *pgd, pmd_t *pmd)
                (__u32)(__pa((unsigned long)pmd) >> PxD_VALUE_SHIFT));
 }

-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
 {
-   pmd_t *pmd = (pmd_t *)__get_free_pages(GFP_KERNEL|__GFP_REPEAT,
+   pmd_t *pmd = (pmd_t *)__get_free_pages(gfp_mask|__GFP_REPEAT,
                           PMD_ORDER);
    if (pmd)
        memset(pmd, 0, PAGE_SIZE<<PMD_ORDER);
    return pmd;
 }

+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+{
+   return __pmd_alloc_one(mm, address, GFP_KERNEL);
+}
+
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 #ifdef CONFIG_64BIT
@@ -90,6 +96,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
  * inside the pgd, so has no extra memory associated with it.
  */

+#define __pmd_alloc_one(mm, addr, mask)        ({ BUG(); ((pmd_t *)2); })
 #define pmd_alloc_one(mm, addr)        ({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)            do { } while (0)
 #define pgd_populate(mm, pmd, pte) BUG()
@@ -127,10 +134,15 @@ pte_alloc_one(struct mm_struct *mm, unsigned long address)
 }

 static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr,
gfp_t gfp_mask)
+{
+   return (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
+}
+
+static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
 {
-   pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-   return pte;
+   return __pte_alloc_one_kernel(mm, addr, GFP_KERNEL);
 }

 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
