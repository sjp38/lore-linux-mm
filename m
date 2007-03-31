From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH 07/11] RFP prot support: uml, i386, x64 bits
Date: Sat, 31 Mar 2007 02:35:46 +0200
Message-ID: <20070331003546.3415.39016.stgit@americanbeauty.home.lan>
In-Reply-To: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
References: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>,
	Ingo Molnar <mingo@elte.hu>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

Various boilerplate stuff.

Update pte encoding macros for UML, i386 and x86-64.

*) remap_file_pages protection support: improvement for UML bits

Recover one bit by additionally using _PAGE_NEWPROT. Since I wasn't sure this
would work, I've split this out, but it has worked well. We rely on the fact
that pte_newprot always checks first if the PTE is marked present. This is
joined because it worked well during the unit testing I performed, beyond
making sense.

========
RFP: Avoid using _PAGE_PROTNONE

For i386, x86_64, uml:

To encode a pte_file PROTNONE pte, since _PAGE_PROTNONE makes pte_present be
set, and since such a pte actually still references a page, we need to use
another bit for our purposes. Implement this.

* Add _PAGE_FILE_PROTNONE, the bit describe above.
* Add to each arch pgprot_access_bits() to extract the value of protection bits
  (i.e._PAGE_RW and _PAGE_PROTNONE) and encode them (translate _PAGE_PROTNONE to
  _PAGE_FILE_PROTNONE), and use it in pgoff_prot_to_pte().
* Modify pte_to_pgprot() to do the inverse translation.
* Modify pte_to_pgoff() and pgoff_prot_to_pte() to leave alone the newly used
  bit (for 32-bit PTEs).
* Join for UML and x86 pte_to_pgprot() for 2level and 3level page tables, since
  they were identical.
* Decrease by 1 PTE_FILE_MAX_BITS where appropriate.
* Also replace in bit operations + with | where appropriate.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 include/asm-i386/pgtable-2level.h |   11 ++++++-----
 include/asm-i386/pgtable-3level.h |    7 +++++--
 include/asm-i386/pgtable.h        |   24 ++++++++++++++++++++++++
 include/asm-um/pgtable-2level.h   |   16 ++++++++++++----
 include/asm-um/pgtable-3level.h   |   21 ++++++++++++++-------
 include/asm-um/pgtable.h          |   21 +++++++++++++++++++++
 include/asm-x86_64/pgtable.h      |   29 +++++++++++++++++++++++++++--
 7 files changed, 109 insertions(+), 20 deletions(-)

diff --git a/include/asm-i386/pgtable-2level.h b/include/asm-i386/pgtable-2level.h
index 38c3fcc..31f1d3b 100644
--- a/include/asm-i386/pgtable-2level.h
+++ b/include/asm-i386/pgtable-2level.h
@@ -48,16 +48,17 @@ static inline int pte_exec_kernel(pte_t pte)
 }
 
 /*
- * Bits 0, 6 and 7 are taken, split up the 29 bits of offset
+ * Bits 0, 1, 6, 7 and 8 are taken, split up the 27 bits of offset
  * into this range:
  */
-#define PTE_FILE_MAX_BITS	29
+#define PTE_FILE_MAX_BITS	27
 
 #define pte_to_pgoff(pte) \
-	((((pte).pte_low >> 1) & 0x1f ) + (((pte).pte_low >> 8) << 5 ))
+	((((pte).pte_low >> 2) & 0xf ) | (((pte).pte_low >> 9) << 4 ))
 
-#define pgoff_to_pte(off) \
-	((pte_t) { (((off) & 0x1f) << 1) + (((off) >> 5) << 8) + _PAGE_FILE })
+#define pgoff_prot_to_pte(off, prot) \
+	((pte_t) { (((off) & 0xf) << 2) | (((off) >> 4) << 9) | \
+	 pgprot_access_bits(prot) | _PAGE_FILE })
 
 /* Encode and de-code a swap entry */
 #define __swp_type(x)			(((x).val >> 1) & 0x1f)
diff --git a/include/asm-i386/pgtable-3level.h b/include/asm-i386/pgtable-3level.h
index 7a2318f..aa4ba07 100644
--- a/include/asm-i386/pgtable-3level.h
+++ b/include/asm-i386/pgtable-3level.h
@@ -171,11 +171,14 @@ static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
 }
 
 /*
- * Bits 0, 6 and 7 are taken in the low part of the pte,
+ * Bits 0, 1, 6, 7 and 8 are taken in the low part of the pte,
  * put the 32 bits of offset into the high part.
  */
 #define pte_to_pgoff(pte) ((pte).pte_high)
