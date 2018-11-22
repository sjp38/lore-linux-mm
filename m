Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 589BE6B2C51
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 12:05:06 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m19so4771176edc.6
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 09:05:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h22-v6si1269004ejl.15.2018.11.22.09.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 09:05:04 -0800 (PST)
Subject: Re: [PATCH 4/4] mm: Stall movable allocations until kswapd progresses
 during serious external fragmentation event
References: <20181121101414.21301-1-mgorman@techsingularity.net>
 <20181121101414.21301-5-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <35ea6691-e819-5581-7d32-39c1abfbe775@suse.cz>
Date: Thu, 22 Nov 2018 18:02:10 +0100
MIME-Version: 1.0
In-Reply-To: <20181121101414.21301-5-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 11/21/18 11:14 AM, Mel Gorman wrote:
> An event that potentially causes external fragmentation problems has
> already been described but there are degrees of severity.  A "serious"
> event is defined as one that steals a contiguous range of pages of an order
> lower than fragment_stall_order (PAGE_ALLOC_COSTLY_ORDER by default). If a
> movable allocation request that is allowed to sleep needs to steal a small
> block then it schedules until kswapd makes progress or a timeout passes.
> The watermarks are also boosted slightly faster so that kswapd makes
> greater effort to reclaim enough pages to avoid the fragmentation event.
> 
> This stall is not guaranteed to avoid serious fragmentation events.
> If memory pressure is high enough, the pages freed by kswapd may be
> reallocated or the free pages may not be in pageblocks that contain
> only movable pages. Furthermore an allocation request that cannot stall
> (e.g. atomic allocations) or unmovable/reclaimable allocations will still
> proceed without stalling.

Not doing this for unmovable/reclaimable allocations is kinda disadvantage?

>  ==============================================================
>  
> +fragment_stall_order
> +
> +External fragmentation control is managed on a pageblock level where the
> +page allocator tries to avoid mixing pages of different mobility within page
> +blocks (e.g. order 9 on 64-bit x86). If external fragmentation is perfectly
> +controlled then a THP allocation will often succeed up to the number of
> +movable pageblocks in the system as reported by /proc/pagetypeinfo.
> +
> +When memory is low, the system may have to mix pageblocks and will wake
> +kswapd to try control future fragmentation. fragment_stall_order controls if
> +the allocating task will stall if possible until kswapd makes some progress
> +in preference to fragmenting the system. This incurs a small stall penalty
> +in exchange for future success at allocating huge pages. If the stalls
> +are undesirable and high-order allocations are irrelevant then this can
> +be disabled by writing 0 to the tunable. Writing the pageblock order will
> +strongly (but not perfectly) control external fragmentation.
> +
> +The default will stall for fragmenting allocations smaller than the
> +PAGE_ALLOC_COSTLY_ORDER (defined as order-3 at the time of writing).

Perhaps be more explicit that steals of orders strictly lower than given
value will stall? So for the default order-3, the sysctl value is 4,
which might confuse somebody.

> +
> @@ -2130,9 +2131,10 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
>  	return false;
>  }
>  
> +
> +static void stall_fragmentation(struct zone *pzone)
> +{
> +	DEFINE_WAIT(wait);
> +	long remaining = 0;
> +	long timeout = HZ/50;
> +	pg_data_t *pgdat = pzone->zone_pgdat;
> +
> +	if (current->flags & PF_MEMALLOC)
> +		return;
> +
> +	boost_watermark(pzone, true);

Should zone->lock be taken around this to make watermark_boost
adjustment safe? Similar to balance_pgdat().

> +	prepare_to_wait(&pgdat->pfmemalloc_wait, &wait, TASK_INTERRUPTIBLE);
> +	if (waitqueue_active(&pgdat->kswapd_wait))
> +		wake_up_interruptible(&pgdat->kswapd_wait);
> +	remaining = schedule_timeout(timeout);
> +	finish_wait(&pgdat->pfmemalloc_wait, &wait);
> +	if (remaining != timeout) {
> +		trace_mm_fragmentation_stall(pgdat->node_id,
> +			jiffies_to_usecs(timeout - remaining));
> +		count_vm_event(FRAGMENTSTALL);
> +	}
>  }
>  

> @@ -4186,6 +4234,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	alloc_flags = gfp_to_alloc_flags(gfp_mask);
>  
> +	/*
> +	 * Consider stalling on heavy for movable allocations in preference to
> +	 * fragmenting unmovable/reclaimable pageblocks.
> +	 */
> +	if ((gfp_mask & (__GFP_MOVABLE|__GFP_DIRECT_RECLAIM)) ==
> +			(__GFP_MOVABLE|__GFP_DIRECT_RECLAIM))
> +		alloc_flags |= ALLOC_FRAGMENT_STALL;

Surprised that this only has effect in the slowpath, i.e. when
watermarks are below 'low'. If it's intended (to not stall that much I
suppose) maybe explain the rationale in the changelog?

Thanks for the series, Mel, hope the results are still optimistic after
some of the fixes that might unfortunately limit its impact :)

Vlastimil
