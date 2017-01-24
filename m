Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 509006B0260
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 02:49:20 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id a29so140929985qtb.6
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 23:49:20 -0800 (PST)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id q15si12585511qtb.214.2017.01.23.23.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 23:49:19 -0800 (PST)
Received: by mail-qt0-x243.google.com with SMTP id n13so23206319qtc.0
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 23:49:19 -0800 (PST)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH RFC 2/3] mm, vmscan: limit kswapd loop if no progress is made
Date: Tue, 24 Jan 2017 15:49:03 +0800
Message-Id: <1485244144-13487-3-git-send-email-hejianet@gmail.com>
In-Reply-To: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
References: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, zhong jiang <zhongjiang@huawei.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Jia He <hejianet@gmail.com>

Currently there is no hard limitation for kswapd retry times if no progress
is made. Then kswapd will take 100% for a long time.

In my test, I tried to allocate 4000 hugepages by:
echo 4000 > /proc/sys/vm/nr_hugepages

Then,kswapd will take 100% cpu for a long time.

The numa layout is:
available: 7 nodes (0-6)
node 0 cpus: 0 1 2 3 4 5 6 7
node 0 size: 6611 MB
node 0 free: 1103 MB
node 1 cpus:
node 1 size: 12527 MB
node 1 free: 8477 MB
node 2 cpus:
node 2 size: 15087 MB
node 2 free: 11037 MB
node 3 cpus:
node 3 size: 16111 MB
node 3 free: 12060 MB
node 4 cpus: 8 9 10 11 12 13 14 15
node 4 size: 24815 MB
node 4 free: 20704 MB
node 5 cpus:
node 5 size: 4095 MB
node 5 free: 61 MB 
node 6 cpus:
node 6 size: 22750 MB
node 6 free: 18716 MB

The cause is kswapd will loop for long time even if there is no progress in
balance_pgdat.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 mm/vmscan.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 532a2a7..7396a0a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -59,6 +59,7 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/vmscan.h>
 
+#define MAX_KSWAPD_RECLAIM_RETRIES 16
 struct scan_control {
 	/* How many pages shrink_list() should reclaim */
 	unsigned long nr_to_reclaim;
@@ -3202,7 +3203,8 @@ static bool kswapd_shrink_node(pg_data_t *pgdat,
  * or lower is eligible for reclaim until at least one usable zone is
  * balanced.
  */
-static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
+static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx,
+						 int *did_some_progress)
 {
 	int i;
 	unsigned long nr_soft_reclaimed;
@@ -3322,6 +3324,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 	 * entered the allocator slow path while kswapd was awake, order will
 	 * remain at the higher level.
 	 */
+	*did_some_progress = !!(sc.nr_scanned || sc.nr_reclaimed);
 	return sc.order;
 }
 
@@ -3417,6 +3420,8 @@ static int kswapd(void *p)
 	unsigned int alloc_order, reclaim_order, classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
+	int no_progress_loops = 0;
+	int did_some_progress = 0;
 
 	struct reclaim_state reclaim_state = {
 		.reclaimed_slab = 0,
@@ -3480,9 +3485,23 @@ static int kswapd(void *p)
 		 */
 		trace_mm_vmscan_kswapd_wake(pgdat->node_id, classzone_idx,
 						alloc_order);
-		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
-		if (reclaim_order < alloc_order)
+		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx,
+						&did_some_progress);
+
+		if (reclaim_order < alloc_order) {
+			no_progress_loops = 0;
 			goto kswapd_try_sleep;
+		}
+
+		if (did_some_progress)
+			no_progress_loops = 0;
+		else
+			no_progress_loops++;
+
+		if (no_progress_loops >= MAX_KSWAPD_RECLAIM_RETRIES) {
+			no_progress_loops = 0;
+			goto kswapd_try_sleep;
+		}
 
 		alloc_order = reclaim_order = pgdat->kswapd_order;
 		classzone_idx = pgdat->kswapd_classzone_idx;
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
