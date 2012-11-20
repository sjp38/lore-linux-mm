Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 4FAA36B0072
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 02:44:14 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id dq11so1614309wgb.26
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 23:44:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50A9F6DC.6050408@huawei.com>
References: <1353314707-31834-1-git-send-email-lliubbo@gmail.com>
	<50A9F6DC.6050408@huawei.com>
Date: Tue, 20 Nov 2012 15:44:12 +0800
Message-ID: <CAA_GA1dY_VeTkJfogS-6K-aiyiEn3kv8OcLt0k9cQRsgU8LOdA@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: fix up zone's present_pages
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: akpm@linux-foundation.org, maciej.rutecki@gmail.com, chris2553@googlemail.com, rjw@sisk.pl, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, wency@cn.fujitsu.com, daniel.vetter@ffwll.ch, rientjes@google.com, wujianguo@huawei.com, ptesarik@suse.cz, riel@redhat.com, linux-mm@kvack.org

On Mon, Nov 19, 2012 at 5:07 PM, Jiang Liu <jiang.liu@huawei.com> wrote:
> On 2012-11-19 16:45, Bob Liu wrote:
>> zone->present_pages shoule be:
>> spanned pages - absent pages - bootmem pages(including memmap pages),
>> but now it's:
>> spanned pages - absent pages - memmap pages.
>> And it didn't consider whether the memmap pages is actully allocated fro=
m the
>> zone or not which may cause problem when memory hotplug is improved rece=
ntly.
>>
>> For example:
>> numa node 1 has ZONE_NORMAL and ZONE_MOVABLE, it's memmap and other boot=
mem
>> allocated from ZONE_MOVABLE.
>> So ZONE_NORMAL's present_pages should be spanned pages - absent pages, b=
ut now
>> it also minus memmap pages, which are actually allocated from ZONE_MOVAB=
LE.
>> This is wrong and when offlining all memory of this zone:
>> (zone->present_pages -=3D offline_pages) will less than 0.
>> Since present_pages is unsigned long type, that is actually a very large
>> integer which will cause zone->watermark[WMARK_MIN] becomes a large
>> integer too(see setup_per_zone_wmarks()).
>> As a result, totalreserve_pages become a large integer also and finally =
memory
>> allocating will fail in __vm_enough_memory().
>>
>> Related discuss:
>> http://lkml.org/lkml/2012/11/5/866
>> https://patchwork.kernel.org/patch/1346751/
>>
>> Related patches in mmotm:
>> mm: fix-up zone present pages(7f1290f2f2a4d2c) (sometimes cause egressio=
n)
>> mm: fix a regression with HIGHMEM(fe2cebd5a259eec) (Andrew have some fee=
dback)
>>
>> Jiang Liu have sent a series patches to fix this issue by adding a
>> managed_pages area to zone struct:
>> [RFT PATCH v1 0/5] fix up inaccurate zone->present_pages
>>
>> But i think it's too complicated.
>> Mine is based on the two related patches already in mmotm(need to revert=
 them
>> first)
>> It fix the calculation of zone->present_pages by:
>> 1. Reset the zone->present_pages to zero before
>> free_all_bootmem(),free_all_bootmem_node() and free_low_memory_core_earl=
y().
>> I think these should already included all path in all arch.
>>
>> 2. If there is a page freed to buddy system in __free_pages_bootmem(),
>> add zone->present_pages accrodingly.
>>
>> Note this patch assumes that bootmem won't use memory above ZONE_HIGHMEM=
, so
>> only zones below ZONE_HIGHMEM are reset/fixed. If not, some update is ne=
eded.
>> For ZONE_HIGHMEM, only fix it's init value to:
>> panned_pages - absent_pages in free_area_init_core().
>>
>> Only did some simple test currently.
> Hi Bob=EF=BC=8C
>         Great to know that you are working on this issue too.
> Originally I have thought about reusing the zone->present_pages.
> And later I propose to add the new field "managed_pages" because
> we could know that there are some pages not managed by the buddy
> system in the zone (present_pages - managed_pages). This may help
> the ongoing memory power management work from Srivatsa S. Bhat
> because we can't put memory ranges into low power state if there
> are unmanaged pages.
> And pgdat->node_present_pages =3D spanned_pages - absent_pages,
> so it would be better to keep consistence with node_present_pages
> by setting zone->present_pages =3D spanned_pages - absent_pages.

Okay, and i have seen feedback from Andrew in your series.
I will spend more time on it when i am free.
Sorry for the noise.

