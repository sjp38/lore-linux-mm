Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B82656B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 18:04:39 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 13so734545fge.4
        for <linux-mm@kvack.org>; Wed, 28 Jan 2009 15:04:37 -0800 (PST)
From: Andrea Righi <righi.andrea@gmail.com>
Subject: [PATCH -mmotm] mm: unify some pmd_*() functions fix
Date: Thu, 29 Jan 2009 00:04:34 +0100
Message-Id: <1233183874-26066-1-git-send-email-righi.andrea@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Roman Zippel <zippel@linux-m68k.org>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Andrea Righi <righi.andrea@gmail.com>
List-ID: <linux-mm.kvack.org>

Also unify implementations of pmd_*() functions in arch/*.

This patch must be applied on top of mm-unify-some-pmd_-functions.patch.

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 arch/alpha/include/asm/pgalloc.h      |    2 ++
 arch/arm/include/asm/pgalloc.h        |    3 +--
 arch/ia64/include/asm/pgalloc.h       |    2 ++
 arch/mips/include/asm/pgalloc.h       |   13 ++-----------
 arch/parisc/include/asm/pgalloc.h     |    5 +++--
 arch/powerpc/include/asm/pgalloc-32.h |    9 ---------
 arch/powerpc/include/asm/pgalloc-64.h |    2 ++
 arch/s390/include/asm/pgalloc.h       |    3 +--
 arch/sh/include/asm/pgalloc.h         |    8 --------
 arch/sparc/include/asm/pgalloc_64.h   |    2 ++
 arch/um/include/asm/pgalloc.h         |    1 +
 arch/um/include/asm/pgtable-3level.h  |    1 +
 arch/x86/include/asm/pgalloc.h        |    3 +++
 13 files changed, 20 insertions(+), 34 deletions(-)

diff --git a/arch/alpha/include/asm/pgalloc.h b/arch/alpha/include/asm/pgalloc.h
index fd09015..b372295 100644
--- a/arch/alpha/include/asm/pgalloc.h
+++ b/arch/alpha/include/asm/pgalloc.h
@@ -43,12 +43,14 @@ pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 	pmd_t *ret = (pmd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
 	return ret;
 }
+#define pmd_alloc_one pmd_alloc_one
 
 static inline void
 pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_page((unsigned long)pmd);
 }
+#define pmd_free pmd_free
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
 
diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
index 3dcd64b..2f241c8 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -26,8 +26,7 @@
 /*
  * Since we have only two-level page tables, these are trivial
  */
-#define pmd_alloc_one(mm,addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(mm, pmd)		do { } while (0)
+#define pmd_alloc_one	pmd_alloc_one_bug
 #define pgd_populate(mm,pmd,pte)	BUG()
 
 extern pgd_t *get_pgd_slow(struct mm_struct *mm);
diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
index b9ac1a6..660b128 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -61,11 +61,13 @@ static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
+#define pmd_alloc_one pmd_alloc_one
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	quicklist_free(0, NULL, pmd);
 }
+#define pmd_free pmd_free
 
 #define __pmd_free_tlb(tlb, pmd)	pmd_free((tlb)->mm, pmd)
 
diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index 1275831..139b127 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -104,17 +104,6 @@ do {							\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
-#ifdef CONFIG_32BIT
-
-/*
- * allocating and freeing a pmd is trivial: the 1-entry pmd is
- * inside the pgd, so has no extra memory associated with it.
- */
-#define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb, x)		do { } while (0)
-
-#endif
-
 #ifdef CONFIG_64BIT
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
@@ -126,11 +115,13 @@ static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 		pmd_init((unsigned long)pmd, (unsigned long)invalid_pte_table);
 	return pmd;
 }
+#define pmd_alloc_one pmd_alloc_one
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_pages((unsigned long)pmd, PMD_ORDER);
 }
+#define pmd_free pmd_free
 
 #define __pmd_free_tlb(tlb, x)	pmd_free((tlb)->mm, x)
 
diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
index fc987a1..dbb8bc2 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -69,6 +69,7 @@ static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 		memset(pmd, 0, PAGE_SIZE<<PMD_ORDER);
 	return pmd;
 }
+#define pmd_alloc_one pmd_alloc_one
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
@@ -80,6 +81,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 #endif
 	free_pages((unsigned long)pmd, PMD_ORDER);
 }
+#define pmd_free pmd_free
 
 #else
 
@@ -90,8 +92,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
  * inside the pgd, so has no extra memory associated with it.
  */
 
-#define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(mm, x)			do { } while (0)
+#define pmd_alloc_one	pmd_alloc_one_bug
 #define pgd_populate(mm, pmd, pte)	BUG()
 
 #endif
