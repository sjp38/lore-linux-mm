Message-ID: <41C3D4F9.9040803@yahoo.com.au>
Date: Sat, 18 Dec 2004 17:58:01 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 5/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au>
In-Reply-To: <41C3D4C8.1000508@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------010301020400030808090806"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010301020400030808090806
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

5/10

--------------010301020400030808090806
Content-Type: text/plain;
 name="4level-compat.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4level-compat.patch"



Generic headers to fold the 4-level pagetable into 3 levels.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/include/asm-generic/pgtable-nopmd.h |   46 +++++++------
 linux-2.6-npiggin/include/asm-generic/pgtable-nopud.h |   61 ++++++++++++++++++
 linux-2.6-npiggin/include/asm-generic/tlb.h           |    6 +
 3 files changed, 91 insertions(+), 22 deletions(-)

diff -puN /dev/null include/asm-generic/pgtable-nopud.h
--- /dev/null	2004-09-06 19:38:39.000000000 +1000
+++ linux-2.6-npiggin/include/asm-generic/pgtable-nopud.h	2004-12-18 16:57:19.000000000 +1100
@@ -0,0 +1,61 @@
+#ifndef _PGTABLE_NOPUD_H
+#define _PGTABLE_NOPUD_H
+
+#ifndef __ASSEMBLY__
+
+/*
+ * Having the pud type consist of a pgd gets the size right, and allows
+ * us to conceptually access the pgd entry that this pud is folded into
+ * without casting.
+ */
+typedef struct { pgd_t pgd; } pud_t;
+
+#define PUD_SHIFT	PGDIR_SHIFT
+#define PTRS_PER_PUD	1
+#define PUD_SIZE  	(1UL << PUD_SHIFT)
+#define PUD_MASK  	(~(PUD_SIZE-1))
+
+/*
+ * The "pgd_xxx()" functions here are trivial for a folded two-level
+ * setup: the pud is never bad, and a pud always exists (as it's folded
+ * into the pgd entry)
+ */
+static inline int pgd_none(pgd_t pgd)		{ return 0; }
+static inline int pgd_bad(pgd_t pgd)		{ return 0; }
+static inline int pgd_present(pgd_t pgd)	{ return 1; }
+static inline void pgd_clear(pgd_t *pgd)	{ }
+#define pud_ERROR(pud)				(pgd_ERROR((pud).pgd))
+
+#define pgd_populate(mm, pgd, pud)		do { } while (0)
+/*
+ * (puds are folded into pgds so this doesn't get actually called,
+ * but the define is needed for a generic inline function.)
+ */
+#define set_pgd(pgdptr, pgdval)			set_pud((pud_t *)(pgdptr), (pud_t) { pgdval })
+
+static inline pud_t * pud_offset(pgd_t * pgd, unsigned long address)
+{
+	return (pud_t *)pgd;
+}
+
+static inline pud_t * pud_offset_k(pgd_t * pgd, unsigned long address)
+{
+	return (pud_t *)pgd;
+}
+
+#define pud_val(x)				(pgd_val((x).pgd))
+#define __pud(x)				((pud_t) { __pgd(x) } )
+
+#define pgd_page(pgd)				(pud_page((pud_t){ pgd }))
+#define pgd_page_kernel(pgd)			(pud_page_kernel((pud_t){ pgd }))
+
+/*
+ * allocating and freeing a pud is trivial: the 1-entry pud is
+ * inside the pgd, so has no extra memory associated with it.
+ */
+#define pud_alloc_one(mm, address)		NULL
+#define pud_free(x)				do { } while (0)
+#define __pud_free_tlb(tlb, x)			do { } while (0)
+
+#endif /* __ASSEMBLY__ */
+#endif /* _PGTABLE_NOPUD_H */
diff -puN include/asm-generic/pgtable-nopmd.h~4level-compat include/asm-generic/pgtable-nopmd.h
--- linux-2.6/include/asm-generic/pgtable-nopmd.h~4level-compat	2004-12-18 16:57:19.000000000 +1100
+++ linux-2.6-npiggin/include/asm-generic/pgtable-nopmd.h	2004-12-18 16:57:19.000000000 +1100
@@ -3,52 +3,54 @@
 
 #ifndef __ASSEMBLY__
 
