Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA8D96B0025
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:39:54 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t10-v6so2833157plr.12
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 03:39:54 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00100.outbound.protection.outlook.com. [40.107.0.100])
        by mx.google.com with ESMTPS id h7-v6si3519803plt.232.2018.03.21.03.39.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 03:39:53 -0700 (PDT)
Subject: Re: [PATCH 5/6] mm/vmscan: Don't change pgdat state on base of a
 single LRU list state.
References: <20180315164553.17856-1-aryabinin@virtuozzo.com>
 <20180315164553.17856-5-aryabinin@virtuozzo.com>
 <20180320152550.GZ23100@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <232175b6-4cb0-1123-66cb-b9acafdcd660@virtuozzo.com>
Date: Wed, 21 Mar 2018 13:40:32 +0300
MIME-Version: 1.0
In-Reply-To: <20180320152550.GZ23100@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On 03/20/2018 06:25 PM, Michal Hocko wrote:
> On Thu 15-03-18 19:45:52, Andrey Ryabinin wrote:
>> We have separate LRU list for each memory cgroup. Memory reclaim iterates
>> over cgroups and calls shrink_inactive_list() every inactive LRU list.
>> Based on the state of a single LRU shrink_inactive_list() may flag
>> the whole node as dirty,congested or under writeback. This is obviously
>> wrong and hurtful. It's especially hurtful when we have possibly
>> small congested cgroup in system. Than *all* direct reclaims waste time
>> by sleeping in wait_iff_congested().
> 
> I assume you have seen this in real workloads. Could you be more
> specific about how you noticed the problem?
> 

Does it matter? One of our userspace processes have some sort of watchdog.
When it doesn't receive some event in time it complains that process stuck.
In this case in-kernel allocation stuck in wait_iff_congested.


>> Sum reclaim stats across all visited LRUs on node and flag node as dirty,
>> congested or under writeback based on that sum. This only fixes the
>> problem for global reclaim case. Per-cgroup reclaim will be addressed
>> separately by the next patch.
>>
>> This change will also affect systems with no memory cgroups. Reclaimer
>> now makes decision based on reclaim stats of the both anon and file LRU
>> lists. E.g. if the file list is in congested state and get_scan_count()
>> decided to reclaim some anon pages, reclaimer will start shrinking
>> anon without delay in wait_iff_congested() like it was before. It seems
>> to be a reasonable thing to do. Why waste time sleeping, before reclaiming
>> anon given that we going to try to reclaim it anyway?
> 
> Well, if we have few anon pages in the mix then we stop throttling the
> reclaim, I am afraid. I am worried this might get us kswapd hogging CPU
> problems back.
> 

Yeah, it's not ideal choice. If only few anon pages taken than *not* throttling is bad,
and if few file pages taken and many anon than *not* throttling is probably good.

Anyway, such requires more thought,research,justification, etc.
I'll change the patch to take into account file only pages, as it was before the patch.


> [...]

>> @@ -2579,6 +2542,58 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>  		if (sc->nr_reclaimed - nr_reclaimed)
>>  			reclaimable = true;
>>  
>> +		/*
>> +		 * If reclaim is isolating dirty pages under writeback, it implies
>> +		 * that the long-lived page allocation rate is exceeding the page
>> +		 * laundering rate. Either the global limits are not being effective
>> +		 * at throttling processes due to the page distribution throughout
>> +		 * zones or there is heavy usage of a slow backing device. The
>> +		 * only option is to throttle from reclaim context which is not ideal
>> +		 * as there is no guarantee the dirtying process is throttled in the
>> +		 * same way balance_dirty_pages() manages.
>> +		 *
>> +		 * Once a node is flagged PGDAT_WRITEBACK, kswapd will count the number
>> +		 * of pages under pages flagged for immediate reclaim and stall if any
>> +		 * are encountered in the nr_immediate check below.
>> +		 */
>> +		if (stat.nr_writeback && stat.nr_writeback == stat.nr_taken)
>> +			set_bit(PGDAT_WRITEBACK, &pgdat->flags);
>> +
>> +		/*
>> +		 * Legacy memcg will stall in page writeback so avoid forcibly
>> +		 * stalling here.
>> +		 */
>> +		if (sane_reclaim(sc)) {
>> +			/*
>> +			 * Tag a node as congested if all the dirty pages scanned were
>> +			 * backed by a congested BDI and wait_iff_congested will stall.
>> +			 */
>> +			if (stat.nr_dirty && stat.nr_dirty == stat.nr_congested)
>> +				set_bit(PGDAT_CONGESTED, &pgdat->flags);
>> +
>> +			/* Allow kswapd to start writing pages during reclaim. */
>> +			if (stat.nr_unqueued_dirty == stat.nr_taken)
>> +				set_bit(PGDAT_DIRTY, &pgdat->flags);
>> +
>> +			/*
>> +			 * If kswapd scans pages marked marked for immediate
>> +			 * reclaim and under writeback (nr_immediate), it implies
>> +			 * that pages are cycling through the LRU faster than
>> +			 * they are written so also forcibly stall.
>> +			 */
>> +			if (stat.nr_immediate)
>> +				congestion_wait(BLK_RW_ASYNC, HZ/10);
>> +		}
>> +
>> +		/*
>> +		 * Stall direct reclaim for IO completions if underlying BDIs and node
>> +		 * is congested. Allow kswapd to continue until it starts encountering
>> +		 * unqueued dirty pages or cycling through the LRU too quickly.
>> +		 */
>> +		if (!sc->hibernation_mode && !current_is_kswapd() &&
>> +		    current_may_throttle())
>> +			wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
>> +
>>  	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
>>  					 sc->nr_scanned - nr_scanned, sc));
> 
> Why didn't you put the whole thing after the loop?
> 

Why this should be put after the loop? Here we already scanned all LRUs on node and
can decide in what state the node is. If should_countinue_reclaim() decides to continue,
the reclaim will be continued in accordance to the state of the node.
