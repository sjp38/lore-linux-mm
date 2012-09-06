Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id E4F8F6B00A3
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 22:03:33 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EAB693EE0C2
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 11:03:31 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D348745DE3E
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 11:03:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B161B45DE58
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 11:03:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E0C5B1DB8056
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 11:03:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 76A351DB8053
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 11:03:30 +0900 (JST)
Message-ID: <50480447.4030007@jp.fujitsu.com>
Date: Thu, 06 Sep 2012 11:02:47 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: use get_page_migratetype instead of page_private
References: <1346829962-31989-1-git-send-email-minchan@kernel.org> <1346829962-31989-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1346829962-31989-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/09/05 16:26), Minchan Kim wrote:
> page allocator uses set_page_private and page_private for handling
> migratetype when it frees page. Let's replace them with [set|get]
> _page_migratetype to make it more clear.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Hmm. one request from me.

> ---
>   include/linux/mm.h  |   10 ++++++++++
>   mm/page_alloc.c     |   11 +++++++----
>   mm/page_isolation.c |    2 +-
>   3 files changed, 18 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5c76634..86d61d6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -249,6 +249,16 @@ struct inode;
>   #define page_private(page)		((page)->private)
>   #define set_page_private(page, v)	((page)->private = (v))
>   
> +static inline void set_page_migratetype(struct page *page, int migratetype)
> +{
> +	set_page_private(page, migratetype);
> +}
> +
> +static inline int get_page_migratetype(struct page *page)
> +{
> +	return page_private(page);
> +}
> +

Could you add comments to explain "when this function returns expected value" ?
These functions can work well only in very restricted area of codes.

By the way, does these functions should be static-inline ?

Thanks,
-Kame

>   /*
>    * FIXME: take this include out, include page-flags.h in
>    * files which need it (119 of them)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 710d91c..103ba66 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -671,8 +671,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>   			/* must delete as __free_one_page list manipulates */
>   			list_del(&page->lru);
>   			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> -			__free_one_page(page, zone, 0, page_private(page));
> -			trace_mm_page_pcpu_drain(page, 0, page_private(page));
> +			__free_one_page(page, zone, 0,
> +				get_page_migratetype(page));
> +			trace_mm_page_pcpu_drain(page, 0,
> +				get_page_migratetype(page));
>   		} while (--to_free && --batch_free && !list_empty(list));
>   	}
>   	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
> @@ -731,6 +733,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>   	__count_vm_events(PGFREE, 1 << order);
>   	free_one_page(page_zone(page), page, order,
>   					get_pageblock_migratetype(page));
> +
>   	local_irq_restore(flags);
>   }
>   
> @@ -1134,7 +1137,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>   			if (!is_migrate_cma(mt) && mt != MIGRATE_ISOLATE)
>   				mt = migratetype;
>   		}
> -		set_page_private(page, mt);
> +		set_page_migratetype(page, mt);
>   		list = &page->lru;
>   	}
>   	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> @@ -1301,7 +1304,7 @@ void free_hot_cold_page(struct page *page, int cold)
>   		return;
>   
>   	migratetype = get_pageblock_migratetype(page);
> -	set_page_private(page, migratetype);
> +	set_page_migratetype(page, migratetype);
>   	local_irq_save(flags);
>   	if (unlikely(wasMlocked))
>   		free_page_mlock(page);
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 64abb33..acf65a7 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -199,7 +199,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
>   		if (PageBuddy(page))
>   			pfn += 1 << page_order(page);
>   		else if (page_count(page) == 0 &&
> -				page_private(page) == MIGRATE_ISOLATE)
> +				get_page_migratetype(page) == MIGRATE_ISOLATE)
>   			pfn += 1;
>   		else
>   			break;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
