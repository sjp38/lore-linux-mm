Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A011E6B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 09:29:21 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y190so65514422pgb.3
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 06:29:21 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l30si2476648pgu.347.2017.08.09.06.29.19
        for <linux-mm@kvack.org>;
        Wed, 09 Aug 2017 06:29:20 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v5 4/9] arm64: hugetlb: Add break-before-make logic for contiguous entries
References: <20170802094904.27749-1-punit.agrawal@arm.com>
	<20170802094904.27749-5-punit.agrawal@arm.com>
	<20170807171916.vdplrndrdyeontho@armageddon.cambridge.arm.com>
Date: Wed, 09 Aug 2017 14:29:16 +0100
In-Reply-To: <20170807171916.vdplrndrdyeontho@armageddon.cambridge.arm.com>
	(Catalin Marinas's message of "Mon, 7 Aug 2017 18:19:17 +0100")
Message-ID: <87bmnorhsj.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: will.deacon@arm.com, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>, Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Catalin Marinas <catalin.marinas@arm.com> writes:

> On Wed, Aug 02, 2017 at 10:48:59AM +0100, Punit Agrawal wrote:
>> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
>> index 08deed7c71f0..f2c976464f39 100644
>> --- a/arch/arm64/mm/hugetlbpage.c
>> +++ b/arch/arm64/mm/hugetlbpage.c
>> @@ -68,6 +68,47 @@ static int find_num_contig(struct mm_struct *mm, unsigned long addr,
>>  	return CONT_PTES;
>>  }
>>  
>> +/*
>> + * Changing some bits of contiguous entries requires us to follow a
>> + * Break-Before-Make approach, breaking the whole contiguous set
>> + * before we can change any entries. See ARM DDI 0487A.k_iss10775,
>> + * "Misprogramming of the Contiguous bit", page D4-1762.
>> + *
>> + * This helper performs the break step.
>> + */
>> +static pte_t get_clear_flush(struct mm_struct *mm,
>> +			     unsigned long addr,
>> +			     pte_t *ptep,
>> +			     unsigned long pgsize,
>> +			     unsigned long ncontig)
>> +{
>> +	unsigned long i, saddr = addr;
>> +	struct vm_area_struct vma = { .vm_mm = mm };
>> +	pte_t orig_pte = huge_ptep_get(ptep);
>> +
>> +	/*
>> +	 * If we already have a faulting entry then we don't need
>> +	 * to break before make (there won't be a tlb entry cached).
>> +	 */
>> +	if (!pte_present(orig_pte))
>> +		return orig_pte;
>> +
>> +	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++) {
>> +		pte_t pte = ptep_get_and_clear(mm, addr, ptep);
>> +
>> +		/*
>> +		 * If HW_AFDBM is enabled, then the HW could turn on
>> +		 * the dirty bit for any page in the set, so check
>> +		 * them all.  All hugetlb entries are already young.
>> +		 */
>> +		if (IS_ENABLED(CONFIG_ARM64_HW_AFDBM) && pte_dirty(pte))
>> +			orig_pte = pte_mkdirty(orig_pte);
>> +	}
>> +
>> +	flush_tlb_range(&vma, saddr, addr);
>> +	return orig_pte;
>> +}
>> +
>>  void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>>  			    pte_t *ptep, pte_t pte)
>>  {
>> @@ -93,6 +134,8 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>>  	dpfn = pgsize >> PAGE_SHIFT;
>>  	hugeprot = pte_pgprot(pte);
>>  
>> +	get_clear_flush(mm, addr, ptep, pgsize, ncontig);
>> +
>>  	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn) {
>>  		pr_debug("%s: set pte %p to 0x%llx\n", __func__, ptep,
>>  			 pte_val(pfn_pte(pfn, hugeprot)));
>
> Is there any risk of the huge pte being accessed (from user space on
> another CPU) in the short break-before-make window? Not that we can do
> much about it but just checking.

The calls to set_huge_pte_at are protected by a page table lock. If a
fault is taken on another CPU we'll end up running the following call
sequence

hugetlb_fault()
--> hugetlb_no_page()

which checks if the pte is none after acquiring the page table lock and
backs out of the fault if so.

>
> BTW, it seems a bit overkill to use ptep_get_and_clear() (via
> get_clear_flush) when we just want to zero the entries. Probably not
> much overhead though.

We missed converting huge_ptep_clear_flush() to follow break-before-make
requirement. I'll add a helper to zero out the entries and flush the
range which can be used here and in huge_ptep_clear_flush() as well.

>
>> @@ -222,6 +256,7 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>>  	int ncontig, i, changed = 0;
>>  	size_t pgsize = 0;
>>  	unsigned long pfn = pte_pfn(pte), dpfn;
>> +	pte_t orig_pte;
>>  	pgprot_t hugeprot;
>>  
>>  	if (!pte_cont(pte))
>> @@ -231,10 +266,12 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>>  	dpfn = pgsize >> PAGE_SHIFT;
>>  	hugeprot = pte_pgprot(pte);
>>  
>> -	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn) {
>> -		changed |= ptep_set_access_flags(vma, addr, ptep,
>> -				pfn_pte(pfn, hugeprot), dirty);
>> -	}
>> +	orig_pte = get_clear_flush(vma->vm_mm, addr, ptep, pgsize, ncontig);
>> +	if (!pte_same(orig_pte, pte))
>> +		changed = 1;
>> +
>> +	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn)
>> +		set_pte_at(vma->vm_mm, addr, ptep, pfn_pte(pfn, hugeprot));
>>  
>>  	return changed;
>>  }
>
> If hugeprot isn't dirty but orig_pte became dirty, it looks like we just
> drop such information from the new pte.

