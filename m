Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5556B0071
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 09:05:26 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so10155945pab.30
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 06:05:26 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ut3si34421315pab.193.2014.12.24.06.05.23
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 06:05:24 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-33-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1419423766-114457-33-git-send-email-kirill.shutemov@linux.intel.com>
Subject: [PATCH] sh: drop _PAGE_FILE and pte_file()-related helpers
Content-Transfer-Encoding: 7bit
Message-Id: <20141224140505.BD564A6@black.fi.intel.com>
Date: Wed, 24 Dec 2014 16:05:05 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-sh@vger.kernel.org

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: linux-sh@vger.kernel.org
---

 v2: build fix: #endif is removed by mistake

---
 arch/sh/include/asm/pgtable_32.h | 30 ++++--------------------------
 arch/sh/include/asm/pgtable_64.h |  9 +--------
 2 files changed, 5 insertions(+), 34 deletions(-)

diff --git a/arch/sh/include/asm/pgtable_32.h b/arch/sh/include/asm/pgtable_32.h
index 0bce3d81569e..c646e563abce 100644
--- a/arch/sh/include/asm/pgtable_32.h
+++ b/arch/sh/include/asm/pgtable_32.h
@@ -26,8 +26,6 @@
  *   and timing control which (together with bit 0) are moved into the
  *   old-style PTEA on the parts that support it.
  *
- * XXX: Leave the _PAGE_FILE and _PAGE_WT overhaul for a rainy day.
- *
  * SH-X2 MMUs and extended PTEs
  *
  * SH-X2 supports an extended mode TLB with split data arrays due to the
@@ -51,7 +49,6 @@
 #define _PAGE_PRESENT	0x100		/* V-bit   : page is valid */
 #define _PAGE_PROTNONE	0x200		/* software: if not present  */
 #define _PAGE_ACCESSED	0x400		/* software: page referenced */
-#define _PAGE_FILE	_PAGE_WT	/* software: pagecache or swap? */
 #define _PAGE_SPECIAL	0x800		/* software: special page */
 
 #define _PAGE_SZ_MASK	(_PAGE_SZ0 | _PAGE_SZ1)
@@ -105,14 +102,13 @@ static inline unsigned long copy_ptea_attributes(unsigned long x)
 /* Mask which drops unused bits from the PTEL value */
 #if defined(CONFIG_CPU_SH3)
 #define _PAGE_CLEAR_FLAGS	(_PAGE_PROTNONE | _PAGE_ACCESSED| \
-				 _PAGE_FILE	| _PAGE_SZ1	| \
-				 _PAGE_HW_SHARED)
+				  _PAGE_SZ1	| _PAGE_HW_SHARED)
 #elif defined(CONFIG_X2TLB)
 /* Get rid of the legacy PR/SZ bits when using extended mode */
 #define _PAGE_CLEAR_FLAGS	(_PAGE_PROTNONE | _PAGE_ACCESSED | \
-				 _PAGE_FILE | _PAGE_PR_MASK | _PAGE_SZ_MASK)
+				 _PAGE_PR_MASK | _PAGE_SZ_MASK)
 #else
-#define _PAGE_CLEAR_FLAGS	(_PAGE_PROTNONE | _PAGE_ACCESSED | _PAGE_FILE)
+#define _PAGE_CLEAR_FLAGS	(_PAGE_PROTNONE | _PAGE_ACCESSED)
 #endif
 
 #define _PAGE_FLAGS_HARDWARE_MASK	(phys_addr_mask() & ~(_PAGE_CLEAR_FLAGS))
@@ -343,7 +339,6 @@ static inline void set_pte(pte_t *ptep, pte_t pte)
 #define pte_not_present(pte)	(!((pte).pte_low & _PAGE_PRESENT))
 #define pte_dirty(pte)		((pte).pte_low & _PAGE_DIRTY)
 #define pte_young(pte)		((pte).pte_low & _PAGE_ACCESSED)
-#define pte_file(pte)		((pte).pte_low & _PAGE_FILE)
 #define pte_special(pte)	((pte).pte_low & _PAGE_SPECIAL)
 
 #ifdef CONFIG_X2TLB
@@ -445,7 +440,6 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
  * Encode and de-code a swap entry
  *
  * Constraints:
- *	_PAGE_FILE at bit 0
  *	_PAGE_PRESENT at bit 8
  *	_PAGE_PROTNONE at bit 9
  *
