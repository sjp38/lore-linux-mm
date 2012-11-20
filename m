Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 0D5586B0070
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 23:11:42 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4255515pbc.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 20:11:42 -0800 (PST)
Message-ID: <50AB02F3.7040401@gmail.com>
Date: Tue, 20 Nov 2012 12:11:31 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: fix up zone's present_pages
References: <1353314707-31834-1-git-send-email-lliubbo@gmail.com> <50A9F7FF.9010204@cn.fujitsu.com> <50A9F7BE.1050808@huawei.com> <50AAFD69.7080507@gmail.com> <50AB0004.3050103@cn.fujitsu.com>
In-Reply-To: <50AB0004.3050103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, maciej.rutecki@gmail.com, chris2553@googlemail.com, rjw@sisk.pl, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, daniel.vetter@ffwll.ch, rientjes@google.com, wujianguo@huawei.com, ptesarik@suse.cz, riel@redhat.com, linux-mm@kvack.org, lai jiangshan <laijs@cn.fujitsu.com>

On 11/20/2012 11:59 AM, Wen Congyang wrote:
> At 11/20/2012 11:47 AM, Jaegeuk Hanse Wrote:
>> On 11/19/2012 05:11 PM, Jiang Liu wrote:
>>> On 2012-11-19 17:12, Wen Congyang wrote:
>>>> At 11/19/2012 04:45 PM, Bob Liu Wrote:
>>>>> zone->present_pages shoule be:
>>>>> spanned pages - absent pages - bootmem pages(including memmap pages),
>>>>> but now it's:
>>>>> spanned pages - absent pages - memmap pages.
>>>>> And it didn't consider whether the memmap pages is actully allocated
>>>>> from the
>>>>> zone or not which may cause problem when memory hotplug is improved
>>>>> recently.
>>>>>
>>>>> For example:
>>>>> numa node 1 has ZONE_NORMAL and ZONE_MOVABLE, it's memmap and other
>>>>> bootmem
>>>>> allocated from ZONE_MOVABLE.
>>>>> So ZONE_NORMAL's present_pages should be spanned pages - absent
>>>>> pages, but now
>>>>> it also minus memmap pages, which are actually allocated from
>>>>> ZONE_MOVABLE.
>>>>> This is wrong and when offlining all memory of this zone:
>>>>> (zone->present_pages -= offline_pages) will less than 0.
>>>>> Since present_pages is unsigned long type, that is actually a very
>>>>> large
>>>>> integer which will cause zone->watermark[WMARK_MIN] becomes a large
>>>>> integer too(see setup_per_zone_wmarks()).
>>>>> As a result, totalreserve_pages become a large integer also and
>>>>> finally memory
>>>>> allocating will fail in __vm_enough_memory().
>>>>>
>>>>> Related discuss:
>>>>> http://lkml.org/lkml/2012/11/5/866
>>>>> https://patchwork.kernel.org/patch/1346751/
>>>>>
>>>>> Related patches in mmotm:
>>>>> mm: fix-up zone present pages(7f1290f2f2a4d2c) (sometimes cause
>>>>> egression)
>>>>> mm: fix a regression with HIGHMEM(fe2cebd5a259eec) (Andrew have some
>>>>> feedback)
>>>>>
>>>>> Jiang Liu have sent a series patches to fix this issue by adding a
>>>>> managed_pages area to zone struct:
>>>>> [RFT PATCH v1 0/5] fix up inaccurate zone->present_pages
>>>>>
>>>>> But i think it's too complicated.
>>>>> Mine is based on the two related patches already in mmotm(need to
>>>>> revert them
>>>>> first)
>>>>> It fix the calculation of zone->present_pages by:
>>>>> 1. Reset the zone->present_pages to zero before
>>>>> free_all_bootmem(),free_all_bootmem_node() and
>>>>> free_low_memory_core_early().
>>>>> I think these should already included all path in all arch.
>>>>>
>>>>> 2. If there is a page freed to buddy system in __free_pages_bootmem(),
>>>>> add zone->present_pages accrodingly.
>>>>>
>>>>> Note this patch assumes that bootmem won't use memory above
>>>>> ZONE_HIGHMEM, so
>>>> Hmm, on x86_64 box, bootmem uses the memory in ZONE_MOVABLE and
>>>> ZONE_MOVABLE > ZONE_HIGHMEM.
>>> That's an issue, I'm trying to avoid allocating bootmem from
>>> ZONE_MOVABLE.
>>> And is_highmem(z) or is_highmem_idx(zoneidx) could be safely used to
>>> distinguish
>>> movable highmem zones.
>> Hi Jiang,
>>
>> - I'm not sure why the above mentioned bootmem use the memory in
>> ZONE_MOVABLE, IIUR, because current nobootmem/memblock logic will alloc
>> pages from highest available memory to lowest available memory to avoid
>> fragmentation. Is it correct?
>> - why need avoid allocating bootmem from ZONE_MOVABLE?
> ZONE_MOVABLE means that, the memory can be moved to the other place. So
> we can offline it. It is very useful for memory hotplug.

