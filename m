Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D46C26B00EE
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 11:21:44 -0400 (EDT)
From: Alex Shi <alex.shi@intel.com>
Subject: [PATCH] kswapd: avoid unnecessary rebalance after an unsuccessful balancing
Date: Fri, 29 Jul 2011 23:23:10 +0800
Message-Id: <1311952990-3844-1-git-send-email-alex.shi@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, P@draigBrady.com
Cc: mgorman@suse.de, linux-kernel@vger.kernel.org, andrea@cpushare.com, tim.c.chen@intel.com, shaohua.li@intel.com, akpm@linux-foundation.org, riel@redhat.com, luto@mit.edu

In commit 215ddd66, Mel Gorman said kswapd is better to sleep after a
unsuccessful balancing if there is tighter reclaim request pending in
the balancing. In this scenario, the 'order' and 'classzone_idx'
that are checked for tighter request judgment is incorrect, since they
aren't the one kswapd should read from new pgdat, but the last time pgdat
value for just now balancing. Then kswapd will skip try_to_sleep func
and rebalance the last pgdat request. It's not our expected behavior.

So, I added new variables to distinguish the returned order/classzone_idx
from last balancing, that can resolved above issue in that scenario.

I tested the patch on our LKP system with swap-cp/fio mmap randrw
benchmarks. The performance has no change.

Padraig Brady, would you like to test this patch for your scenario.

Signed-off-by: Alex Shi <alex.shi@intel.com>
Reviewed-by:  Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/vmscan.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eb7bcce..6380674 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2792,7 +2792,9 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 static int kswapd(void *p)
 {
 	unsigned long order, new_order;
+	unsigned balanced_order;
 	int classzone_idx, new_classzone_idx;
+	int balanced_classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 
@@ -2823,7 +2825,9 @@ static int kswapd(void *p)
 	set_freezable();
 
 	order = new_order = 0;
+	balanced_order = 0;
 	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
+	balanced_classzone_idx = classzone_idx;
 	for ( ; ; ) {
 		int ret;
 
@@ -2832,7 +2836,7 @@ static int kswapd(void *p)
 		 * new request of a similar or harder type will succeed soon
 		 * so consider going to sleep on the basis we reclaimed at
 		 */
-		if (classzone_idx >= new_classzone_idx && order == new_order) {
+		if (balanced_classzone_idx >= new_classzone_idx && balanced_order == new_order) {
 			new_order = pgdat->kswapd_max_order;
 			new_classzone_idx = pgdat->classzone_idx;
 			pgdat->kswapd_max_order =  0;
@@ -2847,7 +2851,7 @@ static int kswapd(void *p)
 			order = new_order;
 			classzone_idx = new_classzone_idx;
 		} else {
-			kswapd_try_to_sleep(pgdat, order, classzone_idx);
+			kswapd_try_to_sleep(pgdat, balanced_order, balanced_classzone_idx);
 			order = pgdat->kswapd_max_order;
 			classzone_idx = pgdat->classzone_idx;
 			new_order = order;
@@ -2866,7 +2870,8 @@ static int kswapd(void *p)
 		 */
 		if (!ret) {
 			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			order = balance_pgdat(pgdat, order, &classzone_idx);
+			balanced_classzone_idx = classzone_idx;
+			balanced_order = balance_pgdat(pgdat, order, &balanced_classzone_idx);
 		}
 	}
 	return 0;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
