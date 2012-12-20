Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id EC4D66B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 12:26:08 -0500 (EST)
Received: by mail-ia0-f169.google.com with SMTP id r4so3125338iaj.28
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 09:26:08 -0800 (PST)
Message-ID: <50D34A29.4090306@gmail.com>
Date: Thu, 20 Dec 2012 12:26:01 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix zone_watermark_ok_safe() accounting of isolated
 pages
References: <201212181018.41753.b.zolnierkie@samsung.com> <20121220005704.GA2556@blaptop>
In-Reply-To: <20121220005704.GA2556@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Hugh Dickins <hughd@google.com>, Kyungmin Park <kyungmin.park@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, kosaki.motohiro@gmail.com

> 2. Another approach. Let's avoid a branch in free_one_page if we don't enable
>    CONFIG_MEMORY_ISOLATION? It's simpler/less-churning/more accurate/removing
>    unnecessary codes compared to 1.
> 
> index 7e208f0..35c0e82 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -683,8 +683,12 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
>         zone->pages_scanned = 0;
>  
>         __free_one_page(page, zone, order, migratetype);
> +#ifdef CONFIG_MEMORY_ISOLATION
>         if (unlikely(migratetype != MIGRATE_ISOLATE))
>                 __mod_zone_freepage_state(zone, 1 << order, migratetype);
> +#else
> +       __mod_zone_freepage_state(zone, 1 << order, migratetype);
> +#endif
>         spin_unlock(&zone->lock);
>  }
> 
> So I will
> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> 
> Then, will send 2 as follow-up patch soon if anyone doesn't oppose.

I agree. I guess we can remove this branch completely from free page fast path.
However your patch is good first step.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
