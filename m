Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id EDFA16B000C
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 11:47:53 -0500 (EST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 22:14:59 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id CC31B1258052
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:18:35 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LGlhd526673294
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:17:44 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LGlkIv010228
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 03:47:47 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH -V2 05/21] powerpc: Reduce PTE table memory wastage
Date: Thu, 21 Feb 2013 22:17:12 +0530
Message-Id: <1361465248-10867-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We now have PTE page consuming only 2K of the 64K page.This is in order to
facilitate transparent huge page support, which works much better if our PMDs
cover 16MB instead of 256MB.

Inorder to reduce the wastage, we now have multiple PTE page fragment
from the same PTE page.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/mmu-book3e.h |    4 +
 arch/powerpc/include/asm/mmu-hash64.h |    4 +
 arch/powerpc/include/asm/page.h       |    4 +
 arch/powerpc/include/asm/pgalloc-32.h |   45 ++++++++
 arch/powerpc/include/asm/pgalloc-64.h |  143 ++++++++++++++++++++-----
 arch/powerpc/include/asm/pgalloc.h    |   46 +-------
 arch/powerpc/kernel/setup_64.c        |    4 +-
 arch/powerpc/mm/mmu_context_hash64.c  |   27 +++++
 arch/powerpc/mm/pgtable_64.c          |  189 +++++++++++++++++++++++++++++++++
 9 files changed, 392 insertions(+), 74 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu-book3e.h b/arch/powerpc/include/asm/mmu-book3e.h
index 99d43e0..6bd293d 100644
--- a/arch/powerpc/include/asm/mmu-book3e.h
+++ b/arch/powerpc/include/asm/mmu-book3e.h
@@ -231,6 +231,10 @@ typedef struct {
 	u64 high_slices_psize;  /* 4 bits per slice for now */
 	u16 user_psize;         /* page size index */
 #endif
+#ifdef CONFIG_PPC_64K_PAGES
+	/* for 2K page table support */
+	struct list_head pgtable_list;
+#endif
 } mm_context_t;
 
 /* Page size definitions, common between 32 and 64-bit
diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include/asm/mmu-hash64.h
index 35bb51e..c3b3518 100644
--- a/arch/powerpc/include/asm/mmu-hash64.h
+++ b/arch/powerpc/include/asm/mmu-hash64.h
@@ -498,6 +498,10 @@ typedef struct {
 	unsigned long acop;	/* mask of enabled coprocessor types */
 	unsigned int cop_pid;	/* pid value used with coprocessors */
 #endif /* CONFIG_PPC_ICSWX */
+#ifdef CONFIG_PPC_64K_PAGES
+	/* for 2K page table support */
+	struct list_head pgtable_list;
+#endif
 } mm_context_t;
 
 
diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index f072e97..38e7ff6 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -378,7 +378,11 @@ void arch_free_page(struct page *page, int order);
 
 struct vm_area_struct;
 
+#ifdef CONFIG_PPC_64K_PAGES
+typedef pte_t *pgtable_t;
+#else
 typedef struct page *pgtable_t;
+#endif
 
 #include <asm-generic/memory_model.h>
 #endif /* __ASSEMBLY__ */
diff --git a/arch/powerpc/include/asm/pgalloc-32.h b/arch/powerpc/include/asm/pgalloc-32.h
index 580cf73..27b2386 100644
--- a/arch/powerpc/include/asm/pgalloc-32.h
+++ b/arch/powerpc/include/asm/pgalloc-32.h
@@ -37,6 +37,17 @@ extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
 extern pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr);
 
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+{
+	free_page((unsigned long)pte);
+}
+
+static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
+{
+	pgtable_page_dtor(ptepage);
+	__free_page(ptepage);
+}
+
 static inline void pgtable_free(void *table, unsigned index_size)
 {
 	BUG_ON(index_size); /* 32-bit doesn't use this */
@@ -45,4 +56,38 @@ static inline void pgtable_free(void *table, unsigned index_size)
 
 #define check_pgt_cache()	do { } while (0)
 
+#ifdef CONFIG_SMP
+static inline void pgtable_free_tlb(struct mmu_gather *tlb,
+				    void *table, int shift)
+{
+	unsigned long pgf = (unsigned long)table;
+	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
+	pgf |= shift;
+	tlb_remove_table(tlb, (void *)pgf);
+}
+
+static inline void __tlb_remove_table(void *_table)
+{
+	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
+	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
+
+	pgtable_free(table, shift);
+}
+#else
+static inline void pgtable_free_tlb(struct mmu_gather *tlb,
+				    void *table, int shift)
+{
+	pgtable_free(table, shift);
+}
+#endif
+
+static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
+				  unsigned long address)
+{
+	struct page *page = page_address(table);
+
+	tlb_flush_pgtable(tlb, address);
+	pgtable_page_dtor(page);
+	pgtable_free_tlb(tlb, page, 0);
+}
 #endif /* _ASM_POWERPC_PGALLOC_32_H */
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index 292725c..f6875a5 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -72,9 +72,91 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 #define pmd_populate_kernel(mm, pmd, pte) pmd_set(pmd, (unsigned long)(pte))
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
+}
 
