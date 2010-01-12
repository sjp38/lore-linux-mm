Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A528B6B007B
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 22:05:09 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C356AS012974
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 Jan 2010 12:05:06 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CBB9545DE66
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 12:05:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E21E45DE62
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 12:05:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1578EEF8004
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 12:05:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BA0481DB803B
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 12:05:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for memory free
In-Reply-To: <1263264697-1598-1-git-send-email-shijie8@gmail.com>
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com> <1263264697-1598-1-git-send-email-shijie8@gmail.com>
Message-Id: <20100112120133.B39E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Jan 2010 12:05:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org, riel@redhat.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

>   Move the {__mod_zone_page_state, pages_scanned, clear zone's flags}
> out the guard region of the spinlock to relieve the pressure for memory free.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/page_alloc.c |   27 +++++++++++++++++----------
>  1 files changed, 17 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 290dfc3..1c7e32e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -530,12 +530,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  {
>  	int migratetype = 0;
>  	int batch_free = 0;
> +	int free_ok = 0;
>  
>  	spin_lock(&zone->lock);
> -	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> -	zone->pages_scanned = 0;
> -
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
>  	while (count) {
>  		struct page *page;
>  		struct list_head *list;
> @@ -558,23 +555,33 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  			page = list_entry(list->prev, struct page, lru);
>  			/* must delete as __free_one_page list manipulates */
>  			list_del(&page->lru);
> -			__free_one_page(page, zone, 0, migratetype);
> +			free_ok += __free_one_page(page, zone, 0, migratetype);
>  			trace_mm_page_pcpu_drain(page, 0, migratetype);
>  		} while (--count && --batch_free && !list_empty(list));
>  	}
>  	spin_unlock(&zone->lock);
> +
> +	if (likely(free_ok)) {
> +		zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> +		zone->pages_scanned = 0;
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, free_ok);
> +	}
>  }

No. To introduce new branch have big performance degression risk. I don't
think this patch improve performance.

Why can't we remove this "if (free_ok)" statement?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
