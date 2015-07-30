Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1827B6B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 06:58:06 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so239176863wib.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 03:58:05 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id o14si32718782wiw.9.2015.07.30.03.58.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 03:58:04 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 9763099364
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:58:03 +0000 (UTC)
Date: Thu, 30 Jul 2015 11:58:01 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
Message-ID: <20150730105732.GJ19352@techsingularity.net>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
 <1435826795-13777-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1435826795-13777-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, Jul 02, 2015 at 10:46:32AM +0200, Vlastimil Babka wrote:
> Memory compaction can be currently performed in several contexts:
> 
> - kswapd balancing a zone after a high-order allocation failure

Which potentially was a problem that's hard to detect.

> - direct compaction to satisfy a high-order allocation, including THP page
>   fault attemps
> - khugepaged trying to collapse a hugepage
> - manually from /proc
> 
> The purpose of compaction is two-fold. The obvious purpose is to satisfy a
> (pending or future) high-order allocation, and is easy to evaluate. The other
> purpose is to keep overal memory fragmentation low and help the
> anti-fragmentation mechanism. The success wrt the latter purpose is more
> difficult to evaluate.
> 

The latter would be very difficult to measure. It would have to be shown
that the compaction took movable pages from a pageblock assigned to
unmovable or reclaimable pages and that the action prevented a pageblock
being stolen. You'd have to track all allocation/frees and compaction
events and run it through a simulator. Even then, it'd prove/disprove it
in a single case.

The "obvious purpose" is sufficient justification IMO.

> The current situation wrt the purposes has a few drawbacks:
> 
> - compaction is invoked only when a high-order page or hugepage is not
>   available (or manually). This might be too late for the purposes of keeping
>   memory fragmentation low.

Yep. The other side of the coin is that time can be spent compacting for
a non-existent user so there may be demand for tuning.

> - direct compaction increases latency of allocations. Again, it would be
>   better if compaction was performed asynchronously to keep fragmentation low,
>   before the allocation itself comes.

Definitely. Ideally direct compaction stalls would never occur unless the
caller absolutely requires it.

> - (a special case of the previous) the cost of compaction during THP page
>   faults can easily offset the benefits of THP.
> 
> To improve the situation, we need an equivalent of kswapd, but for compaction.
> E.g. a background thread which responds to fragmentation and the need for
> high-order allocations (including hugepages) somewhat proactively.
> 
> One possibility is to extend the responsibilities of kswapd, which could
> however complicate its design too much. It should be better to let kswapd
> handle reclaim, as order-0 allocations are often more critical than high-order
> ones.
> 

Agreed. Kswapd compacting can cause a direct reclaim stall for order-0. One
motivation for kswapd doing the compaction was for high-order atomic
allocation failures. At the risk of distracting from this series, the
requirement for high-order atomic allocations is better served by "Remove
zonelist cache and high-order watermark checking" than kswapd running
compaction. kcompactd would have a lot of value for both THP and allowing
high-atomic reserves to grow quickly if necessary

> Another possibility is to extend khugepaged, but this kthread is a single
> instance and tied to THP configs.
> 
> This patch goes with the option of a new set of per-node kthreads called
> kcompactd, and lays the foundations. The lifecycle mimics kswapd kthreads.
> 
> The work loop of kcompactd currently mimics an pageblock-order direct
> compaction attempt each 15 seconds. This might not be enough to keep
> fragmentation low, and needs evaluation.
> 

You could choose to adapt the rate based on the number of high-order
requests that entered the slow path. Initially I would not try though,
keep it simple first.

