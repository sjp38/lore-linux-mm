Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB0A6B0389
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 21:12:22 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 1so15871781pgz.5
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 18:12:22 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m1si5928508plb.1.2017.02.23.18.12.20
        for <linux-mm@kvack.org>;
        Thu, 23 Feb 2017 18:12:21 -0800 (PST)
Date: Fri, 24 Feb 2017 11:12:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V4 4/6] mm: reclaim MADV_FREE pages
Message-ID: <20170224021218.GD9818@bbox>
References: <cover.1487788131.git.shli@fb.com>
 <94eccf0fcf927f31377a60d7a9f900b7e743fb06.1487788131.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <94eccf0fcf927f31377a60d7a9f900b7e743fb06.1487788131.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed, Feb 22, 2017 at 10:50:42AM -0800, Shaohua Li wrote:
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
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---
>  include/linux/rmap.h |  2 +-
>  mm/huge_memory.c     |  2 ++
>  mm/madvise.c         |  1 +
>  mm/rmap.c            | 10 ++++++++--
>  mm/vmscan.c          | 34 ++++++++++++++++++++++------------
>  5 files changed, 34 insertions(+), 15 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index e2cd8f9..2bfd8c6 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -300,6 +300,6 @@ static inline int page_mkclean(struct page *page)
>  #define SWAP_AGAIN	1
>  #define SWAP_FAIL	2
>  #define SWAP_MLOCK	3
> -#define SWAP_LZFREE	4
> +#define SWAP_DIRTY	4

Could you write down about SWAP_DIRTY in try_to_unmap's description?

< snip >

> diff --git a/mm/rmap.c b/mm/rmap.c
> index c621088..083f32e 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1424,6 +1424,12 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  				dec_mm_counter(mm, MM_ANONPAGES);
>  				rp->lazyfreed++;
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
> @@ -1525,8 +1531,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
>  
>  	if (ret != SWAP_MLOCK && !page_mapcount(page)) {
>  		ret = SWAP_SUCCESS;
> -		if (rp.lazyfreed && !PageDirty(page))
> -			ret = SWAP_LZFREE;
> +		if (rp.lazyfreed && PageDirty(page))
> +			ret = SWAP_DIRTY;

Hmm, I don't understand why we need to introduce new return value.
Can't we set SetPageSwapBacked and return SWAP_FAIL in try_to_unmap_one?

>  	}
>  	return ret;
>  }
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 68ea50d..830981a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c

< snip >
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
> +		if (PageAnon(page) && !PageSwapCache(page) &&
> +		    PageSwapBacked(page)) {
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
