Message-ID: <4196F12D.20005@yahoo.com.au>
Date: Sun, 14 Nov 2004 16:46:21 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [RFC] Possible alternate 4 level pagetables?
Content-Type: multipart/mixed;
 boundary="------------050503000501010702040701"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050503000501010702040701
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andi,

Just looking at your 4 level page tables patch, I wondered why the extra
level isn't inserted between pgd and pmd, as that would appear to be the
least intrusive (conceptually, in the generic code). Also it maybe matches
more closely the way that the 2->3 level conversion was done.

I've been toying with it a little bit. It is mainly just starting with
your code and doing straight conversions, although I also attempted to
implement a better compatibility layer that does the pagetable "folding"
for you if you don't need to use the full range of them.

Caveats are that there is still something slightly broken with it on i386,
and so I haven't looked at x86-64 yet. I don't see why this wouldn't work
though.

I've called the new level 'pud'. u for upper or something.

Sorry the patch isn't in very good shape at the moment - I won't have time
to work on it for a week, so I thought this would be a good point just to
solicit initial comments.

Patches against recent -bk. patch 1/4 attached.

Thanks,
Nick

--------------050503000501010702040701
Content-Type: text/x-patch;
 name="3level-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3level-cleanup.patch"




---

 linux-2.6-npiggin/include/asm-generic/pgtable-nopmd.h    |   47 +++++++++++++++
 linux-2.6-npiggin/include/asm-i386/mmzone.h              |    1 
 linux-2.6-npiggin/include/asm-i386/page.h                |    6 -
 linux-2.6-npiggin/include/asm-i386/pgalloc.h             |    7 --
 linux-2.6-npiggin/include/asm-i386/pgtable-2level-defs.h |    2 
 linux-2.6-npiggin/include/asm-i386/pgtable-2level.h      |   27 +-------
 linux-2.6-npiggin/include/asm-i386/pgtable-3level.h      |    7 ++
 linux-2.6-npiggin/include/asm-i386/pgtable.h             |   14 +---
 8 files changed, 68 insertions(+), 43 deletions(-)

diff -puN /dev/null include/asm-generic/pgtable-nopmd.h
--- /dev/null	2004-09-06 19:38:39.000000000 +1000
+++ linux-2.6-npiggin/include/asm-generic/pgtable-nopmd.h	2004-11-14 12:31:01.000000000 +1100
@@ -0,0 +1,47 @@
+#ifndef _PGTABLE_NOPMD_H
+#define _PGTABLE_NOPMD_H
+
+#define PMD_SHIFT	PGDIR_SHIFT
+#define PTRS_PER_PMD	1
+#define PMD_SIZE  (1UL << PMD_SHIFT)
+#define PMD_MASK  (~(PMD_SIZE-1))
+
+/*
+ * The "pgd_xxx()" functions here are trivial for a folded two-level
+ * setup: the pmd is never bad, and a pmd always exists (as it's folded
+ * into the pgd entry)
+ */
+#define pgd_none(pmd)			0
+#define pgd_bad(pmd)			0
+#define pgd_present(pmd)		1
+#define pgd_clear(xp)			do { } while (0)
+#define pgd_ERROR(pmd)			do { } while (0)
+
+#define pgd_populate(mm, pmd, pte)		do { } while (0)
+#define pgd_populate_kernel(mm, pmd, pte)	do { } while (0)
+
+/*
+ * (pmds are folded into pgds so this doesn't get actually called,
+ * but the define is needed for a generic inline function.)
+ */
+#define set_pmd(pmdptr, pmdval)		set_pgd(((pgd_t *)pmdptr), __pgd(pmd_val(pmdval)))
+
+#define pmd_offset(pgd, address)	((pmd_t *)(pgd))
+
+#define pmd_val(x)			(pgd_val((x).pmd))
+#define __pmd(x)			((pmd_t) { (x) } )
+
+#define pmd_page(pmd)			(pgd_page(*(pgd_t *)&(pmd)))
+#define pmd_page_kernel(pmd)		(pgd_page_kernel(*(pgd_t *)&(pmd)))
+
+/*
+ * allocating and freeing a pmd is trivial: the 1-entry pmd is
+ * inside the pgd, so has no extra memory associated with it.
+ */
+#define pmd_alloc_one(mm, address)		NULL
+#define pmd_free(x)				do { } while (0)
+#define __pmd_free_tlb(tlb, x)			do { } while (0)
+
+typedef struct { pgd_t pmd; } pmd_t;
+
+#endif /* _PGTABLE_NOPMD_H */
diff -puN include/asm-i386/pgtable-2level.h~3level-cleanup include/asm-i386/pgtable-2level.h
--- linux-2.6/include/asm-i386/pgtable-2level.h~3level-cleanup	2004-11-13 18:44:06.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable-2level.h	2004-11-13 18:44:06.000000000 +1100
@@ -1,22 +1,12 @@
 #ifndef _I386_PGTABLE_2LEVEL_H
 #define _I386_PGTABLE_2LEVEL_H
 
