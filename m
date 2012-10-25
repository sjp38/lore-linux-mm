Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id BF05E6B0073
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:09:02 -0400 (EDT)
Message-Id: <20121025124832.770994193@chello.nl>
Date: Thu, 25 Oct 2012 14:16:21 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/31] x86/mm: Introduce pte_accessible()
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0004-x86-mm-Introduce-pte_accessible.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>

From: Rik van Riel <riel@redhat.com>

We need pte_present to return true for _PAGE_PROTNONE pages, to indicate that
the pte is associated with a page.

However, for TLB flushing purposes, we would like to know whether the pte
points to an actually accessible page.  This allows us to skip remote TLB
flushes for pages that are not actually accessible.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/include/asm/pgtable.h |    6 ++++++
 include/asm-generic/pgtable.h  |    4 ++++
 2 files changed, 10 insertions(+)

Index: tip/arch/x86/include/asm/pgtable.h
===================================================================
--- tip.orig/arch/x86/include/asm/pgtable.h
+++ tip/arch/x86/include/asm/pgtable.h
@@ -408,6 +408,12 @@ static inline int pte_present(pte_t a)
 	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
 }
 
+#define __HAVE_ARCH_PTE_ACCESSIBLE
+static inline int pte_accessible(pte_t a)
+{
+	return pte_flags(a) & _PAGE_PRESENT;
+}
+
 static inline int pte_hidden(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_HIDDEN;
Index: tip/include/asm-generic/pgtable.h
===================================================================
--- tip.orig/include/asm-generic/pgtable.h
+++ tip/include/asm-generic/pgtable.h
@@ -219,6 +219,10 @@ static inline int pmd_same(pmd_t pmd_a,
 #define move_pte(pte, prot, old_addr, new_addr)	(pte)
 #endif
 
+#ifndef __HAVE_ARCH_PTE_ACCESSIBLE
+#define pte_accessible(pte)		pte_present(pte)
+#endif
+
 #ifndef flush_tlb_fix_spurious_fault
 #define flush_tlb_fix_spurious_fault(vma, address) flush_tlb_page(vma, address)
 #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
