Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 050936B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 08:49:58 -0500 (EST)
Date: Thu, 5 Feb 2009 13:49:56 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] SLQB slab allocator (try 2)
Message-ID: <20090205134956.GC12132@csn.ul.ie>
References: <20090123154653.GA14517@wotan.suse.de> <200902041748.41801.nickpiggin@yahoo.com.au> <20090204152709.GA4799@csn.ul.ie> <200902051459.30064.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200902051459.30064.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 05, 2009 at 02:59:29PM +1100, Nick Piggin wrote:
> On Thursday 05 February 2009 02:27:10 Mel Gorman wrote:
> > On Wed, Feb 04, 2009 at 05:48:40PM +1100, Nick Piggin wrote:
> 
> > > It couldn't hurt, but it's usually tricky to read anything out of these
> > > from CPU cycle profiles. Especially if they are due to cache or tlb
> > > effects (which tend to just get spread out all over the profile).
> >
> > Indeed. To date, I've used them for comparing relative counts of things
> > like TLB and cache misses on the basis "relatively more misses running test
> > X is bad" or working out things like tlb-misses-per-instructions but it's a
> > bit vague. We might notice if one of the allocators is being particularly
> > cache unfriendly due to a spike in cache misses.
> 
> Very true. Total counts of TLB and cache misses could show some insight.
> 

Agreed. I'm collecting just cache misses in this run. Due to limitations
on the ppc970 PMU, I can't collect TLB and cache at the same time. I
can't remember if it can or not on the x86-64 but I went with the lowest
common denominator in any case.

> 
> > PPC64 Test Machine
> > Sysbench-Postgres
> > -----------------
> > Client           slab  slub-default  slub-minorder            slqb
> >      1         1.0000        1.0153         1.0179          1.0051
> >      2         1.0000        1.0273         1.0181          1.0269
> >      3         1.0000        1.0299         1.0195          1.0234
> >      4         1.0000        1.0159         1.0130          1.0146
> >      5         1.0000        1.0232         1.0192          1.0264
> >      6         1.0000        1.0238         1.0142          1.0088
> >      7         1.0000        1.0240         1.0063          1.0076
> >      8         1.0000        1.0134         0.9842          1.0024
> >      9         1.0000        1.0154         1.0152          1.0077
> >     10         1.0000        1.0126         1.0018          1.0009
> >     11         1.0000        1.0100         0.9971          0.9933
> >     12         1.0000        1.0112         0.9985          0.9993
> >     13         1.0000        1.0131         1.0060          1.0035
> >     14         1.0000        1.0237         1.0074          1.0071
> >     15         1.0000        1.0098         0.9997          0.9997
> >     16         1.0000        1.0110         0.9899          0.9994
> > Geo. mean      1.0000        1.0175         1.0067          1.0078
> >
> > The order SLUB uses does not make much of a difference to SPEC CPU on
> > either test machine or sysbench on x86-64. Howeer, on the ppc64 machine,
> > the performance advantage SLUB has over SLAB appears to be eliminated if
> > high-order pages are not used. I think I might run SLUB again incase the
> > higher average performance was a co-incidence due to lucky cache layout.
> > Otherwise, Christoph can probably put together a plausible theory on this
> > result faster than I can.
> 
> It's interesting, thanks. It's a good result for SLQB I guess. 1% is fairly
> large here (if it is statistically significant),

I believe it is. I don't recall the figures deviating much for sysbench but
I have to alter the scripts to do multiple runs just in case.

> but I don't think the
> drawbacks of using higher order pages warrant changing anything by default
> in SLQB. It does encourage me to add a boot or runtime parameter, though
> (even if just for testing purposes).
> 

Based on this test-machine, it's not justified by default but as the tests are
not allocator intensive it doesn't say much. tbench (or netperf or anything
that is more slab intensive) might reveal something but it'll be Monday at
the earliest before I can find out.

> > On the TLB front, it is perfectly possible that the workloads on x86-64 are
> > not allocator or memory intensive enough to take advantage of fewer calls
> > to the page allocator or potentially reduced TLB pressure. As the kernel
> > portion of the address space already uses huge pages slab objects may have
> > to occupy a very large percentage of memory before TLB pressure became an
> > issue. The L1 TLBs on both test machines are fully associative making
> > testing reduced TLB pressure practically impossible. For bonus points, 1G
> > pages are being used on the x86-64 so I have nowhere near enough memory to
> > put that under TLB pressure.
> 
> TLB pressure... I would be interested in. I'm not exactly sold on the idea
> that higher order allocations will give a significant TLB improvement.

Currently, I suspect the machine has to be running a very long time and the
memory footprint used by SLAB has to be significant before a large enough
number of TLB entries are being used. A side-effect of anti-fragmentation
is that kernel allocations get grouped into hugepages as much as possible
without using high-order pages. This makes it even harder to cause TLB
pressure within the kernel (a good thing in general).

> Although for benchmark runs, maybe it is more likely (ie. if memory hasn't
> been too fragmented).
> 
> Suppose you have a million slab objects scattered all over memory, the fact
> you might have them clumped into 64K regions rather than 4K regions... is
> it going to be significant?

I doubt it's significant from a TLB perspective. Anti-frag will be clumping the
the 4K pages together in 2MB (on x86-64) and 16MB (on ppc64) already. It would
actually be pretty tricky to form an allocation pattern from userspace that
would force use of multiple huge pages. While it is possible thh situation
does occur, I don't think a realistic test-case can be put together that
demonstrates it.

What 64K regions will do is reduce the amount of management data needed by
slab and reduce the number of calls to the page allocator. This is likely
to be much more significant in general than TLBs.

> How many access patterns are likely to soon touch
> exactly those objects that are in the same page?
> 
> Sure it is possible to come up with a scenario where it does help. But also
> others where it will not.
> 
> OTOH, if it is a win on ppc but not x86-64, then that may point to TLB...
> 

I'm not sure what it is, but I'm not convinced right now that TLB could make
a 1% difference. Maybe the cache miss figures will show something up and
if not, and there is nothign obvious in the profiles, I'll rerun with
TLB profiling and see what pops up.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
