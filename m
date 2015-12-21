Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id B31F36B0006
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 07:18:56 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id l9so62308560oia.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 04:18:56 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id sa5si4262855obc.69.2015.12.21.04.18.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 04:18:56 -0800 (PST)
Received: by mail-oi0-x232.google.com with SMTP id y66so90959479oig.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 04:18:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5677D888.40704@suse.cz>
References: <1450678432-16593-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1450678432-16593-2-git-send-email-iamjoonsoo.kim@lge.com>
	<5677D888.40704@suse.cz>
Date: Mon, 21 Dec 2015 21:18:55 +0900
Message-ID: <CAAmzW4NN+hbhb7FXJv8VgpvEwgze6xCTU9V93PhavX=xX-HTfg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/compaction: speed up pageblock_pfn_to_page() when
 zone is contiguous
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Toshi Kani <toshi.kani@hpe.com>

2015-12-21 19:46 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 12/21/2015 07:13 AM, Joonsoo Kim wrote:
>>
>> There is a performance drop report due to hugepage allocation and in there
>> half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
>> In that workload, compaction is triggered to make hugepage but most of
>> pageblocks are un-available for compaction due to pageblock type and
>> skip bit so compaction usually fails. Most costly operations in this case
>> is to find valid pageblock while scanning whole zone range. To check
>> if pageblock is valid to compact, valid pfn within pageblock is required
>> and we can obtain it by calling pageblock_pfn_to_page(). This function
>> checks whether pageblock is in a single zone and return valid pfn
>> if possible. Problem is that we need to check it every time before
>> scanning pageblock even if we re-visit it and this turns out to
>> be very expensive in this workload.
>>
>> Although we have no way to skip this pageblock check in the system
>> where hole exists at arbitrary position, we can use cached value for
>> zone continuity and just do pfn_to_page() in the system where hole doesn't
>> exist. This optimization considerably speeds up in above workload.
>>
>> Before vs After
>> Max: 1096 MB/s vs 1325 MB/s
>> Min: 635 MB/s 1015 MB/s
>> Avg: 899 MB/s 1194 MB/s
>>
>> Avg is improved by roughly 30% [2].
>>
>> [1]: http://www.spinics.net/lists/linux-mm/msg97378.html
>> [2]: https://lkml.org/lkml/2015/12/9/23
>>
>> v2
>> o checking zone continuity after initialization
>> o handle memory-hotplug case
>>
>> Reported and Tested-by: Aaron Lu <aaron.lu@intel.com>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> [...]
>
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -505,6 +505,9 @@ int __ref __add_pages(int nid, struct zone *zone,
>> unsigned long phys_start_pfn,
>>         unsigned long i;
>>         int err = 0;
>>         int start_sec, end_sec;
>> +
>> +       clear_zone_contiguous(zone);
>> +
>>         /* during initialize mem_map, align hot-added range to section */
>>         start_sec = pfn_to_section_nr(phys_start_pfn);
>>         end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
>> @@ -523,6 +526,8 @@ int __ref __add_pages(int nid, struct zone *zone,
>> unsigned long phys_start_pfn,
>>         }
>>         vmemmap_populate_print_last();
>>
>> +       set_zone_contiguous(zone);
>> +
>>         return err;
>>   }
>>   EXPORT_SYMBOL_GPL(__add_pages);
>> @@ -770,6 +775,8 @@ int __remove_pages(struct zone *zone, unsigned long
>> phys_start_pfn,
>>         resource_size_t start, size;
>>         int ret = 0;
>>
>> +       clear_zone_contiguous(zone);
>> +
>>         /*
>>          * We can only remove entire sections
>>          */
>> @@ -796,6 +803,9 @@ int __remove_pages(struct zone *zone, unsigned long
>> phys_start_pfn,
>>                 if (ret)
>>                         break;
>>         }
>> +
>> +       set_zone_contiguous(zone);
>> +
>>         return ret;
>
>
> Hm I wonder how many __add_ or __remove_pages calls there might be per a
> major hotplug event (e.g. whole node). IIRC there may be many subranges that
> are onlined/offlined separately?

__add_ or __removed_pages are called whenever memory device is added
or removed, that is, 1 call per 1 device add/remove. If device is 1GB,
it is called
for 1GB range and if device is 2GB, it is called for 2GB range. I think they are
reasonable place to check continuity.

> Doing a full zone rescan on each
> sub-operation could be quite costly, no?

Doing full zone rescan makes code much simpler. It can be optimized further but
at this point there is no reason to handle complexity.

You should have added
> mm/hotplug_memory.c people to CC to comment, as you did in the [RFC]
> theoretical race... mail. Doing that now.

Okay. Thanks.

> If the hotplug people confirm it might be an issue, I guess one solution is
> to call set_zone_contiguous() lazily on-demand as you did in the v1 (but not
> relying on cached pfn initialization to determine whether contiguous was
> already evaluated). Add another variable like zone->contiguous_evaluated and
> make hotplug code just set it to false.

It could be, but, I guess that this is not too expensive for memory
hotplug. They can
tolerate 120 sec for offline memory and rescanning full zone to check
continuity is
very cheap than it.

Anyway, it's better to confirm these things by memory hotplug people.

Thanks.

>
>>   }
>>   EXPORT_SYMBOL_GPL(__remove_pages);
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index bac8842..4f5ad2b 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1271,9 +1271,13 @@ free_range:
>>         pgdat_init_report_one_done();
>>         return 0;
>>   }
>> +#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>>
>>   void __init page_alloc_init_late(void)
>>   {
>> +       struct zone *zone;
>> +
>> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>>         int nid;
>>
>>         /* There will be num_node_state(N_MEMORY) threads */
>> @@ -1287,8 +1291,87 @@ void __init page_alloc_init_late(void)
>>
>>         /* Reinit limits that are based on free pages after the kernel is
>> up */
>>         files_maxfiles_init();
>> +#endif
>> +
>> +       for_each_populated_zone(zone)
>> +               set_zone_contiguous(zone);
>> +}
>> +
>> +/*
>> + * Check that the whole (or subset of) a pageblock given by the interval
>> of
>> + * [start_pfn, end_pfn) is valid and within the same zone, before
>> scanning it
>> + * with the migration of free compaction scanner. The scanners then need
>> to
>> + * use only pfn_valid_within() check for arches that allow holes within
>> + * pageblocks.
>> + *
>> + * Return struct page pointer of start_pfn, or NULL if checks were not
>> passed.
>> + *
>> + * It's possible on some configurations to have a setup like node0 node1
>> node0
>> + * i.e. it's possible that all pages within a zones range of pages do not
>> + * belong to a single zone. We assume that a border between node0 and
>> node1
>> + * can occur within a single pageblock, but not a node0 node1 node0
>> + * interleaving within a single pageblock. It is therefore sufficient to
>> check
>> + * the first and last page of a pageblock and avoid checking each
>> individual
>> + * page in a pageblock.
>> + */
>> +struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
>> +                               unsigned long end_pfn, struct zone *zone)
>> +{
>> +       struct page *start_page;
>> +       struct page *end_page;
>> +
>> +       /* end_pfn is one past the range we are checking */
>> +       end_pfn--;
>> +
>> +       if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
>> +               return NULL;
>> +
>> +       start_page = pfn_to_page(start_pfn);
>> +
>> +       if (page_zone(start_page) != zone)
>> +               return NULL;
>> +
>> +       end_page = pfn_to_page(end_pfn);
>> +
>> +       /* This gives a shorter code than deriving page_zone(end_page) */
>> +       if (page_zone_id(start_page) != page_zone_id(end_page))
>> +               return NULL;
>> +
>> +       return start_page;
>> +}
>> +
>> +void set_zone_contiguous(struct zone *zone)
>> +{
>> +       unsigned long block_start_pfn = zone->zone_start_pfn;
>> +       unsigned long block_end_pfn;
>> +       unsigned long pfn;
>> +
>> +       block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
>> +       for (; block_start_pfn < zone_end_pfn(zone);
>> +               block_start_pfn = block_end_pfn,
>> +               block_end_pfn += pageblock_nr_pages) {
>> +
>> +               block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
>> +
>> +               if (!__pageblock_pfn_to_page(block_start_pfn,
>> +                                       block_end_pfn, zone))
>> +                       return;
>> +
>> +               /* Check validity of pfn within pageblock */
>> +               for (pfn = block_start_pfn; pfn < block_end_pfn; pfn++) {
>> +                       if (!pfn_valid_within(pfn))
>> +                               return;
>> +               }
>
>
> Hm this is suboptimal and misleading. The result of pfn_valid_within()
> doesn't affect whether we need to use __pageblock_pfn_to_page() or not, so
> zone->contiguous shouldn't depend on it.
>
> On the other hand, if we knew that pfn_valid_within() is true everywhere, we
> wouldn't need to check it inside isolate_*pages_block().
> So you could add another patch that adds another bool to struct zone and
> test for that (with #ifdef CONFIG_HOLES_IN_ZONE at appropriate places).
>
> Thanks,
> Vlastimil
>
>
>> +       }
>> +
>> +       /* We confirm that there is no hole */
>> +       zone->contiguous = true;
>> +}
>> +
>> +void clear_zone_contiguous(struct zone *zone)
>> +{
>> +       zone->contiguous = false;
>>   }
>> -#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>>
>>   #ifdef CONFIG_CMA
>>   /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