-#define pgoff_to_pte(off) ((pte_t) { _PAGE_FILE, (off) })
+
+#define pgoff_prot_to_pte(off, prot) \
+	((pte_t) { _PAGE_FILE | pgprot_access_bits(prot), (off) })
+
 #define PTE_FILE_MAX_BITS       32
 
 /* Encode and de-code a swap entry */
diff --git a/include/asm-i386/pgtable.h b/include/asm-i386/pgtable.h
index d36b241..ed10cf4 100644
--- a/include/asm-i386/pgtable.h
+++ b/include/asm-i386/pgtable.h
@@ -14,6 +14,7 @@
 #ifndef __ASSEMBLY__
 #include <asm/processor.h>
 #include <asm/fixmap.h>
+#include <linux/bitops.h>
 #include <linux/threads.h>
 #include <asm/paravirt.h>
 
@@ -100,8 +101,10 @@ void paging_init(void);
 #define _PAGE_BIT_PCD		4
 #define _PAGE_BIT_ACCESSED	5
 #define _PAGE_BIT_DIRTY		6
+#define _PAGE_BIT_PROTNONE	6
 #define _PAGE_BIT_PSE		7	/* 4 MB (or 2MB) page, Pentium+, if present.. */
 #define _PAGE_BIT_GLOBAL	8	/* Global TLB entry PPro+ */
+#define _PAGE_BIT_FILE_PROTNONE 8
 #define _PAGE_BIT_UNUSED1	9	/* available for programmer */
 #define _PAGE_BIT_UNUSED2	10
 #define _PAGE_BIT_UNUSED3	11
@@ -124,6 +127,27 @@ void paging_init(void);
 #define _PAGE_FILE	0x040	/* nonlinear file mapping, saved PTE; unset:swap */
 #define _PAGE_PROTNONE	0x080	/* if the user mapped it with PROT_NONE;
 				   pte_present gives true */
+#define _PAGE_FILE_PROTNONE	0x100	/* indicate that the page is remapped
+					   with PROT_NONE - this is different
+					   from _PAGE_PROTNONE as no page is
+					   held here, so pte_present() is false
+					   */
+
+/* Extracts _PAGE_RW and _PAGE_PROTNONE and replace the latter with
+ * _PAGE_FILE_PROTNONE. */
+#define pgprot_access_bits(prot) \
+	((pgprot_val(prot) & _PAGE_RW) | \
+	 bitmask_trans(pgprot_val(prot), _PAGE_PROTNONE, _PAGE_FILE_PROTNONE))
+
+#define __HAVE_ARCH_PTE_TO_PGPROT
+#define pte_to_pgprot(pte) \
+	__pgprot(((pte).pte_low & (_PAGE_RW|_PAGE_PROTNONE)))
+
+#define pte_file_to_pgprot(pte) \
+	__pgprot(((pte).pte_low & _PAGE_RW) | _PAGE_ACCESSED | \
+		(((pte).pte_low & _PAGE_FILE_PROTNONE) ? _PAGE_PROTNONE : \
+			(_PAGE_USER | _PAGE_PRESENT)))
+
 #ifdef CONFIG_X86_PAE
 #define _PAGE_NX	(1ULL<<_PAGE_BIT_NX)
 #else
