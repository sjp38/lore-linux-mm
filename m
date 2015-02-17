Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1E16B0070
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 04:46:07 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id a1so17467052wgh.12
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 01:46:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pc2si27688587wic.121.2015.02.17.01.46.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Feb 2015 01:46:05 -0800 (PST)
Message-ID: <54E30DDC.6050403@suse.cz>
Date: Tue, 17 Feb 2015 10:46:04 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3/3] mm/compaction: enhance compaction finish condition
References: <1423725305-3726-1-git-send-email-iamjoonsoo.kim@lge.com> <1423725305-3726-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423725305-3726-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 02/12/2015 08:15 AM, Joonsoo Kim wrote:
> Compaction has anti fragmentation algorithm. It is that freepage
> should be more than pageblock order to finish the compaction if we don't
> find any freepage in requested migratetype buddy list. This is for
> mitigating fragmentation, but, there is a lack of migratetype
> consideration and it is too excessive compared to page allocator's anti
> fragmentation algorithm.
>
> Not considering migratetype would cause premature finish of compaction.
> For example, if allocation request is for unmovable migratetype,
> freepage with CMA migratetype doesn't help that allocation and
> compaction should not be stopped. But, current logic regards this
> situation as compaction is no longer needed, so finish the compaction.
>
> Secondly, condition is too excessive compared to page allocator's logic.
> We can steal freepage from other migratetype and change pageblock
> migratetype on more relaxed conditions in page allocator. This is designed
> to prevent fragmentation and we can use it here. Imposing hard constraint
> only to the compaction doesn't help much in this case since page allocator
> would cause fragmentation again.
>
> To solve these problems, this patch borrows anti fragmentation logic from
> page allocator. It will reduce premature compaction finish in some cases
> and reduce excessive compaction work.
>
> stress-highalloc test in mmtests with non movable order 7 allocation shows
> considerable increase of compaction success rate.
>
> Compaction success rate (Compaction success * 100 / Compaction stalls, %)
> 31.82 : 42.20
>
> I tested it on non-reboot 5 runs stress-highalloc benchmark and found that
> there is no more degradation on allocation success rate than before. That
> roughly means that this patch doesn't result in more fragmentations.
>
> Vlastimil suggests additional idea that we only test for fallbacks
> when migration scanner has scanned a whole pageblock. It looked good for
> fragmentation because chance of stealing increase due to making more
> free pages in certain pageblock. So, I tested it, but, it results in
> decreased compaction success rate, roughly 38.00. I guess the reason that
> if system is low memory condition, watermark check could be failed due to
> not enough order 0 free page and so, sometimes, we can't reach a fallback
> check although migrate_pfn is aligned to pageblock_nr_pages. I can insert
> code to cope with this situation but it makes code more complicated so
> I don't include his idea at this patch.

Hm that's weird. I'll try to investigate this later. Meanwhile it can 
stay as it is.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

But you'll need to fix:

> ---
>   mm/compaction.c |   14 ++++++++++++--
>   mm/internal.h   |    2 ++
>   mm/page_alloc.c |   19 ++++++++++++++-----
>   3 files changed, 28 insertions(+), 7 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 782772d..d40c426 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1170,13 +1170,23 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
>   	/* Direct compactor: Is a suitable page free? */
>   	for (order = cc->order; order < MAX_ORDER; order++) {
>   		struct free_area *area = &zone->free_area[order];
> +		bool can_steal;
>
>   		/* Job done if page is free of the right migratetype */
>   		if (!list_empty(&area->free_list[migratetype]))
>   			return COMPACT_PARTIAL;
>
> -		/* Job done if allocation would set block type */
> -		if (order >= pageblock_order && area->nr_free)
> +		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
> +		if (migratetype == MIGRATE_MOVABLE &&
> +			!list_empty(&area->free_list[MIGRATE_CMA]))

This won't compile with !CONFIG_CMA, right? I recall pointing it on v3 
already (or something similar elsewhere).

> +			return COMPACT_PARTIAL;
> +
> +		/*
> +		 * Job done if allocation would steal freepages from
> +		 * other migratetype buddy lists.
> +		 */
> +		if (find_suitable_fallback(area, order, migratetype,
> +						true, &can_steal) != -1)
>   			return COMPACT_PARTIAL;
>   	}
>
> diff --git a/mm/internal.h b/mm/internal.h
> index c4d6c9b..9640650 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -200,6 +200,8 @@ isolate_freepages_range(struct compact_control *cc,
>   unsigned long
>   isolate_migratepages_range(struct compact_control *cc,
>   			   unsigned long low_pfn, unsigned long end_pfn);
> +int find_suitable_fallback(struct free_area *area, unsigned int order,
> +			int migratetype, bool only_stealable, bool *can_steal);
>
>   #endif
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 64a4974..95654f9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1191,9 +1191,14 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>   		set_pageblock_migratetype(page, start_type);
>   }
>
> -/* Check whether there is a suitable fallback freepage with requested order. */
> -static int find_suitable_fallback(struct free_area *area, unsigned int order,
> -					int migratetype, bool *can_steal)
> +/*
> + * Check whether there is a suitable fallback freepage with requested order.
> + * If only_stealable is true, this function returns fallback_mt only if
> + * we can steal other freepages all together. This would help to reduce
> + * fragmentation due to mixed migratetype pages in one pageblock.
> + */
> +int find_suitable_fallback(struct free_area *area, unsigned int order,
> +			int migratetype, bool only_stealable, bool *can_steal)
>   {
>   	int i;
>   	int fallback_mt;
> @@ -1213,7 +1218,11 @@ static int find_suitable_fallback(struct free_area *area, unsigned int order,
>   		if (can_steal_fallback(order, migratetype))
>   			*can_steal = true;
>
> -		return fallback_mt;
> +		if (!only_stealable)
> +			return fallback_mt;
> +
> +		if (*can_steal)
> +			return fallback_mt;

Why not just single if (!only_stealable || *can_steal)

>   	}
>
>   	return -1;
> @@ -1235,7 +1244,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>   				--current_order) {
>   		area = &(zone->free_area[current_order]);
>   		fallback_mt = find_suitable_fallback(area, current_order,
> -				start_migratetype, &can_steal);
> +				start_migratetype, false, &can_steal);
>   		if (fallback_mt == -1)
>   			continue;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
