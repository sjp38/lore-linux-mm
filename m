Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 4B13F6B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 23:50:49 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A28E33EE0BD
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 12:50:47 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 88E8345DE50
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 12:50:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6758945DD74
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 12:50:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B7451DB803C
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 12:50:47 +0900 (JST)
Received: from g01jpexchkw02.g01.fujitsu.local (g01jpexchkw02.g01.fujitsu.local [10.0.194.41])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1383A1DB8038
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 12:50:47 +0900 (JST)
Message-ID: <50496F05.1020603@jp.fujitsu.com>
Date: Fri, 7 Sep 2012 12:50:29 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/4] use get_freepage_migratetype instead of page_private
References: <1346978372-17903-1-git-send-email-minchan@kernel.org> <1346978372-17903-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1346978372-17903-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

2012/09/07 9:39, Minchan Kim wrote:
> page allocator uses set_page_private and page_private for handling
> migratetype when it frees page. Let's replace them with [set|get]
> _freepage_migratetype to make it more clear.
> 
> * from v2
>    * Add Acked-by of Kame
> 
> * from v1
>    * Change set_page_migratetype with set_freepage_migratetype
>    * Add comment on set_freepage_migratetype
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

> ---
>   include/linux/mm.h  |   12 ++++++++++++
>   mm/page_alloc.c     |   10 ++++++----
>   mm/page_isolation.c |    2 +-
>   3 files changed, 19 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0514fe9..84d1663f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -237,6 +237,18 @@ struct inode;
>   #define page_private(page)		((page)->private)
>   #define set_page_private(page, v)	((page)->private = (v))
>   
> +/* It's valid only if the page is free path or free_list */
> +static inline void set_freepage_migratetype(struct page *page, int migratetype)
> +{
> +	set_page_private(page, migratetype);
> +}
> +
> +/* It's valid only if the page is free path or free_list */
> +static inline int get_freepage_migratetype(struct page *page)
> +{
> +	return page_private(page);
> +}
> +
>   /*
>    * FIXME: take this include out, include page-flags.h in
>    * files which need it (119 of them)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ba3100a..f5ba236 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -671,8 +671,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>   			/* must delete as __free_one_page list manipulates */
>   			list_del(&page->lru);
>   			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> -			__free_one_page(page, zone, 0, page_private(page));
> -			trace_mm_page_pcpu_drain(page, 0, page_private(page));
> +			__free_one_page(page, zone, 0,
> +				get_freepage_migratetype(page));
> +			trace_mm_page_pcpu_drain(page, 0,
> +				get_freepage_migratetype(page));
>   		} while (--to_free && --batch_free && !list_empty(list));
>   	}
>   	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
> @@ -1134,7 +1136,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>   			if (!is_migrate_cma(mt) && mt != MIGRATE_ISOLATE)
>   				mt = migratetype;
>   		}
> -		set_page_private(page, mt);
> +		set_freepage_migratetype(page, mt);
>   		list = &page->lru;
>   	}
>   	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> @@ -1301,7 +1303,7 @@ void free_hot_cold_page(struct page *page, int cold)
>   		return;
>   
>   	migratetype = get_pageblock_migratetype(page);
> -	set_page_private(page, migratetype);
> +	set_freepage_migratetype(page, migratetype);
>   	local_irq_save(flags);
>   	if (unlikely(wasMlocked))
>   		free_page_mlock(page);
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 247d1f1..87a7929 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -196,7 +196,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
>   		if (PageBuddy(page))
>   			pfn += 1 << page_order(page);
>   		else if (page_count(page) == 0 &&
> -				page_private(page) == MIGRATE_ISOLATE)
> +			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
>   			pfn += 1;
>   		else
>   			break;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
