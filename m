Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7213B8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:59:24 -0500 (EST)
Received: by qyk30 with SMTP id 30so3218041qyk.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:59:22 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:59:22 +0000
Message-ID: <AANLkTimBjDv6e2z_4oERgNiqE5_MPsKqVHSbtv1jpwb-@mail.gmail.com>
Subject: [RFC][PATCH 14/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/um/include/asm/pgalloc.h b/arch/um/include/asm/pgalloc.h
index 32c8ce4..8b6257e 100644
--- a/arch/um/include/asm/pgalloc.h
+++ b/arch/um/include/asm/pgalloc.h
@@ -27,6 +27,7 @@ extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);

 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
+extern pte_t *__pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);
 extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);

 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 8137ccc..1ea7dd0 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -284,12 +284,15 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
    free_page((unsigned long) pgd);
 }

-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)
 {
-   pte_t *pte;
+   return (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
+}

-   pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-   return pte;
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+{
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
@@ -303,15 +306,21 @@ pgtable_t pte_alloc_one(struct mm_struct *mm,
unsigned long address)
 }

 #ifdef CONFIG_3_LEVEL_PGTABLES
-pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
 {
-   pmd_t *pmd = (pmd_t *) __get_free_page(GFP_KERNEL);
+   pmd_t *pmd = (pmd_t *) __get_free_page(gfp_mask);

    if (pmd)
        memset(pmd, 0, PAGE_SIZE);

    return pmd;
 }
+
+pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+{
+   return __pmd_alloc_one(mm, address, GFP_KERNEL);
+}
 #endif

 void *uml_kmalloc(int size, int flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
