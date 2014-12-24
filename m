Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7086B0083
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:38 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id r10so9920261pdi.9
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:38 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ru9si34134461pac.210.2014.12.24.04.23.11
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 24/38] mips: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:32 +0200
Message-Id: <1419423766-114457-25-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ralf Baechle <ralf@linux-mips.org>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
---
 arch/m68k/include/asm/mcf_pgtable.h  |  6 ++----
 arch/mips/include/asm/pgtable-32.h   | 36 ------------------------------------
 arch/mips/include/asm/pgtable-64.h   |  9 ---------
 arch/mips/include/asm/pgtable-bits.h |  9 ---------
 arch/mips/include/asm/pgtable.h      |  2 --
 5 files changed, 2 insertions(+), 60 deletions(-)

diff --git a/arch/m68k/include/asm/mcf_pgtable.h b/arch/m68k/include/asm/mcf_pgtable.h
index 7a4d8ee0b161..2500ce04fcc4 100644
--- a/arch/m68k/include/asm/mcf_pgtable.h
+++ b/arch/m68k/include/asm/mcf_pgtable.h
@@ -385,15 +385,13 @@ static inline void cache_page(void *vaddr)
 	*ptep = pte_mkcache(*ptep);
 }
 
-#define PTE_FILE_SHIFT		11
-
 /*
  * Encode and de-code a swap entry (must be !pte_none(e) && !pte_present(e))
  */
 #define __swp_type(x)		((x).val & 0xFF)
-#define __swp_offset(x)		((x).val >> PTE_FILE_SHIFT)
+#define __swp_offset(x)		((x).val >> 11)
 #define __swp_entry(typ, off)	((swp_entry_t) { (typ) | \
-					(off << PTE_FILE_SHIFT) })
+					(off << 11) })
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	(__pte((x).val))
 
diff --git a/arch/mips/include/asm/pgtable-32.h b/arch/mips/include/asm/pgtable-32.h
index 68984b612f9d..16aa9f23e17b 100644
--- a/arch/mips/include/asm/pgtable-32.h
+++ b/arch/mips/include/asm/pgtable-32.h
@@ -161,22 +161,6 @@ pfn_pte(unsigned long pfn, pgprot_t prot)
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-/*
- * Encode and decode a nonlinear file mapping entry
- */
-#define pte_to_pgoff(_pte)		((((_pte).pte >> 1 ) & 0x07) | \
-					 (((_pte).pte >> 2 ) & 0x38) | \
-					 (((_pte).pte >> 10) <<	 6 ))
-
-#define pgoff_to_pte(off)		((pte_t) { (((off) & 0x07) << 1 ) | \
-						   (((off) & 0x38) << 2 ) | \
-						   (((off) >>  6 ) << 10) | \
-						   _PAGE_FILE })
-
-/*
- * Bits 0, 4, 8, and 9 are taken, split up 28 bits of offset into this range:
- */
-#define PTE_FILE_MAX_BITS		28
 #else
 
 #if defined(CONFIG_PHYS_ADDR_T_64BIT) && defined(CONFIG_CPU_MIPS32)
@@ -188,13 +172,6 @@ pfn_pte(unsigned long pfn, pgprot_t prot)
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { (pte).pte_high })
 #define __swp_entry_to_pte(x)		((pte_t) { 0, (x).val })
 
-/*
- * Bits 0 and 1 of pte_high are taken, use the rest for the page offset...
- */
-#define pte_to_pgoff(_pte)		((_pte).pte_high >> 2)
-#define pgoff_to_pte(off)		((pte_t) { _PAGE_FILE, (off) << 2 })
-
-#define PTE_FILE_MAX_BITS		30
 #else
 /*
  * Constraints:
@@ -209,19 +186,6 @@ pfn_pte(unsigned long pfn, pgprot_t prot)
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-/*
- * Encode and decode a nonlinear file mapping entry
- */
-#define pte_to_pgoff(_pte)		((((_pte).pte >> 1) & 0x7) | \
-					 (((_pte).pte >> 2) & 0x8) | \
-					 (((_pte).pte >> 8) <<	4))
-
-#define pgoff_to_pte(off)		((pte_t) { (((off) & 0x7) << 1) | \
-						   (((off) & 0x8) << 2) | \
-						   (((off) >>  4) << 8) | \
-						   _PAGE_FILE })
-
-#define PTE_FILE_MAX_BITS		28
 #endif /* defined(CONFIG_PHYS_ADDR_T_64BIT) && defined(CONFIG_CPU_MIPS32) */
 
 #endif /* defined(CONFIG_CPU_R3000) || defined(CONFIG_CPU_TX39XX) */
