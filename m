Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1C560021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 06:27:35 -0500 (EST)
Date: Mon, 7 Dec 2009 12:27:05 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/7] Replace page_mapping_inuse() with page_mapped()
Message-ID: <20091207112705.GA5772@cmpxchg.org>
References: <20091204173233.5891.A69D9226@jp.fujitsu.com> <20091204174016.5894.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091204174016.5894.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 04, 2009 at 05:41:35PM +0900, KOSAKI Motohiro wrote:
> From c0cd3ee2bb13567a36728600a86f43abac3125b5 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Wed, 2 Dec 2009 12:05:26 +0900
> Subject: [PATCH 1/7] Replace page_mapping_inuse() with page_mapped()
> 
> page reclaim logic need to distingish mapped and unmapped pages.
> However page_mapping_inuse() don't provide proper test way. it test
> the address space (i.e. file) is mmpad(). Why `page' reclaim need
> care unrelated page's mapped state? it's unrelated.
> 
> Thus, This patch replace page_mapping_inuse() with page_mapped()
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

> ---
>  mm/vmscan.c |   25 ++-----------------------
>  1 files changed, 2 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index da6cf42..4ba08da 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -262,27 +262,6 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
>  	return ret;
>  }
>  
> -/* Called without lock on whether page is mapped, so answer is unstable */
> -static inline int page_mapping_inuse(struct page *page)
> -{
> -	struct address_space *mapping;
> -
> -	/* Page is in somebody's page tables. */
> -	if (page_mapped(page))
> -		return 1;
> -
> -	/* Be more reluctant to reclaim swapcache than pagecache */
> -	if (PageSwapCache(page))
> -		return 1;
> -
> -	mapping = page_mapping(page);
> -	if (!mapping)
> -		return 0;
> -
> -	/* File is mmap'd by somebody? */
> -	return mapping_mapped(mapping);
> -}
> -
>  static inline int is_page_cache_freeable(struct page *page)
>  {
>  	/*
> @@ -649,7 +628,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * try_to_unmap moves it to unevictable list
>  		 */
>  		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
> -					referenced && page_mapping_inuse(page)
> +					referenced && page_mapped(page)
>  					&& !(vm_flags & VM_LOCKED))
>  			goto activate_locked;
>  
> @@ -1356,7 +1335,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  		}
>  
>  		/* page_referenced clears PageReferenced */
> -		if (page_mapping_inuse(page) &&
> +		if (page_mapped(page) &&
>  		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
>  			nr_rotated++;
>  			/*
> -- 
> 1.6.5.2
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
