Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 448036B0038
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 07:08:13 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id gl10so7594961lab.26
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 04:08:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p12si19296726laa.133.2014.08.12.04.08.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 04:08:11 -0700 (PDT)
Date: Tue, 12 Aug 2014 12:08:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: Remove misleading ARCH_USES_NUMA_PROT_NONE
Message-ID: <20140812110806.GA17467@suse.de>
References: <53DD5F20.8010507@oracle.com>
 <alpine.LSU.2.11.1408040418500.3406@eggly.anvils>
 <20140805144439.GW10819@suse.de>
 <alpine.LSU.2.11.1408051649330.6591@eggly.anvils>
 <53E17F06.30401@oracle.com>
 <53E989FB.5000904@oracle.com>
 <20140812104758.GE7970@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140812104758.GE7970@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

ARCH_USES_NUMA_PROT_NONE was defined for architectures that implemented
_PAGE_NUMA using _PROT_NONE. This saved using an additional PTE bit and
relied on the fact that PROT_NONE vmas were skipped by the NUMA hinting
fault scanner. This was found to be conceptually confusing with a lot of
implicit assumptions and it was asked that an alternative be found.

Commit c46a7c81 "x86: define _PAGE_NUMA by reusing software bits on the
PMD and PTE levels" redefined _PAGE_NUMA on x86 to be one of the swap
PTE bits and shrunk the maximum possible swap size but it did not go far
enough. There are no architectures that reuse _PROT_NONE as _PROT_NUMA
but the relics still exist.

This patch removes ARCH_USES_NUMA_PROT_NONE and removes some unnecessary
duplication in powerpc vs the generic implementation by defining the types
the core NUMA helpers expected to exist from x86 with their ppc64 equivalent.
This necessitated that a PTE bit mask be created that identified the bits
that distinguish present from NUMA pte entries but it is expected this
will only differ between arches based on _PAGE_PROTNONE. The naming for
the generic helpers was taken from x86 originally but ppc64 has types that
are equivalent for the purposes of the helper so they are mapped instead
of duplicating code.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/powerpc/include/asm/pgtable.h    | 57 ++++++++---------------------------
 arch/powerpc/include/asm/pte-common.h |  5 +++
 arch/x86/Kconfig                      |  1 -
 arch/x86/include/asm/pgtable_types.h  | 14 +++++++++
 include/asm-generic/pgtable.h         | 27 ++++++-----------
 init/Kconfig                          | 11 -------
 6 files changed, 40 insertions(+), 75 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index d98c1ec..f60d4ea 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -38,10 +38,9 @@ static inline int pte_none(pte_t pte)		{ return (pte_val(pte) & ~_PTE_NONE_MASK)
 static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & PAGE_PROT_BITS); }
 
 #ifdef CONFIG_NUMA_BALANCING
-
 static inline int pte_present(pte_t pte)
 {
-	return pte_val(pte) & (_PAGE_PRESENT | _PAGE_NUMA);
+	return pte_val(pte) & _PAGE_NUMA_MASK;
 }
 
 #define pte_present_nonuma pte_present_nonuma
@@ -50,37 +49,6 @@ static inline int pte_present_nonuma(pte_t pte)
 	return pte_val(pte) & (_PAGE_PRESENT);
 }
 
