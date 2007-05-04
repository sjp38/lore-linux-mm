Date: Fri, 4 May 2007 10:52:01 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
Message-ID: <20070504085201.GA24666@elte.hu>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070503155407.GA7536@elte.hu> <463AE1EB.1020909@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <463AE1EB.1020909@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Con Kolivas <kernel@kolivas.org>
List-ID: <linux-mm.kvack.org>

* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > i'm wondering about swap-prefetch:

> Being able to config all these core heuristics changes is really not 
> that much of a positive. The fact that we might _need_ to config 
> something out, and double the configuration range isn't too pleasing.

Well, to the desktop user this is a speculative performance feature that 
he is willing to potentially waste CPU and IO capacity, in expectation 
of better performance.

On the conceptual level it is _precisely the same thing as regular file 
readahead_. (with the difference that to me swapahead seems to be quite 
a bit more intelligent than our current file readahead logic.)

This feature has no API or ABI impact at all, it's a pure performance 
feature. (besides the trivial sysctl to turn it runtime on/off).

> Here were some of my concerns, and where our discussion got up to.

> > Yes.  Perhaps it just doesn't help with the updatedb thing.  Or 
> > maybe with normal system activity we get enough free pages to kick 
> > the thing off and running.  Perhaps updatedb itself has a lot of 
> > rss, for example.
> 
> Could be, but I don't know. I'd think it unlikely to allow _much_ 
> swapin, if huge amounts of the desktop have been swapped out. But 
> maybe... as I said, nobody seems to have a recipe for these things.

can i take this one as a "no fundamental objection"? There are really 
only 2 maintainance options left:

  1) either you can do it better or at least have a _very_ clearly
     described idea outlined about how to do it differently

  2) or you should let others try it

#1 you've not done for 2-3 years since swap-prefetch was waiting for
integration so it's not an option at this stage anymore. Then you are 
pretty much obliged to do #2. ;-)

And let me be really blunt about this, there is no option #3 to say: "I 
have no real better idea, I have no code, I have no time, but hey, lets 
not merge this because it 'could in theory' be possible to do it better" 
=B-)

really, we are likely be better off by risking the merge of _bad_ code 
(which in the swap-prefetch case is the exact opposite of the truth), 
than to let code stagnate. People are clearly unhappy about certain 
desktop aspects of swapping, and the only way out of that is to let more 
people hack that code. Merging code involves more people. It will cause 
'noise' and could cause regressions, but at least in this case the only 
impact is 'performance' and the feature is trivial to disable.

The maintainance drag outside of swap_prefetch.c is essentially _zero_. 
If the feature doesnt work it ends up on Con's desk. If it turns out to 
not work at all (despite years of testing and happy users) it still only 
ends up on Con's desk. A clear win/win scenario for you i think :-)

> > Would be useful to see this claim substantiated with a real 
> > testcase, description of results and an explanation of how and why 
> > it worked.
> 
> Yes... and then try to first improve regular page reclaim and use-once 
> handling.

agreed. Con, IIRC you wrote a testcase for this, right? Could you please 
send us the results of that testing?

> >>2) It is a _highly_ speculative operation, and in workloads where periods
> >>    of low and high page usage with genuinely unused anonymous / tmpfs
> >>    pages, it could waste power, memory bandwidth, bus bandwidth, disk
> >>    bandwidth...
> > 
> > Yes.  I suspect that's a matter of waiting for the corner-case 
> > reporters to complain, then add more heuristics.
> 
> Ugh. Well it is a pretty fundamental problem. Basically swap-prefetch 
> is happy to do a _lot_ of work for these things which we have already 
> decided are least likely to be used again.

i see no real problem here. We've had heuristics for a _long_ time in 
various areas of the code. Sometimes they work, sometimes they suck.

the flow of this is really easy: distro looking for a feature edge turns 
it on and announces it, if the feature does not work out for users then 
user turns it off and complains to distro, if enough users complain then 
distro turns it off for next release, upstream forgets about this 
performance feature and eventually removes it once someone notices that 
it wouldnt even compile in the past 2 main releases. I see no problem 
here, we did that in the past too with performance features. The 
networking stack has literally dozens of such small tunable things which 
get experimented with, and whose defaults do get tuned carefully. Some 
of the knobs help bandwidth, some help latency.

I do not even see any risk of "splitup of mindshare" - swap-prefetch is 
so clearly speculative that it's not really a different view about how 
to do swapping (which would split the tester base, etc.), it's simply a 
"do you want your system to speculate about the future or not" add-on 
decision. Every system has a pretty clear idea about that: desktops 
generally want to do it, clusters generally dont want to do it.

> >>3) I haven't seen a single set of numbers out of it. Feedback seems to
> >>    have mostly come from people who
> >
> > Yup.  But can we come up with a testcase?  It's hard.

i think Con has a testcase.

> >>4) If this is helpful, wouldn't it be equally important for things like
> >>    mapped file pages? Seems like half a solution.
[...]
> > (otoh the akpm usersapce implementation is swapoff -a;swapon -a)
> 
> Perhaps. You may need a few indicators to see whether the system is 
> idle... but OTOH, we've already got a lot of indicators for memory, 
> disk usage, etc. So, maybe :)

The time has passed for this. Let others play too. Please :-)

> I could be wrong, but IIRC there is no good way to know which cpuset 
> to bring the page back into, (and I guess similarly it would be hard 
> to know what container to account it to, if doing 
> account-on-allocate).

(i think cpusets are totally uninteresting in this context: nobody in 
their right mind is going to use swap-prefetch on a big NUMA box. Nor 
can i see any fundamental impediment to making this more cpuset-aware, 
just like other subsystems were made cpuset-aware, once the requests 
from actual users came in and people started getting interested in it.)

I think the "lack of testcase and numbers" is the only valid technical 
objection i've seen so far. Con might be able to help us with that?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
