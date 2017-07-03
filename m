Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0487F6B0279
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 05:09:15 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e3so195382864pfc.4
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 02:09:14 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTP id g3si3624733plb.210.2017.07.03.02.09.11
        for <linux-mm@kvack.org>;
        Mon, 03 Jul 2017 02:09:13 -0700 (PDT)
Subject: Re: [PATCH mm] introduce reverse buddy concept to reduce buddy
 fragment
References: <1498821941-55771-1-git-send-email-zhouxianrong@huawei.com>
 <20170703074829.GD3217@dhcp22.suse.cz>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <a17148b8-9d2b-4c8d-1148-463412153e1e@huawei.com>
Date: Mon, 3 Jul 2017 17:01:20 +0800
MIME-Version: 1.0
In-Reply-To: <20170703074829.GD3217@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, alexander.h.duyck@intel.com, mgorman@suse.de, l.stach@pengutronix.de, vdavydov.dev@gmail.com, hannes@cmpxchg.org, minchan@kernel.org, npiggin@gmail.com, kirill.shutemov@linux.intel.com, gi-oh.kim@profitbricks.com, luto@kernel.org, keescook@chromium.org, mark.rutland@arm.com, mingo@kernel.org, heiko.carstens@de.ibm.com, iamjoonsoo.kim@lge.com, rientjes@google.com, ming.ling@spreadtrum.com, jack@suse.cz, ebru.akagunduz@gmail.com, bigeasy@linutronix.de, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, fanghua3@huawei.com, won.ho.park@huawei.com



On 2017/7/3 15:48, Michal Hocko wrote:
> On Fri 30-06-17 19:25:41, zhouxianrong@huawei.com wrote:
>> From: zhouxianrong <zhouxianrong@huawei.com>
>>
>> when buddy is under fragment i find that still there are some pages
>> just like AFFA mode. A is allocated, F is free, AF is buddy pair for
>> oder n, FA is buddy	pair for oder n as well.
>
> Could you quantify how often does this happen and how much of a problem
> this actually is? Is there any specific workload that would suffer from
> such an artificial fragmentation?
>
>> I want to compse the
>> FF as oder n + 1 and align to n other than n + 1. this patch broke
>> the rules of buddy stated as alignment to its length of oder. i think
>> we can do so except for kernel stack because the requirement comes from
>> buddy attribution rather than user.
>
> Why do you think the stack is a problem here?
>
>> for kernel stack requirement i add
>> __GFP_NOREVERSEBUDDY for this purpose.
>>
>> a sample just like blow.
>>
>> Node 0, zone      DMA
>>   1389   1765    342    272      2      0      0      0      0      0      0
>> 	 0     75   4398   1560    379     27      2      0      0      0      0
>> Node 0, zone   Normal
>> 	20     24     14      2      0      0      0      0      0      0      0
>> 	 0      6    228      3      0      0      0      0      0      0      0
>>

at the sample moment if we have not this patch, the aspect should like below:

Node 0, zone    DMA
    (1389 + 75 * 2)   (1765 + 4398 * 2)    (342 + 1560 * 2)    (272 + 379 * 2)      (2 + 27 * 2)      (0 + 2 * 2)      0      0      0      0      0
Node 0, zone    Normal
    (20 + 6 * 2)    (24 + 228 * 2)     (14 + 3 * 2)      2      0      0      0      0      0      0      0

i find out AFFA mode in lower order free_list and move FF into higher order free_list_reverse.