> When there's not enough free memory for compaction, kswapd is woken up for
> reclaim only (not compaction/reclaim).
> 
> Further patches will add the ability to wake up kcompactd on demand in special
> situations such as when hugepages are not available, or when a fragmentation
> event occured.
> 
> Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/compaction.h |  11 +++
>  include/linux/mmzone.h     |   4 ++
>  mm/compaction.c            | 173 +++++++++++++++++++++++++++++++++++++++++++++
>  mm/memory_hotplug.c        |  15 ++--
>  mm/page_alloc.c            |   3 +
>  5 files changed, 201 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index aa8f61c..a2525d8 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -51,6 +51,9 @@ extern void compaction_defer_reset(struct zone *zone, int order,
>  				bool alloc_success);
>  extern bool compaction_restarting(struct zone *zone, int order);
>  
> +extern int kcompactd_run(int nid);
> +extern void kcompactd_stop(int nid);
> +
>  #else
>  static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
>  			unsigned int order, int alloc_flags,
> @@ -83,6 +86,14 @@ static inline bool compaction_deferred(struct zone *zone, int order)
>  	return true;
>  }
>  
> +static int kcompactd_run(int nid)
> +{
> +	return 0;
> +}
> +extern void kcompactd_stop(int nid)
> +{
> +}
> +
>  #endif /* CONFIG_COMPACTION */
>  
>  #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 54d74f6..bc96a23 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -762,6 +762,10 @@ typedef struct pglist_data {
>  	/* Number of pages migrated during the rate limiting time interval */
>  	unsigned long numabalancing_migrate_nr_pages;
>  #endif
> +#ifdef CONFIG_COMPACTION
> +	struct task_struct *kcompactd;
> +	wait_queue_head_t kcompactd_wait;
> +#endif
>  } pg_data_t;
>  
>  #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 018f08d..fcbc093 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -17,6 +17,8 @@
>  #include <linux/balloon_compaction.h>
>  #include <linux/page-isolation.h>
>  #include <linux/kasan.h>
> +#include <linux/kthread.h>
> +#include <linux/freezer.h>
>  #include "internal.h"
>  
>  #ifdef CONFIG_COMPACTION
> @@ -29,6 +31,10 @@ static inline void count_compact_events(enum vm_event_item item, long delta)
>  {
>  	count_vm_events(item, delta);
>  }
> +
> +//TODO: add tuning knob
> +static unsigned int kcompactd_sleep_millisecs __read_mostly = 15000;
> +
>  #else
>  #define count_compact_event(item) do { } while (0)
>  #define count_compact_events(item, delta) do { } while (0)

Leave the tuning knob out unless it is absolutely required. kcompactd
may eventually decide that a time-based heuristic for wakeups is not
enough. Minimally add a mechanism that wakes kcompactd up in response to
allocation failures to how wakeup_kswapd gets called.  An alternative
would be to continue waking kswapd as normal, have kswapd only reclaim
order-0 pages as part of the reclaim/compaction phase and wake kcompactd
when the reclaim phase is complete. If kswapd decides that no reclaim is
necessary then kcompactd gets woken immediately.

khugepaged would then kick kswapd through the normal mechanism and
potentially avoid direct compaction.  On NUMA machines, it could keep
scanning to see if there is another node whose pages can be collapsed. On
UMA, it could just pause immediately and wait for kswapd and kcompactd to
do something useful.

There will be different opinions on periodic compaction but to be honest,
periodic compaction also could be implemented from userspace using the
compact_node sysfs files. The risk with periodic compaction is that it
can cause stalls in applications that do not care if they fault the pages
being migrated. This may happen even though there are zero requirements
for high-order pages from anybody.

> @@ -1714,4 +1720,171 @@ void compaction_unregister_node(struct node *node)
>  }
>  #endif /* CONFIG_SYSFS && CONFIG_NUMA */
>  
> +/*
> + * Has any special work been requested of kcompactd?
> + */
> +static bool kcompactd_work_requested(pg_data_t *pgdat)
> +{
> +	return false;
> +}
> +
> +static void kcompactd_do_work(pg_data_t *pgdat)
> +{
> +	/*
> +	 * //TODO: smarter decisions on how much to compact. Using pageblock
> +	 * order might result in no compaction, until fragmentation builds up
> +	 * too much. Using order -1 could be too aggressive on large zones.
> +	 *

You could consider using pgdat->kswapd_max_order? That thing is meant
to help kswapd decide what order is required by callers at the moment.
Again, kswapd does the order-0 reclaim and then wakes kcompactd with the
kswapd_max_order as a parameter.

> +	 * With no special task, compact all zones so that a pageblock-order
> +	 * page is allocatable. Wake up kswapd if there's not enough free
> +	 * memory for compaction.
> +	 */
> +	int zoneid;
> +	struct zone *zone;
> +	struct compact_control cc = {
> +		.order = pageblock_order,
> +		.mode = MIGRATE_SYNC,
> +		.ignore_skip_hint = true,
> +	};
> +
> +	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
> +
> +		int suitable;
> +
> +		zone = &pgdat->node_zones[zoneid];
> +		if (!populated_zone(zone))
> +			continue;
> +
> +		suitable = compaction_suitable(zone, cc.order, 0, 0);
> +
> +		if (suitable == COMPACT_SKIPPED) {
> +			/*
> +			 * We pass order==0 to kswapd so it doesn't compact by
> +			 * itself. We just need enough free pages to proceed
> +			 * with compaction here on next kcompactd wakeup.
> +			 */
> +			wakeup_kswapd(zone, 0, 0);
> +			continue;
> +		}

I think it makes more sense that kswapd kicks kcompactd than the other
way around. 

Overall, I like the idea.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
