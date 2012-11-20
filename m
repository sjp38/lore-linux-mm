Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id DBB336B0088
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 09:56:26 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4660081pbc.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 06:56:26 -0800 (PST)
Message-ID: <50AB9A0B.9090105@gmail.com>
Date: Tue, 20 Nov 2012 22:56:11 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFT PATCH v1 1/5] mm: introduce new field "managed_pages" to
 struct zone
References: <20121115112454.e582a033.akpm@linux-foundation.org> <1353254850-27336-1-git-send-email-jiang.liu@huawei.com> <1353254850-27336-2-git-send-email-jiang.liu@huawei.com> <20121119153832.437c7e59.akpm@linux-foundation.org>
In-Reply-To: <20121119153832.437c7e59.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/20/2012 07:38 AM, Andrew Morton wrote:
> On Mon, 19 Nov 2012 00:07:26 +0800
> Jiang Liu <liuj97@gmail.com> wrote:
> 
>> Currently a zone's present_pages is calcuated as below, which is
>> inaccurate and may cause trouble to memory hotplug.
>> 	spanned_pages - absent_pages - memmap_pages - dma_reserve.
>>
>> During fixing bugs caused by inaccurate zone->present_pages, we found
>> zone->present_pages has been abused. The field zone->present_pages
>> may have different meanings in different contexts:
>> 1) pages existing in a zone.
>> 2) pages managed by the buddy system.
>>
>> For more discussions about the issue, please refer to:
>> http://lkml.org/lkml/2012/11/5/866
>> https://patchwork.kernel.org/patch/1346751/
>>
>> This patchset tries to introduce a new field named "managed_pages" to
>> struct zone, which counts "pages managed by the buddy system". And
>> revert zone->present_pages to count "physical pages existing in a zone",
>> which also keep in consistence with pgdat->node_present_pages.
>>
>> We will set an initial value for zone->managed_pages in function
>> free_area_init_core() and will be adjusted later if the initial value is
>> inaccurate.
>>
>> For DMA/normal zones, the initial value is set to:
>> 	(spanned_pages - absent_pages - memmap_pages - dma_reserve)
>> Later zone->managed_pages will be adjusted to the accurate value when
>> the bootmem allocator frees all free pages to the buddy system in
>> function free_all_bootmem_node() and free_all_bootmem().
>>
>> The bootmem allocator doesn't touch highmem pages, so highmem zones'
>> managed_pages is set to the accurate value "spanned_pages - absent_pages"
>> in function free_area_init_core() and won't be updated anymore.
>>
>> This patch also adds a new field "managed_pages" to /proc/zoneinfo
>> and sysrq showmem.
> 
> hoo boy, what a mess we made.  I'd like to merge these patches and get
> them into -next for some testing, but -next has stopped for a couple of
> weeks.  Oh well, let's see what can be done.
Hi Andrew,
	Really sorry for the delay. Within last a few weeks, I could only
