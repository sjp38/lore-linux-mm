Date: Tue, 4 Mar 2008 10:53:31 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/8] slub: Fallback to order 0 and variable order slab
 support
In-Reply-To: <20080304122008.GB19606@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0803041044520.13957@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com> <20080304122008.GB19606@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, Mel Gorman wrote:

> 				Loss	to	Gain
> Kernbench Elapsed time		 -0.64%		0.32%
> Kernbench Total time		 -0.61%		0.48%
> Hackbench sockets-12 clients	 -2.95%		5.13%
> Hackbench pipes-12 clients	-16.95%		9.27%
> TBench 4 clients		 -1.98%		8.2%
> DBench 4 clients (ext2)		 -5.9%		7.99%
> 
> So, running with the high orders is not a clear-cut win to my eyes. What
> did you test to show that it was a general win justifying a high-order by
> default? From looking through, tbench seems to be the only obvious one to
> gain but the rest, it is not clear at all. I'll try give sysbench a spin
> later to see if it is clear-cut.

Hmmm... Interesting. The tests that I did awhile ago were with max order 
3. The patch as is now has max order 4. Maybe we need to reduce the order?

Looks like this was mostly a gain except for hackbench. Which is to be 
expected since the benchmark shelves out objects from the same slab round 
robin to different cpus. The higher the number of objects in the slab the 
higher the chance of contention on the slab lock.

> However, in *all* cases, superpage allocations were less successful and in
> some cases it was severely regressed (one machine went from 81% success rate
> to 36%). Sufficient statistics are not gathered to see why this happened
> in retrospect but my suspicion would be that high-order RECLAIMABLE and
> UNMOVABLE slub allocations routinely fall back to the less fragmented
> MOVABLE pageblocks with these patches - something that is normally a very
> rare event. This change in assumption hurts fragmentation avoidance and
> chances are the long-term behaviour of these patches is not great.

Superpage allocations means huge page allocations? Enable slub statistics 
and you will be able to see the number of fallbacks in 
/sys/kernel/slab/xx/order_fallback to confirm your suspicions.

How would the allocator be able to get MOVABLE allocations? Is fallback 
permitted for order 0 allocs to MOVABLE?

> If this guess is correct, using a high-order size by default is a bad plan
> and it should only be set when it is known that the target workload benefits
> and superpage allocations are not a concern. Alternative, set high-order by
> default only for a limited number of caches that are RECLAIMABLE (or better
> yet ones we know can be directly reclaimed with the slub-defrag patches).
> 
> As it is, this is painful from a fragmentation perspective and the
> performance win is not clear-cut.

Could we reduce the max order to 3 and see what happens then?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
