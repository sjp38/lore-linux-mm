Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 5D6666B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 02:29:44 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 11:55:10 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 0DC7D3940057
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 11:59:35 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3A6TQuk66715894
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 11:59:26 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3A6TUlk011253
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:29:31 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 06/25] powerpc: Reduce PTE table memory wastage
In-Reply-To: <20130410044611.GF8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1365055083-31956-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130410044611.GF8165@truffula.fritz.box>
Date: Wed, 10 Apr 2013 11:59:29 +0530
Message-ID: <8738uyq4om.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

David Gibson <dwg@au1.ibm.com> writes:

> On Thu, Apr 04, 2013 at 11:27:44AM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> We allocate one page for the last level of linux page table. With THP and
>> large page size of 16MB, that would mean we are wasting large part
>> of that page. To map 16MB area, we only need a PTE space of 2K with 64K
>> page size. This patch reduce the space wastage by sharing the page
>> allocated for the last level of linux page table with multiple pmd
>> entries. We call these smaller chunks PTE page fragments and allocated
>> page, PTE page.
>> 
>> In order to support systems which doesn't have 64K HPTE support, we also
>> add another 2K to PTE page fragment. The second half of the PTE fragments
>> is used for storing slot and secondary bit information of an HPTE. With this
>> we now have a 4K PTE fragment.
>> 
>> We use a simple approach to share the PTE page. On allocation, we bump the
>> PTE page refcount to 16 and share the PTE page with the next 16 pte alloc
>> request. This should help in the node locality of the PTE page fragment,
>> assuming that the immediate pte alloc request will mostly come from the
>> same NUMA node. We don't try to reuse the freed PTE page fragment. Hence
>> we could be waisting some space.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  arch/powerpc/include/asm/mmu-book3e.h |    4 +
>>  arch/powerpc/include/asm/mmu-hash64.h |    4 +
>>  arch/powerpc/include/asm/page.h       |    4 +
>>  arch/powerpc/include/asm/pgalloc-64.h |   72 ++++-------------
>>  arch/powerpc/kernel/setup_64.c        |    4 +-
>>  arch/powerpc/mm/mmu_context_hash64.c  |   35 +++++++++
>>  arch/powerpc/mm/pgtable_64.c          |  137 +++++++++++++++++++++++++++++++++
>>  7 files changed, 202 insertions(+), 58 deletions(-)
>> 
>> diff --git a/arch/powerpc/include/asm/mmu-book3e.h b/arch/powerpc/include/asm/mmu-book3e.h
>> index 99d43e0..affbd68 100644
>> --- a/arch/powerpc/include/asm/mmu-book3e.h
>> +++ b/arch/powerpc/include/asm/mmu-book3e.h
>> @@ -231,6 +231,10 @@ typedef struct {
>>  	u64 high_slices_psize;  /* 4 bits per slice for now */
>>  	u16 user_psize;         /* page size index */
>>  #endif
>> +#ifdef CONFIG_PPC_64K_PAGES
>> +	/* for 4K PTE fragment support */
>> +	struct page *pgtable_page;
>> +#endif
>>  } mm_context_t;
>>  
>>  /* Page size definitions, common between 32 and 64-bit
>> diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include/asm/mmu-hash64.h
>> index 35bb51e..300ac3c 100644
>> --- a/arch/powerpc/include/asm/mmu-hash64.h
>> +++ b/arch/powerpc/include/asm/mmu-hash64.h
>> @@ -498,6 +498,10 @@ typedef struct {
>>  	unsigned long acop;	/* mask of enabled coprocessor types */
>>  	unsigned int cop_pid;	/* pid value used with coprocessors */
>>  #endif /* CONFIG_PPC_ICSWX */
>> +#ifdef CONFIG_PPC_64K_PAGES
>> +	/* for 4K PTE fragment support */
>> +	struct page *pgtable_page;
>> +#endif
>>  } mm_context_t;
>>  
>>  
>> diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
>> index f072e97..38e7ff6 100644
>> --- a/arch/powerpc/include/asm/page.h
>> +++ b/arch/powerpc/include/asm/page.h
>> @@ -378,7 +378,11 @@ void arch_free_page(struct page *page, int order);
>>  
>>  struct vm_area_struct;
>>  
>> +#ifdef CONFIG_PPC_64K_PAGES
>> +typedef pte_t *pgtable_t;
>> +#else
>>  typedef struct page *pgtable_t;
>> +#endif
>
> Ugh, that's pretty horrible, though I don't see an easy way around it.
>
>>  #include <asm-generic/memory_model.h>
>>  #endif /* __ASSEMBLY__ */
>> diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
>> index cdbf555..3418989 100644
>> --- a/arch/powerpc/include/asm/pgalloc-64.h
>> +++ b/arch/powerpc/include/asm/pgalloc-64.h
>> @@ -150,6 +150,13 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
>>  
>>  #else /* if CONFIG_PPC_64K_PAGES */
>>  
>> +extern pte_t *page_table_alloc(struct mm_struct *, unsigned long, int);
>> +extern void page_table_free(struct mm_struct *, unsigned long *, int);
>> +extern void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift);
>> +#ifdef CONFIG_SMP
>> +extern void __tlb_remove_table(void *_table);
>> +#endif
>> +
>>  #define pud_populate(mm, pud, pmd)	pud_set(pud, (unsigned long)pmd)
>>  
>>  static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
>> @@ -161,90 +168,42 @@ static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
>>  static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
>>  				pgtable_t pte_page)
>>  {
>> -	pmd_populate_kernel(mm, pmd, page_address(pte_page));
>> +	pmd_set(pmd, (unsigned long)pte_page);
>>  }
>>  
>>  static inline pgtable_t pmd_pgtable(pmd_t pmd)
>>  {
>> -	return pmd_page(pmd);
>> +	return (pgtable_t)(pmd_val(pmd) & -sizeof(pte_t)*PTRS_PER_PTE);
>>  }
>>  
>>  static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
>>  					  unsigned long address)
>>  {
>> -	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
>> +	return (pte_t *)page_table_alloc(mm, address, 1);
>>  }
>>  
>>  static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
>> -				      unsigned long address)
>> +					unsigned long address)
>>  {
>> -	struct page *page;
>> -	pte_t *pte;
>> -
>> -	pte = pte_alloc_one_kernel(mm, address);
>> -	if (!pte)
>> -		return NULL;
>> -	page = virt_to_page(pte);
>> -	pgtable_page_ctor(page);
>> -	return page;
>> +	return (pgtable_t)page_table_alloc(mm, address, 0);
>>  }
>>  
>>  static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
>>  {
>> -	free_page((unsigned long)pte);
>> +	page_table_free(mm, (unsigned long *)pte, 1);
>>  }
>>  
>>  static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
>>  {
>> -	pgtable_page_dtor(ptepage);
>> -	__free_page(ptepage);
>> -}
>> -
>> -static inline void pgtable_free(void *table, unsigned index_size)
>> -{
>> -	if (!index_size)
>> -		free_page((unsigned long)table);
>> -	else {
>> -		BUG_ON(index_size > MAX_PGTABLE_INDEX_SIZE);
>> -		kmem_cache_free(PGT_CACHE(index_size), table);
>> -	}
>> +	page_table_free(mm, (unsigned long *)ptepage, 0);
>>  }
>>  
>> -#ifdef CONFIG_SMP
>> -static inline void pgtable_free_tlb(struct mmu_gather *tlb,
>> -				    void *table, int shift)
>> -{
>> -	unsigned long pgf = (unsigned long)table;
>> -	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
>> -	pgf |= shift;
>> -	tlb_remove_table(tlb, (void *)pgf);
>> -}
>> -
>> -static inline void __tlb_remove_table(void *_table)
>> -{
>> -	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
>> -	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
>> -
>> -	pgtable_free(table, shift);
>> -}
>> -#else /* !CONFIG_SMP */
>> -static inline void pgtable_free_tlb(struct mmu_gather *tlb,
>> -				    void *table, int shift)
>> -{
>> -	pgtable_free(table, shift);
>> -}
>> -#endif /* CONFIG_SMP */
>> -
>>  static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
>>  				  unsigned long address)
>>  {
>> -	struct page *page = page_address(table);
>> -
>>  	tlb_flush_pgtable(tlb, address);
>> -	pgtable_page_dtor(page);
>> -	pgtable_free_tlb(tlb, page, 0);
>> +	pgtable_free_tlb(tlb, table, 0);
>>  }
>> -
>>  #endif /* CONFIG_PPC_64K_PAGES */
>>  
>>  static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
>> @@ -258,7 +217,6 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
>>  	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
>>  }
>>  
>> -
>>  #define __pmd_free_tlb(tlb, pmd, addr)		      \
>>  	pgtable_free_tlb(tlb, pmd, PMD_INDEX_SIZE)
>>  #ifndef CONFIG_PPC_64K_PAGES
>> diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
>> index 6da881b..04d833c 100644
>> --- a/arch/powerpc/kernel/setup_64.c
>> +++ b/arch/powerpc/kernel/setup_64.c
>> @@ -575,7 +575,9 @@ void __init setup_arch(char **cmdline_p)
>>  	init_mm.end_code = (unsigned long) _etext;
>>  	init_mm.end_data = (unsigned long) _edata;
>>  	init_mm.brk = klimit;
>> -	
>> +#ifdef CONFIG_PPC_64K_PAGES
>> +	init_mm.context.pgtable_page = NULL;
>> +#endif
>>  	irqstack_early_init();
>>  	exc_lvl_early_init();
>>  	emergency_stack_init();
>> diff --git a/arch/powerpc/mm/mmu_context_hash64.c b/arch/powerpc/mm/mmu_context_hash64.c
>> index 59cd773..fbfdca2 100644
>> --- a/arch/powerpc/mm/mmu_context_hash64.c
>> +++ b/arch/powerpc/mm/mmu_context_hash64.c
>> @@ -86,6 +86,9 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
>>  	spin_lock_init(mm->context.cop_lockp);
>>  #endif /* CONFIG_PPC_ICSWX */
>>  
>> +#ifdef CONFIG_PPC_64K_PAGES
>> +	mm->context.pgtable_page = NULL;
>> +#endif
>>  	return 0;
>>  }
>>  
>> @@ -97,13 +100,45 @@ void __destroy_context(int context_id)
>>  }
>>  EXPORT_SYMBOL_GPL(__destroy_context);
>>  
>> +#ifdef CONFIG_PPC_64K_PAGES
>> +static void destroy_pagetable_page(struct mm_struct *mm)
>> +{
>> +	int count;
>> +	struct page *page;
>> +
>> +	page = mm->context.pgtable_page;
>> +	if (!page)
>> +		return;
>> +
>> +	/* drop all the pending references */
>> +	count = atomic_read(&page->_mapcount) + 1;
>> +	/* We allow PTE_FRAG_NR(16) fragments from a PTE page */
>> +	count = atomic_sub_return(16 - count, &page->_count);
>
> You should really move PTE_FRAG_NR to a header so you can actually use
> it here rather than hard coding 16.
>
> It took me a fair while to convince myself that there is no race here
> with something altering mapcount and count between the atomic_read()
> and the atomic_sub_return().  It could do with a comment to explain
> why that is safe.
>
> Re-using the mapcount field for your index also seems odd, and it took
> me a while to convince myself that that's safe too.  Wouldn't it be
> simpler to store a pointer to the next sub-page in the mm_context
> instead? You can get from that to the struct page easily enough with a
> shift and pfn_to_page().

I found using _mapcount simpler in this case. I was looking at it not
as an index, but rather how may fragments are mapped/used already. Using
subpage pointer in mm->context.xyz means, we have to calculate the
number of fragments used/mapped via the pointer. We need the fragment
count so that we can drop page reference count correctly here.


>
>> +	if (!count) {
>> +		pgtable_page_dtor(page);
>> +		reset_page_mapcount(page);
>> +		free_hot_cold_page(page, 0);
>
> It would be nice to use put_page() somehow instead of duplicating its
> logic, though I realise the sparc code you've based this on does the
> same thing.

That is not exactly put_page. We can avoid lots of check in this
specific case.

>
>> +	}
>> +}
>> +
>> +#else
>> +static inline void destroy_pagetable_page(struct mm_struct *mm)
>> +{
>> +	return;
>> +}
>> +#endif
>> +
>> +
>>  void destroy_context(struct mm_struct *mm)
>>  {
>> +
>>  #ifdef CONFIG_PPC_ICSWX
>>  	drop_cop(mm->context.acop, mm);
>>  	kfree(mm->context.cop_lockp);
>>  	mm->context.cop_lockp = NULL;
>>  #endif /* CONFIG_PPC_ICSWX */
>> +
>> +	destroy_pagetable_page(mm);
>>  	__destroy_context(mm->context.id);
>>  	subpage_prot_free(mm);
>>  	mm->context.id = MMU_NO_CONTEXT;
>> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
>> index e212a27..e79840b 100644
>> --- a/arch/powerpc/mm/pgtable_64.c
>> +++ b/arch/powerpc/mm/pgtable_64.c
>> @@ -337,3 +337,140 @@ EXPORT_SYMBOL(__ioremap_at);
>>  EXPORT_SYMBOL(iounmap);
>>  EXPORT_SYMBOL(__iounmap);
>>  EXPORT_SYMBOL(__iounmap_at);
>> +
>> +#ifdef CONFIG_PPC_64K_PAGES
>> +/*
>> + * we support 16 fragments per PTE page. This is limited by how many
>> + * bits we can pack in page->_mapcount. We use the first half for
>> + * tracking the usage for rcu page table free.
>> + */
>> +#define PTE_FRAG_NR	16
>> +/*
>> + * We use a 2K PTE page fragment and another 2K for storing
>> + * real_pte_t hash index
>> + */
>> +#define PTE_FRAG_SIZE (2 * PTRS_PER_PTE * sizeof(pte_t))
>> +
>> +static pte_t *get_from_cache(struct mm_struct *mm)
>> +{
>> +	int index;
>> +	pte_t *ret = NULL;
>> +	struct page *page;
>> +
>> +	spin_lock(&mm->page_table_lock);
>> +	page = mm->context.pgtable_page;
>> +	if (page) {
>> +		void *p = page_address(page);
>> +		index = atomic_add_return(1, &page->_mapcount);
>> +		ret = (pte_t *) (p + (index * PTE_FRAG_SIZE));
>> +		/*
>> +		 * If we have taken up all the fragments mark PTE page NULL
>> +		 */
>> +		if (index == PTE_FRAG_NR - 1)
>> +			mm->context.pgtable_page = NULL;
>> +	}
>> +	spin_unlock(&mm->page_table_lock);
>> +	return ret;
>> +}
>> +
>> +static pte_t *__alloc_for_cache(struct mm_struct *mm, int kernel)
>> +{
>> +	pte_t *ret = NULL;
>> +	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK |
>> +				       __GFP_REPEAT | __GFP_ZERO);
>> +	if (!page)
>> +		return NULL;
>> +
>> +	spin_lock(&mm->page_table_lock);
>> +	/*
>> +	 * If we find pgtable_page set, we return
>> +	 * the allocated page with single fragement
>> +	 * count.
>> +	 */
>> +	if (likely(!mm->context.pgtable_page)) {
>> +		atomic_set(&page->_count, PTE_FRAG_NR);
>> +		atomic_set(&page->_mapcount, 0);
>> +		mm->context.pgtable_page = page;
>> +	}
>
> .. and in the unlikely case where there *is* a pgtable_page already
> set, what then?  Seems like you should BUG_ON, or at least return NULL
> - as it is you will return the first sub-page of that page again,
> which is very likely in use.


As explained in the comment above, we return with the allocated page
with fragment count set to 1. So we end up having only one fragment. The
other option I had was to to free the allocated page and do a
get_from_cache under the page_table_lock. But since we already allocated
the page, why not use that ?. It also keep the code similar to sparc.


>
>> +	spin_unlock(&mm->page_table_lock);
>> +
>> +	ret = (unsigned long *)page_address(page);
>> +	if (!kernel)
>> +		pgtable_page_ctor(page);
>> +
>> +	return ret;
>> +}
>> +
>> +pte_t *page_table_alloc(struct mm_struct *mm, unsigned long vmaddr, int kernel)
>> +{
>> +	pte_t *pte;
>> +
>> +	pte = get_from_cache(mm);
>> +	if (pte)
>> +		return pte;
>> +
>> +	return __alloc_for_cache(mm, kernel);
>> +}
>> +
>> +void page_table_free(struct mm_struct *mm, unsigned long *table, int kernel)
>> +{
>> +	struct page *page = virt_to_page(table);
>> +	if (put_page_testzero(page)) {
>> +		if (!kernel)
>> +			pgtable_page_dtor(page);
>> +		reset_page_mapcount(page);
>> +		free_hot_cold_page(page, 0);
>> +	}
>> +}
>> +
>> +#ifdef CONFIG_SMP
>> +static void page_table_free_rcu(void *table)
>> +{
>> +	struct page *page = virt_to_page(table);
>> +	if (put_page_testzero(page)) {
>> +		pgtable_page_dtor(page);
>> +		reset_page_mapcount(page);
>> +		free_hot_cold_page(page, 0);
>> +	}
>> +}
>> +
>> +void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift)
>> +{
>> +	unsigned long pgf = (unsigned long)table;
>> +
>> +	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
>> +	pgf |= shift;
>> +	tlb_remove_table(tlb, (void *)pgf);
>> +}
>> +
>> +void __tlb_remove_table(void *_table)
>> +{
>> +	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
>> +	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
>> +
>> +	if (!shift)
>> +		/* PTE page needs special handling */
>> +		page_table_free_rcu(table);
>> +	else {
>> +		BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
>> +		kmem_cache_free(PGT_CACHE(shift), table);
>> +	}
>> +}
>> +#else
>> +void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift)
>> +{
>> +	if (!shift) {
>> +		/* PTE page needs special handling */
>> +		struct page *page = virt_to_page(table);
>> +		if (put_page_testzero(page)) {
>> +			pgtable_page_dtor(page);
>> +			reset_page_mapcount(page);
>> +			free_hot_cold_page(page, 0);
>> +		}
>> +	} else {
>> +		BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
>> +		kmem_cache_free(PGT_CACHE(shift), table);
>> +	}
>> +}
>> +#endif
>> +#endif /* CONFIG_PPC_64K_PAGES */
>
> -- 
> David Gibson			| I'll have my music baroque, and my code
> david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
> 				| _way_ _around_!
> http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
