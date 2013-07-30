Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E3ADD6B0032
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 16:46:58 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id fq13so4473629lab.25
        for <linux-mm@kvack.org>; Tue, 30 Jul 2013 13:46:57 -0700 (PDT)
Message-Id: <20130730204654.966378702@gmail.com>
Date: Wed, 31 Jul 2013 00:41:56 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [patch 2/2] [PATCH] mm: Save soft-dirty bits on file pages
References: <20130730204154.407090410@gmail.com>
Content-Disposition: inline; filename=pte-sft-dirty-file-2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, luto@amacapital.net, gorcunov@openvz.org, xemul@parallels.com, akpm@linux-foundation.org, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

Andy reported that if file page get reclaimed we loose soft-dirty bit
if it was there, so save _PAGE_BIT_SOFT_DIRTY bit when page address
get encoded into pte entry. Thus when #pf happens on such non-present
pte we can restore it back.

Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/x86/include/asm/pgtable-2level.h |   48 +++++++++++++++++++++++++++++++++-
 arch/x86/include/asm/pgtable-3level.h |    3 ++
 arch/x86/include/asm/pgtable.h        |   15 ++++++++++
 arch/x86/include/asm/pgtable_types.h  |    4 ++
 fs/proc/task_mmu.c                    |    2 +
 include/asm-generic/pgtable.h         |   15 ++++++++++
 mm/fremap.c                           |   11 +++++--
 mm/memory.c                           |   11 +++++--
 mm/rmap.c                             |    8 ++++-
 9 files changed, 107 insertions(+), 10 deletions(-)

Index: linux-2.6.git/arch/x86/include/asm/pgtable-2level.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable-2level.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable-2level.h
@@ -55,9 +55,53 @@ static inline pmd_t native_pmdp_get_and_
 #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
 #endif
 
+#ifdef CONFIG_MEM_SOFT_DIRTY
+
+/*
+ * Bits _PAGE_BIT_PRESENT, _PAGE_BIT_FILE, _PAGE_BIT_SOFT_DIRTY and
+ * _PAGE_BIT_PROTNONE are taken, split up the 28 bits of offset
+ * into this range.
+ */
+#define PTE_FILE_MAX_BITS	28
+#define PTE_FILE_SHIFT1		(_PAGE_BIT_PRESENT + 1)
+#define PTE_FILE_SHIFT2		(_PAGE_BIT_FILE + 1)
+#define PTE_FILE_SHIFT3		(_PAGE_BIT_PROTNONE + 1)
+#define PTE_FILE_SHIFT4		(_PAGE_BIT_SOFT_DIRTY + 1)
+#define PTE_FILE_BITS1		(PTE_FILE_SHIFT2 - PTE_FILE_SHIFT1 - 1)
+#define PTE_FILE_BITS2		(PTE_FILE_SHIFT3 - PTE_FILE_SHIFT2 - 1)
+#define PTE_FILE_BITS3		(PTE_FILE_SHIFT4 - PTE_FILE_SHIFT3 - 1)
+
+#define pte_to_pgoff(pte)						\
+	((((pte).pte_low >> (PTE_FILE_SHIFT1))				\
+	  & ((1U << PTE_FILE_BITS1) - 1)))				\
+	+ ((((pte).pte_low >> (PTE_FILE_SHIFT2))			\
+	    & ((1U << PTE_FILE_BITS2) - 1))				\
+	   << (PTE_FILE_BITS1))						\
+	+ ((((pte).pte_low >> (PTE_FILE_SHIFT3))			\
+	    & ((1U << PTE_FILE_BITS3) - 1))				\
+	   << (PTE_FILE_BITS1 + PTE_FILE_BITS2))			\
+	+ ((((pte).pte_low >> (PTE_FILE_SHIFT4)))			\
+	    << (PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3))
+
+#define pgoff_to_pte(off)						\
+	((pte_t) { .pte_low =						\
+	 ((((off)) & ((1U << PTE_FILE_BITS1) - 1)) << PTE_FILE_SHIFT1)	\
+	 + ((((off) >> PTE_FILE_BITS1)					\
+	     & ((1U << PTE_FILE_BITS2) - 1))				\
+	    << PTE_FILE_SHIFT2)						\
+	 + ((((off) >> (PTE_FILE_BITS1 + PTE_FILE_BITS2))		\
+	     & ((1U << PTE_FILE_BITS3) - 1))				\
+	    << PTE_FILE_SHIFT3)						\
+	 + ((((off) >>							\
+	      (PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3)))	\
+	    << PTE_FILE_SHIFT4)						\
+	 + _PAGE_FILE })
+
+#else /* CONFIG_MEM_SOFT_DIRTY */
+
 /*
  * Bits _PAGE_BIT_PRESENT, _PAGE_BIT_FILE and _PAGE_BIT_PROTNONE are taken,
- * split up the 29 bits of offset into this range:
+ * split up the 29 bits of offset into this range.
  */
 #define PTE_FILE_MAX_BITS	29
 #define PTE_FILE_SHIFT1		(_PAGE_BIT_PRESENT + 1)
