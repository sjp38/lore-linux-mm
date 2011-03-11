Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4CFB38D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:45:15 -0500 (EST)
Received: by qyk2 with SMTP id 2so6915364qyk.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:45:10 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:45:10 +0000
Message-ID: <AANLkTikOER1V2RAeSrPopLxxwGsWYg7+522FL4rtMNq3@mail.gmail.com>
Subject: [RFC][PATCH 03/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Changes for microblaze architecture.

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/microblaze/include/asm/pgalloc.h
b/arch/microblaze/include/asm/pgalloc.h
index ebd3579..7df761f 100644
--- a/arch/microblaze/include/asm/pgalloc.h
+++ b/arch/microblaze/include/asm/pgalloc.h
@@ -106,9 +106,11 @@ extern inline void free_pgd_slow(pgd_t *pgd)
  * the pgd will always be present..
  */
 #define pmd_alloc_one_fast(mm, address)    ({ BUG(); ((pmd_t *)1); })
+#define __pmd_alloc_one(mm, address,mask)  ({ BUG(); ((pmd_t *)2); })
 #define pmd_alloc_one(mm, address) ({ BUG(); ((pmd_t *)2); })

 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
+extern pte_t *__pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);

 static inline struct page *pte_alloc_one(struct mm_struct *mm,
        unsigned long address)
@@ -175,6 +177,7 @@ extern inline void pte_free(struct mm_struct *mm,
struct page *ptepage)
  * We don't have any real pmd's, and this code never triggers because
  * the pgd will always be present..
  */
+#define __pmd_alloc_one(mm, address,mask)  ({ BUG(); ((pmd_t *)2); })
 #define pmd_alloc_one(mm, address) ({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)            do { } while (0)
 #define __pmd_free_tlb(tlb, x, addr)   pmd_free((tlb)->mm, x)
diff --git a/arch/microblaze/mm/pgtable.c b/arch/microblaze/mm/pgtable.c
index 59bf233..7d89c4b 100644
--- a/arch/microblaze/mm/pgtable.c
+++ b/arch/microblaze/mm/pgtable.c
@@ -240,12 +240,12 @@ unsigned long iopa(unsigned long addr)
    return pa;
 }

-__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-       unsigned long address)
+__init_refok pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+       unsigned long address, gfp_t gfp_mask)
 {
    pte_t *pte;
    if (mem_init_done) {
-       pte = (pte_t *)__get_free_page(GFP_KERNEL |
+       pte = (pte_t *)__get_free_page(gfp_mask |
                    __GFP_REPEAT | __GFP_ZERO);
    } else {
        pte = (pte_t *)early_get_page();
@@ -254,3 +254,9 @@ __init_refok pte_t *pte_alloc_one_kernel(struct
mm_struct *mm,
    }
    return pte;
 }
+
+__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+       unsigned long address)
+{
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
