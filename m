Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 6DBA86B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 14:59:36 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 1 Aug 2013 12:59:35 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 133B91FF001B
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 12:54:06 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r71IxJCH172578
	for <linux-mm@kvack.org>; Thu, 1 Aug 2013 12:59:20 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r71IxHha027624
	for <linux-mm@kvack.org>; Thu, 1 Aug 2013 12:59:19 -0600
Message-ID: <51FAB000.9050407@linux.vnet.ibm.com>
Date: Thu, 01 Aug 2013 11:59:12 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hotplug: fix a drain pcp bug when offline pages
References: <51FA2800.9070706@huawei.com>
In-Reply-To: <51FA2800.9070706@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Liujiang <jiang.liu@huawei.com>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, b.zolnierkie@samsung.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 08/01/2013 02:18 AM, Xishi Qiu wrote:
> __offline_pages()
>     start_isolate_page_range()
>        set_migratetype_isolate()
>           set_pageblock_migratetype() -> this pageblock will be marked as MIGRATE_ISOLATE
>           move_freepages_block() -> pages in PageBuddy will be moved into MIGRATE_ISOLATE list
>           drain_all_pages() -> drain PCP
>              free_pcppages_bulk()
>                 mt = get_freepage_migratetype(page); -> PCP's migratetype is not MIGRATE_ISOLATE
>                 __free_one_page(page, zone, 0, mt); -> so PCP will not be freed into into MIGRATE_ISOLATE list
>
> In this case, the PCP may be allocated again, because they are not in
> PageBuddy's MIGRATE_ISOLATE list. This will cause offline_pages failed.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>   mm/page_alloc.c     |   10 ++++++----
>   mm/page_isolation.c |   15 ++++++++++++++-
>   2 files changed, 20 insertions(+), 5 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b100255..d873471 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -965,11 +965,13 @@ int move_freepages(struct zone *zone,
>   		}
>
>   		order = page_order(page);
> -		list_move(&page->lru,
> -			  &zone->free_area[order].free_list[migratetype]);
> -		set_freepage_migratetype(page, migratetype);
> +		if (get_freepage_migratetype(page) != migratetype) {
> +			list_move(&page->lru,
> +				&zone->free_area[order].free_list[migratetype]);
> +			set_freepage_migratetype(page, migratetype);
> +			pages_moved += 1 << order;
> +		}
>   		page += 1 << order;
> -		pages_moved += 1 << order;

So this looks like it changes the return from move_freepages() to be the 
"pages moved" from "the pages now belonging to the passed migrate type".

The user of move_freepages_block()'s return value (and thus the return 
value of move_freepages()) in mm/page_alloc.c expects that it is the 
original meaning. The users in page_isolation.c expect it is the new 
meaning. Those need to be reconciled.

>   	}
>
>   	return pages_moved;
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 383bdbb..ba1afc9 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -65,8 +65,21 @@ out:
>   	}
>
>   	spin_unlock_irqrestore(&zone->lock, flags);
> -	if (!ret)
> +
> +	if (!ret) {
>   		drain_all_pages();
> +		/*
> +		 * When drain_all_pages() frees cached pages into the buddy
> +		 * system, it uses the stale migratetype cached in the
> +		 * page->index field, so try to move free pages to ISOLATE
> +		 * list again.
> +		 */
> +		spin_lock_irqsave(&zone->lock, flags);
> +		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
> +		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
> +		spin_unlock_irqrestore(&zone->lock, flags);
> +	}
> +

Could we teach drain_all_pages() to use the right migrate type instead 
(or add something similar that does)? (pages could be reallocated 
between the drain_all_pages() and move_freepages_block()).

>   	return ret;
>   }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
