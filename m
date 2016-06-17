Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E556D6B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:40:16 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g13so137978186ioj.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:40:16 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id o37si19835597otc.191.2016.06.17.00.40.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 00:40:15 -0700 (PDT)
Subject: Re: [PATCH v3 0/6] Introduce ZONE_CMA
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160526080454.GA11823@shbuild888>
 <20160527052820.GA13661@js1304-P5Q-DELUXE>
 <20160527062527.GA32297@shbuild888>
 <20160527064218.GA14858@js1304-P5Q-DELUXE> <20160527072702.GA7782@shbuild888>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <5763A909.8080907@hisilicon.com>
Date: Fri, 17 Jun 2016 15:38:49 +0800
MIME-Version: 1.0
In-Reply-To: <20160527072702.GA7782@shbuild888>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Feng Tang <feng.tang@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh
 Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Yiping Xu <xuyiping@hisilicon.com>, "fujun
 (F)" <oliver.fu@hisilicon.com>, Zhuangluan Su <suzhuangluan@hisilicon.com>, Dan Zhao <dan.zhao@hisilicon.com>, saberlily.xia@hisilicon.com

Hi Kim & feng,

Thanks for the share. In our platform also has the same use case.

We only let the alloc with GFP_HIGHUSER_MOVABLE in memory.c to use cma memory.

If we add zone_cma, It seems can resolve the cma migrate issue.

But when free_hot_cold_page, we need let the cma page goto system directly not the pcp.
It can be fail while cma_alloc and cma_release. If we alloc the whole cma pages which
declared before.

