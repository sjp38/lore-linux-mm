Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D333B6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:47:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q75so17438437pfl.1
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 01:47:40 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.125])
        by mx.google.com with ESMTPS id 60si1418902ple.818.2017.09.26.01.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 01:47:39 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 0/2] Use HighAtomic against long-term fragmentation
Date: Tue, 26 Sep 2017 16:46:42 +0800
Message-ID: <1506415604-4310-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

Current HighAtomic just to handle the high atomic page alloc.
But I found that use it handle the normal unmovable continuous page
alloc will help to against long-term fragmentation.

Use highatomic as normal page alloc is odd.  But I really got some good
results with our internal test and mmtests.

Do you think it is worth to work on it?

The patches was tested with mmtests stress-highalloc modified to do
GFP_KERNEL order-4 allocations, on 4.14.0-rc1+ 2 cpus Vbox 1G memory.
                                  orig          ch
Minor Faults                  45659477    43315623
Major Faults                       319         371
Swap Ins                             0           0
Swap Outs                            0           0
Allocation stalls                    0           0
DMA allocs                       93518       18345
DMA32 allocs                  42395699    40406865
Normal allocs                        0           0
Movable allocs                       0           0
Direct pages scanned              7056       16232
Kswapd pages scanned            946174      961750
Kswapd pages reclaimed          945077      942821
Direct pages reclaimed            7022       16170
Kswapd efficiency                  99%         98%
Kswapd velocity               1576.352    1567.977
Direct efficiency                  99%         99%
Direct velocity                 11.755      26.464
Percentage direct scans             0%          1%
Zone normal velocity          1588.108    1594.441
Zone dma32 velocity              0.000       0.000
Zone dma velocity                0.000       0.000
Page writes by reclaim           0.000       0.000
Page writes file                     0           0
Page writes anon                     0           0
Page reclaim immediate             405       16429
Sector Reads                   2027848     2109324
Sector Writes                  3386260     3299388
Page rescued immediate               0           0
Slabs scanned                   867805      877005
Direct inode steals                337        2072
Kswapd inode steals              33911       41777
Kswapd skipped wait                  0           0
THP fault alloc                     30          84
THP collapse alloc                 188         244
THP splits                           0           0
THP fault fallback                  67          51
THP collapse fail                    6           4
Compaction stalls                  111          49
Compaction success                  81          35
Compaction failures                 30          14
Page migrate success             57962       43921
Page migrate failure                67         183
Compaction pages isolated       117473       88823
Compaction migrate scanned       75548       50403
Compaction free scanned        1454638      672310
Compaction cost                     62          47
NUMA alloc hit                42129493    40018326
NUMA alloc miss                      0           0
NUMA interleave hit                  0           0
NUMA alloc local              42129493    40018326
NUMA base PTE updates                0           0
NUMA huge PMD updates                0           0
NUMA page range updates              0           0
NUMA hint faults                     0           0
NUMA hint local faults               0           0
NUMA hint local percent            100         100
NUMA pages migrated                  0           0
AutoNUMA cost                       0%          0%

Hui Zhu (2):
Try to use HighAtomic if try to alloc umovable page that order is not 0
Change limit of HighAtomic from 1% to 10%

 page_alloc.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