Hi Congyang,

Thanks for your quick response. Then how to distinguish the memblock you 
about to remove is allocated from bootmem instead of buddy system during 
memory offline?

Regards,
Jaegeuk

>
> Thanks
> Wen Congyang
>
>> Regards,
>> Jaejeuk
>>>>> only zones below ZONE_HIGHMEM are reset/fixed. If not, some update
>>>>> is needed.
>>>>> For ZONE_HIGHMEM, only fix it's init value to:
>>>>> panned_pages - absent_pages in free_area_init_core().
>>>>>
>>>>> Only did some simple test currently.
>>>>>
>>>>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>>>>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>>>>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>>>>> ---
>>>>>    include/linux/mm.h |    3 +++
>>>>>    mm/bootmem.c       |    2 ++
>>>>>    mm/nobootmem.c     |    1 +
>>>>>    mm/page_alloc.c    |   49
>>>>> +++++++++++++++++++++++++++++++++++++------------
>>>>>    4 files changed, 43 insertions(+), 12 deletions(-)
>>>>>
>>>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>>>> index 7b03cab..3b40eb6 100644
>>>>> --- a/include/linux/mm.h
>>>>> +++ b/include/linux/mm.h
>>>>> @@ -1763,5 +1763,8 @@ static inline unsigned int
>>>>> debug_guardpage_minorder(void) { return 0; }
>>>>>    static inline bool page_is_guard(struct page *page) { return false; }
>>>>>    #endif /* CONFIG_DEBUG_PAGEALLOC */
>>>>>    +extern void reset_lowmem_zone_present_pages_pernode(pg_data_t
>>>>> *pgdat);
>>>>> +extern void reset_lowmem_zone_present_pages(void);
>>>>> +
>>>>>    #endif /* __KERNEL__ */
>>>>>    #endif /* _LINUX_MM_H */
>>>>> diff --git a/mm/bootmem.c b/mm/bootmem.c
>>>>> index 26d057a..661775b 100644
>>>>> --- a/mm/bootmem.c
>>>>> +++ b/mm/bootmem.c
>>>>> @@ -238,6 +238,7 @@ static unsigned long __init
>>>>> free_all_bootmem_core(bootmem_data_t *bdata)
>>>>>    unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
>>>>>    {
>>>>>        register_page_bootmem_info_node(pgdat);
>>>>> +    reset_lowmem_zone_present_pages_pernode(pgdat);
>>>>>        return free_all_bootmem_core(pgdat->bdata);
>>>>>    }
>>>>>    @@ -251,6 +252,7 @@ unsigned long __init free_all_bootmem(void)
>>>>>        unsigned long total_pages = 0;
>>>>>        bootmem_data_t *bdata;
>>>>>    +    reset_lowmem_zone_present_pages();
>>>>>        list_for_each_entry(bdata, &bdata_list, list)
>>>>>            total_pages += free_all_bootmem_core(bdata);
>>>>>    diff --git a/mm/nobootmem.c b/mm/nobootmem.c
>>>>> index bd82f6b..378d50a 100644
>>>>> --- a/mm/nobootmem.c
>>>>> +++ b/mm/nobootmem.c
>>>>> @@ -126,6 +126,7 @@ unsigned long __init
>>>>> free_low_memory_core_early(int nodeid)
>>>>>        phys_addr_t start, end, size;
>>>>>        u64 i;
>>>>>    +    reset_lowmem_zone_present_pages();
>>>>>        for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
>>>>>            count += __free_memory_core(start, end);
>>>>>    diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>>> index 07425a7..76d37f0 100644
>>>>> --- a/mm/page_alloc.c
>>>>> +++ b/mm/page_alloc.c
>>>>> @@ -735,6 +735,7 @@ void __meminit __free_pages_bootmem(struct page
>>>>> *page, unsigned int order)
>>>>>    {
>>>>>        unsigned int nr_pages = 1 << order;
>>>>>        unsigned int loop;
>>>>> +    struct zone *zone;
>>>>>          prefetchw(page);
>>>>>        for (loop = 0; loop < nr_pages; loop++) {
>>>>> @@ -748,6 +749,9 @@ void __meminit __free_pages_bootmem(struct page
>>>>> *page, unsigned int order)
>>>>>          set_page_refcounted(page);
>>>>>        __free_pages(page, order);
>>>>> +    zone = page_zone(page);
>>>>> +    WARN_ON(!(is_normal(zone) || is_dma(zone) || is_dma32(zone)));
>>>>> +    zone->present_pages += nr_pages;
>>>>>    }
>>>>>      #ifdef CONFIG_CMA
>>>>> @@ -4547,18 +4551,20 @@ static void __paginginit
>>>>> free_area_init_core(struct pglist_data *pgdat,
>>>>>             * is used by this zone for memmap. This affects the
>>>>> watermark
>>>>>             * and per-cpu initialisations
>>>>>             */
>>>>> -        memmap_pages =
>>>>> -            PAGE_ALIGN(size * sizeof(struct page)) >> PAGE_SHIFT;
>>>>> -        if (realsize >= memmap_pages) {
>>>>> -            realsize -= memmap_pages;
>>>>> -            if (memmap_pages)
>>>>> -                printk(KERN_DEBUG
>>>>> -                       "  %s zone: %lu pages used for memmap\n",
>>>>> -                       zone_names[j], memmap_pages);
>>>>> -        } else
>>>>> -            printk(KERN_WARNING
>>>>> -                "  %s zone: %lu pages exceeds realsize %lu\n",
>>>>> -                zone_names[j], memmap_pages, realsize);
>>>>> +        if (j < ZONE_HIGHMEM) {
>>>>> +            memmap_pages =
>>>>> +                PAGE_ALIGN(size * sizeof(struct page)) >> PAGE_SHIFT;
>>>>> +            if (realsize >= memmap_pages) {
>>>>> +                realsize -= memmap_pages;
>>>>> +                if (memmap_pages)
>>>>> +                    printk(KERN_DEBUG
>>>>> +                            "  %s zone: %lu pages used for memmap\n",
>>>>> +                            zone_names[j], memmap_pages);
>>>>> +            } else
>>>>> +                printk(KERN_WARNING
>>>>> +                        "  %s zone: %lu pages exceeds realsize %lu\n",
>>>>> +                        zone_names[j], memmap_pages, realsize);
>>>>> +        }
>>>>>              /* Account for reserved pages */
>>>>>            if (j == 0 && realsize > dma_reserve) {
>>>>> @@ -6143,3 +6149,22 @@ void dump_page(struct page *page)
>>>>>        dump_page_flags(page->flags);
>>>>>        mem_cgroup_print_bad_page(page);
>>>>>    }
>>>>> +
>>>>> +/* reset zone->present_pages to 0 for zones below ZONE_HIGHMEM */
>>>>> +void reset_lowmem_zone_present_pages_pernode(pg_data_t *pgdat)
>>>>> +{
>>>>> +    int i;
>>>>> +    struct zone *z;
>>>>> +    for (i = 0; i < ZONE_HIGHMEM; i++) {
>>>> And if CONFIG_HIGHMEM is no, ZONE_NORMAL == ZONE_HIGHMEM.
>>>>
>>>> So, you don't reset ZONE_NORMAL here.
>>>>
>>>>> +        z = pgdat->node_zones + i;
>>>>> +        z->present_pages = 0;
>>>>> +    }
>>>>> +}
>>>>> +
>>>>> +void reset_lowmem_zone_present_pages(void)
>>>>> +{
>>>>> +    int nid;
>>>>> +
>>>>> +    for_each_node_state(nid, N_HIGH_MEMORY)
>>>>> +        reset_lowmem_zone_present_pages_pernode(NODE_DATA(nid));
>>>>> +}
>>>> .
>>>>
>>> -- 
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
