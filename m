Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5OHGrLe011159
	for <linux-mm@kvack.org>; Tue, 24 Jun 2008 13:16:53 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5OHGqZi950354
	for <linux-mm@kvack.org>; Tue, 24 Jun 2008 13:16:53 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5OHGnas023485
	for <linux-mm@kvack.org>; Tue, 24 Jun 2008 11:16:49 -0600
Message-ID: <48612C0E.2060800@linux.vnet.ibm.com>
Date: Tue, 24 Jun 2008 12:17:02 -0500
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] powerpc: support multiple huge page sizes
References: <4829CAC3.30900@us.ibm.com> <4829CF07.3030408@us.ibm.com> <20080624025444.GA6507@wotan.suse.de>
In-Reply-To: <20080624025444.GA6507@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linuxppc-dev <linuxppc-dev@ozlabs.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Paul Mackerras <paulus@samba.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Tue, May 13, 2008 at 12:25:27PM -0500, Jon Tollefson wrote:
>   
>> Instead of using the variable mmu_huge_psize to keep track of the huge
>> page size we use an array of MMU_PAGE_* values.  For each supported
>> huge page size we need to know the hugepte_shift value and have a
>> pgtable_cache.  The hstate or an mmu_huge_psizes index is passed to
>> functions so that they know which huge page size they should use.
>>
>> The hugepage sizes 16M and 64K are setup(if available on the
>> hardware) so that they don't have to be set on the boot cmd line in
>> order to use them.  The number of 16G pages have to be specified at
>> boot-time though (e.g. hugepagesz=16G hugepages=5).
>>
>>
>> Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
>> ---
>>
>> @@ -150,17 +191,25 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned 
>> long addr)
>> 	pud_t *pu;
>> 	pmd_t *pm;
>>
>> -	BUG_ON(get_slice_psize(mm, addr) != mmu_huge_psize);
>> +	unsigned int psize;
>> +	unsigned int shift;
>> +	unsigned long sz;
>> +	struct hstate *hstate;
>> +	psize = get_slice_psize(mm, addr);
>> +	shift = mmu_psize_to_shift(psize);
>> +	sz = ((1UL) << shift);
>> +	hstate = size_to_hstate(sz);
>>
>> -	addr &= HPAGE_MASK;
>> +	addr &= hstate->mask;
>>
>> 	pg = pgd_offset(mm, addr);
>> 	if (!pgd_none(*pg)) {
>> 		pu = pud_offset(pg, addr);
>> 		if (!pud_none(*pu)) {
>> -			pm = hpmd_offset(pu, addr);
>> +			pm = hpmd_offset(pu, addr, hstate);
>> 			if (!pmd_none(*pm))
>> -				return hugepte_offset((hugepd_t *)pm, addr);
>> +				return hugepte_offset((hugepd_t *)pm, addr,
>> +						      hstate);
>> 		}
>> 	}
>>     
>
> Hi Jon,
>
> I just noticed in a few places like this, you might be doing more work
> than really needed to get the HPAGE_MASK.
>   
I would love to be able to simplify it.
> For a first-pass conversion, this is the right way to go (just manually
> replace hugepage constants with hstate-> equivalents). However in this
> case if you already know the page size, you should be able to work out
> the shift from there, I think? That way you can avoid the size_to_hstate
> call completely.
>   
Something like the following?

+	addr &= ~(sz - 1);

Is that faster then just pulling it out of hstate?
I still need to locate hstate, but I guess if the mask is calculated
this way the locate could be pushed further into the function so that it
isn't done if it isn't always needed.
> Anyway, just something to consider.
>
> Thanks,
> Nick
>   
Thank you for looking at the code.

Jon

