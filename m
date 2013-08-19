Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 8758F6B0034
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 08:24:12 -0400 (EDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 0/7] Improving munlock() performance for large non-THP areas
Date: Mon, 19 Aug 2013 14:23:35 +0200
Message-Id: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?J=C3=B6rn=20Engel?= <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

Changes in version 2:

o Added Patch 7 that tries to avoid calling follow_page_mask() on each
  individual page where possible and instead obtain page reference through
  pte walk. Increases the total observed speedup in ideal case to 43%.

o Fixed a pgrescued counting bug in Patch 5.

o Removed the few likely/unlikely wrappers as suggested by JA?rn.

o The switch around call to __isolate_lru_page that used to be introduced in
  Patch 3 and removed in Patch 5 is now not introduced at all, as several
  people pointed out it was unnecessarily ugly.

The goal of this patch series is to improve performance of munlock() of large
mlocked memory areas on systems without THP. This is motivated by reported very
long times of crash recovery of processes with such areas, where munlock() can
take several seconds. See http://lwn.net/Articles/548108/

The work was driven by a simple benchmark (to be included in mmtests) that
mmaps() e.g. 56GB with MAP_LOCKED | MAP_POPULATE and measures the time of
munlock(). Profiling was performed by attaching operf --pid to the process
and sending a signal to trigger the munlock() part and then notify bach
the monitoring wrapper to stop operf, so that only munlock() appears in the
profile.

The profiles have shown that CPU time is spent mostly by atomic operations
and repeated locking per single pages. This series aims to reduce both, starting
from simpler to more complex changes.

Patch 1 performs a simple cleanup in putback_lru_page() so that page lru base
	type is not determined without being actually needed.

Patch 2 removes an unnecessary call to lru_add_drain() which drains the per-cpu
	pagevec after each munlocked page is put there.

Patch 3 changes munlock_vma_range() to use an on-stack pagevec for isolating
	multiple non-THP pages under a single lru_lock instead of locking and
	processing each page separately.

Patch 4 changes the NR_MLOCK accounting to be called only once per the pvec
	introduced by previous patch.

Patch 5 uses the introduced pagevec to batch also the work of putback_lru_page
	when possible, bypassing the per-cpu pvec and associated overhead.

Patch 6 removes a redundant get_page/put_page pair which saves costly atomic
	operations.

Patch 7 avoids calling follow_page_mask() on each individual page, and obtains
	multiple page references under a single page table lock where possible.

Measurements were made using 3.11-rc3 as a baseline.
The first set of measurements shows the possibly ideal conditions where
batching should help the most. All memory is allocated from a single NUMA
node and THP is disabled.

timedmunlock
                            3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3
                                   0                     1                     2                     3                     4                     5                     6                     7
