Message-ID: <41C94449.20004@yahoo.com.au>
Date: Wed, 22 Dec 2004 20:54:17 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 3/11] convert i386 to generic nopmd header
References: <41C94361.6070909@yahoo.com.au> <41C943F0.4090006@yahoo.com.au> <41C94427.9020601@yahoo.com.au>
In-Reply-To: <41C94427.9020601@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------060509050809010303080604"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060509050809010303080604
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

3/11

--------------060509050809010303080604
Content-Type: text/plain;
 name="3level-i386-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3level-i386-cleanup.patch"


Adapt the i386 architecture to use the generic 2-level folding header.
Just to show how it is done.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/include/asm-i386/mmzone.h              |    1 
 linux-2.6-npiggin/include/asm-i386/page.h                |    6 --
 linux-2.6-npiggin/include/asm-i386/pgalloc.h             |   17 +++----
 linux-2.6-npiggin/include/asm-i386/pgtable-2level-defs.h |    2 
 linux-2.6-npiggin/include/asm-i386/pgtable-2level.h      |   33 +++------------
 linux-2.6-npiggin/include/asm-i386/pgtable-3level.h      |   11 +++++
 linux-2.6-npiggin/include/asm-i386/pgtable.h             |   13 +----
 7 files changed, 31 insertions(+), 52 deletions(-)

diff -puN include/asm-i386/pgtable-2level.h~3level-i386-cleanup include/asm-i386/pgtable-2level.h
--- linux-2.6/include/asm-i386/pgtable-2level.h~3level-i386-cleanup	2004-12-22 20:31:43.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable-2level.h	2004-12-22 20:31:43.000000000 +1100
@@ -1,44 +1,22 @@
 #ifndef _I386_PGTABLE_2LEVEL_H
 #define _I386_PGTABLE_2LEVEL_H
 
+#include <asm-generic/pgtable-nopmd.h>
+
 #define pte_ERROR(e) \
 	printk("%s:%d: bad pte %08lx.\n", __FILE__, __LINE__, (e).pte_low)
-#define pmd_ERROR(e) \
-	printk("%s:%d: bad pmd %08lx.\n", __FILE__, __LINE__, pmd_val(e))
 #define pgd_ERROR(e) \
 	printk("%s:%d: bad pgd %08lx.\n", __FILE__, __LINE__, pgd_val(e))
 
 /*
- * The "pgd_xxx()" functions here are trivial for a folded two-level
- * setup: the pgd is never bad, and a pmd always exists (as it's folded
- * into the pgd entry)
- */
-static inline int pgd_none(pgd_t pgd)		{ return 0; }
-static inline int pgd_bad(pgd_t pgd)		{ return 0; }
-static inline int pgd_present(pgd_t pgd)	{ return 1; }
-#define pgd_clear(xp)				do { } while (0)
-
-/*
  * Certain architectures need to do special things when PTEs
  * within a page table are directly modified.  Thus, the following
  * hook is made available.
  */
 #define set_pte(pteptr, pteval) (*(pteptr) = pteval)
 #define set_pte_atomic(pteptr, pteval) set_pte(pteptr,pteval)
-/*
- * (pmds are folded into pgds so this doesn't get actually called,
- * but the define is needed for a generic inline function.)
- */
-#define set_pmd(pmdptr, pmdval) (*(pmdptr) = pmdval)
-#define set_pgd(pgdptr, pgdval) (*(pgdptr) = pgdval)
+#define set_pmd(pmdptr, pmdval) (*(pmdptr) = (pmdval))
 
-#define pgd_page(pgd) \
-((unsigned long) __va(pgd_val(pgd) & PAGE_MASK))
-
-static inline pmd_t * pmd_offset(pgd_t * dir, unsigned long address)
-{
-	return (pmd_t *) dir;
-}
 #define ptep_get_and_clear(xp)	__pte(xchg(&(xp)->pte_low, 0))
 #define pte_same(a, b)		((a).pte_low == (b).pte_low)
 #define pte_page(x)		pfn_to_page(pte_pfn(x))