@@ -88,6 +132,8 @@ static inline pmd_t native_pmdp_get_and_
 	    << PTE_FILE_SHIFT3)						\
 	 + _PAGE_FILE })
 
+#endif /* CONFIG_MEM_SOFT_DIRTY */
+
 /* Encode and de-code a swap entry */
 #if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE
 #define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)
Index: linux-2.6.git/arch/x86/include/asm/pgtable-3level.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable-3level.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable-3level.h
@@ -179,6 +179,9 @@ static inline pmd_t native_pmdp_get_and_
 /*
  * Bits 0, 6 and 7 are taken in the low part of the pte,
  * put the 32 bits of offset into the high part.
+ *
+ * For soft-dirty tracking 11 bit is taken from
+ * the low part of pte as well.
  */
 #define pte_to_pgoff(pte) ((pte).pte_high)
 #define pgoff_to_pte(off)						\
Index: linux-2.6.git/arch/x86/include/asm/pgtable.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable.h
@@ -329,6 +329,21 @@ static inline pte_t pte_swp_clear_soft_d
 	return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
 }
 
+static inline pte_t pte_file_clear_soft_dirty(pte_t pte)
+{
+	return pte_clear_flags(pte, _PAGE_SOFT_DIRTY);
+}
+
+static inline pte_t pte_file_mksoft_dirty(pte_t pte)
+{
+	return pte_set_flags(pte, _PAGE_SOFT_DIRTY);
+}
+
+static inline int pte_file_soft_dirty(pte_t pte)
+{
+	return pte_flags(pte) & _PAGE_SOFT_DIRTY;
+}
+
 /*
  * Mask out unsupported bits in a present pgprot.  Non-present pgprots
  * can use those bits for other purposes, so leave them be.
Index: linux-2.6.git/arch/x86/include/asm/pgtable_types.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable_types.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable_types.h
@@ -61,8 +61,10 @@
  * they do not conflict with each other.
  */
 
+#define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_HIDDEN
+
 #ifdef CONFIG_MEM_SOFT_DIRTY
-#define _PAGE_SOFT_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_HIDDEN)
+#define _PAGE_SOFT_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_SOFT_DIRTY)
 #else
 #define _PAGE_SOFT_DIRTY	(_AT(pteval_t, 0))
 #endif
Index: linux-2.6.git/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.git.orig/fs/proc/task_mmu.c
+++ linux-2.6.git/fs/proc/task_mmu.c
@@ -736,6 +736,8 @@ static inline void clear_soft_dirty(stru
 		ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
 	} else if (is_swap_pte(ptent)) {
 		ptent = pte_swp_clear_soft_dirty(ptent);
+	} else if (pte_file(ptent)) {
+		ptent = pte_file_clear_soft_dirty(ptent);
 	}
 
 	set_pte_at(vma->vm_mm, addr, pte, ptent);
