Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 53D8C6B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 09:39:31 -0400 (EDT)
Date: Mon, 6 Sep 2010 14:39:15 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUGFIX][PATCH 1/3] memory hotplug: fix next block calculation
	in is_removable
Message-ID: <20100906133914.GL8384@csn.ul.ie>
References: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com> <20100906144228.4ee5a738.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100906144228.4ee5a738.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, fengguang.wu@intel.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, andi.kleen@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 06, 2010 at 02:42:28PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> next_active_pageblock() is for finding next _used_ freeblock. It skips
> several blocks when it finds there are a chunk of free pages lager than
> pageblock. But it has 2 bugs.
> 
>   1. We have no lock. page_order(page) - pageblock_order can be minus.
>   2. pageblocks_stride += is wrong. it should skip page_order(p) of pages.
> 
> CC: stable@kernel.org
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memory_hotplug.c |   16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> Index: kametest/mm/memory_hotplug.c
> ===================================================================
> --- kametest.orig/mm/memory_hotplug.c
> +++ kametest/mm/memory_hotplug.c
> @@ -584,19 +584,19 @@ static inline int pageblock_free(struct 
>  /* Return the start of the next active pageblock after a given page */
>  static struct page *next_active_pageblock(struct page *page)
>  {
> -	int pageblocks_stride;
> -
>  	/* Ensure the starting page is pageblock-aligned */
>  	BUG_ON(page_to_pfn(page) & (pageblock_nr_pages - 1));
>  
> -	/* Move forward by at least 1 * pageblock_nr_pages */
> -	pageblocks_stride = 1;
> -
>  	/* If the entire pageblock is free, move to the end of free page */
> -	if (pageblock_free(page))
> -		pageblocks_stride += page_order(page) - pageblock_order;
> +	if (pageblock_free(page)) {
> +		int order;
> +		/* be careful. we don't have locks, page_order can be changed.*/
> +		order = page_order(page);
> +		if (order > pageblock_order)
> +			return page + (1 << order);
> +	}

As you note in your changelog, page_order() is unsafe because we do not have
the zone lock but you don't check if order is somewhere between pageblock_order
and MAX_ORDER_NR_PAGES. How is this safer?

>  
> -	return page + (pageblocks_stride * pageblock_nr_pages);
> +	return page + pageblock_nr_pages;
>  }
>  
>  /* Checks if this range of memory is likely to be hot-removable. */
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
