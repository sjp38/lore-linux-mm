Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9DA2D6008F1
	for <linux-mm@kvack.org>; Tue, 25 May 2010 05:34:25 -0400 (EDT)
Date: Tue, 25 May 2010 19:34:10 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525093410.GH5087@laptop>
References: <20100521211452.659982351@quilx.com>
 <20100524070309.GU2516@laptop>
 <alpine.DEB.2.00.1005240852580.5045@router.home>
 <20100525020629.GA5087@laptop>
 <AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
 <20100525070734.GC5087@laptop>
 <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
 <20100525081634.GE5087@laptop>
 <AANLkTilJBY0sinB365lIZFUaMgMCZ1xyhMdXRTJTVDSV@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTilJBY0sinB365lIZFUaMgMCZ1xyhMdXRTJTVDSV@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 12:19:09PM +0300, Pekka Enberg wrote:
> Hi Nick,
> 
> On Tue, May 25, 2010 at 11:16 AM, Nick Piggin <npiggin@suse.de> wrote:
> > I don't think SLUB ever proved itself very well. The selling points
> > were some untestable handwaving about how queueing is bad and jitter
> > is bad, ignoring the fact that queues could be shortened and periodic
> > reaping disabled at runtime with SLAB style of allocator. It also
> > has relied heavily on higher order allocations which put great strain
> > on hugepage allocations and page reclaim (witness the big slowdown
> > in low memory conditions when tmpfs was using higher order allocations
> > via SLUB).
> 
> The main selling point for SLUB was NUMA. Has the situation changed?

Well one problem with SLAB was really just those alien caches. AFAIK
they were added by Christoph Lameter (maybe wrong), and I didn't ever
actually see much justification for them in the changelog. noaliencache
can be and is used on bigger machines, and SLES and RHEL kernels are
using SLAB on production NUMA systems up to thousands of CPU Altixes,
and have been looking at working on SGI's UV, and hundreds of cores
POWER7 etc.

I have not seen NUMA benchmarks showing SLUB is significantly better.
I haven't done much testing myself, mind you. But from indications, we
could probably quite easily drop the alien caches setup and do like a
simpler single remote freeing queue per CPU or something like that.


> Reliance on higher order allocations isn't that relevant if we're
> anyway discussing ways to change allocation strategy.

Then it's just going through more churn and adding untested code to
get where SLAB already is (top performance without higher order
allocations). So it is very relevant if we're considering how to get
to a single allocator.

 
> On Tue, May 25, 2010 at 11:16 AM, Nick Piggin <npiggin@suse.de> wrote:
> > SLUB has not been able to displace SLAB for a long timedue to
> > performance and higher order allocation problems.
> >
> > I think "clean code" is very important, but by far the hardest thing to
> > get right by far is the actual allocation and freeing strategies. So
> > it's crazy to base such a choice on code cleanliness. If that's the
> > deciding factor, then I can provide a patch to modernise SLAB and then
> > we can remove SLUB and start incremental improvements from there.
> 
> I'm more than happy to take in patches to clean up SLAB but I think
> you're underestimating the required effort. What SLUB has going for
> it:
> 
>   - No NUMA alien caches
>   - No special lockdep handling required
>   - Debugging support is better
>   - Cpuset interractions are simpler
>   - Memory hotplug is more mature

All this I don't think is much problem. It was only a problem because we
put in SLUB and so half these new features were added to it and people
weren't adding them to SLAB.


>   - Much more contributors to SLUB than to SLAB

In large part because it is less mature. But also because it seems to be
seen as the allocator of the future.

Problem is that SLUB was never able to prove why it should be merged.
The code cleanliness issue is really trivial in comparison to how much
head scratching and work goes into analysing the performance.

It *really* is not required to completely replace a whole subsystem like
this to make progress. Even if we make relatively large changes,
everyone gets to use and test them, and it's so easy to bisect and
work out how changes interact and change behaviour. Compare that with
the problems we have when someone says that SLUB has a performance
regression against SLAB.


> I was one of the people cleaning up SLAB when SLUB was merged and
> based on that experience I'm strongly in favor of SLUB as a base.

I think we should: modernise SLAB code, add missing debug features,
possibly turn off alien caches by default, chuck out SLUB, and then
require that future changes have some reasonable bar set to justify
them.

I would not be at all against adding changes that transform SLAB to
SLUB or SLEB or SLQB. That's how it really should be done in the
first place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
