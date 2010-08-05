Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C48366B02AD
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 11:40:43 -0400 (EDT)
Received: by pxi7 with SMTP id 7so2824051pxi.14
        for <linux-mm@kvack.org>; Thu, 05 Aug 2010 08:40:54 -0700 (PDT)
Date: Fri, 6 Aug 2010 00:40:45 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 7/7] vmscan: isolated_lru_pages() stop neighbor search
 if neighbor can't be isolated
Message-ID: <20100805154045.GE2985@barrios-desktop>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
 <20100805151525.31CC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100805151525.31CC.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 05, 2010 at 03:16:06PM +0900, KOSAKI Motohiro wrote:
> isolate_lru_pages() doesn't only isolate LRU tail pages, but also
> isolate neighbor pages of the eviction page.
> 
> Now, the neighbor search don't stop even if neighbors can't be isolated.
> It is silly. successful higher order allocation need full contenious
> memory, even though only one page reclaim failure mean to fail making
> enough contenious memory.
> 
> Then, isolate_lru_pages() should stop to search PFN neighbor pages and
> try to search next page on LRU soon. This patch does it. Also all of
> lumpy reclaim failure account nr_lumpy_failed.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

I agree this patch. 
But I have a one question. 

> ---
>  mm/vmscan.c |   24 ++++++++++++++++--------
>  1 files changed, 16 insertions(+), 8 deletions(-)
> 
<snip>

  
>  			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
>  				list_move(&cursor_page->lru, dst);
> @@ -1074,9 +1080,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  					nr_lumpy_dirty++;
>  				scan++;
>  			} else {
> -				if (mode == ISOLATE_BOTH &&
> -						page_count(cursor_page))
> -					nr_lumpy_failed++;

sc->order = 1;
shrink_inactive_list;
isolate_pages_global with ISOLATE_INACTIVE(I mean no lumpy relcaim mode);
lumpy relcaim in inactive list in isolate_lru_pages;
(But I am not sure we can call it as lumpy reclaim. but at lesat I think 
it a part of lumpy reclaim)
I mean it can reclaim physical pfn order not LRU order in inactive list since
it only consider sc->order.  Is it a intentional?

I guess it's intentional since we care of ISOLATE_BOTH when we increase nr_lumpy_failed. 
If it is, Shouldn't we care of ISOLATE_BOTH still?


> +				/* the page is freed already. */
> +				if (!page_count(cursor_page))
> +					continue;
> +				nr_lumpy_failed++;
> +				break;
>  			}
>  		}
>  	}
> -- 
> 1.6.5.2
> 


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
