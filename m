Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 852026B0413
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 02:56:59 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g8so18696515wmg.7
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 23:56:59 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id 135si3232814wmh.53.2017.03.08.23.56.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 23:56:58 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id AC7AE99476
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 07:56:57 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/3] Reduce amount of time kswapd sleeps prematurely v2
Date: Thu,  9 Mar 2017 07:56:54 +0000
Message-Id: <20170309075657.25121-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Changelog since v1
o Rebase to 4.11-rc1
o Add small clarifying comment based on review

The series is unusual in that the first patch fixes one problem and
introduces of other issues that are noted in the changelog. Patch 2 makes
a minor modification that is worth considering on its own but leaves the
kernel in a state where it behaves badly. It's not until patch 3 that
there is an improvement against baseline.

This was mostly motivated by examining Chris Mason's "simoop" benchmark
which puts the VM under similar pressure to HADOOP. It has been reported
that the benchmark has regressed severely during the last number of
releases. While I cannot reproduce all the same problems Chris experienced
due to hardware limitations, there was a number of problems on a 2-socket
machine with a single disk.

simoop latencies
                                         4.11.0-rc1            4.11.0-rc1
                                            vanilla          keepawake-v2
Amean    p50-Read             21670074.18 (  0.00%) 22668332.52 ( -4.61%)
Amean    p95-Read             25456267.64 (  0.00%) 26738688.00 ( -5.04%)
Amean    p99-Read             29369064.73 (  0.00%) 30991404.52 ( -5.52%)
Amean    p50-Write                1390.30 (  0.00%)      924.91 ( 33.47%)
Amean    p95-Write              412901.57 (  0.00%)     1362.62 ( 99.67%)
Amean    p99-Write             6668722.09 (  0.00%)    16854.04 ( 99.75%)
Amean    p50-Allocation          78714.31 (  0.00%)    74729.74 (  5.06%)
Amean    p95-Allocation         175533.51 (  0.00%)   101609.74 ( 42.11%)
Amean    p99-Allocation         247003.02 (  0.00%)   125765.57 ( 49.08%)

These are latencies. Read/write are threads reading fixed-size random blocks
from a simulated database. The allocation latency is mmaping and faulting
regions of memory. The p50, 95 and p99 reports the worst latencies for 50%
of the samples, 95% and 99% respectively.

For example, the report indicates that while the test was running 99% of
writes completed 99.75% faster. It's worth noting that on a UMA machine that
no difference in performance with simoop was observed so milage will vary.

It's noted that there is a slight impact to read latencies but it's mostly
due to IO scheduler decisions and offset by the large reduction in other
latencies.

 mm/memory_hotplug.c |   2 +-
 mm/vmscan.c         | 136 ++++++++++++++++++++++++++++++----------------------
 2 files changed, 79 insertions(+), 59 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
