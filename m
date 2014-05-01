Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1966F6B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 04:44:52 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e53so2051770eek.39
        for <linux-mm@kvack.org>; Thu, 01 May 2014 01:44:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i49si33494361eem.252.2014.05.01.01.44.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 01:44:51 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/17] Misc page alloc, shmem, mark_page_accessed and page_waitqueue optimisations
Date: Thu,  1 May 2014 09:44:31 +0100
Message-Id: <1398933888-4940-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>

I was investigating a performance bug that looked like dd to tmpfs
had regressed.  The bulk of the problem turned out to be a difference
in Kconfig but it got me looking at the unnecessary overhead in tmpfs,
mark_page_accessed and parts of the allocator. This series is the result.

The patches themselves have details of the performance results but here
are some of the results based on ext4. This is the result of dd'ing to
a file multiple times on tmpfs

loopdd Throughput
                     3.15.0-rc3            3.15.0-rc3
                        vanilla        lockpage-v2r33
Min         4096.0000 (  0.00%)   3891.2000 ( -5.00%)
Mean        4840.1067 (  0.00%)   5154.1333 (  6.49%)
TrimMean    4867.6571 (  0.00%)   5204.1143 (  6.91%)
Stddev       160.6807 (  0.00%)    275.1917 ( 71.27%)
Max         5017.6000 (  0.00%)   5324.8000 (  6.12%)

loopdd elapsed time
                            3.15.0-rc3            3.15.0-rc3
                               vanilla        lockpage-v2r33
Min      elapsed      0.4100 (  0.00%)      0.3900 (  4.88%)
Mean     elapsed      0.4780 (  0.00%)      0.4203 ( 12.06%)
TrimMean elapsed      0.4796 (  0.00%)      0.4179 ( 12.88%)
Stddev   elapsed      0.0353 (  0.00%)      0.0379 ( -7.23%)
Max      elapsed      0.5100 (  0.00%)      0.4800 (  5.88%)

This table shows the latency in usecs of accessing ext4-backed
mappings of various sizes

lat_mmap
                       3.15.0-rc3            3.15.0-rc3
                          vanilla        lockpage-v2r33
Procs 107M     557.0000 (  0.00%)    544.0000 (  2.33%)
Procs 214M    1150.0000 (  0.00%)   1058.0000 (  8.00%)
Procs 322M    1897.0000 (  0.00%)   1554.0000 ( 18.08%)
Procs 429M    2188.0000 (  0.00%)   2652.0000 (-21.21%)
Procs 536M    2622.0000 (  0.00%)   2473.0000 (  5.68%)
Procs 644M    3065.0000 (  0.00%)   2486.0000 ( 18.89%)
Procs 751M    3400.0000 (  0.00%)   3012.0000 ( 11.41%)
Procs 859M    3996.0000 (  0.00%)   3926.0000 (  1.75%)
Procs 966M    4646.0000 (  0.00%)   3763.0000 ( 19.01%)
Procs 1073M   4981.0000 (  0.00%)   4154.0000 ( 16.60%)
Procs 1181M   5419.0000 (  0.00%)   5152.0000 (  4.93%)
Procs 1288M   5553.0000 (  0.00%)   5538.0000 (  0.27%)
Procs 1395M   5841.0000 (  0.00%)   5730.0000 (  1.90%)
Procs 1503M   6225.0000 (  0.00%)   5981.0000 (  3.92%)
Procs 1610M   6558.0000 (  0.00%)   6332.0000 (  3.45%)
Procs 1717M   7130.0000 (  0.00%)   6741.0000 (  5.46%)
Procs 1825M   9394.0000 (  0.00%)   8483.0000 (  9.70%)
Procs 1932M   8056.0000 (  0.00%)   9427.0000 (-17.02%)
Procs 2040M   8463.0000 (  0.00%)   9030.0000 ( -6.70%)
Procs 2147M   9014.0000 (  0.00%)   8608.0000 (  4.50%)

In general the system CPU overhead is lower.

 arch/tile/mm/homecache.c        |   2 +-
 fs/btrfs/extent_io.c            |  11 +-
 fs/btrfs/file.c                 |   5 +-
 fs/buffer.c                     |   7 +-
 fs/ext4/mballoc.c               |  14 +-
 fs/f2fs/checkpoint.c            |   3 -
 fs/f2fs/node.c                  |   2 -
 fs/fuse/dev.c                   |   2 +-
 fs/fuse/file.c                  |   2 -
 fs/gfs2/aops.c                  |   1 -
 fs/gfs2/meta_io.c               |   4 +-
 fs/ntfs/attrib.c                |   1 -
 fs/ntfs/file.c                  |   1 -
 include/linux/cpuset.h          |  31 +++++
 include/linux/gfp.h             |   4 +-
 include/linux/mmzone.h          |  22 ++-
 include/linux/page-flags.h      |  18 +++
 include/linux/pageblock-flags.h |  34 ++++-
 include/linux/pagemap.h         | 115 ++++++++++++++--
 include/linux/swap.h            |   9 +-
 kernel/cpuset.c                 |   8 +-
 kernel/sched/wait.c             |   3 +-
 mm/filemap.c                    | 292 ++++++++++++++++++++++------------------
 mm/page_alloc.c                 | 226 ++++++++++++++++++-------------
 mm/shmem.c                      |   8 +-
 mm/swap.c                       |  17 ++-
 mm/swap_state.c                 |   2 +-
 mm/vmscan.c                     |   6 +-
 28 files changed, 556 insertions(+), 294 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
