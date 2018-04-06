Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C02886B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 12:27:13 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id i4so1083064wrh.4
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 09:27:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g3si2472686edh.496.2018.04.06.09.27.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Apr 2018 09:27:12 -0700 (PDT)
Date: Fri, 6 Apr 2018 12:28:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 3/4] mm/vmscan: Don't change pgdat state on base of a
 single LRU list state.
Message-ID: <20180406162835.GD20806@cmpxchg.org>
References: <20180323152029.11084-1-aryabinin@virtuozzo.com>
 <20180323152029.11084-4-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180323152029.11084-4-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Fri, Mar 23, 2018 at 06:20:28PM +0300, Andrey Ryabinin wrote:
> We have separate LRU list for each memory cgroup. Memory reclaim iterates
> over cgroups and calls shrink_inactive_list() every inactive LRU list.
> Based on the state of a single LRU shrink_inactive_list() may flag
> the whole node as dirty,congested or under writeback. This is obviously
> wrong and hurtful. It's especially hurtful when we have possibly
> small congested cgroup in system. Than *all* direct reclaims waste time
> by sleeping in wait_iff_congested(). And the more memcgs in the system
> we have the longer memory allocation stall is, because
> wait_iff_congested() called on each lru-list scan.
> 
> Sum reclaim stats across all visited LRUs on node and flag node as dirty,
> congested or under writeback based on that sum. Also call
> congestion_wait(), wait_iff_congested() once per pgdat scan, instead of
> once per lru-list scan.
> 
> This only fixes the problem for global reclaim case. Per-cgroup reclaim
> may alter global pgdat flags too, which is wrong. But that is separate
> issue and will be addressed in the next patch.
> 
> This change will not have any effect on a systems with all workload
> concentrated in a single cgroup.

This makes a ton of sense, and I'm going to ack the patch, but here is
one issue here:

> @@ -2587,6 +2554,61 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  		if (sc->nr_reclaimed - nr_reclaimed)
>  			reclaimable = true;
>  
> +		/*
> +		 * If reclaim is isolating dirty pages under writeback, it
> +		 * implies that the long-lived page allocation rate is exceeding
> +		 * the page laundering rate. Either the global limits are not
> +		 * being effective at throttling processes due to the page
> +		 * distribution throughout zones or there is heavy usage of a
> +		 * slow backing device. The only option is to throttle from
> +		 * reclaim context which is not ideal as there is no guarantee
> +		 * the dirtying process is throttled in the same way
> +		 * balance_dirty_pages() manages.
> +		 *
> +		 * Once a node is flagged PGDAT_WRITEBACK, kswapd will count the
> +		 * number of pages under pages flagged for immediate reclaim and
> +		 * stall if any are encountered in the nr_immediate check below.
> +		 */
> +		if (sc->nr.writeback && sc->nr.writeback == sc->nr.file_taken)
> +			set_bit(PGDAT_WRITEBACK, &pgdat->flags);
> +
> +		/*
> +		 * Legacy memcg will stall in page writeback so avoid forcibly
> +		 * stalling here.
> +		 */
> +		if (sane_reclaim(sc)) {
> +			/*
> +			 * Tag a node as congested if all the dirty pages
> +			 * scanned were backed by a congested BDI and
> +			 * wait_iff_congested will stall.
> +			 */
> +			if (sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
> +				set_bit(PGDAT_CONGESTED, &pgdat->flags);
> +
> +			/* Allow kswapd to start writing pages during reclaim.*/
> +			if (sc->nr.unqueued_dirty == sc->nr.file_taken)
> +				set_bit(PGDAT_DIRTY, &pgdat->flags);
> +
> +			/*
> +			 * If kswapd scans pages marked marked for immediate
> +			 * reclaim and under writeback (nr_immediate), it
> +			 * implies that pages are cycling through the LRU
> +			 * faster than they are written so also forcibly stall.
> +			 */
> +			if (sc->nr.immediate)
> +				congestion_wait(BLK_RW_ASYNC, HZ/10);
> +		}

This isn't quite equivalent to what we have right now.

Yes, nr_dirty, nr_unqueued_dirty and nr_congested apply to file pages
only. That part is about waking the flushers and avoiding writing
files in 4k chunks from reclaim context. So those numbers do need to
be compared against scanned *file* pages.

But nr_writeback and nr_immediate is about throttling reclaim when we
hit too many pages under writeout, and that applies to both file and
anonymous/swap pages. We do want to throttle on swapout, too.

So nr_writeback needs to check against all nr_taken, not just file.