-#else /* CONFIG_PPC_64K_PAGES */
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+					unsigned long address)
+{
+	pte_t *pte;
+	struct page *page;
 
+	pte = pte_alloc_one_kernel(mm, address);
+	if (!pte)
+		return NULL;
+	page = virt_to_page(pte);
+	pgtable_page_ctor(page);
+	return page;
+}
+
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+{
+	free_page((unsigned long)pte);
+}
+
+static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
+{
+	pgtable_page_dtor(ptepage);
+	__free_page(ptepage);
+}
+
+#ifdef CONFIG_SMP
+static inline void pgtable_free_tlb(struct mmu_gather *tlb,
+				    void *table, int shift)
+{
+	unsigned long pgf = (unsigned long)table;
+	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
+	pgf |= shift;
+	tlb_remove_table(tlb, (void *)pgf);
+}
+
+static inline void __tlb_remove_table(void *_table)
+{
+	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
+	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
+
+	if (!shift)
+		free_page((unsigned long)table);
+	else {
+		BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
+		kmem_cache_free(PGT_CACHE(shift), table);
+	}
+}
+#else
+static inline void pgtable_free_tlb(struct mmu_gather *tlb,
+				    void *table, int shift)
+{
+	pgtable_free(table, shift);
+}
+#endif
+
+static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
+				  unsigned long address)
+{
+	struct page *page = page_address(table);
+
+	tlb_flush_pgtable(tlb, address);
+	pgtable_page_dtor(page);
+	pgtable_free_tlb(tlb, page, 0);
+}
+
+#else /* if CONFIG_PPC_64K_PAGES */
+
+extern unsigned long *page_table_alloc(struct mm_struct *, unsigned long);
+extern void page_table_free(struct mm_struct *, unsigned long *);
+#ifdef CONFIG_SMP
+extern void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift);
+extern void __tlb_remove_table(void *_table);
+#else
+static inline void pgtable_free_tlb(struct mmu_gather *tlb,
+				    void *table, int shift)
+{
+	pgtable_free(table, shift);
+}
+#endif
 #define pud_populate(mm, pud, pmd)	pud_set(pud, (unsigned long)pmd)
 
 static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
@@ -83,51 +165,56 @@ static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 	pmd_set(pmd, (unsigned long)pte);
 }
 
