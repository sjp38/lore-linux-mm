Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B23E08D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 16:05:02 -0500 (EST)
Received: by qwa26 with SMTP id 26so108507qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:05:00 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 21:05:00 +0000
Message-ID: <AANLkTi=S_R4VB5v2HHMTOqBnyUUzstcpx1xynT+ACTtW@mail.gmail.com>
Subject: [RFC][PATCH 22/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/frv/include/asm/pgalloc.h b/arch/frv/include/asm/pgalloc.h
index 416d19a..bfc4f7c 100644
--- a/arch/frv/include/asm/pgalloc.h
+++ b/arch/frv/include/asm/pgalloc.h
@@ -35,8 +35,10 @@ extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *mm, pgd_t *);

 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
+extern pte_t *__pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);

 extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);
+extern pgtable_t __pte_alloc_one(struct mm_struct *, unsigned long, gfp_t);

 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
@@ -60,6 +62,7 @@ do {                          \
  * inside the pgd, so has no extra memory associated with it.
  * (In the PAE case we free the pmds as part of the pgd.)
  */
+#define __pmd_alloc_one(mm, addr,mask)     ({ BUG(); ((pmd_t *) 2); })
 #define pmd_alloc_one(mm, addr)        ({ BUG(); ((pmd_t *) 2); })
 #define pmd_free(mm, x)            do { } while (0)
 #define __pmd_free_tlb(tlb,x,a)        do { } while (0)
diff --git a/arch/frv/include/asm/pgtable.h b/arch/frv/include/asm/pgtable.h
index 6bc241e..698e280 100644
--- a/arch/frv/include/asm/pgtable.h
+++ b/arch/frv/include/asm/pgtable.h
@@ -223,6 +223,7 @@ static inline pud_t *pud_offset(pgd_t *pgd,
unsigned long address)
  * allocating and freeing a pud is trivial: the 1-entry pud is
  * inside the pgd, so has no extra memory associated with it.
  */
+#define __pud_alloc_one(mm, address, mask)     NULL
 #define pud_alloc_one(mm, address)     NULL
 #define pud_free(mm, x)                do { } while (0)
 #define __pud_free_tlb(tlb, x, address)        do { } while (0)
diff --git a/arch/frv/mm/pgalloc.c b/arch/frv/mm/pgalloc.c
index c42c83d..c74ace1 100644
--- a/arch/frv/mm/pgalloc.c
+++ b/arch/frv/mm/pgalloc.c
@@ -20,14 +20,19 @@

 pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((aligned(PAGE_SIZE)));

-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long
address, gfp_t gfp_mask)
 {
-   pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+   pte_t *pte = (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT);
    if (pte)
        clear_page(pte);
    return pte;
 }

+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+{
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
+}
+
 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
    struct page *page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
