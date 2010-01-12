Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 68DF86B007D
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 22:03:35 -0500 (EST)
Date: Tue, 12 Jan 2010 11:03:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
	memory free
Message-ID: <20100112030330.GA20034@localhost>
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com> <1263264697-1598-1-git-send-email-shijie8@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1263264697-1598-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Shijie,

> +	int free_ok;
>  
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> -	__free_one_page(page, zone, order, migratetype);
> +	spin_lock(&zone->lock);
> +	free_ok = __free_one_page(page, zone, order, migratetype);
>  	spin_unlock(&zone->lock);
> +
> +	if (likely(free_ok)) {
> +		zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> +		zone->pages_scanned = 0;
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, free_ok << order);
> +	}

If we do
        __mod_zone_page_state(zone, -NR_FREE_PAGES, count);
in __free_one_page() on error, we can remove the likely(free_ok) test.

This sounds a bit hacky though.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
