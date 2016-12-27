Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 78C0F6B0268
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:54:44 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g1so737180090pgn.3
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:54:44 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n187si26679909pga.63.2016.12.26.17.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:54:43 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 05/29] asm-generic: introduce <asm-generic/pgtable-nop4d.h>
Date: Tue, 27 Dec 2016 04:53:49 +0300
Message-Id: <20161227015413.187403-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Like with pgtable-nopud.h for 4-level paging, this new header is base
for converting an architectures to properly folded p4d_t level.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/asm-generic/pgtable-nop4d.h | 56 +++++++++++++++++++++++++++++++++++++
 include/asm-generic/pgtable-nopud.h | 43 ++++++++++++++--------------
 include/asm-generic/tlb.h           | 14 ++++++++--
 3 files changed, 89 insertions(+), 24 deletions(-)
 create mode 100644 include/asm-generic/pgtable-nop4d.h

diff --git a/include/asm-generic/pgtable-nop4d.h b/include/asm-generic/pgtable-nop4d.h
new file mode 100644
index 000000000000..de364ecb8df6
--- /dev/null
+++ b/include/asm-generic/pgtable-nop4d.h
@@ -0,0 +1,56 @@
+#ifndef _PGTABLE_NOP4D_H
+#define _PGTABLE_NOP4D_H
+
+#ifndef __ASSEMBLY__
+
+#define __PAGETABLE_P4D_FOLDED
+
+typedef struct { pgd_t pgd; } p4d_t;
+
+#define P4D_SHIFT	PGDIR_SHIFT
+#define PTRS_PER_P4D	1
+#define P4D_SIZE	(1UL << P4D_SHIFT)
+#define P4D_MASK	(~(P4D_SIZE-1))
+
+/*
+ * The "pgd_xxx()" functions here are trivial for a folded two-level
+ * setup: the p4d is never bad, and a p4d always exists (as it's folded
+ * into the pgd entry)
+ */
+static inline int pgd_none(pgd_t pgd)		{ return 0; }
+static inline int pgd_bad(pgd_t pgd)		{ return 0; }
+static inline int pgd_present(pgd_t pgd)	{ return 1; }
+static inline void pgd_clear(pgd_t *pgd)	{ }
+#define p4d_ERROR(p4d)				(pgd_ERROR((p4d).pgd))
+
+#define pgd_populate(mm, pgd, p4d)		do { } while (0)
+/*
+ * (p4ds are folded into pgds so this doesn't get actually called,
+ * but the define is needed for a generic inline function.)
+ */
+#define set_pgd(pgdptr, pgdval)	set_p4d((p4d_t *)(pgdptr), (p4d_t) { pgdval })
+
+static inline p4d_t *p4d_offset(pgd_t *pgd, unsigned long address)
+{
+	return (p4d_t *)pgd;
+}
+
+#define p4d_val(x)				(pgd_val((x).pgd))
+#define __p4d(x)				((p4d_t) { __pgd(x) })
+
+#define pgd_page(pgd)				(p4d_page((p4d_t){ pgd }))
+#define pgd_page_vaddr(pgd)			(p4d_page_vaddr((p4d_t){ pgd }))
+
+/*
+ * allocating and freeing a p4d is trivial: the 1-entry p4d is
+ * inside the pgd, so has no extra memory associated with it.
+ */
+#define p4d_alloc_one(mm, address)		NULL
+#define p4d_free(mm, x)				do { } while (0)
+#define __p4d_free_tlb(tlb, x, a)		do { } while (0)
+
+#undef  p4d_addr_end
+#define p4d_addr_end(addr, end)			(end)
+
+#endif /* __ASSEMBLY__ */
+#endif /* _PGTABLE_NOP4D_H */
diff --git a/include/asm-generic/pgtable-nopud.h b/include/asm-generic/pgtable-nopud.h
index 5e49430a30a4..c2b9b96d6268 100644
--- a/include/asm-generic/pgtable-nopud.h
+++ b/include/asm-generic/pgtable-nopud.h
@@ -6,53 +6,54 @@
 #ifdef __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nop4d-hack.h>
 #else
+#include <asm-generic/pgtable-nop4d.h>
 
 #define __PAGETABLE_PUD_FOLDED
 
 /*
- * Having the pud type consist of a pgd gets the size right, and allows
- * us to conceptually access the pgd entry that this pud is folded into
+ * Having the pud type consist of a p4d gets the size right, and allows
+ * us to conceptually access the p4d entry that this pud is folded into
  * without casting.
  */
