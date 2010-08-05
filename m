Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A42646B02B2
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 11:12:51 -0400 (EDT)
Date: Thu, 5 Aug 2010 16:12:37 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/7] vmscan: synchrounous lumpy reclaim use lock_page()
	instead trylock_page()
Message-ID: <20100805151237.GG25688@csn.ul.ie>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com> <20100805151304.31C0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100805151304.31C0.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 05, 2010 at 03:13:39PM +0900, KOSAKI Motohiro wrote:
> When synchrounous lumpy reclaim, there is no reason to give up to
> reclaim pages even if page is locked. We use lock_page() instead
> trylock_page() in this case.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

The intention of the code looks fine so;

Acked-by: Mel Gorman <mel@csn.ul.ie>

Something like the following might just be easier on the eye but it's a
question of personal taste.

/* Returns true if the page is locked */
static bool lru_lock_page(struct page *page, enum pageout_io sync_writeback)
{
	if (likely(sync_writeback == PAGEOUT_IO_ASYNC))
		return trylock_page(page);

	lock_page(page);
	return true;
}

then replace trylock_page() with lru_lock_page(). The naming is vaguely
similar to other helpers like lru_to_page

> ---
>  mm/vmscan.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1cdc3db..833b6ad 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -665,7 +665,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		page = lru_to_page(page_list);
>  		list_del(&page->lru);
>  
> -		if (!trylock_page(page))
> +		if (sync_writeback == PAGEOUT_IO_SYNC)
> +			lock_page(page);
> +		else if (!trylock_page(page))
>  			goto keep;
>  
>  		VM_BUG_ON(PageActive(page));
> -- 
> 1.6.5.2
> 
> 
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
