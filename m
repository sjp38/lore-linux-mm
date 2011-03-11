Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 535218D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:56:12 -0500 (EST)
Received: by qwa26 with SMTP id 26so102513qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:56:11 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:56:11 +0000
Message-ID: <AANLkTi=2u+4C8J0qtYjekJUj_Kgs0mXn0E6Gqg-_1W9j@mail.gmail.com>
Subject: [RFC][PATCH 10/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/sh/include/asm/pgalloc.h b/arch/sh/include/asm/pgalloc.h
index 8c00785..1214abd 100644
--- a/arch/sh/include/asm/pgalloc.h
+++ b/arch/sh/include/asm/pgalloc.h
@@ -31,10 +31,16 @@ static inline void pmd_populate(struct mm_struct
*mm, pmd_t *pmd,
 /*
  * Allocate and free page tables.
  */
+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+                     unsigned long address, gfp_t gfp_mask)
+{
+   return quicklist_alloc(QUICK_PT, gfp_mask | __GFP_REPEAT, NULL);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
                      unsigned long address)
 {
-   return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/sh/mm/pgtable.c b/arch/sh/mm/pgtable.c
index 26e03a1..3b93198 100644
--- a/arch/sh/mm/pgtable.c
+++ b/arch/sh/mm/pgtable.c
@@ -45,9 +45,15 @@ void pud_populate(struct mm_struct *mm, pud_t *pud,
pmd_t *pmd)
    set_pud(pud, __pud((unsigned long)pmd));
 }

+pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
+{
+   return kmem_cache_alloc(pmd_cachep, gfp_mask | __GFP_REPEAT | __GFP_ZERO);
+}
+
 pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-   return kmem_cache_alloc(pmd_cachep, PGALLOC_GFP);
+   return __pmd_alloc_one(mm, address, GFP_KERNEL);
 }

 void pmd_free(struct mm_struct *mm, pmd_t *pmd)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
