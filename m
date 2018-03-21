Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1AA16B0003
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 07:32:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 31so2409835wrr.2
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 04:32:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m14si3286730wrb.449.2018.03.21.04.32.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 04:32:20 -0700 (PDT)
Date: Wed, 21 Mar 2018 12:32:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] mm/vmscan: Don't change pgdat state on base of a
 single LRU list state.
Message-ID: <20180321113217.GG23100@dhcp22.suse.cz>
References: <20180315164553.17856-1-aryabinin@virtuozzo.com>
 <20180315164553.17856-5-aryabinin@virtuozzo.com>
 <20180320152550.GZ23100@dhcp22.suse.cz>
 <232175b6-4cb0-1123-66cb-b9acafdcd660@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <232175b6-4cb0-1123-66cb-b9acafdcd660@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 21-03-18 13:40:32, Andrey Ryabinin wrote:
> On 03/20/2018 06:25 PM, Michal Hocko wrote:
> > On Thu 15-03-18 19:45:52, Andrey Ryabinin wrote:
> >> We have separate LRU list for each memory cgroup. Memory reclaim iterates
> >> over cgroups and calls shrink_inactive_list() every inactive LRU list.
> >> Based on the state of a single LRU shrink_inactive_list() may flag
> >> the whole node as dirty,congested or under writeback. This is obviously
> >> wrong and hurtful. It's especially hurtful when we have possibly
> >> small congested cgroup in system. Than *all* direct reclaims waste time
> >> by sleeping in wait_iff_congested().
> > 
> > I assume you have seen this in real workloads. Could you be more
> > specific about how you noticed the problem?
> > 
> 
> Does it matter?

Yes. Having relevant information in the changelog can help other people
to evaluate whether they need to backport the patch. Their symptoms
might be similar or even same.

> One of our userspace processes have some sort of watchdog.
> When it doesn't receive some event in time it complains that process stuck.
> In this case in-kernel allocation stuck in wait_iff_congested.

OK, so normally it would exhibit as a long stall in the page allocator.
Anyway I was more curious about the setup. I assume you have many memcgs
and some of them with a very small hard limit which triggers the
throttling to other memcgs?

> >> Sum reclaim stats across all visited LRUs on node and flag node as dirty,
> >> congested or under writeback based on that sum. This only fixes the
> >> problem for global reclaim case. Per-cgroup reclaim will be addressed
> >> separately by the next patch.
> >>
> >> This change will also affect systems with no memory cgroups. Reclaimer
> >> now makes decision based on reclaim stats of the both anon and file LRU
> >> lists. E.g. if the file list is in congested state and get_scan_count()
> >> decided to reclaim some anon pages, reclaimer will start shrinking
> >> anon without delay in wait_iff_congested() like it was before. It seems
> >> to be a reasonable thing to do. Why waste time sleeping, before reclaiming
> >> anon given that we going to try to reclaim it anyway?
> > 
> > Well, if we have few anon pages in the mix then we stop throttling the
> > reclaim, I am afraid. I am worried this might get us kswapd hogging CPU
> > problems back.
> > 
> 
> Yeah, it's not ideal choice. If only few anon pages taken than *not* throttling is bad,
> and if few file pages taken and many anon than *not* throttling is probably good.
> 
> Anyway, such requires more thought,research,justification, etc.
> I'll change the patch to take into account file only pages, as it was before the patch.

Keeping the status quo would be safer for now. Handling all those kswapd
at 100% CPU issues was quite painful.
 
> > [...]
> 
> >> @@ -2579,6 +2542,58 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> >>  		if (sc->nr_reclaimed - nr_reclaimed)
> >>  			reclaimable = true;
> >>  
> >> +		/*
> >> +		 * If reclaim is isolating dirty pages under writeback, it implies
> >> +		 * that the long-lived page allocation rate is exceeding the page
> >> +		 * laundering rate. Either the global limits are not being effective
> >> +		 * at throttling processes due to the page distribution throughout
> >> +		 * zones or there is heavy usage of a slow backing device. The
> >> +		 * only option is to throttle from reclaim context which is not ideal
> >> +		 * as there is no guarantee the dirtying process is throttled in the
> >> +		 * same way balance_dirty_pages() manages.
> >> +		 *
> >> +		 * Once a node is flagged PGDAT_WRITEBACK, kswapd will count the number
> >> +		 * of pages under pages flagged for immediate reclaim and stall if any
> >> +		 * are encountered in the nr_immediate check below.
> >> +		 */
> >> +		if (stat.nr_writeback && stat.nr_writeback == stat.nr_taken)
> >> +			set_bit(PGDAT_WRITEBACK, &pgdat->flags);
> >> +
> >> +		/*
> >> +		 * Legacy memcg will stall in page writeback so avoid forcibly
> >> +		 * stalling here.
> >> +		 */
> >> +		if (sane_reclaim(sc)) {
> >> +			/*
> >> +			 * Tag a node as congested if all the dirty pages scanned were
> >> +			 * backed by a congested BDI and wait_iff_congested will stall.
> >> +			 */
> >> +			if (stat.nr_dirty && stat.nr_dirty == stat.nr_congested)
> >> +				set_bit(PGDAT_CONGESTED, &pgdat->flags);
> >> +
> >> +			/* Allow kswapd to start writing pages during reclaim. */
> >> +			if (stat.nr_unqueued_dirty == stat.nr_taken)
> >> +				set_bit(PGDAT_DIRTY, &pgdat->flags);
> >> +
> >> +			/*
> >> +			 * If kswapd scans pages marked marked for immediate
> >> +			 * reclaim and under writeback (nr_immediate), it implies
> >> +			 * that pages are cycling through the LRU faster than
> >> +			 * they are written so also forcibly stall.
> >> +			 */
> >> +			if (stat.nr_immediate)
> >> +				congestion_wait(BLK_RW_ASYNC, HZ/10);
> >> +		}
> >> +
> >> +		/*
> >> +		 * Stall direct reclaim for IO completions if underlying BDIs and node
> >> +		 * is congested. Allow kswapd to continue until it starts encountering
> >> +		 * unqueued dirty pages or cycling through the LRU too quickly.
> >> +		 */
> >> +		if (!sc->hibernation_mode && !current_is_kswapd() &&
> >> +		    current_may_throttle())
> >> +			wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
> >> +
> >>  	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
> >>  					 sc->nr_scanned - nr_scanned, sc));
> > 
> > Why didn't you put the whole thing after the loop?
> > 
> 
> Why this should be put after the loop? Here we already scanned all LRUs on node and
> can decide in what state the node is. If should_countinue_reclaim() decides to continue,
> the reclaim will be continued in accordance to the state of the node.

I thought the whole point of the change was to evaluate all these
decisions once per pgdat reclaim which would be after the final loop.

I do not have a strong preference here, though, so I was merely asking
because the choice was not obvious to me and the changelog didn't say
either. I guess both are fine.
-- 
Michal Hocko
SUSE Labs