-#define pmd_populate(mm, pmd, pte_page) \
-	pmd_populate_kernel(mm, pmd, page_address(pte_page))
-#define pmd_pgtable(pmd) pmd_page(pmd)
-
-#endif /* CONFIG_PPC_64K_PAGES */
-
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
+				pgtable_t pte_page)
 {
-	return kmem_cache_alloc(PGT_CACHE(PMD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
+	pmd_set(pmd, (unsigned long)pte_page);
 }
 
-static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
+static inline pgtable_t pmd_pgtable(pmd_t pmd)
 {
-	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
+	return (pgtable_t)(pmd_val(pmd) & -sizeof(pte_t)*PTRS_PER_PTE);
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-        return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
+	return (pte_t *)page_table_alloc(mm, address);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 					unsigned long address)
 {
-	struct page *page;
-	pte_t *pte;
+	return (pgtable_t)page_table_alloc(mm, address);
+}
 
-	pte = pte_alloc_one_kernel(mm, address);
-	if (!pte)
-		return NULL;
-	page = virt_to_page(pte);
-	pgtable_page_ctor(page);
-	return page;
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+{
+	page_table_free(mm, (unsigned long *)pte);
 }
 
-static inline void pgtable_free(void *table, unsigned index_size)
+static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
 {
-	if (!index_size)
-		free_page((unsigned long)table);
-	else {
-		BUG_ON(index_size > MAX_PGTABLE_INDEX_SIZE);
-		kmem_cache_free(PGT_CACHE(index_size), table);
-	}
+	page_table_free(mm, (unsigned long *)ptepage);
+}
+
+static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
+				  unsigned long address)
+{
+	tlb_flush_pgtable(tlb, address);
+	pgtable_free_tlb(tlb, table, 0);
+}
+#endif /* CONFIG_PPC_64K_PAGES */
+
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return kmem_cache_alloc(PGT_CACHE(PMD_INDEX_SIZE),
+				GFP_KERNEL|__GFP_REPEAT);
+}
+
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
+{
+	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
 }
 
 #define __pmd_free_tlb(tlb, pmd, addr)		      \
diff --git a/arch/powerpc/include/asm/pgalloc.h b/arch/powerpc/include/asm/pgalloc.h
index bf301ac..e9a9f60 100644
--- a/arch/powerpc/include/asm/pgalloc.h
+++ b/arch/powerpc/include/asm/pgalloc.h
@@ -3,6 +3,7 @@
 #ifdef __KERNEL__
 
 #include <linux/mm.h>
+#include <asm-generic/tlb.h>
 
 #ifdef CONFIG_PPC_BOOK3E
 extern void tlb_flush_pgtable(struct mmu_gather *tlb, unsigned long address);
@@ -13,56 +14,11 @@ static inline void tlb_flush_pgtable(struct mmu_gather *tlb,
 }
 #endif /* !CONFIG_PPC_BOOK3E */
 
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	free_page((unsigned long)pte);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
-{
-	pgtable_page_dtor(ptepage);
-	__free_page(ptepage);
-}
-
 #ifdef CONFIG_PPC64
 #include <asm/pgalloc-64.h>
 #else
 #include <asm/pgalloc-32.h>
 #endif
 
-#ifdef CONFIG_SMP
-struct mmu_gather;
-extern void tlb_remove_table(struct mmu_gather *, void *);
-
-static inline void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift)
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
-#else /* CONFIG_SMP */
-static inline void pgtable_free_tlb(struct mmu_gather *tlb, void *table, unsigned shift)
-{
-	pgtable_free(table, shift);
-}
-#endif /* !CONFIG_SMP */
-
-static inline void __pte_free_tlb(struct mmu_gather *tlb, struct page *ptepage,
-				  unsigned long address)
-{
-	tlb_flush_pgtable(tlb, address);
-	pgtable_page_dtor(ptepage);
-	pgtable_free_tlb(tlb, page_address(ptepage), 0);
-}
-
 #endif /* __KERNEL__ */
 #endif /* _ASM_POWERPC_PGALLOC_H */
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index 6da881b..4e2db82 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -575,7 +575,9 @@ void __init setup_arch(char **cmdline_p)
 	init_mm.end_code = (unsigned long) _etext;
 	init_mm.end_data = (unsigned long) _edata;
 	init_mm.brk = klimit;
-	
+#ifdef CONFIG_PPC_64K_PAGES
+	INIT_LIST_HEAD(&init_mm.context.pgtable_list);
+#endif
 	irqstack_early_init();
 	exc_lvl_early_init();
 	emergency_stack_init();
diff --git a/arch/powerpc/mm/mmu_context_hash64.c b/arch/powerpc/mm/mmu_context_hash64.c
index 59cd773..474b9af 100644
--- a/arch/powerpc/mm/mmu_context_hash64.c
+++ b/arch/powerpc/mm/mmu_context_hash64.c
@@ -86,6 +86,9 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	spin_lock_init(mm->context.cop_lockp);
 #endif /* CONFIG_PPC_ICSWX */
 
