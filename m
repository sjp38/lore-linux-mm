Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id D4AE56B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 04:10:15 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l65so136426626wmf.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 01:10:15 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id fa10si7183079wjd.246.2016.01.27.01.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 01:10:14 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 11A811C2191
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:10:14 +0000 (GMT)
Date: Wed, 27 Jan 2016 09:10:12 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 2/3] mm, compaction: introduce kcompactd
Message-ID: <20160127091012.GL3162@techsingularity.net>
References: <1453822575-20835-1-git-send-email-vbabka@suse.cz>
 <1453822575-20835-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1453822575-20835-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Jan 26, 2016 at 04:36:14PM +0100, Vlastimil Babka wrote:
> Memory compaction can be currently performed in several contexts:
> 
> - kswapd balancing a zone after a high-order allocation failure
> - direct compaction to satisfy a high-order allocation, including THP page
>   fault attemps
> - khugepaged trying to collapse a hugepage
> - manually from /proc
> 
> The purpose of compaction is two-fold. The obvious purpose is to satisfy a
> (pending or future) high-order allocation, and is easy to evaluate. The other
> purpose is to keep overal memory fragmentation low and help the
> anti-fragmentation mechanism. The success wrt the latter purpose is more
> difficult to evaluate though.
> 
> The current situation wrt the purposes has a few drawbacks:
> 
> - compaction is invoked only when a high-order page or hugepage is not
>   available (or manually). This might be too late for the purposes of keeping
>   memory fragmentation low.
> - direct compaction increases latency of allocations. Again, it would be
>   better if compaction was performed asynchronously to keep fragmentation low,
>   before the allocation itself comes.
> - (a special case of the previous) the cost of compaction during THP page
>   faults can easily offset the benefits of THP.
> - kswapd compaction appears to be complex, fragile and not working in some
>   scenarios
> 

An addendum to that is that kswapd can be compacting for a high-order
allocation request when it should be reclaiming memory for an order-0
request.

My recollection is that kswapd compacting was meant to help atomic
high-order allocations but I wonder if the same problem even exists with
the revised watermark handling.

> To improve the situation, we should be able to benefit from an equivalent of
> kswapd, but for compaction - i.e. a background thread which responds to
> fragmentation and the need for high-order allocations (including hugepages)
> somewhat proactively.
> 
> One possibility is to extend the responsibilities of kswapd, which could
> however complicate its design too much. It should be better to let kswapd
> handle reclaim, as order-0 allocations are often more critical than high-order
> ones.
> 
> Another possibility is to extend khugepaged, but this kthread is a single
> instance and tied to THP configs.
> 

That also would not handle the atomic high-order allocation case.

> This patch goes with the option of a new set of per-node kthreads called
> kcompactd, and lays the foundations, without introducing any new tunables.
> The lifecycle mimics kswapd kthreads, including the memory hotplug hooks.
> 
> Waking up of the kcompactd threads is also tied to kswapd activity and follows
> these rules:
> - we don't want to affect any fastpaths, so wake up kcompactd only from the
>   slowpath, as it's done for kswapd

Ok

> - if kswapd is doing reclaim, it's more important than compaction, so don't
>   invoke kcompactd until kswapd goes to sleep

This makes sense given that kswapd can be reclaiming order-0 pages so
compaction can even start with a reasonable chance of success.

> - the target order used for kswapd is passed to kcompactd
> 
> The kswapd compact/reclaim loop for high-order pages will be removed in the
> next patch with the description of what's wrong with it.
> 
> In this patch, kcompactd uses the standard compaction_suitable() and
> compact_finished() criteria, which means it will most likely have nothing left
> to do after kswapd finishes, until the next patch. Kcompactd also mimics
> direct compaction somewhat by trying async compaction first and sync compaction
> afterwards, and uses the deferred compaction functionality.
> 

Why should it try async compaction first? The deferred compaction makes
sense as kcompact will need some sort of limitation on the amount of
CPU it can use.

