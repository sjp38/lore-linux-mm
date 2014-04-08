Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4B05F6B009C
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 09:09:40 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so665772eek.31
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 06:09:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z42si2763570eel.32.2014.04.08.06.09.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 06:09:38 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/5] x86: Define _PAGE_NUMA by reusing software bits on the PMD and PTE levels
Date: Tue,  8 Apr 2014 14:09:27 +0100
Message-Id: <1396962570-18762-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1396962570-18762-1-git-send-email-mgorman@suse.de>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-X86 <x86@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

_PAGE_NUMA is currently an alias of _PROT_PROTNONE to trap NUMA hinting
faults. Care is taken such that _PAGE_NUMA is used only in situations where
the VMA flags distinguish between NUMA hinting faults and prot_none faults.
Conceptually this is difficult and it has caused problems.

Fundamentally, we only need the _PAGE_NUMA bit to tell the difference between
an entry that is really unmapped and a page that is protected for NUMA
hinting faults as if the PTE is not present then a fault will be trapped.

Currently one of the software bits is used for identifying IO mappings and
by Xen to track if it's a Xen PTE or a machine PFN.  This patch reuses the
software bit for IOMAP for NUMA hinting faults with the expectation that
the bit is not used for userspace addresses. Xen and NUMA balancing are
now mutually exclusive in Kconfig.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/Kconfig                     |  2 +-
 arch/x86/include/asm/pgtable.h       |  5 ++++
 arch/x86/include/asm/pgtable_types.h | 54 +++++++++++++++++-------------------
 3 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 084b1c1..4fab25a 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -26,7 +26,7 @@ config X86
 	select ARCH_MIGHT_HAVE_PC_SERIO
 	select HAVE_AOUT if X86_32
 	select HAVE_UNSTABLE_SCHED_CLOCK
-	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64
+	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64 && !XEN
 	select ARCH_SUPPORTS_INT128 if X86_64
 	select ARCH_WANTS_PROT_NUMA_PROT_NONE
 	select HAVE_IDE
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index bbc8b12..076daff 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -447,6 +447,8 @@ static inline int pte_same(pte_t a, pte_t b)
 
 static inline int pte_present(pte_t a)
 {
+	VM_BUG_ON((pte_flags(a) & (_PAGE_NUMA | _PAGE_GLOBAL)) ==
+			(_PAGE_NUMA | _PAGE_GLOBAL));
 	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE |
 			       _PAGE_NUMA);
 }
