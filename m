Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 3035B6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 19:34:30 -0400 (EDT)
Message-ID: <4FECEA16.4060200@kernel.org>
Date: Fri, 29 Jun 2012 08:34:46 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2 v2] memory-hotplug: fix kswapd looping forever problem
References: <1340783514-8150-1-git-send-email-minchan@kernel.org> <1340783514-8150-3-git-send-email-minchan@kernel.org> <4FEC042C.5070509@jp.fujitsu.com>
In-Reply-To: <4FEC042C.5070509@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

Hi Kame,

On 06/28/2012 04:13 PM, Kamezawa Hiroyuki wrote:

> (2012/06/27 16:51), Minchan Kim wrote:
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
>> Copy/modify from Mel's quote
>> "
>> Ideal solution would be "allocating" the pageblock.
>> It would keep the free space accounting as it is but historically,
>> memory hotplug didn't allocate pages because it would be difficult to
>> detect if a pageblock was isolated or if part of some balloon.
>> Allocating just full pageblocks would work around this, However,
>> it would play very badly with CMA.
>> "
>>
>> [1] http://lkml.org/lkml/2012/6/14/74
>>
>> * from v1
>>   - add changelog
>>   - make functions simple
>>   - remove atomic variable
>>   - discard exact isolated free page accounting.
>>   - rebased on next-20120626
>>
>> Suggested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>
>> Aaditya, coul you confirm this patch solve your problem and
>> make sure nr_pageblock_isolate is zero after hotplug end?
>>
>> Thanks!
>>
>>   include/linux/mmzone.h |    8 ++++++++
>>   mm/page_alloc.c        |   31 +++++++++++++++++++++++++++++++
>>   mm/page_isolation.c    |   29 +++++++++++++++++++++++++++--
>>   3 files changed, 66 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index dbc876e..6ee83b8 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -474,6 +474,14 @@ struct zone {
>>   	 * rarely used fields:
>>   	 */
>>   	const char		*name;
>> +#ifdef CONFIG_MEMORY_ISOLATION
>> +	/*
>> +	 * the number of MIGRATE_ISOLATE *pageblock*.
>> +	 * We need this for free page counting. Look at zone_watermark_ok_safe.
>> +	 * It's protected by zone->lock
>> +	 */
>> +	int		nr_pageblock_isolate;
>> +#endif
>>   } ____cacheline_internodealigned_in_smp;
>>   
>>   typedef enum {
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index c175fa9..b12c8ec 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -218,6 +218,11 @@ EXPORT_SYMBOL(nr_online_nodes);
>>   
>>   int page_group_by_mobility_disabled __read_mostly;
>>   
>> +/*
>> + * NOTE:
>> + * Don't use set_pageblock_migratetype(page, MIGRATE_ISOLATE) directly.
>> + * Instead, use {un}set_pageblock_isolate.
>> + */
>>   void set_pageblock_migratetype(struct page *page, int migratetype)
>>   {
>>   	if (unlikely(page_group_by_mobility_disabled))
>> @@ -1614,6 +1619,23 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>>   	return true;
>>   }
>>   
>> +#ifdef CONFIG_MEMORY_ISOLATION
>> +static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
>> +{
>> +	unsigned long nr_pages = 0;
>> +
>> +	if (unlikely(zone->nr_pageblock_isolate)) {
>> +		nr_pages = zone->nr_pageblock_isolate * pageblock_nr_pages;
>> +	}
>> +	return nr_pages;
>> +}
>> +#else
>> +static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
>> +{
>> +	return 0;
>> +}
>> +#endif
>> +
>>   bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>>   		      int classzone_idx, int alloc_flags)
>>   {
>> @@ -1629,6 +1651,14 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
>>   	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
>>   		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
>>   
>> +	/*
>> +	 * If the zone has MIGRATE_ISOLATE type free page,
>> +	 * we should consider it. nr_zone_isolate_freepages is never
>> +	 * accurate so kswapd might not sleep although she can.
>> +	 * But it's more desirable for memory hotplug rather than
>> +	 * forever sleep which cause livelock in direct reclaim path.
>> +	 */
>> +	free_pages -= nr_zone_isolate_freepages(z);
> 
> Here, free_pages could be < 0 ?


It could but __zone_watermark_ok returns false so kswapd is going to work
without sleep. It's not bad because nr_zone_isolate_freepages already
isn't accurate
and hotplug event is temporal so kswapd should work well after end hotplug.



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
