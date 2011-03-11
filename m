Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ED8A48D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:47:33 -0500 (EST)
Received: by qyk2 with SMTP id 2so6917120qyk.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:47:32 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:47:31 +0000
Message-ID: <AANLkTi=UsV5FAT2TrGhj=3E34ueTnjk_kkDyGSbDc0WJ@mail.gmail.com>
Subject: [RFC][PATCH 04/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Changes for mn10300 architecture.

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/mn10300/include/asm/pgalloc.h
b/arch/mn10300/include/asm/pgalloc.h
index 146bacf..35150ae 100644
--- a/arch/mn10300/include/asm/pgalloc.h
+++ b/arch/mn10300/include/asm/pgalloc.h
@@ -37,6 +37,8 @@ extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *, pgd_t *);

 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
+extern pte_t *__pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);
+
 extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);

 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
diff --git a/arch/mn10300/mm/pgtable.c b/arch/mn10300/mm/pgtable.c
index 450f7ba..59fd04d 100644
--- a/arch/mn10300/mm/pgtable.c
+++ b/arch/mn10300/mm/pgtable.c
@@ -62,14 +62,20 @@ void set_pmd_pfn(unsigned long vaddr, unsigned
long pfn, pgprot_t flags)
    local_flush_tlb_one(vaddr);
 }

-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+       gfp_t gfp_mask)
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
 struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
    struct page *pte;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
