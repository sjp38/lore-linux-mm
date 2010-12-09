Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 73A5C6B0089
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 06:18:24 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/5] Prevent kswapd dumping excessive amounts of memory in response to high-order allocations V3
Date: Thu,  9 Dec 2010 11:18:14 +0000
Message-Id: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

There was a minor bug in V2 that led to this release.  I'm hopeful it'll
stop kswapd going mad on Simon's machine and might also alleviate some of
the "too much free memory" problem.

Changelog since V2
  o Add clarifying comments
  o Properly check that the zone is balanced for order-0
  o Treat zone->all_unreclaimable properly

Changelog since V1
  o Take classzone into account
  o Ensure that kswapd always balances at order-09
  o Reset classzone and order after reading
  o Require a percentage of a node be balanced for high-order allocations,
    not just any zone as ZONE_DMA could be balanced when the node in general
    is a mess

Simon Kirby reported the following problem

   We're seeing cases on a number of servers where cache never fully
   grows to use all available memory.  Sometimes we see servers with 4
   GB of memory that never seem to have less than 1.5 GB free, even with
   a constantly-active VM.  In some cases, these servers also swap out
   while this happens, even though they are constantly reading the working
   set into memory.  We have been seeing this happening for a long time;
   I don't think it's anything recent, and it still happens on 2.6.36.

After some debugging work by Simon, Dave Hansen and others, the prevaling
theory became that kswapd is reclaiming order-3 pages requested by SLUB
too aggressive about it.

There are two apparent problems here. On the target machine, there is a small
Normal zone in comparison to DMA32. As kswapd tries to balance all zones, it
would continually try reclaiming for Normal even though DMA32 was balanced
enough for callers. The second problem is that sleeping_prematurely() does
not use the same logic as balance_pgdat() when deciding whether to sleep
or not.  This keeps kswapd artifically awake.

A number of tests were run and the figures from previous postings will look
very different for a few reasons. One, the old figures were forcing my network
card to use GFP_ATOMIC in attempt to replicate Simon's problem. Second, I
previous specified slub_min_order=3 again in an attempt to reproduce Simon's
problem. In this posting, I'm depending on Simon to say whether his problem is
fixed or not and these figures are to show the impact to the ordinary cases.
Finally, the "vmscan" figures are taken from /proc/vmstat instead of the
tracepoints.  There is less information but recording is less disruptive.

The first test of relevance was postmark with a process running in the
background reading a large amount of anonymous memory in blocks. The
objective was to vaguely simulate what was happening on Simon's machine
and it's memory intensive enough to have kswapd awake.

POSTMARK
                                            traceonly          kanyzone
Transactions per second:              156.00 ( 0.00%)   153.00 (-1.96%)
Data megabytes read per second:        21.51 ( 0.00%)    21.52 ( 0.05%)
Data megabytes written per second:     29.28 ( 0.00%)    29.11 (-0.58%)
Files created alone per second:       250.00 ( 0.00%)   416.00 (39.90%)
Files create/transact per second:      79.00 ( 0.00%)    76.00 (-3.95%)
Files deleted alone per second:       520.00 ( 0.00%)   420.00 (-23.81%)
Files delete/transact per second:      79.00 ( 0.00%)    76.00 (-3.95%)

MMTests Statistics: duration
User/Sys Time Running Test (seconds)         16.58      17.4
Total Elapsed Time (seconds)                218.48    222.47

VMstat Reclaim Statistics: vmscan
Direct reclaims                                  0          4
Direct reclaim pages scanned                     0        203
Direct reclaim pages reclaimed                   0        184
Kswapd pages scanned                        326631     322018
Kswapd pages reclaimed                      312632     309784
Kswapd low wmark quickly                         1          4
Kswapd high wmark quickly                      122        475
Kswapd skip congestion_wait                      1          0
Pages activated                             700040     705317
Pages deactivated                           212113     203922
Pages written                                 9875       6363

Total pages scanned                         326631    322221
Total pages reclaimed                       312632    309968
%age total pages scanned/reclaimed          95.71%    96.20%
%age total pages scanned/written             3.02%     1.97%

proc vmstat: Faults
Major Faults                                   300       254
Minor Faults                                645183    660284
Page ins                                    493588    486704
Page outs                                  4960088   4986704
Swap ins                                      1230       661
Swap outs                                     9869      6355

Performance is mildly affected because kswapd is no longer doing as much
work and the background memory consumer process is getting in the way. Note
that kswapd scanned and reclaimed fewer pages as it's less aggressive and
overall fewer pages were scanned and reclaimed. Swap in/out is particularly
reduced again reflecting kswapd throwing out fewer pages.

The slight performance impact is unfortunate here but it looks like a direct
result of kswapd being less aggressive. As the bug report is about too many
pages being freed by kswapd, it may have to be accepted for now.

The second test is a streaming IO benchmark that was previously used by
Johannes to show regressions in page reclaim.

MICRO
					 traceonly  kanyzone
User/Sys Time Running Test (seconds)         29.29     28.87
Total Elapsed Time (seconds)                492.18    488.79

VMstat Reclaim Statistics: vmscan
Direct reclaims                               2128       1460
Direct reclaim pages scanned               2284822    1496067
Direct reclaim pages reclaimed              148919     110937
Kswapd pages scanned                      15450014   16202876
Kswapd pages reclaimed                     8503697    8537897
Kswapd low wmark quickly                      3100       3397
Kswapd high wmark quickly                     1860       7243
Kswapd skip congestion_wait                    708        801
Pages activated                               9635       9573
Pages deactivated                             1432       1271
Pages written                                  223       1130

Total pages scanned                       17734836  17698943
Total pages reclaimed                      8652616   8648834
%age total pages scanned/reclaimed          48.79%    48.87%
%age total pages scanned/written             0.00%     0.01%

proc vmstat: Faults
Major Faults                                   165       221
Minor Faults                               9655785   9656506
Page ins                                      3880      7228
Page outs                                 37692940  37480076
Swap ins                                         0        69
Swap outs                                       19        15

Again fewer pages are scanned and reclaimed as expected and this time the test
completed faster. Note that kswapd is hitting its watermarks faster (low and
high wmark quickly) which I expect is due to kswapd reclaiming fewer pages.

I also ran fs-mark, iozone and sysbench but there is nothing interesting
to report in the figures. Performance is not significantly changed and the
reclaim statistics look reasonable.

 include/linux/mmzone.h |    3 +-
 mm/page_alloc.c        |    8 ++-
 mm/vmscan.c            |  132 +++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 120 insertions(+), 23 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
