Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E36B68D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:53:44 -0400 (EDT)
Received: by qyk2 with SMTP id 2so1835919qyk.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:53:21 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 17:53:15 +0000
Message-ID: <AANLkTi=gvGj0SFMbK+jnSdKhuR1_u=eHTvv8RHrgjApN@mail.gmail.com>
Subject: [RFC][PATCH v2 13/23] (powerpc) __vmalloc: add gfp flags variant of
 pte, pmd, and pud allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/powerpc/include/asm/pgalloc-32.h |    2 ++
arch/powerpc/include/asm/pgalloc-64.h |   27 ++++++++++++++++++++++-----
arch/powerpc/mm/pgtable_32.c          |   10 ++++++++--
3 files changed, 32 insertions(+), 7 deletions(-)
---
diff --git a/arch/powerpc/include/asm/pgalloc-32.h
b/arch/powerpc/include/asm/pgalloc-32.h
index 580cf73..21b7a94 100644
--- a/arch/powerpc/include/asm/pgalloc-32.h
+++ b/arch/powerpc/include/asm/pgalloc-32.h
@@ -35,6 +35,8 @@ extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 #endif

 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
+extern pte_t *__pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);
+
 extern pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr);

 static inline void pgtable_free(void *table, unsigned index_size)
diff --git a/arch/powerpc/include/asm/pgalloc-64.h
b/arch/powerpc/include/asm/pgalloc-64.h
index 292725c..e5ea650 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -51,10 +51,15 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)

 #define pgd_populate(MM, PGD, PUD)	pgd_set(PGD, PUD)

+static inline pud_t *
+__pud_alloc_one(struct mm_struct *mm, unsigned long addr, gfp_t gfp_mask)
+{
+	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE), gfp_mask);
+}
+
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
+	return __pud_alloc_one(mm, addr, GFP_KERNEL | __GFP_REPEAT);
 }

 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -89,10 +94,15 @@ static inline void pmd_populate_kernel(struct
mm_struct *mm, pmd_t *pmd,

 #endif /* CONFIG_PPC_64K_PAGES */

+static inline pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long addr, gfp_t gfp_mask)
+{
+	return kmem_cache_alloc(PGT_CACHE(PMD_INDEX_SIZE), gfp_mask);
+}
+
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(PGT_CACHE(PMD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
+	return __pmd_alloc_one(mm, addr, GFP_KERNEL | __GFP_REPEAT);
 }

 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -100,10 +110,17 @@ static inline void pmd_free(struct mm_struct
*mm, pmd_t *pmd)
 	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
 }

+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+		gfp_t gfp_mask)
+{
+        return (pte_t *)__get_free_page(gfp_mask | __GFP_ZERO);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-        return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT |
__GFP_ZERO);
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
index 8dc41c0..736593f 100644
--- a/arch/powerpc/mm/pgtable_32.c
+++ b/arch/powerpc/mm/pgtable_32.c
@@ -95,14 +95,15 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 #endif
 }

-__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
unsigned long address)
+__init_refok pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)
 {
 	pte_t *pte;
 	extern int mem_init_done;
 	extern void *early_get_page(void);

 	if (mem_init_done) {
-		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+		pte = (pte_t *)__get_free_page(gfp_mask | __GFP_ZERO);
 	} else {
 		pte = (pte_t *)early_get_page();
 		if (pte)
@@ -111,6 +112,11 @@ __init_refok pte_t *pte_alloc_one_kernel(struct
mm_struct *mm, unsigned long add
 	return pte;
 }

+__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
+}
+
 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *ptepage;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
