Date: Thu, 3 May 2007 22:04:10 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22 -mm merge plans: slub on PowerPC
In-Reply-To: <Pine.LNX.4.64.0705031011020.9826@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0705032143420.7589@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705021017270.32635@schroedinger.engr.sgi.com>
 <20070503011515.0d89082b.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705030936120.5165@blonde.wat.veritas.com>
 <20070503015729.7496edff.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705031011020.9826@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 May 2007, Hugh Dickins wrote:
> 
> Seems we're all wrong in thinking Christoph's Kconfiggery worked
> as intended: maybe it just works some of the time.  I'm not going
> to hazard a guess as to how to fix it up, will resume looking at
> the powerpc's quicklist potential later.

Here's the patch I've been testing on G5, with 4k and with 64k pages,
with SLAB and with SLUB.  But, though it doesn't crash, the pgd
kmem_cache in the 4k-page SLUB case is revealing SLUB's propensity
for using highorder allocations where SLAB would stick to order 0:
under load, exec's mm_init gets page allocation failure on order 4
- SLUB's calculate_order may need some retuning.  (I'd expect it to
be going for order 3 actually, I'm not sure how order 4 comes about.)

I don't know how offensive Ben and Paulus may find this patch:
the kmem_cache use was nicely done and this messes it up a little.


The SLUB allocator relies on struct page fields first_page and slab,
overwritten by ptl when SPLIT_PTLOCK: so the SLUB allocator cannot then
be used for the lowest level of pagetable pages.  This was obstructing
SLUB on PowerPC, which uses kmem_caches for its pagetables.  So convert
its pte level to use quicklist pages (whereas pmd, pud and 64k-page pgd
want partpages, so continue to use kmem_caches for pmd, pud and pgd).
But to keep up appearances for pgtable_free, we still need PTE_CACHE_NUM.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 arch/powerpc/Kconfig          |    4 ++++
 arch/powerpc/mm/init_64.c     |   17 ++++++-----------
 include/asm-powerpc/pgalloc.h |   26 +++++++++++---------------
 3 files changed, 21 insertions(+), 26 deletions(-)

--- 2.6.21-rc7-mm2/arch/powerpc/Kconfig	2007-04-26 13:33:51.000000000 +0100
+++ linux/arch/powerpc/Kconfig	2007-05-03 20:45:12.000000000 +0100
@@ -31,6 +31,10 @@ config MMU
 	bool
 	default y
 
+config QUICKLIST
+	bool
+	default y
+
 config GENERIC_HARDIRQS
 	bool
 	default y
--- 2.6.21-rc7-mm2/arch/powerpc/mm/init_64.c	2007-04-26 13:33:51.000000000 +0100
+++ linux/arch/powerpc/mm/init_64.c	2007-05-03 20:45:12.000000000 +0100
@@ -146,21 +146,16 @@ static void zero_ctor(void *addr, struct
 	memset(addr, 0, kmem_cache_size(cache));
 }
 
-#ifdef CONFIG_PPC_64K_PAGES
-static const unsigned int pgtable_cache_size[3] = {
-	PTE_TABLE_SIZE, PMD_TABLE_SIZE, PGD_TABLE_SIZE
-};
-static const char *pgtable_cache_name[ARRAY_SIZE(pgtable_cache_size)] = {
-	"pte_pmd_cache", "pmd_cache", "pgd_cache",
-};
-#else
 static const unsigned int pgtable_cache_size[2] = {
-	PTE_TABLE_SIZE, PMD_TABLE_SIZE
+	PGD_TABLE_SIZE, PMD_TABLE_SIZE
 };
 static const char *pgtable_cache_name[ARRAY_SIZE(pgtable_cache_size)] = {
-	"pgd_pte_cache", "pud_pmd_cache",
-};
+#ifdef CONFIG_PPC_64K_PAGES
+	"pgd_cache", "pmd_cache",
+#else
+	"pgd_cache", "pud_pmd_cache",
 #endif /* CONFIG_PPC_64K_PAGES */
+};
 
 #ifdef CONFIG_HUGETLB_PAGE
 /* Hugepages need one extra cache, initialized in hugetlbpage.c.  We
--- 2.6.21-rc7-mm2/include/asm-powerpc/pgalloc.h	2007-02-04 18:44:54.000000000 +0000
+++ linux/include/asm-powerpc/pgalloc.h	2007-05-03 20:45:12.000000000 +0100
@@ -10,21 +10,15 @@
 #include <linux/slab.h>
 #include <linux/cpumask.h>
 #include <linux/percpu.h>
+#include <linux/quicklist.h>
 
 extern struct kmem_cache *pgtable_cache[];
 
-#ifdef CONFIG_PPC_64K_PAGES
-#define PTE_CACHE_NUM	0
-#define PMD_CACHE_NUM	1
-#define PGD_CACHE_NUM	2
-#define HUGEPTE_CACHE_NUM 3
-#else
-#define PTE_CACHE_NUM	0
-#define PMD_CACHE_NUM	1
-#define PUD_CACHE_NUM	1
 #define PGD_CACHE_NUM	0
+#define PUD_CACHE_NUM	1
+#define PMD_CACHE_NUM	1
 #define HUGEPTE_CACHE_NUM 2
-#endif
+#define PTE_CACHE_NUM	3	/* from quicklist rather than  kmem_cache */
 
 /*
  * This program is free software; you can redistribute it and/or
@@ -97,8 +91,7 @@ static inline void pmd_free(pmd_t *pmd)
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return kmem_cache_alloc(pgtable_cache[PTE_CACHE_NUM],
-				GFP_KERNEL|__GFP_REPEAT);
+	return quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
 }
 
 static inline struct page *pte_alloc_one(struct mm_struct *mm,
@@ -109,7 +102,7 @@ static inline struct page *pte_alloc_one
 		
 static inline void pte_free_kernel(pte_t *pte)
 {
-	kmem_cache_free(pgtable_cache[PTE_CACHE_NUM], pte);
+	quicklist_free(0, NULL, pte);
 }
 
 static inline void pte_free(struct page *ptepage)
@@ -136,7 +129,10 @@ static inline void pgtable_free(pgtable_
 	void *p = (void *)(pgf.val & ~PGF_CACHENUM_MASK);
 	int cachenum = pgf.val & PGF_CACHENUM_MASK;
 
-	kmem_cache_free(pgtable_cache[cachenum], p);
+	if (cachenum == PTE_CACHE_NUM)
+		quicklist_free(0, NULL, p);
+	else
+		kmem_cache_free(pgtable_cache[cachenum], p);
 }
 
 extern void pgtable_free_tlb(struct mmu_gather *tlb, pgtable_free_t pgf);
@@ -153,7 +149,7 @@ extern void pgtable_free_tlb(struct mmu_
 		PUD_CACHE_NUM, PUD_TABLE_SIZE-1))
 #endif /* CONFIG_PPC_64K_PAGES */
 
-#define check_pgt_cache()	do { } while (0)
+#define check_pgt_cache()	quicklist_trim(0, NULL, 25, 16)
 
 #endif /* CONFIG_PPC64 */
 #endif /* __KERNEL__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
