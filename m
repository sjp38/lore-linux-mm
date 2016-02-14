Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 285786B0009
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 05:25:53 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id r207so50575692ykd.2
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 02:25:53 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id u10si9853287ywf.221.2016.02.14.02.25.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 14 Feb 2016 02:25:52 -0800 (PST)
Message-ID: <56C0550F.8020402@huawei.com>
Date: Sun, 14 Feb 2016 18:21:03 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page()
 when zone is contiguous
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com> <1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com> <20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org> <CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com>
In-Reply-To: <CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory
 Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Xishi Qiu <qiuxishi@huawei.com>

On 2016/2/6 0:11, Joonsoo Kim wrote:
> 2016-02-05 9:49 GMT+09:00 Andrew Morton <akpm@linux-foundation.org>:
>> On Thu,  4 Feb 2016 15:19:35 +0900 Joonsoo Kim <js1304@gmail.com> wrote:
>>
>>> There is a performance drop report due to hugepage allocation and in there
>>> half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
>>> In that workload, compaction is triggered to make hugepage but most of
>>> pageblocks are un-available for compaction due to pageblock type and
>>> skip bit so compaction usually fails. Most costly operations in this case
>>> is to find valid pageblock while scanning whole zone range. To check
>>> if pageblock is valid to compact, valid pfn within pageblock is required
>>> and we can obtain it by calling pageblock_pfn_to_page(). This function
>>> checks whether pageblock is in a single zone and return valid pfn
>>> if possible. Problem is that we need to check it every time before
>>> scanning pageblock even if we re-visit it and this turns out to
>>> be very expensive in this workload.
>>>
>>> Although we have no way to skip this pageblock check in the system
>>> where hole exists at arbitrary position, we can use cached value for
>>> zone continuity and just do pfn_to_page() in the system where hole doesn't
>>> exist. This optimization considerably speeds up in above workload.
>>>
>>> Before vs After
>>> Max: 1096 MB/s vs 1325 MB/s
>>> Min: 635 MB/s 1015 MB/s
>>> Avg: 899 MB/s 1194 MB/s
>>>
>>> Avg is improved by roughly 30% [2].
>>>
>>> [1]: http://www.spinics.net/lists/linux-mm/msg97378.html
>>> [2]: https://lkml.org/lkml/2015/12/9/23
>>>
>>> ...
>>>
>>> --- a/include/linux/memory_hotplug.h
>>> +++ b/include/linux/memory_hotplug.h
>>> @@ -196,6 +196,9 @@ void put_online_mems(void);
>>>  void mem_hotplug_begin(void);
>>>  void mem_hotplug_done(void);
>>>
>>> +extern void set_zone_contiguous(struct zone *zone);
>>> +extern void clear_zone_contiguous(struct zone *zone);
>>> +
>>>  #else /* ! CONFIG_MEMORY_HOTPLUG */
>>>  /*
>>>   * Stub functions for when hotplug is off
>>
>> Was it really intended that these declarations only exist if
>> CONFIG_MEMORY_HOTPLUG?  Seems unrelated.
> 
> These are called for caching memory layout whether it is contiguous
> or not. So, they are always called in memory initialization. Then,
> hotplug could change memory layout so they should be called
> there, too. So, they are defined in page_alloc.c and exported only
> if CONFIG_MEMORY_HOTPLUG.
> 
>> The i386 allnocofnig build fails in preditable ways so I fixed that up
>> as below, but it seems wrong.
> 
> Yeah, it seems wrong to me. :)
> Here goes fix.
> 
> ----------->8------------
>>From ed6add18bc361e00a7ac6746de6eeb62109e6416 Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Thu, 10 Dec 2015 17:03:54 +0900
> Subject: [PATCH] mm/compaction: speed up pageblock_pfn_to_page() when zone is
>  contiguous
> 
> There is a performance drop report due to hugepage allocation and in there
> half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
> In that workload, compaction is triggered to make hugepage but most of
> pageblocks are un-available for compaction due to pageblock type and
> skip bit so compaction usually fails. Most costly operations in this case
> is to find valid pageblock while scanning whole zone range. To check
> if pageblock is valid to compact, valid pfn within pageblock is required
> and we can obtain it by calling pageblock_pfn_to_page(). This function
> checks whether pageblock is in a single zone and return valid pfn
> if possible. Problem is that we need to check it every time before
> scanning pageblock even if we re-visit it and this turns out to
> be very expensive in this workload.
> 
> Although we have no way to skip this pageblock check in the system
> where hole exists at arbitrary position, we can use cached value for
> zone continuity and just do pfn_to_page() in the system where hole doesn't
> exist. This optimization considerably speeds up in above workload.
> 
> Before vs After
> Max: 1096 MB/s vs 1325 MB/s
> Min: 635 MB/s 1015 MB/s
> Avg: 899 MB/s 1194 MB/s
> 
> Avg is improved by roughly 30% [2].
> 
> [1]: http://www.spinics.net/lists/linux-mm/msg97378.html
> [2]: https://lkml.org/lkml/2015/12/9/23
> 
> v3
> o remove pfn_valid_within() check for all pages in the pageblock
> because pageblock_pfn_to_page() is only called with pageblock aligned pfn.

I have a question about the zone continuity. because hole exists at
arbitrary position in a page block. Therefore, only pageblock_pf_to_page()
is insufficiency, whether pageblock aligned pfn or not , the pfn_valid_within()
is necessary.

eh: 120M-122M is a range of page block, but the 120.5M-121.5M is holes, only by
pageblock_pfn_to_page() to conclude in the result is inaccurate

Thanks
zhongjiang

> v2
> o checking zone continuity after initialization
> o handle memory-hotplug case
> 
> Reported and Tested-by: Aaron Lu <aaron.lu@intel.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/gfp.h            |  6 ----
>  include/linux/memory_hotplug.h |  3 ++
>  include/linux/mmzone.h         |  2 ++
>  mm/compaction.c                | 43 -----------------------
>  mm/internal.h                  | 12 +++++++
>  mm/memory_hotplug.c            |  9 +++++
>  mm/page_alloc.c                | 78 +++++++++++++++++++++++++++++++++++++++++-
>  7 files changed, 103 insertions(+), 50 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 28ad5f6..bd7fccc 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -515,13 +515,7 @@ void drain_zone_pages(struct zone *zone, struct
> per_cpu_pages *pcp);
>  void drain_all_pages(struct zone *zone);
>  void drain_local_pages(struct zone *zone);
> 
> -#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>  void page_alloc_init_late(void);
> -#else
> -static inline void page_alloc_init_late(void)
> -{
> -}
> -#endif
> 
>  /*
>   * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 4340599..e960b78 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -196,6 +196,9 @@ void put_online_mems(void);
>  void mem_hotplug_begin(void);
>  void mem_hotplug_done(void);
> 
> +extern void set_zone_contiguous(struct zone *zone);
> +extern void clear_zone_contiguous(struct zone *zone);
> +
>  #else /* ! CONFIG_MEMORY_HOTPLUG */
>  /*
>   * Stub functions for when hotplug is off
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 7b6c2cf..f12b950 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -520,6 +520,8 @@ struct zone {
>   bool compact_blockskip_flush;
>  #endif
> 
> + bool contiguous;
> +
>   ZONE_PADDING(_pad3_)
>   /* Zone statistics */
>   atomic_long_t vm_stat[NR_VM_ZONE_STAT_ITEMS];
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8ce36eb..93f71d9 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -71,49 +71,6 @@ static inline bool migrate_async_suitable(int migratetype)
>   return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
>  }
> 
> -/*
> - * Check that the whole (or subset of) a pageblock given by the interval of
> - * [start_pfn, end_pfn) is valid and within the same zone, before scanning it
> - * with the migration of free compaction scanner. The scanners then need to
> - * use only pfn_valid_within() check for arches that allow holes within
> - * pageblocks.
> - *
> - * Return struct page pointer of start_pfn, or NULL if checks were not passed.
> - *
> - * It's possible on some configurations to have a setup like node0 node1 node0
> - * i.e. it's possible that all pages within a zones range of pages do not
> - * belong to a single zone. We assume that a border between node0 and node1
> - * can occur within a single pageblock, but not a node0 node1 node0
> - * interleaving within a single pageblock. It is therefore sufficient to check
> - * the first and last page of a pageblock and avoid checking each individual
> - * page in a pageblock.
> - */
> -static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> - unsigned long end_pfn, struct zone *zone)
> -{
> - struct page *start_page;
> - struct page *end_page;
> -
> - /* end_pfn is one past the range we are checking */
> - end_pfn--;
> -
> - if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
> - return NULL;
> -
> - start_page = pfn_to_page(start_pfn);
> -
> - if (page_zone(start_page) != zone)
> - return NULL;
> -
> - end_page = pfn_to_page(end_pfn);
> -
> - /* This gives a shorter code than deriving page_zone(end_page) */
> - if (page_zone_id(start_page) != page_zone_id(end_page))
> - return NULL;
> -
> - return start_page;
> -}
> -
>  #ifdef CONFIG_COMPACTION
> 
>  /* Do not skip compaction more than 64 times */
> diff --git a/mm/internal.h b/mm/internal.h
> index 9006ce1..9609755 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -140,6 +140,18 @@ __find_buddy_index(unsigned long page_idx,
> unsigned int order)
>   return page_idx ^ (1 << order);
>  }
> 
> +extern struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
> + unsigned long end_pfn, struct zone *zone);
> +
> +static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> + unsigned long end_pfn, struct zone *zone)
> +{
> + if (zone->contiguous)
> + return pfn_to_page(start_pfn);
> +
> + return __pageblock_pfn_to_page(start_pfn, end_pfn, zone);
> +}
> +
>  extern int __isolate_free_page(struct page *page, unsigned int order);
>  extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
>   unsigned int order);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 4af58a3..f06916c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -509,6 +509,8 @@ int __ref __add_pages(int nid, struct zone *zone,
> unsigned long phys_start_pfn,
>   int start_sec, end_sec;
>   struct vmem_altmap *altmap;
> 
> + clear_zone_contiguous(zone);
> +
>   /* during initialize mem_map, align hot-added range to section */
>   start_sec = pfn_to_section_nr(phys_start_pfn);
>   end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
> @@ -540,6 +542,8 @@ int __ref __add_pages(int nid, struct zone *zone,
> unsigned long phys_start_pfn,
>   }
>   vmemmap_populate_print_last();
> 
> + set_zone_contiguous(zone);
> +
>   return err;
>  }
>  EXPORT_SYMBOL_GPL(__add_pages);
> @@ -811,6 +815,8 @@ int __remove_pages(struct zone *zone, unsigned
> long phys_start_pfn,
>   }
>   }
> 
> + clear_zone_contiguous(zone);
> +
>   /*
>   * We can only remove entire sections
>   */
> @@ -826,6 +832,9 @@ int __remove_pages(struct zone *zone, unsigned
> long phys_start_pfn,
>   if (ret)
>   break;
>   }
> +
> + set_zone_contiguous(zone);
> +
>   return ret;
>  }
>  EXPORT_SYMBOL_GPL(__remove_pages);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d60c860..059f9c0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1105,6 +1105,75 @@ void __init __free_pages_bootmem(struct page
> *page, unsigned long pfn,
>   return __free_pages_boot_core(page, pfn, order);
>  }
> 
> +/*
> + * Check that the whole (or subset of) a pageblock given by the interval of
> + * [start_pfn, end_pfn) is valid and within the same zone, before scanning it
> + * with the migration of free compaction scanner. The scanners then need to
> + * use only pfn_valid_within() check for arches that allow holes within
> + * pageblocks.
> + *
> + * Return struct page pointer of start_pfn, or NULL if checks were not passed.
> + *
> + * It's possible on some configurations to have a setup like node0 node1 node0
> + * i.e. it's possible that all pages within a zones range of pages do not
> + * belong to a single zone. We assume that a border between node0 and node1
> + * can occur within a single pageblock, but not a node0 node1 node0
> + * interleaving within a single pageblock. It is therefore sufficient to check
> + * the first and last page of a pageblock and avoid checking each individual
> + * page in a pageblock.
> + */
> +struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
> + unsigned long end_pfn, struct zone *zone)
> +{
> + struct page *start_page;
> + struct page *end_page;
> +
> + /* end_pfn is one past the range we are checking */
> + end_pfn--;
> +
> + if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
> + return NULL;
> +
> + start_page = pfn_to_page(start_pfn);
> +
> + if (page_zone(start_page) != zone)
> + return NULL;
> +
> + end_page = pfn_to_page(end_pfn);
> +
> + /* This gives a shorter code than deriving page_zone(end_page) */
> + if (page_zone_id(start_page) != page_zone_id(end_page))
> + return NULL;
> +
> + return start_page;
> +}
> +
> +void set_zone_contiguous(struct zone *zone)
> +{
> + unsigned long block_start_pfn = zone->zone_start_pfn;
> + unsigned long block_end_pfn;
> +
> + block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
> + for (; block_start_pfn < zone_end_pfn(zone);
> + block_start_pfn = block_end_pfn,
> + block_end_pfn += pageblock_nr_pages) {
> +
> + block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
> +
> + if (!__pageblock_pfn_to_page(block_start_pfn,
> + block_end_pfn, zone))
> + return;
> + }
> +
> + /* We confirm that there is no hole */
> + zone->contiguous = true;
> +}
> +
> +void clear_zone_contiguous(struct zone *zone)
> +{
> + zone->contiguous = false;
> +}
> +
>  #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>  static void __init deferred_free_range(struct page *page,
>   unsigned long pfn, int nr_pages)
> @@ -1255,9 +1324,13 @@ free_range:
>   pgdat_init_report_one_done();
>   return 0;
>  }
> +#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
> 
>  void __init page_alloc_init_late(void)
>  {
> + struct zone *zone;
> +
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>   int nid;
> 
>   /* There will be num_node_state(N_MEMORY) threads */
> @@ -1271,8 +1344,11 @@ void __init page_alloc_init_late(void)
> 
>   /* Reinit limits that are based on free pages after the kernel is up */
>   files_maxfiles_init();
> +#endif
> +
> + for_each_populated_zone(zone)
> + set_zone_contiguous(zone);
>  }
> -#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
> 
>  #ifdef CONFIG_CMA
>  /* Free whole pageblock and set its migration type to MIGRATE_CMA. */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
