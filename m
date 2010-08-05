Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 854656B02AF
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 10:16:23 -0400 (EDT)
Received: by pwj7 with SMTP id 7so80549pwj.14
        for <linux-mm@kvack.org>; Thu, 05 Aug 2010 07:17:14 -0700 (PDT)
Date: Thu, 5 Aug 2010 23:17:06 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 3/7] vmscan: synchrounous lumpy reclaim use lock_page()
 instead trylock_page()
Message-ID: <20100805141706.GB2985@barrios-desktop>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
 <20100805151304.31C0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100805151304.31C0.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 05, 2010 at 03:13:39PM +0900, KOSAKI Motohiro wrote:
> When synchrounous lumpy reclaim, there is no reason to give up to
> reclaim pages even if page is locked. We use lock_page() instead
> trylock_page() in this case.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
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

Hmm. We can make sure lumpy already doesn't select the page locked?
I mean below scenario. 

LRU head -> page A -> page B -> LRU tail

lock_page(page A)
some_function()
direct reclaim
select victim page B
enter lumpy mode 
select victim page A as well as page B
shrink_page_list
lock_page(page A)


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
