Message-Id: <200405222204.i4MM4hr12530@mail.osdl.org>
Subject: [patch 13/57] rmap 12 pgtable remove rmap
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:04:12 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

Remove the support for pte_chain rmap from page table initialization, just
continue to maintain nr_page_table_pages (but only for user page tables -
it also counted vmalloc page tables before, little need, and I'm unsure if
per-cpu stats are safe early enough on all arches).  mm/memory.c is the
only core file affected.

But ppc and ppc64 have found the old rmap page table initialization useful
to support their ptep_test_and_clear_young: so transfer rmap's
initialization to them (even on kernel page tables?  well, okay).


---

 25-akpm/arch/arm/mm/mm-armv.c       |    3 +--
 25-akpm/arch/ppc/mm/pgtable.c       |   28 +++++++++++++++++++---------
 25-akpm/arch/ppc64/mm/hugetlbpage.c |    3 +--
 25-akpm/arch/ppc64/mm/tlb.c         |    4 ++--
 25-akpm/include/asm-ppc64/pgalloc.h |   31 +++++++++++++++++++++++--------
 25-akpm/mm/memory.c                 |    6 ++----
 6 files changed, 48 insertions(+), 27 deletions(-)

diff -puN arch/arm/mm/mm-armv.c~rmap-12-pgtable-remove-rmap arch/arm/mm/mm-armv.c
--- 25/arch/arm/mm/mm-armv.c~rmap-12-pgtable-remove-rmap	2004-05-22 14:56:23.318546568 -0700
+++ 25-akpm/arch/arm/mm/mm-armv.c	2004-05-22 14:56:23.328545048 -0700
@@ -18,7 +18,6 @@
 
 #include <asm/pgalloc.h>
 #include <asm/page.h>
-#include <asm/rmap.h>
 #include <asm/io.h>
 #include <asm/setup.h>
 #include <asm/tlbflush.h>
@@ -231,7 +230,7 @@ void free_pgd_slow(pgd_t *pgd)
 
 	pte = pmd_page(*pmd);
 	pmd_clear(pmd);
-	pgtable_remove_rmap(pte);
+	dec_page_state(nr_page_table_pages);
 	pte_free(pte);
 	pmd_free(pmd);
 free:
diff -puN arch/ppc64/mm/hugetlbpage.c~rmap-12-pgtable-remove-rmap arch/ppc64/mm/hugetlbpage.c
--- 25/arch/ppc64/mm/hugetlbpage.c~rmap-12-pgtable-remove-rmap	2004-05-22 14:56:23.319546416 -0700
+++ 25-akpm/arch/ppc64/mm/hugetlbpage.c	2004-05-22 14:56:23.329544896 -0700
@@ -24,7 +24,6 @@
 #include <asm/machdep.h>
 #include <asm/cputable.h>
 #include <asm/tlb.h>
-#include <asm/rmap.h>
 
 #include <linux/sysctl.h>
 
@@ -214,7 +213,7 @@ static int prepare_low_seg_for_htlb(stru
 		}
 		page = pmd_page(*pmd);
 		pmd_clear(pmd);
-		pgtable_remove_rmap(page);
+		dec_page_state(nr_page_table_pages);
 		pte_free_tlb(tlb, page);
 	}
 	tlb_finish_mmu(tlb, start, end);
diff -puN arch/ppc64/mm/tlb.c~rmap-12-pgtable-remove-rmap arch/ppc64/mm/tlb.c
--- 25/arch/ppc64/mm/tlb.c~rmap-12-pgtable-remove-rmap	2004-05-22 14:56:23.321546112 -0700
+++ 25-akpm/arch/ppc64/mm/tlb.c	2004-05-22 14:56:23.329544896 -0700
@@ -31,7 +31,6 @@
 #include <asm/tlb.h>
 #include <asm/hardirq.h>
 #include <linux/highmem.h>
-#include <asm/rmap.h>
 
 DEFINE_PER_CPU(struct ppc64_tlb_batch, ppc64_tlb_batch);
 
