Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2116B0260
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 05:59:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g141so10391326wmd.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 02:59:43 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id n64si2225375wmn.41.2016.09.09.02.59.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 02:59:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id DCC78989DE
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 09:59:36 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/4] mm, vmscan: Stall kswapd if contending on tree_lock
Date: Fri,  9 Sep 2016 10:59:34 +0100
Message-Id: <1473415175-20807-4-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
References: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Chinner <david@fromorbit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>

If there is a large reader/writer, it's possible for multiple kswapd instances
and the processes issueing IO to contend on a single mapping->tree_lock. This
patch will cause all kswapd instances except one to backoff if contending on
tree_lock. A sleep kswapd instance will be woken when one has made progress.

                              4.8.0-rc5             4.8.0-rc5
                       ramdisknonrot-v1          waitqueue-v1
Min      Elapsd-8       18.31 (  0.00%)       28.32 (-54.67%)
Amean    System-1      181.00 (  0.00%)      179.61 (  0.77%)
Amean    System-3       86.19 (  0.00%)       68.91 ( 20.05%)
Amean    System-5       67.43 (  0.00%)       93.09 (-38.05%)
Amean    System-7       89.55 (  0.00%)       90.98 ( -1.60%)
Amean    System-8      102.92 (  0.00%)      299.81 (-191.30%)
Amean    Elapsd-1      209.23 (  0.00%)      210.41 ( -0.57%)
Amean    Elapsd-3       36.93 (  0.00%)       33.89 (  8.25%)
Amean    Elapsd-5       19.52 (  0.00%)       25.19 (-29.08%)
Amean    Elapsd-7       21.93 (  0.00%)       18.45 ( 15.88%)
Amean    Elapsd-8       23.63 (  0.00%)       48.80 (-106.51%)

Note that unlike the previous patches that this is not an unconditional win.
System CPU usage is generally higher because direct reclaim is used instead
of multiple competing kswapd instances. According to the stats, there is
10 times more direct reclaim scanning and reclaim activity and overall
the workload takes longer to complete.

           4.8.0-rc5    4.8.0-rc5
     amdisknonrot-v1 waitqueue-v1
User          473.24       462.40
System       3690.20      5127.32
Elapsed      2186.05      2364.08

The motivation for this patch was Dave Chinner reporting that an xfs_io
workload rewriting a single file spent significant amount of time spinning
on the tree_lock. Local tests were inconclusive. On spinning storage, the
IO was so slow as it was not noticable. When xfs_io is backed by ramdisk
to simulate fast storage then it can be observed;

                                                        4.8.0-rc5             4.8.0-rc5
                                                 ramdisknonrot-v1          waitqueue-v1
Min      pwrite-single-rewrite-async-System        3.12 (  0.00%)        3.06 (  1.92%)
Min      pwrite-single-rewrite-async-Elapsd        3.25 (  0.00%)        3.17 (  2.46%)
Amean    pwrite-single-rewrite-async-System        3.32 (  0.00%)        3.23 (  2.67%)
Amean    pwrite-single-rewrite-async-Elapsd        3.42 (  0.00%)        3.33 (  2.71%)

           4.8.0-rc5    4.8.0-rc5
    ramdisknonrot-v1 waitqueue-v1
User            9.06         8.76
System        402.67       392.31
Elapsed       416.91       406.29

That's roughly a 2.5% drop in CPU usage overall. A test from Dave Chinner
with some data to support/reject this patch is highly desirable.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 32 +++++++++++++++++++++++++++++++-
 1 file changed, 31 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f7beb573a594..936070b0790e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -735,6 +735,9 @@ static enum remove_mapping __remove_mapping(struct address_space *mapping,
 	return REMOVED_FAIL;
 }
 
+static unsigned long kswapd_exclusive = NUMA_NO_NODE;
+static DECLARE_WAIT_QUEUE_HEAD(kswapd_contended_wait);
+
 static unsigned long remove_mapping_list(struct list_head *mapping_list,
 					 struct list_head *free_pages,
 					 struct list_head *ret_pages)
@@ -755,8 +758,28 @@ static unsigned long remove_mapping_list(struct list_head *mapping_list,
 
 		list_del(&page->lru);
 		if (!mapping) {
+			pg_data_t *pgdat = page_pgdat(page);
 			mapping = page_mapping(page);
-			spin_lock_irqsave(&mapping->tree_lock, flags);
+
+			/* Account for trylock contentions in kswapd */
+			if (!current_is_kswapd() ||
+			    pgdat->node_id == kswapd_exclusive) {
+				spin_lock_irqsave(&mapping->tree_lock, flags);
+			} else {
+				/* Account for contended pages and contended kswapds */
+				if (!spin_trylock_irqsave(&mapping->tree_lock, flags)) {
+					/* Stall kswapd once for 10ms on contention */
+					if (cmpxchg(&kswapd_exclusive, NUMA_NO_NODE, pgdat->node_id) != NUMA_NO_NODE) {
+						DEFINE_WAIT(wait);
+						prepare_to_wait(&kswapd_contended_wait,
+							&wait, TASK_INTERRUPTIBLE);
+						io_schedule_timeout(HZ/100);
+						finish_wait(&kswapd_contended_wait, &wait);
+					}
+
+					spin_lock_irqsave(&mapping->tree_lock, flags);
+				}
+			}
 		}
 
 		switch (__remove_mapping(mapping, page, true, &freepage)) {
@@ -3212,6 +3235,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
 {
 	unsigned long mark = high_wmark_pages(zone);
+	unsigned long nid;
 
 	if (!zone_watermark_ok_safe(zone, order, mark, classzone_idx))
 		return false;
@@ -3223,6 +3247,12 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
 	clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
 	clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
 
+	nid = zone->zone_pgdat->node_id;
+	if (nid == kswapd_exclusive) {
+		cmpxchg(&kswapd_exclusive, nid, NUMA_NO_NODE);
+		wake_up_interruptible(&kswapd_contended_wait);
+	}
+
 	return true;
 }
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