diff --git a/arch/powerpc/include/asm/pgalloc-32.h b/arch/powerpc/include/asm/pgalloc-32.h
index 0815eb4..cbf20f0 100644
--- a/arch/powerpc/include/asm/pgalloc-32.h
+++ b/arch/powerpc/include/asm/pgalloc-32.h
@@ -10,15 +10,6 @@ extern void __bad_pte(pmd_t *pmd);
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
-/*
- * We don't have any real pmd's, and this code never triggers because
- * the pgd will always be present..
- */
-/* #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); }) */
-#define pmd_free(mm, x) 		do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
-/* #define pgd_populate(mm, pmd, pte)      BUG() */
-
 #ifndef CONFIG_BOOKE
 #define pmd_populate_kernel(mm, pmd, pte)	\
 		(pmd_val(*(pmd)) = __pa(pte) | _PMD_PRESENT)
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index afda2bd..db765fd 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -81,11 +81,13 @@ static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 	return kmem_cache_alloc(pgtable_cache[PMD_CACHE_NUM],
 				GFP_KERNEL|__GFP_REPEAT);
 }
+#define pmd_alloc_one pmd_alloc_one
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	kmem_cache_free(pgtable_cache[PMD_CACHE_NUM], pmd);
 }
+#define pmd_free pmd_free
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
diff --git a/arch/s390/include/asm/pgalloc.h b/arch/s390/include/asm/pgalloc.h
index b2658b9..6a85281 100644
--- a/arch/s390/include/asm/pgalloc.h
+++ b/arch/s390/include/asm/pgalloc.h
@@ -63,8 +63,7 @@ static inline unsigned long pgd_entry_type(struct mm_struct *mm)
 #define pud_alloc_one(mm,address)		({ BUG(); ((pud_t *)2); })
 #define pud_free(mm, x)				do { } while (0)
 
-#define pmd_alloc_one(mm,address)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(mm, x)				do { } while (0)
+#define pmd_alloc_one	pmd_alloc_one_bug
 
 #define pgd_populate(mm, pgd, pud)		BUG()
 #define pgd_populate_kernel(mm, pgd, pud)	BUG()
diff --git a/arch/sh/include/asm/pgalloc.h b/arch/sh/include/asm/pgalloc.h
index 84dd2db..f9d9ccb 100644
--- a/arch/sh/include/asm/pgalloc.h
+++ b/arch/sh/include/asm/pgalloc.h
@@ -79,14 +79,6 @@ do {							\
 	tlb_remove_page((tlb), (pte));			\
 } while (0)
 
-/*
- * allocating and freeing a pmd is trivial: the 1-entry pmd is
- * inside the pgd, so has no extra memory associated with it.
- */
-
-#define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
-
 static inline void check_pgt_cache(void)
 {
 	quicklist_trim(QUICK_PGD, NULL, 25, 16);
diff --git a/arch/sparc/include/asm/pgalloc_64.h b/arch/sparc/include/asm/pgalloc_64.h
index 5bdfa2c..fa34726 100644
--- a/arch/sparc/include/asm/pgalloc_64.h
+++ b/arch/sparc/include/asm/pgalloc_64.h
@@ -30,11 +30,13 @@ static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
+#define pmd_alloc_one pmd_alloc_one
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	quicklist_free(0, NULL, pmd);
 }
+#define pmd_free pmd_free
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
diff --git a/arch/um/include/asm/pgalloc.h b/arch/um/include/asm/pgalloc.h
index 9062a6e..264120b 100644
--- a/arch/um/include/asm/pgalloc.h
+++ b/arch/um/include/asm/pgalloc.h
@@ -52,6 +52,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_page((unsigned long)pmd);
 }
+#define pmd_free pmd_free
 
 #define __pmd_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
 #endif
diff --git a/arch/um/include/asm/pgtable-3level.h b/arch/um/include/asm/pgtable-3level.h
index 0446f45..d3f320b 100644
--- a/arch/um/include/asm/pgtable-3level.h
+++ b/arch/um/include/asm/pgtable-3level.h
@@ -80,6 +80,7 @@ static inline void pgd_mkuptodate(pgd_t pgd) { pgd_val(pgd) &= ~_PAGE_NEWPAGE; }
 
 struct mm_struct;
 extern pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address);
+#define pmd_alloc_one pmd_alloc_one
 
 static inline void pud_clear (pud_t *pud)
 {
diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index cb7c151..1927b2b 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -70,14 +70,17 @@ static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 }
+#define pmd_alloc_one pmd_alloc_one
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	BUG_ON((unsigned long)pmd & (PAGE_SIZE-1));
 	free_page((unsigned long)pmd);
 }
+#define pmd_free pmd_free
 
 extern void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd);
+#define __pmd_free_tlb __pmd_free_tlb
 
 #ifdef CONFIG_X86_PAE
 extern void pud_populate(struct mm_struct *mm, pud_t *pudp, pmd_t *pmd);
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
