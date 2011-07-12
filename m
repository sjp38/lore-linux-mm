Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 11DD06B0082
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 08:34:13 -0400 (EDT)
Message-Id: <20110712122911.646230694@chello.nl>
Date: Tue, 12 Jul 2011 14:26:10 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 2/4] sparc64: Use RCU page table freeing.
References: <20110712122608.938583937@chello.nl>
Content-Disposition: inline; filename=davem-sparc64-Use_RCU_page_table_freeing.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

Make use of the generic RCU page table freeing on Sparc64, doing so
allows for race-free software page-table walkers like gup_fast().

Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Link: http://lkml.kernel.org/r/20100408.180008.180206930.davem@davemloft.net
---
 arch/sparc/Kconfig                  |    1 
 arch/sparc/include/asm/pgalloc_64.h |   48 ++++++++++++++++++++++++++++++++++--
 2 files changed, 47 insertions(+), 2 deletions(-)

Index: linux-2.6/arch/sparc/include/asm/pgalloc_64.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/pgalloc_64.h
+++ linux-2.6/arch/sparc/include/asm/pgalloc_64.h
@@ -76,7 +76,51 @@ static inline void pte_free(struct mm_st
 
 #define check_pgt_cache()	do { } while (0)
 
-#define __pte_free_tlb(tlb, pte, addr)	pte_free((tlb)->mm, pte)
-#define __pmd_free_tlb(tlb, pmd, addr)	pmd_free((tlb)->mm, pmd)
+static inline void pgtable_free(void *table, bool is_page)
+{
+	if (is_page)
+		free_page((unsigned long)table);
+	else
+		kmem_cache_free(pgtable_cache, table);
+}
+
+#ifdef CONFIG_SMP
+
+struct mmu_gather;
+extern void tlb_remove_table(struct mmu_gather *, void *);
+
+static inline void pgtable_free_tlb(struct mmu_gather *tlb, void *table, bool is_page)
+{
+	unsigned long pgf = (unsigned long)table;
+	if (is_page)
+		pgf |= 0x1UL;
+	tlb_remove_table(tlb, (void *)pgf);
+}
+
+static inline void __tlb_remove_table(void *_table)
+{
+	void *table = (void *)((unsigned long)_table & ~0x1UL);
+	bool is_page = false;
+
+	if ((unsigned long)_table & 0x1UL)
+		is_page = true;
+	pgtable_free(table, is_page);
+}
+#else /* CONFIG_SMP */
+static inline void pgtable_free_tlb(struct mmu_gather *tlb, void *table, bool is_page)
+{
+	pgtable_free(table, is_page);
+}
+#endif /* !CONFIG_SMP */
+
+static inline void __pte_free_tlb(struct mmu_gather *tlb, struct page *ptepage,
+				  unsigned long address)
+{
+	pgtable_page_dtor(ptepage);
+	pgtable_free_tlb(tlb, page_address(ptepage), true);
+}
+
+#define __pmd_free_tlb(tlb, pmd, addr)		      \
+	pgtable_free_tlb(tlb, pmd, false)
 
 #endif /* _SPARC64_PGALLOC_H */
Index: linux-2.6/arch/sparc/Kconfig
===================================================================
--- linux-2.6.orig/arch/sparc/Kconfig
+++ linux-2.6/arch/sparc/Kconfig
@@ -53,6 +53,7 @@ config SPARC64
 	select HAVE_PERF_EVENTS
 	select PERF_USE_VMALLOC
 	select IRQ_PREFLOW_FASTEOI
+	select HAVE_RCU_TABLE_FREE if SMP
 
 config ARCH_DEFCONFIG
 	string


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
