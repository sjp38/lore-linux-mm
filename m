Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id C09F36B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 01:49:45 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vp2so91051186pab.3
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 22:49:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o15si4916274pfj.276.2016.09.05.22.49.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Sep 2016 22:49:44 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u865mJNV093813
	for <linux-mm@kvack.org>; Tue, 6 Sep 2016 01:49:43 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 259kn9h129-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Sep 2016 01:49:43 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 5 Sep 2016 23:49:42 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RESEND][v2][PATCH] KVM: PPC: Book3S HV: Migrate pinned pages out of CMA
In-Reply-To: <20160714042536.GG18277@balbir.ozlabs.ibm.com>
References: <20160714042536.GG18277@balbir.ozlabs.ibm.com>
Date: Tue, 06 Sep 2016 11:19:33 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87vay9pogi.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bsingharora@gmail.com, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

Balbir Singh <bsingharora@gmail.com> writes:

> From: Balbir Singh <bsingharora@gmail.com>
> Subject: [RESEND][v2][PATCH] KVM: PPC: Book3S HV: Migrate pinned pages out of CMA
>
> When PCI Device pass-through is enabled via VFIO, KVM-PPC will
> pin pages using get_user_pages_fast(). One of the downsides of
> the pinning is that the page could be in CMA region. The CMA
> region is used for other allocations like the hash page table.
> Ideally we want the pinned pages to be from non CMA region.
>
> This patch (currently only for KVM PPC with VFIO) forcefully
> migrates the pages out (huge pages are omitted for the moment).
> There are more efficient ways of doing this, but that might
> be elaborate and might impact a larger audience beyond just
> the kvm ppc implementation.
>
> The magic is in new_iommu_non_cma_page() which allocates the
> new page from a non CMA region.
>
> I've tested the patches lightly at my end, but there might be bugs
> For example if after lru_add_drain(), the page is not isolated
> is this a BUG?
>
> Previous discussion was at
> http://permalink.gmane.org/gmane.linux.kernel.mm/136738
>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Paul Mackerras <paulus@ozlabs.org>
> Cc: Alexey Kardashevskiy <aik@ozlabs.ru>
>
> Signed-off-by: Balbir Singh <bsingharora@gmail.com>
> ---
>  arch/powerpc/include/asm/mmu_context.h |  1 +
>  arch/powerpc/mm/mmu_context_iommu.c    | 80 ++++++++++++++++++++++++++++++++--
>  2 files changed, 77 insertions(+), 4 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
> index 9d2cd0c..475d1be 100644
> --- a/arch/powerpc/include/asm/mmu_context.h
> +++ b/arch/powerpc/include/asm/mmu_context.h
> @@ -18,6 +18,7 @@ extern void destroy_context(struct mm_struct *mm);
>  #ifdef CONFIG_SPAPR_TCE_IOMMU
>  struct mm_iommu_table_group_mem_t;
>  
> +extern int isolate_lru_page(struct page *page);	/* from internal.h */
>  extern bool mm_iommu_preregistered(void);
>  extern long mm_iommu_get(unsigned long ua, unsigned long entries,
>  		struct mm_iommu_table_group_mem_t **pmem);
> diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
> index da6a216..c18f742 100644
> --- a/arch/powerpc/mm/mmu_context_iommu.c
> +++ b/arch/powerpc/mm/mmu_context_iommu.c
> @@ -15,6 +15,9 @@
>  #include <linux/rculist.h>
>  #include <linux/vmalloc.h>
>  #include <linux/mutex.h>
> +#include <linux/migrate.h>
> +#include <linux/hugetlb.h>
> +#include <linux/swap.h>
>  #include <asm/mmu_context.h>
>  
>  static DEFINE_MUTEX(mem_list_mutex);
> @@ -72,6 +75,54 @@ bool mm_iommu_preregistered(void)
>  }
>  EXPORT_SYMBOL_GPL(mm_iommu_preregistered);
>  
> +/*
> + * Taken from alloc_migrate_target with changes to remove CMA allocations
> + */
> +struct page *new_iommu_non_cma_page(struct page *page, unsigned long private,
> +					int **resultp)
> +{
> +	gfp_t gfp_mask = GFP_USER;
> +	struct page *new_page;
> +
> +	if (PageHuge(page) || PageTransHuge(page) || PageCompound(page))
> +		return NULL;

Doesn't a PageCompound check cover all ?


> +
> +	if (PageHighMem(page))
> +		gfp_mask |= __GFP_HIGHMEM;
> +
> +	/*
> +	 * We don't want the allocation to force an OOM if possibe
> +	 */
> +	new_page = alloc_page(gfp_mask | __GFP_NORETRY | __GFP_NOWARN);
> +	return new_page;
> +}
> +
> +static int mm_iommu_move_page_from_cma(struct page *page)
> +{
> +	int ret;
> +	LIST_HEAD(cma_migrate_pages);
> +
> +	/* Ignore huge pages for now */
> +	if (PageHuge(page) || PageTransHuge(page) || PageCompound(page))
> +		return -EBUSY;
> +
> +	lru_add_drain();

I guess I asked this last time. Shouldn't this be lru_add_drain_all() ?
What if the page is in other cpu's pagevec ?


> +	ret = isolate_lru_page(page);
> +	if (ret)
> +		get_page(page); /* Potential BUG? */
> +
> +	list_add(&page->lru, &cma_migrate_pages);

Is that correct ? if we failed the isolate_lru_page(), can we be sure we
are not on lru at all ? ie, what if the page was on other cpu pagevec ?


> +	put_page(page); /* Drop the gup reference */
> +

Where is get user page (gup) here ? . I guess you mean drop the
reference taken above ?


> +	ret = migrate_pages(&cma_migrate_pages, new_iommu_non_cma_page,
> +				NULL, 0, MIGRATE_SYNC, MR_CMA);
> +	if (ret) {
> +		if (!list_empty(&cma_migrate_pages))
> +			putback_movable_pages(&cma_migrate_pages);
> +	}
> +	return 0;
> +}
> +