diff --git a/arch/mips/include/asm/pgtable-64.h b/arch/mips/include/asm/pgtable-64.h
index e1c49a96807d..1659bb91ae21 100644
--- a/arch/mips/include/asm/pgtable-64.h
+++ b/arch/mips/include/asm/pgtable-64.h
@@ -291,13 +291,4 @@ static inline pte_t mk_swap_pte(unsigned long type, unsigned long offset)
 #define __pte_to_swp_entry(pte) ((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
 
-/*
- * Bits 0, 4, 6, and 7 are taken. Let's leave bits 1, 2, 3, and 5 alone to
- * make things easier, and only use the upper 56 bits for the page offset...
- */
-#define PTE_FILE_MAX_BITS	56
-
-#define pte_to_pgoff(_pte)	((_pte).pte >> 8)
-#define pgoff_to_pte(off)	((pte_t) { ((off) << 8) | _PAGE_FILE })
-
 #endif /* _ASM_PGTABLE_64_H */
diff --git a/arch/mips/include/asm/pgtable-bits.h b/arch/mips/include/asm/pgtable-bits.h
index ca11f14f40a3..fc807aa5ec8d 100644
--- a/arch/mips/include/asm/pgtable-bits.h
+++ b/arch/mips/include/asm/pgtable-bits.h
@@ -48,8 +48,6 @@
 
 /*
  * The following bits are implemented in software
- *
- * _PAGE_FILE semantics: set:pagecache unset:swap
  */
 #define _PAGE_PRESENT_SHIFT	(_CACHE_SHIFT + 3)
 #define _PAGE_PRESENT		(1 << _PAGE_PRESENT_SHIFT)
@@ -64,7 +62,6 @@
 
 #define _PAGE_SILENT_READ	_PAGE_VALID
 #define _PAGE_SILENT_WRITE	_PAGE_DIRTY
-#define _PAGE_FILE		_PAGE_MODIFIED
 
 #define _PFN_SHIFT		(PAGE_SHIFT - 12 + _CACHE_SHIFT + 3)
 
@@ -72,8 +69,6 @@
 
 /*
  * The following are implemented by software
- *
- * _PAGE_FILE semantics: set:pagecache unset:swap
  */
 #define _PAGE_PRESENT_SHIFT	0
 #define _PAGE_PRESENT		(1 <<  _PAGE_PRESENT_SHIFT)
@@ -85,8 +80,6 @@
 #define _PAGE_ACCESSED		(1 <<  _PAGE_ACCESSED_SHIFT)
 #define _PAGE_MODIFIED_SHIFT	4
 #define _PAGE_MODIFIED		(1 <<  _PAGE_MODIFIED_SHIFT)
-#define _PAGE_FILE_SHIFT	4
-#define _PAGE_FILE		(1 <<  _PAGE_FILE_SHIFT)
 
 /*
  * And these are the hardware TLB bits
@@ -116,7 +109,6 @@
  * The following bits are implemented in software
  *
  * _PAGE_READ / _PAGE_READ_SHIFT should be unused if cpu_has_rixi.
- * _PAGE_FILE semantics: set:pagecache unset:swap
  */
 #define _PAGE_PRESENT_SHIFT	(0)
 #define _PAGE_PRESENT		(1 << _PAGE_PRESENT_SHIFT)
@@ -128,7 +120,6 @@
 #define _PAGE_ACCESSED		(1 << _PAGE_ACCESSED_SHIFT)
 #define _PAGE_MODIFIED_SHIFT	(_PAGE_ACCESSED_SHIFT + 1)
 #define _PAGE_MODIFIED		(1 << _PAGE_MODIFIED_SHIFT)
-#define _PAGE_FILE		(_PAGE_MODIFIED)
 
 #ifdef CONFIG_MIPS_HUGE_TLB_SUPPORT
 /* huge tlb page */
diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
index 62a6ba383d4f..583ff4215479 100644
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -231,7 +231,6 @@ extern pgd_t swapper_pg_dir[];
 static inline int pte_write(pte_t pte)	{ return pte.pte_low & _PAGE_WRITE; }
 static inline int pte_dirty(pte_t pte)	{ return pte.pte_low & _PAGE_MODIFIED; }
 static inline int pte_young(pte_t pte)	{ return pte.pte_low & _PAGE_ACCESSED; }
-static inline int pte_file(pte_t pte)	{ return pte.pte_low & _PAGE_FILE; }
 
 static inline pte_t pte_wrprotect(pte_t pte)
 {
@@ -287,7 +286,6 @@ static inline pte_t pte_mkyoung(pte_t pte)
 static inline int pte_write(pte_t pte)	{ return pte_val(pte) & _PAGE_WRITE; }
 static inline int pte_dirty(pte_t pte)	{ return pte_val(pte) & _PAGE_MODIFIED; }
 static inline int pte_young(pte_t pte)	{ return pte_val(pte) & _PAGE_ACCESSED; }
-static inline int pte_file(pte_t pte)	{ return pte_val(pte) & _PAGE_FILE; }
 
 static inline pte_t pte_wrprotect(pte_t pte)
 {
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