diff --git a/include/asm-um/pgtable-2level.h b/include/asm-um/pgtable-2level.h
index 172a75f..23e1750 100644
--- a/include/asm-um/pgtable-2level.h
+++ b/include/asm-um/pgtable-2level.h
@@ -45,12 +45,20 @@ static inline void pgd_mkuptodate(pgd_t pgd)	{ }
 	((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
 
 /*
- * Bits 0 through 4 are taken
+ * Bits 0, 1, 3 to 5 and 8 are taken, split up the 26 bits of offset
+ * into this range:
  */
-#define PTE_FILE_MAX_BITS	27
+#define PTE_FILE_MAX_BITS	26
 
-#define pte_to_pgoff(pte) (pte_val(pte) >> 5)
+#define pte_to_pgoff(pte) (((pte_val(pte) >> 2) & 0x1) | \
+		(((pte_val(pte) >> 6) & 0x3) << 1) | \
+		((pte_val(pte) >> 9) << 3))
 
-#define pgoff_to_pte(off) ((pte_t) { ((off) << 5) + _PAGE_FILE })
+#define pgoff_prot_to_pte(off, prot) \
+	__pte((((off) & 0x1) << 2) | ((((off) & 0x7) >> 1) << 6) | \
+	((off >> 3) << 9) | pgprot_access_bits(prot) | _PAGE_FILE)
+
+/* For pte_file_to_pgprot definition only */
+#define __pte_low(pte) pte_val(pte)
 
 #endif
diff --git a/include/asm-um/pgtable-3level.h b/include/asm-um/pgtable-3level.h
index ca0c2a9..0444dc4 100644
--- a/include/asm-um/pgtable-3level.h
+++ b/include/asm-um/pgtable-3level.h
@@ -102,25 +102,32 @@ static inline pmd_t pfn_pmd(pfn_t page_nr, pgprot_t pgprot)
 }
 
 /*
- * Bits 0 through 3 are taken in the low part of the pte,
+ * Bits 0 through 5 are taken in the low part of the pte,
  * put the 32 bits of offset into the high part.
  */
 #define PTE_FILE_MAX_BITS	32
 
-#ifdef CONFIG_64BIT
 
-#define pte_to_pgoff(p) ((p).pte >> 32)
+#ifdef CONFIG_64BIT
 
-#define pgoff_to_pte(off) ((pte_t) { ((off) << 32) | _PAGE_FILE })
+/* For pte_file_to_pgprot definition only */
+#define __pte_low(pte) pte_val(pte)
+#define __pte_high(pte) (pte_val(pte) >> 32)
+#define __build_pte(low, high) ((pte_t) { (high) << 32 | (low)})
 
 #else
 
-#define pte_to_pgoff(pte) ((pte).pte_high)
-
-#define pgoff_to_pte(off) ((pte_t) { _PAGE_FILE, (off) })
+/* Don't use pte_val below, useless to join the two halves */
+#define __pte_low(pte) ((pte).pte_low)
+#define __pte_high(pte) ((pte).pte_high)
+#define __build_pte(low, high) ((pte_t) {(low), (high)})
 
 #endif
 
+#define pte_to_pgoff(pte) __pte_high(pte)
+#define pgoff_prot_to_pte(off, prot) \
+	__build_pte(_PAGE_FILE | pgprot_access_bits(prot), (off))
+
 #endif
 
 /*
diff --git a/include/asm-um/pgtable.h b/include/asm-um/pgtable.h
index 1b1090a..9ff1ca7 100644
--- a/include/asm-um/pgtable.h
+++ b/include/asm-um/pgtable.h
@@ -10,6 +10,7 @@
 
 #include "linux/sched.h"
 #include "linux/linkage.h"
+#include "linux/bitops.h"
 #include "asm/processor.h"
 #include "asm/page.h"
 #include "asm/fixmap.h"
@@ -25,6 +26,17 @@
 #define _PAGE_FILE	0x008	/* nonlinear file mapping, saved PTE; unset:swap */
 #define _PAGE_PROTNONE	0x010	/* if the user mapped it with PROT_NONE;
 				   pte_present gives true */
+#define _PAGE_FILE_PROTNONE	0x100	/* indicate that the page is remapped
+					   with PROT_NONE - this is different
+					   from _PAGE_PROTNONE as no page is
+					   held here, so pte_present() is false
+					   */
+
+/* Extracts _PAGE_RW and _PAGE_PROTNONE and replace the latter with
+ * _PAGE_FILE_PROTNONE. */
+#define pgprot_access_bits(prot) \
+	((pgprot_val(prot) & _PAGE_RW) | \
+	 bitmask_trans(pgprot_val(prot), _PAGE_PROTNONE, _PAGE_FILE_PROTNONE))
 
 #ifdef CONFIG_3_LEVEL_PGTABLES
 #include "asm/pgtable-3level.h"
@@ -32,6 +44,14 @@
 #include "asm/pgtable-2level.h"
 #endif
 
