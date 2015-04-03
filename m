Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E2B506B0032
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 04:16:17 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so34939522pdb.0
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 01:16:17 -0700 (PDT)
Received: from us-alimail-mta2.hst.scl.en.alidc.net (mail113-251.mail.alibaba.com. [205.204.113.251])
        by mx.google.com with ESMTP id g12si11012617pat.50.2015.04.03.01.16.14
        for <linux-mm@kvack.org>;
        Fri, 03 Apr 2015 01:16:16 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <058201d06de5$9e15edc0$da41c940$@alibaba-inc.com>
In-Reply-To: <058201d06de5$9e15edc0$da41c940$@alibaba-inc.com>
Subject: Re: [patch] mm, memcg: sync allocation and memcg charge gfp flags for thp fix fix
Date: Fri, 03 Apr 2015 16:14:39 +0800
Message-ID: <058301d06de6$3b941310$b2bc3930$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

> 
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
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

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
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