@@ -47,6 +25,11 @@ static inline pmd_t * pmd_offset(pgd_t *
 #define pfn_pte(pfn, prot)	__pte(((pfn) << PAGE_SHIFT) | pgprot_val(prot))
 #define pfn_pmd(pfn, prot)	__pmd(((pfn) << PAGE_SHIFT) | pgprot_val(prot))
 
+#define pmd_page(pmd) (pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
+
+#define pmd_page_kernel(pmd) \
+((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
+
 /*
  * All present user pages are user-executable:
  */
diff -puN include/asm-i386/page.h~3level-i386-cleanup include/asm-i386/page.h
--- linux-2.6/include/asm-i386/page.h~3level-i386-cleanup	2004-12-22 20:31:43.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/page.h	2004-12-22 20:31:43.000000000 +1100
@@ -46,11 +46,12 @@ typedef struct { unsigned long pte_low, 
 typedef struct { unsigned long long pmd; } pmd_t;
 typedef struct { unsigned long long pgd; } pgd_t;
 typedef struct { unsigned long long pgprot; } pgprot_t;
+#define pmd_val(x)	((x).pmd)
 #define pte_val(x)	((x).pte_low | ((unsigned long long)(x).pte_high << 32))
+#define __pmd(x) ((pmd_t) { (x) } )
 #define HPAGE_SHIFT	21
 #else
 typedef struct { unsigned long pte_low; } pte_t;
-typedef struct { unsigned long pmd; } pmd_t;
 typedef struct { unsigned long pgd; } pgd_t;
 typedef struct { unsigned long pgprot; } pgprot_t;
 #define boot_pte_t pte_t /* or would you rather have a typedef */
@@ -66,13 +67,10 @@ typedef struct { unsigned long pgprot; }
 #define HAVE_ARCH_HUGETLB_UNMAPPED_AREA
 #endif
 
-
-#define pmd_val(x)	((x).pmd)
 #define pgd_val(x)	((x).pgd)
 #define pgprot_val(x)	((x).pgprot)
 
 #define __pte(x) ((pte_t) { (x) } )
-#define __pmd(x) ((pmd_t) { (x) } )
 #define __pgd(x) ((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
diff -puN include/asm-i386/pgtable-2level-defs.h~3level-i386-cleanup include/asm-i386/pgtable-2level-defs.h
--- linux-2.6/include/asm-i386/pgtable-2level-defs.h~3level-i386-cleanup	2004-12-22 20:31:43.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable-2level-defs.h	2004-12-22 20:31:43.000000000 +1100
@@ -12,8 +12,6 @@
  * the i386 is two-level, so we don't really have any
  * PMD directory physically.
  */
-#define PMD_SHIFT	22
-#define PTRS_PER_PMD	1
 
 #define PTRS_PER_PTE	1024
 
diff -puN include/asm-i386/pgtable-3level.h~3level-i386-cleanup include/asm-i386/pgtable-3level.h
--- linux-2.6/include/asm-i386/pgtable-3level.h~3level-i386-cleanup	2004-12-22 20:31:43.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable-3level.h	2004-12-22 20:35:54.000000000 +1100
@@ -70,9 +70,18 @@ static inline void set_pte(pte_t *ptep, 
  */
 static inline void pgd_clear (pgd_t * pgd) { }
 
+#define pmd_page(pmd) (pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
+
+#define pmd_page_kernel(pmd) \
+((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
+
 #define pgd_page(pgd) \
+((struct page *) __va(pgd_val(pgd) & PAGE_MASK))
+
+#define pgd_page_kernel(pgd) \
 ((unsigned long) __va(pgd_val(pgd) & PAGE_MASK))
 
+
 /* Find an entry in the second-level page table.. */
 #define pmd_offset(dir, address) ((pmd_t *) pgd_page(*(dir)) + \
 			pmd_index(address))
@@ -142,4 +151,6 @@ static inline pmd_t pfn_pmd(unsigned lon
 #define __pte_to_swp_entry(pte)		((swp_entry_t){ (pte).pte_high })
 #define __swp_entry_to_pte(x)		((pte_t){ 0, (x).val })
 
+#define __pmd_free_tlb(tlb, x)		do { } while (0)
+
 #endif /* _I386_PGTABLE_3LEVEL_H */
diff -puN include/asm-i386/pgalloc.h~3level-i386-cleanup include/asm-i386/pgalloc.h
--- linux-2.6/include/asm-i386/pgalloc.h~3level-i386-cleanup	2004-12-22 20:31:43.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgalloc.h	2004-12-22 20:35:54.000000000 +1100
@@ -10,12 +10,10 @@
 #define pmd_populate_kernel(mm, pmd, pte) \
 		set_pmd(pmd, __pmd(_PAGE_TABLE + __pa(pte)))
 
-static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct page *pte)
-{
-	set_pmd(pmd, __pmd(_PAGE_TABLE +
-		((unsigned long long)page_to_pfn(pte) <<
-			(unsigned long long) PAGE_SHIFT)));
-}
+#define pmd_populate(mm, pmd, pte) 				\
+	set_pmd(pmd, __pmd(_PAGE_TABLE +			\
+		((unsigned long long)page_to_pfn(pte) <<	\
+			(unsigned long long) PAGE_SHIFT)))
 /*
  * Allocate and free page tables.
  */
@@ -39,16 +37,15 @@ static inline void pte_free(struct page 
 
 #define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
 
+#ifdef CONFIG_X86_PAE
 /*
- * allocating and freeing a pmd is trivial: the 1-entry pmd is
- * inside the pgd, so has no extra memory associated with it.
- * (In the PAE case we free the pmds as part of the pgd.)
+ * In the PAE case we free the pmds as part of the pgd.
  */
-
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
 #define pmd_free(x)			do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
+#endif
 
 #define check_pgt_cache()	do { } while (0)
 
diff -puN include/asm-i386/pgtable.h~3level-i386-cleanup include/asm-i386/pgtable.h
--- linux-2.6/include/asm-i386/pgtable.h~3level-i386-cleanup	2004-12-22 20:31:43.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable.h	2004-12-22 20:35:54.000000000 +1100
@@ -50,12 +50,12 @@ void paging_init(void);
  */
 #ifdef CONFIG_X86_PAE
 # include <asm/pgtable-3level-defs.h>
+# define PMD_SIZE	(1UL << PMD_SHIFT)
+# define PMD_MASK	(~(PMD_SIZE-1))
 #else
 # include <asm/pgtable-2level-defs.h>
 #endif
 
-#define PMD_SIZE	(1UL << PMD_SHIFT)
-#define PMD_MASK	(~(PMD_SIZE-1))
 #define PGDIR_SIZE	(1UL << PGDIR_SHIFT)
 #define PGDIR_MASK	(~(PGDIR_SIZE-1))
 
@@ -293,15 +293,8 @@ static inline pte_t pte_modify(pte_t pte
 
 #define page_pte(page) page_pte_prot(page, __pgprot(0))
 
-#define pmd_page_kernel(pmd) \
-((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
-
-#ifndef CONFIG_DISCONTIGMEM
-#define pmd_page(pmd) (pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
-#endif /* !CONFIG_DISCONTIGMEM */
-
 #define pmd_large(pmd) \
-	((pmd_val(pmd) & (_PAGE_PSE|_PAGE_PRESENT)) == (_PAGE_PSE|_PAGE_PRESENT))
+((pmd_val(pmd) & (_PAGE_PSE|_PAGE_PRESENT)) == (_PAGE_PSE|_PAGE_PRESENT))
 
 /*
  * the pgd page can be thought of an array like this: pgd_t[PTRS_PER_PGD]
diff -puN include/asm-i386/mmzone.h~3level-i386-cleanup include/asm-i386/mmzone.h
--- linux-2.6/include/asm-i386/mmzone.h~3level-i386-cleanup	2004-12-22 20:31:43.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/mmzone.h	2004-12-22 20:31:44.000000000 +1100
@@ -116,7 +116,6 @@ static inline struct pglist_data *pfn_to
 	(unsigned long)(__page - __zone->zone_mem_map)			\
 		+ __zone->zone_start_pfn;				\
 })
-#define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
 
 #ifdef CONFIG_X86_NUMAQ            /* we have contiguous memory on NUMA-Q */
 #define pfn_valid(pfn)          ((pfn) < num_physpages)

_

--------------060509050809010303080604--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