@@ -59,7 +58,8 @@ void hpte_update(pte_t *ptep, unsigned l
 
 	ptepage = virt_to_page(ptep);
 	mm = (struct mm_struct *) ptepage->mapping;
-	addr = ptep_to_address(ptep);
+	addr = ptepage->index +
+		(((unsigned long)ptep & ~PAGE_MASK) * PTRS_PER_PTE);
 
 	if (REGION_ID(addr) == USER_REGION_ID)
 		context = mm->context.id;
diff -puN arch/ppc/mm/pgtable.c~rmap-12-pgtable-remove-rmap arch/ppc/mm/pgtable.c
--- 25/arch/ppc/mm/pgtable.c~rmap-12-pgtable-remove-rmap	2004-05-22 14:56:23.322545960 -0700
+++ 25-akpm/arch/ppc/mm/pgtable.c	2004-05-22 14:56:23.330544744 -0700
@@ -86,9 +86,14 @@ pte_t *pte_alloc_one_kernel(struct mm_st
 	extern int mem_init_done;
 	extern void *early_get_page(void);
 
-	if (mem_init_done)
+	if (mem_init_done) {
 		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
-	else
+		if (pte) {
+			struct page *ptepage = virt_to_page(pte);
+			ptepage->mapping = (void *) mm;
+			ptepage->index = address & PMD_MASK;
+		}
+	} else
 		pte = (pte_t *)early_get_page();
 	if (pte)
 		clear_page(pte);
@@ -97,7 +102,7 @@ pte_t *pte_alloc_one_kernel(struct mm_st
 
 struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	struct page *pte;
+	struct page *ptepage;
 
 #ifdef CONFIG_HIGHPTE
 	int flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_REPEAT;
@@ -105,10 +110,13 @@ struct page *pte_alloc_one(struct mm_str
 	int flags = GFP_KERNEL | __GFP_REPEAT;
 #endif
 
-	pte = alloc_pages(flags, 0);
-	if (pte)
-		clear_highpage(pte);
-	return pte;
+	ptepage = alloc_pages(flags, 0);
+	if (ptepage) {
+		ptepage->mapping = (void *) mm;
+		ptepage->index = address & PMD_MASK;
+		clear_highpage(ptepage);
+	}
+	return ptepage;
 }
 
 void pte_free_kernel(pte_t *pte)
@@ -116,15 +124,17 @@ void pte_free_kernel(pte_t *pte)
 #ifdef CONFIG_SMP
 	hash_page_sync();
 #endif
+	virt_to_page(pte)->mapping = NULL;
 	free_page((unsigned long)pte);
 }
 
-void pte_free(struct page *pte)
+void pte_free(struct page *ptepage)
 {
 #ifdef CONFIG_SMP
 	hash_page_sync();
 #endif
-	__free_page(pte);
+	ptepage->mapping = NULL;
+	__free_page(ptepage);
 }
 
 #ifndef CONFIG_44x
diff -puN include/asm-ppc64/pgalloc.h~rmap-12-pgtable-remove-rmap include/asm-ppc64/pgalloc.h
--- 25/include/asm-ppc64/pgalloc.h~rmap-12-pgtable-remove-rmap	2004-05-22 14:56:23.324545656 -0700
+++ 25-akpm/include/asm-ppc64/pgalloc.h	2004-05-22 14:56:23.331544592 -0700
@@ -48,28 +48,43 @@ pmd_free(pmd_t *pmd)
 	pmd_populate_kernel(mm, pmd, page_address(pte_page))
 
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
+pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return kmem_cache_alloc(zero_cache, GFP_KERNEL|__GFP_REPEAT);
+	pte_t *pte;
+	pte = kmem_cache_alloc(zero_cache, GFP_KERNEL|__GFP_REPEAT);
+	if (pte) {
+		struct page *ptepage = virt_to_page(pte);
+		ptepage->mapping = (void *) mm;
+		ptepage->index = address & PMD_MASK;
+	}
+	return pte;
 }
 
 static inline struct page *
 pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte = pte_alloc_one_kernel(mm, address);
-
-	if (pte)
-		return virt_to_page(pte);
-
+	pte_t *pte;
+	pte = kmem_cache_alloc(zero_cache, GFP_KERNEL|__GFP_REPEAT);
+	if (pte) {
+		struct page *ptepage = virt_to_page(pte);
+		ptepage->mapping = (void *) mm;
+		ptepage->index = address & PMD_MASK;
+		return ptepage;
+	}
 	return NULL;
 }
 		
 static inline void pte_free_kernel(pte_t *pte)
 {
+	virt_to_page(pte)->mapping = NULL;
 	kmem_cache_free(zero_cache, pte);
 }
 
-#define pte_free(pte_page)	pte_free_kernel(page_address(pte_page))
+static inline void pte_free(struct page *ptepage)
+{
+	ptepage->mapping = NULL;
+	kmem_cache_free(zero_cache, page_address(ptepage));
+}
 
 struct pte_freelist_batch
 {
diff -puN mm/memory.c~rmap-12-pgtable-remove-rmap mm/memory.c
--- 25/mm/memory.c~rmap-12-pgtable-remove-rmap	2004-05-22 14:56:23.325545504 -0700
+++ 25-akpm/mm/memory.c	2004-05-22 14:59:42.133322128 -0700
@@ -48,7 +48,6 @@
 #include <linux/init.h>
 
 #include <asm/pgalloc.h>
-#include <asm/rmap.h>
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
@@ -105,7 +104,7 @@ static inline void free_one_pmd(struct m
 	}
 	page = pmd_page(*dir);
 	pmd_clear(dir);
-	pgtable_remove_rmap(page);
+	dec_page_state(nr_page_table_pages);
 	pte_free_tlb(tlb, page);
 }
 
@@ -164,7 +163,7 @@ pte_t fastcall * pte_alloc_map(struct mm
 			pte_free(new);
 			goto out;
 		}
-		pgtable_add_rmap(new, mm, address);
+		inc_page_state(nr_page_table_pages);
 		pmd_populate(mm, pmd, new);
 	}
 out:
@@ -190,7 +189,6 @@ pte_t fastcall * pte_alloc_kernel(struct
 			pte_free_kernel(new);
 			goto out;
 		}
-		pgtable_add_rmap(virt_to_page(new), mm, address);
 		pmd_populate_kernel(mm, pmd, new);
 	}
 out:

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