We can avoid this by deriving hugeprot from orig_pte instead of
pte. I'll move update the patch to move setting hugeprot after the call
to get_clear_flush().

>
> Same comment here about the window. huge_ptep_set_access_flags() is
> called on a present (huge) pte and we briefly make it invalid. Can the
> mm subsystem cope with a fault on another CPU here? Same for the
> huge_ptep_set_wrprotect() below.

I've checked through the code and can confirm that callers to both
huge_ptep_set_access_flags() and huge_ptep_set_wrprotect() hold the page
table lock. So we should be safe here.

I also checked the get_user_pages_fast (based on offline discussion) and
can confirm that there are checks for p*d_none() in which case the slow
path is taken.

I'll update the patches with the two changes discussed above and
re-post.

Thanks,
Punit

>
>> @@ -244,6 +281,9 @@ void huge_ptep_set_wrprotect(struct mm_struct *mm,
>>  {
>>  	int ncontig, i;
>>  	size_t pgsize;
>> +	pte_t pte = pte_wrprotect(huge_ptep_get(ptep)), orig_pte;
>> +	unsigned long pfn = pte_pfn(pte), dpfn;
>> +	pgprot_t hugeprot;
>>  
>>  	if (!pte_cont(*ptep)) {
>>  		ptep_set_wrprotect(mm, addr, ptep);
>> @@ -251,8 +291,15 @@ void huge_ptep_set_wrprotect(struct mm_struct *mm,
>>  	}
>>  
>>  	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
>> -	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize)
>> -		ptep_set_wrprotect(mm, addr, ptep);
>> +	dpfn = pgsize >> PAGE_SHIFT;
>> +
>> +	orig_pte = get_clear_flush(mm, addr, ptep, pgsize, ncontig);
>> +	if (pte_dirty(orig_pte))
>> +		pte = pte_mkdirty(pte);
>> +
>> +	hugeprot = pte_pgprot(pte);
>> +	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn)
>> +		set_pte_at(mm, addr, ptep, pfn_pte(pfn, hugeprot));
>>  }
>>  
>>  void huge_ptep_clear_flush(struct vm_area_struct *vma,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
