Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id D044D6B005A
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 15:37:52 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Apr 2013 01:03:18 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 6C9E7394005B
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:07:46 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3SJbdLh8651262
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:07:39 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3SJbj20003237
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 05:37:45 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 12/18] powerpc: Reduce PTE table memory wastage
Date: Mon, 29 Apr 2013 01:07:33 +0530
Message-Id: <1367177859-7893-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We allocate one page for the last level of linux page table. With THP and
large page size of 16MB, that would mean we are wasting large part
of that page. To map 16MB area, we only need a PTE space of 2K with 64K
page size. This patch reduce the space wastage by sharing the page
allocated for the last level of linux page table with multiple pmd
entries. We call these smaller chunks PTE page fragments and allocated
page, PTE page.

In order to support systems which doesn't have 64K HPTE support, we also
add another 2K to PTE page fragment. The second half of the PTE fragments
is used for storing slot and secondary bit information of an HPTE. With this
we now have a 4K PTE fragment.

We use a simple approach to share the PTE page. On allocation, we bump the
PTE page refcount to 16 and share the PTE page with the next 16 pte alloc
request. This should help in the node locality of the PTE page fragment,
assuming that the immediate pte alloc request will mostly come from the
same NUMA node. We don't try to reuse the freed PTE page fragment. Hence
we could be waisting some space.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/mmu-book3e.h |   4 ++
 arch/powerpc/include/asm/mmu-hash64.h |   4 ++
 arch/powerpc/include/asm/page.h       |   4 ++
 arch/powerpc/include/asm/pgalloc-64.h |  82 +++++++----------------
 arch/powerpc/kernel/setup_64.c        |   4 +-
 arch/powerpc/mm/mmu_context_hash64.c  |  37 +++++++++++
 arch/powerpc/mm/pgtable_64.c          | 118 ++++++++++++++++++++++++++++++++++
 7 files changed, 195 insertions(+), 58 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu-book3e.h b/arch/powerpc/include/asm/mmu-book3e.h
index 99d43e0..8bd560c 100644
--- a/arch/powerpc/include/asm/mmu-book3e.h
+++ b/arch/powerpc/include/asm/mmu-book3e.h
@@ -231,6 +231,10 @@ typedef struct {
 	u64 high_slices_psize;  /* 4 bits per slice for now */
 	u16 user_psize;         /* page size index */
 #endif
+#ifdef CONFIG_PPC_64K_PAGES
+	/* for 4K PTE fragment support */
+	void *pte_frag;
+#endif
 } mm_context_t;
 
 /* Page size definitions, common between 32 and 64-bit
diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include/asm/mmu-hash64.h
index 05895cf..de9e577 100644
--- a/arch/powerpc/include/asm/mmu-hash64.h
+++ b/arch/powerpc/include/asm/mmu-hash64.h
@@ -516,6 +516,10 @@ typedef struct {
 	unsigned long acop;	/* mask of enabled coprocessor types */
 	unsigned int cop_pid;	/* pid value used with coprocessors */
 #endif /* CONFIG_PPC_ICSWX */
+#ifdef CONFIG_PPC_64K_PAGES
+	/* for 4K PTE fragment support */
+	void *pte_frag;
+#endif
 } mm_context_t;
 
 
diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index 711e83a..988c812 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -393,7 +393,11 @@ void arch_free_page(struct page *page, int order);
 
 struct vm_area_struct;
 
+#ifdef CONFIG_PPC_64K_PAGES
+typedef pte_t *pgtable_t;
+#else
 typedef struct page *pgtable_t;
+#endif
 
 #include <asm-generic/memory_model.h>
 #endif /* __ASSEMBLY__ */
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index d390123..91acb12 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -152,6 +152,23 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 }
 
 #else /* if CONFIG_PPC_64K_PAGES */
+/*
+ * we support 16 fragments per PTE page.
+ */
+#define PTE_FRAG_NR	16
+/*
+ * We use a 2K PTE page fragment and another 2K for storing
+ * real_pte_t hash index
+ */
+#define PTE_FRAG_SIZE_SHIFT  12
+#define PTE_FRAG_SIZE (2 * PTRS_PER_PTE * sizeof(pte_t))
+
+extern pte_t *page_table_alloc(struct mm_struct *, unsigned long, int);
+extern void page_table_free(struct mm_struct *, unsigned long *, int);
+extern void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift);
+#ifdef CONFIG_SMP
+extern void __tlb_remove_table(void *_table);
+#endif
 
 #define pud_populate(mm, pud, pmd)	pud_set(pud, (unsigned long)pmd)
 
