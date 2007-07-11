Date: Wed, 11 Jul 2007 11:05:41 +0100
Subject: Re: -mm merge plans -- anti-fragmentation
Message-ID: <20070711100540.GF7568@skynet.ie>
References: <20070710102043.GA20303@skynet.ie> <200707100929.46153.dave.mccracken@oracle.com> <20070710152355.GI8779@wotan.suse.de> <Pine.LNX.4.64.0707101148161.11906@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707101148161.11906@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Dave McCracken <dave.mccracken@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (10/07/07 11:50), Christoph Lameter didst pronounce:
> On Tue, 10 Jul 2007, Nick Piggin wrote:
> 
> > > The sheer list of patches lined up behind this set is strong evidence that 
> > > there are useful features which depend on a working order>0.  When you add in 
> > > the existing code that has to struggle with allocation failures or resort to 
> > > special pools (ie hugetlbfs), I see a clear vote for the need for this patch.
> > 
> > Really the only patches so far that I think have convincing reasons are
> > memory unplug and hugepage, and both of those can get a long way by using
> > a reserve zone (note it isn't entirely reserved, but still available for
> > things like pagecache). Beyond that, is there a big demand, and do we
> > want to make this fundamental change in direction in the kernel to
> > satisfy that demand?
> 
> SLUB can use it to use large order pages which generate less lock 
> contention which is important in SMP systems. Large pages also increase 
> the object density in slabs.
> 

And this should be a measurable benefit at least.

> > So small ones like order-1 and 2 seem reasonably good right now AFAIKS.
> 
> Sorry no. Without the antifrag patches I had failures even with order 1 
> and 2 allocs from SLUB.
> 

Which doesn't really suprise me. Order-1 and order-2 allocation succeed
today because there are so few users of them. Order-1 is sometimes used
for stacks and the occasional wireless driver instead of on a regular
basis.

We still need to revisit the watermark handling before pushing this
aspect of SLUB forward but I'd like to see grouping pages by mobility go
forward first so the work is not pie-in-the-sky. I'm sure it can be
handled better than what we do in -mm today but it's good to know we
have a comparison point. The first stab at watermark handling may not be
the best approach but it's held up pretty well so far.

> > If you perhaps want to say start using order-4  pages for slab or
> > some other kernel memory allocations, then you can run into the situation
> > where memory gets fragmented such that you have one sixteenth of your
> > memory actualy used but you can't allocate from any of your slabs because
> > there are no order-4 pages left. I guess this is a big difference between
> > order-low failures and order-high.
> 
> The order that is readily reclaimable should be configurable.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
