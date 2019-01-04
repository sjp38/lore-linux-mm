Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 88B628E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:50:24 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t2so34858778edb.22
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:50:24 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id n1-v6si344185eji.127.2019.01.04.04.50.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:50:22 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 3A53D1C2121
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:50:22 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 00/25] Increase success rates and reduce latency of compaction v2
Date: Fri,  4 Jan 2019 12:49:46 +0000
Message-Id: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This series reduces scan rates and success rates of compaction, primarily
by using the free lists to shorten scans, better controlling of skip
information and whether multiple scanners can target the same block and
capturing pageblocks before being stolen by parallel requests. The series
is based on the 4.21/5.0 merge window after Andrew's tree had been merged.
It's known to rebase cleanly.

Primarily I'm using thpscale to measure the impact of the series. The
benchmark creates a large file, maps it, faults it, punches holes in the
mapping so that the virtual address space is fragmented and then tries
to allocate THP. It re-executes for different numbers of threads. From a
fragmentation perspective, the workload is relatively benign but it does
stress compaction.

The overall impact on latencies for a 1-socket machine is

				      baseline		      patches
Amean     fault-both-3      5362.80 (   0.00%)     4446.89 *  17.08%*
Amean     fault-both-5      9488.75 (   0.00%)     5660.86 *  40.34%*
Amean     fault-both-7     11909.86 (   0.00%)     8549.63 *  28.21%*
Amean     fault-both-12    16185.09 (   0.00%)    11508.36 *  28.90%*
Amean     fault-both-18    12057.72 (   0.00%)    19013.48 * -57.69%*
Amean     fault-both-24    23939.95 (   0.00%)    19676.16 *  17.81%*
Amean     fault-both-30    26606.14 (   0.00%)    27363.23 (  -2.85%)
Amean     fault-both-32    31677.12 (   0.00%)    23154.09 *  26.91%*

While there is a glitch at the 18-thread mark, it's known that the base
page allocation latency was much lower and huge pages were taking
longer -- partially due a high allocation success rate.

The allocation success rates are much improved

			 	 baseline		 patches
Percentage huge-3        70.93 (   0.00%)       98.30 (  38.60%)
Percentage huge-5        56.02 (   0.00%)       83.36 (  48.81%)
Percentage huge-7        60.98 (   0.00%)       89.04 (  46.01%)
Percentage huge-12       73.02 (   0.00%)       94.36 (  29.23%)
Percentage huge-18       94.37 (   0.00%)       95.87 (   1.58%)
Percentage huge-24       84.95 (   0.00%)       97.41 (  14.67%)
Percentage huge-30       83.63 (   0.00%)       96.69 (  15.62%)
Percentage huge-32       81.69 (   0.00%)       96.10 (  17.65%)

That's a nearly perfect allocation success rate.

The biggest impact is on the scan rates

Compaction migrate scanned   106520811    26934599
Compaction free scanned     4180735040    26584944

The number of pages scanned for migration was reduced by 74% and the
free scanner was reduced by 99.36%. So much less work in exchange
for lower latency and better success rates.

The series was also evaluated using a workload that heavily fragments
memory but the benefits there are also significant, albeit not presented.

It was commented that we should be rethinking scanning entirely and to
a large extent I agree. However, to achieve that you need a lot of this
series in place first so it's best to make the linear scanners as best
as possible before ripping them out.

 include/linux/compaction.h |    3 +-
 include/linux/gfp.h        |    7 +-
 include/linux/mmzone.h     |    2 +
 include/linux/sched.h      |    4 +
 kernel/sched/core.c        |    3 +
 mm/compaction.c            | 1031 ++++++++++++++++++++++++++++++++++----------
 mm/internal.h              |   23 +-
 mm/migrate.c               |    2 +-
 mm/page_alloc.c            |   70 ++-
 9 files changed, 908 insertions(+), 237 deletions(-)

-- 
2.16.4
