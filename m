Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4DD836B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 11:37:22 -0400 (EDT)
Received: by pxi5 with SMTP id 5so1634443pxi.14
        for <linux-mm@kvack.org>; Tue, 07 Sep 2010 08:37:18 -0700 (PDT)
Date: Wed, 8 Sep 2010 00:37:08 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 08/10] vmscan: isolated_lru_pages() stop neighbour
 search if neighbour cannot be isolated
Message-ID: <20100907153708.GF4620@barrios-desktop>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
 <1283770053-18833-9-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1283770053-18833-9-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 06, 2010 at 11:47:31AM +0100, Mel Gorman wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> isolate_lru_pages() does not just isolate LRU tail pages, but also isolate
> neighbour pages of the eviction page. The neighbour search does not stop even
> if neighbours cannot be isolated which is excessive as the lumpy reclaim will
> no longer result in a successful higher order allocation. This patch stops
> the PFN neighbour pages if an isolation fails and moves on to the next block.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/vmscan.c |   24 ++++++++++++++++--------
>  1 files changed, 16 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 64f9ca5..ff52b46 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1047,14 +1047,18 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  				continue;
>  
>  			/* Avoid holes within the zone. */
> -			if (unlikely(!pfn_valid_within(pfn)))
> +			if (unlikely(!pfn_valid_within(pfn))) {
> +				nr_lumpy_failed++;
>  				break;
> +			}
>  
>  			cursor_page = pfn_to_page(pfn);
>  
>  			/* Check that we have not crossed a zone boundary. */
> -			if (unlikely(page_zone_id(cursor_page) != zone_id))
> -				continue;
> +			if (unlikely(page_zone_id(cursor_page) != zone_id)) {
> +				nr_lumpy_failed++;
> +				break;
> +			}
>  
>  			/*
>  			 * If we don't have enough swap space, reclaiming of
> @@ -1062,8 +1066,10 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  			 * pointless.
>  			 */
>  			if (nr_swap_pages <= 0 && PageAnon(cursor_page) &&
> -					!PageSwapCache(cursor_page))
> -				continue;
> +			    !PageSwapCache(cursor_page)) {
> +				nr_lumpy_failed++;
> +				break;
> +			}
>  
>  			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
>  				list_move(&cursor_page->lru, dst);
> @@ -1074,9 +1080,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  					nr_lumpy_dirty++;
>  				scan++;
>  			} else {
> -				if (mode == ISOLATE_BOTH &&

Why can we remove ISOLATION_BOTH check?
Is it a intentionall behavior change?

> -						page_count(cursor_page))
> -					nr_lumpy_failed++;
> +				/* the page is freed already. */
> +				if (!page_count(cursor_page))
> +					continue;
> +				nr_lumpy_failed++;
> +				break;
>  			}
>  		}
>  	}
> -- 
> 1.7.1
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
