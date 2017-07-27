Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 03BED6B04BA
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:07:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i187so12232164wma.15
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:07:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b20si16821007wrb.144.2017.07.27.09.07.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 09:07:13 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 0/6] proactive kcompactd
Date: Thu, 27 Jul 2017 18:06:55 +0200
Message-Id: <20170727160701.9245-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

As we discussed at last LSF/MM [1], the goal here is to shift more compaction
work to kcompactd, which currently just makes a single high-order page
available and then goes to sleep. The last patch, evolved from the initial RFC
[2] does this by recording for each order > 0 how many allocations would have
potentially be able to skip direct compaction, if the memory wasn't fragmented.
Kcompactd then tries to compact as long as it takes to make that many
allocations satisfiable. This approach avoids any hooks in allocator fast
paths. There are more details to this, see the last patch.

The first 4 patches fix some corner cases where kcompactd wasn't properly woken
up in my basic testing, and could be reviewed and merged immediately if found
OK. Patch 5 terminates compaction (direct or kcompactd) faster when free memory
has been consumed in parallel. IIRC similar thing was already proposed by
Joonsoo.

First I did some basic testing with workload described in patches 2-4, where
memory is fragmented with allocating a large file and then in every other page
a hole is punched. A test doing GFP_NOWAIT allocations with short sleeps then
fails allocation, waking up kcompactd so that the next allocation succeeds,
then another one fails, waking up kcompactd etc. After the series, the number
of consecutive successes gradually grows as kcompactd increases its target,
and then it falls down as all free memory is depleted.

Then I did some more measurements with mmtests stress-highalloc (3 iterations)
configured for allocating order-4 pages with GFP_NOWAIT, to make it rely on
kcompactd completely. The baseline kernel is 4.12.3 plus "mm, page_alloc:
fallback to smallest page when not stealing whole pageblock"

                               4.12.3                4.12.3                4.12.3                4.12.3
                                 base                patch4                patch5                patch6
Success 1 Min         71.00 (  0.00%)       71.00 (  0.00%)       71.00 (  0.00%)       74.00 ( -4.23%)
Success 1 Mean        72.33 (  0.00%)       72.33 (  0.00%)       72.33 (  0.00%)       75.00 ( -3.69%)
Success 1 Max         73.00 (  0.00%)       74.00 ( -1.37%)       74.00 ( -1.37%)       76.00 ( -4.11%)
Success 2 Min         78.00 (  0.00%)       74.00 (  5.13%)       76.00 (  2.56%)       80.00 ( -2.56%)
Success 2 Mean        80.00 (  0.00%)       77.33 (  3.33%)       79.33 (  0.83%)       81.67 ( -2.08%)
Success 2 Max         81.00 (  0.00%)       81.00 (  0.00%)       82.00 ( -1.23%)       84.00 ( -3.70%)
Success 3 Min         88.00 (  0.00%)       88.00 (  0.00%)       91.00 ( -3.41%)       90.00 ( -2.27%)
Success 3 Mean        88.33 (  0.00%)       88.67 ( -0.38%)       91.33 ( -3.40%)       90.67 ( -2.64%)
Success 3 Max         89.00 (  0.00%)       90.00 ( -1.12%)       92.00 ( -3.37%)       91.00 ( -2.25%)

Success rates didn't change much, already quite high for an order-4 GFP_NOWAIT.

                                    4.12.3       4.12.3     4.12.3      4.12.3
                                      base      patch4      patch5      patch6
Kcompactd wakeups                    15705       16312       15335       20234
Compaction stalls                      155         130         135         130
Compaction success                      86          69          79          82
Compaction failures                     69          61          56          48
Page migrate success                925279      945304      954274     1363974
Page migrate failure                 77284       76466       82188       15060
Compaction pages isolated          1947918     1987482     2008541     2748177
Compaction migrate scanned      1501322768  1590902016  1601288469    85829846
Compaction free scanned          509199325   526560956   522041706   104149027
Compaction cost                      11507       12156       12238        2069

