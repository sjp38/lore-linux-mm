Message-ID: <4196F151.50805@yahoo.com.au>
Date: Sun, 14 Nov 2004 16:46:57 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Possible alternate 4 level pagetables?
References: <4196F12D.20005@yahoo.com.au>
In-Reply-To: <4196F12D.20005@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------040200060208020608070700"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040200060208020608070700
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

2/4

--------------040200060208020608070700
Content-Type: text/x-patch;
 name="4level-compat.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4level-compat.patch"




---

 linux-2.6-npiggin/include/asm-generic/pgtable-nopmd.h |   44 ++++++++--------
 linux-2.6-npiggin/include/asm-generic/pgtable-nopud.h |   47 ++++++++++++++++++
 linux-2.6-npiggin/include/asm-generic/tlb.h           |    6 ++
 linux-2.6-npiggin/include/asm-i386/pgalloc.h          |    2 
 linux-2.6-npiggin/include/asm-i386/pgtable-3level.h   |   16 +++---
 5 files changed, 86 insertions(+), 29 deletions(-)

diff -puN /dev/null include/asm-generic/pgtable-nopud.h
--- /dev/null	2004-09-06 19:38:39.000000000 +1000
+++ linux-2.6-npiggin/include/asm-generic/pgtable-nopud.h	2004-11-14 12:33:19.000000000 +1100
@@ -0,0 +1,47 @@
+#ifndef _PGTABLE_NOPUD_H
+#define _PGTABLE_NOPUD_H
+
+#define PUD_SHIFT	PGDIR_SHIFT
+#define PTRS_PER_PUD	1
+#define PUD_SIZE  (1UL << PUD_SHIFT)
+#define PUD_MASK  (~(PUD_SIZE-1))
+
+/*
+ * The "pgd_xxx()" functions here are trivial for a folded two or three-level
+ * setup: the pgd is never bad, and a pud always exists (as it's folded
+ * into the pgd entry)
+ */
+#define pgd_none(pgd)			0
+#define pgd_bad(pgd)			0
+#define pgd_present(pgd)		1
+#define pgd_clear(xp)			do { } while (0)
+#define pgd_ERROR(pgd)			do { } while (0)
+
+#define pgd_populate(mm, pud, pmd)	do { } while (0)
+
+/*
+ * (puds are folded into pgds so this doesn't get actually called,
+ * but the define is needed for a generic inline function.)
+ */
+#define set_pud(pudptr, pudval)		set_pgd(((pgd_t *)pudptr), *(pgd_t *)&(pudval))
+
+#define pud_offset(pgd, address)	((pud_t *)(pgd))
+#define pud_offset_k(pgd, address)	((pud_t *)(pgd))
+
+#define pud_val(x)			(pgd_val((x).pud))
+#define __pud(x)			((pud_t) { (x) } )
+
+#define pud_page(pud)			(pgd_page(*(pgd_t *)&(pud)))
+#define pud_page_kernel(pud)		(pgd_page_kernel(*(pgd_t *)&(pud)))
+
+/*
+ * allocating and freeing a pud is trivial: the 1-entry pud is
+ * inside the pgd, so has no extra memory associated with it.
+ */
+#define pud_alloc_one(mm, address)	NULL
+#define pud_free(x)			do { } while (0)
+#define __pud_free_tlb(tlb, x)		do { } while (0)
+
+typedef struct { pgd_t pud; } pud_t;
+
+#endif /* _PGTABLE_NOPUD_H */
diff -puN include/asm-generic/pgtable-nopmd.h~4level-compat include/asm-generic/pgtable-nopmd.h
--- linux-2.6/include/asm-generic/pgtable-nopmd.h~4level-compat	2004-11-14 12:32:51.000000000 +1100
+++ linux-2.6-npiggin/include/asm-generic/pgtable-nopmd.h	2004-11-14 12:32:51.000000000 +1100
@@ -1,47 +1,49 @@
 #ifndef _PGTABLE_NOPMD_H
 #define _PGTABLE_NOPMD_H
 
-#define PMD_SHIFT	PGDIR_SHIFT
+#include <asm-generic/pgtable-nopud.h>
+
+#define PMD_SHIFT	PUD_SHIFT
 #define PTRS_PER_PMD	1
 #define PMD_SIZE  (1UL << PMD_SHIFT)
 #define PMD_MASK  (~(PMD_SIZE-1))
 
 /*
- * The "pgd_xxx()" functions here are trivial for a folded two-level
+ * The "pud_xxx()" functions here are trivial for a folded two-level
  * setup: the pmd is never bad, and a pmd always exists (as it's folded
- * into the pgd entry)
+ * into the pud entry)
  */
-#define pgd_none(pmd)			0
-#define pgd_bad(pmd)			0
-#define pgd_present(pmd)		1
-#define pgd_clear(xp)			do { } while (0)
-#define pgd_ERROR(pmd)			do { } while (0)
+#define pud_none(pmd)			0
+#define pud_bad(pmd)			0
+#define pud_present(pmd)		1
+#define pud_clear(xp)			do { } while (0)
+#define pud_ERROR(pmd)			do { } while (0)
 
-#define pgd_populate(mm, pmd, pte)		do { } while (0)
-#define pgd_populate_kernel(mm, pmd, pte)	do { } while (0)
+#define pud_populate(mm, pmd, pte)		do { } while (0)
+#define pud_populate_kernel(mm, pmd, pte)	do { } while (0)
 
 /*
- * (pmds are folded into pgds so this doesn't get actually called,
+ * (pmds are folded into puds so this doesn't get actually called,
  * but the define is needed for a generic inline function.)
  */
