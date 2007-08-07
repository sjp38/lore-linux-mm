From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 07 Aug 2007 17:19:51 +1000
Subject: [RFC/PATCH 8/12] remove ptep_get_and_clear_full
In-Reply-To: <1186471185.826251.312410898174.qpush@grosgo>
Message-Id: <20070807071958.0FE4EDDE11@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch removes it, instead, the arch implementations that
care use the new MMF_DEAD flag in the mm_struct.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

NOTE: I'm not necessarily convinced yet this is the right approach,
but I needed to get rid of it because my current new batch structure
doesn't have this fullmm field anymore.

However, I'm thinking about putting it back in and replacing
ptep_get_and_clear with a tlb_get_and_clear_pte() which would
take a batch as an argument instead once I'm done moving all
page table walkers to use the batch for TLB operations.

 include/asm-generic/pgtable.h |    9 ---------
 include/asm-i386/pgtable.h    |   17 +++++++----------
 include/asm-x86_64/pgtable.h  |    8 ++++----
 mm/memory.c                   |    3 +--
 4 files changed, 12 insertions(+), 25 deletions(-)

Index: linux-work/include/asm-generic/pgtable.h
===================================================================
--- linux-work.orig/include/asm-generic/pgtable.h	2007-08-07 16:19:14.000000000 +1000
+++ linux-work/include/asm-generic/pgtable.h	2007-08-07 16:19:19.000000000 +1000
@@ -58,15 +58,6 @@
 })
 #endif
 
-#ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
-#define ptep_get_and_clear_full(__mm, __address, __ptep, __full)	\
-({									\
-	pte_t __pte;							\
-	__pte = ptep_get_and_clear((__mm), (__address), (__ptep));	\
-	__pte;								\
-})
-#endif
-
 /*
  * Some architectures may be able to avoid expensive synchronization
  * primitives when modifications are made to PTE's which are already
Index: linux-work/include/asm-i386/pgtable.h
===================================================================
--- linux-work.orig/include/asm-i386/pgtable.h	2007-08-07 16:20:05.000000000 +1000
+++ linux-work/include/asm-i386/pgtable.h	2007-08-07 16:22:05.000000000 +1000
@@ -311,15 +311,9 @@ static inline pte_t native_local_ptep_ge
 })
 
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
-static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
-{
-	pte_t pte = native_ptep_get_and_clear(ptep);
-	pte_update(mm, addr, ptep);
-	return pte;
-}
-
-#define __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
-static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm, unsigned long addr, pte_t *ptep, int full)
+static inline pte_t __ptep_get_and_clear(struct mm_struct *mm,
+					 unsigned long addr, pte_t *ptep,
+					 int full)
 {
 	pte_t pte;
 	if (full) {
@@ -329,10 +323,13 @@ static inline pte_t ptep_get_and_clear_f
 		 */
 		pte = native_local_ptep_get_and_clear(ptep);
 	} else {
-		pte = ptep_get_and_clear(mm, addr, ptep);
+		pte = native_ptep_get_and_clear(ptep);
+		pte_update(mm, addr, ptep);
 	}
 	return pte;
 }
+#define ptep_get_and_clear(mm, addr, ptep)				\
+	__ptep_get_and_clear(mm, addr, ptep, test_bit(MMF_DEAD, &mm->flags))
 
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
Index: linux-work/include/asm-x86_64/pgtable.h
===================================================================
--- linux-work.orig/include/asm-x86_64/pgtable.h	2007-08-07 16:22:23.000000000 +1000
+++ linux-work/include/asm-x86_64/pgtable.h	2007-08-07 16:23:14.000000000 +1000
@@ -102,21 +102,21 @@ static inline void pgd_clear (pgd_t * pg
 	set_pgd(pgd, __pgd(0));
 }
 
-#define ptep_get_and_clear(mm,addr,xp)	__pte(xchg(&(xp)->pte, 0))
-
 struct mm_struct;
 
-static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm, unsigned long addr, pte_t *ptep, int full)
+static inline pte_t __ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep, int full)
 {
 	pte_t pte;
 	if (full) {
 		pte = *ptep;
 		*ptep = __pte(0);
 	} else {
-		pte = ptep_get_and_clear(mm, addr, ptep);
+		__pte(xchg(&(xp)->pte, 0))
 	}
 	return pte;
 }
+#define ptep_get_and_clear(mm, addr, ptep)				\
+	__ptep_get_and_clear(mm, addr, ptep, test_bit(MMF_DEAD, &mm->flags))
 
 #define pte_same(a, b)		((a).pte == (b).pte)
 
Index: linux-work/mm/memory.c
===================================================================
--- linux-work.orig/mm/memory.c	2007-08-07 16:18:43.000000000 +1000
+++ linux-work/mm/memory.c	2007-08-07 16:18:48.000000000 +1000
@@ -658,8 +658,7 @@ static unsigned long zap_pte_range(struc
 				     page->index > details->last_index))
 					continue;
 			}
-			ptent = ptep_get_and_clear_full(mm, addr, pte,
-							tlb->fullmm);
+			ptent = ptep_get_and_clear(mm, addr, pte);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 			if (unlikely(!page))
 				continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
