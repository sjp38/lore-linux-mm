Message-ID: <463AE1EB.1020909@yahoo.com.au>
Date: Fri, 04 May 2007 17:34:03 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070503155407.GA7536@elte.hu>
In-Reply-To: <20070503155407.GA7536@elte.hu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Con Kolivas <kernel@kolivas.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> 
>>- If replying, please be sure to cc the appropriate individuals.  
>>  Please also consider rewriting the Subject: to something 
>>  appropriate.
> 
> 
> i'm wondering about swap-prefetch:

Well I had some issues with it that I don't think were fully discussed,
and Andrew prompted me to say something, but it went off list for a
couple of posts (my fault, sorry). Posting it below with Andrew's
permission...


>   mm-implement-swap-prefetching.patch
>   swap-prefetch-avoid-repeating-entry.patch
>   add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated-swap-prefetch.patch
> 
> The swap-prefetch feature is relatively compact:
> 
>    10 files changed, 745 insertions(+), 1 deletion(-)
> 
> it is contained mostly to itself:
> 
>    mm/swap_prefetch.c            |  581 ++++++++++++++++++++++++++++++++
> 
> i've reviewed it once again and in the !CONFIG_SWAP_PREFETCH case it's a 
> clear NOP, while in the CONFIG_SWAP_PREFETCH=y case all the feedback 
> i've seen so far was positive. Time to have this upstream and time for a 
> desktop-oriented distro to pick it up.
> 
> I think this has been held back way too long. It's .config selectable 
> and it is as ready for integration as it ever is going to be. So it's a 
> win/win scenario.

Being able to config all these core heuristics changes is really not that
much of a positive. The fact that we might _need_ to config something out,
and double the configuration range isn't too pleasing.

Here were some of my concerns, and where our discussion got up to.

Andrew Morton wrote:
 > On Fri, 04 May 2007 14:34:45 +1000 Nick Piggin <nickpiggin@yahoo.com.au> wrote:
 >
 >
 >>Andrew Morton wrote:
 >>
 >>>istr you had issues with swap-prefetch?
 >>>
 >>>If so, now's a good time to reiterate them ;)
 >>
 >>1) It is said to help with the updatedb overnight problem, however it
 >>    actually _doesn't_ prefetch swap when there are low free pages, which
 >>    is how updatedb will leave the system. So this really puzzles me how
 >>    it would work. However if updatedb is causing excessive swapout, I
 >>    think we should try improving use-once algorithms first, for example.
 >
 >
 > Yes.  Perhaps it just doesn't help with the updatedb thing.  Or maybe with
 > normal system activity we get enough free pages to kick the thing off and
 > running.  Perhaps updatedb itself has a lot of rss, for example.

Could be, but I don't know. I'd think it unlikely to allow _much_ swapin,
if huge amounts of the desktop have been swapped out. But maybe... as I
said, nobody seems to have a recipe for these things.


 > Would be useful to see this claim substantiated with a real testcase,
 > description of results and an explanation of how and why it worked.

Yes... and then try to first improve regular page reclaim and use-once
handling.


 >>2) It is a _highly_ speculative operation, and in workloads where periods
 >>    of low and high page usage with genuinely unused anonymous / tmpfs
 >>    pages, it could waste power, memory bandwidth, bus bandwidth, disk
 >>    bandwidth...
 >
 >
 > Yes.  I suspect that's a matter of waiting for the corner-case reporters to
 > complain, then add more heuristics.

Ugh. Well it is a pretty fundamental problem. Basically swap-prefetch is
happy to do a _lot_ of work for these things which we have already decided
are least likely to be used again.


 >>3) I haven't seen a single set of numbers out of it. Feedback seems to
 >>    have mostly come from people who
 >
 >
 > Yup.  But can we come up with a testcase?  It's hard.

I guess it is hard firstly because swapping is quite random to start with.
But I haven't even seen basic things like "make -jhuge swapstorm has no
regressions".


 >>4) If this is helpful, wouldn't it be equally important for things like
 >>    mapped file pages? Seems like half a solution.
 >
 >
 > True.
 >
 > Without thinking about it, I almost wonder if one could do a userspace
 > implementation with something which pokes around in /proc/pid/pagemap and
 > /proc/pid/kpagemap, perhaps with some additional interfaces added to
 > do a swapcache read.  (Give userspace the ability to get at swapcache
 > via a regular fd?)
 >
 > (otoh the akpm usersapce implementation is swapoff -a;swapon -a)

Perhaps. You may need a few indicators to see whether the system is idle...
but OTOH, we've already got a lot of indicators for memory, disk usage,
etc. So, maybe :)


 >>5) New one: it is possibly going to interact badly with MADV_FREE lazy
 >>    freeing. The more complex we make page reclaim, the worse IMO.
 >
 >
 > That's a bit vague.  What sort of problems do you envisage?

Well MADV_FREE pages aren't technically free, are they? So it might be
possible for a significant number of them to build up and prevent
swap prefetch from working. Maybe.


 >>...) I had a few issues with implementation, like interaction with
 >>    cpusets. Don't know if these are all fixed or not. I sort of gave
 >>    up looking at it.
 >
 >
 > Ah yes, I remember some mention of cpusets.  I forget what it was though.

I could be wrong, but IIRC there is no good way to know which cpuset to
bring the page back into, (and I guess similarly it would be hard to know
what container to account it to, if doing account-on-allocate).

We could hope that users of these features would be mostly disjoint sets,
but that's an evil road to start heading down, where we have various core
bits of mm that don't play nice together.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