+#include <asm-generic/pgtable-nopmd.h>
+
 #define pte_ERROR(e) \
 	printk("%s:%d: bad pte %08lx.\n", __FILE__, __LINE__, (e).pte_low)
 #define pmd_ERROR(e) \
 	printk("%s:%d: bad pmd %08lx.\n", __FILE__, __LINE__, pmd_val(e))
-#define pgd_ERROR(e) \
-	printk("%s:%d: bad pgd %08lx.\n", __FILE__, __LINE__, pgd_val(e))
-
-/*
- * The "pgd_xxx()" functions here are trivial for a folded two-level
- * setup: the pgd is never bad, and a pmd always exists (as it's folded
- * into the pgd entry)
- */
-static inline int pgd_none(pgd_t pgd)		{ return 0; }
-static inline int pgd_bad(pgd_t pgd)		{ return 0; }
-static inline int pgd_present(pgd_t pgd)	{ return 1; }
-#define pgd_clear(xp)				do { } while (0)
 
 /*
  * Certain architectures need to do special things when PTEs
@@ -25,20 +15,11 @@ static inline int pgd_present(pgd_t pgd)
  */
 #define set_pte(pteptr, pteval) (*(pteptr) = pteval)
 #define set_pte_atomic(pteptr, pteval) set_pte(pteptr,pteval)
-/*
- * (pmds are folded into pgds so this doesn't get actually called,
- * but the define is needed for a generic inline function.)
- */
-#define set_pmd(pmdptr, pmdval) (*(pmdptr) = pmdval)
+
 #define set_pgd(pgdptr, pgdval) (*(pgdptr) = pgdval)
 
-#define pgd_page(pgd) \
-((unsigned long) __va(pgd_val(pgd) & PAGE_MASK))
+#define pgd_page(pgd) (pfn_to_page(pgd_val(pgd) >> PAGE_SHIFT))
 
-static inline pmd_t * pmd_offset(pgd_t * dir, unsigned long address)
-{
-	return (pmd_t *) dir;
-}
 #define ptep_get_and_clear(xp)	__pte(xchg(&(xp)->pte_low, 0))
 #define pte_same(a, b)		((a).pte_low == (b).pte_low)
 #define pte_page(x)		pfn_to_page(pte_pfn(x))
diff -puN include/asm-i386/page.h~3level-cleanup include/asm-i386/page.h
--- linux-2.6/include/asm-i386/page.h~3level-cleanup	2004-11-13 18:44:06.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/page.h	2004-11-13 18:44:06.000000000 +1100
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
 
diff -puN include/asm-i386/pgtable-2level-defs.h~3level-cleanup include/asm-i386/pgtable-2level-defs.h
--- linux-2.6/include/asm-i386/pgtable-2level-defs.h~3level-cleanup	2004-11-13 18:44:06.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable-2level-defs.h	2004-11-13 18:44:06.000000000 +1100
@@ -12,8 +12,6 @@
  * the i386 is two-level, so we don't really have any
  * PMD directory physically.
  */