-#define set_pmd(pmdptr, pmdval)		set_pgd(((pgd_t *)pmdptr), __pgd(pmd_val(pmdval)))
+#define set_pmd(pmdptr, pmdval)		set_pud(((pud_t *)pmdptr), *(pud_t *)&(pmdval))
 
-#define pmd_offset(pgd, address)	((pmd_t *)(pgd))
+#define pmd_offset(pud, address)	((pmd_t *)(pud))
 
-#define pmd_val(x)			(pgd_val((x).pmd))
+#define pmd_val(x)			(pud_val((x).pmd))
 #define __pmd(x)			((pmd_t) { (x) } )
 
-#define pmd_page(pmd)			(pgd_page(*(pgd_t *)&(pmd)))
-#define pmd_page_kernel(pmd)		(pgd_page_kernel(*(pgd_t *)&(pmd)))
+#define pmd_page(pmd)			(pud_page(*(pud_t *)&(pmd)))
+#define pmd_page_kernel(pmd)		(pud_page_kernel(*(pud_t *)&(pmd)))
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
- * inside the pgd, so has no extra memory associated with it.
+ * inside the pud, so has no extra memory associated with it.
  */
-#define pmd_alloc_one(mm, address)		NULL
-#define pmd_free(x)				do { } while (0)
-#define __pmd_free_tlb(tlb, x)			do { } while (0)
+#define pmd_alloc_one(mm, address)	NULL
+#define pmd_free(x)			do { } while (0)
+#define __pmd_free_tlb(tlb, x)		do { } while (0)
 
-typedef struct { pgd_t pmd; } pmd_t;
+typedef struct { pud_t pmd; } pmd_t;
 
 #endif /* _PGTABLE_NOPMD_H */
diff -puN include/asm-i386/pgtable.h~4level-compat include/asm-i386/pgtable.h
diff -puN include/asm-generic/tlb.h~4level-compat include/asm-generic/tlb.h
--- linux-2.6/include/asm-generic/tlb.h~4level-compat	2004-11-14 12:32:51.000000000 +1100
+++ linux-2.6-npiggin/include/asm-generic/tlb.h	2004-11-14 12:32:51.000000000 +1100
@@ -141,6 +141,12 @@ static inline void tlb_remove_page(struc
 		__pte_free_tlb(tlb, ptep);			\
 	} while (0)
 
+#define pud_free_tlb(tlb, pudp)					\
+	do {							\
+		tlb->need_flush = 1;				\
+		__pud_free_tlb(tlb, pudp);			\
+	} while (0)
+
 #define pmd_free_tlb(tlb, pmdp)					\
 	do {							\
 		tlb->need_flush = 1;				\
diff -puN include/asm-i386/pgtable-3level.h~4level-compat include/asm-i386/pgtable-3level.h
--- linux-2.6/include/asm-i386/pgtable-3level.h~4level-compat	2004-11-14 12:32:51.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable-3level.h	2004-11-14 12:32:51.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef _I386_PGTABLE_3LEVEL_H
 #define _I386_PGTABLE_3LEVEL_H
 
+#include <asm-generic/pgtable-nopud.h>
+
 /*
  * Intel Physical Address Extension (PAE) Mode - three-level page
  * tables on PPro+ CPUs.
@@ -12,12 +14,12 @@
 	printk("%s:%d: bad pte %p(%08lx%08lx).\n", __FILE__, __LINE__, &(e), (e).pte_high, (e).pte_low)
 #define pmd_ERROR(e) \
 	printk("%s:%d: bad pmd %p(%016Lx).\n", __FILE__, __LINE__, &(e), pmd_val(e))
-#define pgd_ERROR(e) \
-	printk("%s:%d: bad pgd %p(%016Lx).\n", __FILE__, __LINE__, &(e), pgd_val(e))
+#define pud_ERROR(e) \
+	printk("%s:%d: bad pud %p(%016Lx).\n", __FILE__, __LINE__, &(e), pud_val(e))
 
-static inline int pgd_none(pgd_t pgd)		{ return 0; }
-static inline int pgd_bad(pgd_t pgd)		{ return 0; }
-static inline int pgd_present(pgd_t pgd)	{ return 1; }
+#define pud_none(pud)				0
+#define pud_bad(pud)				0
+#define pud_present(pud)			1
 
 /*
  * Is the pte executable?
@@ -68,7 +70,7 @@ static inline void set_pte(pte_t *ptep, 
  * We do not let the generic code free and clear pgd entries due to
  * this erratum.
  */
-static inline void pgd_clear (pgd_t * pgd) { }
+#define pud_clear(pud)                do { } while (0)
 
 #define pgd_page(pgd) \
 ((unsigned long) __va(pgd_val(pgd) & PAGE_MASK))
@@ -79,7 +81,7 @@ static inline void pgd_clear (pgd_t * pg
 ((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
 
 /* Find an entry in the second-level page table.. */
-#define pmd_offset(dir, address) ((pmd_t *) pgd_page(*(dir)) + \
+#define pmd_offset(pud, address) ((pmd_t *) pud_page(*(pud)) + \
 			pmd_index(address))
 
 static inline pte_t ptep_get_and_clear(pte_t *ptep)
diff -puN include/asm-i386/pgalloc.h~4level-compat include/asm-i386/pgalloc.h
--- linux-2.6/include/asm-i386/pgalloc.h~4level-compat	2004-11-14 12:32:51.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgalloc.h	2004-11-14 12:32:51.000000000 +1100
@@ -46,7 +46,7 @@ static inline void pte_free(struct page 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
 #define pmd_free(x)			do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
-#define pgd_populate(mm, pmd, pte)	BUG()
+#define pud_populate(mm, pmd, pte)	BUG()
 #endif
 
 #define check_pgt_cache()	do { } while (0)

_

--------------040200060208020608070700--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