@@ -164,90 +181,42 @@ static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 				pgtable_t pte_page)
 {
-	pmd_populate_kernel(mm, pmd, page_address(pte_page));
+	pmd_set(pmd, (unsigned long)pte_page);
 }
 
 static inline pgtable_t pmd_pgtable(pmd_t pmd)
 {
-	return pmd_page(pmd);
+	return (pgtable_t)(pmd_val(pmd) & -sizeof(pte_t)*PTRS_PER_PTE);
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
+	return (pte_t *)page_table_alloc(mm, address, 1);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-				      unsigned long address)
+					unsigned long address)
 {
-	struct page *page;
-	pte_t *pte;
-
-	pte = pte_alloc_one_kernel(mm, address);
-	if (!pte)
-		return NULL;
-	page = virt_to_page(pte);
-	pgtable_page_ctor(page);
-	return page;
+	return (pgtable_t)page_table_alloc(mm, address, 0);
 }
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
-	free_page((unsigned long)pte);
+	page_table_free(mm, (unsigned long *)pte, 1);
 }
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
 {
-	pgtable_page_dtor(ptepage);
-	__free_page(ptepage);
+	page_table_free(mm, (unsigned long *)ptepage, 0);
 }
 
-static inline void pgtable_free(void *table, unsigned index_size)
-{
-	if (!index_size)
-		free_page((unsigned long)table);
-	else {
-		BUG_ON(index_size > MAX_PGTABLE_INDEX_SIZE);
-		kmem_cache_free(PGT_CACHE(index_size), table);
-	}
-}
-
-#ifdef CONFIG_SMP
-static inline void pgtable_free_tlb(struct mmu_gather *tlb,
-				    void *table, int shift)
-{
-	unsigned long pgf = (unsigned long)table;
-	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
-	pgf |= shift;
-	tlb_remove_table(tlb, (void *)pgf);
-}
-
-static inline void __tlb_remove_table(void *_table)
-{
-	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
-	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
-
-	pgtable_free(table, shift);
-}
-#else /* !CONFIG_SMP */
-static inline void pgtable_free_tlb(struct mmu_gather *tlb,
-				    void *table, int shift)
-{
-	pgtable_free(table, shift);
-}
-#endif /* CONFIG_SMP */
-
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 				  unsigned long address)
 {
-	struct page *page = page_address(table);
-
 	tlb_flush_pgtable(tlb, address);
-	pgtable_page_dtor(page);
-	pgtable_free_tlb(tlb, page, 0);
+	pgtable_free_tlb(tlb, table, 0);
 }
-
 #endif /* CONFIG_PPC_64K_PAGES */
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
@@ -261,7 +230,6 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
 }
 
-
 #define __pmd_free_tlb(tlb, pmd, addr)		      \
 	pgtable_free_tlb(tlb, pmd, PMD_INDEX_SIZE)
 #ifndef CONFIG_PPC_64K_PAGES
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index 75fbaceb..e379d3f 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -583,7 +583,9 @@ void __init setup_arch(char **cmdline_p)
 	init_mm.end_code = (unsigned long) _etext;
 	init_mm.end_data = (unsigned long) _edata;
 	init_mm.brk = klimit;
-	
+#ifdef CONFIG_PPC_64K_PAGES
+	init_mm.context.pte_frag = NULL;
+#endif
 	irqstack_early_init();
 	exc_lvl_early_init();
 	emergency_stack_init();
diff --git a/arch/powerpc/mm/mmu_context_hash64.c b/arch/powerpc/mm/mmu_context_hash64.c
index d1d1b92..178876ae 100644
--- a/arch/powerpc/mm/mmu_context_hash64.c
+++ b/arch/powerpc/mm/mmu_context_hash64.c
@@ -23,6 +23,7 @@
 #include <linux/slab.h>
 
 #include <asm/mmu_context.h>
+#include <asm/pgalloc.h>
 
 #include "icswx.h"
 
@@ -85,6 +86,9 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	spin_lock_init(mm->context.cop_lockp);
 #endif /* CONFIG_PPC_ICSWX */
 
+#ifdef CONFIG_PPC_64K_PAGES
+	mm->context.pte_frag = NULL;
+#endif
 	return 0;
 }
 
@@ -96,13 +100,46 @@ void __destroy_context(int context_id)
 }
 EXPORT_SYMBOL_GPL(__destroy_context);
 
