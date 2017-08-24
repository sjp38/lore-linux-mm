Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 87F3E28042C
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 04:00:54 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p17so2421904wmd.5
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 01:00:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s136si1183063wmb.189.2017.08.24.01.00.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 01:00:52 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: Track actual nr_scanned during shrink_slab()
References: <20170815153010.e3cfc177af0b2c0dc421b84c@linux-foundation.org>
 <20170822135325.9191-1-chris@chris-wilson.co.uk>
 <20170824051153.GB13922@bgram>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <29aae2cd-85a8-f3c4-66e2-4d4f5a2732c1@suse.cz>
Date: Thu, 24 Aug 2017 10:00:49 +0200
MIME-Version: 1.0
In-Reply-To: <20170824051153.GB13922@bgram>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mel Gorman <mgorman@techsingularity.net>, Shaohua Li <shli@fb.com>

On 08/24/2017 07:11 AM, Minchan Kim wrote:
> Hello Chris,
> 
> On Tue, Aug 22, 2017 at 02:53:24PM +0100, Chris Wilson wrote:
>> Some shrinkers may only be able to free a bunch of objects at a time, and
>> so free more than the requested nr_to_scan in one pass.

Can such shrinkers reflect that in their shrinker->batch value? Or is it
unpredictable for each scan?

>> Whilst other
>> shrinkers may find themselves even unable to scan as many objects as
>> they counted, and so underreport. Account for the extra freed/scanned
>> objects against the total number of objects we intend to scan, otherwise
>> we may end up penalising the slab far more than intended. Similarly,
>> we want to add the underperforming scan to the deferred pass so that we
>> try harder and harder in future passes.
>>
>> v2: Andrew's shrinkctl->nr_scanned
>>
>> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Cc: Shaohua Li <shli@fb.com>
>> Cc: linux-mm@kvack.org
>> ---
>>  include/linux/shrinker.h | 7 +++++++
>>  mm/vmscan.c              | 7 ++++---
>>  2 files changed, 11 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
>> index 4fcacd915d45..51d189615bda 100644
>> --- a/include/linux/shrinker.h
>> +++ b/include/linux/shrinker.h
>> @@ -18,6 +18,13 @@ struct shrink_control {
>>  	 */
>>  	unsigned long nr_to_scan;
>>  
>> +	/*
>> +	 * How many objects did scan_objects process?
>> +	 * This defaults to nr_to_scan before every call, but the callee
>> +	 * should track its actual progress.
> 
> So, if shrinker scans object more than requested, it shoud add up
> top nr_scanned?

That sounds fair.

> opposite case, if shrinker scans less than requested, it should reduce
> nr_scanned to the value scanned real?

Unsure. If they can't scan more, the following attempt in the next
iteration should fail and thus result in SHRINK_STOP?

> To track the progress is burden for the shrinker users.

You mean shrinker authors, not users? AFAICS this nr_scanned is opt-in,
if they don't want to touch it, the default remains nr_to_scan.

> Even if a
> shrinker has a mistake, VM will have big trouble like infinite loop.

We could fake 0 as 1 or something, at least.

> IMHO, we need concrete reason to do it but fail to see it at this moment.
> 
> Could we just add up more freed object than requested to total_scan
> like you did in first version[1]?

That's a bit different metric, but maybe it doesn't matter. Different
shrinkers are essentially apples and oranges anyway, so improving the
arithmetics can only help to some extent, IMHO.

> [1] lkml.kernel.org/r/<20170812113437.7397-1-chris@chris-wilson.co.uk>
> 
>> +	 */
>> +	unsigned long nr_scanned;
>> +
>>  	/* current node being shrunk (for NUMA aware shrinkers) */
>>  	int nid;
>>  
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index a1af041930a6..339b8fc95fc9 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -393,14 +393,15 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>>  		unsigned long nr_to_scan = min(batch_size, total_scan);
>>  
>>  		shrinkctl->nr_to_scan = nr_to_scan;
>> +		shrinkctl->nr_scanned = nr_to_scan;
>>  		ret = shrinker->scan_objects(shrinker, shrinkctl);
>>  		if (ret == SHRINK_STOP)
>>  			break;
>>  		freed += ret;
>>  
>> -		count_vm_events(SLABS_SCANNED, nr_to_scan);
>> -		total_scan -= nr_to_scan;
>> -		scanned += nr_to_scan;
>> +		count_vm_events(SLABS_SCANNED, shrinkctl->nr_scanned);
>> +		total_scan -= shrinkctl->nr_scanned;
>> +		scanned += shrinkctl->nr_scanned;
> 
> If we really want to go this way, at least, We need some defense code
> to prevent infinite loop when shrinker doesn't have object any more.
> However, I really want to go with your first version.
> 
> Andrew?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
