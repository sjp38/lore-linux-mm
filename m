Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE136B0008
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:49:03 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id i16-v6so13694774ybk.21
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:49:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 9si806955qtd.424.2018.04.04.08.49.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 08:49:01 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w34FlbTA050552
	for <linux-mm@kvack.org>; Wed, 4 Apr 2018 11:49:00 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h4xdbts6j-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Apr 2018 11:49:00 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 4 Apr 2018 16:48:57 +0100
Subject: Re: [PATCH v9 11/24] mm: Cache some VMA fields in the vm_fault
 structure
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-12-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1804021523100.249714@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 4 Apr 2018 17:48:46 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1804021523100.249714@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <363acd83-7ef2-f962-ea0e-3672d5e0d5b4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 03/04/2018 00:24, David Rientjes wrote:
> On Tue, 13 Mar 2018, Laurent Dufour wrote:
> 
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index ef6ef0627090..dfa81a638b7c 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -359,6 +359,12 @@ struct vm_fault {
>>  					 * page table to avoid allocation from
>>  					 * atomic context.
>>  					 */
>> +	/*
>> +	 * These entries are required when handling speculative page fault.
>> +	 * This way the page handling is done using consistent field values.
>> +	 */
>> +	unsigned long vma_flags;
>> +	pgprot_t vma_page_prot;
>>  };
>>  
>>  /* page entry size for vm->huge_fault() */
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 446427cafa19..f71db2b42b30 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -3717,6 +3717,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>  				.vma = vma,
>>  				.address = address,
>>  				.flags = flags,
>> +				.vma_flags = vma->vm_flags,
>> +				.vma_page_prot = vma->vm_page_prot,
>>  				/*
>>  				 * Hard to debug if it ends up being
>>  				 * used by a callee that assumes
>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>> index 32314e9e48dd..a946d5306160 100644
>> --- a/mm/khugepaged.c
>> +++ b/mm/khugepaged.c
>> @@ -882,6 +882,8 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
>>  		.flags = FAULT_FLAG_ALLOW_RETRY,
>>  		.pmd = pmd,
>>  		.pgoff = linear_page_index(vma, address),
>> +		.vma_flags = vma->vm_flags,
>> +		.vma_page_prot = vma->vm_page_prot,
>>  	};
>>  
>>  	/* we only decide to swapin, if there is enough young ptes */
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 0200340ef089..46fe92b93682 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2615,7 +2615,7 @@ static int wp_page_copy(struct vm_fault *vmf)
>>  		 * Don't let another task, with possibly unlocked vma,
>>  		 * keep the mlocked page.
>>  		 */
>> -		if (page_copied && (vma->vm_flags & VM_LOCKED)) {
>> +		if (page_copied && (vmf->vma_flags & VM_LOCKED)) {
>>  			lock_page(old_page);	/* LRU manipulation */
>>  			if (PageMlocked(old_page))
>>  				munlock_vma_page(old_page);
> 
> Doesn't wp_page_copy() also need to pass this to anon_vma_prepare() so 
> that find_mergeable_anon_vma() works correctly?

In the case of the spf handler, we check that the vma->anon_vma is not null.
So __anon_vma_prepare(vma) is never called in the context of the SPF handler.

> 
>> @@ -2649,7 +2649,7 @@ static int wp_page_copy(struct vm_fault *vmf)
>>   */
>>  int finish_mkwrite_fault(struct vm_fault *vmf)
>>  {
>> -	WARN_ON_ONCE(!(vmf->vma->vm_flags & VM_SHARED));
>> +	WARN_ON_ONCE(!(vmf->vma_flags & VM_SHARED));
>>  	if (!pte_map_lock(vmf))
>>  		return VM_FAULT_RETRY;
>>  	/*
>> @@ -2751,7 +2751,7 @@ static int do_wp_page(struct vm_fault *vmf)
>>  		 * We should not cow pages in a shared writeable mapping.
>>  		 * Just mark the pages writable and/or call ops->pfn_mkwrite.
>>  		 */
>> -		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
>> +		if ((vmf->vma_flags & (VM_WRITE|VM_SHARED)) ==
>>  				     (VM_WRITE|VM_SHARED))
>>  			return wp_pfn_shared(vmf);
>>  
>> @@ -2798,7 +2798,7 @@ static int do_wp_page(struct vm_fault *vmf)
>>  			return VM_FAULT_WRITE;
>>  		}
>>  		unlock_page(vmf->page);
>> -	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
>> +	} else if (unlikely((vmf->vma_flags & (VM_WRITE|VM_SHARED)) ==
>>  					(VM_WRITE|VM_SHARED))) {
>>  		return wp_page_shared(vmf);
>>  	}
>> @@ -3067,7 +3067,7 @@ int do_swap_page(struct vm_fault *vmf)
>>  
>>  	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
>>  	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
>> -	pte = mk_pte(page, vma->vm_page_prot);
>> +	pte = mk_pte(page, vmf->vma_page_prot);
>>  	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
>>  		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
>>  		vmf->flags &= ~FAULT_FLAG_WRITE;
>> @@ -3093,7 +3093,7 @@ int do_swap_page(struct vm_fault *vmf)
>>  
>>  	swap_free(entry);
>>  	if (mem_cgroup_swap_full(page) ||
>> -	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
>> +	    (vmf->vma_flags & VM_LOCKED) || PageMlocked(page))
>>  		try_to_free_swap(page);
>>  	unlock_page(page);
>>  	if (page != swapcache && swapcache) {
>> @@ -3150,7 +3150,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
>>  	pte_t entry;
>>  
>>  	/* File mapping without ->vm_ops ? */
>> -	if (vma->vm_flags & VM_SHARED)
>> +	if (vmf->vma_flags & VM_SHARED)
>>  		return VM_FAULT_SIGBUS;
>>  
>>  	/*
>> @@ -3174,7 +3174,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
>>  	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
>>  			!mm_forbids_zeropage(vma->vm_mm)) {
>>  		entry = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
>> -						vma->vm_page_prot));
>> +						vmf->vma_page_prot));
>>  		if (!pte_map_lock(vmf))
>>  			return VM_FAULT_RETRY;
>>  		if (!pte_none(*vmf->pte))
>> @@ -3207,8 +3207,8 @@ static int do_anonymous_page(struct vm_fault *vmf)
>>  	 */
>>  	__SetPageUptodate(page);
>>  
>> -	entry = mk_pte(page, vma->vm_page_prot);
>> -	if (vma->vm_flags & VM_WRITE)
>> +	entry = mk_pte(page, vmf->vma_page_prot);
>> +	if (vmf->vma_flags & VM_WRITE)
>>  		entry = pte_mkwrite(pte_mkdirty(entry));
>>  
>>  	if (!pte_map_lock(vmf)) {
>> @@ -3404,7 +3404,7 @@ static int do_set_pmd(struct vm_fault *vmf, struct page *page)
>>  	for (i = 0; i < HPAGE_PMD_NR; i++)
>>  		flush_icache_page(vma, page + i);
>>  
>> -	entry = mk_huge_pmd(page, vma->vm_page_prot);
>> +	entry = mk_huge_pmd(page, vmf->vma_page_prot);
>>  	if (write)
>>  		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
>>  
>> @@ -3478,11 +3478,11 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
>>  		return VM_FAULT_NOPAGE;
>>  
>>  	flush_icache_page(vma, page);
>> -	entry = mk_pte(page, vma->vm_page_prot);
>> +	entry = mk_pte(page, vmf->vma_page_prot);
>>  	if (write)
>>  		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>>  	/* copy-on-write page */
>> -	if (write && !(vma->vm_flags & VM_SHARED)) {
>> +	if (write && !(vmf->vma_flags & VM_SHARED)) {
>>  		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
>>  		page_add_new_anon_rmap(page, vma, vmf->address, false);
>>  		mem_cgroup_commit_charge(page, memcg, false, false);
>> @@ -3521,7 +3521,7 @@ int finish_fault(struct vm_fault *vmf)
>>  
>>  	/* Did we COW the page? */
>>  	if ((vmf->flags & FAULT_FLAG_WRITE) &&
>> -	    !(vmf->vma->vm_flags & VM_SHARED))
>> +	    !(vmf->vma_flags & VM_SHARED))
>>  		page = vmf->cow_page;
>>  	else
>>  		page = vmf->page;
>> @@ -3775,7 +3775,7 @@ static int do_fault(struct vm_fault *vmf)
>>  		ret = VM_FAULT_SIGBUS;
>>  	else if (!(vmf->flags & FAULT_FLAG_WRITE))
>>  		ret = do_read_fault(vmf);
>> -	else if (!(vma->vm_flags & VM_SHARED))
>> +	else if (!(vmf->vma_flags & VM_SHARED))
>>  		ret = do_cow_fault(vmf);
>>  	else
>>  		ret = do_shared_fault(vmf);
>> @@ -3832,7 +3832,7 @@ static int do_numa_page(struct vm_fault *vmf)
>>  	 * accessible ptes, some can allow access by kernel mode.
>>  	 */
>>  	pte = ptep_modify_prot_start(vma->vm_mm, vmf->address, vmf->pte);
>> -	pte = pte_modify(pte, vma->vm_page_prot);
>> +	pte = pte_modify(pte, vmf->vma_page_prot);
>>  	pte = pte_mkyoung(pte);
>>  	if (was_writable)
>>  		pte = pte_mkwrite(pte);
>> @@ -3866,7 +3866,7 @@ static int do_numa_page(struct vm_fault *vmf)
>>  	 * Flag if the page is shared between multiple address spaces. This
>>  	 * is later used when determining whether to group tasks together
>>  	 */
>> -	if (page_mapcount(page) > 1 && (vma->vm_flags & VM_SHARED))
>> +	if (page_mapcount(page) > 1 && (vmf->vma_flags & VM_SHARED))
>>  		flags |= TNF_SHARED;
>>  
>>  	last_cpupid = page_cpupid_last(page);
>> @@ -3911,7 +3911,7 @@ static inline int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
>>  		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PMD);
>>  
>>  	/* COW handled on pte level: split pmd */
>> -	VM_BUG_ON_VMA(vmf->vma->vm_flags & VM_SHARED, vmf->vma);
>> +	VM_BUG_ON_VMA(vmf->vma_flags & VM_SHARED, vmf->vma);
>>  	__split_huge_pmd(vmf->vma, vmf->pmd, vmf->address, false, NULL);
>>  
>>  	return VM_FAULT_FALLBACK;
>> @@ -4058,6 +4058,8 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>>  		.flags = flags,
>>  		.pgoff = linear_page_index(vma, address),
>>  		.gfp_mask = __get_fault_gfp_mask(vma),
>> +		.vma_flags = vma->vm_flags,
>> +		.vma_page_prot = vma->vm_page_prot,
>>  	};
>>  	unsigned int dirty = flags & FAULT_FLAG_WRITE;
>>  	struct mm_struct *mm = vma->vm_mm;
> 
> Don't you also need to do this?

In theory there is no risk there, because if the vma->vm_flags have changed in
our back, the locking of the pte will prevent concurrent update of the pte's
values.
So if a mprotect() call is occuring in parallel, once the vm_flags have been
touched, the pte needs to be modified and this requires the pte lock to be
held. So this will happen after we have revalidated the vma and locked the pte.

This being said, that sounds better to deal with the vmf->vma_flags when the
vmf structure is available so I'll apply the following.

> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -694,9 +694,9 @@ void free_compound_page(struct page *page);
>   * pte_mkwrite.  But get_user_pages can cause write faults for mappings
>   * that do not have writing enabled, when used by access_process_vm.
>   */
> -static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> +static inline pte_t maybe_mkwrite(pte_t pte, unsigned long vma_flags)
>  {
> -	if (likely(vma->vm_flags & VM_WRITE))
> +	if (likely(vma_flags & VM_WRITE))
>  		pte = pte_mkwrite(pte);
>  	return pte;
>  }
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1195,8 +1195,8 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
> 
>  	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
>  		pte_t entry;
> -		entry = mk_pte(pages[i], vma->vm_page_prot);
> -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		entry = mk_pte(pages[i], vmf->vma_page_prot);
> +		entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
>  		memcg = (void *)page_private(pages[i]);
>  		set_page_private(pages[i], 0);
>  		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, false);
> @@ -2169,7 +2169,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  				entry = pte_swp_mksoft_dirty(entry);
>  		} else {
>  			entry = mk_pte(page + i, READ_ONCE(vma->vm_page_prot));
> -			entry = maybe_mkwrite(entry, vma);
> +			entry = maybe_mkwrite(entry, vma->vm_flags);
>  			if (!write)
>  				entry = pte_wrprotect(entry);
>  			if (!young)
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1826,7 +1826,7 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  out_mkwrite:
>  	if (mkwrite) {
>  		entry = pte_mkyoung(entry);
> -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		entry = maybe_mkwrite(pte_mkdirty(entry), vma->vm_flags);
>  	}
> 
>  	set_pte_at(mm, addr, pte, entry);
> @@ -2472,7 +2472,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
> 
>  	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
>  	entry = pte_mkyoung(vmf->orig_pte);
> -	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +	entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
>  	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
>  		update_mmu_cache(vma, vmf->address, vmf->pte);
>  	pte_unmap_unlock(vmf->pte, vmf->ptl);
> @@ -2549,8 +2549,8 @@ static int wp_page_copy(struct vm_fault *vmf)
>  			inc_mm_counter_fast(mm, MM_ANONPAGES);
>  		}
>  		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
> -		entry = mk_pte(new_page, vma->vm_page_prot);
> -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		entry = mk_pte(new_page, vmf->vma_page_prot);
> +		entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
>  		/*
>  		 * Clear the pte entry and flush it first, before updating the
>  		 * pte with the new entry. This will avoid a race condition
> @@ -3069,7 +3069,7 @@ int do_swap_page(struct vm_fault *vmf)
>  	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
>  	pte = mk_pte(page, vmf->vma_page_prot);
>  	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
> -		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
> +		pte = maybe_mkwrite(pte_mkdirty(pte), vmf->vm_flags);
>  		vmf->flags &= ~FAULT_FLAG_WRITE;
>  		ret |= VM_FAULT_WRITE;
>  		exclusive = RMAP_EXCLUSIVE;
> @@ -3481,7 +3481,7 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
>  	flush_icache_page(vma, page);
>  	entry = mk_pte(page, vmf->vma_page_prot);
>  	if (write)
> -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vm_flags);
>  	/* copy-on-write page */
>  	if (write && !(vmf->vma_flags & VM_SHARED)) {
>  		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
> diff --git a/mm/migrate.c b/mm/migrate.c
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -240,7 +240,7 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
>  		 */
>  		entry = pte_to_swp_entry(*pvmw.pte);
>  		if (is_write_migration_entry(entry))
> -			pte = maybe_mkwrite(pte, vma);
> +			pte = maybe_mkwrite(pte, vma->vm_flags);
> 
>  		if (unlikely(is_zone_device_page(new))) {
>  			if (is_device_private_page(new)) {
> 
