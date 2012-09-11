Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id A278C6B00A4
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 02:14:37 -0400 (EDT)
Date: Tue, 11 Sep 2012 15:16:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v2] memory-hotplug: remove MIGRATE_ISOLATE from
 free_area->free_list
Message-ID: <20120911061635.GA15214@bbox>
References: <1346900018-14759-1-git-send-email-minchan@kernel.org>
 <5049A216.3010307@cn.fujitsu.com>
 <20120911005253.GB14205@bbox>
 <504E95F2.6070802@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <504E95F2.6070802@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mel@csn.ul.ie>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Tue, Sep 11, 2012 at 09:37:54AM +0800, Wen Congyang wrote:
> At 09/11/2012 08:52 AM, Minchan Kim Wrote:
> > Hello Wen,
> > 
> > On Fri, Sep 07, 2012 at 03:28:22PM +0800, Wen Congyang wrote:
> >> At 09/06/2012 10:53 AM, Minchan Kim Wrote:
> >>> Normally, MIGRATE_ISOLATE type is used for memory-hotplug.
> >>> But it's irony type because the pages isolated would exist
> >>> as free page in free_area->free_list[MIGRATE_ISOLATE] so people
> >>> can think of it as allocatable pages but it is *never* allocatable.
> >>> It ends up confusing NR_FREE_PAGES vmstat so it would be
> >>> totally not accurate so some of place which depend on such vmstat
> >>> could reach wrong decision by the context.
> >>>
> >>> There were already report about it.[1]
> >>> [1] 702d1a6e, memory-hotplug: fix kswapd looping forever problem
> >>>
> >>> Then, there was other report which is other problem.[2]
> >>> [2] http://www.spinics.net/lists/linux-mm/msg41251.html
> >>>
> >>> I believe it can make problems in future, too.
> >>> So I hope removing such irony type by another design.
> >>>
> >>> I hope this patch solves it and let's revert [1] and doesn't need [2].
> >>>
> >>> * Changelog v1
> >>>  * Fix from Michal's many suggestion
> >>>
> >>> Cc: Michal Nazarewicz <mina86@mina86.com>
> >>> Cc: Mel Gorman <mel@csn.ul.ie>
> >>> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> >>> Cc: Wen Congyang <wency@cn.fujitsu.com>
> >>> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> >>> Signed-off-by: Minchan Kim <minchan@kernel.org>
> >>> ---
> >>> It's very early version which show the concept so I still marked it with RFC.
> >>> I just tested it with simple test and works.
> >>> This patch is needed indepth review from memory-hotplug guys from fujitsu
> >>> because I saw there are lots of patches recenlty they sent to about
> >>> memory-hotplug change. Please take a look at this patch.
> >>>
> >>>  drivers/xen/balloon.c          |    2 +
> >>>  include/linux/mmzone.h         |    4 +-
> >>>  include/linux/page-isolation.h |   11 ++-
> >>>  mm/internal.h                  |    3 +
> >>>  mm/memory_hotplug.c            |   38 ++++++----
> >>>  mm/page_alloc.c                |   33 ++++----
> >>>  mm/page_isolation.c            |  162 +++++++++++++++++++++++++++++++++-------
> >>>  mm/vmstat.c                    |    1 -
> >>>  8 files changed, 193 insertions(+), 61 deletions(-)
> >>>
> >>> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> >>> index 31ab82f..df0f5f3 100644
> >>> --- a/drivers/xen/balloon.c
> >>> +++ b/drivers/xen/balloon.c
> >>> @@ -50,6 +50,7 @@
> >>>  #include <linux/notifier.h>
> >>>  #include <linux/memory.h>
> >>>  #include <linux/memory_hotplug.h>
> >>> +#include <linux/page-isolation.h>
> >>>  
> >>>  #include <asm/page.h>
> >>>  #include <asm/pgalloc.h>
> >>> @@ -268,6 +269,7 @@ static void xen_online_page(struct page *page)
> >>>  	else
> >>>  		--balloon_stats.balloon_hotplug;
> >>>  
> >>> +	delete_from_isolated_list(page);
> >>>  	mutex_unlock(&balloon_mutex);
> >>>  }
> >>>  
> >>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >>> index 2daa54f..438bab8 100644
> >>> --- a/include/linux/mmzone.h
> >>> +++ b/include/linux/mmzone.h
> >>> @@ -57,8 +57,8 @@ enum {
> >>>  	 */
> >>>  	MIGRATE_CMA,
> >>>  #endif
> >>> -	MIGRATE_ISOLATE,	/* can't allocate from here */
> >>> -	MIGRATE_TYPES
> >>> +	MIGRATE_TYPES,
> >>> +	MIGRATE_ISOLATE
> >>>  };
> >>>  
> >>>  #ifdef CONFIG_CMA
> >>> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> >>> index 105077a..1ae2cd6 100644
> >>> --- a/include/linux/page-isolation.h
> >>> +++ b/include/linux/page-isolation.h
> >>> @@ -1,11 +1,16 @@
> >>>  #ifndef __LINUX_PAGEISOLATION_H
> >>>  #define __LINUX_PAGEISOLATION_H
> >>>  
> >>> +extern struct list_head isolated_pages;
> >>>  
> >>>  bool has_unmovable_pages(struct zone *zone, struct page *page, int count);
> >>>  void set_pageblock_migratetype(struct page *page, int migratetype);
> >>>  int move_freepages_block(struct zone *zone, struct page *page,
> >>>  				int migratetype);
> >>> +
> >>> +void isolate_free_page(struct page *page, unsigned int order);
> >>> +void delete_from_isolated_list(struct page *page);
> >>> +
> >>>  /*
> >>>   * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
> >>>   * If specified range includes migrate types other than MOVABLE or CMA,
> >>> @@ -20,9 +25,13 @@ start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
> >>>  			 unsigned migratetype);
> >>>  
> >>>  /*
> >>> - * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
> >>> + * Changes MIGRATE_ISOLATE to @migratetype.
> >>>   * target range is [start_pfn, end_pfn)
> >>>   */
> >>> +void
> >>> +undo_isolate_pageblocks(unsigned long start_pfn, unsigned long end_pfn,
> >>> +			unsigned migratetype);
> >>> +
> >>>  int
> >>>  undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
> >>>  			unsigned migratetype);
> >>> diff --git a/mm/internal.h b/mm/internal.h
> >>> index 3314f79..393197e 100644
> >>> --- a/mm/internal.h
> >>> +++ b/mm/internal.h
> >>> @@ -144,6 +144,9 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> >>>   * function for dealing with page's order in buddy system.
> >>>   * zone->lock is already acquired when we use these.
> >>>   * So, we don't need atomic page->flags operations here.
> >>> + *
> >>> + * Page order should be put on page->private because
> >>> + * memory-hotplug depends on it. Look mm/page_isolation.c.
> >>>   */
> >>>  static inline unsigned long page_order(struct page *page)
> >>>  {
> >>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> >>> index 3ad25f9..30c36d5 100644
> >>> --- a/mm/memory_hotplug.c
> >>> +++ b/mm/memory_hotplug.c
> >>> @@ -410,26 +410,29 @@ void __online_page_set_limits(struct page *page)
> >>>  	unsigned long pfn = page_to_pfn(page);
> >>>  
> >>>  	if (pfn >= num_physpages)
> >>> -		num_physpages = pfn + 1;
> >>> +		num_physpages = pfn + (1 << page_order(page));
> >>>  }
> >>>  EXPORT_SYMBOL_GPL(__online_page_set_limits);
> >>>  
> >>>  void __online_page_increment_counters(struct page *page)
> >>>  {
> >>> -	totalram_pages++;
> >>> +	totalram_pages += (1 << page_order(page));
> >>>  
> >>>  #ifdef CONFIG_HIGHMEM
> >>>  	if (PageHighMem(page))
> >>> -		totalhigh_pages++;
> >>> +		totalhigh_pages += (1 << page_order(page));
> >>>  #endif
> >>>  }
> >>>  EXPORT_SYMBOL_GPL(__online_page_increment_counters);
> >>>  
> >>>  void __online_page_free(struct page *page)
> >>>  {
> >>> -	ClearPageReserved(page);
> >>> -	init_page_count(page);
> >>> -	__free_page(page);
> >>> +	int i;
> >>> +	unsigned long order = page_order(page);
> >>> +	for (i = 0; i < (1 << order); i++)
> >>> +		ClearPageReserved(page + i);
> >>> +	set_page_private(page, 0);
> >>> +	__free_pages(page, order);
> >>>  }
> >>>  EXPORT_SYMBOL_GPL(__online_page_free);
> >>>  
> >>> @@ -437,26 +440,29 @@ static void generic_online_page(struct page *page)
> >>>  {
> >>>  	__online_page_set_limits(page);
> >>>  	__online_page_increment_counters(page);
> >>> +	delete_from_isolated_list(page);
> >>>  	__online_page_free(page);
> >>>  }
> >>>  
> >>>  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> >>>  			void *arg)
> >>>  {
> >>> -	unsigned long i;
> >>> +	unsigned long pfn;
> >>> +	unsigned long end_pfn = start_pfn + nr_pages;
> >>>  	unsigned long onlined_pages = *(unsigned long *)arg;
> >>> -	struct page *page;
> >>> -	if (PageReserved(pfn_to_page(start_pfn)))
> >>> -		for (i = 0; i < nr_pages; i++) {
> >>> -			page = pfn_to_page(start_pfn + i);
> >>> -			(*online_page_callback)(page);
> >>> -			onlined_pages++;
> >>> +	struct page *cursor, *tmp;
> >>> +	list_for_each_entry_safe(cursor, tmp, &isolated_pages, lru) {
> >>> +		pfn = page_to_pfn(cursor);
> >>> +		if (pfn >= start_pfn && pfn < end_pfn) {
> >>> +			(*online_page_callback)(cursor);
> >>> +			onlined_pages += (1 << page_order(cursor));
> >>>  		}
> >>> +	}
> >>> +
> >>
> >> If the memory is hotpluged, the pages are not in isolated_pages, and they
> >> can't be onlined.
> > 
> > Hmm, I can't parse your point.
> > Could you elaborate it a bit?
> 
> The driver for hotplugable memory device is acpi-memhotplug. When a memory
> device is hotpluged, add_memory() will be called. The pages of the memory
> is added into kernel in the function __add_pages():
> 
> __add_pages()
>     __add_section()
>         __add_zone()
>             memmap_init_zone() // pages are initialized here
> 
> These pages are not added into isolated_pages, so we can't online
> them because you only online isolated pages.
> 

I got it. Thanks for the clarification.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
