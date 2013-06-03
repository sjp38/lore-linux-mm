Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 996676B0002
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 01:40:50 -0400 (EDT)
Date: Mon, 3 Jun 2013 14:40:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [v4][PATCH 1/6] mm: swap: defer clearing of page_private() for
 swap cache pages
Message-ID: <20130603054048.GA27858@blaptop>
References: <20130531183855.44DDF928@viggo.jf.intel.com>
 <20130531183856.1D7D75AD@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130531183856.1D7D75AD@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On Fri, May 31, 2013 at 11:38:56AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This patch defers the destruction of swapcache-specific data in
> 'struct page'.  This simplifies the code because we do not have
> to keep extra copies of the data during the removal of a page
> from the swap cache.
> 
> There are only two callers of swapcache_free() which actually
> pass in a non-NULL 'struct page'.  Both of them (__remove_mapping
> and delete_from_swap_cache())  create a temporary on-stack
> 'swp_entry_t' and set entry.val to page_private().
> 
> They need to do this since __delete_from_swap_cache() does
> set_page_private(page, 0) and destroys the information.
> 
> However, I'd like to batch a few of these operations on several
> pages together in a new version of __remove_mapping(), and I
> would prefer not to have to allocate temporary storage for each
> page.  The code is pretty ugly, and it's a bit silly to create
> these on-stack 'swp_entry_t's when it is so easy to just keep the
> information around in 'struct page'.
> 
> There should not be any danger in doing this since we are
> absolutely on the path of freeing these page.  There is no
> turning back, and no other rerferences can be obtained after it
> comes out of the radix tree.
> 
> Note: This patch is separate from the next one since it
> introduces the behavior change.  I've seen issues with this patch
> by itself in various forms and I think having it separate like
> this aids bisection.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Acked-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Minchan Kim <minchan@kernel.org>

Look at below nitpick.

> ---
> 
>  linux.git-davehans/mm/swap_state.c |    4 ++--
>  linux.git-davehans/mm/vmscan.c     |    2 ++
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff -puN mm/swap_state.c~__delete_from_swap_cache-dont-clear-page-private mm/swap_state.c
> --- linux.git/mm/swap_state.c~__delete_from_swap_cache-dont-clear-page-private	2013-05-30 16:07:50.630079404 -0700
> +++ linux.git-davehans/mm/swap_state.c	2013-05-30 16:07:50.635079624 -0700
> @@ -148,8 +148,6 @@ void __delete_from_swap_cache(struct pag
>  	entry.val = page_private(page);
>  	address_space = swap_address_space(entry);
>  	radix_tree_delete(&address_space->page_tree, page_private(page));
> -	set_page_private(page, 0);
> -	ClearPageSwapCache(page);
>  	address_space->nrpages--;
>  	__dec_zone_page_state(page, NR_FILE_PAGES);
>  	INC_CACHE_INFO(del_total);
> @@ -226,6 +224,8 @@ void delete_from_swap_cache(struct page
>  	spin_unlock_irq(&address_space->tree_lock);
>  
>  	swapcache_free(entry, page);
> +	set_page_private(page, 0);
> +	ClearPageSwapCache(page);
>  	page_cache_release(page);
>  }
>  
> diff -puN mm/vmscan.c~__delete_from_swap_cache-dont-clear-page-private mm/vmscan.c
> --- linux.git/mm/vmscan.c~__delete_from_swap_cache-dont-clear-page-private	2013-05-30 16:07:50.632079492 -0700
> +++ linux.git-davehans/mm/vmscan.c	2013-05-30 16:07:50.637079712 -0700
> @@ -494,6 +494,8 @@ static int __remove_mapping(struct addre
>  		__delete_from_swap_cache(page);
>  		spin_unlock_irq(&mapping->tree_lock);
>  		swapcache_free(swap, page);
> +		set_page_private(page, 0);
> +		ClearPageSwapCache(page);

It it worth to support non-atomic version of ClearPageSwapCache?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
