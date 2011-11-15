Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EE01E6B0070
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 01:54:39 -0500 (EST)
Subject: [patch v2 3/4]thp: add tlb_remove_pmd_tlb_entry
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Nov 2011 15:04:18 +0800
Message-ID: <1321340658.22361.296.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>

We have tlb_remove_tlb_entry to indicate a pte tlb flush entry should be
flushed, but not a corresponding API for pmd entry. This isn't a problem so far
because THP is only for x86 currently and tlb_flush() under x86 will flush
entire TLB. But this is confusion and could be missed if thp is ported to
other arch.
Also converted tlb->need_flush = 1 to a VM_BUG_ON(!tlb->need_flush) in
__tlb_remove_page() as suggested by Andrea Arcangeli. __tlb_remove_page()
is supposed to be called after tlb_remove_xxx_tlb_entry() and we can catch
any misuse.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 include/asm-generic/tlb.h |   14 ++++++++++++++
 include/linux/huge_mm.h   |    2 +-
 mm/huge_memory.c          |    3 ++-
 mm/memory.c               |    4 ++--
 4 files changed, 19 insertions(+), 4 deletions(-)

Index: linux/include/asm-generic/tlb.h
===================================================================
--- linux.orig/include/asm-generic/tlb.h	2011-11-15 09:39:11.000000000 +0800
+++ linux/include/asm-generic/tlb.h	2011-11-15 09:39:23.000000000 +0800
@@ -139,6 +139,20 @@ static inline void tlb_remove_page(struc
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
+/**
+ * tlb_remove_pmd_tlb_entry - remember a pmd mapping for later tlb invalidation
+ * This is a nop so far, because only x86 needs it.
+ */
+#ifndef __tlb_remove_pmd_tlb_entry
+#define __tlb_remove_pmd_tlb_entry(tlb, pmdp, address) do {} while (0)
+#endif
+
+#define tlb_remove_pmd_tlb_entry(tlb, pmdp, address)		\
+	do {							\
+		tlb->need_flush = 1;				\
+		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);	\
+	} while (0)
+
 #define pte_free_tlb(tlb, ptep, address)			\
 	do {							\
 		tlb->need_flush = 1;				\
Index: linux/include/linux/huge_mm.h
===================================================================
--- linux.orig/include/linux/huge_mm.h	2011-11-15 09:39:11.000000000 +0800
+++ linux/include/linux/huge_mm.h	2011-11-15 09:39:23.000000000 +0800
@@ -18,7 +18,7 @@ extern struct page *follow_trans_huge_pm
 					  unsigned int flags);
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
-			pmd_t *pmd);
+			pmd_t *pmd, unsigned long addr);
 extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, unsigned long end,
 			unsigned char *vec);
Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c	2011-11-15 09:39:17.000000000 +0800
+++ linux/mm/huge_memory.c	2011-11-15 09:39:23.000000000 +0800
@@ -1026,7 +1026,7 @@ out:
 }
 
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
-		 pmd_t *pmd)
+		 pmd_t *pmd, unsigned long addr)
 {
 	int ret = 0;
 
@@ -1042,6 +1042,7 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 			pgtable = get_pmd_huge_pte(tlb->mm);
 			page = pmd_page(*pmd);
 			pmd_clear(pmd);
+			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 			page_remove_rmap(page);
 			VM_BUG_ON(page_mapcount(page) < 0);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2011-11-15 09:39:11.000000000 +0800
+++ linux/mm/memory.c	2011-11-15 09:40:55.000000000 +0800
@@ -293,7 +293,7 @@ int __tlb_remove_page(struct mmu_gather
 {
 	struct mmu_gather_batch *batch;
 
-	tlb->need_flush = 1;
+	VM_BUG_ON(!tlb->need_flush);
 
 	if (tlb_fast_mode(tlb)) {
 		free_page_and_swap_cache(page);
@@ -1231,7 +1231,7 @@ static inline unsigned long zap_pmd_rang
 			if (next-addr != HPAGE_PMD_SIZE) {
 				VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
 				split_huge_page_pmd(vma->vm_mm, pmd);
-			} else if (zap_huge_pmd(tlb, vma, pmd))
+			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				continue;
 			/* fall through */
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