+#include <asm-generic/pgtable-nopud.h>
+
 /*
- * Having the pmd type consist of a pgd gets the size right, and allows
- * us to conceptually access the pgd entry that this pmd is folded into
+ * Having the pmd type consist of a pud gets the size right, and allows
+ * us to conceptually access the pud entry that this pmd is folded into
  * without casting.
  */
-typedef struct { pgd_t pgd; } pmd_t;
+typedef struct { pud_t pud; } pmd_t;
 
-#define PMD_SHIFT	PGDIR_SHIFT
+#define PMD_SHIFT	PUD_SHIFT
 #define PTRS_PER_PMD	1
 #define PMD_SIZE  	(1UL << PMD_SHIFT)
 #define PMD_MASK  	(~(PMD_SIZE-1))
 
 /*
- * The "pgd_xxx()" functions here are trivial for a folded two-level
+ * The "pud_xxx()" functions here are trivial for a folded two-level
  * setup: the pmd is never bad, and a pmd always exists (as it's folded
- * into the pgd entry)
+ * into the pud entry)
  */
-static inline int pgd_none(pgd_t pgd)		{ return 0; }
-static inline int pgd_bad(pgd_t pgd)		{ return 0; }
-static inline int pgd_present(pgd_t pgd)	{ return 1; }
-static inline void pgd_clear(pgd_t *pgd)	{ }
-#define pmd_ERROR(pmd)				(pgd_ERROR((pmd).pgd))
+static inline int pud_none(pud_t pud)		{ return 0; }
+static inline int pud_bad(pud_t pud)		{ return 0; }
+static inline int pud_present(pud_t pud)	{ return 1; }
+static inline void pud_clear(pud_t *pud)	{ }
+#define pmd_ERROR(pmd)				(pud_ERROR((pmd).pud))
 
-#define pgd_populate(mm, pmd, pte)		do { } while (0)
-#define pgd_populate_kernel(mm, pmd, pte)	do { } while (0)
+#define pud_populate(mm, pmd, pte)		do { } while (0)
+#define pud_populate_kernel(mm, pmd, pte)	do { } while (0)
 
 /*
- * (pmds are folded into pgds so this doesn't get actually called,
+ * (pmds are folded into puds so this doesn't get actually called,
  * but the define is needed for a generic inline function.)
  */
-#define set_pgd(pgdptr, pgdval)			set_pmd((pmd_t *)(pgdptr), (pmd_t) { pgdval })
+#define set_pud(pudptr, pudval)			set_pmd((pmd_t *)(pudptr), (pmd_t) { pudval })
 
-static inline pmd_t * pmd_offset(pgd_t * pgd, unsigned long address)
+static inline pmd_t * pmd_offset(pud_t * pud, unsigned long address)
 {
-	return (pmd_t *)pgd;
+	return (pmd_t *)pud;
 }
 
-#define pmd_val(x)				(pgd_val((x).pgd))
-#define __pmd(x)				((pmd_t) { __pgd(x) } )
+#define pmd_val(x)				(pud_val((x).pud))
+#define __pmd(x)				((pmd_t) { __pud(x) } )
 
-#define pgd_page(pgd)				(pmd_page((pmd_t){ pgd }))
-#define pgd_page_kernel(pgd)			(pmd_page_kernel((pmd_t){ pgd }))
+#define pud_page(pud)				(pmd_page((pmd_t){ pud }))
+#define pud_page_kernel(pud)			(pmd_page_kernel((pmd_t){ pud }))
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
- * inside the pgd, so has no extra memory associated with it.
+ * inside the pud, so has no extra memory associated with it.
  */
 #define pmd_alloc_one(mm, address)		NULL
 #define pmd_free(x)				do { } while (0)
diff -puN include/asm-generic/tlb.h~4level-compat include/asm-generic/tlb.h
--- linux-2.6/include/asm-generic/tlb.h~4level-compat	2004-12-18 16:57:19.000000000 +1100
+++ linux-2.6-npiggin/include/asm-generic/tlb.h	2004-12-18 16:57:19.000000000 +1100
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

_

--------------010301020400030808090806--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
