Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 00A486B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 07:19:12 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so37615590pab.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 04:19:12 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id ay3si2384704pbc.54.2015.05.07.04.19.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 07 May 2015 04:19:11 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 7 May 2015 21:19:06 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E33B73578048
	for <linux-mm@kvack.org>; Thu,  7 May 2015 21:19:03 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t47BIte644892336
	for <linux-mm@kvack.org>; Thu, 7 May 2015 21:19:03 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t47BIUQB013305
	for <linux-mm@kvack.org>; Thu, 7 May 2015 21:18:31 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 1/2] mm/thp: Split out pmd collpase flush into a seperate functions
In-Reply-To: <20150507092000.GA18516@node.dhcp.inet.fi>
References: <1430983408-24924-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150507092000.GA18516@node.dhcp.inet.fi>
Date: Thu, 07 May 2015 16:48:02 +0530
Message-ID: <87egmsd4b9.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, mpe@ellerman.id.au, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Thu, May 07, 2015 at 12:53:27PM +0530, Aneesh Kumar K.V wrote:
>> After this patch pmdp_* functions operate only on hugepage pte,
>> and not on regular pmd_t values pointing to page table.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  arch/powerpc/include/asm/pgtable-ppc64.h |  4 ++
>>  arch/powerpc/mm/pgtable_64.c             | 76 +++++++++++++++++---------------
>>  include/asm-generic/pgtable.h            | 19 ++++++++
>>  mm/huge_memory.c                         |  2 +-
>>  4 files changed, 65 insertions(+), 36 deletions(-)
>> 
>> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
>> index 43e6ad424c7f..50830c9a2116 100644
>> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
>> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
>> @@ -576,6 +576,10 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
>>  extern void pmdp_splitting_flush(struct vm_area_struct *vma,
>>  				 unsigned long address, pmd_t *pmdp);
>>  
>> +#define __HAVE_ARCH_PMDP_COLLAPSE_FLUSH
>> +extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
>> +				 unsigned long address, pmd_t *pmdp);
>> +
>>  #define __HAVE_ARCH_PGTABLE_DEPOSIT
>>  extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
>>  				       pgtable_t pgtable);
>> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
>> index 59daa5eeec25..9171c1a37290 100644
>> --- a/arch/powerpc/mm/pgtable_64.c
>> +++ b/arch/powerpc/mm/pgtable_64.c
>> @@ -560,41 +560,47 @@ pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
>>  	pmd_t pmd;
>>  
>>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>> -	if (pmd_trans_huge(*pmdp)) {
>> -		pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
>> -	} else {
>> -		/*
>> -		 * khugepaged calls this for normal pmd
>> -		 */
>> -		pmd = *pmdp;
>> -		pmd_clear(pmdp);
>> -		/*
>> -		 * Wait for all pending hash_page to finish. This is needed
>> -		 * in case of subpage collapse. When we collapse normal pages
>> -		 * to hugepage, we first clear the pmd, then invalidate all
>> -		 * the PTE entries. The assumption here is that any low level
>> -		 * page fault will see a none pmd and take the slow path that
>> -		 * will wait on mmap_sem. But we could very well be in a
>> -		 * hash_page with local ptep pointer value. Such a hash page
>> -		 * can result in adding new HPTE entries for normal subpages.
>> -		 * That means we could be modifying the page content as we
>> -		 * copy them to a huge page. So wait for parallel hash_page
>> -		 * to finish before invalidating HPTE entries. We can do this
>> -		 * by sending an IPI to all the cpus and executing a dummy
>> -		 * function there.
>> -		 */
>> -		kick_all_cpus_sync();
>> -		/*
>> -		 * Now invalidate the hpte entries in the range
>> -		 * covered by pmd. This make sure we take a
>> -		 * fault and will find the pmd as none, which will
>> -		 * result in a major fault which takes mmap_sem and
>> -		 * hence wait for collapse to complete. Without this
>> -		 * the __collapse_huge_page_copy can result in copying
>> -		 * the old content.
>> -		 */
>> -		flush_tlb_pmd_range(vma->vm_mm, &pmd, address);
>> -	}
>> +	VM_BUG_ON(!pmd_trans_huge(*pmdp));
>> +	pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
>> +	return pmd;
>
> The patches are in reverse order: you need to change pmdp_get_and_clear
> first otherwise you break bisectability.
> Or better merge patches together.

