Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2CE26B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 04:04:54 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c143so192806wmd.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 01:04:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y22si5760935wrd.301.2017.03.01.01.04.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 01:04:53 -0800 (PST)
Subject: Re: [PATCH 3/3] mm, vmscan: Prevent kswapd sleeping prematurely due
 to mismatched classzone_idx
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215092247.15989-4-mgorman@techsingularity.net>
 <f9720ed6-f834-5b64-de0a-ea0e72bf548b@suse.cz>
 <20170223150108.sjw3mghjh3jvrbjn@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f84b532c-85f5-753e-a0aa-f5eb37995db2@suse.cz>
Date: Wed, 1 Mar 2017 10:04:52 +0100
MIME-Version: 1.0
In-Reply-To: <20170223150108.sjw3mghjh3jvrbjn@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 02/23/2017 04:01 PM, Mel Gorman wrote:
> On Mon, Feb 20, 2017 at 05:42:49PM +0100, Vlastimil Babka wrote:
>>> With this patch on top, all the latencies relative to the baseline are
>>> improved, particularly write latencies. The read latencies are still high
>>> for the number of threads but it's worth noting that this is mostly due
>>> to the IO scheduler and not directly related to reclaim. The vmstats are
>>> a bit of a mix but the relevant ones are as follows;
>>>
>>>                             4.10.0-rc7  4.10.0-rc7  4.10.0-rc7
>>>                           mmots-20170209 clear-v1r25keepawake-v1r25
>>> Swap Ins                             0           0           0
>>> Swap Outs                            0         608           0
>>> Direct pages scanned           6910672     3132699     6357298
>>> Kswapd pages scanned          57036946    82488665    56986286
>>> Kswapd pages reclaimed        55993488    63474329    55939113
>>> Direct pages reclaimed         6905990     2964843     6352115
>>
>> These stats are confusing me. The earlier description suggests that this patch
>> should cause less direct reclaim and more kswapd reclaim, but compared to
>> "clear-v1r25" it does the opposite? Was clear-v1r25 overreclaiming then? (when
>> considering direct + kswapd combined)
>>
> 
> The description is referring to the impact relative to baseline. It is
> true that relative to patch that direct reclaim is higher but there are
> a number of anomalies.
> 
> Note that kswapd is scanning very aggressively in "clear-v1" and overall
> efficiency is down to 76%. It's also not clear in the stats but in
> "clear-v1", pgskip_* is active as the wrong zone is being reclaimed for
> due to the patch "mm, vmscan: fix zone balance check in
> prepare_kswapd_sleep". It's also doing a lot of writing of file-backed
> pages from reclaim context and some swapping due to the aggressiveness
> of the scan.
> 
> While direct reclaim activity might be lower, it's due to kswapd scanning
> aggressively and trying to reclaim the world which is not the right thing
> to do.  With the patches applied, there is still direct reclaim but the fast
> bulk of them are when the workload changes phase from "creating work files"
> to starting multiple threads that allocate a lot of anonymous memory with
> a sudden spike in memory pressure that kswapd does not keep ahead of with
> multiple allocating threads.

Thanks for the explanation.

> 
>>> @@ -3328,6 +3330,22 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>>>  	return sc.order;
>>>  }
>>>  
>>> +/*
>>> + * pgdat->kswapd_classzone_idx is the highest zone index that a recent
>>> + * allocation request woke kswapd for. When kswapd has not woken recently,
>>> + * the value is MAX_NR_ZONES which is not a valid index. This compares a
>>> + * given classzone and returns it or the highest classzone index kswapd
>>> + * was recently woke for.
>>> + */
>>> +static enum zone_type kswapd_classzone_idx(pg_data_t *pgdat,
>>> +					   enum zone_type classzone_idx)
>>> +{
>>> +	if (pgdat->kswapd_classzone_idx == MAX_NR_ZONES)
>>> +		return classzone_idx;
>>> +
>>> +	return max(pgdat->kswapd_classzone_idx, classzone_idx);
>>
>> A bit paranoid comment: this should probably read pgdat->kswapd_classzone_idx to
>> a local variable with READ_ONCE(), otherwise something can set it to
>> MAX_NR_ZONES between the check and max(), and compiler can decide to reread.
>> Probably not an issue with current callers, but I'd rather future-proof it.
>>
> 
> I'm a little wary of adding READ_ONCE unless there is a definite
> problem. Even if it was an issue, I think it would be better to protect
> thse kswapd_classzone_idx and kswapd_order with a spinlock that is taken
> if an update is required or a read to fully guarantee the ordering.
> 
> The consequences as they are is that kswapd may miss reclaiming at a
> higher order or classzone than it should have although it is very
> unlikely and the update and read are made with a workqueue wake and
> scheduler wakeup which should be sufficient in terms of barriers.

OK then.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
