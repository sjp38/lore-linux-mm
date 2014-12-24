Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 789976B00C1
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:31:22 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so9924997pac.25
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:31:22 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id dn2si34129159pbc.160.2014.12.24.04.23.13
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:14 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 29/38] powerpc: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:37 +0200
Message-Id: <1419423766-114457-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
---
 arch/powerpc/include/asm/pgtable-ppc32.h | 9 ++-------
 arch/powerpc/include/asm/pgtable-ppc64.h | 5 +----
 arch/powerpc/include/asm/pgtable.h       | 1 -
 arch/powerpc/include/asm/pte-40x.h       | 1 -
 arch/powerpc/include/asm/pte-44x.h       | 5 -----
 arch/powerpc/include/asm/pte-8xx.h       | 1 -
 arch/powerpc/include/asm/pte-book3e.h    | 1 -
 arch/powerpc/include/asm/pte-fsl-booke.h | 3 ---
 arch/powerpc/include/asm/pte-hash32.h    | 1 -
 arch/powerpc/include/asm/pte-hash64.h    | 1 -
 arch/powerpc/mm/pgtable_64.c             | 2 +-
 11 files changed, 4 insertions(+), 26 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc32.h b/arch/powerpc/include/asm/pgtable-ppc32.h
index 234e07c47803..c718bfd58bcb 100644
--- a/arch/powerpc/include/asm/pgtable-ppc32.h
+++ b/arch/powerpc/include/asm/pgtable-ppc32.h
@@ -332,8 +332,8 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 /*
  * Encode and decode a swap entry.
  * Note that the bits we use in a PTE for representing a swap entry
- * must not include the _PAGE_PRESENT bit, the _PAGE_FILE bit, or the
- *_PAGE_HASHPTE bit (if used).  -- paulus
+ * must not include the _PAGE_PRESENT bit or the _PAGE_HASHPTE bit (if used).
+ *   -- paulus
  */
 #define __swp_type(entry)		((entry).val & 0x1f)
 #define __swp_offset(entry)		((entry).val >> 5)
@@ -341,11 +341,6 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) >> 3 })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val << 3 })
 
-/* Encode and decode a nonlinear file mapping entry */
-#define PTE_FILE_MAX_BITS	29
-#define pte_to_pgoff(pte)	(pte_val(pte) >> 3)
-#define pgoff_to_pte(off)	((pte_t) { ((off) << 3) | _PAGE_FILE })
-
 /*
  * No page table caches to initialise
  */
diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index ddf4e29fbd3f..3956c71b95b7 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -352,9 +352,6 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 #define __swp_entry(type, offset) ((swp_entry_t){((type)<< 1)|((offset)<<8)})
 #define __pte_to_swp_entry(pte)	((swp_entry_t){pte_val(pte) >> PTE_RPN_SHIFT})
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val << PTE_RPN_SHIFT })
-#define pte_to_pgoff(pte)	(pte_val(pte) >> PTE_RPN_SHIFT)
-#define pgoff_to_pte(off)	((pte_t) {((off) << PTE_RPN_SHIFT)|_PAGE_FILE})
-#define PTE_FILE_MAX_BITS	(BITS_PER_LONG - PTE_RPN_SHIFT)
 
 void pgtable_cache_add(unsigned shift, void (*ctor)(void *));
 void pgtable_cache_init(void);
@@ -389,7 +386,7 @@ void pgtable_cache_init(void);
  * The last three bits are intentionally left to zero. This memory location
  * are also used as normal page PTE pointers. So if we have any pointers
  * left around while we collapse a hugepage, we need to make sure
