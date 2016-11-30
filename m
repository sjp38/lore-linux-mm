Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C175A6B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 02:34:28 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so48939884wma.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 23:34:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 127si5806863wmv.35.2016.11.29.23.34.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 23:34:27 -0800 (PST)
Subject: Re: [patch v2 1/2] mm, zone: track number of movable free pages
References: <alpine.DEB.2.10.1611161731350.17379@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1611291615400.103050@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ee587096-9d0f-65ef-75aa-d9211e846adb@suse.cz>
Date: Wed, 30 Nov 2016 08:34:24 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1611291615400.103050@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/30/2016 01:16 AM, David Rientjes wrote:
> An upcoming compaction change will need the number of movable free pages
> per zone to determine if async compaction will become unnecessarily
> expensive.
>
> This patch introduces no functional change or increased memory footprint.
> It simply tracks the number of free movable pages as a subset of the
> total number of free pages.  This is exported to userspace as part of a
> new /proc/vmstat field.
>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  v2: do not track free pages per migratetype since page allocator stress
>      testing reveals this tracking can impact workloads and there is no
>      substantial benefit when thp is disabled.  This occurs because
>      entire pageblocks can be converted to new migratetypes and requires
>      iteration of free_areas in the hotpaths for proper tracking.

Ah, right, forgot about the accuracy issue when focusing on the overhead 
issue. Unfortunately I'm afraid the NR_FREE_MOVABLE_PAGES in this patch 
will also drift uncontrollably over time. Stealing is one thing, and 
also buddy merging can silently move free pages between migratetypes. It 
already took some effort to make this accurate for MIGRATE_CMA and 
MIGRATE_ISOLATE, which has some overhead and works only thanks to 
additional constraints - CMA pageblocks don't ever get converted, and 
for ISOLATE we don't put them on pcplists, perform pcplists draining 
during isolation, and have extra code guarded by has_isolate_pageblock() 
in buddy merging. None of this would be directly viable for 
MIGRATE_MOVABLE I'm afraid.

>  include/linux/mmzone.h | 1 +
>  include/linux/vmstat.h | 2 ++
>  mm/page_alloc.c        | 8 +++++++-
>  mm/vmstat.c            | 1 +
>  4 files changed, 11 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -138,6 +138,7 @@ enum zone_stat_item {
>  	NUMA_OTHER,		/* allocation from other node */
>  #endif
>  	NR_FREE_CMA_PAGES,
> +	NR_FREE_MOVABLE_PAGES,
>  	NR_VM_ZONE_STAT_ITEMS };
>
>  enum node_stat_item {
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -347,6 +347,8 @@ static inline void __mod_zone_freepage_state(struct zone *zone, int nr_pages,
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
>  	if (is_migrate_cma(migratetype))
>  		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, nr_pages);
> +	if (migratetype == MIGRATE_MOVABLE)
> +		__mod_zone_page_state(zone, NR_FREE_MOVABLE_PAGES, nr_pages);
>  }
>
>  extern const char * const vmstat_text[];
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2197,6 +2197,8 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  	spin_lock(&zone->lock);
>  	for (i = 0; i < count; ++i) {
>  		struct page *page = __rmqueue(zone, order, migratetype);
> +		int mt;
> +
>  		if (unlikely(page == NULL))
>  			break;
>
> @@ -2217,9 +2219,13 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  		else
>  			list_add_tail(&page->lru, list);
>  		list = &page->lru;
> -		if (is_migrate_cma(get_pcppage_migratetype(page)))
> +		mt = get_pcppage_migratetype(page);
> +		if (is_migrate_cma(mt))
>  			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
>  					      -(1 << order));
> +		if (mt == MIGRATE_MOVABLE)
> +			__mod_zone_page_state(zone, NR_FREE_MOVABLE_PAGES,
> +					      -(1 << order));
>  	}
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
>  	spin_unlock(&zone->lock);
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -945,6 +945,7 @@ const char * const vmstat_text[] = {
>  	"numa_other",
>  #endif
>  	"nr_free_cma",
> +	"nr_free_movable",
>
>  	/* Node-based counters */
>  	"nr_inactive_anon",
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