-#define PMD_SHIFT	22
-#define PTRS_PER_PMD	1
 
 #define PTRS_PER_PTE	1024
 
diff -puN include/asm-generic/pgtable.h~3level-cleanup include/asm-generic/pgtable.h
diff -puN include/asm-i386/pgtable-3level.h~3level-cleanup include/asm-i386/pgtable-3level.h
--- linux-2.6/include/asm-i386/pgtable-3level.h~3level-cleanup	2004-11-13 18:44:06.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable-3level.h	2004-11-14 12:31:01.000000000 +1100
@@ -73,6 +73,11 @@ static inline void pgd_clear (pgd_t * pg
 #define pgd_page(pgd) \
 ((unsigned long) __va(pgd_val(pgd) & PAGE_MASK))
 
+#define pmd_page(pmd) (pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
+
+#define pmd_page_kernel(pmd) \
+((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
+
 /* Find an entry in the second-level page table.. */
 #define pmd_offset(dir, address) ((pmd_t *) pgd_page(*(dir)) + \
 			pmd_index(address))
@@ -142,4 +147,6 @@ static inline pmd_t pfn_pmd(unsigned lon
 #define __pte_to_swp_entry(pte)		((swp_entry_t){ (pte).pte_high })
 #define __swp_entry_to_pte(x)		((pte_t){ 0, (x).val })
 
+#define __pmd_free_tlb(tlb, x)		do { } while (0)
+
 #endif /* _I386_PGTABLE_3LEVEL_H */
diff -puN include/asm-i386/pgalloc.h~3level-cleanup include/asm-i386/pgalloc.h
--- linux-2.6/include/asm-i386/pgalloc.h~3level-cleanup	2004-11-13 18:44:06.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgalloc.h	2004-11-14 12:31:01.000000000 +1100
@@ -39,16 +39,15 @@ static inline void pte_free(struct page 
 
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
 
diff -puN include/asm-i386/pgtable.h~3level-cleanup include/asm-i386/pgtable.h
--- linux-2.6/include/asm-i386/pgtable.h~3level-cleanup	2004-11-13 18:44:06.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable.h	2004-11-14 12:30:02.000000000 +1100
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
 
@@ -293,15 +293,11 @@ static inline pte_t pte_modify(pte_t pte
 
 #define page_pte(page) page_pte_prot(page, __pgprot(0))
 
-#define pmd_page_kernel(pmd) \
-((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
-
-#ifndef CONFIG_DISCONTIGMEM
-#define pmd_page(pmd) (pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
-#endif /* !CONFIG_DISCONTIGMEM */
+#define pgd_page_kernel(pgd) \
+((unsigned long) __va(pgd_val(pgd) & PAGE_MASK))
 
 #define pmd_large(pmd) \
-	((pmd_val(pmd) & (_PAGE_PSE|_PAGE_PRESENT)) == (_PAGE_PSE|_PAGE_PRESENT))
+((pmd_val(pmd) & (_PAGE_PSE|_PAGE_PRESENT)) == (_PAGE_PSE|_PAGE_PRESENT))
 
 /*
  * the pgd page can be thought of an array like this: pgd_t[PTRS_PER_PGD]
diff -puN include/asm-i386/mmzone.h~3level-cleanup include/asm-i386/mmzone.h
--- linux-2.6/include/asm-i386/mmzone.h~3level-cleanup	2004-11-13 18:44:06.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/mmzone.h	2004-11-13 18:44:06.000000000 +1100
@@ -116,7 +116,6 @@ static inline struct pglist_data *pfn_to
 	(unsigned long)(__page - __zone->zone_mem_map)			\
 		+ __zone->zone_start_pfn;				\
 })
-#define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
 
 #ifdef CONFIG_X86_NUMAQ            /* we have contiguous memory on NUMA-Q */
 #define pfn_valid(pfn)          ((pfn) < num_physpages)

_

--------------050503000501010702040701--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
