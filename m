Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id D67316B0073
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 06:23:05 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/43] mm: numa: Make pte_numa() and pmd_numa() a generic implementation
Date: Fri, 16 Nov 2012 11:22:16 +0000
Message-Id: <1353064973-26082-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1353064973-26082-1-git-send-email-mgorman@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

It was pointed out by Ingo Molnar that the per-architecture definition of
the NUMA PTE helper functions means that each supporting architecture
will have to cut and paste it which is unfortunate. He suggested instead
that the helpers should be weak functions that can be overridden by the
architecture.

This patch moves the helpers to mm/pgtable-generic.c and makes them weak
functions. Architectures wishing to use this will still be required to
define _PAGE_NUMA and potentially update their p[te|md]_present and
pmd_bad helpers if they choose to make PAGE_NUMA similar to PROT_NONE.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/include/asm/pgtable.h |   56 +---------------------------------------
 include/asm-generic/pgtable.h  |   17 +++++-------
 mm/pgtable-generic.c           |   53 +++++++++++++++++++++++++++++++++++++
 3 files changed, 60 insertions(+), 66 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index e075d57..4a4c11c 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -425,61 +425,6 @@ static inline int pmd_present(pmd_t pmd)
 				 _PAGE_NUMA);
 }
 
-#ifdef CONFIG_BALANCE_NUMA
-/*
- * _PAGE_NUMA works identical to _PAGE_PROTNONE (it's actually the
- * same bit too). It's set only when _PAGE_PRESET is not set and it's
- * never set if _PAGE_PRESENT is set.
- *
- * pte/pmd_present() returns true if pte/pmd_numa returns true. Page
- * fault triggers on those regions if pte/pmd_numa returns true
- * (because _PAGE_PRESENT is not set).
- */
-static inline int pte_numa(pte_t pte)
-{
-	return (pte_flags(pte) &
-		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
-}
-
-static inline int pmd_numa(pmd_t pmd)
-{
-	return (pmd_flags(pmd) &
-		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
-}
-#endif
-
-/*
- * pte/pmd_mknuma sets the _PAGE_ACCESSED bitflag automatically
- * because they're called by the NUMA hinting minor page fault. If we
- * wouldn't set the _PAGE_ACCESSED bitflag here, the TLB miss handler
- * would be forced to set it later while filling the TLB after we
- * return to userland. That would trigger a second write to memory
- * that we optimize away by setting _PAGE_ACCESSED here.
- */
-static inline pte_t pte_mknonnuma(pte_t pte)
-{
-	pte = pte_clear_flags(pte, _PAGE_NUMA);
-	return pte_set_flags(pte, _PAGE_PRESENT|_PAGE_ACCESSED);
-}
-
-static inline pmd_t pmd_mknonnuma(pmd_t pmd)
-{
-	pmd = pmd_clear_flags(pmd, _PAGE_NUMA);
-	return pmd_set_flags(pmd, _PAGE_PRESENT|_PAGE_ACCESSED);
-}
-
-static inline pte_t pte_mknuma(pte_t pte)
-{
-	pte = pte_set_flags(pte, _PAGE_NUMA);
-	return pte_clear_flags(pte, _PAGE_PRESENT);
-}
-
-static inline pmd_t pmd_mknuma(pmd_t pmd)
-{
-	pmd = pmd_set_flags(pmd, _PAGE_NUMA);
-	return pmd_clear_flags(pmd, _PAGE_PRESENT);
-}
-
 static inline int pmd_none(pmd_t pmd)
 {
 	/* Only check low word on 32-bit platforms, since it might be
@@ -534,6 +479,7 @@ static inline pte_t *pte_offset_kernel(pmd_t *pmd, unsigned long address)
 	return (pte_t *)pmd_page_vaddr(*pmd) + pte_index(address);
 }
 
+extern int pmd_numa(pmd_t pmd);
 static inline int pmd_bad(pmd_t pmd)
 {
 #ifdef CONFIG_BALANCE_NUMA
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 896667e..da3e761 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -554,17 +554,12 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 #endif
 }
 
-#ifndef CONFIG_BALANCE_NUMA
-static inline int pte_numa(pte_t pte)
-{
-	return 0;
-}
-
-static inline int pmd_numa(pmd_t pmd)
-{
-	return 0;
-}
-#endif /* CONFIG_BALANCE_NUMA */
+extern int pte_numa(pte_t pte);
+extern int pmd_numa(pmd_t pmd);
+extern pte_t pte_mknonnuma(pte_t pte);
+extern pmd_t pmd_mknonnuma(pmd_t pmd);
+extern pte_t pte_mknuma(pte_t pte);
+extern pmd_t pmd_mknuma(pmd_t pmd);
 
 #endif /* CONFIG_MMU */
 
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index e642627..6b6507f 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -170,3 +170,56 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
+
+/*
+ * _PAGE_NUMA works identical to _PAGE_PROTNONE (it's actually the
+ * same bit too). It's set only when _PAGE_PRESET is not set and it's
+ * never set if _PAGE_PRESENT is set.
+ *
+ * pte/pmd_present() returns true if pte/pmd_numa returns true. Page
+ * fault triggers on those regions if pte/pmd_numa returns true
+ * (because _PAGE_PRESENT is not set).
+ */
+__weak int pte_numa(pte_t pte)
+{
+	return (pte_flags(pte) &
+		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
+}
+
+__weak int pmd_numa(pmd_t pmd)
+{
+	return (pmd_flags(pmd) &
+		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
+}
+
+/*
+ * pte/pmd_mknuma sets the _PAGE_ACCESSED bitflag automatically
+ * because they're called by the NUMA hinting minor page fault. If we
+ * wouldn't set the _PAGE_ACCESSED bitflag here, the TLB miss handler
+ * would be forced to set it later while filling the TLB after we
+ * return to userland. That would trigger a second write to memory
+ * that we optimize away by setting _PAGE_ACCESSED here.
+ */
+__weak pte_t pte_mknonnuma(pte_t pte)
+{
+	pte = pte_clear_flags(pte, _PAGE_NUMA);
+	return pte_set_flags(pte, _PAGE_PRESENT|_PAGE_ACCESSED);
+}
+
+__weak pmd_t pmd_mknonnuma(pmd_t pmd)
+{
+	pmd = pmd_clear_flags(pmd, _PAGE_NUMA);
+	return pmd_set_flags(pmd, _PAGE_PRESENT|_PAGE_ACCESSED);
+}
+
+__weak pte_t pte_mknuma(pte_t pte)
+{
+	pte = pte_set_flags(pte, _PAGE_NUMA);
+	return pte_clear_flags(pte, _PAGE_PRESENT);
+}
+
+__weak pmd_t pmd_mknuma(pmd_t pmd)
+{
+	pmd = pmd_set_flags(pmd, _PAGE_NUMA);
+	return pmd_clear_flags(pmd, _PAGE_PRESENT);
+}
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
