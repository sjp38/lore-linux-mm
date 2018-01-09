Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A595B6B0253
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 03:46:25 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r63so4993631wmb.9
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 00:46:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j134si9024289wmj.210.2018.01.09.00.46.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Jan 2018 00:46:24 -0800 (PST)
Date: Tue, 9 Jan 2018 09:46:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't expose page to fast gup before it's ready
Message-ID: <20180109084622.GF1732@dhcp22.suse.cz>
References: <20180108225632.16332-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180108225632.16332-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 08-01-18 14:56:32, Yu Zhao wrote:
> We don't want to expose page before it's properly setup. During
> page setup, we may call page_add_new_anon_rmap() which uses non-
> atomic bit op. If page is exposed before it's done, we could
> overwrite page flags that are set by get_user_pages_fast() or
> it's callers. Here is a non-fatal scenario (there might be other
> fatal problems that I didn't look into):
> 
> 	CPU 1				CPU1
> set_pte_at()			get_user_pages_fast()
> page_add_new_anon_rmap()		gup_pte_range()
> 	__SetPageSwapBacked()			SetPageReferenced()
> 
> Fix the problem by delaying set_pte_at() until page is ready.

Have you seen this race happening in real workloads or this is a code
review based fix or a theoretical issue? I am primarily asking because
the code is like that at least throughout git era and I do not remember
any issue like this. If you can really trigger this tiny race window
then we should mark the fix for stable.

Also what prevents reordering here? There do not seem to be any barriers
to prevent __SetPageSwapBacked leak after set_pte_at with your patch.

> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  mm/memory.c   | 2 +-
>  mm/swapfile.c | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index ca5674cbaff2..b8be1a4adf93 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3010,7 +3010,6 @@ int do_swap_page(struct vm_fault *vmf)
>  	flush_icache_page(vma, page);
>  	if (pte_swp_soft_dirty(vmf->orig_pte))
>  		pte = pte_mksoft_dirty(pte);
> -	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
>  	vmf->orig_pte = pte;
>  
>  	/* ksm created a completely new copy */
> @@ -3023,6 +3022,7 @@ int do_swap_page(struct vm_fault *vmf)
>  		mem_cgroup_commit_charge(page, memcg, true, false);
>  		activate_page(page);
>  	}
> +	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
>  
>  	swap_free(entry);
>  	if (mem_cgroup_swap_full(page) ||
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 3074b02eaa09..bd49da2b5221 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1800,8 +1800,6 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
>  	dec_mm_counter(vma->vm_mm, MM_SWAPENTS);
>  	inc_mm_counter(vma->vm_mm, MM_ANONPAGES);
>  	get_page(page);
> -	set_pte_at(vma->vm_mm, addr, pte,
> -		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
>  	if (page == swapcache) {
>  		page_add_anon_rmap(page, vma, addr, false);
>  		mem_cgroup_commit_charge(page, memcg, true, false);
> @@ -1810,6 +1808,8 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
>  		mem_cgroup_commit_charge(page, memcg, false, false);
>  		lru_cache_add_active_or_unevictable(page, vma);
>  	}
> +	set_pte_at(vma->vm_mm, addr, pte,
> +		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
>  	swap_free(entry);
>  	/*
>  	 * Move the page to the active list so it is not
> -- 
> 2.16.0.rc0.223.g4a4ac83678-goog
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
