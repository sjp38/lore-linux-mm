Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 645126B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 04:07:47 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id x1so262566191pav.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 01:07:47 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id qd3si10083207pab.208.2016.05.30.01.07.44
        for <linux-mm@kvack.org>;
        Mon, 30 May 2016 01:07:46 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <001701d1ba44$b9c0d560$2d428020$@alibaba-inc.com>
In-Reply-To: <001701d1ba44$b9c0d560$2d428020$@alibaba-inc.com>
Subject: Re: [RFC PATCH 2/4] mm: Change the interface for __tlb_remove_page
Date: Mon, 30 May 2016 16:07:31 +0800
Message-ID: <001901d1ba4a$514eccc0$f3ec6640$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> diff --git a/mm/memory.c b/mm/memory.c
> index 15322b73636b..a01db5bc756b 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -292,23 +292,24 @@ void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long e
>   *	handling the additional races in SMP caused by other CPUs caching valid
>   *	mappings in their TLBs. Returns the number of free page slots left.
>   *	When out of page slots we must call tlb_flush_mmu().
> + *returns true if the caller should flush.
>   */
> -int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
> +bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
>  {
>  	struct mmu_gather_batch *batch;
> 
>  	VM_BUG_ON(!tlb->end);
> 
>  	batch = tlb->active;
> -	batch->pages[batch->nr++] = page;
>  	if (batch->nr == batch->max) {
>  		if (!tlb_next_batch(tlb))
> -			return 0;
> +			return true;
>  		batch = tlb->active;
>  	}
>  	VM_BUG_ON_PAGE(batch->nr > batch->max, page);

Still needed?
> 
> -	return batch->max - batch->nr;
> +	batch->pages[batch->nr++] = page;
> +	return false;
>  }
> 
>  #endif /* HAVE_GENERIC_MMU_GATHER */
> @@ -1109,6 +1110,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  	pte_t *start_pte;
>  	pte_t *pte;
>  	swp_entry_t entry;
> +	struct page *pending_page = NULL;
> 
>  again:
>  	init_rss_vec(rss);
> @@ -1160,8 +1162,9 @@ again:
>  			page_remove_rmap(page, false);
>  			if (unlikely(page_mapcount(page) < 0))
>  				print_bad_pte(vma, addr, ptent, page);
> -			if (unlikely(!__tlb_remove_page(tlb, page))) {
> +			if (unlikely(__tlb_remove_page(tlb, page))) {
>  				force_flush = 1;
> +				pending_page = page;
>  				addr += PAGE_SIZE;
>  				break;
>  			}
> @@ -1202,7 +1205,12 @@ again:
>  	if (force_flush) {
>  		force_flush = 0;
>  		tlb_flush_mmu_free(tlb);
> -
> +		if (pending_page) {
> +			/* remove the page with new size */
> +			__tlb_adjust_range(tlb, tlb->addr);

Would you please specify why tlb->addr is used here?

thanks
Hillf 
> +			__tlb_remove_page(tlb, pending_page);
> +			pending_page = NULL;
> +		}
>  		if (addr != end)
>  			goto again;
>  	}
> --
> 2.7.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