@@ -453,9 +447,7 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
  * swap offset into bits 10:30. For the 64-bit PTE case, we keep the
  * preserved bits in the low 32-bits and use the upper 32 as the swap
  * offset (along with a 5-bit type), following the same approach as x86
- * PAE. This keeps the logic quite simple, and allows for a full 32
- * PTE_FILE_MAX_BITS, as opposed to the 29-bits we're constrained with
- * in the pte_low case.
+ * PAE. This keeps the logic quite simple.
  *
  * As is evident by the Alpha code, if we ever get a 64-bit unsigned
  * long (swp_entry_t) to match up with the 64-bit PTEs, this all becomes
@@ -471,13 +463,6 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 #define __pte_to_swp_entry(pte)		((swp_entry_t){ (pte).pte_high })
 #define __swp_entry_to_pte(x)		((pte_t){ 0, (x).val })
 
-/*
- * Encode and decode a nonlinear file mapping entry
- */
-#define pte_to_pgoff(pte)		((pte).pte_high)
-#define pgoff_to_pte(off)		((pte_t) { _PAGE_FILE, (off) })
-
-#define PTE_FILE_MAX_BITS		32
 #else
 #define __swp_type(x)			((x).val & 0xff)
 #define __swp_offset(x)			((x).val >> 10)
@@ -485,13 +470,6 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) >> 1 })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val << 1 })
-
-/*
- * Encode and decode a nonlinear file mapping entry
- */
-#define PTE_FILE_MAX_BITS	29
-#define pte_to_pgoff(pte)	(pte_val(pte) >> 1)
-#define pgoff_to_pte(off)	((pte_t) { ((off) << 1) | _PAGE_FILE })
 #endif
 
 #endif /* __ASSEMBLY__ */
diff --git a/arch/sh/include/asm/pgtable_64.h b/arch/sh/include/asm/pgtable_64.h
index dda8c82601b9..07424968df62 100644
--- a/arch/sh/include/asm/pgtable_64.h
+++ b/arch/sh/include/asm/pgtable_64.h
@@ -107,7 +107,6 @@ static __inline__ void set_pte(pte_t *pteptr, pte_t pteval)
 #define _PAGE_DEVICE	0x001  /* CB0: if uncacheable, 1->device (i.e. no write-combining or reordering at bus level) */
 #define _PAGE_CACHABLE	0x002  /* CB1: uncachable/cachable */
 #define _PAGE_PRESENT	0x004  /* software: page referenced */
-#define _PAGE_FILE	0x004  /* software: only when !present */
 #define _PAGE_SIZE0	0x008  /* SZ0-bit : size of page */
 #define _PAGE_SIZE1	0x010  /* SZ1-bit : size of page */
 #define _PAGE_SHARED	0x020  /* software: reflects PTEH's SH */
@@ -129,7 +128,7 @@ static __inline__ void set_pte(pte_t *pteptr, pte_t pteval)
 #define _PAGE_WIRED	_PAGE_EXT(0x001) /* software: wire the tlb entry */
 #define _PAGE_SPECIAL	_PAGE_EXT(0x002)
 
-#define _PAGE_CLEAR_FLAGS	(_PAGE_PRESENT | _PAGE_FILE | _PAGE_SHARED | \
+#define _PAGE_CLEAR_FLAGS	(_PAGE_PRESENT | _PAGE_SHARED | \
 				 _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_WIRED)
 
 /* Mask which drops software flags */
@@ -260,7 +259,6 @@ static __inline__ void set_pte(pte_t *pteptr, pte_t pteval)
  */
 static inline int pte_dirty(pte_t pte)  { return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)  { return pte_val(pte) & _PAGE_ACCESSED; }
-static inline int pte_file(pte_t pte)   { return pte_val(pte) & _PAGE_FILE; }
 static inline int pte_write(pte_t pte)  { return pte_val(pte) & _PAGE_WRITE; }
 static inline int pte_special(pte_t pte){ return pte_val(pte) & _PAGE_SPECIAL; }
 
@@ -304,11 +302,6 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-/* Encode and decode a nonlinear file mapping entry */
-#define PTE_FILE_MAX_BITS		29
-#define pte_to_pgoff(pte)		(pte_val(pte))
-#define pgoff_to_pte(off)		((pte_t) { (off) | _PAGE_FILE })
-
 #endif /* !__ASSEMBLY__ */
 
 #define pfn_pte(pfn, prot)	__pte(((pfn) << PAGE_SHIFT) | pgprot_val(prot))
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
