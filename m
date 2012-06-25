Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 9EFD86B02FB
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 21:09:57 -0400 (EDT)
Message-ID: <4FE7BA81.7000805@kernel.org>
Date: Mon, 25 Jun 2012 10:10:25 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
References: <4FE169B1.7020600@kernel.org> <4FE16E80.9000306@gmail.com> <4FE18187.3050103@kernel.org> <4FE23069.5030702@gmail.com> <4FE26470.90401@kernel.org> <CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com> <4FE27F15.8050102@kernel.org> <CAHGf_=pDw4axwG2tQ+B5hPks-sz2S5+G1Kk-=HSDmo=DSXOkEw@mail.gmail.com> <4FE2A937.6040701@kernel.org> <4FE2FCFB.4040808@jp.fujitsu.com> <4FE3C4E4.2050107@kernel.org> <4FE414A2.3000700@kernel.org> <4FE53074.50809@gmail.com>
In-Reply-To: <4FE53074.50809@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi KOSAKI,

On 06/23/2012 11:56 AM, KOSAKI Motohiro wrote:

> (6/22/12 2:45 AM), Minchan Kim wrote:
>> On 06/22/2012 10:05 AM, Minchan Kim wrote:
>>
>>> Second approach which is suggested by KOSAKI is what you mentioned.
>>> But the concern about second approach is how to make sure matched count increase/decrease of nr_isolated_areas.
>>> I mean how to make sure nr_isolated_areas would be zero when isolation is done.
>>> Of course, we can investigate all of current caller and make sure they don't make mistake
>>> now. But it's very error-prone if we consider future's user.
>>> So we might need test_set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>>
>>
>> It's an implementation about above approach.
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index bf3404e..3e9a9e1 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -474,6 +474,11 @@ struct zone {
>>          * rarely used fields:
>>          */  
>>         const char              *name;
>> +       /*
>> +        * the number of MIGRATE_ISOLATE pageblock
>> +        * We need this for accurate free page counting.
>> +        */
>> +       atomic_t                nr_migrate_isolate;
> 
> #ifdef CONFIG_MEMORY_HOTPLUG?


Now I am seeing how to handle CONFIG_{MEMORY_HOTPLUG | CMA | MEMORY_FAILURE}.

> 
> 
>>  } ____cacheline_internodealigned_in_smp;
>>  
>>  typedef enum {
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 2c29b1c..6cb1f9f 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -219,6 +219,11 @@ EXPORT_SYMBOL(nr_online_nodes);
>>  
>>  int page_group_by_mobility_disabled __read_mostly;
>>  
>> +/*
>> + * NOTE:
>> + * Don't use set_pageblock_migratetype(page, MIGRATE_ISOLATE) direclty.
>> + * Instead, use {un}set_pageblock_isolate.
>> + */
>>  void set_pageblock_migratetype(struct page *page, int migratetype)
>>  {
>>         if (unlikely(page_group_by_mobility_disabled))
>> @@ -1622,6 +1627,28 @@ bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>>                                         zone_page_state(z, NR_FREE_PAGES));
>>  }
>>  
>> +unsigned long migrate_isolate_pages(struct zone *zone)
>> +{
>> +       unsigned long nr_pages = 0;
>> +
>> +       if (unlikely(atomic_read(&zone->nr_migrate_isolate))) {
>> +               unsigned long flags;
>> +               int order;
>> +               spin_lock_irqsave(&zone->lock, flags);
>> +               for (order = 0; order < MAX_ORDER; order++) {
>> +                       struct free_area *area = &zone->free_area[order];
>> +                       long count = 0;
>> +                       struct list_head *curr;
>> +
>> +                       list_for_each(curr, &area->free_list[MIGRATE_ISOLATE])
>> +                               count++;
>> +                       nr_pages += (count << order);
>> +               }
>> +               spin_unlock_irqrestore(&zone->lock, flags);
>> +       }
>> +       return nr_pages;
>> +}
>> +
>>  bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
>>                       int classzone_idx, int alloc_flags)
>>  {
>> @@ -1630,6 +1657,14 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
>>         if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
>>                 free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
>>  
>> +       /*
>> +        * If the zone has MIGRATE_ISOLATE type free page,
>> +        * we should consider it, too. Otherwise, kswapd can sleep forever.
>> +        */
>> +       free_pages -= migrate_isolate_pages(z);
>> +       if (free_pages < 0)
>> +               free_pages = 0;
>> +
>>         return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
>>                                                                 free_pages);
>>  }
>> @@ -4408,6 +4443,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>>                 lruvec_init(&zone->lruvec, zone);
>>                 zap_zone_vm_stats(zone);
>>                 zone->flags = 0;
>> +               atomic_set(&zone->nr_migrate_isolate, 0);
>>                 if (!size)
>>                         continue;
>>  
>> @@ -5555,6 +5591,45 @@ bool is_pageblock_removable_nolock(struct page *page)
>>         return __count_immobile_pages(zone, page, 0);
>>  }
>>  
>> +static void set_pageblock_isolate(struct zone *zone, struct page *page)
>> +{
>> +       int old_migratetype;
>> +       assert_spin_locked(&zone->lock);
>> +
>> +        if (unlikely(page_group_by_mobility_disabled)) {
> 
> 
> We don't need this check. page_group_by_mobility_disabled is an optimization for
> low memory system. but memory hotplug should work even though run on low memory.
> 
> In other words, current upstream code is buggy. :-)


If it's a bug, I want to fix it as another patch in next chance all at once.

> 
> 
>> +               set_pageblock_flags_group(page, MIGRATE_UNMOVABLE,
>> +                                       PB_migrate, PB_migrate_end);
>> +               return;
>> +       }
>> +
>> +       old_migratetype = get_pageblock_migratetype(page);
>> +       set_pageblock_flags_group(page, MIGRATE_ISOLATE,
>> +                                       PB_migrate, PB_migrate_end);
>> +
>> +       if (old_migratetype != MIGRATE_ISOLATE)
>> +               atomic_inc(&zone->nr_migrate_isolate);
>> +}
>> +
>> +static void unset_pageblock_isolate(struct zone *zone, struct page *page,
>> +                               unsigned long migratetype)
>> +{
>> +       assert_spin_locked(&zone->lock);
>> +
>> +        if (unlikely(page_group_by_mobility_disabled)) {
>> +               set_pageblock_flags_group(page, migratetype,
>> +                                       PB_migrate, PB_migrate_end);
>> +               return;
>> +       }
>> +
>> +       BUG_ON(get_pageblock_migratetype(page) != MIGRATE_ISOLATE);
>> +       BUG_ON(migratetype == MIGRATE_ISOLATE);
>> +
>> +       set_pageblock_flags_group(page, migratetype,
>> +                                       PB_migrate, PB_migrate_end);
>> +       atomic_dec(&zone->nr_migrate_isolate);
>> +       BUG_ON(atomic_read(&zone->nr_migrate_isolate) < 0);
>> +}
>> +
>>  int set_migratetype_isolate(struct page *page)
>>  {
>>         struct zone *zone;
>> @@ -5601,7 +5676,7 @@ int set_migratetype_isolate(struct page *page)
>>  
>>  out:
>>         if (!ret) {
>> -               set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>> +               set_pageblock_isolate(zone, page);
>>                 move_freepages_block(zone, page, MIGRATE_ISOLATE);
>>         }
>>  
>> @@ -5619,8 +5694,8 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>>         spin_lock_irqsave(&zone->lock, flags);
>>         if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
>>                 goto out;
>> -       set_pageblock_migratetype(page, migratetype);
>>         move_freepages_block(zone, page, migratetype);
>> +       unset_pageblock_isolate(zone, page, migratetype);
> 
> I don't think this order change is unnecessary. Why did you swap?


If we don't change it, zone_watermark_pages_ok can see stale the number of free pages because
nr_migrate_isolate count is zero but still remains several pages in MIGRATE_ISOLATE in buddy.

> 
> 
> Other than that, looks very good to me.


Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