On 2016/5/27 15:27, Feng Tang wrote:
> On Fri, May 27, 2016 at 02:42:18PM +0800, Joonsoo Kim wrote:
>> On Fri, May 27, 2016 at 02:25:27PM +0800, Feng Tang wrote:
>>> On Fri, May 27, 2016 at 01:28:20PM +0800, Joonsoo Kim wrote:
>>>> On Thu, May 26, 2016 at 04:04:54PM +0800, Feng Tang wrote:
>>>>> On Thu, May 26, 2016 at 02:22:22PM +0800, js1304@gmail.com wrote:
>>>>>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>>>
>>>  
>>>>>> FYI, there is another attempt [3] trying to solve this problem in lkml.
>>>>>> And, as far as I know, Qualcomm also has out-of-tree solution for this
>>>>>> problem.
>>>>>
>>>>> This may be a little off-topic :) Actually, we have used another way in
>>>>> our products, that we disable the fallback from MIGRATETYE_MOVABLE to
>>>>> MIGRATETYPE_CMA completely, and only allow free CMA memory to be used
>>>>> by file page cache (which is easy to be reclaimed by its nature). 
>>>>> We did it by adding a GFP_PAGE_CACHE to every allocation request for
>>>>> page cache, and the MM will try to pick up an available free CMA page
>>>>> first, and goes to normal path when fail. 
>>>>
>>>> Just wonder, why do you allow CMA memory to file page cache rather
>>>> than anonymous page? I guess that anonymous pages would be more easily
>>>> migrated/reclaimed than file page cache. In fact, some of our product
>>>> uses anonymous page adaptation to satisfy similar requirement by
>>>> introducing GFP_CMA. AFAIK, some of chip vendor also uses "anonymous
>>>> page first adaptation" to get better success rate.
>>>
>>> The biggest problem we faced is to allocate big chunk of CMA memory,
>>> say 256MB in a whole, or 9 pieces of 20MB buffers, so the speed
>>> is not the biggest concern, but whether all the cma pages be reclaimed.
>>
>> Okay. Our product have similar workload.
>>
>>> With the MOVABLE fallback, there may be many types of bad guys from device
>>> drivers/kernel or different subsystems, who refuse to return the borrowed
>>> cma pages, so I took a lazy way by only allowing page cache to use free
>>> cma pages, and we see good results which could pass most of the test for
>>> allocating big chunks. 
>>
>> Could you explain more about why file page cache rather than anonymous page?
>> If there is a reason, I'd like to test it by myself.
> 
> I didn't make it clear. This is not for anonymous page, but for MIGRATETYPE_MOVABLE.
> 
> following is the patch to disable the kernel default sharing (kernel 3.14)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1b5f20e..a5e698f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -974,7 +974,11 @@ static int fallbacks[MIGRATE_TYPES][4] = {
>  	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
>  	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
>  #ifdef CONFIG_CMA
> -	[MIGRATE_MOVABLE]     = { MIGRATE_CMA,         MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
> +	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
>  	[MIGRATE_CMA]         = { MIGRATE_RESERVE }, /* Never used */
>  	[MIGRATE_CMA_ISOLATE] = { MIGRATE_RESERVE }, /* Never used */
>  #else
> @@ -1414,6 +1418,18 @@ void free_hot_cold_page(struct page *page, int cold)
>  	local_irq_save(flags);
>  	__count_vm_event(PGFREE);
>  
> +#ifndef CONFIG_USE_CMA_FALLBACK
> +	if (migratetype == MIGRATE_CMA) {
> +		free_one_page(zone, page, 0, MIGRATE_CMA);
> +		local_irq_restore(flags);
> +		return;
> +	}
> +#endif
> +
> 
>>
>>> One of the customer used to use a CMA sharing patch from another vendor
>>> on our Socs, which can't pass these tests and finally took our page cache
>>> approach.
>>
>> CMA has too many problems so each vendor uses their own adaptation. I'd
>> like to solve this code fragmentation by fixing problems on upstream
>> kernel and this ZONE_CMA is one of that effort. If you can share the
>> pointer for your adaptation, it would be very helpful to me.
> 
> As I said, I started to work on CMA problem back in 2014, and faced many
> of these failure in reclamation problems. I didn't have time and capability
> to track/analyze each and every failure, but decided to go another way by
> only allowing the page cache to use CMA.  And frankly speaking, I don't have
> detailed data for performance measurement, but some rough one, that it
> did improve the cma page reclaiming and the usage rate.
> 
> Our patches was based on 3.14 (the Android Mashmallow kenrel). Earlier this
> year I finally got some free time, and worked on cleaning them for submission
> to LKML, and found your cma improving patches merged in 4.1 or 4.2, so I gave
> up as my patches is more hacky :)
> 
> The sharing patch is here FYI:
> ------
> commit fb28d4db6278df42ab2ef4996bdfd44e613ace99
> Author: Feng Tang <feng.tang@intel.com>
> Date:   Wed Jul 15 13:39:50 2015 +0800
> 
>     cma, page-cache: use cma as page cache
>     
>     This will free a lot of cma memory for system to use them
>     as page cache. Previously, cma memory is mostly preserved
>     and difficult to be shared by others, thus a big waste.
>     
>     Using them as page cache will improve the meory usage, while
>     keeping the flexibility of fast reclaiming when big cma memory
>     request comes.
>     
>     And some of the threshold values should be adjustable for
>     different platforms with different cma reserved memory, common
>     cma usage scenario and CTS test should be carefully verified
>     for those adjustment.
>     
>     Signed-off-by: Feng Tang <feng.tang@intel.com>
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 5dc12b7..3c3ab2b 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -36,6 +36,7 @@ struct vm_area_struct;
>  #define ___GFP_NO_KSWAPD	0x400000u
>  #define ___GFP_OTHER_NODE	0x800000u
>  #define ___GFP_WRITE		0x1000000u
> +#define ___GFP_CMA_PAGE_CACHE	0x2000000u
>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>  
>  /*
> @@ -123,6 +124,9 @@ struct vm_area_struct;
>  			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN | \
>  			 __GFP_NO_KSWAPD)
>  
> +/* Allocat for page cache use */
> +#define GFP_PAGE_CACHE	((__force gfp_t)___GFP_CMA_PAGE_CACHE)
> +
>  /*
>   * GFP_THISNODE does not perform any reclaim, you most likely want to
>   * use __GFP_THISNODE to allocate from a given node without fallback!
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 1710d1b..a2452f6 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -221,7 +221,7 @@ extern struct page *__page_cache_alloc(gfp_t gfp);
>  #else
>  static inline struct page *__page_cache_alloc(gfp_t gfp)
>  {
> -	return alloc_pages(gfp, 0);
> +	return alloc_pages(gfp | GFP_PAGE_CACHE, 0);
>  }
>  #endif
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 532ee0d..1b5f20e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1568,7 +1568,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>  	int cold = !!(gfp_flags & __GFP_COLD);
>  
>  again:
> -	if (likely(order == 0)) {
> +	if (likely(order == 0) && !(gfp_flags & GFP_PAGE_CACHE)) {
>  		struct per_cpu_pages *pcp;
>  		struct list_head *list;
>  
> @@ -2744,6 +2744,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET;
>  	struct mem_cgroup *memcg = NULL;
>  
> +	gfp_allowed_mask |= GFP_PAGE_CACHE;
> +
>  	gfp_mask &= gfp_allowed_mask;
>  
>  	lockdep_trace_alloc(gfp_mask);
> @@ -2753,6 +2755,25 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	if (should_fail_alloc_page(gfp_mask, order))
>  		return NULL;
>  
> +#ifdef CONFIG_CMA
> +	if (gfp_mask & GFP_PAGE_CACHE) {
> +		int nr_free = global_page_state(NR_FREE_PAGES)
> +				- totalreserve_pages;
> +		int free_cma = global_page_state(NR_FREE_CMA_PAGES);
> +
> +		/*
> +		 * Use CMA memory as page cache iff system is under memory
> +		 * pressure and free cma is big enough (>= 48M).  And these
> +		 * value should be adjustable for different platforms with
> +		 * different cma reserved memory
> +		 */
> +		if ((nr_free - free_cma) <= (48 * 1024 * 1024 / PAGE_SIZE)
> +			&& free_cma >= (48 * 1024 * 1024 / PAGE_SIZE)) {
> +			migratetype = MIGRATE_CMA;
> +		}
> +	}
> +#endif
> +
>  	/*
>  	 * Check the zones suitable for the gfp_mask contain at least one
>  	 * valid zone. It's possible to have an empty zonelist as a result
> 
> 
> 
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
