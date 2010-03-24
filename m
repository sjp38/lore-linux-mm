Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 336B86B01E9
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 10:50:52 -0400 (EDT)
Date: Wed, 24 Mar 2010 14:50:29 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
	pressure
Message-ID: <20100324145028.GD2024@csn.ul.ie>
References: <20100322235053.GD9590@csn.ul.ie> <4BA940E7.2030308@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4BA940E7.2030308@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 23, 2010 at 06:29:59PM -0400, Rik van Riel wrote:
> On 03/22/2010 07:50 PM, Mel Gorman wrote:
>
>> Test scenario
>> =============
>> X86-64 machine 1 socket 4 cores
>> 4 consumer-grade disks connected as RAID-0 - software raid. RAID controller
>> 	on-board and a piece of crap, and a decent RAID card could blow
>> 	the budget.
>> Booted mem=256 to ensure it is fully IO-bound and match closer to what
>> 	Christian was doing
>
> With that many disks, you can easily have dozens of megabytes
> of data in flight to the disk at once.  That is a major
> fraction of memory.
>

That is easily possible. Note, I'm not maintaining this workload configuration
is a good idea.

The background to this problem is Christian running a disk-intensive iozone
workload over many CPUs and disks with limited memory. It's already known
that if he added a small amount of extra memory, the problem went away.
The problem was a massive throughput regression and a bisect pinpointed
two patches (both mine) but neither make sense. One altered the order pages
come back from lists but not availability and his hardware does no automatic
merging. A second does alter the availility of pages via the per-cpu lists
but reverting the behaviour didn't help.

The first fix to this was to replace congestion_wait with a waitqueue
that woke up processes if the watermarks were met. This fixed
Christian's problem but Andrew wants to pin the underlying cause.

I strongly suspect that evict-once behaves sensibly when memory is ample
but in this particular case, it's not helping.

> In fact, you might have all of the inactive file pages under
> IO...
>

Possibly. The tests have a write and a read phase but I wasn't
collecting the data with sufficient granularity to see which of the
tests are actually stalling.

>> 3. Page reclaim evict-once logic from 56e49d21 hurts really badly
>> 	fix title: revertevict
>> 	fixed in mainline? no
>> 	affects: 2.6.31 to now
>>
>> 	For reasons that are not immediately obvious, the evict-once patches
>> 	*really* hurt the time spent on congestion and the number of pages
>> 	reclaimed. Rik, I'm afaid I'm punting this to you for explanation
>> 	because clearly you tested this for AIM7 and might have some
>> 	theories. For the purposes of testing, I just reverted the changes.
>
> The patch helped IO tests with reasonable amounts of memory
> available, because the VM can cache frequently used data
> much more effectively.
>
> This comes at the cost of caching less recently accessed
> use-once data, which should not be an issue since the data
> is only used once...
>

Indeed. With or without evict-once, I'd have an expectation of all the
pages being recycled anyway because of the amount of data involved.

>> Rik, any theory on evict-once?
>
> No real theories yet, just the observation that your revert
> appears to be buggy (see below) and the possibility that your
> test may have all of the inactive file pages under IO...
>

Bah. I had the initial revert right and screwed up reverting from
2.6.32.10 on. I'm rerunning the tests. Is this right?

-       if (is_active_lru(lru)) {
-               if (inactive_list_is_low(zone, sc, file))
-                   shrink_active_list(nr_to_scan, zone, sc, priority, file);
+       if (is_active_lru(lru)) {
+               shrink_active_list(nr_to_scan, zone, sc, priority, file);
                return 0;


> Can you reproduce the stall if you lower the dirty limits?
>

I'm rerunning the revertevict patches at the moment. When they complete,
I'll experiment with dirty limits. Any suggested values or will I just
increase it by some arbitrary amount and see what falls out? e.g.
increse dirty_ratio to 80.

>>   static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>>   	struct zone *zone, struct scan_control *sc, int priority)
>>   {
>>   	int file = is_file_lru(lru);
>>
>> -	if (is_active_lru(lru)) {
>> -		if (inactive_list_is_low(zone, sc, file))
>> -		    shrink_active_list(nr_to_scan, zone, sc, priority, file);
>> +	if (lru == LRU_ACTIVE_FILE) {
>> +		shrink_active_list(nr_to_scan, zone, sc, priority, file);
>>   		return 0;
>>   	}
>
> Your revert is buggy.  With this change, anonymous pages will
> never get deactivated via shrink_list.
>

/me slaps self

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
