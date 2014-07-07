Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 005276B0036
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 07:13:38 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id s18so2706574lam.6
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 04:13:38 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.231])
        by mx.google.com with ESMTP id u2si19861523laa.27.2014.07.07.04.13.37
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 04:13:37 -0700 (PDT)
Date: Mon, 7 Jul 2014 14:13:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v10 7/7] mm: Don't split THP page when syscall is called
Message-ID: <20140707111303.GC23150@node.dhcp.inet.fi>
References: <1404694438-10272-1-git-send-email-minchan@kernel.org>
 <1404694438-10272-8-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404694438-10272-8-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Jul 07, 2014 at 09:53:58AM +0900, Minchan Kim wrote:
> We don't need to split THP page when MADV_FREE syscall is
> called. It could be done when VM decide really frees it so
> we could reduce the number of THP split.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/linux/huge_mm.h |  3 +++
>  mm/huge_memory.c        | 25 +++++++++++++++++++++++++
>  mm/madvise.c            | 19 +++++++++++++++++--
>  mm/rmap.c               |  4 ++++
>  mm/vmscan.c             | 24 ++++++++++++++++--------
>  5 files changed, 65 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 63579cb8d3dc..f0d37238cf8f 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -19,6 +19,9 @@ extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  					  unsigned long addr,
>  					  pmd_t *pmd,
>  					  unsigned int flags);
> +extern int madvise_free_pmd(struct mmu_gather *tlb,
> +			struct vm_area_struct *vma,
> +			pmd_t *pmd, unsigned long addr);
>  extern int zap_huge_pmd(struct mmu_gather *tlb,
>  			struct vm_area_struct *vma,
>  			pmd_t *pmd, unsigned long addr);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 5d562a9fe931..2a70069dcfc0 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1384,6 +1384,31 @@ out:
>  	return 0;
>  }
>  
> +int madvise_free_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> +		 pmd_t *pmd, unsigned long addr)
> +{
> +	spinlock_t *ptl;
> +	int ret = 0;
> +
> +	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
> +		pmd_t orig_pmd;
> +		struct mm_struct *mm = vma->vm_mm;
> +
> +		/* No hugepage in swapcache */
> +		VM_BUG_ON(PageSwapCache(pmd_page(orig_pmd)));

VM_BUG_ON_PAGE() ?

> +
> +		orig_pmd = pmdp_get_and_clear(tlb->mm, addr, pmd);
> +		orig_pmd = pmd_mkold(orig_pmd);
> +		orig_pmd = pmd_mkclean(orig_pmd);
> +
> +		set_pmd_at(mm, addr, pmd, orig_pmd);
> +		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> +		spin_unlock(ptl);
> +		ret = 1;
> +	}
> +	return ret;
> +}
> +
>  int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		 pmd_t *pmd, unsigned long addr)
>  {
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 372a25a8ea82..3c99919ee094 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -320,8 +320,23 @@ static inline unsigned long madvise_free_pmd_range(struct mmu_gather *tlb,
>  		 * if the range covers.
>  		 */
>  		next = pmd_addr_end(addr, end);
> -		if (pmd_trans_huge(*pmd))
> -			split_huge_page_pmd(vma, addr, pmd);
> +		if (pmd_trans_huge(*pmd)) {
> +			if (next - addr != HPAGE_PMD_SIZE) {
> +#ifdef CONFIG_DEBUG_VM
> +				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
> +					pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
> +						__func__, addr, end,
> +						vma->vm_start,
> +						vma->vm_end);
> +					BUG();
> +				}
> +#endif
> +				split_huge_page_pmd(vma, addr, pmd);
> +			} else if (madvise_free_pmd(tlb, vma, pmd, addr))
> +				goto next;
> +			/* fall through */
> +		}
> +
>  		/*
>  		 * Here there can be other concurrent MADV_DONTNEED or
>  		 * trans huge page faults running, and if the pmd is
> diff --git a/mm/rmap.c b/mm/rmap.c
> index ee495d84c8b3..3c415eb8b6f0 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -702,6 +702,10 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>  		/* go ahead even if the pmd is pmd_trans_splitting() */
>  		if (pmdp_clear_flush_young_notify(vma, address, pmd))
>  			referenced++;
> +
> +		if (pmd_dirty(*pmd))
> +			dirty++;
> +
>  		spin_unlock(ptl);
>  	} else {
>  		pte_t *pte;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f7a45600846f..4e15babf4414 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -971,15 +971,23 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * Anonymous process memory has backing store?
>  		 * Try to allocate it some swap space here.
>  		 */
> -		if (PageAnon(page) && !PageSwapCache(page) && !freeable) {
> -			if (!(sc->gfp_mask & __GFP_IO))
> -				goto keep_locked;
> -			if (!add_to_swap(page, page_list))
> -				goto activate_locked;
> -			may_enter_fs = 1;
> +		if (PageAnon(page) && !PageSwapCache(page)) {
> +			if (!freeable) {
> +				if (!(sc->gfp_mask & __GFP_IO))
> +					goto keep_locked;
> +				if (!add_to_swap(page, page_list))
> +					goto activate_locked;
> +				may_enter_fs = 1;
>  
> -			/* Adding to swap updated mapping */
> -			mapping = page_mapping(page);
> +				/* Adding to swap updated mapping */
> +				mapping = page_mapping(page);
> +			} else {
> +				if (unlikely(PageTransHuge(page))) {
> +					if (unlikely(split_huge_page_to_list(
> +						page, page_list)))
> +						goto keep_locked;

Hm. It would be better to free the huge page without splitting. 
It shouldn't be a big deal: walk over rmap and zap all pmds.
Or I miss something?

> +				}
> +			}
>  		}
>  
>  		/*
> -- 
> 2.0.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
