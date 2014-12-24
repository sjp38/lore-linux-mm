Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id ABCCC6B008C
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:48 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id w10so9792434pde.25
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:48 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id nr8si34465401pdb.5.2014.12.24.04.23.20
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:21 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 37/38] x86: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:45 +0200
Message-Id: <1419423766-114457-38-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
---
 arch/x86/include/asm/pgtable-2level.h | 38 +----------------------------------
 arch/x86/include/asm/pgtable-3level.h | 12 -----------
 arch/x86/include/asm/pgtable.h        | 20 ------------------
 arch/x86/include/asm/pgtable_64.h     |  6 +-----
 arch/x86/include/asm/pgtable_types.h  |  3 ---
 5 files changed, 2 insertions(+), 77 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
index 206a87fdd22d..fd74a11959de 100644
--- a/arch/x86/include/asm/pgtable-2level.h
+++ b/arch/x86/include/asm/pgtable-2level.h
@@ -62,44 +62,8 @@ static inline unsigned long pte_bitop(unsigned long value, unsigned int rightshi
 	return ((value >> rightshift) & mask) << leftshift;
 }
 
-/*
- * Bits _PAGE_BIT_PRESENT, _PAGE_BIT_FILE and _PAGE_BIT_PROTNONE are taken,
- * split up the 29 bits of offset into this range.
- */
-#define PTE_FILE_MAX_BITS	29
-#define PTE_FILE_SHIFT1		(_PAGE_BIT_PRESENT + 1)
-#define PTE_FILE_SHIFT2		(_PAGE_BIT_FILE + 1)
-#define PTE_FILE_SHIFT3		(_PAGE_BIT_PROTNONE + 1)
-#define PTE_FILE_BITS1		(PTE_FILE_SHIFT2 - PTE_FILE_SHIFT1 - 1)
-#define PTE_FILE_BITS2		(PTE_FILE_SHIFT3 - PTE_FILE_SHIFT2 - 1)
-
-#define PTE_FILE_MASK1		((1U << PTE_FILE_BITS1) - 1)
-#define PTE_FILE_MASK2		((1U << PTE_FILE_BITS2) - 1)
-
-#define PTE_FILE_LSHIFT2	(PTE_FILE_BITS1)
-#define PTE_FILE_LSHIFT3	(PTE_FILE_BITS1 + PTE_FILE_BITS2)
-
-static __always_inline pgoff_t pte_to_pgoff(pte_t pte)
-{
-	return (pgoff_t)
-		(pte_bitop(pte.pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1,  0)		    +
-		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2,  PTE_FILE_LSHIFT2) +
-		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT3,           -1UL,  PTE_FILE_LSHIFT3));
-}
-
-static __always_inline pte_t pgoff_to_pte(pgoff_t off)
-{
-	return (pte_t){
-		.pte_low =
-			pte_bitop(off,                0, PTE_FILE_MASK1,  PTE_FILE_SHIFT1) +
-			pte_bitop(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2,  PTE_FILE_SHIFT2) +
-			pte_bitop(off, PTE_FILE_LSHIFT3,           -1UL,  PTE_FILE_SHIFT3) +
-			_PAGE_FILE,
-	};
-}
-
 /* Encode and de-code a swap entry */
-#define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)
+#define SWP_TYPE_BITS 5
 #define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
 
 #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS)
diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index 81bb91b49a88..cdaa58c9b39e 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -176,18 +176,6 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
 #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
 #endif
 
-/*
- * Bits 0, 6 and 7 are taken in the low part of the pte,
- * put the 32 bits of offset into the high part.
- *
- * For soft-dirty tracking 11 bit is taken from
- * the low part of pte as well.
- */
-#define pte_to_pgoff(pte) ((pte).pte_high)
-#define pgoff_to_pte(off)						\
-	((pte_t) { { .pte_low = _PAGE_FILE, .pte_high = (off) } })
-#define PTE_FILE_MAX_BITS       32
-
 /* Encode and de-code a swap entry */
 #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > 5)
 #define __swp_type(x)			(((x).val) & 0x1f)
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5e105ca5de51..0c4bde7b9b5e 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -115,11 +115,6 @@ static inline int pte_write(pte_t pte)
 	return pte_flags(pte) & _PAGE_RW;
 }
 
-static inline int pte_file(pte_t pte)
-{
-	return pte_flags(pte) & _PAGE_FILE;
-}
-
 static inline int pte_huge(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_PSE;
@@ -334,21 +329,6 @@ static inline pmd_t pmd_mksoft_dirty(pmd_t pmd)
 	return pmd_set_flags(pmd, _PAGE_SOFT_DIRTY);
 }
 
-static inline pte_t pte_file_clear_soft_dirty(pte_t pte)
-{
-	return pte_clear_flags(pte, _PAGE_SOFT_DIRTY);
-}
-
-static inline pte_t pte_file_mksoft_dirty(pte_t pte)
-{
-	return pte_set_flags(pte, _PAGE_SOFT_DIRTY);
-}
-
-static inline int pte_file_soft_dirty(pte_t pte)
-{
-	return pte_flags(pte) & _PAGE_SOFT_DIRTY;
-}
-
 #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
 
 /*
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 4572b2f30237..e227970f983e 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -133,10 +133,6 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 /* PUD - Level3 access */
 
 /* PMD  - Level 2 access */
-#define pte_to_pgoff(pte) ((pte_val((pte)) & PHYSICAL_PAGE_MASK) >> PAGE_SHIFT)
-#define pgoff_to_pte(off) ((pte_t) { .pte = ((off) << PAGE_SHIFT) |	\
-					    _PAGE_FILE })
-#define PTE_FILE_MAX_BITS __PHYSICAL_MASK_SHIFT
 
 /* PTE - Level 1 access. */
 
@@ -145,7 +141,7 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 #define pte_unmap(pte) ((void)(pte))/* NOP */
 
 /* Encode and de-code a swap entry */
-#define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)
+#define SWP_TYPE_BITS 5
 #ifdef CONFIG_NUMA_BALANCING
 /* Automatic NUMA balancing needs to be distinguishable from swap entries */
 #define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 2)
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 25bcd4a89517..5185a4f599ec 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -38,8 +38,6 @@
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
 #define _PAGE_BIT_PROTNONE	_PAGE_BIT_GLOBAL
-/* - set: nonlinear file mapping, saved PTE; unset:swap */
-#define _PAGE_BIT_FILE		_PAGE_BIT_DIRTY
 
 #define _PAGE_PRESENT	(_AT(pteval_t, 1) << _PAGE_BIT_PRESENT)
 #define _PAGE_RW	(_AT(pteval_t, 1) << _PAGE_BIT_RW)
@@ -114,7 +112,6 @@
 #define _PAGE_NX	(_AT(pteval_t, 0))
 #endif
 
-#define _PAGE_FILE	(_AT(pteval_t, 1) << _PAGE_BIT_FILE)
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
 #define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
