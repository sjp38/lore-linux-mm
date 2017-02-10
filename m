Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9A26B0389
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 08:23:26 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id x4so10834037wme.3
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:23:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t185si1188665wmt.113.2017.02.10.05.23.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 05:23:25 -0800 (PST)
Date: Fri, 10 Feb 2017 14:23:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 3/7] mm: reclaim MADV_FREE pages
Message-ID: <20170210132323.GL10893@dhcp22.suse.cz>
References: <cover.1486163864.git.shli@fb.com>
 <9426fa2cf9fe320a15bfb20744c451eb6af1710a.1486163864.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9426fa2cf9fe320a15bfb20744c451eb6af1710a.1486163864.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri 03-02-17 15:33:19, Shaohua Li wrote:
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

Ohh, so this is where the convoluted part sits ;) I thought we just
check for references/dirty bit and make lazy free page regular anon
again and activate it. lazyfree checks in shrink_page_list seem to
be quite excessive to me. Maybe I am just oversimplifying it, though.
 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---
>  mm/rmap.c   |  4 ++++
>  mm/vmscan.c | 43 +++++++++++++++++++++++++++++++------------
>  2 files changed, 35 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index c8d6204..5f05926 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1554,6 +1554,10 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			dec_mm_counter(mm, MM_ANONPAGES);
>  			rp->lazyfreed++;
>  			goto discard;
> +		} else if (flags & TTU_LZFREE) {
> +			set_pte_at(mm, address, pte, pteval);
> +			ret = SWAP_FAIL;
> +			goto out_unmap;
>  		}
>  
>  		if (swap_duplicate(entry) < 0) {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 947ab6f..b304a84 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -864,7 +864,7 @@ static enum page_references page_check_references(struct page *page,
>  		return PAGEREF_RECLAIM;
>  
>  	if (referenced_ptes) {
> -		if (PageSwapBacked(page))
> +		if (PageSwapBacked(page) || PageAnon(page))
>  			return PAGEREF_ACTIVATE;
>  		/*
>  		 * All mapped pages start out with page table
> @@ -903,7 +903,7 @@ static enum page_references page_check_references(struct page *page,
>  
>  /* Check if a page is dirty or under writeback */
>  static void page_check_dirty_writeback(struct page *page,
> -				       bool *dirty, bool *writeback)
> +			bool *dirty, bool *writeback, bool lazyfree)
>  {
>  	struct address_space *mapping;
>  
> @@ -911,7 +911,7 @@ static void page_check_dirty_writeback(struct page *page,
>  	 * Anonymous pages are not handled by flushers and must be written
>  	 * from reclaim context. Do not stall reclaim based on them
>  	 */
> -	if (!page_is_file_cache(page)) {
> +	if (!page_is_file_cache(page) || lazyfree) {
>  		*dirty = false;
>  		*writeback = false;
>  		return;
> @@ -971,7 +971,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		int may_enter_fs;
>  		enum page_references references = PAGEREF_RECLAIM_CLEAN;
>  		bool dirty, writeback;
> -		bool lazyfree = false;
> +		bool lazyfree;
>  		int ret = SWAP_SUCCESS;
>  
>  		cond_resched();
> @@ -986,6 +986,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  		sc->nr_scanned++;
>  
> +		lazyfree = page_is_lazyfree(page);
> +
>  		if (unlikely(!page_evictable(page)))
>  			goto cull_mlocked;
>  
> @@ -993,7 +995,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			goto keep_locked;
>  
>  		/* Double the slab pressure for mapped and swapcache pages */
> -		if (page_mapped(page) || PageSwapCache(page))
> +		if ((page_mapped(page) || PageSwapCache(page)) && !lazyfree)
>  			sc->nr_scanned++;
>  
>  		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
> @@ -1005,7 +1007,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * will stall and start writing pages if the tail of the LRU
>  		 * is all dirty unqueued pages.
>  		 */
> -		page_check_dirty_writeback(page, &dirty, &writeback);
> +		page_check_dirty_writeback(page, &dirty, &writeback, lazyfree);
>  		if (dirty || writeback)
>  			nr_dirty++;
>  
> @@ -1107,6 +1109,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			; /* try to reclaim the page below */
>  		}
>  
> +		/* lazyfree page could be freed directly */
> +		if (lazyfree) {
> +			if (unlikely(PageTransHuge(page)) &&
> +			    split_huge_page_to_list(page, page_list))
> +				goto keep_locked;
> +			goto unmap_page;
> +		}
> +
>  		/*
>  		 * Anonymous process memory has backing store?
>  		 * Try to allocate it some swap space here.
> @@ -1116,7 +1126,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				goto keep_locked;
>  			if (!add_to_swap(page, page_list))
>  				goto activate_locked;
> -			lazyfree = true;
>  			may_enter_fs = 1;
>  
>  			/* Adding to swap updated mapping */
> @@ -1128,12 +1137,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		}
>  
>  		VM_BUG_ON_PAGE(PageTransHuge(page), page);
> -
> +unmap_page:
>  		/*
>  		 * The page is mapped into the page tables of one or more
>  		 * processes. Try to unmap it here.
>  		 */
> -		if (page_mapped(page) && mapping) {
> +		if (page_mapped(page) && (mapping || lazyfree)) {
>  			switch (ret = try_to_unmap(page, lazyfree ?
>  				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
>  				(ttu_flags | TTU_BATCH_FLUSH))) {
> @@ -1145,7 +1154,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			case SWAP_MLOCK:
>  				goto cull_mlocked;
>  			case SWAP_LZFREE:
> -				goto lazyfree;
> +				/* follow __remove_mapping for reference */
> +				if (page_ref_freeze(page, 1)) {
> +					if (!PageDirty(page))
> +						goto lazyfree;
> +					else
> +						page_ref_unfreeze(page, 1);
> +				}
> +				goto keep_locked;
>  			case SWAP_SUCCESS:
>  				; /* try to free the page below */
>  			}
> @@ -1257,10 +1273,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			}
>  		}
>  
> -lazyfree:
>  		if (!mapping || !__remove_mapping(mapping, page, true))
>  			goto keep_locked;
> -
> +lazyfree:
>  		/*
>  		 * At this point, we have no other references and there is
>  		 * no way to pick any more up (removed from LRU, removed
> @@ -1285,6 +1300,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  cull_mlocked:
>  		if (PageSwapCache(page))
>  			try_to_free_swap(page);
> +		if (lazyfree)
> +			SetPageSwapBacked(page);
>  		unlock_page(page);
>  		list_add(&page->lru, &ret_pages);
>  		continue;
> @@ -1294,6 +1311,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
>  			try_to_free_swap(page);
>  		VM_BUG_ON_PAGE(PageActive(page), page);
> +		if (lazyfree)
> +			SetPageSwapBacked(page);
>  		SetPageActive(page);
>  		pgactivate++;
>  keep_locked:
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
