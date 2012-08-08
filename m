Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 9C2CB6B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 15:08:48 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/5] Improve hugepage allocation success rates under load V2
Date: Wed,  8 Aug 2012 20:08:39 +0100
Message-Id: <1344452924-24438-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
to 0% in one case.  There is a proposed change to that patch in this series
and it would be ideal if Jim Schutt could retest the workload that led to
commit [7db8889a: mm: have order > 0 compaction start off where it left].

This series aims to improve the allocation success rates without regressing
the benefits of commit fe2c2a10. The series is based on 3.5 and includes
the commit 7db8889a to illustrate what impact it has to success rates.

Patch 1 updates a stale comment seeing as I was in the general area.

Patch 2 updates reclaim/compaction to reclaim pages scaled on the number
	of recent failures.

Patch 3 captures suitable high-order pages freed by compaction to reduce
	races with parallel allocation requests.

Patch 4 is an upstream commit that has compaction restart free page scanning
	from an old position instead of always starting from the end of the
	zone

Patch 5 adjusts patch 5 to restores allocation success rates.

STRESS-HIGHALLOC
		 3.5.0-vanilla	  patches:1-2	    patches:1-3       patches:1-5
Pass 1          36.00 ( 0.00%)    61.00 (25.00%)    62.00 (26.00%)    56.00 (20.00%)
Pass 2          46.00 ( 0.00%)    61.00 (15.00%)    60.00 (14.00%)    56.00 (10.00%)
while Rested    84.00 ( 0.00%)    85.00 ( 1.00%)    86.00 ( 2.00%)    85.00 ( 1.00%)

>From
http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__stress-highalloc-performance-ext3/hydra/comparison.html
I know that the allocation success rates in 3.3.6 was 78% in comparison
to 36% in 3.5. With the full series applied, the success rates are up to
around 60% with some variability in the results. This is not as high
a success rate but it does not reclaim excessively which is a key point.

Previous tests on V1 of this series showed that patch 4 on its own adversely
affected high-order allocation success rates.

MMTests Statistics: vmstat
Page Ins                                     3037580     3167260     3121588     2939576
Page Outs                                    8026888     8028472     8026444     8033852
Swap Ins                                           0           0           0           0
Swap Outs                                          0           0           0           0

Note that swap in/out rates remain at 0. In 3.3.6 with 78% success rates
there were 71881 pages swapped out.

Direct pages scanned                           97106       59600      118792       84142
Kswapd pages scanned                         1231288     1419472     1406569     1406642
Kswapd pages reclaimed                       1231221     1419248     1390694     1357820
Direct pages reclaimed                         97100       59486      107873       82067
Kswapd efficiency                                99%         99%         98%         96%
Kswapd velocity                             1001.153    1129.622    1082.592    1077.474
Direct efficiency                                99%         99%         90%         97%
Direct velocity                               78.956      47.430      91.431      64.452

kswapd velocity stays at around 1000 pages/second which is reasonable. In
kernel 3.3.6, it was 8140 pages/second.

 include/linux/compaction.h |    4 +-
 include/linux/mm.h         |    1 +
 include/linux/mmzone.h     |    4 ++
 mm/compaction.c            |  142 +++++++++++++++++++++++++++++++++++++-------
 mm/internal.h              |    7 +++
 mm/page_alloc.c            |   68 ++++++++++++++++-----
 mm/vmscan.c                |   10 ++++
 7 files changed, 197 insertions(+), 39 deletions(-)

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
