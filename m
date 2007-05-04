Message-ID: <463AF83A.9060300@yahoo.com.au>
Date: Fri, 04 May 2007 19:09:14 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070503155407.GA7536@elte.hu> <463AE1EB.1020909@yahoo.com.au> <20070504085201.GA24666@elte.hu>
In-Reply-To: <20070504085201.GA24666@elte.hu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Con Kolivas <kernel@kolivas.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Nick Piggin <nickpiggin@yahoo.com.au> wrote:

>>Here were some of my concerns, and where our discussion got up to.
> 
> 
>>>Yes.  Perhaps it just doesn't help with the updatedb thing.  Or 
>>>maybe with normal system activity we get enough free pages to kick 
>>>the thing off and running.  Perhaps updatedb itself has a lot of 
>>>rss, for example.
>>
>>Could be, but I don't know. I'd think it unlikely to allow _much_ 
>>swapin, if huge amounts of the desktop have been swapped out. But 
>>maybe... as I said, nobody seems to have a recipe for these things.
> 
> 
> can i take this one as a "no fundamental objection"? There are really 
> only 2 maintainance options left:
> 
>   1) either you can do it better or at least have a _very_ clearly
>      described idea outlined about how to do it differently
> 
>   2) or you should let others try it
> 
> #1 you've not done for 2-3 years since swap-prefetch was waiting for
> integration so it's not an option at this stage anymore. Then you are 
> pretty much obliged to do #2. ;-)

The burden is not on me to get someone else's feature merged. If it
can be shown to work well and people's concerns addressed, then anything
will get merged. The reason Linux is so good is because of what we don't
merge, figuratively speaking.

I wanted to see some basic regression tests to show that it hasn't caused
obvious problems, and some basic scenarios where it helps, so that we can
analyse them. It is really simple, but I haven't got any since first
asking.

And note that I don't think I ever explicitly "nacked" anything, just
voiced my concerns. If my concerns had been addressed, then I couldn't
have stopped anybody from merging anything.


>>>>2) It is a _highly_ speculative operation, and in workloads where periods
>>>>   of low and high page usage with genuinely unused anonymous / tmpfs
>>>>   pages, it could waste power, memory bandwidth, bus bandwidth, disk
>>>>   bandwidth...
>>>
>>>Yes.  I suspect that's a matter of waiting for the corner-case 
>>>reporters to complain, then add more heuristics.
>>
>>Ugh. Well it is a pretty fundamental problem. Basically swap-prefetch 
>>is happy to do a _lot_ of work for these things which we have already 
>>decided are least likely to be used again.
> 
> 
> i see no real problem here. We've had heuristics for a _long_ time in 
> various areas of the code. Sometimes they work, sometimes they suck.

So that's one of my issues with the code. If all you have to support a
merge is anecodal evidence, then I find it interesting that you would
easily discount something like this.


>>>>4) If this is helpful, wouldn't it be equally important for things like
>>>>   mapped file pages? Seems like half a solution.
> 
> [...]
> 
>>>(otoh the akpm usersapce implementation is swapoff -a;swapon -a)
>>
>>Perhaps. You may need a few indicators to see whether the system is 
>>idle... but OTOH, we've already got a lot of indicators for memory, 
>>disk usage, etc. So, maybe :)
> 
> 
> The time has passed for this. Let others play too. Please :-)

Play with what? Prefetching mmaped file pages as well? Sure.


>>I could be wrong, but IIRC there is no good way to know which cpuset 
>>to bring the page back into, (and I guess similarly it would be hard 
>>to know what container to account it to, if doing 
>>account-on-allocate).
> 
> 
> (i think cpusets are totally uninteresting in this context: nobody in 
> their right mind is going to use swap-prefetch on a big NUMA box. Nor 
> can i see any fundamental impediment to making this more cpuset-aware, 
> just like other subsystems were made cpuset-aware, once the requests 
> from actual users came in and people started getting interested in it.)

OK, so make it more cpuset aware. This isn't a new issue, I raised it
a long time ago. And trust me, it is a nightmare to just assume that
nobody will use cpusets on a small box for example (AFAIK the resource
control guys are looking at doing just that).

All core VM features should play nicely with each other without *really*
good reason.


> I think the "lack of testcase and numbers" is the only valid technical 
> objection i've seen so far.

Well you're entitled to your opinion too.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
