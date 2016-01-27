Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B49C26B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 07:58:14 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p63so25106878wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 04:58:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a194si10897131wmd.73.2016.01.27.04.58.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 04:58:13 -0800 (PST)
Subject: Re: [RFC 2/3] mm, compaction: introduce kcompactd
References: <1453822575-20835-1-git-send-email-vbabka@suse.cz>
 <1453822575-20835-2-git-send-email-vbabka@suse.cz>
 <20160127091012.GL3162@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A8BEE3.3010708@suse.cz>
Date: Wed, 27 Jan 2016 13:58:11 +0100
MIME-Version: 1.0
In-Reply-To: <20160127091012.GL3162@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On 01/27/2016 10:10 AM, Mel Gorman wrote:
> On Tue, Jan 26, 2016 at 04:36:14PM +0100, Vlastimil Babka wrote:
>> Memory compaction can be currently performed in several contexts:
>> 
>> - kswapd balancing a zone after a high-order allocation failure
>> - direct compaction to satisfy a high-order allocation, including THP page
>>   fault attemps
>> - khugepaged trying to collapse a hugepage
>> - manually from /proc
>> 
>> The purpose of compaction is two-fold. The obvious purpose is to satisfy a
>> (pending or future) high-order allocation, and is easy to evaluate. The other
>> purpose is to keep overal memory fragmentation low and help the
>> anti-fragmentation mechanism. The success wrt the latter purpose is more
>> difficult to evaluate though.
>> 
>> The current situation wrt the purposes has a few drawbacks:
>> 
>> - compaction is invoked only when a high-order page or hugepage is not
>>   available (or manually). This might be too late for the purposes of keeping
>>   memory fragmentation low.
>> - direct compaction increases latency of allocations. Again, it would be
>>   better if compaction was performed asynchronously to keep fragmentation low,
>>   before the allocation itself comes.
>> - (a special case of the previous) the cost of compaction during THP page
>>   faults can easily offset the benefits of THP.
>> - kswapd compaction appears to be complex, fragile and not working in some
>>   scenarios
>> 
> 
> An addendum to that is that kswapd can be compacting for a high-order
> allocation request when it should be reclaiming memory for an order-0
> request.

Right, thanks.

> My recollection is that kswapd compacting was meant to help atomic
> high-order allocations but I wonder if the same problem even exists with
> the revised watermark handling.

Well, certainly nobody noticed kswapd compaction being dysfunctional.

> 
>> - the target order used for kswapd is passed to kcompactd
>> 
>> The kswapd compact/reclaim loop for high-order pages will be removed in the
>> next patch with the description of what's wrong with it.
>> 
>> In this patch, kcompactd uses the standard compaction_suitable() and
>> compact_finished() criteria, which means it will most likely have nothing left
>> to do after kswapd finishes, until the next patch. Kcompactd also mimics
>> direct compaction somewhat by trying async compaction first and sync compaction
>> afterwards, and uses the deferred compaction functionality.
>> 
> 
> Why should it try async compaction first? The deferred compaction makes
> sense as kcompact will need some sort of limitation on the amount of
> CPU it can use.

I was just being conservative, but good point. Unlike direct compaction, latency
doesn't bother kcompactd.

> 
>> @@ -1759,4 +1763,227 @@ void compaction_unregister_node(struct node *node)
>>  }
>>  #endif /* CONFIG_SYSFS && CONFIG_NUMA */
>>  
>> +static bool kcompactd_work_requested(pg_data_t *pgdat)
>> +{
>> +	return pgdat->kcompactd_max_order > 0;
>> +}
>> +
> 
> inline
> 
>> +static bool kcompactd_node_suitable(pg_data_t *pgdat)
>> +{
>> +	int zoneid;
>> +	struct zone *zone;
>> +
>> +	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
>> +		zone = &pgdat->node_zones[zoneid];
>> +
>> +		if (!populated_zone(zone))
>> +			continue;
>> +
>> +		if (compaction_suitable(zone, pgdat->kcompactd_max_order, 0,
>> +					pgdat->kcompactd_classzone_idx)
>> +							== COMPACT_CONTINUE)
>> +			return true;
>> +	}
>> +
>> +	return false;
>> +}
>> +
> 
> Why does this traverse all zones and not just the ones within the
> classzone_idx?

Hmm, guess I didn't revisit it after previous submission where kswapd compaction
wasn't being replaced by kcompactd. But kswapd also tries to balance higher
zones than those given by classzone_idx, if they needed. I'll rethink this.

>> +static void kcompactd_do_work(pg_data_t *pgdat)
>> +{
>> +	/*
>> +	 * With no special task, compact all zones so that a page of requested
>> +	 * order is allocatable.
>> +	 */
>> +	int zoneid;
>> +	struct zone *zone;
>> +	struct compact_control cc = {
>> +		.order = pgdat->kcompactd_max_order,
>> +		.classzone_idx = pgdat->kcompactd_classzone_idx,
>> +		.mode = MIGRATE_ASYNC,
>> +		.ignore_skip_hint = true,
>> +
>> +	};
>> +	bool success = false;
>> +
>> +	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
>> +							cc.classzone_idx);
>> +	count_vm_event(KCOMPACTD_WAKE);
>> +
>> +retry:
>> +	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
> 
> Again, why is classzone_idx not taken into account?

