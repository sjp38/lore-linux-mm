Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id CBF846B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 05:58:52 -0500 (EST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 4 Mar 2013 20:53:57 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C11662BB0023
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 21:58:46 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r24Awh6A6619592
	for <linux-mm@kvack.org>; Mon, 4 Mar 2013 21:58:44 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r24AwjHB027707
	for <linux-mm@kvack.org>; Mon, 4 Mar 2013 21:58:45 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V1 06/24] powerpc: Reduce PTE table memory wastage
In-Reply-To: <20130304045853.GB27523@drongo>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361865914-13911-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130304045853.GB27523@drongo>
Date: Mon, 04 Mar 2013 16:28:42 +0530
Message-ID: <874ngr2zz1.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@samba.org> writes:

> On Tue, Feb 26, 2013 at 01:34:56PM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> We allocate one page for the last level of linux page table. With THP and
>> large page size of 16MB, that would mean we are be wasting large part
>> of that page. To map 16MB area, we only need a PTE space of 2K with 64K
>> page size. This patch reduce the space wastage by sharing the page
>> allocated for the last level of linux page table with multiple pmd
>> entries. We call these smaller chunks PTE page fragments and allocated
>> page, PTE page. We use the page->_mapcount as bitmap to indicate which
>> PTE fragments are free.
>> 
>> page->_mapcount is divided into two halves. The upper half is used for
>> tracking the freed page framents in the RCU grace period.
>> 
>> In order to support systems which doesn't have 64K HPTE support, we also
>> add another 2K to PTE page fragment. The second half of the PTE fragments
>> is used for storing slot and secondary bit information of an HPTE. With this
>> we now have a 4K PTE fragment.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> This one has taken me hours to review.  Perhaps it's partly because of
> the way that diff has matched things up, but it's difficult to see
> what's moved where, what's common code that is now the 4k page case,
> etc.  For example, pmd_alloc_one() and pmd_free() are unchanged, but
> the diff shows them as removed in one place and added in another.

I updated the previous patch "powerpc: Move the pte free routines from
common header" to duplicate the 4K and 64K definitions. That helped in
making the diff better. I have inlined the resulting patch below. Let
know if this one looks better.

>
> The other general comment I have is that it's not really clear when a
> page will be on the mm->context.pgtable_list and when it won't.  I
> would like to see an invariant that says something like "the page is
> on the pgtable_list if and only if (page->_mapcount & FRAG_MASK) is
> neither 0 nor FRAG_MASK".  But that doesn't seem to be the case
> exactly, and I can't see any consistent rule, which makes me think
> there are going to be bugs in corner cases.
>


I added the below comment when initializing the list.

+#ifdef CONFIG_PPC_64K_PAGES
+       /*
+        * Used to support 4K PTE fragment. The pages are added to list,
+        * when we have free framents in the page. We track the whether
+        * a page frament is available using page._mapcount. A value of
+        * zero indicate none of the fragments are used and page can be
+        * freed. A value of FRAG_MASK indicate all the fragments are used
+        * and hence the page will be removed from the below list.
+        */
+       INIT_LIST_HEAD(&init_mm.context.pgtable_list);
+#endif

I am not sure about why you say there is no consistent rule. Can you
elaborate on that ?

> Consider, for example, the case where a page has two fragments still
> in use, and one of them gets queued up by RCU for freeing via a call
> to page_table_free_rcu, and then the other one gets freed through
> page_table_free().  Neither the call to page_table_free_rcu nor the
> call to page_table_free will take the page off the list AFAICS, and
> then __page_table_free_rcu() will free the page while it's still on
> the pgtable_list.

The last one that ends up doing atomic_xor_bits which cause the mapcount
to go zero, will take the page off the list and free the page. 

>
> More specific comments below...
>
>> -static inline void pgtable_free(void *table, unsigned index_size)
>> -{
>> -	if (!index_size)
>> -		free_page((unsigned long)table);
>> -	else {
>> -		BUG_ON(index_size > MAX_PGTABLE_INDEX_SIZE);
>> -		kmem_cache_free(PGT_CACHE(index_size), table);
>> -	}
>> -}
>
> This is still used in the UP case, both for 4k and 64k, and UP configs
> now fail to build.
>
>>  static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
>>  {
>>  	free_page((unsigned long)pte);
>> @@ -156,7 +118,12 @@ static inline void __tlb_remove_table(void *_table)
>>  	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
>>  	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
>>  
>> -	pgtable_free(table, shift);
>> +	if (!shift)
>> +		free_page((unsigned long)table);
>> +	else {
>> +		BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
>> +		kmem_cache_free(PGT_CACHE(shift), table);
>> +	}
>
> Any particular reason for open-coding pgtable_free() here?
>
>> +/*
>> + * we support 15 fragments per PTE page. This is limited by how many
>> + * bits we can pack in page->_mapcount. We use the first half for
>> + * tracking the usage for rcu page table free.
>> + */
>> +#define FRAG_MASK_BITS	15
>> +#define FRAG_MASK ((1 << FRAG_MASK_BITS) - 1)
>
> Atomic_t variables are 32-bit, so you really should be able to make
> FRAG_MASK_BITS be 16 and avoid wasting the last fragment of each page.
>


commit ff1af6b4b5c90223bac43052436aae943bae1104
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Fri Oct 12 10:54:07 2012 +0530

    powerpc: Reduce PTE table memory wastage
    
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
index cdbf555..3b62636 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -150,6 +150,18 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 
 #else /* if CONFIG_PPC_64K_PAGES */
 
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
@@ -161,90 +173,42 @@ static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
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
+	return (pte_t *)page_table_alloc(mm, address);
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
+	return (pgtable_t)page_table_alloc(mm, address);
 }
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
-	free_page((unsigned long)pte);
+	page_table_free(mm, (unsigned long *)pte);
 }
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
 {
-	pgtable_page_dtor(ptepage);
-	__free_page(ptepage);
+	page_table_free(mm, (unsigned long *)ptepage);
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
@@ -258,7 +222,6 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
 }
 
-
 #define __pmd_free_tlb(tlb, pmd, addr)		      \
 	pgtable_free_tlb(tlb, pmd, PMD_INDEX_SIZE)
 #ifndef CONFIG_PPC_64K_PAGES
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index 6da881b..442f858 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -575,7 +575,17 @@ void __init setup_arch(char **cmdline_p)
 	init_mm.end_code = (unsigned long) _etext;
 	init_mm.end_data = (unsigned long) _edata;
 	init_mm.brk = klimit;
-	
+#ifdef CONFIG_PPC_64K_PAGES
+	/*
+	 * Used to support 4K PTE fragment. The pages are added to list,
+	 * when we have free framents in the page. We track the whether
+	 * a page frament is available using page._mapcount. A value of
+	 * zero indicate none of the fragments are used and page can be
+	 * freed. A value of FRAG_MASK indicate all the fragments are used
+	 * and hence the page will be removed from the below list.
+	 */
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
index e212a27..2a49044 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -337,3 +337,193 @@ EXPORT_SYMBOL(__ioremap_at);
 EXPORT_SYMBOL(iounmap);
 EXPORT_SYMBOL(__iounmap);
 EXPORT_SYMBOL(__iounmap_at);
+
+#ifdef CONFIG_PPC_64K_PAGES
+/*
+ * we support 16 fragments per PTE page. This is limited by how many
+ * bits we can pack in page->_mapcount. We use the first half for
+ * tracking the usage for rcu page table free.
+ */
+#define FRAG_MASK_BITS	16
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