- * _PAGE_PRESENT and _PAGE_FILE bits of that are zero when we look at them
+ * _PAGE_PRESENT bit of that is zero when we look at them
  */
 static inline unsigned int hpte_valid(unsigned char *hpte_slot_array, int index)
 {
diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index a8805fee0df9..48c9a50e1151 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -33,7 +33,6 @@ struct mm_struct;
 static inline int pte_write(pte_t pte)		{ return pte_val(pte) & _PAGE_RW; }
 static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
-static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
 static inline int pte_special(pte_t pte)	{ return pte_val(pte) & _PAGE_SPECIAL; }
 static inline int pte_none(pte_t pte)		{ return (pte_val(pte) & ~_PTE_NONE_MASK) == 0; }
 static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & PAGE_PROT_BITS); }
diff --git a/arch/powerpc/include/asm/pte-40x.h b/arch/powerpc/include/asm/pte-40x.h
index ec0b0b0d1df9..486b1ef81338 100644
--- a/arch/powerpc/include/asm/pte-40x.h
+++ b/arch/powerpc/include/asm/pte-40x.h
@@ -38,7 +38,6 @@
  */
 
 #define	_PAGE_GUARDED	0x001	/* G: page is guarded from prefetch */
-#define _PAGE_FILE	0x001	/* when !present: nonlinear file mapping */
 #define _PAGE_PRESENT	0x002	/* software: PTE contains a translation */
 #define	_PAGE_NO_CACHE	0x004	/* I: caching is inhibited */
 #define	_PAGE_WRITETHRU	0x008	/* W: caching is write-through */
diff --git a/arch/powerpc/include/asm/pte-44x.h b/arch/powerpc/include/asm/pte-44x.h
index 4192b9bad901..36f75fab23f5 100644
--- a/arch/powerpc/include/asm/pte-44x.h
+++ b/arch/powerpc/include/asm/pte-44x.h
@@ -44,9 +44,6 @@
  *   - PRESENT *must* be in the bottom three bits because swap cache
  *     entries use the top 29 bits for TLB2.
  *
- *   - FILE *must* be in the bottom three bits because swap cache
- *     entries use the top 29 bits for TLB2.
- *
  *   - CACHE COHERENT bit (M) has no effect on original PPC440 cores,
  *     because it doesn't support SMP. However, some later 460 variants
  *     have -some- form of SMP support and so I keep the bit there for
@@ -68,7 +65,6 @@
  *
  * There are three protection bits available for SWAP entry:
  *	_PAGE_PRESENT
- *	_PAGE_FILE
  *	_PAGE_HASHPTE (if HW has)
  *
  * So those three bits have to be inside of 0-2nd LSB of PTE.
@@ -77,7 +73,6 @@
 
 #define _PAGE_PRESENT	0x00000001		/* S: PTE valid */
 #define _PAGE_RW	0x00000002		/* S: Write permission */
-#define _PAGE_FILE	0x00000004		/* S: nonlinear file mapping */
 #define _PAGE_EXEC	0x00000004		/* H: Execute permission */
 #define _PAGE_ACCESSED	0x00000008		/* S: Page referenced */
 #define _PAGE_DIRTY	0x00000010		/* S: Page dirty */
diff --git a/arch/powerpc/include/asm/pte-8xx.h b/arch/powerpc/include/asm/pte-8xx.h
index daa4616e61c4..b2d6b9a22e7c 100644
--- a/arch/powerpc/include/asm/pte-8xx.h
+++ b/arch/powerpc/include/asm/pte-8xx.h
@@ -29,7 +29,6 @@
 
 /* Definitions for 8xx embedded chips. */
 #define _PAGE_PRESENT	0x0001	/* Page is valid */
-#define _PAGE_FILE	0x0002	/* when !present: nonlinear file mapping */
 #define _PAGE_NO_CACHE	0x0002	/* I: cache inhibit */
 #define _PAGE_SHARED	0x0004	/* No ASID (context) compare */
 #define _PAGE_SPECIAL	0x0008	/* SW entry, forced to 0 by the TLB miss */