+#define pte_to_pgprot(pte) \
+	__pgprot((__pte_low(pte) & (_PAGE_RW|_PAGE_PROTNONE)))
+
+#define pte_file_to_pgprot(pte) \
+	__pgprot((__pte_low(pte) & _PAGE_RW) | _PAGE_ACCESSED | \
+		((__pte_low(pte) & _PAGE_FILE_PROTNONE) ? _PAGE_PROTNONE : \
+			(_PAGE_USER | _PAGE_PRESENT)))
+
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 
 extern void *um_virt_to_phys(struct task_struct *task, unsigned long virt,
@@ -404,6 +424,7 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 
 #define kern_addr_valid(addr) (1)
 
+#define __HAVE_ARCH_PTE_TO_PGPROT
 #include <asm-generic/pgtable.h>
 
 #include <asm-generic/pgtable-nopud.h>
diff --git a/include/asm-x86_64/pgtable.h b/include/asm-x86_64/pgtable.h
index 599993f..9dad0dd 100644
--- a/include/asm-x86_64/pgtable.h
+++ b/include/asm-x86_64/pgtable.h
@@ -9,7 +9,7 @@
  * the x86-64 page table tree.
  */
 #include <asm/processor.h>
-#include <asm/bitops.h>
+#include <linux/bitops.h>
 #include <linux/threads.h>
 #include <asm/pda.h>
 
@@ -150,6 +150,7 @@ static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm, unsigned long
 #define _PAGE_BIT_DIRTY		6
 #define _PAGE_BIT_PSE		7	/* 4 MB (or 2MB) page */
 #define _PAGE_BIT_GLOBAL	8	/* Global TLB entry PPro+ */
+#define _PAGE_BIT_FILE_PROTNONE 8
 #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
 
 #define _PAGE_PRESENT	0x001
@@ -164,6 +165,12 @@ static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm, unsigned long
 #define _PAGE_GLOBAL	0x100	/* Global TLB entry */
 
 #define _PAGE_PROTNONE	0x080	/* If not present */
+#define _PAGE_FILE_PROTNONE	0x100	/* indicate that the page is remapped
+					   with PROT_NONE - this is different
+					   from _PAGE_PROTNONE as no page is
+					   held here, so pte_present() is false
+					   */
+
 #define _PAGE_NX        (_AC(1,UL)<<_PAGE_BIT_NX)
 
 #define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER | _PAGE_ACCESSED | _PAGE_DIRTY)
@@ -357,9 +364,26 @@ static inline int pmd_large(pmd_t pte) {
 #define pmd_pfn(x)  ((pmd_val(x) & __PHYSICAL_MASK) >> PAGE_SHIFT)
 
 #define pte_to_pgoff(pte) ((pte_val(pte) & PHYSICAL_PAGE_MASK) >> PAGE_SHIFT)
-#define pgoff_to_pte(off) ((pte_t) { ((off) << PAGE_SHIFT) | _PAGE_FILE })
 #define PTE_FILE_MAX_BITS __PHYSICAL_MASK_SHIFT
 
+#define pte_to_pgprot(pte) \
+	__pgprot((pte_val(pte) & (_PAGE_RW|_PAGE_PROTNONE)))
+
+#define pte_file_to_pgprot(pte) \
+	__pgprot((pte_val(pte) & _PAGE_RW) | _PAGE_ACCESSED | \
+		((pte_val(pte) & _PAGE_FILE_PROTNONE) ? _PAGE_PROTNONE : \
+			(_PAGE_USER | _PAGE_PRESENT)))
+
+/* Extracts _PAGE_RW and _PAGE_PROTNONE and replace the latter with
+ * _PAGE_FILE_PROTNONE. */
+#define pgprot_access_bits(prot) \
+	((pgprot_val(prot) & _PAGE_RW) | \
+	 bitmask_trans(pgprot_val(prot), _PAGE_PROTNONE, _PAGE_FILE_PROTNONE))
+
+#define pgoff_prot_to_pte(off, prot) \
+	((pte_t) { _PAGE_FILE | pgprot_access_bits(prot) | ((off) << PAGE_SHIFT) })
+
+
 /* PTE - Level 1 access. */
 
 /* page, protection -> pte */
@@ -441,6 +465,7 @@ extern int kern_addr_valid(unsigned long addr);
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTE_SAME
+#define __HAVE_ARCH_PTE_TO_PGPROT
 #include <asm-generic/pgtable.h>
 #endif /* !__ASSEMBLY__ */
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