@@ -471,6 +473,9 @@ static inline int pte_hidden(pte_t pte)
 
 static inline int pmd_present(pmd_t pmd)
 {
+	VM_BUG_ON((pmd_flags(pmd) & (_PAGE_NUMA | _PAGE_GLOBAL)) ==
+			(_PAGE_NUMA | _PAGE_GLOBAL));
+
 	/*
 	 * Checking for _PAGE_PSE is needed too because
 	 * split_huge_page will temporarily clear the present bit (but
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 1aa9ccd..49b3e15 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -16,13 +16,17 @@
 #define _PAGE_BIT_PSE		7	/* 4 MB (or 2MB) page */
 #define _PAGE_BIT_PAT		7	/* on 4KB pages */
 #define _PAGE_BIT_GLOBAL	8	/* Global TLB entry PPro+ */
-#define _PAGE_BIT_UNUSED1	9	/* available for programmer */
-#define _PAGE_BIT_IOMAP		10	/* flag used to indicate IO mapping */
-#define _PAGE_BIT_HIDDEN	11	/* hidden by kmemcheck */
+#define _PAGE_BIT_SOFTW1	9	/* available for programmer */
+#define _PAGE_BIT_SOFTW2	10	/* " */
+#define _PAGE_BIT_SOFTW3	11	/* " */
 #define _PAGE_BIT_PAT_LARGE	12	/* On 2MB or 1GB pages */
-#define _PAGE_BIT_SPECIAL	_PAGE_BIT_UNUSED1
-#define _PAGE_BIT_CPA_TEST	_PAGE_BIT_UNUSED1
-#define _PAGE_BIT_SPLITTING	_PAGE_BIT_UNUSED1 /* only valid on a PSE pmd */
+#define _PAGE_BIT_SPECIAL	_PAGE_BIT_SOFTW1
+#define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW1
+#define _PAGE_BIT_SPLITTING	_PAGE_BIT_SOFTW1 /* only valid on a PSE pmd */
+#define _PAGE_BIT_IOMAP		_PAGE_BIT_SOFTW2 /* flag used to indicate IO mapping */
+#define _PAGE_BIT_NUMA		_PAGE_BIT_SOFTW2 /* for NUMA balancing hinting */
+#define _PAGE_BIT_HIDDEN	_PAGE_BIT_SOFTW3 /* hidden by kmemcheck */
+#define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
 #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
 
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
@@ -40,7 +44,6 @@
 #define _PAGE_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_DIRTY)
 #define _PAGE_PSE	(_AT(pteval_t, 1) << _PAGE_BIT_PSE)
 #define _PAGE_GLOBAL	(_AT(pteval_t, 1) << _PAGE_BIT_GLOBAL)
-#define _PAGE_UNUSED1	(_AT(pteval_t, 1) << _PAGE_BIT_UNUSED1)
 #define _PAGE_IOMAP	(_AT(pteval_t, 1) << _PAGE_BIT_IOMAP)
 #define _PAGE_PAT	(_AT(pteval_t, 1) << _PAGE_BIT_PAT)
 #define _PAGE_PAT_LARGE (_AT(pteval_t, 1) << _PAGE_BIT_PAT_LARGE)
@@ -61,8 +64,6 @@
  * they do not conflict with each other.
  */
 
-#define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_HIDDEN
-
 #ifdef CONFIG_MEM_SOFT_DIRTY
 #define _PAGE_SOFT_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_SOFT_DIRTY)
 #else
@@ -70,6 +71,21 @@
 #endif
 
 /*
+ * _PAGE_NUMA distinguishes between a numa hinting minor fault and a page
+ * that is not present. The hinting fault gathers numa placement statistics
+ * (see pte_numa()). The bit is always zero when the PTE is not present.
+ *
+ * The bit picked must be always zero when the pmd is present and not
+ * present, so that we don't lose information when we set it while
+ * atomically clearing the present bit.
+ */
+#ifdef CONFIG_NUMA_BALANCING
+#define _PAGE_NUMA	(_AT(pteval_t, 1) << _PAGE_BIT_NUMA)
+#else
+#define _PAGE_NUMA	(_AT(pteval_t, 0))
+#endif
+
+/*
  * Tracking soft dirty bit when a page goes to a swap is tricky.
  * We need a bit which can be stored in pte _and_ not conflict
  * with swap entry format. On x86 bits 6 and 7 are *not* involved
@@ -94,26 +110,6 @@
 #define _PAGE_FILE	(_AT(pteval_t, 1) << _PAGE_BIT_FILE)
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
-/*
- * _PAGE_NUMA indicates that this page will trigger a numa hinting
- * minor page fault to gather numa placement statistics (see
- * pte_numa()). The bit picked (8) is within the range between
- * _PAGE_FILE (6) and _PAGE_PROTNONE (8) bits. Therefore, it doesn't
- * require changes to the swp entry format because that bit is always
- * zero when the pte is not present.
- *
- * The bit picked must be always zero when the pmd is present and not
- * present, so that we don't lose information when we set it while
- * atomically clearing the present bit.
- *
- * Because we shared the same bit (8) with _PAGE_PROTNONE this can be
- * interpreted as _PAGE_NUMA only in places that _PAGE_PROTNONE
- * couldn't reach, like handle_mm_fault() (see access_error in
- * arch/x86/mm/fault.c, the vma protection must not be PROT_NONE for
- * handle_mm_fault() to be invoked).
- */
-#define _PAGE_NUMA	_PAGE_PROTNONE
-
 #define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
 			 _PAGE_ACCESSED | _PAGE_DIRTY)
 #define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
