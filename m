Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7816B0260
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:05:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n8so1837344wmg.4
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 06:05:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13si2483281edk.214.2017.10.26.06.04.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 06:04:58 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
 <20171019025111.GA3852@js1304-P5Q-DELUXE>
 <20171019071503.e7w5fo35lsq6ca54@dhcp22.suse.cz>
 <20171019073355.GA4486@js1304-P5Q-DELUXE>
 <20171019082041.5zudpqacaxjhe4gw@dhcp22.suse.cz>
 <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <76e4290b-47b9-6c6f-bce6-befc30713083@suse.cz>
Date: Thu, 26 Oct 2017 15:04:55 +0200
MIME-Version: 1.0
In-Reply-To: <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 10/19/2017 02:21 PM, Michal Hocko wrote:
> On Thu 19-10-17 10:20:41, Michal Hocko wrote:
>> On Thu 19-10-17 16:33:56, Joonsoo Kim wrote:
>>> On Thu, Oct 19, 2017 at 09:15:03AM +0200, Michal Hocko wrote:
>>>> On Thu 19-10-17 11:51:11, Joonsoo Kim wrote:
>> [...]
>>>>> Hello,
>>>>>
>>>>> This patch will break the CMA user. As you mentioned, CMA allocation
>>>>> itself isn't migrateable. So, after a single page is allocated through
>>>>> CMA allocation, has_unmovable_pages() will return true for this
>>>>> pageblock. Then, futher CMA allocation request to this pageblock will
>>>>> fail because it requires isolating the pageblock.
>>>>
>>>> Hmm, does this mean that the CMA allocation path depends on
>>>> has_unmovable_pages to return false here even though the memory is not
>>>> movable? This sounds really strange to me and kind of abuse of this
>>>
>>> Your understanding is correct. Perhaps, abuse or wrong function name.
>>>
>>>> function. Which path is that? Can we do the migrate type test theres?
>>>
>>> alloc_contig_range() -> start_isolate_page_range() ->
>>> set_migratetype_isolate() -> has_unmovable_pages()
>>
>> I see. It seems that the CMA and memory hotplug have a very different
>> view on what should happen during isolation.
>>  
>>> We can add one argument, 'XXX' to set_migratetype_isolate() and change
>>> it to check migrate type rather than has_unmovable_pages() if 'XXX' is
>>> specified.
>>
>> Can we use the migratetype argument and do the special thing for
>> MIGRATE_CMA? Like the following diff?
> 
> And with the full changelog.
> ---
> From 8cbd811d741f5dd93d1b21bb3ef94482a4d0bd32 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 19 Oct 2017 14:14:02 +0200
> Subject: [PATCH] mm: distinguish CMA and MOVABLE isolation in
>  has_unmovable_pages
> 
> Joonsoo has noticed that "mm: drop migrate type checks from
> has_unmovable_pages" would break CMA allocator because it relies on
> has_unmovable_pages returning false even for CMA pageblocks which in
> fact don't have to be movable:
> alloc_contig_range
>   start_isolate_page_range
>     set_migratetype_isolate
>       has_unmovable_pages
> 
> This is a result of the code sharing between CMA and memory hotplug
> while each one has a different idea of what has_unmovable_pages should
> return. This is unfortunate but fixing it properly would require a lot
> of code duplication.
> 
> Fix the issue by introducing the requested migrate type argument
> and special case MIGRATE_CMA case where CMA page blocks are handled
> properly. This will work for memory hotplug because it requires
> MIGRATE_MOVABLE.
> 
> Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/linux/page-isolation.h |  2 +-
>  mm/page_alloc.c                | 12 +++++++++++-
>  mm/page_isolation.c            | 10 +++++-----
>  3 files changed, 17 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index d4cd2014fa6f..fa9db0c7b54e 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -30,7 +30,7 @@ static inline bool is_migrate_isolate(int migratetype)
>  #endif
>  
>  bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> -			 bool skip_hwpoisoned_pages);
> +			 int migratetype, bool skip_hwpoisoned_pages);
>  void set_pageblock_migratetype(struct page *page, int migratetype);
>  int move_freepages_block(struct zone *zone, struct page *page,
>  				int migratetype, int *num_movable);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b4d85ae445c..259aeb22462f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7344,6 +7344,7 @@ void *__init alloc_large_system_hash(const char *tablename,
>   * race condition. So you can't expect this function should be exact.
>   */
>  bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> +			 int migratetype,
>  			 bool skip_hwpoisoned_pages)
>  {
>  	unsigned long pfn, iter, found;
> @@ -7356,6 +7357,15 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	if (zone_idx(zone) == ZONE_MOVABLE)
>  		return false;
>  
> +	/*
> +	 * CMA allocations (alloc_contig_range) really need to mark isolate
> +	 * CMA pageblocks even when they are not movable in fact so consider
> +	 * them movable here.
> +	 */
> +	if (is_migrate_cma(migratetype) &&
> +			is_migrate_cma(get_pageblock_migratetype(page)))
> +		return false;
> +
>  	pfn = page_to_pfn(page);
>  	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
>  		unsigned long check = pfn + iter;
> @@ -7441,7 +7451,7 @@ bool is_pageblock_removable_nolock(struct page *page)
>  	if (!zone_spans_pfn(zone, pfn))
>  		return false;
>  
> -	return !has_unmovable_pages(zone, page, 0, true);
> +	return !has_unmovable_pages(zone, page, 0, MIGRATE_MOVABLE, true);
>  }
>  
>  #if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 757410d9f758..8616f5332c77 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -14,7 +14,7 @@
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/page_isolation.h>
>  
> -static int set_migratetype_isolate(struct page *page,
> +static int set_migratetype_isolate(struct page *page, int migratetype,
>  				bool skip_hwpoisoned_pages)
>  {
>  	struct zone *zone;
> @@ -51,7 +51,7 @@ static int set_migratetype_isolate(struct page *page,
>  	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
>  	 * We just check MOVABLE pages.
>  	 */
> -	if (!has_unmovable_pages(zone, page, arg.pages_found,
> +	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype,
>  				 skip_hwpoisoned_pages))
>  		ret = 0;
>  
> @@ -63,14 +63,14 @@ static int set_migratetype_isolate(struct page *page,
>  out:
>  	if (!ret) {
>  		unsigned long nr_pages;
> -		int migratetype = get_pageblock_migratetype(page);
> +		int mt = get_pageblock_migratetype(page);
>  
>  		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>  		zone->nr_isolate_pageblock++;
>  		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE,
>  									NULL);
>  
> -		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
> +		__mod_zone_freepage_state(zone, -nr_pages, mt);
>  	}
>  
>  	spin_unlock_irqrestore(&zone->lock, flags);
> @@ -182,7 +182,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  	     pfn += pageblock_nr_pages) {
>  		page = __first_valid_page(pfn, pageblock_nr_pages);
>  		if (page &&
> -		    set_migratetype_isolate(page, skip_hwpoisoned_pages)) {
> +		    set_migratetype_isolate(page, migratetype, skip_hwpoisoned_pages)) {
>  			undo_pfn = pfn;
>  			goto undo;
>  		}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
