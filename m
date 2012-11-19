Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 35BDC6B006C
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 18:38:34 -0500 (EST)
Date: Mon, 19 Nov 2012 15:38:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFT PATCH v1 1/5] mm: introduce new field "managed_pages" to
 struct zone
Message-Id: <20121119153832.437c7e59.akpm@linux-foundation.org>
In-Reply-To: <1353254850-27336-2-git-send-email-jiang.liu@huawei.com>
References: <20121115112454.e582a033.akpm@linux-foundation.org>
	<1353254850-27336-1-git-send-email-jiang.liu@huawei.com>
	<1353254850-27336-2-git-send-email-jiang.liu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 19 Nov 2012 00:07:26 +0800
Jiang Liu <liuj97@gmail.com> wrote:

> Currently a zone's present_pages is calcuated as below, which is
> inaccurate and may cause trouble to memory hotplug.
> 	spanned_pages - absent_pages - memmap_pages - dma_reserve.
> 
> During fixing bugs caused by inaccurate zone->present_pages, we found
> zone->present_pages has been abused. The field zone->present_pages
> may have different meanings in different contexts:
> 1) pages existing in a zone.
> 2) pages managed by the buddy system.
> 
> For more discussions about the issue, please refer to:
> http://lkml.org/lkml/2012/11/5/866
> https://patchwork.kernel.org/patch/1346751/
> 
> This patchset tries to introduce a new field named "managed_pages" to
> struct zone, which counts "pages managed by the buddy system". And
> revert zone->present_pages to count "physical pages existing in a zone",
> which also keep in consistence with pgdat->node_present_pages.
> 
> We will set an initial value for zone->managed_pages in function
> free_area_init_core() and will be adjusted later if the initial value is
> inaccurate.
> 
> For DMA/normal zones, the initial value is set to:
> 	(spanned_pages - absent_pages - memmap_pages - dma_reserve)
> Later zone->managed_pages will be adjusted to the accurate value when
> the bootmem allocator frees all free pages to the buddy system in
> function free_all_bootmem_node() and free_all_bootmem().
> 
> The bootmem allocator doesn't touch highmem pages, so highmem zones'
> managed_pages is set to the accurate value "spanned_pages - absent_pages"
> in function free_area_init_core() and won't be updated anymore.
> 
> This patch also adds a new field "managed_pages" to /proc/zoneinfo
> and sysrq showmem.

hoo boy, what a mess we made.  I'd like to merge these patches and get
them into -next for some testing, but -next has stopped for a couple of
weeks.  Oh well, let's see what can be done.

> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -480,6 +480,7 @@ struct zone {
>  	 */
>  	unsigned long		spanned_pages;	/* total size, including holes */
>  	unsigned long		present_pages;	/* amount of memory (excluding holes) */
> +	unsigned long		managed_pages;	/* pages managed by the Buddy */

Can you please add a nice big comment over these three fields which
fully describes what they do and the relationship between them? 
Basically that stuff that's in the changelog.

Also, the existing comment tells us that spanned_pages and
present_pages are protected by span_seqlock but has not been updated to
describe the locking (if any) for managed_pages.

>  	/*
>  	 * rarely used fields:
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index f468185..a813e5b 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -229,6 +229,15 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>  	return count;
>  }
>  
> +static void reset_node_lowmem_managed_pages(pg_data_t *pgdat)
> +{
> +	struct zone *z;
> +
> +	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
> +		if (!is_highmem(z))

Needs a comment explaining why we skip the highmem zone, please.

> +			z->managed_pages = 0;
> +}
> +
>
> ...
>
> @@ -106,6 +106,7 @@ static void get_page_bootmem(unsigned long info,  struct page *page,
>  void __ref put_page_bootmem(struct page *page)
>  {
>  	unsigned long type;
> +	static DEFINE_MUTEX(ppb_lock);
>  
>  	type = (unsigned long) page->lru.next;
>  	BUG_ON(type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
> @@ -115,7 +116,9 @@ void __ref put_page_bootmem(struct page *page)
>  		ClearPagePrivate(page);
>  		set_page_private(page, 0);
>  		INIT_LIST_HEAD(&page->lru);
> +		mutex_lock(&ppb_lock);
>  		__free_pages_bootmem(page, 0);
> +		mutex_unlock(&ppb_lock);

The mutex is odd.  Nothing in the changelog, no code comment. 
__free_pages_bootmem() is called from a lot of places but only this one
has locking.  I'm madly guessing that the lock is here to handle two or
more concurrent memory hotpluggings, but I shouldn't need to guess!!

>  	}
>  
>  }
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