-typedef struct { pgd_t pgd; } pud_t;
+typedef struct { p4d_t p4d; } pud_t;
 
-#define PUD_SHIFT	PGDIR_SHIFT
+#define PUD_SHIFT	P4D_SHIFT
 #define PTRS_PER_PUD	1
 #define PUD_SIZE  	(1UL << PUD_SHIFT)
 #define PUD_MASK  	(~(PUD_SIZE-1))
 
 /*
- * The "pgd_xxx()" functions here are trivial for a folded two-level
+ * The "p4d_xxx()" functions here are trivial for a folded two-level
  * setup: the pud is never bad, and a pud always exists (as it's folded
- * into the pgd entry)
+ * into the p4d entry)
  */
-static inline int pgd_none(pgd_t pgd)		{ return 0; }
-static inline int pgd_bad(pgd_t pgd)		{ return 0; }
-static inline int pgd_present(pgd_t pgd)	{ return 1; }
-static inline void pgd_clear(pgd_t *pgd)	{ }
-#define pud_ERROR(pud)				(pgd_ERROR((pud).pgd))
+static inline int p4d_none(p4d_t p4d)		{ return 0; }
+static inline int p4d_bad(p4d_t p4d)		{ return 0; }
+static inline int p4d_present(p4d_t p4d)	{ return 1; }
+static inline void p4d_clear(p4d_t *p4d)	{ }
+#define pud_ERROR(pud)				(p4d_ERROR((pud).p4d))
 
-#define pgd_populate(mm, pgd, pud)		do { } while (0)
+#define p4d_populate(mm, p4d, pud)		do { } while (0)
 /*
- * (puds are folded into pgds so this doesn't get actually called,
+ * (puds are folded into p4ds so this doesn't get actually called,
  * but the define is needed for a generic inline function.)
  */
-#define set_pgd(pgdptr, pgdval)			set_pud((pud_t *)(pgdptr), (pud_t) { pgdval })
+#define set_p4d(p4dptr, p4dval)	set_pud((pud_t *)(p4dptr), (pud_t) { p4dval })
 
-static inline pud_t * pud_offset(pgd_t * pgd, unsigned long address)
+static inline pud_t *pud_offset(p4d_t *p4d, unsigned long address)
 {
-	return (pud_t *)pgd;
+	return (pud_t *)p4d;
 }
 
-#define pud_val(x)				(pgd_val((x).pgd))
-#define __pud(x)				((pud_t) { __pgd(x) } )
+#define pud_val(x)				(p4d_val((x).p4d))
+#define __pud(x)				((pud_t) { __p4d(x) })
 
-#define pgd_page(pgd)				(pud_page((pud_t){ pgd }))
-#define pgd_page_vaddr(pgd)			(pud_page_vaddr((pud_t){ pgd }))
+#define p4d_page(p4d)				(pud_page((pud_t){ p4d }))
+#define p4d_page_vaddr(p4d)			(pud_page_vaddr((pud_t){ p4d }))
 
 /*
  * allocating and freeing a pud is trivial: the 1-entry pud is
- * inside the pgd, so has no extra memory associated with it.
+ * inside the p4d, so has no extra memory associated with it.
  */
 #define pud_alloc_one(mm, address)		NULL
 #define pud_free(mm, x)				do { } while (0)
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 7eed8cf3130a..a6b51b1a7b7f 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -256,6 +256,12 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 		__pte_free_tlb(tlb, ptep, address);		\
 	} while (0)
 
+#define pmd_free_tlb(tlb, pmdp, address)			\
+	do {							\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
+		__pmd_free_tlb(tlb, pmdp, address);		\
+	} while (0)
+
 #ifndef __ARCH_HAS_4LEVEL_HACK
 #define pud_free_tlb(tlb, pudp, address)			\
 	do {							\
@@ -264,11 +270,13 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 	} while (0)
 #endif
 
-#define pmd_free_tlb(tlb, pmdp, address)			\
+#ifndef __ARCH_HAS_5LEVEL_HACK
+#define p4d_free_tlb(tlb, pudp, address)			\
 	do {							\
-		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
-		__pmd_free_tlb(tlb, pmdp, address);		\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
+		__p4d_free_tlb(tlb, pudp, address);		\
 	} while (0)
+#endif
 
 #define tlb_migrate_finish(mm) do {} while (0)
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