> Future possible future uses for kcompactd include the ability to wake up
> kcompactd on demand in special situations, such as when hugepages are not
> available (currently not done due to __GFP_NO_KSWAPD) or when a fragmentation
> event (i.e. __rmqueue_fallback()) occurs. It's also possible to perform
> periodic compaction with kcompactd.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/compaction.h        |  16 +++
>  include/linux/mmzone.h            |   6 +
>  include/linux/vm_event_item.h     |   1 +
>  include/trace/events/compaction.h |  55 +++++++++
>  mm/compaction.c                   | 227 ++++++++++++++++++++++++++++++++++++++
>  mm/memory_hotplug.c               |  15 ++-
>  mm/page_alloc.c                   |   3 +
>  mm/vmscan.c                       |   6 +
>  mm/vmstat.c                       |   1 +
>  9 files changed, 325 insertions(+), 5 deletions(-)
> 
> <SNIP>
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 585de54dbe8c..7452975fa481 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -17,6 +17,9 @@
>  #include <linux/balloon_compaction.h>
>  #include <linux/page-isolation.h>
>  #include <linux/kasan.h>
> +#include <linux/kthread.h>
> +#include <linux/freezer.h>
> +#include <linux/module.h>
>  #include "internal.h"
>  
>  #ifdef CONFIG_COMPACTION
> @@ -29,6 +32,7 @@ static inline void count_compact_events(enum vm_event_item item, long delta)
>  {
>  	count_vm_events(item, delta);
>  }
> +
>  #else
>  #define count_compact_event(item) do { } while (0)
>  #define count_compact_events(item, delta) do { } while (0)

Spurious whitespace change.

> @@ -1759,4 +1763,227 @@ void compaction_unregister_node(struct node *node)
>  }
>  #endif /* CONFIG_SYSFS && CONFIG_NUMA */
>  
> +static bool kcompactd_work_requested(pg_data_t *pgdat)
> +{
> +	return pgdat->kcompactd_max_order > 0;
> +}
> +

inline

> +static bool kcompactd_node_suitable(pg_data_t *pgdat)
> +{
> +	int zoneid;
> +	struct zone *zone;
> +
> +	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
> +		zone = &pgdat->node_zones[zoneid];
> +
> +		if (!populated_zone(zone))
> +			continue;
> +
> +		if (compaction_suitable(zone, pgdat->kcompactd_max_order, 0,
> +					pgdat->kcompactd_classzone_idx)
> +							== COMPACT_CONTINUE)
> +			return true;
> +	}
> +
> +	return false;
> +}
> +

Why does this traverse all zones and not just the ones within the
classzone_idx?

> +static void kcompactd_do_work(pg_data_t *pgdat)
> +{
> +	/*
> +	 * With no special task, compact all zones so that a page of requested
> +	 * order is allocatable.
> +	 */
> +	int zoneid;
> +	struct zone *zone;
> +	struct compact_control cc = {
> +		.order = pgdat->kcompactd_max_order,
> +		.classzone_idx = pgdat->kcompactd_classzone_idx,
> +		.mode = MIGRATE_ASYNC,
> +		.ignore_skip_hint = true,
> +
> +	};
> +	bool success = false;
> +
> +	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
> +							cc.classzone_idx);
> +	count_vm_event(KCOMPACTD_WAKE);
> +
> +retry:
> +	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {

Again, why is classzone_idx not taken into account?

> +		int status;
> +
> +		zone = &pgdat->node_zones[zoneid];
> +		if (!populated_zone(zone))
> +			continue;
> +
> +		if (compaction_deferred(zone, cc.order))
> +			continue;
> +
> +		if (compaction_suitable(zone, cc.order, 0, zoneid) !=
> +							COMPACT_CONTINUE)
> +			continue;
> +
> +		cc.nr_freepages = 0;
> +		cc.nr_migratepages = 0;
> +		cc.zone = zone;
> +		INIT_LIST_HEAD(&cc.freepages);
> +		INIT_LIST_HEAD(&cc.migratepages);
> +
> +		status = compact_zone(zone, &cc);
> +
> +		if (zone_watermark_ok(zone, cc.order, low_wmark_pages(zone),
> +						cc.classzone_idx, 0)) {
> +			success = true;
> +			compaction_defer_reset(zone, cc.order, false);
> +		} else if (cc.mode != MIGRATE_ASYNC &&
> +						status == COMPACT_COMPLETE) {
> +			defer_compaction(zone, cc.order);
> +		}
> +
> +		VM_BUG_ON(!list_empty(&cc.freepages));
> +		VM_BUG_ON(!list_empty(&cc.migratepages));
> +	}
> +
> +	if (!success && cc.mode == MIGRATE_ASYNC) {
> +		cc.mode = MIGRATE_SYNC_LIGHT;
> +		goto retry;
> +	}
> +

