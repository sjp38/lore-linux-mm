Date: Thu, 6 Mar 2008 22:04:02 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 0/8] slub: Fallback to order 0 and variable order slab support
Message-ID: <20080306220402.GC20085@csn.ul.ie>
References: <20080229044803.482012397@sgi.com> <20080304122008.GB19606@csn.ul.ie> <Pine.LNX.4.64.0803041044520.13957@schroedinger.engr.sgi.com> <20080305182834.GA10678@csn.ul.ie> <Pine.LNX.4.64.0803051051190.29794@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803051051190.29794@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (05/03/08 10:52), Christoph Lameter didst pronounce:
> On Wed, 5 Mar 2008, Mel Gorman wrote:
> 
> > Ok, I'm offically a tool. I had named patchsets wrong and tested slub-defrag
> > instead of slub-highorder. I didn't notice until I opened the diff file to
> > set the max_order. slub-highorder is being tested at the moment but it'll
> > be hours before it completes.
> 
> Tool? Never heard it before. Is that an Irish term?

Possibly. It's not very complimentary either way :)

> Do not worry. That 
> happens all the time in the computer industry. These days, I get 
> suspicious when people claim something is perfect (100% yes!).
> 

Lets try this again. The range of performance losses/gains with order 4
was

Kernbench Elapsed    time      -0.16      to 6.23
Kernbench Total  CPU           -0.14      to 0.14
Hackbench pipes-1              -5.57      to 8.03
Hackbench pipes-4              -13.16     to 6.00
Hackbench pipes-8              -14.02     to 6.13
Hackbench pipes-16             -27.02     to 1.45
Hackbench sockets-1            0.00       to 12.90
Hackbench sockets-4            3.02       to 13.68
Hackbench sockets-8            2.57       to 13.40
Hackbench sockets-16           2.55       to 14.47
TBench    clients-1            -3.96      to 3.10
TBench    clients-2            -2.46      to 4.52
TBench    clients-4            -3.65      to 5.03
TBench    clients-8            -4.73      to 5.14
DBench    clients-1-ext2       -1.82      to 8.12
DBench    clients-2-ext2       -8.10      to 6.40
DBench    clients-4-ext2       -7.96      to 3.97
DBench    clients-8-ext2       0.89       to 7.54

At first glance, hackbench-pipes seemed to be hit hardest but in reality
it was one machine that showed wildly different values (bl6-13 from
TKO). When this machine is omitted, it looks like

Hackbench pipes-1              -3.75      to 8.03
Hackbench pipes-4              -5.26      to 6.00
Hackbench pipes-8              -4.56      to 6.13
Hackbench pipes-16             -5.28      to 1.45
Hackbench sockets-1            0.20       to 12.90
Hackbench sockets-4            3.02       to 11.92
Hackbench sockets-8            2.57       to 12.86
Hackbench sockets-16           2.55       to 14.47

Still a fairly wide variance but not as negative. DBench was kindof the
same. There was a different machine that appeared to particularly
suffer. With both machines omitted we get for DBench

DBench    clients-1-ext2       -1.82      to 3.84
DBench    clients-2-ext2       0.04       to 4.07
DBench    clients-4-ext2       -0.17      to 3.97
DBench    clients-8-ext2       0.89       to 4.21

(perversely, the machine with particularly bad hackbench results had
some of the best dbench results, go figure)

For huge page allocation success rates, the high order never helper the
situation but it was nowhere near as severe as it was for the slub-defrag
patches (ironically enough). Only one machine showed significantly worse
results. The rest were comparable for this set of tests at least but I would
still be wary of the long-lived behaviour of high-order slab allocations
slowly fragmenting memory due to pageblock fallbacks. Will think of how to
prove that in some way but just re-running the tests multiple times
without reboot may be enough.

It's more or less the same observation. Going with a higher order by
default wins heavily on some machines but occasionally loses badly as
well. Based on this, it's difficult to know which is more likely. I'll
start the sysbench tests to see what happens there.

Setting the order to 3 had vaguely similar results. The two outlier
machines had even worse negatives than order-4. With those machines
omitted the results were

