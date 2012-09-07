Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 2539B6B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 23:51:52 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 439DE3EE0B6
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 12:51:50 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 27E5845DE51
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 12:51:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 05B8145DE4D
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 12:51:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ECBC41DB803F
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 12:51:49 +0900 (JST)
Received: from g01jpexchkw04.g01.fujitsu.local (g01jpexchkw04.g01.fujitsu.local [10.0.194.43])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A903A1DB803B
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 12:51:49 +0900 (JST)
Message-ID: <50496F43.60603@jp.fujitsu.com>
Date: Fri, 7 Sep 2012 12:51:31 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/4] mm: remain migratetype in freed page
References: <1346978372-17903-1-git-send-email-minchan@kernel.org> <1346978372-17903-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1346978372-17903-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

2012/09/07 9:39, Minchan Kim wrote:
> The page allocator caches the pageblock information in page->private while
> it is in the PCP freelists but this is overwritten with the order of the
> page when freed to the buddy allocator. This patch stores the migratetype
> of the page in the page->index field so that it is available at all times
> when the page remain in free_list.
> 
> This patch adds a new call site in __free_pages_ok so it might be
> overhead a bit but it's for high order allocation.
> So I believe damage isn't hurt.
> 
> * from v2
>    * Add Acked-by of Kame
> 
> * from v1
>    * Fix move_freepages's migratetype - Mel
>    * Add more kind explanation in description - Mel
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

> ---
>   include/linux/mm.h |    4 ++--
>   mm/page_alloc.c    |    7 +++++--
>   2 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 84d1663f..68f9e8d 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -240,13 +240,13 @@ struct inode;
>   /* It's valid only if the page is free path or free_list */
>   static inline void set_freepage_migratetype(struct page *page, int migratetype)
>   {
> -	set_page_private(page, migratetype);
> +	page->index = migratetype;
>   }
>   
>   /* It's valid only if the page is free path or free_list */
>   static inline int get_freepage_migratetype(struct page *page)
>   {
> -	return page_private(page);
> +	return page->index;
>   }
>   
>   /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f5ba236..8531fa3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -723,6 +723,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>   {
>   	unsigned long flags;
>   	int wasMlocked = __TestClearPageMlocked(page);
> +	int migratetype;
>   
>   	if (!free_pages_prepare(page, order))
>   		return;
> @@ -731,8 +732,9 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>   	if (unlikely(wasMlocked))
>   		free_page_mlock(page);
>   	__count_vm_events(PGFREE, 1 << order);
> -	free_one_page(page_zone(page), page, order,
> -					get_pageblock_migratetype(page));
> +	migratetype = get_pageblock_migratetype(page);
> +	set_freepage_migratetype(page, migratetype);
> +	free_one_page(page_zone(page), page, order, migratetype);
>   	local_irq_restore(flags);
>   }
>   
> @@ -952,6 +954,7 @@ static int move_freepages(struct zone *zone,
>   		order = page_order(page);
>   		list_move(&page->lru,
>   			  &zone->free_area[order].free_list[migratetype]);
> +		set_freepage_migratetype(page, migratetype);
>   		page += 1 << order;
>   		pages_moved += 1 << order;
>   	}
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
