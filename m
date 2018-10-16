Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7CB66B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 00:57:22 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id v4-v6so17260711plz.21
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 21:57:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1-v6sor3969026pfn.68.2018.10.15.21.57.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 21:57:20 -0700 (PDT)
Subject: Re: [PATCH V3 2/2] powerpc/mm/iommu: Allow migration of cma allocated
 pages during mm_iommu_get
References: <20180918115839.22154-1-aneesh.kumar@linux.ibm.com>
 <20180918115839.22154-3-aneesh.kumar@linux.ibm.com>
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Message-ID: <ed52bfcd-9440-9f1f-202c-5b51d31c7cf1@ozlabs.ru>
Date: Tue, 16 Oct 2018 15:57:13 +1100
MIME-Version: 1.0
In-Reply-To: <20180918115839.22154-3-aneesh.kumar@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org



On 18/09/2018 21:58, Aneesh Kumar K.V wrote:
> Current code doesn't do page migration if the page allocated is a compound page.
> With HugeTLB migration support, we can end up allocating hugetlb pages from
> CMA region. Also THP pages can be allocated from CMA region. This patch updates
> the code to handle compound pages correctly.
> 
> This use the new helper get_user_pages_cma_migrate. It does one get_user_pages
> with right count, instead of doing one get_user_pages per page. That avoids
> reading page table multiple times.
> 
> The patch also convert the hpas member of mm_iommu_table_group_mem_t to a union.
> We use the same storage location to store pointers to struct page. We cannot
> update alll the code path use struct page *, because we access hpas in real mode
> and we can't do that struct page * to pfn conversion in real mode.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  arch/powerpc/mm/mmu_context_iommu.c | 120 ++++++++--------------------
>  1 file changed, 35 insertions(+), 85 deletions(-)
> 
> diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
> index c9ee9e23845f..f0d8645872cb 100644
> --- a/arch/powerpc/mm/mmu_context_iommu.c
> +++ b/arch/powerpc/mm/mmu_context_iommu.c
> @@ -20,6 +20,7 @@
>  #include <linux/swap.h>
>  #include <asm/mmu_context.h>
>  #include <asm/pte-walk.h>
> +#include <linux/mm_inline.h>
>  
>  static DEFINE_MUTEX(mem_list_mutex);
>  
> @@ -30,8 +31,18 @@ struct mm_iommu_table_group_mem_t {
>  	atomic64_t mapped;
>  	unsigned int pageshift;
>  	u64 ua;			/* userspace address */
> -	u64 entries;		/* number of entries in hpas[] */
> -	u64 *hpas;		/* vmalloc'ed */
> +	u64 entries;		/* number of entries in hpages[] */
> +	/*
> +	 * in mm_iommu_get we temporarily use this to store
> +	 * struct page address.
> +	 *
> +	 * We need to convert ua to hpa in real mode. Make it
> +	 * simpler by storing physicall address.
> +	 */
> +	union {
> +		struct page **hpages;	/* vmalloc'ed */
> +		phys_addr_t *hpas;


It could always be hpages. Now it is slightly complicated though because
of MM_IOMMU_TABLE_GROUP_PAGE_DIRTY...

> +	};
>  };
>  
>  static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
> @@ -74,63 +85,14 @@ bool mm_iommu_preregistered(struct mm_struct *mm)
>  }
>  EXPORT_SYMBOL_GPL(mm_iommu_preregistered);
>  
> -/*
> - * Taken from alloc_migrate_target with changes to remove CMA allocations
> - */
> -struct page *new_iommu_non_cma_page(struct page *page, unsigned long private)
> -{
> -	gfp_t gfp_mask = GFP_USER;
> -	struct page *new_page;
> -
> -	if (PageCompound(page))
> -		return NULL;
> -
> -	if (PageHighMem(page))
> -		gfp_mask |= __GFP_HIGHMEM;
> -
> -	/*
> -	 * We don't want the allocation to force an OOM if possibe
> -	 */
> -	new_page = alloc_page(gfp_mask | __GFP_NORETRY | __GFP_NOWARN);
> -	return new_page;
> -}
> -
> -static int mm_iommu_move_page_from_cma(struct page *page)
> -{
> -	int ret = 0;
> -	LIST_HEAD(cma_migrate_pages);
> -
> -	/* Ignore huge pages for now */
> -	if (PageCompound(page))
> -		return -EBUSY;
> -
> -	lru_add_drain();
> -	ret = isolate_lru_page(page);
> -	if (ret)
> -		return ret;
> -
> -	list_add(&page->lru, &cma_migrate_pages);
> -	put_page(page); /* Drop the gup reference */
> -
> -	ret = migrate_pages(&cma_migrate_pages, new_iommu_non_cma_page,
> -				NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE);
> -	if (ret) {
> -		if (!list_empty(&cma_migrate_pages))
> -			putback_movable_pages(&cma_migrate_pages);
> -	}
> -
> -	return 0;
> -}
> -
>  long mm_iommu_get(struct mm_struct *mm, unsigned long ua, unsigned long entries,
>  		struct mm_iommu_table_group_mem_t **pmem)
>  {
>  	struct mm_iommu_table_group_mem_t *mem;
> -	long i, j, ret = 0, locked_entries = 0;
> +	long i, ret = 0, locked_entries = 0;
>  	unsigned int pageshift;
>  	unsigned long flags;
>  	unsigned long cur_ua;
> -	struct page *page = NULL;
>  
>  	mutex_lock(&mem_list_mutex);
>  
> @@ -177,41 +139,24 @@ long mm_iommu_get(struct mm_struct *mm, unsigned long ua, unsigned long entries,
>  		goto unlock_exit;
>  	}
>  
> +	ret = get_user_pages_cma_migrate(ua, entries, 1, mem->hpages);
> +	if (ret != entries) {
> +		/* free the reference taken */
> +		for (i = 0; i < ret; i++)
> +			put_page(mem->hpages[i]);
> +
> +		vfree(mem->hpas);
> +		kfree(mem);
> +		ret = -EFAULT;
> +		goto unlock_exit;
> +	} else

Do not need "else".


> +		ret = 0;
> +
> +	pageshift = PAGE_SHIFT;
>  	for (i = 0; i < entries; ++i) {
> +		struct page *page = mem->hpages[i];
>  		cur_ua = ua + (i << PAGE_SHIFT);
> -		if (1 != get_user_pages_fast(cur_ua,
> -					1/* pages */, 1/* iswrite */, &page)) {
> -			ret = -EFAULT;
> -			for (j = 0; j < i; ++j)
> -				put_page(pfn_to_page(mem->hpas[j] >>
> -						PAGE_SHIFT));
> -			vfree(mem->hpas);
> -			kfree(mem);
> -			goto unlock_exit;
> -		}
> -		/*
> -		 * If we get a page from the CMA zone, since we are going to
> -		 * be pinning these entries, we might as well move them out
> -		 * of the CMA zone if possible. NOTE: faulting in + migration
> -		 * can be expensive. Batching can be considered later
> -		 */
> -		if (is_migrate_cma_page(page)) {
> -			if (mm_iommu_move_page_from_cma(page))
> -				goto populate;
> -			if (1 != get_user_pages_fast(cur_ua,
> -						1/* pages */, 1/* iswrite */,
> -						&page)) {
> -				ret = -EFAULT;
> -				for (j = 0; j < i; ++j)
> -					put_page(pfn_to_page(mem->hpas[j] >>
> -								PAGE_SHIFT));
> -				vfree(mem->hpas);
> -				kfree(mem);
> -				goto unlock_exit;
> -			}
> -		}
> -populate:
> -		pageshift = PAGE_SHIFT;
> +
>  		if (mem->pageshift > PAGE_SHIFT && PageCompound(page)) {
>  			pte_t *pte;
>  			struct page *head = compound_head(page);
> @@ -229,7 +174,12 @@ long mm_iommu_get(struct mm_struct *mm, unsigned long ua, unsigned long entries,
>  			local_irq_restore(flags);
>  		}
>  		mem->pageshift = min(mem->pageshift, pageshift);
> +		/*
> +		 * We don't need struct page reference any more, switch
> +		 * physicall address.
> +		 */
>  		mem->hpas[i] = page_to_pfn(page) << PAGE_SHIFT;
> +

nit: do not need an empty line here.


>  	}
>  
>  	atomic64_set(&mem->mapped, 1);
> 

-- 
Alexey
