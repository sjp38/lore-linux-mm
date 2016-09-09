Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 67CD86B0261
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 05:59:45 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id s64so42336659lfs.1
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 02:59:45 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id ty2si2229214wjb.223.2016.09.09.02.59.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 02:59:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 16111989D7
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 09:59:37 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 4/4] mm, vmscan: Potentially stall direct reclaimers on tree_lock contention
Date: Fri,  9 Sep 2016 10:59:35 +0100
Message-Id: <1473415175-20807-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
References: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Chinner <david@fromorbit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>

If a heavy writer of a single file is forcing contention on the tree_lock
then it may be necessary to tempoarily stall the direct writer to allow
kswapd to make progress. This patch marks a pgdat congested if tree_lock
is being contended on the tail of the LRU.

On a swap-intensive workload to ramdisk, the following is observed

usemem
                              4.8.0-rc5             4.8.0-rc5
                           waitqueue-v1      directcongest-v1
Amean    System-1      179.61 (  0.00%)      202.21 (-12.58%)
Amean    System-3       68.91 (  0.00%)      105.14 (-52.59%)
Amean    System-5       93.09 (  0.00%)       80.98 ( 13.01%)
Amean    System-7       90.98 (  0.00%)       81.07 ( 10.90%)
Amean    System-8      299.81 (  0.00%)      227.08 ( 24.26%)
Amean    Elapsd-1      210.41 (  0.00%)      236.56 (-12.43%)
Amean    Elapsd-3       33.89 (  0.00%)       46.78 (-38.06%)
Amean    Elapsd-5       25.19 (  0.00%)       23.33 (  7.38%)
Amean    Elapsd-7       18.45 (  0.00%)       17.18 (  6.91%)
Amean    Elapsd-8       48.80 (  0.00%)       38.09 ( 21.93%)

Note that system CPU usage is reduced for high thread counts but it
is not a universal win and it's known to be highly variable. The
overall time stats look like

           4.8.0-rc5   4.8.0-rc5
        waitqueue-v1 directcongest-v1
User          462.40      468.18
System       5127.32     4875.92
Elapsed      2364.08     2539.77

It takes longer to complete but uses less system CPU. The benefit
is more noticable with xfs_io rewriting a file backed by ramdisk

                                                        4.8.0-rc5             4.8.0-rc5
                                                  waitqueue-v1r24   directcongest-v1r24
Amean    pwrite-single-rewrite-async-System        3.23 (  0.00%)        3.21 (  0.80%)
Amean    pwrite-single-rewrite-async-Elapsd        3.33 (  0.00%)        3.31 (  0.67%)

           4.8.0-rc5   4.8.0-rc5
        waitqueue-v1 directcongest-v1
User            8.76        9.25
System        392.31      389.10
Elapsed       406.29      403.74

As with the previous patch, a test from Dave Chinner would be necessary
to decide whether this patch is worthwhile. It seems reasonable to favour
workloads that are heavily writing files than heavily swapping as the
former situation is normal and reasonable while the latter situation will
never be optimal.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 936070b0790e..953df97abe0c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -771,6 +771,15 @@ static unsigned long remove_mapping_list(struct list_head *mapping_list,
 					/* Stall kswapd once for 10ms on contention */
 					if (cmpxchg(&kswapd_exclusive, NUMA_NO_NODE, pgdat->node_id) != NUMA_NO_NODE) {
 						DEFINE_WAIT(wait);
+
+						/*
+						 * Tag the pgdat as congested as it may
+						 * indicate contention with a heavy
+						 * writer that should stall on
+						 * wait_iff_congested.
+						 */
+						set_bit(PGDAT_CONGESTED, &pgdat->flags);
+
 						prepare_to_wait(&kswapd_contended_wait,
 							&wait, TASK_INTERRUPTIBLE);
 						io_schedule_timeout(HZ/100);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
