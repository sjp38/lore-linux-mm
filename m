Message-ID: <41C3D479.40708@yahoo.com.au>
Date: Sat, 18 Dec 2004 17:55:53 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 1/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au>
In-Reply-To: <41C3D453.4040208@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------050802070405040700080703"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050802070405040700080703
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

1/10

--------------050802070405040700080703
Content-Type: text/plain;
 name="3level-compat.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3level-compat.patch"



Generic headers to fold the 3-level pagetable into 2 levels.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/include/asm-generic/pgtable-nopmd.h |   59 ++++++++++++++++++
 1 files changed, 59 insertions(+)

diff -puN /dev/null include/asm-generic/pgtable-nopmd.h
--- /dev/null	2004-09-06 19:38:39.000000000 +1000
+++ linux-2.6-npiggin/include/asm-generic/pgtable-nopmd.h	2004-12-18 17:07:48.000000000 +1100
@@ -0,0 +1,59 @@
+#ifndef _PGTABLE_NOPMD_H
+#define _PGTABLE_NOPMD_H
+
+#ifndef __ASSEMBLY__
+
+/*
+ * Having the pmd type consist of a pgd gets the size right, and allows
+ * us to conceptually access the pgd entry that this pmd is folded into
+ * without casting.
+ */
+typedef struct { pgd_t pgd; } pmd_t;
+
+#define PMD_SHIFT	PGDIR_SHIFT
+#define PTRS_PER_PMD	1
+#define PMD_SIZE  	(1UL << PMD_SHIFT)
+#define PMD_MASK  	(~(PMD_SIZE-1))
+
+/*
+ * The "pgd_xxx()" functions here are trivial for a folded two-level
+ * setup: the pmd is never bad, and a pmd always exists (as it's folded
+ * into the pgd entry)
+ */
+static inline int pgd_none(pgd_t pgd)		{ return 0; }
+static inline int pgd_bad(pgd_t pgd)		{ return 0; }
+static inline int pgd_present(pgd_t pgd)	{ return 1; }
+static inline void pgd_clear(pgd_t *pgd)	{ }
+#define pmd_ERROR(pmd)				(pgd_ERROR((pmd).pgd))
+
+#define pgd_populate(mm, pmd, pte)		do { } while (0)
+#define pgd_populate_kernel(mm, pmd, pte)	do { } while (0)
+
+/*
+ * (pmds are folded into pgds so this doesn't get actually called,
+ * but the define is needed for a generic inline function.)
+ */
+#define set_pgd(pgdptr, pgdval)			set_pmd((pmd_t *)(pgdptr), (pmd_t) { pgdval })
+
+static inline pmd_t * pmd_offset(pgd_t * pgd, unsigned long address)
+{
+	return (pmd_t *)pgd;
+}
+
+#define pmd_val(x)				(pgd_val((x).pgd))
+#define __pmd(x)				((pmd_t) { __pgd(x) } )
+
+#define pgd_page(pgd)				(pmd_page((pmd_t){ pgd }))
+#define pgd_page_kernel(pgd)			(pmd_page_kernel((pmd_t){ pgd }))
+
+/*
+ * allocating and freeing a pmd is trivial: the 1-entry pmd is
+ * inside the pgd, so has no extra memory associated with it.
+ */
+#define pmd_alloc_one(mm, address)		NULL
+#define pmd_free(x)				do { } while (0)
+#define __pmd_free_tlb(tlb, x)			do { } while (0)
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _PGTABLE_NOPMD_H */

_

--------------050802070405040700080703--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
