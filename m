Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 724156B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 10:05:58 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y51so5391090wry.6
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 07:05:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n124si13804683wmg.96.2017.02.27.07.05.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 07:05:57 -0800 (PST)
Date: Mon, 27 Feb 2017 16:05:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 4/6] mm: reclaim MADV_FREE pages
Message-ID: <20170227150553.GG26504@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
 <14b8eb1d3f6bf6cc492833f183ac8c304e560484.1487965799.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14b8eb1d3f6bf6cc492833f183ac8c304e560484.1487965799.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri 24-02-17 13:31:47, Shaohua Li wrote:
> When memory pressure is high, we free MADV_FREE pages. If the pages are
> not dirty in pte, the pages could be freed immediately. Otherwise we
> can't reclaim them. We put the pages back to anonumous LRU list (by
> setting SwapBacked flag) and the pages will be reclaimed in normal
> swapout way.
> 
> We use normal page reclaim policy. Since MADV_FREE pages are put into
> inactive file list, such pages and inactive file pages are reclaimed
> according to their age. This is expected, because we don't want to
> reclaim too many MADV_FREE pages before used once pages.
> 
> Based on Minchan's original patch

OK, this looks much more cleaner and easier to follow than the original
version I have seen.
 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/rmap.h |  2 +-
>  mm/huge_memory.c     |  2 ++
>  mm/madvise.c         |  1 +
>  mm/rmap.c            | 40 +++++++++++++++++-----------------------
>  mm/vmscan.c          | 34 ++++++++++++++++++++++------------
>  5 files changed, 43 insertions(+), 36 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 7a39414..fee10d7 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -298,6 +298,6 @@ static inline int page_mkclean(struct page *page)
>  #define SWAP_AGAIN	1
>  #define SWAP_FAIL	2
>  #define SWAP_MLOCK	3
> -#define SWAP_LZFREE	4
> +#define SWAP_DIRTY	4
>  
>  #endif	/* _LINUX_RMAP_H */
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 3b7ee0c..4c7454b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1571,6 +1571,8 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		set_pmd_at(mm, addr, pmd, orig_pmd);
>  		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
>  	}
> +
> +	mark_page_lazyfree(page);
>  	ret = true;
>  out:
>  	spin_unlock(ptl);
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 61e10b1..225af7d 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -413,6 +413,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  			set_pte_at(mm, addr, pte, ptent);
>  			tlb_remove_tlb_entry(tlb, pte, addr);
>  		}
> +		mark_page_lazyfree(page);
>  	}
>  out:
>  	if (nr_swap) {
> diff --git a/mm/rmap.c b/mm/rmap.c
> index c621088..bb45712 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1281,11 +1281,6 @@ void page_remove_rmap(struct page *page, bool compound)
>  	 */
>  }
>  
> -struct rmap_private {
> -	enum ttu_flags flags;
> -	int lazyfreed;
> -};
> -
>  /*
>   * @arg: enum ttu_flags will be passed to this argument
>   */
> @@ -1301,8 +1296,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	pte_t pteval;
>  	struct page *subpage;
>  	int ret = SWAP_AGAIN;
> -	struct rmap_private *rp = arg;
> -	enum ttu_flags flags = rp->flags;
> +	enum ttu_flags flags = (enum ttu_flags)arg;
>  
>  	/* munlock has nothing to gain from examining un-locked vmas */
>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
> @@ -1419,11 +1413,21 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			VM_BUG_ON_PAGE(!PageSwapCache(page) && PageSwapBacked(page),
>  				page);
>  
> -			if (!PageDirty(page)) {
> +			/*
> +			 * swapin page could be clean, it has data stored in
> +			 * swap. We can't silently discard it without setting
> +			 * swap entry in the page table.
> +			 */
> +			if (!PageDirty(page) && !PageSwapCache(page)) {
>  				/* It's a freeable page by MADV_FREE */
>  				dec_mm_counter(mm, MM_ANONPAGES);
> -				rp->lazyfreed++;
>  				goto discard;
> +			} else if (!PageSwapBacked(page)) {
> +				/* dirty MADV_FREE page */
> +				set_pte_at(mm, address, pvmw.pte, pteval);
> +				ret = SWAP_DIRTY;
> +				page_vma_mapped_walk_done(&pvmw);
> +				break;
>  			}
>  
>  			if (swap_duplicate(entry) < 0) {
> @@ -1491,18 +1495,15 @@ static int page_mapcount_is_zero(struct page *page)
>   * SWAP_AGAIN	- we missed a mapping, try again later
>   * SWAP_FAIL	- the page is unswappable
>   * SWAP_MLOCK	- page is mlocked.
> + * SWAP_DIRTY	- page is dirty MADV_FREE page
>   */
>  int try_to_unmap(struct page *page, enum ttu_flags flags)
>  {
>  	int ret;
> -	struct rmap_private rp = {
> -		.flags = flags,
> -		.lazyfreed = 0,
> -	};
>  
>  	struct rmap_walk_control rwc = {
>  		.rmap_one = try_to_unmap_one,
> -		.arg = &rp,
> +		.arg = (void *)flags,
>  		.done = page_mapcount_is_zero,
>  		.anon_lock = page_lock_anon_vma_read,
>  	};
> @@ -1523,11 +1524,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
>  	else
>  		ret = rmap_walk(page, &rwc);
>  
> -	if (ret != SWAP_MLOCK && !page_mapcount(page)) {
> +	if (ret != SWAP_MLOCK && !page_mapcount(page))
>  		ret = SWAP_SUCCESS;
> -		if (rp.lazyfreed && !PageDirty(page))
> -			ret = SWAP_LZFREE;
> -	}
>  	return ret;
>  }
>  
> @@ -1554,14 +1552,10 @@ static int page_not_mapped(struct page *page)
>  int try_to_munlock(struct page *page)
>  {
>  	int ret;
> -	struct rmap_private rp = {
> -		.flags = TTU_MUNLOCK,
> -		.lazyfreed = 0,
> -	};
>  
>  	struct rmap_walk_control rwc = {
>  		.rmap_one = try_to_unmap_one,
> -		.arg = &rp,
> +		.arg = (void *)TTU_MUNLOCK,
>  		.done = page_not_mapped,
>  		.anon_lock = page_lock_anon_vma_read,
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 68ea50d..16ad821 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -911,7 +911,8 @@ static void page_check_dirty_writeback(struct page *page,
>  	 * Anonymous pages are not handled by flushers and must be written
>  	 * from reclaim context. Do not stall reclaim based on them
>  	 */
> -	if (!page_is_file_cache(page)) {
> +	if (!page_is_file_cache(page) ||
> +	    (PageAnon(page) && !PageSwapBacked(page))) {
>  		*dirty = false;
>  		*writeback = false;
>  		return;
> @@ -992,7 +993,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			goto keep_locked;
>  
>  		/* Double the slab pressure for mapped and swapcache pages */
> -		if (page_mapped(page) || PageSwapCache(page))
> +		if ((page_mapped(page) || PageSwapCache(page)) &&
> +		    !(PageAnon(page) && !PageSwapBacked(page)))
>  			sc->nr_scanned++;
>  
>  		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
> @@ -1118,8 +1120,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		/*
>  		 * Anonymous process memory has backing store?
>  		 * Try to allocate it some swap space here.
> +		 * Lazyfree page could be freed directly
>  		 */
> -		if (PageAnon(page) && !PageSwapCache(page)) {
> +		if (PageAnon(page) && PageSwapBacked(page) &&
> +		    !PageSwapCache(page)) {
>  			if (!(sc->gfp_mask & __GFP_IO))
>  				goto keep_locked;
>  			if (!add_to_swap(page, page_list))
> @@ -1140,9 +1144,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * The page is mapped into the page tables of one or more
>  		 * processes. Try to unmap it here.
>  		 */
> -		if (page_mapped(page) && mapping) {
> +		if (page_mapped(page)) {
>  			switch (ret = try_to_unmap(page,
>  				ttu_flags | TTU_BATCH_FLUSH)) {
> +			case SWAP_DIRTY:
> +				SetPageSwapBacked(page);
> +				/* fall through */
>  			case SWAP_FAIL:
>  				nr_unmap_fail++;
>  				goto activate_locked;
> @@ -1150,8 +1157,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				goto keep_locked;
>  			case SWAP_MLOCK:
>  				goto cull_mlocked;
> -			case SWAP_LZFREE:
> -				goto lazyfree;
>  			case SWAP_SUCCESS:
>  				; /* try to free the page below */
>  			}
> @@ -1263,10 +1268,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			}
>  		}
>  
> -lazyfree:
> -		if (!mapping || !__remove_mapping(mapping, page, true))
> -			goto keep_locked;
> +		if (PageAnon(page) && !PageSwapBacked(page)) {
> +			/* follow __remove_mapping for reference */
> +			if (!page_ref_freeze(page, 1))
> +				goto keep_locked;
> +			if (PageDirty(page)) {
> +				page_ref_unfreeze(page, 1);
> +				goto keep_locked;
> +			}
>  
> +			count_vm_event(PGLAZYFREED);
> +		} else if (!mapping || !__remove_mapping(mapping, page, true))
> +			goto keep_locked;
>  		/*
>  		 * At this point, we have no other references and there is
>  		 * no way to pick any more up (removed from LRU, removed
> @@ -1276,9 +1289,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 */
>  		__ClearPageLocked(page);
>  free_it:
> -		if (ret == SWAP_LZFREE)
> -			count_vm_event(PGLAZYFREED);
> -
>  		nr_reclaimed++;
>  
>  		/*
> -- 
> 2.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
