Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E87B6680FE7
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 04:22:51 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so62765248wjb.5
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 01:22:51 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id z65si4684745wme.157.2017.02.15.01.22.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Feb 2017 01:22:49 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 3AB0798E7A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 09:22:49 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/3] Reduce amount of time kswapd sleeps prematurely
Date: Wed, 15 Feb 2017 09:22:44 +0000
Message-Id: <20170215092247.15989-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

This patchset is based on mmots as of Feb 9th, 2016. The baseline is
important as there are a number of kswapd-related fixes in that tree and
a comparison against v4.10-rc7 would be almost meaningless as a result.

The series is unusual in that the first patch fixes one problem and
introduces a host of other issues and is incomplete. It was not developed
by me but it appears to have gotten lost so I picked it up and added to the
changelog. Patch 2 makes a minor modification that is worth considering
on its own but leaves the kernel in a state where it behaves badly. It's
not until patch 3 that there is an improvement against baseline.

This was mostly motivated by examining Chris Mason's "simoop" benchmark
which puts the VM under similar pressure to HADOOP. It has been reported
that the benchmark has regressed severely during the last number of
releases. While I cannot reproduce all the same problems Chris experienced
due to hardware limitations, there was a number of problems on a 2-socket
machine with a single disk.

                                         4.10.0-rc7            4.10.0-rc7
                                     mmots-20170209       keepawake-v1r25
Amean    p50-Read             22325202.49 (  0.00%) 22092755.48 (  1.04%)
Amean    p95-Read             26102988.80 (  0.00%) 26101849.04 (  0.00%)
Amean    p99-Read             30935176.53 (  0.00%) 29746220.52 (  3.84%)
Amean    p50-Write                 976.44 (  0.00%)      952.73 (  2.43%)
Amean    p95-Write               15471.29 (  0.00%)     3140.27 ( 79.70%)
Amean    p99-Write               35108.62 (  0.00%)     8843.73 ( 74.81%)
Amean    p50-Allocation          76382.61 (  0.00%)    76349.22 (  0.04%)
Amean    p95-Allocation         127777.39 (  0.00%)   108630.26 ( 14.98%)
Amean    p99-Allocation         187937.39 (  0.00%)   139094.26 ( 25.99%)

These are latencies. Read/write are threads reading fixed-size random blocks
from a simulated database. The allocation latency is mmaping and faulting
regions of memory. The p50, 95 and p99 reports the worst latencies for 50%
of the samples, 95% and 99% respectively.

For example, the report indicates that while the test was running 99% of
writes completed 74.81% faster. It's worth noting that on a UMA machine that
no difference in performance with simoop was observed so milage will vary.

On UMA, there was a notable difference in the "stutter" benchmark which
measures the latency of mmap while large files are being copied. This has
been used as a proxy measure for desktop jitter while large amounts of IO
were taking place

                            4.10.0-rc7            4.10.0-rc7
                        mmots-20170209          keepawake-v1
Min         mmap      6.3847 (  0.00%)      5.9785 (  6.36%)
1st-qrtle   mmap      7.6310 (  0.00%)      7.4086 (  2.91%)
2nd-qrtle   mmap      9.9959 (  0.00%)      7.7052 ( 22.92%)
3rd-qrtle   mmap     14.8180 (  0.00%)      8.5895 ( 42.03%)
Max-90%     mmap     15.8397 (  0.00%)     13.6974 ( 13.52%)
Max-93%     mmap     16.4268 (  0.00%)     14.3175 ( 12.84%)
Max-95%     mmap     18.3295 (  0.00%)     16.9233 (  7.67%)
Max-99%     mmap     24.2042 (  0.00%)     20.6182 ( 14.82%)
Max         mmap    255.0688 (  0.00%)    265.5818 ( -4.12%)
Mean        mmap     11.2192 (  0.00%)      9.1811 ( 18.17%)

Latency is measured in milliseconds and indicates that 99% of mmap
operations complete 14.82% faster and are 18.17% faster on average with
these patches applied.

 mm/memory_hotplug.c |   2 +-
 mm/vmscan.c         | 128 +++++++++++++++++++++++++++++-----------------------
 2 files changed, 72 insertions(+), 58 deletions(-)

-- 
2.11.0

Mel Gorman (2):
  mm, vmscan: Only clear pgdat congested/dirty/writeback state when
    balanced
  mm, vmscan: Prevent kswapd sleeping prematurely due to mismatched
    classzone_idx

Shantanu Goel (1):
  mm, vmscan: fix zone balance check in prepare_kswapd_sleep

 mm/memory_hotplug.c |   2 +-
 mm/vmscan.c         | 128 +++++++++++++++++++++++++++++-----------------------
 2 files changed, 72 insertions(+), 58 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