Might be worth to just do everything once we've woken up, like kswapd.
Deferred+suitable checks should prevent wasted attempts in either case.

[...]

>> +
>> +	if (!success && cc.mode == MIGRATE_ASYNC) {
>> +		cc.mode = MIGRATE_SYNC_LIGHT;
>> +		goto retry;
>> +	}
>> +
> 
> Still not getting why kcompactd should concern itself with async
> compaction. It's really direct compaction that cared and was trying to
> avoid stalls.

Right

>> +	 * Regardless of success, we are done until woken up next. But remember
>> +	 * the requested order/classzone_idx in case it was higher/tighter than
>> +	 * our current ones
>> +	 */
>> +	if (pgdat->kcompactd_max_order <= cc.order)
>> +		pgdat->kcompactd_max_order = 0;
>> +	if (pgdat->classzone_idx >= cc.classzone_idx)
>> +		pgdat->classzone_idx = pgdat->nr_zones - 1;
>> +}
>> +
>>
>> <SNIP>
>>
>> @@ -1042,7 +1043,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>>  	arg.nr_pages = nr_pages;
>>  	node_states_check_changes_online(nr_pages, zone, &arg);
>>  
>> -	nid = pfn_to_nid(pfn);
>> +	nid = zone_to_nid(zone);
>>  
>>  	ret = memory_notify(MEM_GOING_ONLINE, &arg);
>>  	ret = notifier_to_errno(ret);
>> @@ -1082,7 +1083,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>>  	pgdat_resize_unlock(zone->zone_pgdat, &flags);
>>  
>>  	if (onlined_pages) {
>> -		node_states_set_node(zone_to_nid(zone), &arg);
>> +		node_states_set_node(nid, &arg);
>>  		if (need_zonelists_rebuild)
>>  			build_all_zonelists(NULL, NULL);
>>  		else
> 
> Why are these two hunks necessary?

Just a drive-by cleanup/optimization that didn't seem worth separate patch. But
I probably should?

> 
>> @@ -1093,8 +1094,10 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>>  
>>  	init_per_zone_wmark_min();
>>  
>> -	if (onlined_pages)
>> -		kswapd_run(zone_to_nid(zone));
>> +	if (onlined_pages) {
>> +		kswapd_run(nid);
>> +		kcompactd_run(nid);
>> +	}
>>  
>>  	vm_total_pages = nr_free_pagecache_pages();
>>  
>> @@ -1858,8 +1861,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
>>  		zone_pcp_update(zone);
>>  
>>  	node_states_clear_node(node, &arg);
>> -	if (arg.status_change_nid >= 0)
>> +	if (arg.status_change_nid >= 0) {
>>  		kswapd_stop(node);
>> +		kcompactd_stop(node);
>> +	}
>>  
>>  	vm_total_pages = nr_free_pagecache_pages();
>>  	writeback_set_ratelimit();
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 63358d9f9aa9..7747eb36e789 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5212,6 +5212,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>>  #endif
>>  	init_waitqueue_head(&pgdat->kswapd_wait);
>>  	init_waitqueue_head(&pgdat->pfmemalloc_wait);
>> +#ifdef CONFIG_COMPACTION
>> +	init_waitqueue_head(&pgdat->kcompactd_wait);
>> +#endif
>>  	pgdat_page_ext_init(pgdat);
>>  
>>  	for (j = 0; j < MAX_NR_ZONES; j++) {
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 72d52d3aef74..1449e21c55cc 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -3408,6 +3408,12 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
>>  		 */
>>  		reset_isolation_suitable(pgdat);
>>  
>> +		/*
>> +		 * We have freed the memory, now we should compact it to make
>> +		 * allocation of the requested order possible.
>> +		 */
>> +		wakeup_kcompactd(pgdat, order, classzone_idx);
>> +
>>  		if (!kthread_should_stop())
>>  			schedule();
>>  
> 
> This initially confused me but it's due to patch ordering. It's silly
> but when this patch is applied then both kswapd and kcompactd are
> compacting memory. I would prefer if the patches were in reverse order
> but that is purely taste.

In reverse order there would be a case where neither is compacting. Guess I'll
just move the wakeup to the next patch. The separation is mainly for making
review more tractable.

> While this was not a comprehensive review, I think the patch is ok in
> principal. While deferred compaction will keep the CPU usage under control,
> the main concern is that kcompactd consumes too much CPU but I do not
> see a case where that would trigger that kswapd would not have
> encountered already.

Thanks! On the opposite, kswapd didn't consider deferred compaction, so it could
consume too much CPU if it wasn't otherwise broken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
