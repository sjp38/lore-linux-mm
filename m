Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 066AF6B0038
	for <linux-mm@kvack.org>; Thu,  9 May 2013 17:23:57 -0400 (EDT)
Message-ID: <518C1419.40705@parallels.com>
Date: Fri, 10 May 2013 01:24:41 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 00/31] kmemcg shrinkers
References: <1368079608-5611-1-git-send-email-glommer@openvz.org> <20130509105519.GQ11497@suse.de> <20130509131823.GP24635@dastard> <20130509140311.GB11497@suse.de>
In-Reply-To: <20130509140311.GB11497@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org

On 05/09/2013 06:03 PM, Mel Gorman wrote:
> On Thu, May 09, 2013 at 11:18:23PM +1000, Dave Chinner wrote:
>>>> Mel, I have identified the overly aggressive behavior you noticed to be a bug
>>>> in the at-least-one-pass patch, that would ask the shrinkers to scan the full
>>>> batch even when total_scan < batch. They would do their best for it, and
>>>> eventually succeed. I also went further, and made that the behavior of direct
>>>> reclaim only - The only case that really matter for memcg, and one in which
>>>> we could argue that we are more or less desperate for small squeezes in memory.
>>>> Thank you very much for spotting this.
>>>>
>>>
>>> I haven't seen the relevant code yet but in general I do not think it is
>>> a good idea for direct reclaim to potentially reclaim all of slabs like
>>> this. Direct reclaim does not necessarily mean the system is desperate
>>> for small amounts of memory. Lets take a few examples where it would be
>>> a poor decision to reclaim all the slab pages within direct reclaim.
>>>
>>> 1. Direct reclaim triggers because kswapd is stalled writing pages for
>>>    memcg (see code near comment "memcg doesn't have any dirty pages
>>>    throttling"). A memcg dirtying its limit of pages may cause a lot of
>>>    direct reclaim and dumping all the slab pages
>>>
>>> 2. Direct reclaim triggers because kswapd is writing pages out to swap.
>>>    Similar to memcg above, kswapd failing to make forward progress triggers
>>>    direct reclaim which then potentially reclaims all slab
>>>
>>> 3. Direct reclaim triggers because kswapd waits on congestion as there
>>>    are too many pages under writeback. In this case, a large amounts of
>>>    writes to slow storage like USB could result in all slab being reclaimed
>>>
>>> 4. The system has been up a long time, memory is fragmented and the page
>>>    allocator enters direct reclaim/compaction to allocate THPs. It would
>>>    be very unfortunate if allocating a THP reclaimed all the slabs
>>>
>>> All that is potentially bad and likely to make Dave put in his cranky
>>> pants. I would much prefer if direct reclaim and kswapd treated slab
>>> similarly and not ask the shrinkers to do a full scan unless the alternative
>>> is OOM kill.
>>
>> Just keep in mind that I really don't care about micro-behaviours of
>> the shrinker algorithm. What I look at is the overall cache balance
>> under steady state workloads, the response to step changes in
>> workload and what sort of overhead is seen to maintain system
>> balance under memory pressure. So unless a micro-behaviour has an
>> impact at the macro level, I just don't care one way or the other.
>>
> 
> Ok, that's fine by me because I think what you are worried about can
> happen too easily right now.  A system in a steady state of streaming
> IO can decide to reclaim excessively in direct reclaim becomes active --
> a macro level change for a steady state workload.
> 
> However, Glauber has already said he will either make a priority check in
> direct reclaim or make it memcg specific. I'm happy with either as either
> should avoid a large impact at a macro level in response to a small change
> in the workload pattern.
> 
>> But I can put on cranky panks if you want, Mel. :)
>>
> 
> Unjustified cranky pants just isn't the same :)
> 
>>>> Running postmark on the final result (at least on my 2-node box) show something
>>>> a lot saner. We are still stealing more inodes than before, but by a factor of
>>>> around 15 %. Since the correct balance is somewhat heuristic anyway - I
>>>> personally think this is acceptable. But I am waiting to hear from you on this
>>>> matter. Meanwhile, I am investigating further to try to pinpoint where exactly
>>>> this comes from. It might either be because of the new node-aware behavior, or
>>>> because of the increased calculation precision in the first patch.
>>>>
>>>
>>> I'm going to defer to Dave as to whether that increased level of slab
>>> reclaim is acceptable or not.
>>
>> Depends on how it changes the balance of the system. I won't know
>> that until I run some new tests.
>>
> 
> Thanks
> 
Ok guys

The "problem" (change of behavior, actually), lies somewhere between
those two consecutive patches:

    dcache: convert to use new lru list infrastructure
    list_lru: per-node list infrastructure

I cannot pinpoint it for sure because the results I've got for the first
one were quite weird, and we have actually stolen *a lot* *less* inodes
with this patch. I decided to re-run the test just to be sure, but I am
already back home, so I will grab the results tomorrow.

The fact that the stealing of inodes increases after the list_lru patch
seems to indicate that this is because we are now able to shrink in
parallel due to the per node lists. It is only reasonable that we will
be able to do more work, and it is consistent with expectations.

However, to confirm that, I think it would be beneficial to disable one
of the nodes in my system and then run it again (which I will have to do
tomorrow). Meanwhile, of course, other tests and validations from Dave
are welcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