>> @@ -173,16 +222,20 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned 
>> long addr, unsigned long sz
>> 	pud_t *pu;
>> 	pmd_t *pm;
>> 	hugepd_t *hpdp = NULL;
>> +	struct hstate *hstate;
>> +	unsigned int psize;
>> +	hstate = size_to_hstate(sz);
>>
>> -	BUG_ON(get_slice_psize(mm, addr) != mmu_huge_psize);
>> +	psize = get_slice_psize(mm, addr);
>> +	BUG_ON(!mmu_huge_psizes[psize]);
>>
>> -	addr &= HPAGE_MASK;
>> +	addr &= hstate->mask;
>>
>> 	pg = pgd_offset(mm, addr);
>> 	pu = pud_alloc(mm, pg, addr);
>>
>> 	if (pu) {
>> -		pm = hpmd_alloc(mm, pu, addr);
>> +		pm = hpmd_alloc(mm, pu, addr, hstate);
>> 		if (pm)
>> 			hpdp = (hugepd_t *)pm;
>> 	}
>> @@ -190,10 +243,10 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned 
>> long addr, unsigned long sz
>> 	if (! hpdp)
>> 		return NULL;
>>
>> -	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr))
>> +	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr, psize))
>> 		return NULL;
>>
>> -	return hugepte_offset(hpdp, addr);
>> +	return hugepte_offset(hpdp, addr, hstate);
>> }
>>
>> int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
>> @@ -201,19 +254,22 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned 
>> long *addr, pte_t *ptep)
>> 	return 0;
>> }
>>
>> -static void free_hugepte_range(struct mmu_gather *tlb, hugepd_t *hpdp)
>> +static void free_hugepte_range(struct mmu_gather *tlb, hugepd_t *hpdp,
>> +			       unsigned int psize)
>> {
>> 	pte_t *hugepte = hugepd_page(*hpdp);
>>
>> 	hpdp->pd = 0;
>> 	tlb->need_flush = 1;
>> -	pgtable_free_tlb(tlb, pgtable_free_cache(hugepte, HUGEPTE_CACHE_NUM,
>> +	pgtable_free_tlb(tlb, pgtable_free_cache(hugepte,
>> +						 HUGEPTE_CACHE_NUM+psize-1,
>> 						 PGF_CACHENUM_MASK));
>> }
>>
>> static void hugetlb_free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
>> 				   unsigned long addr, unsigned long end,
>> -				   unsigned long floor, unsigned long 
>> ceiling)
>> +				   unsigned long floor, unsigned long 
>> ceiling,
>> +				   unsigned int psize)
>> {
>> 	pmd_t *pmd;
>> 	unsigned long next;
>> @@ -225,7 +281,7 @@ static void hugetlb_free_pmd_range(struct mmu_gather 
>> *tlb, pud_t *pud,
>> 		next = pmd_addr_end(addr, end);
>> 		if (pmd_none(*pmd))
>> 			continue;
>> -		free_hugepte_range(tlb, (hugepd_t *)pmd);
>> +		free_hugepte_range(tlb, (hugepd_t *)pmd, psize);
>> 	} while (pmd++, addr = next, addr != end);
>>
>> 	start &= PUD_MASK;
>> @@ -251,6 +307,9 @@ static void hugetlb_free_pud_range(struct mmu_gather 
>> *tlb, pgd_t *pgd,
>> 	pud_t *pud;
>> 	unsigned long next;
>> 	unsigned long start;
>> +	unsigned int shift;
>> +	unsigned int psize = get_slice_psize(tlb->mm, addr);
>> +	shift = mmu_psize_to_shift(psize);
>>
>> 	start = addr;
>> 	pud = pud_offset(pgd, addr);
>> @@ -259,16 +318,18 @@ static void hugetlb_free_pud_range(struct mmu_gather 
>> *tlb, pgd_t *pgd,
>> #ifdef CONFIG_PPC_64K_PAGES
>> 		if (pud_none_or_clear_bad(pud))
>> 			continue;
>> -		hugetlb_free_pmd_range(tlb, pud, addr, next, floor, ceiling);
>> +		hugetlb_free_pmd_range(tlb, pud, addr, next, floor, ceiling,
>> +				       psize);
>> #else
>> -		if (HPAGE_SHIFT == PAGE_SHIFT_64K) {
>> +		if (shift == PAGE_SHIFT_64K) {
>> 			if (pud_none_or_clear_bad(pud))
>> 				continue;
>> -			hugetlb_free_pmd_range(tlb, pud, addr, next, floor, 
>> ceiling);
>> +			hugetlb_free_pmd_range(tlb, pud, addr, next, floor,
>> +					       ceiling, psize);
>> 		} else {
>> 			if (pud_none(*pud))
>> 				continue;
>> -			free_hugepte_range(tlb, (hugepd_t *)pud);
>> +			free_hugepte_range(tlb, (hugepd_t *)pud, psize);
>> 		}
>> #endif
>> 	} while (pud++, addr = next, addr != end);
>> @@ -336,27 +397,29 @@ void hugetlb_free_pgd_range(struct mmu_gather **tlb,
>> 	 * now has no other vmas using it, so can be freed, we don't
>> 	 * bother to round floor or end up - the tests don't need that.
>> 	 */
>> +	unsigned int psize = get_slice_psize((*tlb)->mm, addr);
>>
>> -	addr &= HUGEPD_MASK;
>> +	addr &= HUGEPD_MASK(psize);
>> 	if (addr < floor) {
>> -		addr += HUGEPD_SIZE;
>> +		addr += HUGEPD_SIZE(psize);
>> 		if (!addr)
>> 			return;
>> 	}
>> 	if (ceiling) {
>> -		ceiling &= HUGEPD_MASK;
>> +		ceiling &= HUGEPD_MASK(psize);
>> 		if (!ceiling)
>> 			return;
>> 	}
>> 	if (end - 1 > ceiling - 1)
>> -		end -= HUGEPD_SIZE;
>> +		end -= HUGEPD_SIZE(psize);
>> 	if (addr > end - 1)
>> 		return;
>>
>> 	start = addr;
>> 	pgd = pgd_offset((*tlb)->mm, addr);
>> 	do {
>> -		BUG_ON(get_slice_psize((*tlb)->mm, addr) != mmu_huge_psize);
>> +		psize = get_slice_psize((*tlb)->mm, addr);
>> +		BUG_ON(!mmu_huge_psizes[psize]);
>> 		next = pgd_addr_end(addr, end);
>> 		if (pgd_none_or_clear_bad(pgd))
>> 			continue;
>> @@ -373,7 +436,12 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned 
>> long addr,
>> 		 * necessary anymore if we make hpte_need_flush() get the
>> 		 * page size from the slices
>> 		 */
>> -		pte_update(mm, addr & HPAGE_MASK, ptep, ~0UL, 1);
>> +		unsigned int psize = get_slice_psize(mm, addr);
>> +		unsigned int shift = mmu_psize_to_shift(psize);
>> +		unsigned long sz;
>> +		sz = ((1UL) << shift);
>> +		struct hstate *hstate = size_to_hstate(sz);
>> +		pte_update(mm, addr & hstate->mask, ptep, ~0UL, 1);
>> 	}
>> 	*ptep = __pte(pte_val(pte) & ~_PAGE_HPTEFLAGS);
>> }
>> @@ -390,14 +458,19 @@ follow_huge_addr(struct mm_struct *mm, unsigned long 
>> address, int write)
>> {
>> 	pte_t *ptep;
>> 	struct page *page;
>> +	unsigned int mmu_psize = get_slice_psize(mm, address);
>>
>> -	if (get_slice_psize(mm, address) != mmu_huge_psize)
>> +	/* Verify it is a huge page else bail. */
>> +	if (!mmu_huge_psizes[mmu_psize])
>> 		return ERR_PTR(-EINVAL);
>>
>> 	ptep = huge_pte_offset(mm, address);
>> 	page = pte_page(*ptep);
>> -	if (page)
>> -		page += (address % HPAGE_SIZE) / PAGE_SIZE;
>> +	if (page) {
>> +		unsigned int shift = mmu_psize_to_shift(mmu_psize);
>> +		unsigned long sz = ((1UL) << shift);
>> +		page += (address % sz) / PAGE_SIZE;
>> +	}
>>
>> 	return page;
>> }
>> @@ -425,15 +498,16 @@ unsigned long hugetlb_get_unmapped_area(struct file 
>> *file, unsigned long addr,
>> 					unsigned long len, unsigned long 
>> 					pgoff,
>> 					unsigned long flags)
>> {
>> -	return slice_get_unmapped_area(addr, len, flags,
>> -				       mmu_huge_psize, 1, 0);
>> +	struct hstate *hstate = hstate_file(file);
>> +	int mmu_psize = shift_to_mmu_psize(huge_page_shift(hstate));
>> +	return slice_get_unmapped_area(addr, len, flags, mmu_psize, 1, 0);
>> }
>>
>> /*
>>  * Called by asm hashtable.S for doing lazy icache flush
>>  */
>> static unsigned int hash_huge_page_do_lazy_icache(unsigned long rflags,
>> -						  pte_t pte, int trap)
>> +					pte_t pte, int trap, unsigned long 
>> sz)
>> {
>> 	struct page *page;
>> 	int i;
>> @@ -446,7 +520,7 @@ static unsigned int 
>> hash_huge_page_do_lazy_icache(unsigned long rflags,
>> 	/* page is dirty */
>> 	if (!test_bit(PG_arch_1, &page->flags) && !PageReserved(page)) {
>> 		if (trap == 0x400) {
>> -			for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++)
>> +			for (i = 0; i < (sz / PAGE_SIZE); i++)
>> 				__flush_dcache_icache(page_address(page+i));
>> 			set_bit(PG_arch_1, &page->flags);
>> 		} else {
>> @@ -466,7 +540,12 @@ int hash_huge_page(struct mm_struct *mm, unsigned long 
>> access,
>> 	long slot;
>> 	int err = 1;
>> 	int ssize = user_segment_size(ea);
>> +	unsigned int mmu_psize;
>> +	int shift;
>> +	mmu_psize = get_slice_psize(mm, ea);
>>
>> +	if(!mmu_huge_psizes[mmu_psize])
>> +		goto out;
>> 	ptep = huge_pte_offset(mm, ea);
>>
>> 	/* Search the Linux page table for a match with va */
>> @@ -510,30 +589,32 @@ int hash_huge_page(struct mm_struct *mm, unsigned 
>> long access,
>> 	rflags = 0x2 | (!(new_pte & _PAGE_RW));
>>  	/* _PAGE_EXEC -> HW_NO_EXEC since it's inverted */
>> 	rflags |= ((new_pte & _PAGE_EXEC) ? 0 : HPTE_R_N);
>> +	shift = mmu_psize_to_shift(mmu_psize);
>> +	unsigned long sz = ((1UL) << shift);
>> 	if (!cpu_has_feature(CPU_FTR_COHERENT_ICACHE))
>> 		/* No CPU has hugepages but lacks no execute, so we
>> 		 * don't need to worry about that case */
>> 		rflags = hash_huge_page_do_lazy_icache(rflags, 
>> 		__pte(old_pte),
>> -						       trap);
>> +						       trap, sz);
>>
>> 	/* Check if pte already has an hpte (case 2) */
>> 	if (unlikely(old_pte & _PAGE_HASHPTE)) {
>> 		/* There MIGHT be an HPTE for this pte */
>> 		unsigned long hash, slot;
>>
>> -		hash = hpt_hash(va, HPAGE_SHIFT, ssize);
>> +		hash = hpt_hash(va, shift, ssize);
>> 		if (old_pte & _PAGE_F_SECOND)
>> 			hash = ~hash;
>> 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
>> 		slot += (old_pte & _PAGE_F_GIX) >> 12;
>>
>> -		if (ppc_md.hpte_updatepp(slot, rflags, va, mmu_huge_psize,
>> +		if (ppc_md.hpte_updatepp(slot, rflags, va, mmu_psize,
>> 					 ssize, local) == -1)
>> 			old_pte &= ~_PAGE_HPTEFLAGS;
>> 	}
>>
>> 	if (likely(!(old_pte & _PAGE_HASHPTE))) {
>> -		unsigned long hash = hpt_hash(va, HPAGE_SHIFT, ssize);
>> +		unsigned long hash = hpt_hash(va, shift, ssize);
>> 		unsigned long hpte_group;
>>
>> 		pa = pte_pfn(__pte(old_pte)) << PAGE_SHIFT;
>> @@ -552,7 +633,7 @@ repeat:
>>
>> 		/* Insert into the hash table, primary slot */
>> 		slot = ppc_md.hpte_insert(hpte_group, va, pa, rflags, 0,
>> -					  mmu_huge_psize, ssize);
>> +					  mmu_psize, ssize);
>>
>> 		/* Primary is full, try the secondary */
>> 		if (unlikely(slot == -1)) {
>> @@ -560,7 +641,7 @@ repeat:
>> 				      HPTES_PER_GROUP) & ~0x7UL; 
>> 			slot = ppc_md.hpte_insert(hpte_group, va, pa, rflags,
>> 						  HPTE_V_SECONDARY,
>> -						  mmu_huge_psize, ssize);
>> +						  mmu_psize, ssize);
>> 			if (slot == -1) {
>> 				if (mftb() & 0x1)
>> 					hpte_group = ((hash & 
>> 					htab_hash_mask) *
>> @@ -597,35 +678,34 @@ void set_huge_psize(int psize)
>> 		(mmu_psize_defs[psize].shift > MIN_HUGEPTE_SHIFT ||
>> 		 mmu_psize_defs[psize].shift == PAGE_SHIFT_64K ||
>> 		 mmu_psize_defs[psize].shift == PAGE_SHIFT_16G)) {
>> -		/* Return if huge page size is the same as the
>> -		 * base page size. */
>> -		if (mmu_psize_defs[psize].shift == PAGE_SHIFT)
>> +		/* Return if huge page size has already been setup or is the
>> +		 * same as the base page size. */
>> +		if (mmu_huge_psizes[psize] ||
>> +		   mmu_psize_defs[psize].shift == PAGE_SHIFT)
>> 			return;
>> +		huge_add_hstate(mmu_psize_defs[psize].shift - PAGE_SHIFT);
>>
>> -		HPAGE_SHIFT = mmu_psize_defs[psize].shift;
>> -		mmu_huge_psize = psize;
>> -
>> -		switch (HPAGE_SHIFT) {
>> +		switch (mmu_psize_defs[psize].shift) {
>> 		case PAGE_SHIFT_64K:
>> 		    /* We only allow 64k hpages with 4k base page,
>> 		     * which was checked above, and always put them
>> 		     * at the PMD */
>> -		    hugepte_shift = PMD_SHIFT;
>> +		    hugepte_shift[psize] = PMD_SHIFT;
>> 		    break;
>> 		case PAGE_SHIFT_16M:
>> 		    /* 16M pages can be at two different levels
>> 		     * of pagestables based on base page size */
>> 		    if (PAGE_SHIFT == PAGE_SHIFT_64K)
>> -			    hugepte_shift = PMD_SHIFT;
>> +			    hugepte_shift[psize] = PMD_SHIFT;
>> 		    else /* 4k base page */
>> -			    hugepte_shift = PUD_SHIFT;
>> +			    hugepte_shift[psize] = PUD_SHIFT;
>> 		    break;
>> 		case PAGE_SHIFT_16G:
>> 		    /* 16G pages are always at PGD level */
>> -		    hugepte_shift = PGDIR_SHIFT;
>> +		    hugepte_shift[psize] = PGDIR_SHIFT;
>> 		    break;
>> 		}
>> -		hugepte_shift -= HPAGE_SHIFT;
>> +		hugepte_shift[psize] -= mmu_psize_defs[psize].shift;
>> 	} else
>> 		HPAGE_SHIFT = 0;
>> }
>> @@ -633,30 +713,15 @@ void set_huge_psize(int psize)
>> static int __init hugepage_setup_sz(char *str)
>> {
>> 	unsigned long long size;
>> -	int mmu_psize = -1;
>> +	int mmu_psize;
>> 	int shift;
>>
>> 	size = memparse(str, &str);
>>
>> 	shift = __ffs(size);
>> -	switch (shift) {
>> -#ifndef CONFIG_PPC_64K_PAGES
>> -	case PAGE_SHIFT_64K:
>> -		mmu_psize = MMU_PAGE_64K;
>> -		break;
>> -#endif
>> -	case PAGE_SHIFT_16M:
>> -		mmu_psize = MMU_PAGE_16M;
>> -		break;
>> -	case PAGE_SHIFT_16G:
>> -		mmu_psize = MMU_PAGE_16G;
>> -		break;
>> -	}
>> -
>> -	if (mmu_psize >= 0 && mmu_psize_defs[mmu_psize].shift) {
>> +	mmu_psize = shift_to_mmu_psize(shift);
>> +	if (mmu_psize >= 0 && mmu_psize_defs[mmu_psize].shift)
>> 		set_huge_psize(mmu_psize);
>> -		huge_add_hstate(shift - PAGE_SHIFT);
>> -	}
>> 	else
>> 		printk(KERN_WARNING "Invalid huge page size 
>> 		specified(%llu)\n", size);
>>
>> @@ -671,16 +736,30 @@ static void zero_ctor(struct kmem_cache *cache, void 
>> *addr)
>>
>> static int __init hugetlbpage_init(void)
>> {
>> +	unsigned int psize;
>> 	if (!cpu_has_feature(CPU_FTR_16M_PAGE))
>> 		return -ENODEV;
>> -
>> -	huge_pgtable_cache = kmem_cache_create("hugepte_cache",
>> -					       HUGEPTE_TABLE_SIZE,
>> -					       HUGEPTE_TABLE_SIZE,
>> -					       0,
>> -					       zero_ctor);
>> -	if (! huge_pgtable_cache)
>> -		panic("hugetlbpage_init(): could not create hugepte 
>> cache\n");
>> +	/* Add supported huge page sizes.  Need to change HUGE_MAX_HSTATE
>> +	 * and adjust PTE_NONCACHE_NUM if the number of supported huge page
>> +	 * sizes changes.
>> +	 */
>> +	set_huge_psize(MMU_PAGE_16M);
>> +	set_huge_psize(MMU_PAGE_64K);
>> +	set_huge_psize(MMU_PAGE_16G);
>> +
>> +	for (psize = 0; psize < MMU_PAGE_COUNT; ++psize) {
>> +		if (mmu_huge_psizes[psize]) {
>> +			huge_pgtable_cache(psize) = kmem_cache_create(
>> +						HUGEPTE_CACHE_NAME(psize),
>> +						HUGEPTE_TABLE_SIZE(psize),
>> +						HUGEPTE_TABLE_SIZE(psize),
>> +						0,
>> +						zero_ctor);
>> +			if (!huge_pgtable_cache(psize))
>> +				panic("hugetlbpage_init(): could not create 
>> %s"\
>> +				      "\n", HUGEPTE_CACHE_NAME(psize));
>> +		}
>> +	}
>>
>> 	return 0;
>> }
>> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
>> index c0f5cff..55588d5 100644
>> --- a/arch/powerpc/mm/init_64.c
>> +++ b/arch/powerpc/mm/init_64.c
>> @@ -151,10 +151,10 @@ static const char 
>> *pgtable_cache_name[ARRAY_SIZE(pgtable_cache_size)] = {
>> };
>>
>> #ifdef CONFIG_HUGETLB_PAGE
>> -/* Hugepages need one extra cache, initialized in hugetlbpage.c.  We
>> - * can't put into the tables above, because HPAGE_SHIFT is not compile
>> - * time constant. */
>> -struct kmem_cache *pgtable_cache[ARRAY_SIZE(pgtable_cache_size)+1];
>> +/* Hugepages need an extra cache per hugepagesize, initialized in
>> + * hugetlbpage.c.  We can't put into the tables above, because HPAGE_SHIFT
>> + * is not compile time constant. */
>> +struct kmem_cache 
>> *pgtable_cache[ARRAY_SIZE(pgtable_cache_size)+MMU_PAGE_COUNT];
>> #else
>> struct kmem_cache *pgtable_cache[ARRAY_SIZE(pgtable_cache_size)];
>> #endif
>> diff --git a/arch/powerpc/mm/tlb_64.c b/arch/powerpc/mm/tlb_64.c
>> index e2d867c..8d79e16 100644
>> --- a/arch/powerpc/mm/tlb_64.c
>> +++ b/arch/powerpc/mm/tlb_64.c
>> @@ -150,7 +150,7 @@ void hpte_need_flush(struct mm_struct *mm, unsigned 
>> long addr,
>> 	 */
>> 	if (huge) {
>> #ifdef CONFIG_HUGETLB_PAGE
>> -		psize = mmu_huge_psize;
>> +		psize = get_slice_psize(mm, addr);;
>> #else
>> 		BUG();
>> 		psize = pte_pagesize_index(mm, addr, pte); /* shutup gcc */
>> diff --git a/include/asm-powerpc/mmu-hash64.h 
>> b/include/asm-powerpc/mmu-hash64.h
>> index db1276a..63b0fa5 100644
>> --- a/include/asm-powerpc/mmu-hash64.h
>> +++ b/include/asm-powerpc/mmu-hash64.h
>> @@ -192,9 +192,9 @@ extern int mmu_ci_restrictions;
>>
>> #ifdef CONFIG_HUGETLB_PAGE
>> /*
>> - * The page size index of the huge pages for use by hugetlbfs
>> + * The page size indexes of the huge pages for use by hugetlbfs
>>  */
>> -extern int mmu_huge_psize;
>> +extern unsigned int mmu_huge_psizes[MMU_PAGE_COUNT];
>>
>> #endif /* CONFIG_HUGETLB_PAGE */
>>
>> diff --git a/include/asm-powerpc/page_64.h b/include/asm-powerpc/page_64.h
>> index 67834ea..bdf453b 100644
>> --- a/include/asm-powerpc/page_64.h
>> +++ b/include/asm-powerpc/page_64.h
>> @@ -90,6 +90,7 @@ extern unsigned int HPAGE_SHIFT;
>> #define HPAGE_SIZE		((1UL) << HPAGE_SHIFT)
>> #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
>> #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
>> +#define HUGE_MAX_HSTATE		3
>>
>> #endif /* __ASSEMBLY__ */
>>
>> diff --git a/include/asm-powerpc/pgalloc-64.h 
>> b/include/asm-powerpc/pgalloc-64.h
>> index 6898099..812a1d8 100644
>> --- a/include/asm-powerpc/pgalloc-64.h
>> +++ b/include/asm-powerpc/pgalloc-64.h
>> @@ -22,7 +22,7 @@ extern struct kmem_cache *pgtable_cache[];
>> #define PUD_CACHE_NUM		1
>> #define PMD_CACHE_NUM		1
>> #define HUGEPTE_CACHE_NUM	2
>> -#define PTE_NONCACHE_NUM	3  /* from GFP rather than kmem_cache */
>> +#define PTE_NONCACHE_NUM	7  /* from GFP rather than kmem_cache */
>>
>> static inline pgd_t *pgd_alloc(struct mm_struct *mm)
>> {
>> @@ -119,7 +119,7 @@ static inline void pte_free(struct mm_struct *mm, 
>> pgtable_t ptepage)
>> 	__free_page(ptepage);
>> }
>>
>> -#define PGF_CACHENUM_MASK	0x3
>> +#define PGF_CACHENUM_MASK	0x7
>>
>> typedef struct pgtable_free {
>> 	unsigned long val;
>>
>>     

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