Kernbench Elapsed    time      -0.28      to 0.16
Kernbench Total  CPU           -0.31      to 0.07
Hackbench pipes-1              -6.55      to 5.95
Hackbench pipes-4              -4.90      to 3.30
Hackbench pipes-8              -3.63      to 0.96
Hackbench pipes-16             -4.47      to 2.06
Hackbench sockets-1            0.80       to 10.04
Hackbench sockets-4            3.20       to 10.80
Hackbench sockets-8            1.61       to 13.69
Hackbench sockets-16           3.88       to 15.45
TBench    clients-1            -3.97      to 1.44
TBench    clients-2            -3.00      to 1.61
TBench    clients-4            -1.83      to 3.26
TBench    clients-8            -0.35      to 9.80
DBench    clients-1-ext2       -0.47      to 2.99
DBench    clients-2-ext2       -1.45      to 2.25
DBench    clients-4-ext2       -0.48      to 5.09

With the two machines included, it's

Kernbench Elapsed    time      -0.28      to 7.77
Kernbench Total  CPU           -0.31      to 0.10
Hackbench pipes-1              -6.55      to 5.95
Hackbench pipes-4              -8.00      to 3.30
Hackbench pipes-8              -25.87     to 0.96
Hackbench pipes-16             -24.74     to 2.06
Hackbench sockets-1            0.80       to 10.04
Hackbench sockets-4            3.20       to 10.80
Hackbench sockets-8            1.61       to 14.17
Hackbench sockets-16           2.42       to 15.45
TBench    clients-1            -3.97      to 1.44
TBench    clients-2            -3.00      to 1.63
TBench    clients-4            -1.83      to 3.26
TBench    clients-8            -3.15      to 9.80
DBench    clients-1-ext2       -0.47      to 3.22
DBench    clients-2-ext2       -11.41     to 10.53
DBench    clients-4-ext2       -26.95     to 5.09
DBench    clients-8-ext2       -5.75      to 5.50

Same story, hackbench-pipes and dbench suffer badly on some machines.
It's a similar story for order-1. With machine omitted it's

Kernbench Elapsed    time      -0.14      to 0.24
Kernbench Total  CPU           -0.13      to 0.11
Hackbench pipes-1              -11.90     to 5.39
Hackbench pipes-4              -7.01      to 2.06
Hackbench pipes-8              -5.49      to 1.66
Hackbench pipes-16             -6.08      to 2.72
Hackbench sockets-1            0.28       to 6.99
Hackbench sockets-4            0.63       to 5.50
Hackbench sockets-8            -10.95     to 7.70
Hackbench sockets-16           0.64       to 12.16
TBench    clients-1            -3.94      to 1.05
TBench    clients-2            -11.96     to 3.25
TBench    clients-4            -12.48     to -1.12
TBench    clients-8            -11.82     to -8.56
DBench    clients-1-ext2       -12.20     to 2.27
DBench    clients-2-ext2       -4.23      to 0.57
DBench    clients-4-ext2       -2.31      to 3.96
DBench    clients-8-ext2       -3.65      to 6.09

Included, it's

Kernbench Elapsed    time      -0.14      to 7.53
Kernbench Total  CPU           -0.14      to 0.53
Hackbench pipes-1              -18.85     to 5.39
Hackbench pipes-4              -18.93     to 2.06
Hackbench pipes-8              -14.24     to 1.66
Hackbench pipes-16             -12.82     to 2.72
Hackbench sockets-1            -4.89      to 6.99
Hackbench sockets-4            0.63       to 5.51
Hackbench sockets-8            -10.95     to 8.75
Hackbench sockets-16           -0.43      to 12.16
TBench    clients-1            -4.72      to 1.05
TBench    clients-2            -12.81     to 3.25
TBench    clients-4            -19.15     to -1.12
TBench    clients-8            -21.81     to -8.56
DBench    clients-1-ext2       -12.20     to 2.27
DBench    clients-2-ext2       -4.23      to 6.93
DBench    clients-4-ext2       -7.13      to 3.96
DBench    clients-8-ext2       -3.65      to 6.09

Based on this set of tests, it's clear that raising the order can be a big
win but setting it as default is less clear-cut.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