find after work hours or weekends for programming:(

>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -480,6 +480,7 @@ struct zone {
>>  	 */
>>  	unsigned long		spanned_pages;	/* total size, including holes */
>>  	unsigned long		present_pages;	/* amount of memory (excluding holes) */
>> +	unsigned long		managed_pages;	/* pages managed by the Buddy */
> 
> Can you please add a nice big comment over these three fields which
> fully describes what they do and the relationship between them? 
> Basically that stuff that's in the changelog.
> 
> Also, the existing comment tells us that spanned_pages and
> present_pages are protected by span_seqlock but has not been updated to
> describe the locking (if any) for managed_pages.
How about this?

        /*
         * spanned_pages is the total pages spanned by the zone, including
         * holes, which is calcualted as:
         *      spanned_pages = zone_end_pfn - zone_start_pfn;
         *
         * present_pages is physical pages existing within the zone, which
         * is calculated as:
         *      present_pages = spanned_pages - absent_pages(pags in holes);
         *
         * managed_pages is present pages managed by the buddy system, which
         * is calculated as (reserved_pages includes pages allocated by the
         * bootmem allocator):
         *      managed_pages = present_pages - reserved_pages;
         *
         * So present_pages may be used by memory hotplug or memory power
         * management logic to figure out unmanaged pages by checking
         * (present_pages - managed_pages). And managed_pages should be used
         * by page allocator and vm scanner to calculate all kinds of watermarks
         * and thresholds.
         *
         * Lock Rules:
         *
         * zone_start_pfn, spanned_pages are protected by span_seqlock.
         * It is a seqlock because it has to be read outside of zone->lock,
         * and it is done in the main allocator path.  But, it is written
         * quite infrequently.
         *
         * The span_seq lock is declared along with zone->lock because it is
         * frequently read in proximity to zone->lock.  It's good to
         * give them a chance of being in the same cacheline.
         *
         * Writing access to present_pages and managed_pages at runtime should
         * be protected by lock_memory_hotplug()/unlock_memory_hotplug().
         * Any reader who can't tolerant drift of present_pages and
         * managed_pages should hold memory hotplug lock to get a stable value.
         */
        unsigned long           spanned_pages;  
        unsigned long           present_pages;  
        unsigned long           managed_pages;  


> 
>>  	/*
>>  	 * rarely used fields:
>> diff --git a/mm/bootmem.c b/mm/bootmem.c
>> index f468185..a813e5b 100644
>> --- a/mm/bootmem.c
>> +++ b/mm/bootmem.c
>> @@ -229,6 +229,15 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>>  	return count;
>>  }
>>  
>> +static void reset_node_lowmem_managed_pages(pg_data_t *pgdat)
>> +{
>> +	struct zone *z;
>> +
>> +	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
>> +		if (!is_highmem(z))
> 
> Needs a comment explaining why we skip the highmem zone, please.
How about this?
        /*
         * In free_area_init_core(), highmem zone's managed_pages is set to
         * present_pages, and bootmem allocator doesn't allocate from highmem
         * zones. So there's no need to recalculate managed_pages because all
         * highmem pages will be managed by the buddy system. Here highmem
         * zone also includes highmem movable zone.
         */


>> +			z->managed_pages = 0;
>> +}
>> +
>>
>> ...
>>
>> @@ -106,6 +106,7 @@ static void get_page_bootmem(unsigned long info,  struct page *page,
>>  void __ref put_page_bootmem(struct page *page)
>>  {
>>  	unsigned long type;
>> +	static DEFINE_MUTEX(ppb_lock);
>>  
>>  	type = (unsigned long) page->lru.next;
>>  	BUG_ON(type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
>> @@ -115,7 +116,9 @@ void __ref put_page_bootmem(struct page *page)
>>  		ClearPagePrivate(page);
>>  		set_page_private(page, 0);
>>  		INIT_LIST_HEAD(&page->lru);
>> +		mutex_lock(&ppb_lock);
>>  		__free_pages_bootmem(page, 0);
>> +		mutex_unlock(&ppb_lock);
> 
> The mutex is odd.  Nothing in the changelog, no code comment. 
> __free_pages_bootmem() is called from a lot of places but only this one
> has locking.  I'm madly guessing that the lock is here to handle two or
> more concurrent memory hotpluggings, but I shouldn't need to guess!!
Actually I'm a little hesitate whether we should add a lock here.

All callers of __free_pages_bootmem() other than put_page_bootmem() should
only be used at startup time. And currently the only caller of put_page_bootmem()
has already been protected by pgdat_resize_lock(pgdat, &flags). So there's
no real need for lock, just defensive.

I'm not sure which is the best solution here.
1) add a comments into __free_pages_bootmem() to state that the caller should
   serialize themselves.
2) Use a dedicated lock to serialize updates to zone->managed_pages, this need
   modifications to page_alloc.c and memory_hotplug.c.
3) The above solution to serialize in put_page_bootmem().
What's your suggestions here?

Thanks
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
