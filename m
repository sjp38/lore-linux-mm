Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9726B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 20:46:51 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so58736642pdb.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 17:46:51 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id r4si39265793pdf.25.2015.03.18.17.46.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 17:46:50 -0700 (PDT)
Received: by padcy3 with SMTP id cy3so58186415pad.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 17:46:50 -0700 (PDT)
Date: Thu, 19 Mar 2015 09:46:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/4] mm: free swp_entry in madvise_free
Message-ID: <20150319004641.GC9153@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426036838-18154-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

Bump up.

On Wed, Mar 11, 2015 at 10:20:35AM +0900, Minchan Kim wrote:
> When I test below piece of code with 12 processes(ie, 512M * 12 = 6G consume)
> on my (3G ram + 12 cpu + 8G swap, the madvise_free is siginficat slower
> (ie, 2x times) than madvise_dontneed.
> 
> loop = 5;
> mmap(512M);
> while (loop--) {
>         memset(512M);
>         madvise(MADV_FREE or MADV_DONTNEED);
> }
> 
> The reason is lots of swapin.
> 
> 1) dontneed: 1,612 swapin
> 2) madvfree: 879,585 swapin
> 
> If we find hinted pages were already swapped out when syscall is called,
> it's pointless to keep the swapped-out pages in pte.
> Instead, let's free the cold page because swapin is more expensive
> than (alloc page + zeroing).
> 
> With this patch, it reduced swapin from 879,585 to 1,878 so elapsed time
> 
> 1) dontneed: 6.10user 233.50system 0:50.44elapsed
> 2) madvfree: 6.03user 401.17system 1:30.67elapsed
> 2) madvfree + below patch: 6.70user 339.14system 1:04.45elapsed
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/madvise.c | 26 +++++++++++++++++++++++++-
>  1 file changed, 25 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 6d0fcb8..ebe692e 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -274,7 +274,9 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  	spinlock_t *ptl;
>  	pte_t *pte, ptent;
>  	struct page *page;
> +	swp_entry_t entry;
>  	unsigned long next;
> +	int nr_swap = 0;
>  
>  	next = pmd_addr_end(addr, end);
>  	if (pmd_trans_huge(*pmd)) {
> @@ -293,8 +295,22 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  	for (; addr != end; pte++, addr += PAGE_SIZE) {
>  		ptent = *pte;
>  
> -		if (!pte_present(ptent))
> +		if (pte_none(ptent))
>  			continue;
> +		/*
> +		 * If the pte has swp_entry, just clear page table to
> +		 * prevent swap-in which is more expensive rather than
> +		 * (page allocation + zeroing).
> +		 */
> +		if (!pte_present(ptent)) {
> +			entry = pte_to_swp_entry(ptent);
> +			if (non_swap_entry(entry))
> +				continue;
> +			nr_swap--;
> +			free_swap_and_cache(entry);
> +			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
> +			continue;
> +		}
>  
>  		page = vm_normal_page(vma, addr, ptent);
>  		if (!page)
> @@ -326,6 +342,14 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  		set_pte_at(mm, addr, pte, ptent);
>  		tlb_remove_tlb_entry(tlb, pte, addr);
>  	}
> +
> +	if (nr_swap) {
> +		if (current->mm == mm)
> +			sync_mm_rss(mm);
> +
> +		add_mm_counter(mm, MM_SWAPENTS, nr_swap);
> +	}
> +
>  	arch_leave_lazy_mmu_mode();
>  	pte_unmap_unlock(pte - 1, ptl);
>  next:
> -- 
> 1.9.3
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
