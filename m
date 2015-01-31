Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 86A3D6B0032
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 10:58:18 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id n4so23986367qaq.12
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 07:58:18 -0800 (PST)
Received: from BLU004-OMC2S18.hotmail.com (blu004-omc2s18.hotmail.com. [65.55.111.93])
        by mx.google.com with ESMTPS id w5si18331095qad.21.2015.01.31.07.58.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 31 Jan 2015 07:58:17 -0800 (PST)
Message-ID: <BLU436-SMTP337E19C27F309D20380A81833E0@phx.gbl>
Date: Sat, 31 Jan 2015 23:58:03 +0800
From: Zhang Yanfei <zhangyanfei.ok@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/4] mm/compaction: enhance compaction finish condition
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com> <1422621252-29859-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1422621252-29859-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

At 2015/1/30 20:34, Joonsoo Kim wrote:
> From: Joonsoo <iamjoonsoo.kim@lge.com>
> 
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

Changing both two behaviours in compaction may change the high order allocation
behaviours in the buddy allocator slowpath, so just as Vlastimil suggested,
some data from allocator should be necessary and helpful, IMHO.

Thanks. 

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
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/mmzone.h |  3 +++
>  mm/compaction.c        | 30 ++++++++++++++++++++++++++++--
>  mm/internal.h          |  1 +
>  mm/page_alloc.c        |  5 ++---
>  4 files changed, 34 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index f279d9c..a2906bc 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -63,6 +63,9 @@ enum {
>  	MIGRATE_TYPES
>  };
>  
> +#define FALLBACK_MIGRATETYPES (4)
> +extern int fallbacks[MIGRATE_TYPES][FALLBACK_MIGRATETYPES];
> +
>  #ifdef CONFIG_CMA
>  #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
>  #else
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 782772d..0460e4b 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1125,6 +1125,29 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>  }
>  
> +static bool can_steal_fallbacks(struct free_area *area,
> +			unsigned int order, int migratetype)
> +{
> +	int i;
> +	int fallback_mt;
> +
> +	if (area->nr_free == 0)
> +		return false;
> +
> +	for (i = 0; i < FALLBACK_MIGRATETYPES; i++) {
> +		fallback_mt = fallbacks[migratetype][i];
> +		if (fallback_mt == MIGRATE_RESERVE)
> +			break;
> +
> +		if (list_empty(&area->free_list[fallback_mt]))
> +			continue;
> +
> +		if (can_steal_freepages(order, migratetype, fallback_mt))
> +			return true;
> +	}
> +	return false;
> +}
> +
>  static int __compact_finished(struct zone *zone, struct compact_control *cc,
>  			    const int migratetype)
>  {
> @@ -1175,8 +1198,11 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
>  		if (!list_empty(&area->free_list[migratetype]))
>  			return COMPACT_PARTIAL;
>  
> -		/* Job done if allocation would set block type */
> -		if (order >= pageblock_order && area->nr_free)
> +		/*
> +		 * Job done if allocation would steal freepages from
> +		 * other migratetype buddy lists.
> +		 */
> +		if (can_steal_fallbacks(area, order, migratetype))
>  			return COMPACT_PARTIAL;
>  	}
>  
> diff --git a/mm/internal.h b/mm/internal.h
> index c4d6c9b..0a89a14 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -201,6 +201,7 @@ unsigned long
>  isolate_migratepages_range(struct compact_control *cc,
>  			   unsigned long low_pfn, unsigned long end_pfn);
>  
> +bool can_steal_freepages(unsigned int order, int start_mt, int fallback_mt);
>  #endif
>  
>  /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ef74750..4c3538b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1026,7 +1026,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>   * This array describes the order lists are fallen back to when
>   * the free lists for the desirable migrate type are depleted
>   */
> -static int fallbacks[MIGRATE_TYPES][4] = {
> +int fallbacks[MIGRATE_TYPES][FALLBACK_MIGRATETYPES] = {
>  	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
>  	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
>  #ifdef CONFIG_CMA
> @@ -1122,8 +1122,7 @@ static void change_pageblock_range(struct page *pageblock_page,
>  	}
>  }
>  
> -static bool can_steal_freepages(unsigned int order,
> -				int start_mt, int fallback_mt)
> +bool can_steal_freepages(unsigned int order, int start_mt, int fallback_mt)
>  {
>  	if (is_migrate_cma(fallback_mt))
>  		return false;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
