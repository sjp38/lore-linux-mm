Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8FA6B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 08:22:52 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate3.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o3JCMgYN018789
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 12:22:42 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3JCMf7v1368302
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 13:22:41 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o3JCMfSP012101
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 13:22:41 +0100
Message-ID: <4BCC4B0C.8000602@linux.vnet.ibm.com>
Date: Mon, 19 Apr 2010 14:22:36 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone pressure
References: <20100322235053.GD9590@csn.ul.ie> <4BA940E7.2030308@redhat.com> <20100324145028.GD2024@csn.ul.ie>
In-Reply-To: <20100324145028.GD2024@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Sorry for replying that late, but after digging through another pile of tasks I'm happy to come back to this issue and I'll try to answer all open questions.
Fortunately I'm also able to add a few new insights that might resurrect this discussion^^

For the requested CFQ scheduler tuning, its deadline what is here :-)
So I can't apply all that. But in the past I was already able to show that all the "slowdown" occurs above the block device layer (read back through our threads if interessted about details). But eventually that leaves all lower layer tuning out of the critical zone.

Corrado also asked for iostat data, due to the reason explained above (issue above BDL) it doesn't contain anything much useful as expected.
So I'll just add a one liner of good/bad case to show that things like req-sz etc are the same, but just slower.
This "being slower" is caused by the request arriving in the BDL at a lower rate - caused by our beloved full timeouts in congestion_wait.

Device:         rrqm/s   wrqm/s     r/s     w/s     rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
bad sdb         0.00     0.00    154.50    0.00  70144.00     0.00   908.01     0.62    4.05   2.72  42.00
good sdb        0.00     0.00    270.50    0.00 122624.00     0.00   906.65     1.32    4.94   2.92  79.00


So now coming to the probably most critical part - the evict once discussion in this thread.
I'll try to explain what I found in the meanwhile - let me know whats unclear and I'll add data etc.

In the past we identified that "echo 3 > /proc/sys/vm/drop_caches" helps to improve the accuracy of the used testcase by lowering the noise from 5-8% to <1%.
Therefore I ran all tests and verifications with that drops.
In the meanwhile I unfortunately discovered that Mel's fix only helps for the cases when the caches are dropped.
Without it seems to be bad all the time. So don't cast the patch away due to that discovery :-)

On the good side I was also able to analyze a few more things due to that insight - and it might give us new data to debug the root cause.
Like Mel I also had identified "56e49d21 vmscan: evict use-once pages first" to be related in the past. But without the watermark wait fix, unapplying it 56e49d21 didn't change much for my case so I left this analysis path.

But now after I found dropping caches is the key to "get back good performance" and "subsequent writes for bad performance" even with watermark wait applied I checked what else changes:
- first write/read load after reboot or dropping caches -> read TP good
- second write/read load after reboot or dropping caches -> read TP bad
=> so what changed.

I went through all kind of logs and found something in the system activity report which very probably is related to 56e49d21.
When issuing subsequent writes after I dropped caches to get a clean start I get this in Buffers/Caches from Meminfo:

pre write 1
Buffers:             484 kB
Cached:             5664 kB
pre write 2
Buffers:           33500 kB
Cached:           149856 kB
pre write 3
Buffers:           65564 kB
Cached:           115888 kB
pre write 4
Buffers:           85556 kB
Cached:            97184 kB

It stays at ~85M with more writes which is approx 50% of my free 160M memory.
It can be said that once Buffers reached the 65M level all (no matter how much read load I throw at the system) following read loads will have the bad throughput.
Dropping caches - and by that removing these buffers - gives back the good performance.

So far I found no alternative to a manual drop_caches, but recommending a 30 second cron job dropping caches to get good read performance for customers is not that good anyway.
I checked if the buffers get cleaned some when, but neither a lot of subsequent read loads pushing the pressure towards read page cache (I hoped the buffers would age or something to eventually get thrown out) nor waiting a long time helped.
The system seems to be totally unable to get rid of these buffers without my manual help via drop_caches.

I imagine a huge customer DB running wirtes&reads fine at day, with a nightly large backup that losses 50% read throughput because the kernel keeps 50% buffers all the night - and by that doesn't fit in their night slot - just to draw one realistic scenario.
Is there anything to avoid that behavior to "never free these buffers", but still get all/some of the intended benefits of 56e49d21?

Ideas welcome

P.S. This is still a .32 stable kernel + Mels watermark wait patch based analysis - I plan to check current kernels as well once I find the time, but let me know if there are known obvious fixes related to this issue I should test asap. 

