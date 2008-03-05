Date: Wed, 5 Mar 2008 18:28:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 0/8] slub: Fallback to order 0 and variable order slab support
Message-ID: <20080305182834.GA10678@csn.ul.ie>
References: <20080229044803.482012397@sgi.com> <20080304122008.GB19606@csn.ul.ie> <Pine.LNX.4.64.0803041044520.13957@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803041044520.13957@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (04/03/08 10:53), Christoph Lameter didst pronounce:
> On Tue, 4 Mar 2008, Mel Gorman wrote:
> 
> > 				Loss	to	Gain
> > Kernbench Elapsed time		 -0.64%		0.32%
> > Kernbench Total time		 -0.61%		0.48%
> > Hackbench sockets-12 clients	 -2.95%		5.13%
> > Hackbench pipes-12 clients	-16.95%		9.27%
> > TBench 4 clients		 -1.98%		8.2%
> > DBench 4 clients (ext2)		 -5.9%		7.99%
> > 
> > So, running with the high orders is not a clear-cut win to my eyes. What
> > did you test to show that it was a general win justifying a high-order by
> > default? From looking through, tbench seems to be the only obvious one to
> > gain but the rest, it is not clear at all. I'll try give sysbench a spin
> > later to see if it is clear-cut.
> 
> Hmmm... Interesting. The tests that I did awhile ago were with max order 
> 3. The patch as is now has max order 4. Maybe we need to reduce the order?
> 
> Looks like this was mostly a gain except for hackbench. Which is to be 
> expected since the benchmark shelves out objects from the same slab round 
> robin to different cpus. The higher the number of objects in the slab the 
> higher the chance of contention on the slab lock.
> 

Ok, I'm offically a tool. I had named patchsets wrong and tested slub-defrag
instead of slub-highorder. I didn't notice until I opened the diff file to
set the max_order. slub-highorder is being tested at the moment but it'll
be hours before it completes.

FWIW, the comments in the mail apply to slub-defrag instead. There is definite
performance alterations with the patches but that is hardly a surprise.
sysbench in some cases suffered but it wasn't clear why. For small
pages, it might regress and huge pages, not at all. So there may be a
alloc/free batch patterns that performance particularly badly.

What is a major surprise is that it hurt huge page allocations so severely
in some cases. That doesn't make a lot of sense.

> > However, in *all* cases, superpage allocations were less successful and in
> > some cases it was severely regressed (one machine went from 81% success rate
> > to 36%). Sufficient statistics are not gathered to see why this happened
> > in retrospect but my suspicion would be that high-order RECLAIMABLE and
> > UNMOVABLE slub allocations routinely fall back to the less fragmented
> > MOVABLE pageblocks with these patches - something that is normally a very
> > rare event. This change in assumption hurts fragmentation avoidance and
> > chances are the long-term behaviour of these patches is not great.
> 
> Superpage allocations means huge page allocations?

yes

> Enable slub statistics 
> and you will be able to see the number of fallbacks in 
> /sys/kernel/slab/xx/order_fallback to confirm your suspicions.
> 
> How would the allocator be able to get MOVABLE allocations? Is fallback 
> permitted for order 0 allocs to MOVABLE?
> 

Yes as the alternative may be failing allocations. It's avoided where
possible.

> > If this guess is correct, using a high-order size by default is a bad plan
> > and it should only be set when it is known that the target workload benefits
> > and superpage allocations are not a concern. Alternative, set high-order by
> > default only for a limited number of caches that are RECLAIMABLE (or better
> > yet ones we know can be directly reclaimed with the slub-defrag patches).
> > 
> > As it is, this is painful from a fragmentation perspective and the
> > performance win is not clear-cut.
> 
> Could we reduce the max order to 3 and see what happens then?
> 

When the order-4 figures come through I'll post them. If they are
unexpected, I'll run with order 3. Unconditionally, I'll check order-1
as suggested by Matt.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
