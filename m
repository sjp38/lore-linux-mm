Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 234566B0034
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 10:32:17 -0400 (EDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 0/6] Improving munlock() performance for large non-THP areas
Date: Mon,  5 Aug 2013 16:31:59 +0200
Message-Id: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: joern@logfs.org
Cc: mgorman@suse.de, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

Hi everyone and apologies for any mistakes in my first attempt at linux-mm
contribution :)

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
and locking, which the patches aim to reduce, starting from easier to more
complex changes.

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

Patch 6 Removes a redundant get_page/put_page pair which saves costly atomic
	operations.

Measurements were made using 3.11-rc3 as a baseline.

timedmunlock
                            3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3
                                   0                     1                     2                     3                     4                     5                     6
Elapsed min           3.38 (  0.00%)        3.39 ( -0.14%)        3.00 ( 11.35%)        2.73 ( 19.48%)        2.72 ( 19.50%)        2.34 ( 30.78%)        2.16 ( 36.23%)
Elapsed mean          3.39 (  0.00%)        3.39 ( -0.05%)        3.01 ( 11.25%)        2.73 ( 19.54%)        2.73 ( 19.41%)        2.36 ( 30.30%)        2.17 ( 36.00%)
Elapsed stddev        0.01 (  0.00%)        0.00 ( 71.98%)        0.01 (-71.14%)        0.00 ( 89.12%)        0.01 (-48.55%)        0.03 (-277.27%)        0.01 (-85.75%)
Elapsed max           3.41 (  0.00%)        3.40 (  0.39%)        3.04 ( 10.81%)        2.73 ( 19.96%)        2.76 ( 19.09%)        2.43 ( 28.64%)        2.20 ( 35.41%)
Elapsed range         0.02 (  0.00%)        0.01 ( 74.99%)        0.04 (-66.12%)        0.00 ( 88.12%)        0.03 (-39.24%)        0.09 (-274.85%)        0.04 (-81.04%)


Vlastimil Babka (6):
  mm: putback_lru_page: remove unnecessary call to page_lru_base_type()
  mm: munlock: remove unnecessary call to lru_add_drain()
  mm: munlock: batch non-THP page isolation and munlock+putback using
    pagevec
  mm: munlock: batch NR_MLOCK zone state updates
  mm: munlock: bypass per-cpu pvec for putback_lru_page
  mm: munlock: remove redundant get_page/put_page pair on the fast path

 mm/mlock.c  | 259 ++++++++++++++++++++++++++++++++++++++++++++++++++----------
 mm/vmscan.c |  12 +--
 2 files changed, 224 insertions(+), 47 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