Mel Gorman wrote:
> On Tue, Mar 23, 2010 at 06:29:59PM -0400, Rik van Riel wrote:
>> On 03/22/2010 07:50 PM, Mel Gorman wrote:
>>
>>> Test scenario
>>> =============
>>> X86-64 machine 1 socket 4 cores
>>> 4 consumer-grade disks connected as RAID-0 - software raid. RAID controller
>>> 	on-board and a piece of crap, and a decent RAID card could blow
>>> 	the budget.
>>> Booted mem=256 to ensure it is fully IO-bound and match closer to what
>>> 	Christian was doing
>> With that many disks, you can easily have dozens of megabytes
>> of data in flight to the disk at once.  That is a major
>> fraction of memory.
>>
> 
> That is easily possible. Note, I'm not maintaining this workload configuration
> is a good idea.
> 
> The background to this problem is Christian running a disk-intensive iozone
> workload over many CPUs and disks with limited memory. It's already known
> that if he added a small amount of extra memory, the problem went away.
> The problem was a massive throughput regression and a bisect pinpointed
> two patches (both mine) but neither make sense. One altered the order pages
> come back from lists but not availability and his hardware does no automatic
> merging. A second does alter the availility of pages via the per-cpu lists
> but reverting the behaviour didn't help.
> 
> The first fix to this was to replace congestion_wait with a waitqueue
> that woke up processes if the watermarks were met. This fixed
> Christian's problem but Andrew wants to pin the underlying cause.
> 
> I strongly suspect that evict-once behaves sensibly when memory is ample
> but in this particular case, it's not helping.
> 
>> In fact, you might have all of the inactive file pages under
>> IO...
>>
> 
> Possibly. The tests have a write and a read phase but I wasn't
> collecting the data with sufficient granularity to see which of the
> tests are actually stalling.
> 
>>> 3. Page reclaim evict-once logic from 56e49d21 hurts really badly
>>> 	fix title: revertevict
>>> 	fixed in mainline? no
>>> 	affects: 2.6.31 to now
>>>
>>> 	For reasons that are not immediately obvious, the evict-once patches
>>> 	*really* hurt the time spent on congestion and the number of pages
>>> 	reclaimed. Rik, I'm afaid I'm punting this to you for explanation
>>> 	because clearly you tested this for AIM7 and might have some
>>> 	theories. For the purposes of testing, I just reverted the changes.
>> The patch helped IO tests with reasonable amounts of memory
>> available, because the VM can cache frequently used data
>> much more effectively.
>>
>> This comes at the cost of caching less recently accessed
>> use-once data, which should not be an issue since the data
>> is only used once...
>>
> 
> Indeed. With or without evict-once, I'd have an expectation of all the
> pages being recycled anyway because of the amount of data involved.
> 
>>> Rik, any theory on evict-once?
>> No real theories yet, just the observation that your revert
>> appears to be buggy (see below) and the possibility that your
>> test may have all of the inactive file pages under IO...
>>
> 
> Bah. I had the initial revert right and screwed up reverting from
> 2.6.32.10 on. I'm rerunning the tests. Is this right?
> 
> -       if (is_active_lru(lru)) {
> -               if (inactive_list_is_low(zone, sc, file))
> -                   shrink_active_list(nr_to_scan, zone, sc, priority, file);
> +       if (is_active_lru(lru)) {
> +               shrink_active_list(nr_to_scan, zone, sc, priority, file);
>                 return 0;
> 
> 
>> Can you reproduce the stall if you lower the dirty limits?
>>
> 
> I'm rerunning the revertevict patches at the moment. When they complete,
> I'll experiment with dirty limits. Any suggested values or will I just
> increase it by some arbitrary amount and see what falls out? e.g.
> increse dirty_ratio to 80.
> 
>>>   static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>>>   	struct zone *zone, struct scan_control *sc, int priority)
>>>   {
>>>   	int file = is_file_lru(lru);
>>>
>>> -	if (is_active_lru(lru)) {
>>> -		if (inactive_list_is_low(zone, sc, file))
>>> -		    shrink_active_list(nr_to_scan, zone, sc, priority, file);
>>> +	if (lru == LRU_ACTIVE_FILE) {
>>> +		shrink_active_list(nr_to_scan, zone, sc, priority, file);
>>>   		return 0;
>>>   	}
>> Your revert is buggy.  With this change, anonymous pages will
>> never get deactivated via shrink_list.
>>
> 
> /me slaps self
> 

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