The first patch is really a cleanup and should not result in code
changes. It just make sure that we use pmdp_* functions only on hugepage
ptes and not on regular pmd_t pointers to pgtable. It avoid the not so
nice if (pmd_trans_huge()) check in the code and allows us to do the
VM_BUG_ON(!pmd_trans_huge(*pmdp)) there. That is really important on
archs like ppc64 where regular pmd format is different from hugepage pte
format.


>
>> +}
>> +
>> +pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
>> +			  pmd_t *pmdp)
>> +{
>> +	pmd_t pmd;
>> +
>> +	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>> +	VM_BUG_ON(pmd_trans_huge(*pmdp));
>> +
>> +	pmd = *pmdp;
>> +	pmd_clear(pmdp);
>> +	/*
>> +	 * Wait for all pending hash_page to finish. This is needed
>> +	 * in case of subpage collapse. When we collapse normal pages
>> +	 * to hugepage, we first clear the pmd, then invalidate all
>> +	 * the PTE entries. The assumption here is that any low level
>> +	 * page fault will see a none pmd and take the slow path that
>> +	 * will wait on mmap_sem. But we could very well be in a
>> +	 * hash_page with local ptep pointer value. Such a hash page
>> +	 * can result in adding new HPTE entries for normal subpages.
>> +	 * That means we could be modifying the page content as we
>> +	 * copy them to a huge page. So wait for parallel hash_page
>> +	 * to finish before invalidating HPTE entries. We can do this
>> +	 * by sending an IPI to all the cpus and executing a dummy
>> +	 * function there.
>> +	 */
>> +	kick_all_cpus_sync();
>> +	/*
>> +	 * Now invalidate the hpte entries in the range
>> +	 * covered by pmd. This make sure we take a
>> +	 * fault and will find the pmd as none, which will
>> +	 * result in a major fault which takes mmap_sem and
>> +	 * hence wait for collapse to complete. Without this
>> +	 * the __collapse_huge_page_copy can result in copying
>> +	 * the old content.
>> +	 */
>> +	flush_tlb_pmd_range(vma->vm_mm, &pmd, address);
>>  	return pmd;
>>  }
>>  
>> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
>> index 39f1d6a2b04d..80e6d415cd57 100644
>> --- a/include/asm-generic/pgtable.h
>> +++ b/include/asm-generic/pgtable.h
>> @@ -189,6 +189,25 @@ extern void pmdp_splitting_flush(struct vm_area_struct *vma,
>>  				 unsigned long address, pmd_t *pmdp);
>>  #endif
>>  
>> +#ifndef __HAVE_ARCH_PMDP_COLLAPSE_FLUSH
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
>> +				       unsigned long address,
>> +				       pmd_t *pmdp)
>> +{
>> +	return pmdp_clear_flush(vma, address, pmdp);
>> +}
>> +#else
>> +static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
>> +				       unsigned long address,
>> +				       pmd_t *pmdp)
>> +{
>> +	BUILD_BUG();
>> +	return __pmd(0);
>> +}
>> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>> +#endif
>> +
>>  #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
>>  extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
>>  				       pgtable_t pgtable);
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 078832cf3636..88f695a4e38b 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2499,7 +2499,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>>  	 * huge and small TLB entries for the same virtual address
>>  	 * to avoid the risk of CPU bugs in that area.
>>  	 */
>> -	_pmd = pmdp_clear_flush(vma, address, pmd);
>> +	_pmd = pmdp_collapse_flush(vma, address, pmd);
>
> Why? pmdp_clear_flush() does kick_all_cpus_sync() already.

Here we are clearing the regular pmd_t and for ppc64 that means we need
to invalidate all the normal page pte mappings we already have inserted
in the hardware hash page table. But before doing that we need to make
sure there are no parallel hash page table insert going on. So we need
to do a kick_all_cpus_sync() before flushing the older hash table
entries. By moving this to a seperate function we capture these details
nicely.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