Not much happening until patch6, which results in more kcompactd wakeups, but
surprisingly much reduced scanning activity, and improved migrate stats.

Same test, but order-9 (again GFP_NOWAIT)

                               4.12.3                4.12.3                4.12.3                4.12.3
                                 base                patch4                patch5                patch6
Success 1 Min         57.00 (  0.00%)       56.00 (  1.75%)       54.00 (  5.26%)       56.00 (  1.75%)
Success 1 Mean        59.00 (  0.00%)       59.33 ( -0.56%)       56.00 (  5.08%)       58.00 (  1.69%)
Success 1 Max         60.00 (  0.00%)       63.00 ( -5.00%)       58.00 (  3.33%)       60.00 (  0.00%)
Success 2 Min         66.00 (  0.00%)       66.00 (  0.00%)       67.00 ( -1.52%)       65.00 (  1.52%)
Success 2 Mean        66.33 (  0.00%)       67.00 ( -1.01%)       67.00 ( -1.01%)       66.33 (  0.00%)
Success 2 Max         67.00 (  0.00%)       68.00 ( -1.49%)       67.00 (  0.00%)       68.00 ( -1.49%)
Success 3 Min         53.00 (  0.00%)       56.00 ( -5.66%)       51.00 (  3.77%)       57.00 ( -7.55%)
Success 3 Mean        56.00 (  0.00%)       57.00 ( -1.79%)       54.33 (  2.98%)       57.33 ( -2.38%)
Success 3 Max         58.00 (  0.00%)       59.00 ( -1.72%)       58.00 (  0.00%)       58.00 (  0.00%)

                                    4.12.3       4.12.3     4.12.3      4.12.3
                                      base      patch4      patch5      patch6
Kcompactd wakeups                      992        1676        1749        1661
Compaction stalls                      134         139         151          91
Compaction success                      93          83         103          53
Compaction failures                     41          55          48          37
Page migrate success                885733      904325      849397      869434
Page migrate failure                  8261       12819       12299       10288
Compaction pages isolated          1779692     1822833     1713638     1749977
Compaction migrate scanned        95755848    87494396    96276153    18487127
Compaction migrate prescanned            0           0           0           0
Compaction free scanned           33409748    38040646    34997109    15738289
Compaction free direct alloc             0           0           0           0
Compaction free dir. all. miss           0           0           0           0
Compaction cost                       1623        1585        1588        1065

Order-9 allocations are more likely to trigger the corner cases fixed by
patches 2-4 and thus we see increased kcompactd wakeups with patch 4.
Patch 6 again significantly decreases the numbers of pages scanned. It's not
yet clear how. Optimistic explanation would be that creating more free
high-order at once is more efficient than repeatedly creating a single page
always rescanning part of the zone uselessly, but it needs more investigation.
I will also redo the test with gfp flags allowing direct compaction, and see
if the series does shift the direct compaction effort into kcompactd as
expected. Meanwhile I would like some feedback whether this is going into the
right direction or not...

[1] https://lwn.net/Articles/717656/
[2] https://marc.info/?l=linux-mm&m=148898500006034

Vlastimil Babka (6):
  mm, kswapd: refactor kswapd_try_to_sleep()
  mm, kswapd: don't reset kswapd_order prematurely
  mm, kswapd: reset kswapd's order to 0 when it fails to reclaim enough
  mm, kswapd: wake up kcompactd when kswapd had too many failures
  mm, compaction: stop when number of free pages goes below watermark
  mm: make kcompactd more proactive

 include/linux/compaction.h |   6 ++
 include/linux/mmzone.h     |   3 +
 mm/compaction.c            | 226 ++++++++++++++++++++++++++++++++++++++++++++-
 mm/page_alloc.c            |  13 +++
 mm/vmscan.c                | 149 +++++++++++++++++-------------
 5 files changed, 329 insertions(+), 68 deletions(-)

-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
