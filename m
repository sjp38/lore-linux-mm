Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA786B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 04:46:50 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r133so5924230pgr.6
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 01:46:50 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w26si5283768pfi.302.2017.08.15.01.46.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 01:46:49 -0700 (PDT)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH 0/2] Separate NUMA statistics from zone statistics
Date: Tue, 15 Aug 2017 16:45:34 +0800
Message-Id: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Kemi Wang <kemi.wang@intel.com>

Each page allocation updates a set of per-zone statistics with a call to
zone_statistics(). As discussed in 2017 MM submit, these are a substantial
source of overhead in the page allocator and are very rarely consumed. This
significant overhead in cache bouncing caused by zone counters (NUMA
associated counters) update in parallel in multi-threaded page allocation
(pointed out by Dave Hansen).

To mitigate this overhead, this patchset separates NUMA statistics from
zone statistics framework, and update NUMA counter threshold to a fixed
size of 32765, as a small threshold greatly increases the update frequency
of the global counter from local per cpu counter (suggested by Ying Huang).
The rationality is that these statistics counters don't need to be read
often, unlike other VM counters, so it's not a problem to use a large
threshold and make readers more expensive.

With this patchset, we see 26.6% drop of CPU cycles(537-->394, see below)
for per single page allocation and reclaim on Jesper's page_bench03
benchmark. Meanwhile, this patchset keeps the same style of virtual memory
statistics with little end-user-visible effects (see the first patch for
details), except that the number of NUMA items in each cpu
(vm_numa_stat_diff[]) is added to zone->vm_numa_stat[] when a user *reads*
the value of NUMA counter to eliminate deviation.

I did an experiment of single page allocation and reclaim concurrently
using Jesper's page_bench03 benchmark on a 2-Socket Broadwell-based server
(88 processors with 126G memory) with different size of threshold of pcp
counter.

Benchmark provided by Jesper D Broucer(increase loop times to 10000000):
https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/bench

   Threshold   CPU cycles    Throughput(88 threads)
      32        799         241760478
      64        640         301628829
      125       537         358906028 <==> system by default
      256       468         412397590
      512       428         450550704
      4096      399         482520943
      20000     394         489009617
      30000     395         488017817
      32765     394(-26.6%) 488932078(+36.2%) <==> with this patchset
      N/A       342(-36.3%) 562900157(+56.8%) <==> disable zone_statistics

Kemi Wang (2):
  mm: Change the call sites of numa statistics items
  mm: Update NUMA counter threshold size

 drivers/base/node.c    |  22 ++++---
 include/linux/mmzone.h |  25 +++++---
 include/linux/vmstat.h |  33 ++++++++++
 mm/page_alloc.c        |  10 +--
 mm/vmstat.c            | 162 +++++++++++++++++++++++++++++++++++++++++++++++--
 5 files changed, 227 insertions(+), 25 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
