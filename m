Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 211B06B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:37:51 -0500 (EST)
Received: by pdev10 with SMTP id v10so6699973pde.10
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 10:37:50 -0800 (PST)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id o9si1123930pdk.241.2015.02.25.10.37.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 10:37:50 -0800 (PST)
Received: by pdjz10 with SMTP id z10so6682395pdj.12
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 10:37:49 -0800 (PST)
Date: Wed, 25 Feb 2015 10:37:48 -0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH RFC 1/4] mm: throttle MADV_FREE
Message-ID: <20150225183748.GA2551@kernel.org>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz>
 <20150225000809.GA6468@blaptop>
 <20150225071118.GA19115@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150225071118.GA19115@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Yalin.Wang@sonymobile.com

On Wed, Feb 25, 2015 at 04:11:18PM +0900, Minchan Kim wrote:
> On Wed, Feb 25, 2015 at 09:08:09AM +0900, Minchan Kim wrote:
> > Hi Michal,
> > 
> > On Tue, Feb 24, 2015 at 04:43:18PM +0100, Michal Hocko wrote:
> > > On Tue 24-02-15 17:18:14, Minchan Kim wrote:
> > > > Recently, Shaohua reported that MADV_FREE is much slower than
> > > > MADV_DONTNEED in his MADV_FREE bomb test. The reason is many of
> > > > applications went to stall with direct reclaim since kswapd's
> > > > reclaim speed isn't fast than applications's allocation speed
> > > > so that it causes lots of stall and lock contention.
> > > 
> > > I am not sure I understand this correctly. So the issue is that there is
> > > huge number of MADV_FREE on the LRU and they are not close to the tail
> > > of the list so the reclaim has to do a lot of work before it starts
> > > dropping them?
> > 
> > No, Shaohua already tested deactivating of hinted pages to head/tail
> > of inactive anon LRU and he said it didn't solve his problem.
> > I thought main culprit was scanning/rotating/throttling in
> > direct reclaim path.
> 
> I investigated my workload and found most of slowness came from swapin.
> 
> 1) dontneed: 1,612 swapin
> 2) madvfree: 879,585 swapin
> 
> If we find hinted pages were already swapped out when syscall is called,
> it's pointless to keep the pages in pte. Instead, free the cold page
> because swapin is more expensive than (alloc page + zeroing).
> 
> I tested below quick fix and reduced swapin from 879,585 to 1,878.
> Elapsed time was
> 
> 1) dontneed: 6.10user 233.50system 0:50.44elapsed
> 2) madvfree + below patch: 6.70user 339.14system 1:04.45elapsed
> 
> Although it was not good as throttling, it's better than old and
> it's orthogoral with throttling so I hope to merge this first
> than arguable throttling. Any comments?
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 6d0fcb8921c2..d41ae76d3e54 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -274,7 +274,9 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  	spinlock_t *ptl;
>  	pte_t *pte, ptent;
>  	struct page *page;
> +	swp_entry_t entry;
>  	unsigned long next;
> +	int rss = 0;
>  
>  	next = pmd_addr_end(addr, end);
>  	if (pmd_trans_huge(*pmd)) {
> @@ -293,9 +295,19 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  	for (; addr != end; pte++, addr += PAGE_SIZE) {
>  		ptent = *pte;
>  
> -		if (!pte_present(ptent))
> +		if (pte_none(ptent))
>  			continue;
>  
> +		if (!pte_present(ptent)) {
> +			entry = pte_to_swp_entry(ptent);
> +			if (non_swap_entry(entry))
> +				continue;
> +			rss--;
> +			free_swap_and_cache(entry);
> +			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
> +			continue;
> +		}
> +
>  		page = vm_normal_page(vma, addr, ptent);
>  		if (!page)
>  			continue;
> @@ -326,6 +338,14 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  		set_pte_at(mm, addr, pte, ptent);
>  		tlb_remove_tlb_entry(tlb, pte, addr);
>  	}
> +
> +	if (rss) {
> +		if (current->mm == mm)
> +			sync_mm_rss(mm);
> +
> +		add_mm_counter(mm, MM_SWAPENTS, rss);
> +	}
> +

This looks make sense, but I'm wondering why it can help and if this can help
real workload.  Let me have an example. Say there is 1G memory, workload uses
800M memory with DONTNEED, there should be no swap. With FREE, workload might
use more than 1G memory and trigger swap. I thought the case (DONTNEED doesn't
trigger swap) is more suitable to evaluate the performance of the patch.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
