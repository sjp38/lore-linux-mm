Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 97C626B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 10:28:29 -0500 (EST)
Message-ID: <4F201F60.8080808@redhat.com>
Date: Wed, 25 Jan 2012 10:27:28 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 -mm 1/3] mm: reclaim at order 0 when compaction is
 enabled
References: <20120124131822.4dc03524@annuminas.surriel.com> <20120124132136.3b765f0c@annuminas.surriel.com> <20120125150016.GB3901@csn.ul.ie>
In-Reply-To: <20120125150016.GB3901@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On 01/25/2012 10:00 AM, Mel Gorman wrote:
> On Tue, Jan 24, 2012 at 01:21:36PM -0500, Rik van Riel wrote:
>> When built with CONFIG_COMPACTION, kswapd does not try to free
>> contiguous pages.
>
> balance_pgdat() gets its order from wakeup_kswapd(). This does not apply
> to THP because kswapd does not get woken for THP but it should be woken
> up for allocations like jumbo frames or order-1.

In the kernel I run at home, I wake up kswapd for THP
as well. This is a larger change, which Andrea asked
me to delay submitting upstream for a bit.

So far there seem to be no ill effects. I'll continue
watching for them.

> As kswapd does no memory compaction itself, this patch still makes
> sense but I found the changelog misleading.

Fair enough.  I will adjust the changelog.

>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 2880396..0398fab 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1512,6 +1512,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
>>   	unsigned long nr_writeback = 0;
>>   	isolate_mode_t reclaim_mode = ISOLATE_INACTIVE;
>>   	struct zone *zone = mz->zone;
>> +	int order = 0;
>>
>>   	while (unlikely(too_many_isolated(zone, file, sc))) {
>>   		congestion_wait(BLK_RW_ASYNC, HZ/10);
>> @@ -1522,8 +1523,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
>>   	}
>>
>>   	set_reclaim_mode(priority, sc, false);
>> -	if (sc->reclaim_mode&  RECLAIM_MODE_LUMPYRECLAIM)
>> +	if (sc->reclaim_mode&  RECLAIM_MODE_LUMPYRECLAIM) {
>>   		reclaim_mode |= ISOLATE_ACTIVE;
>> +		order = sc->order;
>> +	}
>>
>>   	lru_add_drain();
>>
>
> This is a nit-pick but I would far prefer if you did not bypass
> sc->order like this and instead changes isolate_lru_pages to do a
>
> if (!order || !(sc->reclaim_mode&  RECLAIM_MODE_LUMPYRECLAIM))
> 	continue;
>
> That would very clearly mark where LUMPYRECLAIM takes effect in
> isolate_lru_pages() and makes deleting LUMPYRECLAIM easier in the
> future.

OK, I will do things that way instead.

> The second effect of this change is a non-obvious side-effect. kswapd
> will now isolate fewer pages per cycle because it will isolate
> SWAP_CLUSTER_MAX pages instead of SWAP_CLUSTER_MAX<<order which it
> potentially does currently. This is not wrong as such and may be
> desirable to limit how much reclaim kswapd does but potentially it
> impacts success rates for compaction. As this does not apply to THP,
> it will be difficult to detect but bear in mind if we see an increase
> in high-order allocation failures after this patch is merged. I am
> not suggesting a change here but it would be nice to note in the
> changelog if there is a new version of this patch.

Good point.  I am running with THP waking up kswapd, and
things seem to behave (and compaction seems to succeed),
but we might indeed want to change balance_pgdat to free
more pages for higher order allocations.

Maybe this is the place to check (in balanced_pgdat) ?

                 /*
                  * We do this so kswapd doesn't build up large 
priorities for
                  * example when it is freeing in parallel with 
allocators. It
                  * matches the direct reclaim path behaviour in terms 
of impact
                  * on zone->*_priority.
                  */
                 if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
                         break;

>> @@ -2922,8 +2939,6 @@ out:
>>
>>   			/* If balanced, clear the congested flag */
>>   			zone_clear_flag(zone, ZONE_CONGESTED);
>> -			if (i<= *classzone_idx)
>> -				balanced += zone->present_pages;
>>   		}
>
> Why is this being deleted? It is still used by pgdat_balanced().

This is outside of the big while loop and is not used again
in the function.  This final for loop does not appear to
use the variable balanced at all, except for incrementing
it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
