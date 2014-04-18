Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id EC9F86B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:45 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so1681959eek.24
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w48si40531741eel.296.2014.04.18.07.50.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:44 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/16] Misc page alloc, shmem and mark_page_accessed optimisations
Date: Fri, 18 Apr 2014 15:50:27 +0100
Message-Id: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

I was investigating a performance bug that looked like dd to tmpfs
had regressed.  The bulk of the problem turned out to be a difference
in Kconfig but it got me looking at the unnecessary overhead in tmpfs,
mark_page_accessed and parts of the allocator. This series is the result.

The primary test workload was dd to a tmpfs file that was 1/10th the size
of memory so that dirty balancing and reclaim should not be factors.

loopdd Throughput
                     3.15.0-rc1            3.15.0-rc1
                        vanilla        microopt-v1r11
Min      3993.6000 (  0.00%)      4096.0000 (  2.56%)
Mean     4766.7200 (  0.00%)      4896.4267 (  2.72%)
Stddev    164.5053 (  0.00%)       167.7316 (  1.96%)
Max      4812.8000 (  0.00%)      5120.0000 (  6.38%)

Respectable increase in throughput. The figures are misleading though because
dd reports in GB/sec so there is a lot of noise. The actual time to completiono
is easier to see

loopdd Time
                         3.15.0-rc1            3.15.0-rc1
                            vanilla        microopt-v1r11
Min      time0.3521 (  0.00%)0.3317 (  5.80%)
Mean     time0.3570 (  0.00%)0.3458 (  3.14%)
Stddev   time0.0140 (  0.00%)0.0112 ( 20.59%)
Max      time0.4230 (  0.00%)0.4083 (  3.49%)

The time to dd the data is noticably reduced

          3.15.0-rc1  3.15.0-rc1
             vanillamicroopt-v1r11
User           10.86       10.78
System         70.21       67.12
Elapsed        92.43       89.42

And the system CPU overhead is lower.

A series of tests against various filesystems as well as a general
benchmark are still running but I thought I would send the series out
as-is for comment.

 Documentation/sysctl/vm.txt         |  17 ++--
 arch/ia64/include/asm/topology.h    |   3 +-
 arch/powerpc/include/asm/topology.h |   8 +-
 include/linux/cpuset.h              |  29 +++++++
 include/linux/mmzone.h              |  14 ++-
 include/linux/page-flags.h          |   2 +
 include/linux/pageblock-flags.h     |  18 +++-
 include/linux/swap.h                |   7 +-
 include/linux/topology.h            |   3 +-
 kernel/cpuset.c                     |   8 +-
 mm/filemap.c                        |  58 ++++++++-----
 mm/page_alloc.c                     | 164 ++++++++++++++++++++----------------
 mm/shmem.c                          |   8 +-
 mm/swap.c                           |  13 ++-
 14 files changed, 226 insertions(+), 126 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
