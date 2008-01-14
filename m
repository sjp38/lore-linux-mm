Date: Mon, 14 Jan 2008 11:24:02 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Eliminate the hot/cold distinction in the page allocator
Message-ID: <20080114112401.GA32446@csn.ul.ie>
References: <Pine.LNX.4.64.0801102011340.23992@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801102011340.23992@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (10/01/08 20:13), Christoph Lameter didst pronounce:
> This is on top of the patch that adds cold pages to the end of the pcp
> list. It drops all the distinctions between hot and cold pages which
> improves performance. See the discussion and the tests that Mel Gorman
> performed with this patch at
> 
> http://marc.info/?t=119507025400001&r=1&w=2
> 

To be sure, I ran some tests on this. They take a while to run, hence
the delay in responding. The tests were based on 2.6.24-rc7 with the
per-cpu-related patches and this patch rebased to mainline instead of -mm (see
http://www.csn.ul.ie/~mel/postings/percpu-20080114/remove-hotcoldpcp.diff). It
still is a case that the performance with or without the list-split is
very close. With only one exception, the unified per-cpu list was slower
on average but by such a small amount, it's mostly within the standard
deviation between runs. Based on these tests, I still think it's safe to
get rid of the hot/cold PCP split.

Test Machine A: bl6-13 X86-64 (BladeCenter LS20)
Test Machine B: elm3a68 X86 (xSeries 345, Xeon based)
Test Machine C: gekko-lp3 PPC64 (System p5 570)

Kernbench
---------

X86-64 bl6-13
KernBench Timing Comparisin (2.6.24-rc7-hot-cold-pcp/2.6.24-rc7-unified-pcp)
                     Min                         Average
Max                         Std. Deviation              
                     --------------------------- --------------------------- --------------------------- ----------------------------
User   CPU time         84.86/84.82    (  0.05%)    85.32/84.87    (  0.53%) 85.59/84.94    (  0.76%)     0.28/0.05     (  84.03%)
System CPU time         33.14/33.46    ( -0.97%)    33.55/33.72    ( -0.49%) 34.14/33.83    (  0.91%)     0.37/0.15     (  59.84%)
Total  CPU time        118.73/118.40   (  0.28%)   118.87/118.58   (  0.24%) 119.00/118.67   (  0.28%)     0.10/0.11     ( -12.02%)
Elapsed    time         34.06/36.01    ( -5.73%)    35.49/36.78    ( -3.65%) 36.48/37.71    ( -3.37%)     0.91/0.65     (  28.53%)

X86 elm3a68
KernBench Timing Comparisin (2.6.24-rc7-hot-cold-pcp/2.6.24-rc7-unified-pcp)
                     Min                         Average                     Max                         Std. Deviation              
                     --------------------------- --------------------------- --------------------------- ----------------------------
User   CPU time       1251.30/1251.25  (  0.00%)  1251.40/1251.97  ( -0.05%)  1251.55/1253.07  ( -0.12%)     0.09/0.68     (-638.66%)
System CPU time        271.00/274.00   ( -1.11%)   272.32/274.22   ( -0.70%)   272.98/274.45   ( -0.54%)     0.78/0.21     (  73.70%)
Total  CPU time       1522.55/1525.28  ( -0.18%)  1523.72/1526.19  ( -0.16%)  1524.37/1527.07  ( -0.18%)     0.71/0.64     (  10.63%)
Elapsed    time        387.55/388.19   ( -0.17%)   388.94/389.76   ( -0.21%)   391.27/392.51   ( -0.32%)     1.47/1.77     ( -20.72%)

PPC64 gekko-lp3
KernBench Timing Comparisin (2.6.24-rc7-hot-cold-pcp/2.6.24-rc7-unified-pcp)
                     Min                         Average                     Max                         Std. Deviation              
                     --------------------------- --------------------------- --------------------------- ----------------------------
User   CPU time        308.92/308.29   (  0.20%)   309.10/308.60   (  0.16%)   309.35/308.86   (  0.16%)     0.16/0.23     ( -44.74%)
System CPU time         16.80/16.78    (  0.12%)    16.82/16.80    (  0.12%)    16.83/16.81    (  0.12%)     0.01/0.01     (   0.00%)
Total  CPU time        325.72/325.07   (  0.20%)   325.92/325.39   (  0.16%)   326.16/325.66   (  0.15%)     0.16/0.23     ( -44.74%)
Elapsed    time        164.03/163.29   (  0.45%)   164.20/163.85   (  0.21%)   164.36/164.21   (  0.09%)     0.12/0.34     (-191.99%)

The bl6-13 elapsed time regression looks severe but it's within standard
deviation. gekko-lp3 was the only machine (out of 12 I tested) that showed
an improvement here. However, gekko-lp1 which is very similar to gekko-lp3
showed a small regression so I guess this is something that varies.

However, I would conclude that the difference here is so minimal that it
doesn't justify splitting per-cpu lists on its own.

Create/Delete
-------------

This is based on the create-delete.c test from ext3 mentioned last by Andrew
here http://marc.info/?l=linux-mm&m=119517308705439&w=2. The test is run
multiple times with different numbers of clients and size mappings. The results
linked here as 1 client running per CPU in the system (i.e. 4 clients)

bl6-13:    http://www.csn.ul.ie/~mel/postings/percpu-20080114/bl6-13-comparison-anonfilemapping-4.ps
elm3a68:   http://www.csn.ul.ie/~mel/postings/percpu-20080114/elm3a68-comparison-anonfilemapping-4.ps
gekko-lp3: http://www.csn.ul.ie/~mel/postings/percpu-20080114/gekko-lp3-comparison-anonfilemapping-4.ps

On bl6-13, anonymous file mappings were comparable. With file mappings,
splitting the per-cpu lists is comparable until the size is larger than the
L2 cache, then it gets slower (11% at the end). In contrast with elm3a68 and
gekko-lp3, the unifying the lists is sometimes marginally faster throughout.

HackBench
---------

While this test is for the scheduler, we've seen where SLAB/SLUB has different
performance characteristics on this test. While the nature of that regression
has no relevance here, I thought it wouldn't hurt to do a comparison just
in case we were very unlucky with the batch sizes and PCP watermarks.

bl6-13:    http://www.csn.ul.ie/~mel/postings/percpu-20080114/bl6-13-comparison-hackbench.ps
elm3a68:   http://www.csn.ul.ie/~mel/postings/percpu-20080114/elm3a68-comparison-hackbench.ps
gekko-lp3: http://www.csn.ul.ie/~mel/postings/percpu-20080114/gekko-lp3-comparison-hackbench.ps

With bl6-13, performance is again very close. Unifying the lists seemed
marginally faster with sockets and marginally slower with pipes - too small
a margin to really say much about. Similar story with elm3a68. With gekko-lp3,
unifying seems slightly *slower* with sockets but similar with pipes.

HighAlloc Comparison
--------------------

I'm not going to say much about this as it's not a performance issue. On some
machines it helped and on others it hurt. I don't have specific details as to
why it makes a difference at all but analysing it will be done independently
of this patch.

Ideally, sysbench and volanomark would also be run but I'm still in the
process of getting them automated fully for doing this type of testing. As
it is, I still see no problems with the patches.

> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