diff --git a/arch/powerpc/include/asm/pte-book3e.h b/arch/powerpc/include/asm/pte-book3e.h
index 576ad88104cb..91a704952ca1 100644
--- a/arch/powerpc/include/asm/pte-book3e.h
+++ b/arch/powerpc/include/asm/pte-book3e.h
@@ -10,7 +10,6 @@
 
 /* Architected bits */
 #define _PAGE_PRESENT	0x000001 /* software: pte contains a translation */
-#define _PAGE_FILE	0x000002 /* (!present only) software: pte holds file offset */
 #define _PAGE_SW1	0x000002
 #define _PAGE_BAP_SR	0x000004
 #define _PAGE_BAP_UR	0x000008
diff --git a/arch/powerpc/include/asm/pte-fsl-booke.h b/arch/powerpc/include/asm/pte-fsl-booke.h
index e84dd7ed505e..9f5c3d04a1a3 100644
--- a/arch/powerpc/include/asm/pte-fsl-booke.h
+++ b/arch/powerpc/include/asm/pte-fsl-booke.h
@@ -13,14 +13,11 @@
    - PRESENT *must* be in the bottom three bits because swap cache
      entries use the top 29 bits.
 
-   - FILE *must* be in the bottom three bits because swap cache
-     entries use the top 29 bits.
 */
 
 /* Definitions for FSL Book-E Cores */
 #define _PAGE_PRESENT	0x00001	/* S: PTE contains a translation */
 #define _PAGE_USER	0x00002	/* S: User page (maps to UR) */
-#define _PAGE_FILE	0x00002	/* S: when !present: nonlinear file mapping */
 #define _PAGE_RW	0x00004	/* S: Write permission (SW) */
 #define _PAGE_DIRTY	0x00008	/* S: Page dirty */
 #define _PAGE_EXEC	0x00010	/* H: SX permission */
diff --git a/arch/powerpc/include/asm/pte-hash32.h b/arch/powerpc/include/asm/pte-hash32.h
index 4aad4132d0a8..62cfb0c663bb 100644
--- a/arch/powerpc/include/asm/pte-hash32.h
+++ b/arch/powerpc/include/asm/pte-hash32.h
@@ -18,7 +18,6 @@
 
 #define _PAGE_PRESENT	0x001	/* software: pte contains a translation */
 #define _PAGE_HASHPTE	0x002	/* hash_page has made an HPTE for this pte */
-#define _PAGE_FILE	0x004	/* when !present: nonlinear file mapping */
 #define _PAGE_USER	0x004	/* usermode access allowed */
 #define _PAGE_GUARDED	0x008	/* G: prohibit speculative access */
 #define _PAGE_COHERENT	0x010	/* M: enforce memory coherence (SMP systems) */
diff --git a/arch/powerpc/include/asm/pte-hash64.h b/arch/powerpc/include/asm/pte-hash64.h
index 2505d8eab15c..1a66c25eeac2 100644
--- a/arch/powerpc/include/asm/pte-hash64.h
+++ b/arch/powerpc/include/asm/pte-hash64.h
@@ -16,7 +16,6 @@
  */
 #define _PAGE_PRESENT		0x0001 /* software: pte contains a translation */
 #define _PAGE_USER		0x0002 /* matches one of the PP bits */
-#define _PAGE_FILE		0x0002 /* (!present only) software: pte holds file offset */
 #define _PAGE_EXEC		0x0004 /* No execute on POWER4 and newer (we invert) */
 #define _PAGE_GUARDED		0x0008
 /* We can derive Memory coherence from _PAGE_NO_CACHE */
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 4fe5f64cc179..8526c5896c94 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -781,7 +781,7 @@ pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot)
 {
 	pmd_t pmd;
 	/*
-	 * For a valid pte, we would have _PAGE_PRESENT or _PAGE_FILE always
+	 * For a valid pte, we would have _PAGE_PRESENT always
 	 * set. We use this to check THP page at pmd level.
 	 * leaf pte for huge page, bottom two bits != 00
 	 */
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
