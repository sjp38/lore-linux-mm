Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 9DB706B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 18:01:34 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so2444376pbb.14
        for <linux-mm@kvack.org>; Thu, 23 Aug 2012 15:01:33 -0700 (PDT)
Date: Fri, 24 Aug 2012 07:01:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC]swap: add a simple random read swapin detection
Message-ID: <20120823220124.GB2066@barrios>
References: <20120822034044.GB24099@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120822034044.GB24099@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, fengguang.wu@intel.com

Hi Shaohua,

On Wed, Aug 22, 2012 at 11:40:44AM +0800, Shaohua Li wrote:
> The swapin readahead does a blind readahead regardless if the swapin is
> sequential. This is ok for harddisk and random read, because read big size has
> no penality in harddisk, and if the readahead pages are garbage, they can be
> reclaimed fastly. But for SSD, big size read is more expensive than small size
> read. If readahead pages are garbage, such readahead only has overhead.
> 
> This patch addes a simple random read detection like what file mmap readahead
> does. If random read is detected, swapin readahead will be skipped. This
> improves a lot for a swap workload with random IO in a fast SSD.
> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> ---
>  include/linux/mm_types.h |    1 +
>  mm/memory.c              |    3 ++-
>  mm/swap_state.c          |    9 +++++++++
>  3 files changed, 12 insertions(+), 1 deletion(-)
> 
> Index: linux/mm/swap_state.c
> ===================================================================
> --- linux.orig/mm/swap_state.c	2012-08-21 23:01:43.825613437 +0800
> +++ linux/mm/swap_state.c	2012-08-22 10:38:36.687902916 +0800
> @@ -351,6 +351,7 @@ struct page *read_swap_cache_async(swp_e
>  	return found_page;
>  }
>  
> +#define SWAPRA_MISS  (100)
>  /**
>   * swapin_readahead - swap in pages in hope we need them soon
>   * @entry: swap entry of this memory
> @@ -379,6 +380,13 @@ struct page *swapin_readahead(swp_entry_
>  	unsigned long mask = (1UL << page_cluster) - 1;
>  	struct blk_plug plug;
>  
> +	if (vma) {
> +		if (atomic_read(&vma->swapra_miss) < SWAPRA_MISS * 10)
> +			atomic_inc(&vma->swapra_miss);
> +		if (atomic_read(&vma->swapra_miss) > SWAPRA_MISS)
> +			goto skip;
> +	}
> +
>  	/* Read a page_cluster sized and aligned cluster around offset. */
>  	start_offset = offset & ~mask;
>  	end_offset = offset | mask;
> @@ -397,5 +405,6 @@ struct page *swapin_readahead(swp_entry_
>  	blk_finish_plug(&plug);
>  
>  	lru_add_drain();	/* Push any new pages onto the LRU now */
> +skip:
>  	return read_swap_cache_async(entry, gfp_mask, vma, addr);
>  }
> Index: linux/include/linux/mm_types.h
> ===================================================================
> --- linux.orig/include/linux/mm_types.h	2012-08-21 23:02:01.969385586 +0800
> +++ linux/include/linux/mm_types.h	2012-08-22 10:37:59.028376385 +0800
> @@ -279,6 +279,7 @@ struct vm_area_struct {
>  #ifdef CONFIG_NUMA
>  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>  #endif
> +	atomic_t swapra_miss;

#ifdef CONFIG_SWAP
	atomic_t swapra_miss;
#endif

Many embedded devices don't have swap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
