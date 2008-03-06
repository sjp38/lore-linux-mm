Date: Thu, 6 Mar 2008 14:18:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/8] slub: Fallback to order 0 and variable order slab
 support
In-Reply-To: <20080306220402.GC20085@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0803061409150.15083@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com> <20080304122008.GB19606@csn.ul.ie>
 <Pine.LNX.4.64.0803041044520.13957@schroedinger.engr.sgi.com>
 <20080305182834.GA10678@csn.ul.ie> <Pine.LNX.4.64.0803051051190.29794@schroedinger.engr.sgi.com>
 <20080306220402.GC20085@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Mar 2008, Mel Gorman wrote:

> For huge page allocation success rates, the high order never helper the
> situation but it was nowhere near as severe as it was for the slub-defrag
> patches (ironically enough). Only one machine showed significantly worse

Well the slub-defrag tree is not really in shape for testing at this 
point and I was working on it the last week. So not sure what tree was 
picked up and thus not sure what to deduce from it. It may be too 
aggressive in defragmentation attempts.

> results. The rest were comparable for this set of tests at least but I would
> still be wary of the long-lived behaviour of high-order slab allocations
> slowly fragmenting memory due to pageblock fallbacks. Will think of how to
> prove that in some way but just re-running the tests multiple times
> without reboot may be enough.

Well maybe we could tune the page allocator a bit? There is the order 0 
issue. We could also make all slab allocations use the same slab order in 
order to reduce fragmentation problems.
 
> Setting the order to 3 had vaguely similar results. The two outlier
> machines had even worse negatives than order-4. With those machines
> omitted the results were

Wonder what made them go worse.

> Same story, hackbench-pipes and dbench suffer badly on some machines.
> It's a similar story for order-1. With machine omitted it's
> 
> Kernbench Elapsed    time      -0.14      to 0.24
> Kernbench Total  CPU           -0.13      to 0.11
> Hackbench pipes-1              -11.90     to 5.39
> Hackbench pipes-4              -7.01      to 2.06
> Hackbench pipes-8              -5.49      to 1.66
> Hackbench pipes-16             -6.08      to 2.72
> Hackbench sockets-1            0.28       to 6.99
> Hackbench sockets-4            0.63       to 5.50
> Hackbench sockets-8            -10.95     to 7.70
> Hackbench sockets-16           0.64       to 12.16
> TBench    clients-1            -3.94      to 1.05
> TBench    clients-2            -11.96     to 3.25
> TBench    clients-4            -12.48     to -1.12
> TBench    clients-8            -11.82     to -8.56
> DBench    clients-1-ext2       -12.20     to 2.27
> DBench    clients-2-ext2       -4.23      to 0.57
> DBench    clients-4-ext2       -2.31      to 3.96
> DBench    clients-8-ext2       -3.65      to 6.09

Well in that case there is something going on very strange performance
wise. The results should be equal to upstream since the same orders 
are used. The only change in the hotpaths is another lookup which cannot 
really account for the variances we see here. An 12% improvement because 
logic was added to the hotpath? There should be a significant regression 
tbench (2%-4%) because the 4k slab cache must cause trouble.


> Based on this set of tests, it's clear that raising the order can be a big
> win but setting it as default is less clear-cut.

There is something wrong here and we need to figure out what it is. The 
order-1 test should fairly accurately reproduce upstream performance 
characteristics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
