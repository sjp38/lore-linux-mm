Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 700A28D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 13:52:53 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 1/3] move scan_control definition to header file
Date: Tue, 19 Apr 2011 10:51:34 -0700
Message-Id: <1303235496-3060-2-git-send-email-yinghan@google.com>
In-Reply-To: <1303235496-3060-1-git-send-email-yinghan@google.com>
References: <1303235496-3060-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This patch moves the scan_control definition from vmscan to swap.h
header file, which is needed later to pass the struct to shrinkers.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/swap.h |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c          |   61 --------------------------------------------------
 2 files changed, 61 insertions(+), 61 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index ed6ebe6..cb48fbd 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -16,6 +16,67 @@ struct notifier_block;
 
 struct bio;
 
+/*
+ * reclaim_mode determines how the inactive list is shrunk
+ * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
+ * RECLAIM_MODE_ASYNC:  Do not block
+ * RECLAIM_MODE_SYNC:   Allow blocking e.g. call wait_on_page_writeback
+ * RECLAIM_MODE_LUMPYRECLAIM: For high-order allocations, take a reference
+ *			page from the LRU and reclaim all pages within a
+ *			naturally aligned range
+ * RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a number of
+ *			order-0 pages and then compact the zone
+ */
+typedef unsigned __bitwise__ reclaim_mode_t;
+#define RECLAIM_MODE_SINGLE		((__force reclaim_mode_t)0x01u)
+#define RECLAIM_MODE_ASYNC		((__force reclaim_mode_t)0x02u)
+#define RECLAIM_MODE_SYNC		((__force reclaim_mode_t)0x04u)
+#define RECLAIM_MODE_LUMPYRECLAIM	((__force reclaim_mode_t)0x08u)
+#define RECLAIM_MODE_COMPACTION		((__force reclaim_mode_t)0x10u)
+
+struct scan_control {
+	/* Incremented by the number of inactive pages that were scanned */
+	unsigned long nr_scanned;
+
+	/* Number of pages freed so far during a call to shrink_zones() */
+	unsigned long nr_reclaimed;
+
+	/* How many pages shrink_list() should reclaim */
+	unsigned long nr_to_reclaim;
+
+	unsigned long hibernation_mode;
+
+	/* This context's GFP mask */
+	gfp_t gfp_mask;
+
+	int may_writepage;
+
+	/* Can mapped pages be reclaimed? */
+	int may_unmap;
+
+	/* Can pages be swapped as part of reclaim? */
+	int may_swap;
+
+	int swappiness;
+
+	int order;
+
+	/*
+	 * Intend to reclaim enough continuous memory rather than reclaim
+	 * enough amount of memory. i.e, mode for high order allocation.
+	 */
+	reclaim_mode_t reclaim_mode;
+
+	/* Which cgroup do we reclaim from */
+	struct mem_cgroup *mem_cgroup;
+
+	/*
+	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
+	 * are scanned.
+	 */
+	nodemask_t	*nodemask;
+};
+
 #define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
 #define SWAP_FLAG_PRIO_MASK	0x7fff
 #define SWAP_FLAG_PRIO_SHIFT	0
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 060e4c1..08b1ab5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -52,67 +52,6 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/vmscan.h>
 
-/*
- * reclaim_mode determines how the inactive list is shrunk
- * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
- * RECLAIM_MODE_ASYNC:  Do not block
- * RECLAIM_MODE_SYNC:   Allow blocking e.g. call wait_on_page_writeback
- * RECLAIM_MODE_LUMPYRECLAIM: For high-order allocations, take a reference
- *			page from the LRU and reclaim all pages within a
- *			naturally aligned range
- * RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a number of
- *			order-0 pages and then compact the zone
- */
-typedef unsigned __bitwise__ reclaim_mode_t;
-#define RECLAIM_MODE_SINGLE		((__force reclaim_mode_t)0x01u)
-#define RECLAIM_MODE_ASYNC		((__force reclaim_mode_t)0x02u)
-#define RECLAIM_MODE_SYNC		((__force reclaim_mode_t)0x04u)
-#define RECLAIM_MODE_LUMPYRECLAIM	((__force reclaim_mode_t)0x08u)
-#define RECLAIM_MODE_COMPACTION		((__force reclaim_mode_t)0x10u)
-
-struct scan_control {
-	/* Incremented by the number of inactive pages that were scanned */
-	unsigned long nr_scanned;
-
-	/* Number of pages freed so far during a call to shrink_zones() */
-	unsigned long nr_reclaimed;
-
-	/* How many pages shrink_list() should reclaim */
-	unsigned long nr_to_reclaim;
-
-	unsigned long hibernation_mode;
-
-	/* This context's GFP mask */
-	gfp_t gfp_mask;
-
-	int may_writepage;
-
-	/* Can mapped pages be reclaimed? */
-	int may_unmap;
-
-	/* Can pages be swapped as part of reclaim? */
-	int may_swap;
-
-	int swappiness;
-
-	int order;
-
-	/*
-	 * Intend to reclaim enough continuous memory rather than reclaim
-	 * enough amount of memory. i.e, mode for high order allocation.
-	 */
-	reclaim_mode_t reclaim_mode;
-
-	/* Which cgroup do we reclaim from */
-	struct mem_cgroup *mem_cgroup;
-
-	/*
-	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
-	 * are scanned.
-	 */
-	nodemask_t	*nodemask;
-};
-
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 #ifdef ARCH_HAS_PREFETCH
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
