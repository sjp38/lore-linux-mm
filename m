Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 01FCC6B014E
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 20:10:23 -0400 (EDT)
Message-ID: <4FE8FDEF.7030306@kernel.org>
Date: Tue, 26 Jun 2012 09:10:23 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memory-hotplug: fix kswapd looping forever problem
References: <1340600367-23620-1-git-send-email-minchan@kernel.org> <1340600367-23620-3-git-send-email-minchan@kernel.org> <20120625100247.GC8103@csn.ul.ie>
In-Reply-To: <20120625100247.GC8103@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

Hi Mel,

On 06/25/2012 07:02 PM, Mel Gorman wrote:

> On Mon, Jun 25, 2012 at 01:59:27PM +0900, Minchan Kim wrote:
>> When hotplug offlining happens on zone A, it starts to mark freed page
>> as MIGRATE_ISOLATE type in buddy for preventing further allocation.
>> (MIGRATE_ISOLATE is very irony type because it's apparently on buddy
>> but we can't allocate them).
>> When the memory shortage happens during hotplug offlining,
>> current task starts to reclaim, then wake up kswapd.
>> Kswapd checks watermark, then go sleep because current zone_watermark_ok_safe
>> doesn't consider MIGRATE_ISOLATE freed page count.
>> Current task continue to reclaim in direct reclaim path without kswapd's helping.
>> The problem is that zone->all_unreclaimable is set by only kswapd
>> so that current task would be looping forever like below.
>>
>> __alloc_pages_slowpath
>> restart:
>> 	wake_all_kswapd
>> rebalance:
>> 	__alloc_pages_direct_reclaim
>> 		do_try_to_free_pages
>> 			if global_reclaim && !all_unreclaimable
>> 				return 1; /* It means we did did_some_progress */
>> 	skip __alloc_pages_may_oom
>> 	should_alloc_retry
>> 		goto rebalance;
>>
>> If we apply KOSAKI's patch[1] which doesn't depends on kswapd
>> about setting zone->all_unreclaimable, we can solve this problem
>> by killing some task in direct reclaim path. But it doesn't wake up kswapd, still.
>> It could be a problem still if other subsystem needs GFP_ATOMIC request.
>> So kswapd should consider MIGRATE_ISOLATE when it calculate free pages
>> BEFORE going sleep.
>>
>> This patch counts the number of MIGRATE_ISOLATE page block and
>> zone_watermark_ok_safe will consider it if the system has such blocks
>> (fortunately, it's very rare so no problem in POV overhead and kswapd is never
>> hotpath).
>>
>> [1] http://lkml.org/lkml/2012/6/14/74
>>
> 
> I have not been following this discussion at all but reading through the
> patch I wonder again why memory hotplug is not "allocating" the pageblocks
> when they are fully isolated like a balloon driver. This would keep the
> free space accounting as it is currently without introducing something
> memory hotplug specific to kswapd.
> 
> I think historically that memory hotplug did not allocate pages because
> it would be difficult to detect if a pageblock was isolated or if part of
> some balloon. Allocating just full pageblocks would work around this.
> However, it would play very badly with CMA.
> 
> It'd be worth mentioning this in the changelog in case someone tries to
> "fix" it.
> 
>> Suggested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>
>> Aaditya, coul you confirm this patch solve your problem and 
>> make sure nr_migrate_isolate is zero after hotplug end?
>>
>> Thanks!
>>
>>  include/linux/mmzone.h |    8 ++++++++
>>  mm/page_alloc.c        |   36 ++++++++++++++++++++++++++++++++++++
>>  mm/page_isolation.c    |   43 +++++++++++++++++++++++++++++++++++++++++--
>>  3 files changed, 85 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index bf3404e..290e186 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -474,6 +474,14 @@ struct zone {
>>  	 * rarely used fields:
>>  	 */
>>  	const char		*name;
>> +#ifdef CONFIG_MEMORY_ISOLATION
>> +	/*
>> +	 * the number of MIGRATE_ISOLATE pageblock
>> +	 * We need this for accurate free page counting.
>> +	 * It's protected by zone->lock
>> +	 */
>> +	atomic_t		nr_migrate_isolate;
>> +#endif
> 
> If it's protected by the zone->lock then it does not need to be atomic.


Slaps self. :-(

> 
>>  } ____cacheline_internodealigned_in_smp;
>>  
>>  typedef enum {
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index c175fa9..626f877 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -218,6 +218,11 @@ EXPORT_SYMBOL(nr_online_nodes);
>>  
>>  int page_group_by_mobility_disabled __read_mostly;
>>  
>> +/*
>> + * NOTE:
>> + * Don't use set_pageblock_migratetype(page, MIGRATE_ISOLATE) direclty.
> 
> s/direclty/directly/


Will fix.

> 
>> + * Instead, use {un}set_pageblock_isolate.
>> + */
>>  void set_pageblock_migratetype(struct page *page, int migratetype)
>>  {
>>  	if (unlikely(page_group_by_mobility_disabled))
>> @@ -1614,6 +1619,28 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>>  	return true;
>>  }
>>  
>> +static unsigned long migrate_isolate_pages(struct zone *zone)
>> +{
> 
> This name is very misleading as nothing is being migrated. The


Agree.

> other zone-based counters are stored in vmstat[] and accessed
> with zone_page_state(). I doubt you want to use vmstat but
> nr_isolated_zone_pages() would have been a better name.


I feel it's kinda NR_ISOLATE_{ANON + FILE}.
So I think it would be better to use nr_zone_isolate_freepages.

> 
>> +	unsigned long nr_pages = 0;
>> +
>> +	if (unlikely(atomic_read(&zone->nr_migrate_isolate))) {
>> +		unsigned long flags;
>> +		int order;
>> +		spin_lock_irqsave(&zone->lock, flags);
>> +		for (order = 0; order < MAX_ORDER; order++) {
>> +			struct free_area *area = &zone->free_area[order];
>> +			long count = 0;
>> +			struct list_head *curr;
>> +
>> +			list_for_each(curr, &area->free_list[MIGRATE_ISOLATE])
>> +				count++;
>> +			nr_pages += (count << order);
>> +		}
>> +		spin_unlock_irqrestore(&zone->lock, flags);
>> +	}
> 
> We have a zone->nr_migrate_isolate counter but have to search the buddy
> lists to count how many pages are isolated? Don't bother. If the pageblocks
> really have been isolated just assume that they are fully isolated for the
> purposes of figuring out if kswapd should wake up or not. The consequences
> of an inaccurate count is that kswapd wakes up when it potentially could
> have stayed asleep but for memory hotplug that is desirable.


Fair enough.

> 
>> +	return nr_pages;
>> +}
>> +
>>  bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>>  		      int classzone_idx, int alloc_flags)
>>  {
>> @@ -1629,6 +1656,14 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
>>  	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
>>  		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
>>  
>> +	/*
>> +	 * If the zone has MIGRATE_ISOLATE type free page,
>> +	 * we should consider it, too. Otherwise, kswapd can sleep forever.
>> +	 */
>> +	free_pages -= migrate_isolate_pages(z);
>> +	if (free_pages < 0)
>> +		free_pages = 0;
>> +
> 
> You are already taking into account that the numbet of isolated pages may
> be inaccurate so an exact count in migrate_isolate_pages is unnecessary.


I will use following code instead of migrate_isolate_pages's accurate counter.

int migrate_isolate_pages(struct zone *z)
{
	return z->nr_migrate_isolate * pageblock_nr_pages;
}


free_pages -= migrate_isolate_pages(z);
if (free_pages < 0)
	free_pages = 0;

Otherwise, simply, we can always wake up kswapd during hot-plug because it's temporal action and
would end sooner or later.
It is likely to make unnecessary aging and CPU consumption but it would be very rare.

zone_watermark_ok_safe()
{
	if (z->nr_migrate_isolate > 0)
		return false;
	..
	..
}

> 
>>  	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
>>  								free_pages);
>>  }
>> @@ -4407,6 +4442,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>>  		lruvec_init(&zone->lruvec, zone);
>>  		zap_zone_vm_stats(zone);
>>  		zone->flags = 0;
>> +		atomic_set(&zone->nr_migrate_isolate, 0);
>>  		if (!size)
>>  			continue;
>>  
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index 1a9cb36..e95a792 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -8,6 +8,45 @@
>>  #include <linux/memory.h>
>>  #include "internal.h"
>>  
>> +static void set_pageblock_isolate(struct zone *zone, struct page *page)
>> +{
>> +	int old_migratetype;
>> +	assert_spin_locked(&zone->lock);
>> +
>> +	if (unlikely(page_group_by_mobility_disabled)) {
>> +		set_pageblock_flags_group(page, MIGRATE_UNMOVABLE,
>> +				PB_migrate, PB_migrate_end);
>> +		return;
>> +	}
> 
> Not sure why this is necessary.


Yeb. hotplug should work regardless of small memory system(KOSAKI already pointed out)
but current hotplug code have used set_pageblock_migratetype(page, MIGRATE_ISOLATE)
which already check page_group_by_mobility_disabled. It's like buggy.
But I think it should be fixed as another patch. 

> 
>> +
>> +	old_migratetype = get_pageblock_migratetype(page);
>> +	set_pageblock_flags_group(page, MIGRATE_ISOLATE,
>> +			PB_migrate, PB_migrate_end);
>> +
>> +	if (old_migratetype != MIGRATE_ISOLATE)
>> +		atomic_inc(&zone->nr_migrate_isolate);
>> +}
> 
> If the old type was MIGRATE_ISOLATE then it was also unnecessary to call
> set_pageblock_flags_group() or anything else. It's also unnecessary to
> pass in zone because you can figure it out from the page but no harm.
> 
> This could have been a lot easier to read with something like;
> 
> static void set_pageblock_isolate(struct zone *zone, struct page *page)
> {
> 	BUG_ON(page_zone(page) ! = zone);
> 	if (get_pageblock_migratetype(page) == MIGRATE_ISOLATE)
> 		return;
> 
> 	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> 	zone->nr_pageblock_isolate++;
> }
> 
> If set_migratetype_isolate is the only caller then it barely warrents a
> helper functions because it simply looks like
> 
> if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE) {
> 	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> 	zone->nr_pageblock_isolate++;
> }
> 	
> 
>> +
>> +static void unset_pageblock_isolate(struct zone *zone, struct page *page,
>> +		unsigned long migratetype)
>> +{
> 
> The word "unset" in this context would normally refer to a boolean but
> you're actually restoring an old value. Hence reset_pageblock_isolate or
> restore_pageblock_migratetype would have been more appropriate.

> 

> Oh, I see you are matching the naming of unset_migratetype_isolate().
> That sucks, hope it was not me that suggested that name originally :/


Naming/comment is very hard part rather than coding on non-native speakers. 
Will fix.

> 
> migratetype is almost always int too, not sure where that unsigned long
> came out of.


Will fix. 

> 
>> +	assert_spin_locked(&zone->lock);
>> +
>> +	if (unlikely(page_group_by_mobility_disabled)) {
>> +		set_pageblock_flags_group(page, migratetype,
>> +				PB_migrate, PB_migrate_end);
>> +		return;
>> +	}
>> +
>> +	BUG_ON(get_pageblock_migratetype(page) != MIGRATE_ISOLATE);
>> +	BUG_ON(migratetype == MIGRATE_ISOLATE);
>> +
>> +	set_pageblock_flags_group(page, migratetype,
>> +			PB_migrate, PB_migrate_end);
>> +	atomic_dec(&zone->nr_migrate_isolate);
>> +	BUG_ON(atomic_read(&zone->nr_migrate_isolate) < 0);
>> +}
>> +
> 
> static void reset_pageblock_isolate(struct zone *zone, struct page *page,
> 				    int migratetype)
> {
> 	if (WARN_ON(get_pageblock_migratetype(page) != MIGRATE_ISOLATE))
> 		return;
> 
> 	BUG_ON(zone->nr_pageblock_isolate == 0);
> 	set_pageblock_migratetype(page, migratetype);
> 	zone->nr_pageblock_isolate--;
> }
> 
> 
>>  int set_migratetype_isolate(struct page *page)
>>  {
>>  	struct zone *zone;
>> @@ -54,7 +93,7 @@ int set_migratetype_isolate(struct page *page)
>>  
>>  out:
>>  	if (!ret) {
>> -		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>> +		set_pageblock_isolate(zone, page);
>>  		move_freepages_block(zone, page, MIGRATE_ISOLATE);
>>  	}
>>  
>> @@ -72,8 +111,8 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>>  	spin_lock_irqsave(&zone->lock, flags);
>>  	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
>>  		goto out;
>> -	set_pageblock_migratetype(page, migratetype);
>>  	move_freepages_block(zone, page, migratetype);
>> +	unset_pageblock_isolate(zone, page, migratetype);
>>  out:
>>  	spin_unlock_irqrestore(&zone->lock, flags);
>>  }
> 
> While this patch looks like it would work as advertised I also think that
> it is more complicated than it needs to be. The use of atomics and exact
> counts of isolated pages look unnecessary.  set_migeratetype_isolate and
> unset_pageblock_isolate could have been a lot easier to read.
> 


Thanks for the good review, Mel!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
