Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5TEDN9h1605692
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 14:13:23 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5TEDNKL2166974
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:13:23 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5TEDNaM016007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:13:23 +0200
Message-Id: <20070629141527.839906850@de.ibm.com>
References: <20070629135530.912094590@de.ibm.com>
Date: Fri, 29 Jun 2007 15:55:32 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 2/5] remove ptep_establish.
Content-Disposition: inline; filename=003-ptep-establish.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

The last user of ptep_establish in mm/ is long gone. Remove the
architecture primitive as well.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/asm-generic/pgtable.h |   19 -------------------
 include/asm-i386/pgtable.h    |   11 -----------
 include/asm-ia64/pgtable.h    |    6 ++++--
 3 files changed, 4 insertions(+), 32 deletions(-)

diff -urpN linux-2.6/include/asm-generic/pgtable.h linux-2.6-patched/include/asm-generic/pgtable.h
--- linux-2.6/include/asm-generic/pgtable.h	2007-06-18 09:43:22.000000000 +0200
+++ linux-2.6-patched/include/asm-generic/pgtable.h	2007-06-29 15:44:10.000000000 +0200
@@ -3,25 +3,6 @@
 
 #ifndef __ASSEMBLY__
 
-#ifndef __HAVE_ARCH_PTEP_ESTABLISH
-/*
- * Establish a new mapping:
- *  - flush the old one
- *  - update the page tables
- *  - inform the TLB about the new one
- *
- * We hold the mm semaphore for reading, and the pte lock.
- *
- * Note: the old pte is known to not be writable, so we don't need to
- * worry about dirty bits etc getting lost.
- */
-#define ptep_establish(__vma, __address, __ptep, __entry)		\
-do {				  					\
-	set_pte_at((__vma)->vm_mm, (__address), __ptep, __entry);	\
-	flush_tlb_page(__vma, __address);				\
-} while (0)
-#endif
-
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 /*
  * Largely same as above, but only sets the access flags (dirty,
diff -urpN linux-2.6/include/asm-i386/pgtable.h linux-2.6-patched/include/asm-i386/pgtable.h
--- linux-2.6/include/asm-i386/pgtable.h	2007-06-18 09:43:22.000000000 +0200
+++ linux-2.6-patched/include/asm-i386/pgtable.h	2007-06-29 15:44:10.000000000 +0200
@@ -317,17 +317,6 @@ static inline pte_t native_local_ptep_ge
 	__ret;								\
 })
 
-/*
- * Rules for using ptep_establish: the pte MUST be a user pte, and
- * must be a present->present transition.
- */
-#define __HAVE_ARCH_PTEP_ESTABLISH
-#define ptep_establish(vma, address, ptep, pteval)			\
-do {									\
-	set_pte_present((vma)->vm_mm, address, ptep, pteval);		\
-	flush_tlb_page(vma, address);					\
-} while (0)
-
 #define __HAVE_ARCH_PTEP_CLEAR_DIRTY_FLUSH
 #define ptep_clear_flush_dirty(vma, address, ptep)			\
 ({									\
diff -urpN linux-2.6/include/asm-ia64/pgtable.h linux-2.6-patched/include/asm-ia64/pgtable.h
--- linux-2.6/include/asm-ia64/pgtable.h	2007-06-18 09:43:22.000000000 +0200
+++ linux-2.6-patched/include/asm-ia64/pgtable.h	2007-06-29 15:44:10.000000000 +0200
@@ -546,8 +546,10 @@ extern void lazy_mmu_prot_update (pte_t 
 # define ptep_set_access_flags(__vma, __addr, __ptep, __entry, __safely_writable) \
 ({									\
 	int __changed = !pte_same(*(__ptep), __entry);			\
-	if (__changed)							\
-		ptep_establish(__vma, __addr, __ptep, __entry);		\
+	if (__changed) {						\
+		set_pte_at((__vma)->vm_mm, (__addr), __ptep, __entry);	\
+		flush_tlb_page(__vma, __addr);				\
+	}								\
 	__changed;							\
 })
 #endif

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
