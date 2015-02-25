Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id C7CC96B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 10:07:40 -0500 (EST)
Received: by wggy19 with SMTP id y19so4203393wgg.10
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 07:07:40 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id id6si87651wjb.162.2015.02.25.07.07.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 07:07:39 -0800 (PST)
Date: Wed, 25 Feb 2015 16:07:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC 1/4] mm: throttle MADV_FREE
Message-ID: <20150225150736.GF26680@dhcp22.suse.cz>
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
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

On Wed 25-02-15 16:11:18, Minchan Kim wrote:
[...]
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

Yes this makes sense. rss is a bit confusing because those pages are not
resident.

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
>  	arch_leave_lazy_mmu_mode();
>  	pte_unmap_unlock(pte - 1, ptl);
>  next:
> -- 
> 1.9.1
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