+#ifdef CONFIG_PPC_64K_PAGES
+	INIT_LIST_HEAD(&mm->context.pgtable_list);
+#endif
 	return 0;
 }
 
@@ -97,13 +100,37 @@ void __destroy_context(int context_id)
 }
 EXPORT_SYMBOL_GPL(__destroy_context);
 
+#ifdef CONFIG_PPC_64K_PAGES
+static void destroy_pagetable_list(struct mm_struct *mm)
+{
+	struct page *page;
+	struct list_head *item, *tmp;
+
+	list_for_each_safe(item, tmp, &mm->context.pgtable_list) {
+		page = list_entry(item, struct page, lru);
+		list_del(&page->lru);
+		pgtable_page_dtor(page);
+		atomic_set(&page->_mapcount, -1);
+		__free_page(page);
+	}
+}
+#else
+static inline void destroy_pagetable_list(struct mm_struct *mm)
+{
+	return;
+}
+#endif
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
+	destroy_pagetable_list(mm);
 	__destroy_context(mm->context.id);
 	subpage_prot_free(mm);
 	mm->context.id = MMU_NO_CONTEXT;
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index e212a27..ec80314 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -69,6 +69,7 @@
 unsigned long ioremap_bot = IOREMAP_BASE;
 
 #ifdef CONFIG_PPC_MMU_NOHASH
