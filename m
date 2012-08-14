Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id B8E816B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 12:41:36 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/5] Improve hugepage allocation success rates under load V4
Date: Tue, 14 Aug 2012 17:41:27 +0100
Message-Id: <1344962492-1914-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Changelog since V3
o Add patch to backoff compaction in the event of lock contention
o Rebase to mmotm, cope with the removal of __GFP_NO_KSWAPD
o Removed RFC

Changelog since V2
o Capture !MIGRATE_MOVABLE pages where possible
o Document the treatment of MIGRATE_MOVABLE pages while capturing
o Expand changelogs

Changelog since V1
o Dropped kswapd related patch, basically a no-op and regresses if fixed (minchan)
o Expanded changelogs a little

Allocation success rates have been far lower since 3.4 due to commit
[fe2c2a10: vmscan: reclaim at order 0 when compaction is enabled]. This
commit was introduced for good reasons and it was known in advance that
the success rates would suffer but it was justified on the grounds that
the high allocation success rates were achieved by aggressive reclaim.
Success rates are expected to suffer even more in 3.6 due to commit
[7db8889a: mm: have order > 0 compaction start off where it left] which
testing has shown to severely reduce allocation success rates under load -
to 0% in one case.

This series aims to improve the allocation success rates without regressing
the benefits of commit fe2c2a10. The series is based on latest mmotm and
takes into account the __GFP_NO_KSWAPD flag is going away.

Patch 1 updates a stale comment seeing as I was in the general area.

Patch 2 updates reclaim/compaction to reclaim pages scaled on the number
	of recent failures.

Patch 3 captures suitable high-order pages freed by compaction to reduce
	races with parallel allocation requests.

Patch 4 fixes the upstream commit [7db8889a: mm: have order > 0 compaction
	start off where it left] to enable compaction again

Patch 5 identifies when compacion is taking too long due to contention
	and aborts.

STRESS-HIGHALLOC
		 3.6-rc1-akpm	  full-series
Pass 1          36.00 ( 0.00%)    51.00 (15.00%)
Pass 2          42.00 ( 0.00%)    63.00 (21.00%)
while Rested    86.00 ( 0.00%)    86.00 ( 0.00%)

>From
http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__stress-highalloc-performance-ext3/hydra/comparison.html
I know that the allocation success rates in 3.3.6 was 78% in comparison to
36% in in the current akpm tree. With the full series applied, the success
rates are up to around 51% with some variability in the results. This is
not as high a success rate but it does not reclaim excessively which is
a key point.

MMTests Statistics: vmstat
Page Ins                                     3050912     3078892
Page Outs                                    8033528     8039096
Swap Ins                                           0           0
Swap Outs                                          0           0

Note that swap in/out rates remain at 0. In 3.3.6 with 78% success rates
there were 71881 pages swapped out.

Direct pages scanned                           70942      122976
Kswapd pages scanned                         1366300     1520122
Kswapd pages reclaimed                       1366214     1484629
Direct pages reclaimed                         70936      105716
Kswapd efficiency                                99%         97%
Kswapd velocity                             1072.550    1182.615
Direct efficiency                                99%         85%
Direct velocity                               55.690      95.672

The kswapd velocity changes very little as expected. kswapd velocity
is around the 1000 pages/sec mark where as in kernel 3.3.6 with the high
allocation success rates it was 8140 pages/second. Direct velocity is higher
as a result of patch 2 of the series but this is expected and is acceptable.
The direct reclaim and kswapd velocities change very little.

If these get accepted for merging then there is a difficulty in how they
should be handled.  Commit [7db8889a: mm: have order > 0 compaction start
off where it left] is broken but it is already in 3.6-rc1 and needs to
be fixed. However, if just patch 4 from this series is applied then Jim
Schutt's workload is known to break again as his workload also requires
patch 5. While it would be preferred to have all these patches in 3.6 to
improve compaction in general, it would at least be acceptable if just
patches 4 and 5 were merged to 3.6 to fix a known problem without breaking
compaction completely. On the face of it, that would force __GFP_NO_KSWAPD
patches to be merged at the same time but I can do a version of this series
with __GFP_NO_KSWAPD change reverted and then rebase it on top of this
series. That might be best overall because I note that the __GFP_NO_KSWAPD
patch should have removed deferred_compaction from page_alloc.c but it
didn't but fixing that causes collisions with this series.

 include/linux/compaction.h |    4 +-
 include/linux/mm.h         |    1 +
 mm/compaction.c            |  245 +++++++++++++++++++++++++++++++++-----------
 mm/internal.h              |    2 +
 mm/page_alloc.c            |   78 ++++++++++----
 mm/vmscan.c                |   10 ++
 6 files changed, 256 insertions(+), 84 deletions(-)

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
