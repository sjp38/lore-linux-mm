Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 3208D6B003B
	for <linux-mm@kvack.org>; Thu,  9 May 2013 09:18:29 -0400 (EDT)
Date: Thu, 9 May 2013 23:18:23 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 00/31] kmemcg shrinkers
Message-ID: <20130509131823.GP24635@dastard>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
 <20130509105519.GQ11497@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130509105519.GQ11497@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org

On Thu, May 09, 2013 at 11:55:23AM +0100, Mel Gorman wrote:
> On Thu, May 09, 2013 at 10:06:17AM +0400, Glauber Costa wrote:
> > [ Sending again, forgot to CC fsdevel. Shame on me ]
> > To Mel
> > ======
> > 
> 
> I'm surprised Dave Chinner is not on the cc. He may or may not see it
> on fsdevel.

I asked Glauber to send it to -fsdevel earlier today rather than
scattergun CC my RH email address with various patches in the
series. I'll be looking at this a bit more tomorrow now that I have
some new perf baselines I can use for comparison.

> > Mel, I have identified the overly aggressive behavior you noticed to be a bug
> > in the at-least-one-pass patch, that would ask the shrinkers to scan the full
> > batch even when total_scan < batch. They would do their best for it, and
> > eventually succeed. I also went further, and made that the behavior of direct
> > reclaim only - The only case that really matter for memcg, and one in which
> > we could argue that we are more or less desperate for small squeezes in memory.
> > Thank you very much for spotting this.
> > 
> 
> I haven't seen the relevant code yet but in general I do not think it is
> a good idea for direct reclaim to potentially reclaim all of slabs like
> this. Direct reclaim does not necessarily mean the system is desperate
> for small amounts of memory. Lets take a few examples where it would be
> a poor decision to reclaim all the slab pages within direct reclaim.
> 
> 1. Direct reclaim triggers because kswapd is stalled writing pages for
>    memcg (see code near comment "memcg doesn't have any dirty pages
>    throttling"). A memcg dirtying its limit of pages may cause a lot of
>    direct reclaim and dumping all the slab pages
> 
> 2. Direct reclaim triggers because kswapd is writing pages out to swap.
>    Similar to memcg above, kswapd failing to make forward progress triggers
>    direct reclaim which then potentially reclaims all slab
> 
> 3. Direct reclaim triggers because kswapd waits on congestion as there
>    are too many pages under writeback. In this case, a large amounts of
>    writes to slow storage like USB could result in all slab being reclaimed
> 
> 4. The system has been up a long time, memory is fragmented and the page
>    allocator enters direct reclaim/compaction to allocate THPs. It would
>    be very unfortunate if allocating a THP reclaimed all the slabs
> 
> All that is potentially bad and likely to make Dave put in his cranky
> pants. I would much prefer if direct reclaim and kswapd treated slab
> similarly and not ask the shrinkers to do a full scan unless the alternative
> is OOM kill.

Just keep in mind that I really don't care about micro-behaviours of
the shrinker algorithm. What I look at is the overall cache balance
under steady state workloads, the response to step changes in
workload and what sort of overhead is seen to maintain system
balance under memory pressure. So unless a micro-behaviour has an
impact at the macro level, I just don't care one way or the other.

But I can put on cranky panks if you want, Mel. :)

> > Running postmark on the final result (at least on my 2-node box) show something
> > a lot saner. We are still stealing more inodes than before, but by a factor of
> > around 15 %. Since the correct balance is somewhat heuristic anyway - I
> > personally think this is acceptable. But I am waiting to hear from you on this
> > matter. Meanwhile, I am investigating further to try to pinpoint where exactly
> > this comes from. It might either be because of the new node-aware behavior, or
> > because of the increased calculation precision in the first patch.
> > 
> 
> I'm going to defer to Dave as to whether that increased level of slab
> reclaim is acceptable or not.

Depends on how it changes the balance of the system. I won't know
that until I run some new tests.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
