Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A022F6B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 06:26:07 -0500 (EST)
Date: Mon, 18 Jan 2010 11:25:54 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/4] mm/page_alloc : modify the return type of
	__free_one_page
Message-ID: <20100118112554.GC7499@csn.ul.ie>
References: <1263184634-15447-1-git-send-email-shijie8@gmail.com> <1263184634-15447-2-git-send-email-shijie8@gmail.com> <1263184634-15447-3-git-send-email-shijie8@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1263184634-15447-3-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 11, 2010 at 12:37:13PM +0800, Huang Shijie wrote:
>   Modify the return type for __free_one_page.
> It will return 1 on success, and return 0 when
> the check of the compound page is failed.
> 

Why?

I assume it's something to do with patch 4, but it's unclear at this
point why it's necessary. A brief explanation is needed in the
changelog.

> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/page_alloc.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 00aa83a..290dfc3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -445,17 +445,18 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>   * triggers coalescing into a block of larger size.            
>   *
>   * -- wli
> + *
> + *  Returns 1 on success, else return 0;
>   */
>  
> -static inline void __free_one_page(struct page *page,
> -		struct zone *zone, unsigned int order,
> -		int migratetype)
> +static inline int __free_one_page(struct page *page, struct zone *zone,
> +		       unsigned int order, int migratetype)
>  {
>  	unsigned long page_idx;
>  
>  	if (unlikely(PageCompound(page)))
>  		if (unlikely(destroy_compound_page(page, order)))
> -			return;
> +			return 0;
>  
>  	VM_BUG_ON(migratetype == -1);
>  
> @@ -485,6 +486,7 @@ static inline void __free_one_page(struct page *page,
>  	list_add(&page->lru,
>  		&zone->free_area[order].free_list[migratetype]);
>  	zone->free_area[order].nr_free++;
> +	return 1;
>  }
>  
>  /*
> -- 
> 1.6.5.2
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
