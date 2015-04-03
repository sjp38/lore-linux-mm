Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 02BF26B0032
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 06:50:19 -0400 (EDT)
Received: by wgbdm7 with SMTP id dm7so108389418wgb.1
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 03:50:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kx6si13580884wjb.96.2015.04.03.03.50.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Apr 2015 03:50:16 -0700 (PDT)
Date: Fri, 3 Apr 2015 12:50:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: sync allocation and memcg charge gfp flags
 for thp fix fix
Message-ID: <20150403105014.GB6216@dhcp22.suse.cz>
References: <1426514892-7063-1-git-send-email-mhocko@suse.cz>
 <55098D0A.8090605@suse.cz>
 <20150318150257.GL17241@dhcp22.suse.cz>
 <55099C72.1080102@suse.cz>
 <20150318155905.GO17241@dhcp22.suse.cz>
 <5509A31C.3070108@suse.cz>
 <20150318161407.GP17241@dhcp22.suse.cz>
 <alpine.DEB.2.10.1504021836180.20229@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1504021836180.20229@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 02-04-15 18:41:18, David Rientjes wrote:
> "mm, memcg: sync allocation and memcg charge gfp flags for THP" in -mm 
> introduces a formal to pass the gfp mask for khugepaged's hugepage 
> allocation.  This is just too ugly to live.
> 
> alloc_hugepage_gfpmask() cannot differ between NUMA and UMA configs by 
> anything in GFP_RECLAIM_MASK, which is the only thing that matters for 
> memcg reclaim, so just determine the gfp flags once in 
> collapse_huge_page() and avoid the complexity.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Thanks for this cleanup!

Acked-by: Michal Hocko <mhocko@suse.cz>
> ---
>  -mm: intended to be folded into
>       mm-memcg-sync-allocation-and-memcg-charge-gfp-flags-for-thp.patch
> 
>  mm/huge_memory.c | 21 ++++++++-------------
>  1 file changed, 8 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2373,16 +2373,12 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
>  }
>  
>  static struct page *
> -khugepaged_alloc_page(struct page **hpage, gfp_t *gfp, struct mm_struct *mm,
> +khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
>  		       struct vm_area_struct *vma, unsigned long address,
>  		       int node)
>  {
>  	VM_BUG_ON_PAGE(*hpage, *hpage);
>  
> -	/* Only allocate from the target node */
> -	*gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
> -	        __GFP_THISNODE;
> -
>  	/*
>  	 * Before allocating the hugepage, release the mmap_sem read lock.
>  	 * The allocation can take potentially a long time if it involves
> @@ -2391,7 +2387,7 @@ khugepaged_alloc_page(struct page **hpage, gfp_t *gfp, struct mm_struct *mm,
>  	 */
>  	up_read(&mm->mmap_sem);
>  
> -	*hpage = alloc_pages_exact_node(node, *gfp, HPAGE_PMD_ORDER);
> +	*hpage = alloc_pages_exact_node(node, gfp, HPAGE_PMD_ORDER);
>  	if (unlikely(!*hpage)) {
>  		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
>  		*hpage = ERR_PTR(-ENOMEM);
> @@ -2445,18 +2441,13 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
>  }
>  
>  static struct page *
> -khugepaged_alloc_page(struct page **hpage, gfp_t *gfp, struct mm_struct *mm,
> +khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
>  		       struct vm_area_struct *vma, unsigned long address,
>  		       int node)
>  {
>  	up_read(&mm->mmap_sem);
>  	VM_BUG_ON(!*hpage);
>  
> -	/*
> -	 * khugepaged_alloc_hugepage is doing the preallocation, use the same
> -	 * gfp flags here.
> -	 */
> -	*gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), 0);
>  	return  *hpage;
>  }
>  #endif
> @@ -2495,8 +2486,12 @@ static void collapse_huge_page(struct mm_struct *mm,
>  
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>  
> +	/* Only allocate from the target node */
> +	gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
> +		__GFP_THISNODE;
> +
>  	/* release the mmap_sem read lock. */
> -	new_page = khugepaged_alloc_page(hpage, &gfp, mm, vma, address, node);
> +	new_page = khugepaged_alloc_page(hpage, gfp, mm, vma, address, node);
>  	if (!new_page)
>  		return;
>  
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