Index: linux-2.6.git/include/asm-generic/pgtable.h
===================================================================
--- linux-2.6.git.orig/include/asm-generic/pgtable.h
+++ linux-2.6.git/include/asm-generic/pgtable.h
@@ -432,6 +432,21 @@ static inline pte_t pte_swp_clear_soft_d
 {
 	return pte;
 }
+
+static inline pte_t pte_file_clear_soft_dirty(pte_t pte)
+{
+       return pte;
+}
+
+static inline pte_t pte_file_mksoft_dirty(pte_t pte)
+{
+       return pte;
+}
+
+static inline int pte_file_soft_dirty(pte_t pte)
+{
+       return 0;
+}
 #endif
 
 #ifndef __HAVE_PFNMAP_TRACKING
Index: linux-2.6.git/mm/fremap.c
===================================================================
--- linux-2.6.git.orig/mm/fremap.c
+++ linux-2.6.git/mm/fremap.c
@@ -57,17 +57,22 @@ static int install_file_pte(struct mm_st
 		unsigned long addr, unsigned long pgoff, pgprot_t prot)
 {
 	int err = -ENOMEM;
-	pte_t *pte;
+	pte_t *pte, ptfile;
 	spinlock_t *ptl;
 
 	pte = get_locked_pte(mm, addr, &ptl);
 	if (!pte)
 		goto out;
 
-	if (!pte_none(*pte))
+	ptfile = pgoff_to_pte(pgoff);
+
+	if (!pte_none(*pte)) {
+		if (pte_present(*pte) && pte_soft_dirty(*pte))
+			pte_file_mksoft_dirty(ptfile);
 		zap_pte(mm, vma, addr, pte);
+	}
 
-	set_pte_at(mm, addr, pte, pgoff_to_pte(pgoff));
+	set_pte_at(mm, addr, pte, ptfile);
 	/*
 	 * We don't need to run update_mmu_cache() here because the "file pte"
 	 * being installed by install_file_pte() is not a real pte - it's a
Index: linux-2.6.git/mm/memory.c
===================================================================
--- linux-2.6.git.orig/mm/memory.c
+++ linux-2.6.git/mm/memory.c
@@ -1141,9 +1141,12 @@ again:
 				continue;
 			if (unlikely(details) && details->nonlinear_vma
 			    && linear_page_index(details->nonlinear_vma,
-						addr) != page->index)
-				set_pte_at(mm, addr, pte,
-					   pgoff_to_pte(page->index));
+						addr) != page->index) {
+				pte_t ptfile = pgoff_to_pte(page->index);
+				if (pte_soft_dirty(ptent))
+					pte_file_mksoft_dirty(ptfile);
+				set_pte_at(mm, addr, pte, ptfile);
+			}
 			if (PageAnon(page))
 				rss[MM_ANONPAGES]--;
 			else {
@@ -3410,6 +3413,8 @@ static int __do_fault(struct mm_struct *
 		entry = mk_pte(page, vma->vm_page_prot);
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		else if (pte_file(orig_pte) && pte_file_soft_dirty(orig_pte))
+			pte_mksoft_dirty(entry);
 		if (anon) {
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
 			page_add_new_anon_rmap(page, vma, address);
Index: linux-2.6.git/mm/rmap.c
===================================================================
--- linux-2.6.git.orig/mm/rmap.c
+++ linux-2.6.git/mm/rmap.c
@@ -1405,8 +1405,12 @@ static int try_to_unmap_cluster(unsigned
 		pteval = ptep_clear_flush(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
-		if (page->index != linear_page_index(vma, address))
-			set_pte_at(mm, address, pte, pgoff_to_pte(page->index));
+		if (page->index != linear_page_index(vma, address)) {
+			pte_t ptfile = pgoff_to_pte(page->index);
+			if (pte_soft_dirty(pteval))
+				pte_file_mksoft_dirty(ptfile);
+			set_pte_at(mm, address, pte, ptfile);
+		}
 
 		/* Move the dirty bit to the physical page now the pte is gone. */
 		if (pte_dirty(pteval))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