Still not getting why kcompactd should concern itself with async
compaction. It's really direct compaction that cared and was trying to
avoid stalls.

> +	 * Regardless of success, we are done until woken up next. But remember
> +	 * the requested order/classzone_idx in case it was higher/tighter than
> +	 * our current ones
> +	 */
> +	if (pgdat->kcompactd_max_order <= cc.order)
> +		pgdat->kcompactd_max_order = 0;
> +	if (pgdat->classzone_idx >= cc.classzone_idx)
> +		pgdat->classzone_idx = pgdat->nr_zones - 1;
> +}
> +
>
> <SNIP>
>
> @@ -1042,7 +1043,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	arg.nr_pages = nr_pages;
>  	node_states_check_changes_online(nr_pages, zone, &arg);
>  
> -	nid = pfn_to_nid(pfn);
> +	nid = zone_to_nid(zone);
>  
>  	ret = memory_notify(MEM_GOING_ONLINE, &arg);
>  	ret = notifier_to_errno(ret);
> @@ -1082,7 +1083,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	pgdat_resize_unlock(zone->zone_pgdat, &flags);
>  
>  	if (onlined_pages) {
> -		node_states_set_node(zone_to_nid(zone), &arg);
> +		node_states_set_node(nid, &arg);
>  		if (need_zonelists_rebuild)
>  			build_all_zonelists(NULL, NULL);
>  		else

Why are these two hunks necessary?

> @@ -1093,8 +1094,10 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  
>  	init_per_zone_wmark_min();
>  
> -	if (onlined_pages)
> -		kswapd_run(zone_to_nid(zone));
> +	if (onlined_pages) {
> +		kswapd_run(nid);
> +		kcompactd_run(nid);
> +	}
>  
>  	vm_total_pages = nr_free_pagecache_pages();
>  
> @@ -1858,8 +1861,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  		zone_pcp_update(zone);
>  
>  	node_states_clear_node(node, &arg);
> -	if (arg.status_change_nid >= 0)
> +	if (arg.status_change_nid >= 0) {
>  		kswapd_stop(node);
> +		kcompactd_stop(node);
> +	}
>  
>  	vm_total_pages = nr_free_pagecache_pages();
>  	writeback_set_ratelimit();
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 63358d9f9aa9..7747eb36e789 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5212,6 +5212,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  #endif
>  	init_waitqueue_head(&pgdat->kswapd_wait);
>  	init_waitqueue_head(&pgdat->pfmemalloc_wait);
> +#ifdef CONFIG_COMPACTION
> +	init_waitqueue_head(&pgdat->kcompactd_wait);
> +#endif
>  	pgdat_page_ext_init(pgdat);
>  
>  	for (j = 0; j < MAX_NR_ZONES; j++) {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 72d52d3aef74..1449e21c55cc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3408,6 +3408,12 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
>  		 */
>  		reset_isolation_suitable(pgdat);
>  
> +		/*
> +		 * We have freed the memory, now we should compact it to make
> +		 * allocation of the requested order possible.
> +		 */
> +		wakeup_kcompactd(pgdat, order, classzone_idx);
> +
>  		if (!kthread_should_stop())
>  			schedule();
>  

This initially confused me but it's due to patch ordering. It's silly
but when this patch is applied then both kswapd and kcompactd are
compacting memory. I would prefer if the patches were in reverse order
but that is purely taste.

While this was not a comprehensive review, I think the patch is ok in
principal. While deferred compaction will keep the CPU usage under control,
the main concern is that kcompactd consumes too much CPU but I do not
see a case where that would trigger that kswapd would not have
encountered already.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