-#define pte_numa pte_numa
-static inline int pte_numa(pte_t pte)
-{
-	return (pte_val(pte) &
-		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
-}
-
-#define pte_mknonnuma pte_mknonnuma
-static inline pte_t pte_mknonnuma(pte_t pte)
-{
-	pte_val(pte) &= ~_PAGE_NUMA;
-	pte_val(pte) |=  _PAGE_PRESENT | _PAGE_ACCESSED;
-	return pte;
-}
-
-#define pte_mknuma pte_mknuma
-static inline pte_t pte_mknuma(pte_t pte)
-{
-	/*
-	 * We should not set _PAGE_NUMA on non present ptes. Also clear the
-	 * present bit so that hash_page will return 1 and we collect this
-	 * as numa fault.
-	 */
-	if (pte_present(pte)) {
-		pte_val(pte) |= _PAGE_NUMA;
-		pte_val(pte) &= ~_PAGE_PRESENT;
-	} else
-		VM_BUG_ON(1);
-	return pte;
-}
-
 #define ptep_set_numa ptep_set_numa
 static inline void ptep_set_numa(struct mm_struct *mm, unsigned long addr,
 				 pte_t *ptep)
@@ -92,12 +60,6 @@ static inline void ptep_set_numa(struct mm_struct *mm, unsigned long addr,
 	return;
 }
 
-#define pmd_numa pmd_numa
-static inline int pmd_numa(pmd_t pmd)
-{
-	return pte_numa(pmd_pte(pmd));
-}
-
 #define pmdp_set_numa pmdp_set_numa
 static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
 				 pmd_t *pmdp)
@@ -109,16 +71,21 @@ static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
 	return;
 }
 
-#define pmd_mknonnuma pmd_mknonnuma
-static inline pmd_t pmd_mknonnuma(pmd_t pmd)
+/*
+ * Generic NUMA pte helpers expect pteval_t and pmdval_t types to exist
+ * which was inherited from x86. For the purposes of powerpc pte_basic_t and
+ * pmd_t are equivalent
+ */
+#define pteval_t pte_basic_t
+#define pmdval_t pmd_t
+static inline pteval_t ptenuma_flags(pte_t pte)
 {
-	return pte_pmd(pte_mknonnuma(pmd_pte(pmd)));
+	return pte_val(pte) & _PAGE_NUMA_MASK;
 }
 
-#define pmd_mknuma pmd_mknuma
-static inline pmd_t pmd_mknuma(pmd_t pmd)
+static inline pmdval_t pmdnuma_flags(pmd_t pmd)
 {
-	return pte_pmd(pte_mknuma(pmd_pte(pmd)));
+	return pmd_val(pmd) & _PAGE_NUMA_MASK;
 }
 
 # else
diff --git a/arch/powerpc/include/asm/pte-common.h b/arch/powerpc/include/asm/pte-common.h
index 8d1569c..e040c35 100644
--- a/arch/powerpc/include/asm/pte-common.h
+++ b/arch/powerpc/include/asm/pte-common.h
@@ -98,6 +98,11 @@ extern unsigned long bad_call_to_PMD_PAGE_SIZE(void);
 			 _PAGE_USER | _PAGE_ACCESSED | \
 			 _PAGE_RW | _PAGE_HWWRITE | _PAGE_DIRTY | _PAGE_EXEC)
 
+#ifdef CONFIG_NUMA_BALANCING
+/* Mask of bits that distinguish present and numa ptes */
+#define _PAGE_NUMA_MASK (_PAGE_NUMA|_PAGE_PRESENT)
+#endif
+
 /*
  * We define 2 sets of base prot bits, one for basic pages (ie,
  * cacheable kernel and user pages) and one for non cacheable
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index d24887b..0a3f32b 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -28,7 +28,6 @@ config X86
 	select HAVE_UNSTABLE_SCHED_CLOCK
 	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64
 	select ARCH_SUPPORTS_INT128 if X86_64
-	select ARCH_WANTS_PROT_NUMA_PROT_NONE
 	select HAVE_IDE
 	select HAVE_OPROFILE
 	select HAVE_PCSPKR_PLATFORM
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index f216963..0f9724c 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -325,6 +325,20 @@ static inline pteval_t pte_flags(pte_t pte)
 	return native_pte_val(pte) & PTE_FLAGS_MASK;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+/* Set of bits that distinguishes present, prot_none and numa ptes */