+#ifdef CONFIG_PPC_64K_PAGES
+static void destroy_pagetable_page(struct mm_struct *mm)
+{
+	int count;
+	void *pte_frag;
+	struct page *page;
+
+	pte_frag = mm->context.pte_frag;
+	if (!pte_frag)
+		return;
+
+	page = virt_to_page(pte_frag);
+	/* drop all the pending references */
+	count = ((unsigned long)pte_frag & ~PAGE_MASK) >> PTE_FRAG_SIZE_SHIFT;
+	/* We allow PTE_FRAG_NR fragments from a PTE page */
+	count = atomic_sub_return(PTE_FRAG_NR - count, &page->_count);
+	if (!count) {
+		pgtable_page_dtor(page);
+		free_hot_cold_page(page, 0);
+	}
+}
+
+#else
+static inline void destroy_pagetable_page(struct mm_struct *mm)
+{
+	return;
+}
+#endif
+
+
 void destroy_context(struct mm_struct *mm)
 {
+
 #ifdef CONFIG_PPC_ICSWX
 	drop_cop(mm->context.acop, mm);
 	kfree(mm->context.cop_lockp);
 	mm->context.cop_lockp = NULL;
 #endif /* CONFIG_PPC_ICSWX */
+
+	destroy_pagetable_page(mm);
 	__destroy_context(mm->context.id);
 	subpage_prot_free(mm);
 	mm->context.id = MMU_NO_CONTEXT;
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 654258f..a854096 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -337,3 +337,121 @@ EXPORT_SYMBOL(__ioremap_at);
 EXPORT_SYMBOL(iounmap);
 EXPORT_SYMBOL(__iounmap);
 EXPORT_SYMBOL(__iounmap_at);
+
+#ifdef CONFIG_PPC_64K_PAGES
+static pte_t *get_from_cache(struct mm_struct *mm)
+{
+	void *pte_frag, *ret;
+
+	spin_lock(&mm->page_table_lock);
+	ret = mm->context.pte_frag;
+	if (ret) {
+		pte_frag = ret + PTE_FRAG_SIZE;
+		/*
+		 * If we have taken up all the fragments mark PTE page NULL
+		 */
+		if (((unsigned long)pte_frag & ~PAGE_MASK) == 0)
+			pte_frag = NULL;
+		mm->context.pte_frag = pte_frag;
+	}
+	spin_unlock(&mm->page_table_lock);
+	return (pte_t *)ret;
+}
+
+static pte_t *__alloc_for_cache(struct mm_struct *mm, int kernel)
+{
+	void *ret = NULL;
+	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK |
+				       __GFP_REPEAT | __GFP_ZERO);
+	if (!page)
+		return NULL;
+
+	ret = page_address(page);
+	spin_lock(&mm->page_table_lock);
+	/*
+	 * If we find pgtable_page set, we return
+	 * the allocated page with single fragement
+	 * count.
+	 */
+	if (likely(!mm->context.pte_frag)) {
+		atomic_set(&page->_count, PTE_FRAG_NR);
+		mm->context.pte_frag = ret + PTE_FRAG_SIZE;
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	if (!kernel)
+		pgtable_page_ctor(page);
+
+	return (pte_t *)ret;
+}
+
+pte_t *page_table_alloc(struct mm_struct *mm, unsigned long vmaddr, int kernel)
+{
+	pte_t *pte;
+
+	pte = get_from_cache(mm);
+	if (pte)
+		return pte;
+
+	return __alloc_for_cache(mm, kernel);
+}
+
+void page_table_free(struct mm_struct *mm, unsigned long *table, int kernel)
+{
+	struct page *page = virt_to_page(table);
+	if (put_page_testzero(page)) {
+		if (!kernel)
+			pgtable_page_dtor(page);
+		free_hot_cold_page(page, 0);
+	}
+}
+
+#ifdef CONFIG_SMP
+static void page_table_free_rcu(void *table)
+{
+	struct page *page = virt_to_page(table);
+	if (put_page_testzero(page)) {
+		pgtable_page_dtor(page);
+		free_hot_cold_page(page, 0);
+	}
+}
+
+void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift)
+{
+	unsigned long pgf = (unsigned long)table;
+
+	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
+	pgf |= shift;
+	tlb_remove_table(tlb, (void *)pgf);
+}
+
+void __tlb_remove_table(void *_table)
+{
+	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
+	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
+
+	if (!shift)
+		/* PTE page needs special handling */
+		page_table_free_rcu(table);
+	else {
+		BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
+		kmem_cache_free(PGT_CACHE(shift), table);
+	}
+}
+#else
+void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift)
+{
+	if (!shift) {
+		/* PTE page needs special handling */
+		struct page *page = virt_to_page(table);
+		if (put_page_testzero(page)) {
+			pgtable_page_dtor(page);
+			free_hot_cold_page(page, 0);
+		}
+	} else {
+		BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
+		kmem_cache_free(PGT_CACHE(shift), table);
+	}
+}
+#endif
+#endif /* CONFIG_PPC_64K_PAGES */
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
