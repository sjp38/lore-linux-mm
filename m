Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 18CB46B000A
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 03:05:42 -0500 (EST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 26 Feb 2013 17:59:24 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 6E7D02CE8023
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:37 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1Q7rA287864738
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 18:53:10 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1Q85aML007769
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:36 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 06/24] powerpc: Reduce PTE table memory wastage
Date: Tue, 26 Feb 2013 13:34:56 +0530
Message-Id: <1361865914-13911-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We allocate one page for the last level of linux page table. With THP and
large page size of 16MB, that would mean we are be wasting large part
of that page. To map 16MB area, we only need a PTE space of 2K with 64K
page size. This patch reduce the space wastage by sharing the page
allocated for the last level of linux page table with multiple pmd
entries. We call these smaller chunks PTE page fragments and allocated
page, PTE page. We use the page->_mapcount as bitmap to indicate which
PTE fragments are free.

page->_mapcount is divided into two halves. The upper half is used for
tracking the freed page framents in the RCU grace period.

In order to support systems which doesn't have 64K HPTE support, we also
add another 2K to PTE page fragment. The second half of the PTE fragments
is used for storing slot and secondary bit information of an HPTE. With this
we now have a 4K PTE fragment.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/mmu-book3e.h |    4 +
 arch/powerpc/include/asm/mmu-hash64.h |    4 +
 arch/powerpc/include/asm/page.h       |    4 +
 arch/powerpc/include/asm/pgalloc-64.h |  123 ++++++++++++++-------
 arch/powerpc/kernel/setup_64.c        |    4 +-
 arch/powerpc/mm/mmu_context_hash64.c  |   27 +++++
 arch/powerpc/mm/pgtable_64.c          |  190 +++++++++++++++++++++++++++++++++
 7 files changed, 314 insertions(+), 42 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu-book3e.h b/arch/powerpc/include/asm/mmu-book3e.h
index 99d43e0..ffae629 100644
--- a/arch/powerpc/include/asm/mmu-book3e.h
+++ b/arch/powerpc/include/asm/mmu-book3e.h
@@ -231,6 +231,10 @@ typedef struct {
 	u64 high_slices_psize;  /* 4 bits per slice for now */
 	u16 user_psize;         /* page size index */
 #endif
+#ifdef CONFIG_PPC_64K_PAGES
+	/* for 4K PTE fragment support */
+	struct list_head pgtable_list;
+#endif
 } mm_context_t;
 
 /* Page size definitions, common between 32 and 64-bit
diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include/asm/mmu-hash64.h
index 35bb51e..feac737 100644
--- a/arch/powerpc/include/asm/mmu-hash64.h
+++ b/arch/powerpc/include/asm/mmu-hash64.h
@@ -498,6 +498,10 @@ typedef struct {
 	unsigned long acop;	/* mask of enabled coprocessor types */
 	unsigned int cop_pid;	/* pid value used with coprocessors */
 #endif /* CONFIG_PPC_ICSWX */
+#ifdef CONFIG_PPC_64K_PAGES
+	/* for 4K PTE fragment support */
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
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index 8743107..f6875a5 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -72,45 +72,17 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 #define pmd_populate_kernel(mm, pmd, pte) pmd_set(pmd, (unsigned long)(pte))
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
-
-#else /* CONFIG_PPC_64K_PAGES */
-
-#define pud_populate(mm, pud, pmd)	pud_set(pud, (unsigned long)pmd)
-
-static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
-				       pte_t *pte)
-{
-	pmd_set(pmd, (unsigned long)pte);
-}
-
-#define pmd_populate(mm, pmd, pte_page) \
-	pmd_populate_kernel(mm, pmd, page_address(pte_page))
-#define pmd_pgtable(pmd) pmd_page(pmd)
-
-#endif /* CONFIG_PPC_64K_PAGES */
-
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
-{
-	return kmem_cache_alloc(PGT_CACHE(PMD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
-}
-
-static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
-{
-	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
-}
-
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-        return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
+	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 					unsigned long address)
 {
-	struct page *page;
 	pte_t *pte;
+	struct page *page;
 
 	pte = pte_alloc_one_kernel(mm, address);
 	if (!pte)
@@ -120,16 +92,6 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 	return page;
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
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
@@ -156,7 +118,12 @@ static inline void __tlb_remove_table(void *_table)
 	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
 	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
 
-	pgtable_free(table, shift);
+	if (!shift)
+		free_page((unsigned long)table);
+	else {
+		BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
+		kmem_cache_free(PGT_CACHE(shift), table);
+	}
 }
 #else
 static inline void pgtable_free_tlb(struct mmu_gather *tlb,
@@ -176,6 +143,80 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 	pgtable_free_tlb(tlb, page, 0);
 }
 
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
+#define pud_populate(mm, pud, pmd)	pud_set(pud, (unsigned long)pmd)
+
+static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
+				       pte_t *pte)
+{
+	pmd_set(pmd, (unsigned long)pte);
+}
+
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
+				pgtable_t pte_page)
+{
+	pmd_set(pmd, (unsigned long)pte_page);
+}
+
+static inline pgtable_t pmd_pgtable(pmd_t pmd)
+{
+	return (pgtable_t)(pmd_val(pmd) & -sizeof(pte_t)*PTRS_PER_PTE);
+}
+
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return (pte_t *)page_table_alloc(mm, address);
+}
+
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+					unsigned long address)
+{
+	return (pgtable_t)page_table_alloc(mm, address);
+}
+
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+{
+	page_table_free(mm, (unsigned long *)pte);
+}
+
+static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
+{
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
+}
+
 #define __pmd_free_tlb(tlb, pmd, addr)		      \
 	pgtable_free_tlb(tlb, pmd, PMD_INDEX_SIZE)
 #ifndef CONFIG_PPC_64K_PAGES
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
index e212a27..ae5189b 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -337,3 +337,193 @@ EXPORT_SYMBOL(__ioremap_at);
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
+	/* Free 4K page table fragment of a 64K page */
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
+	 * this is a PTE page free 4K page table
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
+	/* Free 4K page table fragment of a 64K page */
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
+		 * the free fragment can be used by the next alloc.
+		 * We will not be able to use it untill the rcu grace period
+		 * is over, because we have the corresponding high half bit set
+		 * and page_table_alloc looks at the high half bit.
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