I guess the plan was to not do it one page at a time and switch this to list
of pages which we need to migrate. Any reason why that is not tried ?

>  long mm_iommu_get(unsigned long ua, unsigned long entries,
>  		struct mm_iommu_table_group_mem_t **pmem)
>  {
> @@ -124,15 +175,36 @@ long mm_iommu_get(unsigned long ua, unsigned long entries,
>  	for (i = 0; i < entries; ++i) {
>  		if (1 != get_user_pages_fast(ua + (i << PAGE_SHIFT),
>  					1/* pages */, 1/* iswrite */, &page)) {
> +			ret = -EFAULT;
>  			for (j = 0; j < i; ++j)
> -				put_page(pfn_to_page(
> -						mem->hpas[j] >> PAGE_SHIFT));
> +				put_page(pfn_to_page(mem->hpas[j] >>
> +						PAGE_SHIFT));
>  			vfree(mem->hpas);
>  			kfree(mem);
> -			ret = -EFAULT;
>  			goto unlock_exit;
>  		}
> -
> +		/*
> +		 * If we get a page from the CMA zone, since we are going to
> +		 * be pinning these entries, we might as well move them out
> +		 * of the CMA zone if possible. NOTE: faulting in + migration
> +		 * can be expensive. Batching can be considered later
> +		 */
> +		if (get_pageblock_migratetype(page) == MIGRATE_CMA) {
> +			if (mm_iommu_move_page_from_cma(page))
> +				goto populate;
> +			if (1 != get_user_pages_fast(ua + (i << PAGE_SHIFT),
> +						1/* pages */, 1/* iswrite */,
> +						&page)) {
> +				ret = -EFAULT;
> +				for (j = 0; j < i; ++j)
> +					put_page(pfn_to_page(mem->hpas[j] >>
> +								PAGE_SHIFT));
> +				vfree(mem->hpas);
> +				kfree(mem);
> +				goto unlock_exit;
> +			}
> +		}
> +populate:
>  		mem->hpas[i] = page_to_pfn(page) << PAGE_SHIFT;
>  	}
>  
> -- 
> 2.5.5
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