+/* FIXME!! */
 static void *early_alloc_pgtable(unsigned long size)
 {
 	void *pt;
@@ -337,3 +338,191 @@ EXPORT_SYMBOL(__ioremap_at);
 EXPORT_SYMBOL(iounmap);
 EXPORT_SYMBOL(__iounmap);
 EXPORT_SYMBOL(__iounmap_at);
+
+#ifdef CONFIG_PPC_64K_PAGES
+/*
+ * we support 15 fragments per PTE page. This is limited by how many
+ * bits we can pack in page->_mapcount. We use the first half for
+ * tracking the usage for rcu page table free.
+ */
+#define FRAG_MASK_BITS	15
+#define FRAG_MASK ((1 << FRAG_MASK_BITS) - 1)
+/*
+ * We use a 2K PTE page fragment and another 2K for storing
+ * real_pte_t hash index
+ */
+#define PTE_FRAG_SIZE (2 * PTRS_PER_PTE * sizeof(pte_t))
+
+static inline unsigned int atomic_xor_bits(atomic_t *v, unsigned int bits)
+{
+	unsigned int old, new;
+
+	do {
+		old = atomic_read(v);
+		new = old ^ bits;
+	} while (atomic_cmpxchg(v, old, new) != old);
+	return new;
+}
+
+unsigned long *page_table_alloc(struct mm_struct *mm, unsigned long vmaddr)
+{
+	struct page *page;
+	unsigned int mask, bit;
+	unsigned long *table;
+
+	/* Allocate fragments of a 4K page as 1K/2K page table */
+	spin_lock(&mm->page_table_lock);
+	mask = FRAG_MASK;
+	if (!list_empty(&mm->context.pgtable_list)) {
+		page = list_first_entry(&mm->context.pgtable_list,
+					struct page, lru);
+		table = (unsigned long *) page_address(page);
+		mask = atomic_read(&page->_mapcount);
+		/*
+		 * Update with the higher order mask bits accumulated,
+		 * added as a part of rcu free.
+		 */
+		mask = mask | (mask >> FRAG_MASK_BITS);
+	}
+	if ((mask & FRAG_MASK) == FRAG_MASK) {
+		spin_unlock(&mm->page_table_lock);
+		page = alloc_page(GFP_KERNEL|__GFP_REPEAT);
+		if (!page)
+			return NULL;
+		pgtable_page_ctor(page);
+		atomic_set(&page->_mapcount, 1);
+		table = (unsigned long *) page_address(page);
+		spin_lock(&mm->page_table_lock);
+		INIT_LIST_HEAD(&page->lru);
+		list_add(&page->lru, &mm->context.pgtable_list);
+	} else {
+		/* The second half is used for real_pte_t hindex */
+		for (bit = 1; mask & bit; bit <<= 1)
+			table = (unsigned long *)((char *)table + PTE_FRAG_SIZE);
+
+		mask = atomic_xor_bits(&page->_mapcount, bit);
+		/*
+		 * We have taken up all the space, remove this from
+		 * the list, we will add it back when we have a free slot
+		 */
+		if ((mask & FRAG_MASK) == FRAG_MASK)
+			list_del_init(&page->lru);
+	}
+	spin_unlock(&mm->page_table_lock);
+	/*
+	 * zero out the newly allocated area, this make sure we don't
+	 * see the old left over pte values
+	 */
+	memset(table, 0, PTE_FRAG_SIZE);
+	return table;
+}
+
+void page_table_free(struct mm_struct *mm, unsigned long *table)
+{
+	struct page *page;
+	unsigned int bit, mask;
+
+	/* Free 2K page table fragment of a 64K page */
+	page = virt_to_page(table);
+	bit = 1 << ((__pa(table) & ~PAGE_MASK) / PTE_FRAG_SIZE);
+	spin_lock(&mm->page_table_lock);
+	mask = atomic_xor_bits(&page->_mapcount, bit);
+	if (mask == 0)
+		list_del(&page->lru);
+	else if (mask & FRAG_MASK) {
+		/*
+		 * Add the page table page to pgtable_list so that
+		 * the free fragment can be used by the next alloc
+		 */
+		list_del_init(&page->lru);
+		list_add(&page->lru, &mm->context.pgtable_list);
+	}
+	spin_unlock(&mm->page_table_lock);
+	if (mask == 0) {
+		pgtable_page_dtor(page);
+		atomic_set(&page->_mapcount, -1);
+		__free_page(page);
+	}
+}
+
+#ifdef CONFIG_SMP
+static void __page_table_free_rcu(void *table)
+{
+	unsigned int bit;
+	struct page *page;
+	/*
+	 * this is a PTE page free 2K page table
+	 * fragment of a 64K page.
+	 */
+	page = virt_to_page(table);
+	bit = 1 << ((__pa(table) & ~PAGE_MASK) / PTE_FRAG_SIZE);
+	bit <<= FRAG_MASK_BITS;
+	/*
+	 * clear the higher half and if nobody used the page in
+	 * between, even lower half would be zero.
+	 */
+	if (atomic_xor_bits(&page->_mapcount, bit) == 0) {
+		pgtable_page_dtor(page);
+		atomic_set(&page->_mapcount, -1);
+		__free_page(page);
+	}
+}
+
+static void page_table_free_rcu(struct mmu_gather *tlb, unsigned long *table)
+{
+	struct page *page;
+	struct mm_struct *mm;
+	unsigned int bit, mask;
+
+	mm = tlb->mm;
+	/* Free 2K page table fragment of a 64K page */
+	page = virt_to_page(table);
+	bit = 1 << ((__pa(table) & ~PAGE_MASK) / PTE_FRAG_SIZE);
+	spin_lock(&mm->page_table_lock);
+	/*
+	 * stash the actual mask in higher half, and clear the lower half
+	 * and selectively, add remove from pgtable list
+	 */
+	mask = atomic_xor_bits(&page->_mapcount, bit | (bit << FRAG_MASK_BITS));
+	if (!(mask & FRAG_MASK))
+		list_del(&page->lru);
+	else {
+		/*
+		 * Add the page table page to pgtable_list so that
+		 * the free fragment can be used by the next alloc
+		 */
+		list_del_init(&page->lru);
+		list_add_tail(&page->lru, &mm->context.pgtable_list);
+	}
+	spin_unlock(&mm->page_table_lock);
+	tlb_remove_table(tlb, table);
+}
+
+void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift)
+{
+	unsigned long pgf = (unsigned long)table;
+
+	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
+	pgf |= shift;
+	if (shift == 0)
+		/* PTE page needs special handling */
+		page_table_free_rcu(tlb, table);
+	else
+		tlb_remove_table(tlb, (void *)pgf);
+}
+
+void __tlb_remove_table(void *_table)
+{
+	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
+	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
+
+	if (!shift)
+		/* PTE page needs special handling */
+		__page_table_free_rcu(table);
+	else {
+		BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
+		kmem_cache_free(PGT_CACHE(shift), table);
+	}
+}
+#endif
+#endif /* CONFIG_PPC_64K_PAGES */
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