>> the patch does not consider fallback allocation for now.
>
> The path is missing the crucial information required for any
> optimization. Some numbers to compare how much it helps. The above
> output of buddyinfo is pointless without any base to compare to. Also
> which workloads would benefit from this change and how much? It is also
> a non trivial amount of code in the guts of the page allocator so this
> really needs _much_ better explanation.
>
> I haven't looked closely on the code yet but a quick look at
> set_reverse_free_area scared me away.
>
>> Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
>> ---
>>  include/linux/gfp.h         |    8 +-
>>  include/linux/mmzone.h      |    2 +
>>  include/linux/page-flags.h  |    9 ++
>>  include/linux/thread_info.h |    5 +-
>>  mm/compaction.c             |   17 ++++
>>  mm/internal.h               |    7 ++
>>  mm/page_alloc.c             |  222 +++++++++++++++++++++++++++++++++++++++----
>>  mm/vmstat.c                 |    5 +-
>>  8 files changed, 251 insertions(+), 24 deletions(-)
>>
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index db373b9..f63d4d9 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -40,6 +40,7 @@
>>  #define ___GFP_DIRECT_RECLAIM	0x400000u
>>  #define ___GFP_WRITE		0x800000u
>>  #define ___GFP_KSWAPD_RECLAIM	0x1000000u
>> +#define ___GFP_NOREVERSEBUDDY	0x2000000u
>>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>>
>>  /*
>> @@ -171,6 +172,10 @@
>>   * __GFP_NOTRACK_FALSE_POSITIVE is an alias of __GFP_NOTRACK. It's a means of
>>   *   distinguishing in the source between false positives and allocations that
>>   *   cannot be supported (e.g. page tables).
>> + *
>> + * __GFP_NOREVERSEBUDDY does not allocate pages from reverse buddy list
>> + *   of current order. It make sure that allocation is alignment to same order
>> + *   with length order.
>>   */
>>  #define __GFP_COLD	((__force gfp_t)___GFP_COLD)
>>  #define __GFP_NOWARN	((__force gfp_t)___GFP_NOWARN)
>> @@ -178,9 +183,10 @@
>>  #define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)
>>  #define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)
>>  #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
>> +#define __GFP_NOREVERSEBUDDY ((__force gfp_t)___GFP_NOREVERSEBUDDY)
>>
>>  /* Room for N __GFP_FOO bits */
>> -#define __GFP_BITS_SHIFT 25
>> +#define __GFP_BITS_SHIFT 26
>>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>>
>>  /*
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 8e02b37..94237fe 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -89,7 +89,9 @@ enum {
>>
>>  struct free_area {
>>  	struct list_head	free_list[MIGRATE_TYPES];
>> +	struct list_head	free_list_reverse[MIGRATE_TYPES];
>>  	unsigned long		nr_free;
>> +	unsigned long		nr_free_reverse;
>>  };
>>
>>  struct pglist_data;
>> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
>> index 6b5818d..39d17d7 100644
>> --- a/include/linux/page-flags.h
>> +++ b/include/linux/page-flags.h
>> @@ -675,6 +675,15 @@ static inline int TestClearPageDoubleMap(struct page *page)
>>  #define PAGE_KMEMCG_MAPCOUNT_VALUE		(-512)
>>  PAGE_MAPCOUNT_OPS(Kmemcg, KMEMCG)
>>
>> +/*
>> + * ReverseBuddy is enabled for the buddy allocator that allow allocating
>> + * two adjacent same free order blocks other than buddy blocks and
>> + * composing them as a order + 1 block. It is for reducing buddy
>> + * fragment.
>> + */
>> +#define PAGE_REVERSE_BUDDY_MAPCOUNT_VALUE		(-1024)
>> +PAGE_MAPCOUNT_OPS(ReverseBuddy, REVERSE_BUDDY)
>> +
>>  extern bool is_free_buddy_page(struct page *page);
>>
>>  __PAGEFLAG(Isolated, isolated, PF_ANY);
>> diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
>> index 5837387..b4a1605 100644
>> --- a/include/linux/thread_info.h
>> +++ b/include/linux/thread_info.h
>> @@ -28,9 +28,10 @@
>>
>>  #ifdef CONFIG_DEBUG_STACK_USAGE
>>  # define THREADINFO_GFP		(GFP_KERNEL_ACCOUNT | __GFP_NOTRACK | \
>> -				 __GFP_ZERO)
>> +				 __GFP_NOREVERSEBUDDY | __GFP_ZERO)
>>  #else
>> -# define THREADINFO_GFP		(GFP_KERNEL_ACCOUNT | __GFP_NOTRACK)
>> +# define THREADINFO_GFP		(GFP_KERNEL_ACCOUNT | __GFP_NOTRACK | \
>> +				 __GFP_NOREVERSEBUDDY)
>>  #endif
>>
>>  /*
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 0fdfde0..a43f169 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -768,6 +768,20 @@ static bool too_many_isolated(struct zone *zone)
>>  			continue;
>>  		}
>>
>> +		if (PageReverseBuddy(page)) {
>> +			unsigned long freepage_order = page_order_unsafe(page);
>> +
>> +			/*
>> +			 * Without lock, we cannot be sure that what we got is
>> +			 * a valid page order. Consider only values in the
>> +			 * valid order range to prevent low_pfn overflow.
>> +			 */
>> +			if (freepage_order > 0 &&
>> +				freepage_order < MAX_ORDER - 1)
>> +				low_pfn += (1UL << (freepage_order + 1)) - 1;
>> +			continue;
>> +		}
>> +
>>  		/*
>>  		 * Regardless of being on LRU, compound pages such as THP and
>>  		 * hugetlbfs are not to be compacted. We can potentially save
>> @@ -1005,6 +1019,9 @@ static bool suitable_migration_target(struct compact_control *cc,
>>  			return false;
>>  	}
>>
>> +	if (PageReverseBuddy(page))
>> +		return false;
>> +
>>  	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
>>  	if (migrate_async_suitable(get_pageblock_migratetype(page)))
>>  		return true;
>> diff --git a/mm/internal.h b/mm/internal.h
>> index ccfc2a2..439b0a8 100644
>> --- a/mm/internal.h
>> +++ b/mm/internal.h
>> @@ -143,6 +143,13 @@ struct alloc_context {
>>  	return page_pfn ^ (1 << order);
>>  }
>>
>> +static inline unsigned long
>> +__find_reverse_buddy_pfn(unsigned long page_pfn, unsigned int order)
>> +{
>> +	return (page_pfn & (1 << order)) ? page_pfn + (1 << order) :
>> +			page_pfn - (1 << order);
>> +}
>> +
>>  extern struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
>>  				unsigned long end_pfn, struct zone *zone);
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 9f9623d..ee1dc1b 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -715,6 +715,18 @@ static inline void rmv_page_order(struct page *page)
>>  	set_page_private(page, 0);
>>  }
>>
>> +static inline void set_reverse_page_order(struct page *page, unsigned int order)
>> +{
>> +	set_page_private(page, order);
>> +	__SetPageReverseBuddy(page);
>> +}
>> +
>> +static inline void rmv_reverse_page_order(struct page *page)
>> +{
>> +	__ClearPageReverseBuddy(page);
>> +	set_page_private(page, 0);
>> +}
>> +
>>  /*
>>   * This function checks whether a page is free && is the buddy
>>   * we can do coalesce a page and its buddy if
>> @@ -758,6 +770,120 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>>  	return 0;
>>  }
>>
>> +static inline int page_is_reverse_buddy(struct page *page, struct page *buddy,
>> +							unsigned int order)
>> +{
>> +	if (PageReverseBuddy(buddy) && page_order(buddy) == order) {
>> +		/*
>> +		 * zone check is done late to avoid uselessly
>> +		 * calculating zone/node ids for pages that could
>> +		 * never merge.
>> +		 */
>> +		if (page_zone_id(page) != page_zone_id(buddy))
>> +			return 0;
>> +
>> +		VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
>> +
>> +		return 1;
>> +	}
>> +	return 0;
>> +}
>> +
>> +static inline
>> +void set_reverse_free_area(struct zone *zone, struct page *page,
>> +					unsigned int order, int migratetype)
>> +{
>> +	unsigned long buddy_pfn;
>> +	unsigned long reserve_buddy_pfn;
>> +	struct page *reverse_buddy;
>> +	struct free_area *area;
>> +
>> +	if (order > MAX_ORDER - 3)
>> +		return;
>> +	if (unlikely(is_migrate_isolate(migratetype)))
>> +		return;
>> +	buddy_pfn = page_to_pfn(page);
>> +	reserve_buddy_pfn = __find_reverse_buddy_pfn(buddy_pfn, order);
>> +	if ((buddy_pfn ^ reserve_buddy_pfn) & ~(pageblock_nr_pages - 1))
>> +		return;
>> +	if (!pfn_valid_within(reserve_buddy_pfn))
>> +		return;
>> +	reverse_buddy = pfn_to_page(reserve_buddy_pfn);
>> +	if (page_zone_id(page) != page_zone_id(reverse_buddy))
>> +		return;
>> +	if (PageBuddy(reverse_buddy) &&
>> +		page_order(reverse_buddy) == order) {
>> +		area = &zone->free_area[order];
>> +		list_del(&page->lru);
>> +		rmv_page_order(page);
>> +		area->nr_free--;
>> +		set_pcppage_migratetype(page, migratetype);
>> +		list_del(&reverse_buddy->lru);
>> +		rmv_page_order(reverse_buddy);
>> +		area->nr_free--;
>> +		set_pcppage_migratetype(reverse_buddy, migratetype);
>> +		area++;
>> +		if (buddy_pfn < reserve_buddy_pfn) {
>> +			list_add(&page->lru,
>> +					 &area->free_list_reverse[migratetype]);
>> +			area->nr_free_reverse++;
>> +			set_reverse_page_order(page, order);
>> +			set_reverse_page_order(reverse_buddy, order);
>> +		} else {
>> +			list_add(&reverse_buddy->lru,
>> +					 &area->free_list_reverse[migratetype]);
>> +			area->nr_free_reverse++;
>> +			set_reverse_page_order(reverse_buddy, order);
>> +			set_reverse_page_order(page, order);
>> +		}
>> +	}
>> +}
>> +
>> +static inline
>> +void rmv_reverse_free_area(struct zone *zone, struct page *page,
>> +					unsigned int order, int migratetype)
>> +{
>> +	unsigned long pfn, buddy_pfn;
>> +	unsigned long reserve_buddy_pfn;
>> +	struct page *buddy, *reverse_buddy;
>> +	struct free_area *area;
>> +
>> +	pfn = page_to_pfn(page);
>> +	buddy_pfn = __find_buddy_index(pfn, order);
>> +	buddy = page + (buddy_pfn - pfn);
>> +	if (!pfn_valid_within(buddy_pfn))
>> +		return;
>> +	if (!page_is_reverse_buddy(page, buddy, order))
>> +		return;
>> +
>> +	area = &zone->free_area[order];
>> +	reserve_buddy_pfn = __find_reverse_buddy_pfn(buddy_pfn, order);
>> +	reverse_buddy = pfn_to_page(reserve_buddy_pfn);
>> +	VM_BUG_ON_PAGE(!PageReverseBuddy(reverse_buddy) ||
>> +			page_order(reverse_buddy) != order, reverse_buddy);
>> +	if (buddy_pfn < reserve_buddy_pfn) {
>> +		list_move(&buddy->lru, &area->free_list[migratetype]);
>> +		rmv_reverse_page_order(buddy);
>> +		area[1].nr_free_reverse--;
>> +		area->nr_free++;
>> +		set_page_order(buddy, order);
>> +		rmv_reverse_page_order(reverse_buddy);
>> +		list_add(&reverse_buddy->lru, &area->free_list[migratetype]);
>> +		area->nr_free++;
>> +		set_page_order(reverse_buddy, order);
>> +	} else {
>> +		list_move(&reverse_buddy->lru, &area->free_list[migratetype]);
>> +		rmv_reverse_page_order(reverse_buddy);
>> +		area[1].nr_free_reverse--;
>> +		area->nr_free++;
>> +		set_page_order(reverse_buddy, order);
>> +		rmv_reverse_page_order(buddy);
>> +		list_add(&buddy->lru, &area->free_list[migratetype]);
>> +		area->nr_free++;
>> +		set_page_order(buddy, order);
>> +	}
>> +}
>> +
>>  /*
>>   * Freeing function for a buddy system allocator.
>>   *
>> @@ -805,6 +931,7 @@ static inline void __free_one_page(struct page *page,
>>  	VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
>>  	VM_BUG_ON_PAGE(bad_range(zone, page), page);
>>
>> +	rmv_reverse_free_area(zone, page, order, migratetype);
>>  continue_merging:
>>  	while (order < max_order - 1) {
>>  		buddy_pfn = __find_buddy_pfn(pfn, order);
>> @@ -882,6 +1009,7 @@ static inline void __free_one_page(struct page *page,
>>  	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
>>  out:
>>  	zone->free_area[order].nr_free++;
>> +	set_reverse_free_area(zone, page, order, migratetype);
>>  }
>>
>>  /*
>> @@ -1238,14 +1366,24 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
>>
>>  static void __free_pages_ok(struct page *page, unsigned int order)
>>  {
>> +	bool reverse_buddy;
>>  	int migratetype;
>>  	unsigned long pfn = page_to_pfn(page);
>>
>>  	if (!free_pages_prepare(page, order, true))
>>  		return;
>>
>> +	reverse_buddy = order &&
>> +		((pfn & ((1 << order) - 1)) == (1 << (order - 1)));
>>  	migratetype = get_pfnblock_migratetype(page, pfn);
>> -	free_one_page(page_zone(page), page, pfn, order, migratetype);
>> +	if (!reverse_buddy)
>> +		free_one_page(page_zone(page), page, pfn, order, migratetype);
>> +	else {
>> +		free_one_page(page_zone(page), page,
>> +			pfn, order - 1, migratetype);
>> +		free_one_page(page_zone(page), page + (1 << (order - 1)),
>> +			pfn + (1 << (order - 1)), order - 1, migratetype);
>> +	}
>>  }
>>
>>  static void __init __free_pages_boot_core(struct page *page, unsigned int order)
>> @@ -1651,6 +1789,25 @@ static inline void expand(struct zone *zone, struct page *page,
>>  	}
>>  }
>>
>> +static inline void expand_reverse(struct zone *zone, struct page *page,
>> +	int low, int high, struct free_area *area,
>> +	int migratetype)
>> +{
>> +	struct page *reverse_buddy;
>> +
>> +	reverse_buddy = page + (1 << (high - 1));
>> +	rmv_reverse_page_order(reverse_buddy);
>> +	set_pcppage_migratetype(reverse_buddy, migratetype);
>> +	if (high > low) {
>> +		area--;
>> +		high--;
>> +		expand(zone, page, low, high, area, migratetype);
>> +		list_add(&reverse_buddy->lru, &area->free_list[migratetype]);
>> +		area->nr_free++;
>> +		set_page_order(reverse_buddy, high);
>> +	}
>> +}
>> +
>>  static void check_new_page_bad(struct page *page)
>>  {
>>  	const char *bad_reason = NULL;
>> @@ -1785,25 +1942,45 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
>>   */
>>  static inline
>>  struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>> -						int migratetype)
>> +					int migratetype, gfp_t gfp_flags)
>>  {
>> +	bool reverse_buddy;
>>  	unsigned int current_order;
>>  	struct free_area *area;
>>  	struct page *page;
>>
>> +	reverse_buddy = !!(gfp_flags & __GFP_NOREVERSEBUDDY);
>>  	/* Find a page of the appropriate size in the preferred list */
>>  	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
>>  		area = &(zone->free_area[current_order]);
>>  		page = list_first_entry_or_null(&area->free_list[migratetype],
>>  							struct page, lru);
>> -		if (!page)
>> +		if (page) {
>> +			list_del(&page->lru);
>> +			rmv_page_order(page);
>> +			area->nr_free--;
>> +			expand(zone, page, order,
>> +				current_order, area, migratetype);
>> +			set_pcppage_migratetype(page, migratetype);
>> +			return page;
>> +		}
>> +		if (current_order + reverse_buddy == 0 ||
>> +			current_order + reverse_buddy > MAX_ORDER - 2)
>>  			continue;
>> -		list_del(&page->lru);
>> -		rmv_page_order(page);
>> -		area->nr_free--;
>> -		expand(zone, page, order, current_order, area, migratetype);
>> -		set_pcppage_migratetype(page, migratetype);
>> -		return page;
>> +		area += reverse_buddy;
>> +		page = list_first_entry_or_null(
>> +			&area->free_list_reverse[migratetype],
>> +			struct page, lru);
>> +		if (page) {
>> +			list_del(&page->lru);
>> +			rmv_reverse_page_order(page);
>> +			area->nr_free_reverse--;
>> +			expand_reverse(zone, page, order,
>> +				current_order + reverse_buddy,
>> +				area, migratetype);
>> +			set_pcppage_migratetype(page, migratetype);
>> +			return page;
>> +		}
>>  	}
>>
>>  	return NULL;
>> @@ -1828,13 +2005,13 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>>
>>  #ifdef CONFIG_CMA
>>  static struct page *__rmqueue_cma_fallback(struct zone *zone,
>> -					unsigned int order)
>> +		unsigned int order, gfp_t gfp_flags)
>>  {
>> -	return __rmqueue_smallest(zone, order, MIGRATE_CMA);
>> +	return __rmqueue_smallest(zone, order, MIGRATE_CMA, gfp_flags);
>>  }
>>  #else
>>  static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
>> -					unsigned int order) { return NULL; }
>> +		unsigned int order, gfp_t gfp_flags) { return NULL; }
>>  #endif
>>
>>  /*
>> @@ -2136,7 +2313,8 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
>>
>>  /* Remove an element from the buddy allocator from the fallback list */
>>  static inline struct page *
>> -__rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>> +__rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype,
>> +						gfp_t gfp_flags)
>>  {
>>  	struct free_area *area;
>>  	unsigned int current_order;
>> @@ -2190,17 +2368,18 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
>>   * Call me with the zone->lock already held.
>>   */
>>  static struct page *__rmqueue(struct zone *zone, unsigned int order,
>> -				int migratetype)
>> +				int migratetype, gfp_t gfp_flags)
>>  {
>>  	struct page *page;
>>
>> -	page = __rmqueue_smallest(zone, order, migratetype);
>> +	page = __rmqueue_smallest(zone, order, migratetype, gfp_flags);
>>  	if (unlikely(!page)) {
>>  		if (migratetype == MIGRATE_MOVABLE)
>> -			page = __rmqueue_cma_fallback(zone, order);
>> +			page = __rmqueue_cma_fallback(zone, order, gfp_flags);
>>
>>  		if (!page)
>> -			page = __rmqueue_fallback(zone, order, migratetype);
>> +			page = __rmqueue_fallback(zone, order, migratetype,
>> +						gfp_flags);
>>  	}
>>
>>  	trace_mm_page_alloc_zone_locked(page, order, migratetype);
>> @@ -2221,7 +2400,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>>
>>  	spin_lock_irqsave(&zone->lock, flags);
>>  	for (i = 0; i < count; ++i) {
>> -		struct page *page = __rmqueue(zone, order, migratetype);
>> +		struct page *page = __rmqueue(zone, order, migratetype, 0);
>>  		if (unlikely(page == NULL))
>>  			break;
>>
>> @@ -2718,12 +2897,13 @@ struct page *rmqueue(struct zone *preferred_zone,
>>  	do {
>>  		page = NULL;
>>  		if (alloc_flags & ALLOC_HARDER) {
>> -			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
>> +			page = __rmqueue_smallest(zone, order,
>> +					MIGRATE_HIGHATOMIC, gfp_flags);
>>  			if (page)
>>  				trace_mm_page_alloc_zone_locked(page, order, migratetype);
>>  		}
>>  		if (!page)
>> -			page = __rmqueue(zone, order, migratetype);
>> +			page = __rmqueue(zone, order, migratetype, gfp_flags);
>>  	} while (page && check_new_pages(page, order));
>>  	spin_unlock(&zone->lock);
>>  	if (!page)
>> @@ -5286,7 +5466,9 @@ static void __meminit zone_init_free_lists(struct zone *zone)
>>  	unsigned int order, t;
>>  	for_each_migratetype_order(order, t) {
>>  		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
>> +		INIT_LIST_HEAD(&zone->free_area[order].free_list_reverse[t]);
>>  		zone->free_area[order].nr_free = 0;
>> +		zone->free_area[order].nr_free_reverse = 0;
>>  	}
>>  }
>>
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 69f9aff..26007df 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -1146,10 +1146,13 @@ static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
>>  {
>>  	int order;
>>
>> -	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
>> +	seq_printf(m, "Node %d, zone %8s\n", pgdat->node_id, zone->name);
>>  	for (order = 0; order < MAX_ORDER; ++order)
>>  		seq_printf(m, "%6lu ", zone->free_area[order].nr_free);
>>  	seq_putc(m, '\n');
>> +	for (order = 0; order < MAX_ORDER; ++order)
>> +		seq_printf(m, "%6lu ", zone->free_area[order].nr_free_reverse);
>> +	seq_putc(m, '\n');
>>  }
>>
>>  /*
>> --
>> 1.7.9.5
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
