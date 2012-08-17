Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 6B4DC6B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 10:14:38 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/7] Improve hugepage allocation success rates under load V5
Date: Fri, 17 Aug 2012 15:14:26 +0100
Message-Id: <1345212873-22447-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Andrew, the biggest change here is that I've reshuffled the patches to
simplify merging. Please consider picking up patches 2 and 3 and merging
them for 3.6 as they fix a broken commit merged in 3.6-rc1. The rest of
the patches can be merged later.

Changelog since V4
o Rebase to latest linux-next/akpm
o Reshuffle patches for easier merging

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

Patch 1 reverts the __GFP_NO_KSWAPD patch and related fixes. This is so
	patches 2 and 3 can be merged before 3.6 releases. It is reintroduced
	later.

Patch 2 fixes the upstream commit [7db8889a: mm: have order > 0 compaction
	start off where it left] to enable compaction again

Patch 3 identifies when compacion is taking too long due to contention
	and aborts. This fixes a performance problem for Jim Schutt that
	commit 7db8889a was meant to fix.

Patch 4 is a comment fix.

Patch 5 is a rebased version of the __GFP_NO_KSWAPD patch with one change
	in how it handles deferred_compaction.

Patch 6 updates reclaim/compaction to reclaim pages scaled on the number
	of recent failures.

Patch 7 captures suitable high-order pages freed by compaction to reduce
	races with parallel allocation requests.

I tested with a high order allocation stress test. The following kernels
were tested.

revert-v5 	linux-next/mmotm based on 3.6-rc2 with patch 1 applied
contended-v5 	patches 1-3
capture-v5  	patches 1-7

STRESS-HIGHALLOC
                   revert-v5      contended-v5        capture-v5  
Pass 1           0.00 ( 0.00%)    38.00 (38.00%)    45.00 (45.00%)
Pass 2           0.00 ( 0.00%)    46.00 (46.00%)    52.00 (52.00%)
while Rested    85.00 ( 0.00%)    86.00 ( 1.00%)    86.00 ( 1.00%)

>From
http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__stress-highalloc-performance-ext3/hydra/comparison.html
I know that the allocation success rates in 3.3.6 was 78% in comparison to
36% in in the current akpm tree. At present the success rate is completely
shot but with patches and 3 applied it goes back up to 38% which is what
I would like to see merged for 3.6. With the full series applied success
rates go up to 45% with some variability in the results.  This is not
as high a success rate as seen in older kernels but it does not reclaim
excessively which is a key point.

MMTests Statistics: vmstat
Page Ins                                     2889316     2904472     3037020
Page Outs                                    8042076     8030516     8026740
Swap Ins                                           0           0           0
Swap Outs                                          0           0           0

Note that swap in/out rates remain at 0. In 3.3.6 with 78% success rates
there were 71881 pages swapped out.

Direct pages scanned                           16822      126135       39297
Kswapd pages scanned                         1112284     1243865     1534553
Kswapd pages reclaimed                       1106913     1203069     1499877
Direct pages reclaimed                         16822      113769       26457
Kswapd efficiency                                99%         96%         97%
Kswapd velocity                              899.586     980.634    1218.131
Direct efficiency                               100%         90%         67%
Direct velocity                               13.605      99.442      31.194

kswapd velocity increased slightly but that is expected as __GFP_NO_KSWAPD is
removed by the full series. The velocity with the full series applied is 1218
pages/sec where as in kernel 3.3.6 with the high allocation success rates
it was 8140 pages/second. Direct velocity is slightly higher but this is
expected as a result of patch 6. Pushing direct reclaim higher would improve
the allocation success rates but with the obvious cost of increased paging
and swap IO.

 include/linux/compaction.h |    4 +-
 include/linux/mm.h         |    1 +
 mm/compaction.c            |  244 +++++++++++++++++++++++++++++++++-----------
 mm/internal.h              |    2 +
 mm/page_alloc.c            |   78 ++++++++++----
 mm/vmscan.c                |   10 ++
 6 files changed, 256 insertions(+), 83 deletions(-)

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
