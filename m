Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id A15FC6B0037
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 11:10:51 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w61so6943070wes.29
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 08:10:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 12si6338456wjw.205.2014.04.07.08.10.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 08:10:49 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address bits PMD and PTE levels
Date: Mon,  7 Apr 2014 16:10:42 +0100
Message-Id: <1396883443-11696-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1396883443-11696-1-git-send-email-mgorman@suse.de>
References: <1396883443-11696-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

_PAGE_NUMA is currently an alias of _PROT_PROTNONE to trap NUMA hinting
faults. As the bit is shared care is taken that _PAGE_NUMA is only used in
places where _PAGE_PROTNONE could not reach but this still causes problems
on Xen and conceptually difficult.

Fundamentally, we only need the _PAGE_NUMA bit to tell the difference
between an entry that is really unmapped and a page that is protected
for NUMA hinting faults. Due to physical address limitations bits 52:62
are free so we can currently use them. As the present bit is cleared when
making a NUMA PTE, the hinting faults will still be trapped. It means that
32-bit NUMA cannot use automatic NUMA balancing but it is improbable that
anyone cares about that configuration.

In the future there will be a problem when the physical address space
expands because the bits may no longer be free. There is also the risk that
the hardware people are planning to use these bits for some other purpose.
When/if this happens then an option would be to use bit 11 and disable
kmemcheck if automatic NUMA balancing is enabled assuming bit 11 has not
been used for something else in the meantime.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/include/asm/pgtable.h       |  8 +++----
 arch/x86/include/asm/pgtable_types.h | 44 ++++++++++++++++++++----------------
 2 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index bbc8b12..58fa7d1 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -447,8 +447,8 @@ static inline int pte_same(pte_t a, pte_t b)
 
 static inline int pte_present(pte_t a)
 {
-	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE |
-			       _PAGE_NUMA);
+	return (pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE |
+			       _PAGE_NUMA)) != 0;
 }
 
 #define pte_accessible pte_accessible
@@ -477,8 +477,8 @@ static inline int pmd_present(pmd_t pmd)
 	 * the _PAGE_PSE flag will remain set at all times while the
 	 * _PAGE_PRESENT bit is clear).
 	 */
-	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE |
-				 _PAGE_NUMA);
+	return (pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE |
+				 _PAGE_NUMA)) != 0;
 }
 
 static inline int pmd_none(pmd_t pmd)
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 1aa9ccd..f3eafd2 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -25,6 +25,15 @@
 #define _PAGE_BIT_SPLITTING	_PAGE_BIT_UNUSED1 /* only valid on a PSE pmd */
 #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
 
+/*
+ * Software bits ignored by the page table walker
+ * At the time of writing, different levels have bits that are ignored. Due
+ * to physical address limitations, bits 52:62 should be ignored for the PMD
+ * and PTE levels and are available for use by software. Be aware that this
+ * may change if the physical address space expands.
+ */
+#define _PAGE_BIT_NUMA		62
+
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
 #define _PAGE_BIT_PROTNONE	_PAGE_BIT_GLOBAL
@@ -56,6 +65,21 @@
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
  * The same hidden bit is used by kmemcheck, but since kmemcheck
  * works on kernel pages while soft-dirty engine on user space,
  * they do not conflict with each other.
@@ -94,26 +118,6 @@
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