Elapsed min           3.38 (  0.00%)        3.39 ( -0.13%)        3.00 ( 11.33%)        2.70 ( 20.20%)        2.67 ( 21.11%)        2.37 ( 29.88%)        2.20 ( 34.91%)        1.91 ( 43.59%)
Elapsed mean          3.39 (  0.00%)        3.40 ( -0.23%)        3.01 ( 11.33%)        2.70 ( 20.26%)        2.67 ( 21.21%)        2.38 ( 29.88%)        2.21 ( 34.93%)        1.92 ( 43.46%)
Elapsed stddev        0.01 (  0.00%)        0.01 (-43.09%)        0.01 ( 15.42%)        0.01 ( 23.42%)        0.00 ( 89.78%)        0.01 ( -7.15%)        0.00 ( 76.69%)        0.02 (-91.77%)
Elapsed max           3.41 (  0.00%)        3.43 ( -0.52%)        3.03 ( 11.29%)        2.72 ( 20.16%)        2.67 ( 21.63%)        2.40 ( 29.50%)        2.21 ( 35.21%)        1.96 ( 42.39%)
Elapsed range         0.03 (  0.00%)        0.04 (-51.16%)        0.02 (  6.27%)        0.02 ( 14.67%)        0.00 ( 88.90%)        0.03 (-19.18%)        0.01 ( 73.70%)        0.06 (-113.35%

The second set of measurements simulates the worst possible conditions for
batching by using numactl --interleave, so that there is in fact only one page
per pagevec. Even in this case the series seems to improve performance thanks
to reduced atomic operations and removal of lru_add_drain().

timedmunlock
                            3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3
                                   0                     1                     2                     3                     4                     5                     6                     7
Elapsed min           4.00 (  0.00%)        4.04 ( -0.93%)        3.87 (  3.37%)        3.72 (  6.94%)        3.81 (  4.72%)        3.69 (  7.82%)        3.64 (  8.92%)        3.41 ( 14.81%)
Elapsed mean          4.17 (  0.00%)        4.15 (  0.51%)        4.03 (  3.49%)        3.89 (  6.84%)        3.86 (  7.48%)        3.89 (  6.69%)        3.70 ( 11.27%)        3.48 ( 16.59%)
Elapsed stddev        0.16 (  0.00%)        0.08 ( 50.76%)        0.10 ( 41.58%)        0.16 (  4.59%)        0.05 ( 72.38%)        0.19 (-12.91%)        0.05 ( 68.09%)        0.06 ( 66.03%)
Elapsed max           4.34 (  0.00%)        4.32 (  0.56%)        4.19 (  3.62%)        4.12 (  5.15%)        3.91 (  9.88%)        4.12 (  5.25%)        3.80 ( 12.58%)        3.56 ( 18.08%)
Elapsed range         0.34 (  0.00%)        0.28 ( 17.91%)        0.32 (  6.45%)        0.40 (-15.73%)        0.10 ( 70.06%)        0.43 (-24.84%)        0.15 ( 55.32%)        0.15 ( 56.16%)

For completeness, a third set of measurements shows the situation where THP is
enabled and allocations are again done on a single NUMA node. Here munlock() is
already very fast thanks to huge pages, and thies series does not compromise
that performance. It seems that the removal of call to lru_add_drain() still
helps a bit.

timedmunlock
                            3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3
                                   0                     1                     2                     3                     4                     5                     6                     7
Elapsed min           0.01 (  0.00%)        0.01 ( -0.11%)        0.01 (  6.59%)        0.01 (  5.41%)        0.01 (  5.45%)        0.01 (  5.03%)        0.01 (  6.08%)        0.01 (  5.20%)
Elapsed mean          0.01 (  0.00%)        0.01 ( -0.27%)        0.01 (  6.39%)        0.01 (  5.30%)        0.01 (  5.32%)        0.01 (  5.03%)        0.01 (  5.97%)        0.01 (  5.22%)
Elapsed stddev        0.00 (  0.00%)        0.00 ( -9.59%)        0.00 ( 10.77%)        0.00 (  3.24%)        0.00 ( 24.42%)        0.00 ( 31.86%)        0.00 ( -7.46%)        0.00 (  6.11%)
Elapsed max           0.01 (  0.00%)        0.01 ( -0.01%)        0.01 (  6.83%)        0.01 (  5.42%)        0.01 (  5.79%)        0.01 (  5.53%)        0.01 (  6.08%)        0.01 (  5.26%)
Elapsed range         0.00 (  0.00%)        0.00 (  7.30%)        0.00 ( 24.38%)        0.00 (  6.10%)        0.00 ( 30.79%)        0.00 ( 42.52%)        0.00 (  6.11%)        0.00 ( 10.07%)

Vlastimil Babka (7):
  mm: putback_lru_page: remove unnecessary call to page_lru_base_type()
  mm: munlock: remove unnecessary call to lru_add_drain()
  mm: munlock: batch non-THP page isolation and munlock+putback using
    pagevec
  mm: munlock: batch NR_MLOCK zone state updates
  mm: munlock: bypass per-cpu pvec for putback_lru_page
  mm: munlock: remove redundant get_page/put_page pair on the fast path
  mm: munlock: manual pte walk in fast path instead of
    follow_page_mask()

 mm/mlock.c  | 331 +++++++++++++++++++++++++++++++++++++++++++++++++++---------
 mm/vmscan.c |  12 +--
 2 files changed, 288 insertions(+), 55 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