>
>>
>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>>  include/linux/mm.h |    3 +++
>>  mm/bootmem.c       |    2 ++
>>  mm/nobootmem.c     |    1 +
>>  mm/page_alloc.c    |   49 +++++++++++++++++++++++++++++++++++++--------=
----
>>  4 files changed, 43 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 7b03cab..3b40eb6 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1763,5 +1763,8 @@ static inline unsigned int debug_guardpage_minorde=
r(void) { return 0; }
>>  static inline bool page_is_guard(struct page *page) { return false; }
>>  #endif /* CONFIG_DEBUG_PAGEALLOC */
>>
>> +extern void reset_lowmem_zone_present_pages_pernode(pg_data_t *pgdat);
>> +extern void reset_lowmem_zone_present_pages(void);
>> +
>>  #endif /* __KERNEL__ */
>>  #endif /* _LINUX_MM_H */
>> diff --git a/mm/bootmem.c b/mm/bootmem.c
>> index 26d057a..661775b 100644
>> --- a/mm/bootmem.c
>> +++ b/mm/bootmem.c
>> @@ -238,6 +238,7 @@ static unsigned long __init free_all_bootmem_core(bo=
otmem_data_t *bdata)
>>  unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
>>  {
>>       register_page_bootmem_info_node(pgdat);
>> +     reset_lowmem_zone_present_pages_pernode(pgdat);
>>       return free_all_bootmem_core(pgdat->bdata);
>>  }
>>
>> @@ -251,6 +252,7 @@ unsigned long __init free_all_bootmem(void)
>>       unsigned long total_pages =3D 0;
>>       bootmem_data_t *bdata;
>>
>> +     reset_lowmem_zone_present_pages();
>>       list_for_each_entry(bdata, &bdata_list, list)
>>               total_pages +=3D free_all_bootmem_core(bdata);
>>
>> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
>> index bd82f6b..378d50a 100644
>> --- a/mm/nobootmem.c
>> +++ b/mm/nobootmem.c
>> @@ -126,6 +126,7 @@ unsigned long __init free_low_memory_core_early(int =
nodeid)
>>       phys_addr_t start, end, size;
>>       u64 i;
>>
>> +     reset_lowmem_zone_present_pages();
>>       for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
>>               count +=3D __free_memory_core(start, end);
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 07425a7..76d37f0 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -735,6 +735,7 @@ void __meminit __free_pages_bootmem(struct page *pag=
e, unsigned int order)
>>  {
>>       unsigned int nr_pages =3D 1 << order;
>>       unsigned int loop;
>> +     struct zone *zone;
>>
>>       prefetchw(page);
>>       for (loop =3D 0; loop < nr_pages; loop++) {
>> @@ -748,6 +749,9 @@ void __meminit __free_pages_bootmem(struct page *pag=
e, unsigned int order)
>>
>>       set_page_refcounted(page);
>>       __free_pages(page, order);
>> +     zone =3D page_zone(page);
>> +     WARN_ON(!(is_normal(zone) || is_dma(zone) || is_dma32(zone)));
>> +     zone->present_pages +=3D nr_pages;
>>  }
>>
>>  #ifdef CONFIG_CMA
>> @@ -4547,18 +4551,20 @@ static void __paginginit free_area_init_core(str=
uct pglist_data *pgdat,
>>                * is used by this zone for memmap. This affects the water=
mark
>>                * and per-cpu initialisations
>>                */
>> -             memmap_pages =3D
>> -                     PAGE_ALIGN(size * sizeof(struct page)) >> PAGE_SHI=
FT;
>> -             if (realsize >=3D memmap_pages) {
>> -                     realsize -=3D memmap_pages;
>> -                     if (memmap_pages)
>> -                             printk(KERN_DEBUG
>> -                                    "  %s zone: %lu pages used for memm=
ap\n",
>> -                                    zone_names[j], memmap_pages);
>> -             } else
>> -                     printk(KERN_WARNING
>> -                             "  %s zone: %lu pages exceeds realsize %lu=
\n",
>> -                             zone_names[j], memmap_pages, realsize);
>> +             if (j < ZONE_HIGHMEM) {
>> +                     memmap_pages =3D
>> +                             PAGE_ALIGN(size * sizeof(struct page)) >> =
PAGE_SHIFT;
>> +                     if (realsize >=3D memmap_pages) {
>> +                             realsize -=3D memmap_pages;
>> +                             if (memmap_pages)
>> +                                     printk(KERN_DEBUG
>> +                                                     "  %s zone: %lu pa=
ges used for memmap\n",
>> +                                                     zone_names[j], mem=
map_pages);
>> +                     } else
>> +                             printk(KERN_WARNING
>> +                                             "  %s zone: %lu pages exce=
eds realsize %lu\n",
>> +                                             zone_names[j], memmap_page=
s, realsize);
>> +             }
>>
>>               /* Account for reserved pages */
>>               if (j =3D=3D 0 && realsize > dma_reserve) {
>> @@ -6143,3 +6149,22 @@ void dump_page(struct page *page)
>>       dump_page_flags(page->flags);
>>       mem_cgroup_print_bad_page(page);
>>  }
>> +
>> +/* reset zone->present_pages to 0 for zones below ZONE_HIGHMEM */
>> +void reset_lowmem_zone_present_pages_pernode(pg_data_t *pgdat)
>> +{
>> +     int i;
>> +     struct zone *z;
>> +     for (i =3D 0; i < ZONE_HIGHMEM; i++) {
>> +             z =3D pgdat->node_zones + i;
>> +             z->present_pages =3D 0;
>> +     }
>> +}
>> +
>> +void reset_lowmem_zone_present_pages(void)
>> +{
>> +     int nid;
>> +
>> +     for_each_node_state(nid, N_HIGH_MEMORY)
>> +             reset_lowmem_zone_present_pages_pernode(NODE_DATA(nid));
>> +}
>
>

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
