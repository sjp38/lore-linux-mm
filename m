Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 3A89E6B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 16:18:11 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id o10so1635960lbi.40
        for <linux-mm@kvack.org>; Fri, 26 Jul 2013 13:18:09 -0700 (PDT)
Date: Sat, 27 Jul 2013 00:18:07 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH] mm: Save soft-dirty bits on file pages
Message-ID: <20130726201807.GJ8661@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

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
---
 arch/x86/include/asm/pgtable-2level.h |   48 +++++++++++++++++++++++++++++++++-
 arch/x86/include/asm/pgtable-3level.h |    3 ++
 arch/x86/include/asm/pgtable.h        |   15 ++++++++++
 arch/x86/include/asm/pgtable_types.h  |    4 ++
 fs/proc/task_mmu.c                    |    2 +
 mm/fremap.c                           |   14 +++++++--
 mm/memory.c                           |   20 +++++++++++---
 mm/rmap.c                             |   10 +++++--
 8 files changed, 105 insertions(+), 11 deletions(-)

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
 	} else if (pte_swp_soft_dirty(ptent)) {
 		ptent = pte_swp_clear_soft_dirty(ptent);
+	} else if (pte_file(ptent)) {
+		ptent = pte_file_clear_soft_dirty(ptent);
 	}
 
 	set_pte_at(vma->vm_mm, addr, pte, ptent);
Index: linux-2.6.git/mm/fremap.c
===================================================================
--- linux-2.6.git.orig/mm/fremap.c
+++ linux-2.6.git/mm/fremap.c
@@ -57,17 +57,25 @@ static int install_file_pte(struct mm_st
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
+#ifdef CONFIG_MEM_SOFT_DIRTY
+		if (pte_present(*pte) &&
+		    pte_soft_dirty(*pte))
+			pte_file_mksoft_dirty(ptfile);
+#endif
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
@@ -1141,9 +1141,14 @@ again:
 				continue;
 			if (unlikely(details) && details->nonlinear_vma
 			    && linear_page_index(details->nonlinear_vma,
-						addr) != page->index)
-				set_pte_at(mm, addr, pte,
-					   pgoff_to_pte(page->index));
+						addr) != page->index) {
+				pte_t ptfile = pgoff_to_pte(page->index);
+#ifdef CONFIG_MEM_SOFT_DIRTY
+				if (pte_soft_dirty(ptent))
+					pte_file_mksoft_dirty(ptfile);
+#endif
+				set_pte_at(mm, addr, pte, ptfile);
+			}
 			if (PageAnon(page))
 				rss[MM_ANONPAGES]--;
 			else {
@@ -3410,8 +3415,15 @@ static int __do_fault(struct mm_struct *
 	if (likely(pte_same(*page_table, orig_pte))) {
 		flush_icache_page(vma, page);
 		entry = mk_pte(page, vma->vm_page_prot);
-		if (flags & FAULT_FLAG_WRITE)
+		if (flags & FAULT_FLAG_WRITE) {
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		}
+#ifdef CONFIG_MEM_SOFT_DIRTY
+		else if (pte_file(orig_pte) &&
+			 pte_file_soft_dirty(orig_pte)) {
+			pte_mksoft_dirty(entry);
+		}
+#endif
 		if (anon) {
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
 			page_add_new_anon_rmap(page, vma, address);
Index: linux-2.6.git/mm/rmap.c
===================================================================
--- linux-2.6.git.orig/mm/rmap.c
+++ linux-2.6.git/mm/rmap.c
@@ -1407,8 +1407,14 @@ static int try_to_unmap_cluster(unsigned
 		pteval = ptep_clear_flush(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
-		if (page->index != linear_page_index(vma, address))
-			set_pte_at(mm, address, pte, pgoff_to_pte(page->index));
+		if (page->index != linear_page_index(vma, address)) {
+			pte_t ptfile = pgoff_to_pte(page->index);
+#ifdef CONFIG_MEM_SOFT_DIRTY
+			if (pte_soft_dirty(pteval))
+				pte_file_mksoft_dirty(ptfile);
+#endif
+			set_pte_at(mm, address, pte, ptfile);
+		}
 
 		/* Move the dirty bit to the physical page now the pte is gone. */
 		if (pte_dirty(pteval))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
