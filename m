Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78F056B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 03:47:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so347918458pfb.3
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 00:47:01 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id ey9si33154176pab.188.2016.09.06.00.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 00:47:00 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id g202so11002226pfb.1
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 00:47:00 -0700 (PDT)
Subject: Re: [RESEND][v2][PATCH] KVM: PPC: Book3S HV: Migrate pinned pages out
 of CMA
References: <20160714042536.GG18277@balbir.ozlabs.ibm.com>
 <87vay9pogi.fsf@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <ff427d5f-4ce0-2a47-bf5a-04cd4641ff84@gmail.com>
Date: Tue, 6 Sep 2016 17:46:53 +1000
MIME-Version: 1.0
In-Reply-To: <87vay9pogi.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>



On 06/09/16 15:49, Aneesh Kumar K.V wrote:
> Balbir Singh <bsingharora@gmail.com> writes:
> 
>> From: Balbir Singh <bsingharora@gmail.com>
>> Subject: [RESEND][v2][PATCH] KVM: PPC: Book3S HV: Migrate pinned pages out of CMA
>>
>> When PCI Device pass-through is enabled via VFIO, KVM-PPC will
>> pin pages using get_user_pages_fast(). One of the downsides of
>> the pinning is that the page could be in CMA region. The CMA
>> region is used for other allocations like the hash page table.
>> Ideally we want the pinned pages to be from non CMA region.
>>
>> This patch (currently only for KVM PPC with VFIO) forcefully
>> migrates the pages out (huge pages are omitted for the moment).
>> There are more efficient ways of doing this, but that might
>> be elaborate and might impact a larger audience beyond just
>> the kvm ppc implementation.
>>
>> The magic is in new_iommu_non_cma_page() which allocates the
>> new page from a non CMA region.
>>
>> I've tested the patches lightly at my end, but there might be bugs
>> For example if after lru_add_drain(), the page is not isolated
>> is this a BUG?
>>
>> Previous discussion was at
>> http://permalink.gmane.org/gmane.linux.kernel.mm/136738
>>
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Cc: Paul Mackerras <paulus@ozlabs.org>
>> Cc: Alexey Kardashevskiy <aik@ozlabs.ru>
>>
>> Signed-off-by: Balbir Singh <bsingharora@gmail.com>
>> ---
>>  arch/powerpc/include/asm/mmu_context.h |  1 +
>>  arch/powerpc/mm/mmu_context_iommu.c    | 80 ++++++++++++++++++++++++++++++++--
>>  2 files changed, 77 insertions(+), 4 deletions(-)
>>
>> diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
>> index 9d2cd0c..475d1be 100644
>> --- a/arch/powerpc/include/asm/mmu_context.h
>> +++ b/arch/powerpc/include/asm/mmu_context.h
>> @@ -18,6 +18,7 @@ extern void destroy_context(struct mm_struct *mm);
>>  #ifdef CONFIG_SPAPR_TCE_IOMMU
>>  struct mm_iommu_table_group_mem_t;
>>  
>> +extern int isolate_lru_page(struct page *page);	/* from internal.h */
>>  extern bool mm_iommu_preregistered(void);
>>  extern long mm_iommu_get(unsigned long ua, unsigned long entries,
>>  		struct mm_iommu_table_group_mem_t **pmem);
>> diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
>> index da6a216..c18f742 100644
>> --- a/arch/powerpc/mm/mmu_context_iommu.c
>> +++ b/arch/powerpc/mm/mmu_context_iommu.c
>> @@ -15,6 +15,9 @@
>>  #include <linux/rculist.h>
>>  #include <linux/vmalloc.h>
>>  #include <linux/mutex.h>
>> +#include <linux/migrate.h>
>> +#include <linux/hugetlb.h>
>> +#include <linux/swap.h>
>>  #include <asm/mmu_context.h>
>>  
>>  static DEFINE_MUTEX(mem_list_mutex);
>> @@ -72,6 +75,54 @@ bool mm_iommu_preregistered(void)
>>  }
>>  EXPORT_SYMBOL_GPL(mm_iommu_preregistered);
>>  
>> +/*
>> + * Taken from alloc_migrate_target with changes to remove CMA allocations
>> + */
>> +struct page *new_iommu_non_cma_page(struct page *page, unsigned long private,
>> +					int **resultp)
>> +{
>> +	gfp_t gfp_mask = GFP_USER;
>> +	struct page *new_page;
>> +
>> +	if (PageHuge(page) || PageTransHuge(page) || PageCompound(page))
>> +		return NULL;
> 
> Doesn't a PageCompound check cover all ?

Yes, I was being overly conservative with the checks

> 
> 
>> +
>> +	if (PageHighMem(page))
>> +		gfp_mask |= __GFP_HIGHMEM;
>> +
>> +	/*
>> +	 * We don't want the allocation to force an OOM if possibe
>> +	 */
>> +	new_page = alloc_page(gfp_mask | __GFP_NORETRY | __GFP_NOWARN);
>> +	return new_page;
>> +}
>> +
>> +static int mm_iommu_move_page_from_cma(struct page *page)
>> +{
>> +	int ret;
>> +	LIST_HEAD(cma_migrate_pages);
>> +
>> +	/* Ignore huge pages for now */
>> +	if (PageHuge(page) || PageTransHuge(page) || PageCompound(page))
>> +		return -EBUSY;
>> +
>> +	lru_add_drain();
> 
> I guess I asked this last time. Shouldn't this be lru_add_drain_all() ?
> What if the page is in other cpu's pagevec ?

lru_add_drain_all() is too expensive for a per-page migration. This is best
effort. If it is on the pagevec of another CPU, we skip it -- see v3

> 
> 
>> +	ret = isolate_lru_page(page);
>> +	if (ret)
>> +		get_page(page); /* Potential BUG? */
>> +
>> +	list_add(&page->lru, &cma_migrate_pages);
> 
> Is that correct ? if we failed the isolate_lru_page(), can we be sure we
> are not on lru at all ? ie, what if the page was on other cpu pagevec ?
> 
> 

Fixed in v3

>> +	put_page(page); /* Drop the gup reference */
>> +
> 
> Where is get user page (gup) here ? . I guess you mean drop the
> reference taken above ?
> 

I say gup, because we'll do gup after this point if migration fails
and that we reacquire the reference lost here.

> 
>> +	ret = migrate_pages(&cma_migrate_pages, new_iommu_non_cma_page,
>> +				NULL, 0, MIGRATE_SYNC, MR_CMA);
>> +	if (ret) {
>> +		if (!list_empty(&cma_migrate_pages))
>> +			putback_movable_pages(&cma_migrate_pages);
>> +	}
>> +	return 0;
>> +}
>> +
> 
> I guess the plan was to not do it one page at a time and switch this to list
> of pages which we need to migrate. Any reason why that is not tried ?
> 

Yes, it is a TODO. Here is my order of preference

1. get this in
2. Get THP migration in -- larger workset
3. Do page aggregation for both 1 and 2


Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
