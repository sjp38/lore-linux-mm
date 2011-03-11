Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EDB1D8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 16:00:40 -0500 (EST)
Received: by qwa26 with SMTP id 26so105598qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:00:39 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 21:00:39 +0000
Message-ID: <AANLkTi=405S-jK97YmZRbGkTQP8cHj5o=GkLNQKftFem@mail.gmail.com>
Subject: [RFC][PATCH 16/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/xtensa/include/asm/pgalloc.h
b/arch/xtensa/include/asm/pgalloc.h
index 40cf9bc..e24c720 100644
--- a/arch/xtensa/include/asm/pgalloc.h
+++ b/arch/xtensa/include/asm/pgalloc.h
@@ -42,10 +42,17 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)

 extern struct kmem_cache *pgtable_cache;

+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+       gfp_t gfp_mask)
+{
+   return kmem_cache_alloc(pgtable_cache, gfp_mask|__GFP_REPEAT);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
                     unsigned long address)
 {
-   return kmem_cache_alloc(pgtable_cache, GFP_KERNEL|__GFP_REPEAT);
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/xtensa/mm/pgtable.c b/arch/xtensa/mm/pgtable.c
index 6979927..1c53abc 100644
--- a/arch/xtensa/mm/pgtable.c
+++ b/arch/xtensa/mm/pgtable.c
@@ -12,13 +12,14 @@

 #if (DCACHE_SIZE > PAGE_SIZE)

-pte_t* pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t*
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)
 {
    pte_t *pte = NULL, *p;
    int color = ADDR_COLOR(address);
    int i;

-   p = (pte_t*) __get_free_pages(GFP_KERNEL|__GFP_REPEAT, COLOR_ORDER);
+   p = (pte_t*) __get_free_pages(gfp_mask|__GFP_REPEAT, COLOR_ORDER);

    if (likely(p)) {
        split_page(virt_to_page(p), COLOR_ORDER);
@@ -35,6 +36,11 @@ pte_t* pte_alloc_one_kernel(struct mm_struct *mm,
unsigned long address)
    return pte;
 }

+pte_t* pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+{
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
+}
+
 #ifdef PROFILING

 int mask;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
