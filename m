Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB1C9003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 08:27:17 -0400 (EDT)
Received: by pacgq8 with SMTP id gq8so24079960pac.3
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 05:27:17 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id i3si26280231pdp.75.2015.08.03.05.27.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 05:27:16 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so73847544pdr.2
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 05:27:16 -0700 (PDT)
Date: Mon, 3 Aug 2015 21:27:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] vmscan: reclaim_clean_pages_from_list() must count
 mlocked pages
Message-ID: <20150803122509.GA29929@bgram>
References: <1438597107-18329-1-git-send-email-jaewon31.kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438597107-18329-1-git-send-email-jaewon31.kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

Hello,

On Mon, Aug 03, 2015 at 07:18:27PM +0900, Jaewon Kim wrote:
> reclaim_clean_pages_from_list() decreases NR_ISOLATED_FILE by returned
> value from shrink_page_list(). But mlocked pages in the isolated
> clean_pages page list would be removed from the list but not counted as
> nr_reclaimed. Fix this miscounting by returning the number of mlocked
> pages and count it.

If there are pages not able to reclaim, VM try to migrate it and
have to handle the stat in migrate_pages.
If migrate_pages fails again, putback-fiends should handle it.

Is there anyting I am missing now?

Thanks.

> 
> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> ---
>  mm/vmscan.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5e8eadd..5837695 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -849,6 +849,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				      unsigned long *ret_nr_congested,
>  				      unsigned long *ret_nr_writeback,
>  				      unsigned long *ret_nr_immediate,
> +				      unsigned long *ret_nr_mlocked,
>  				      bool force_reclaim)
>  {
>  	LIST_HEAD(ret_pages);
> @@ -1158,6 +1159,7 @@ cull_mlocked:
>  			try_to_free_swap(page);
>  		unlock_page(page);
>  		putback_lru_page(page);
> +		(*ret_nr_mlocked)++;
>  		continue;
>  
>  activate_locked:
> @@ -1197,6 +1199,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  		.may_unmap = 1,
>  	};
>  	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
> +	unsigned long nr_mlocked = 0;
>  	struct page *page, *next;
>  	LIST_HEAD(clean_pages);
>  
> @@ -1210,8 +1213,10 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  
>  	ret = shrink_page_list(&clean_pages, zone, &sc,
>  			TTU_UNMAP|TTU_IGNORE_ACCESS,
> -			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
> +			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5,
> +			&nr_mlocked, true);
>  	list_splice(&clean_pages, page_list);
> +	ret += nr_mlocked;
>  	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
>  	return ret;
>  }
> @@ -1523,6 +1528,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	unsigned long nr_unqueued_dirty = 0;
>  	unsigned long nr_writeback = 0;
>  	unsigned long nr_immediate = 0;
> +	unsigned long nr_mlocked = 0;
>  	isolate_mode_t isolate_mode = 0;
>  	int file = is_file_lru(lru);
>  	struct zone *zone = lruvec_zone(lruvec);
> @@ -1565,7 +1571,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  
>  	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
>  				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
> -				&nr_writeback, &nr_immediate,
> +				&nr_writeback, &nr_immediate, &nr_mlocked,
>  				false);
>  
>  	spin_lock_irq(&zone->lru_lock);
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
