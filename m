Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D875E6B009B
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 02:08:13 -0500 (EST)
Date: Wed, 17 Dec 2008 08:09:54 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] SLQB slab allocator
Message-ID: <20081217070954.GB26179@wotan.suse.de>
References: <20081212002518.GH8294@wotan.suse.de> <28c262360812151542g2ac032fay6c5b03d846d05a77@mail.gmail.com> <20081217064238.GA26179@wotan.suse.de> <28c262360812162301i58c9fe9l4a1ee89ca0a6a56@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28c262360812162301i58c9fe9l4a1ee89ca0a6a56@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 17, 2008 at 04:01:06PM +0900, MinChan Kim wrote:
> On Wed, Dec 17, 2008 at 3:42 PM, Nick Piggin <npiggin@suse.de> wrote:
> >> Below is average for ten time test.
> >>
> >> slab :
> >> user : 2376.484, system : 192.616 elapsed : 12:22.0
> >> slub :
> >> user : 2378.439, system : 194.989 elapsed : 12:22.4
> >> slqb :
> >> user : 2380.556, system : 194.801 elapsed : 12:23.0
> >>
> >> so, slqb is rather slow although it is a big difference.
> >> Interestingly, slqb consumes less time than slub in system.
> >
> > Thanks, interesting test. kbuild is not very slab allocator intensive,
> 
> Let me know what is popular benchmark program in slab allocator.
> I will try with it. :)

That's not to say it is a bad benchmark :) If it shows up a difference
and is a useful workload like kbuild, then it is a good benchmark.

Allocator changes tend to show up more when there is a lot of network
or disk IO happening. But it is good to see other tets too, so any
numbers you get are welcome.

 
> > so I hadn't thought of trying it. Possibly the object cacheline layout
> > of longer lived allocations changes the behaviour (increased user time
> > could indicate that).
> 
> What mean "object cacheline layout of loger lived allocations" ?

For example, different allocation schemes will alter the chances of
getting different ways (colours), or false sharing. SLUB and SLQB
for example allow as fine as 8 byte allocation granularity wheras
SLAB goes down to 32 bytes, so small objects *could* be more prone
to false sharing. I don't know for sure at this stage, just guessing ;)

The difference doesn't show up significantly on my system, so profiling
doesn't reveal anything (I guess even on your system it would be
difficult to profile because it is not a huge difference).

 
> > I've been making a few changes to that, and hopefully slqb is slightly
> > improved now (the margin is much closer, seems within the noise with
> > SLUB on my NUMA opteron now, although that's a very different system).
> >
> > The biggest bug I fixed was that the NUMA path wasn't being taken in
> > kmem_cache_free on NUMA systems (oops), but that wouldn't change your
> > result. But I did make some other changes too, eg in prefetching.
> 
> OK. I will review and test your new patch in my machine.

Thanks! Code style and comments should be improved quite a bit now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
