Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 88B0A8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:51:49 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o21so5272371edq.4
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:51:49 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id e52si333809edb.227.2019.01.18.09.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:51:47 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 2A5241C3555
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:51:47 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 00/22] Increase success rates and reduce latency of compaction v3
Date: Fri, 18 Jan 2019 17:51:14 +0000
Message-Id: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

This is a drop-in replacement for the series currently in Andrews tree that
incorporates static checking and compile warning fixes (Dan, YueHaibing)
and extensive review feedback from Vlastimil. Big thanks to Vlastimil as
the review was extremely detailed and a number of issues were caught. Not
all the patches have been acked but I think an update is still worthwhile.

Andrew, please drop the series you have and replace it with the following
on the off-chance we get bug reports that are fixed already. Doing this
with -fix patches would be relatively painful for little gain.

Changelog since v2
o Fix static checker warnings						(dan)
o Fix unused variable warnings						(yue)
o Drop patch about PageReserved as there is some abuse of the flag outside
  of the mm core.							(vbabka)
o Drop patch using the bulk free helper as it may be vulnerable to races
  with compaction and gup						(vbabka)
o Drop patch about remote compaction. It's unnecessary at this time and
  unclear what the semantics should even be				(vbabka)
o Changelog fixes and clarifications					(vbabka)
o Free list management and search
  Confined mostly to "mm, compaction: Use free lists to quickly locate
  a migration source" which is arguably the most heavily modified patch
  in this revision							(vbabka, mel)
o Some minor churn, modifications, flow changes that fallout from
  addressing the review feedback					(mel)
o Minor pageblock skip changes, mostly fixing up which patch makes the
  changes so the patches are incremental				(mel)

This series reduces scan rates and success rates of compaction, primarily
by using the free lists to shorten scans, better controlling of skip
information and whether multiple scanners can target the same block and
capturing pageblocks before being stolen by parallel requests. The series
is based on mmotm from January 9th, 2019 with the previous compaction
series reverted.

I'm mostly using thpscale to measure the impact of the series. The
benchmark creates a large file, maps it, faults it, punches holes in the
mapping so that the virtual address space is fragmented and then tries
to allocate THP. It re-executes for different numbers of threads. From a
fragmentation perspective, the workload is relatively benign but it does
stress compaction.

The overall impact on latencies for a 1-socket machine is

				      baseline		      patches
Amean     fault-both-3      3832.09 (   0.00%)     2748.56 *  28.28%*
Amean     fault-both-5      4933.06 (   0.00%)     4255.52 (  13.73%)
Amean     fault-both-7      7017.75 (   0.00%)     6586.93 (   6.14%)
Amean     fault-both-12    11610.51 (   0.00%)     9162.34 *  21.09%*
Amean     fault-both-18    17055.85 (   0.00%)    11530.06 *  32.40%*
Amean     fault-both-24    19306.27 (   0.00%)    17956.13 (   6.99%)
Amean     fault-both-30    22516.49 (   0.00%)    15686.47 *  30.33%*
Amean     fault-both-32    23442.93 (   0.00%)    16564.83 *  29.34%*

The allocation success rates are much improved

			 	 baseline		 patches
Percentage huge-3        85.99 (   0.00%)       97.96 (  13.92%)
Percentage huge-5        88.27 (   0.00%)       96.87 (   9.74%)
Percentage huge-7        85.87 (   0.00%)       94.53 (  10.09%)
Percentage huge-12       82.38 (   0.00%)       98.44 (  19.49%)
Percentage huge-18       83.29 (   0.00%)       99.14 (  19.04%)
Percentage huge-24       81.41 (   0.00%)       97.35 (  19.57%)
Percentage huge-30       80.98 (   0.00%)       98.05 (  21.08%)
Percentage huge-32       80.53 (   0.00%)       97.06 (  20.53%)

That's a nearly perfect allocation success rate.

The biggest impact is on the scan rates

Compaction migrate scanned    55893379    19341254
Compaction free scanned      474739990    11903963

The number of pages scanned for migration was reduced by 65% and the
free scanner was reduced by 97.5%. So much less work in exchange
for lower latency and better success rates.

The series was also evaluated using a workload that heavily fragments
memory but the benefits there are also significant, albeit not presented.

It was commented that we should be rethinking scanning entirely and to
a large extent I agree. However, to achieve that you need a lot of this
series in place first so it's best to make the linear scanners as best
as possible before ripping them out.

 include/linux/compaction.h |    3 +-
 include/linux/mmzone.h     |    2 +
 include/linux/sched.h      |    4 +
 kernel/sched/core.c        |    3 +
 mm/compaction.c            | 1000 ++++++++++++++++++++++++++++++++++----------
 mm/internal.h              |   23 +-
 mm/migrate.c               |    2 +-
 mm/page_alloc.c            |   76 +++-
 8 files changed, 888 insertions(+), 225 deletions(-)

-- 
2.16.4