+#define _PAGE_NUMA_MASK (_PAGE_NUMA|_PAGE_PROTNONE|_PAGE_PRESENT)
+static inline pteval_t ptenuma_flags(pte_t pte)
+{
+	return pte_flags(pte) & _PAGE_NUMA_MASK;
+}
+
+static inline pmdval_t pmdnuma_flags(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_NUMA_MASK;
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 #define pgprot_val(x)	((x).pgprot)
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 53b2acc..281870f 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -660,11 +660,12 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 }
 
 #ifdef CONFIG_NUMA_BALANCING
-#ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
 /*
- * _PAGE_NUMA works identical to _PAGE_PROTNONE (it's actually the
- * same bit too). It's set only when _PAGE_PRESET is not set and it's
- * never set if _PAGE_PRESENT is set.
+ * _PAGE_NUMA distinguishes between an unmapped page table entry, an entry that
+ * is protected for PROT_NONE and a NUMA hinting fault entry. If the
+ * architecture defines __PAGE_PROTNONE then it should take that into account
+ * but those that do not can rely on the fact that the NUMA hinting scanner
+ * skips inaccessible VMAs.
  *
  * pte/pmd_present() returns true if pte/pmd_numa returns true. Page
  * fault triggers on those regions if pte/pmd_numa returns true
@@ -673,16 +674,14 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 #ifndef pte_numa
 static inline int pte_numa(pte_t pte)
 {
-	return (pte_flags(pte) &
-		(_PAGE_NUMA|_PAGE_PROTNONE|_PAGE_PRESENT)) == _PAGE_NUMA;
+	return ptenuma_flags(pte) == _PAGE_NUMA;
 }
 #endif
 
 #ifndef pmd_numa
 static inline int pmd_numa(pmd_t pmd)
 {
-	return (pmd_flags(pmd) &
-		(_PAGE_NUMA|_PAGE_PROTNONE|_PAGE_PRESENT)) == _PAGE_NUMA;
+	return pmdnuma_flags(pmd) == _PAGE_NUMA;
 }
 #endif
 
@@ -722,6 +721,8 @@ static inline pte_t pte_mknuma(pte_t pte)
 {
 	pteval_t val = pte_val(pte);
 
+	VM_BUG_ON(!(val & _PAGE_PRESENT));
+
 	val &= ~_PAGE_PRESENT;
 	val |= _PAGE_NUMA;
 
@@ -765,16 +766,6 @@ static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
 }
 #endif
 #else
-extern int pte_numa(pte_t pte);
-extern int pmd_numa(pmd_t pmd);
-extern pte_t pte_mknonnuma(pte_t pte);
-extern pmd_t pmd_mknonnuma(pmd_t pmd);
-extern pte_t pte_mknuma(pte_t pte);
-extern pmd_t pmd_mknuma(pmd_t pmd);
-extern void ptep_set_numa(struct mm_struct *mm, unsigned long addr, pte_t *ptep);
-extern void pmdp_set_numa(struct mm_struct *mm, unsigned long addr, pmd_t *pmdp);
-#endif /* CONFIG_ARCH_USES_NUMA_PROT_NONE */
-#else
 static inline int pmd_numa(pmd_t pmd)
 {
 	return 0;
diff --git a/init/Kconfig b/init/Kconfig
index 9d76b99..60fa415 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -844,17 +844,6 @@ config ARCH_SUPPORTS_INT128
 config ARCH_WANT_NUMA_VARIABLE_LOCALITY
 	bool
 
-#
-# For architectures that are willing to define _PAGE_NUMA as _PAGE_PROTNONE
-config ARCH_WANTS_PROT_NUMA_PROT_NONE
-	bool
-
-config ARCH_USES_NUMA_PROT_NONE
-	bool
-	default y
-	depends on ARCH_WANTS_PROT_NUMA_PROT_NONE
-	depends on NUMA_BALANCING
-
 config NUMA_BALANCING_DEFAULT_ENABLED
 	bool "Automatically enable NUMA aware memory/task placement"
 	default y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
