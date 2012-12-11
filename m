Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 365566B0074
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 23:57:53 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v3 4/5][RESEND] page_alloc: Make movablecore_map has higher priority
Date: Tue, 11 Dec 2012 12:56:57 +0800
Message-Id: <1355201817-27230-1-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1355193207-21797-5-git-send-email-tangchen@cn.fujitsu.com>
References: <1355193207-21797-5-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

If kernelcore or movablecore is specified at the same time
with movablecore_map, movablecore_map will have higher
priority to be satisfied.
This patch will make find_zone_movable_pfns_for_nodes()
calculate zone_movable_pfn[] with the limit from
zone_movable_limit[].

change log:
Move find_usable_zone_for_movable() to free_area_init_nodes()
so that sanitize_zone_movable_limit() in patch 3 could use
initialized movable_zone.

Reported-by: Wu Jianguo <wujianguo@huawei.com>

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
Reviewed-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 mm/page_alloc.c |   28 +++++++++++++++++++++++++---
 1 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 52c368e..00fa67d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4839,9 +4839,17 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		required_kernelcore = max(required_kernelcore, corepages);
 	}
 
-	/* If kernelcore was not specified, there is no ZONE_MOVABLE */
-	if (!required_kernelcore)
+	/*
+	 * If neither kernelcore/movablecore nor movablecore_map is specified,
+	 * there is no ZONE_MOVABLE. But if movablecore_map is specified, the
+	 * start pfn of ZONE_MOVABLE has been stored in zone_movable_limit[].
+	 */
+	if (!required_kernelcore) {
+		if (movablecore_map.nr_map)
+			memcpy(zone_movable_pfn, zone_movable_limit,
+				sizeof(zone_movable_pfn));
 		goto out;
+	}
 
 	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
 	usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
@@ -4871,10 +4879,24 @@ restart:
 		for_each_mem_pfn_range(i, nid, &start_pfn, &end_pfn, NULL) {
 			unsigned long size_pages;
 
+			/*
+			 * Find more memory for kernelcore in
+			 * [zone_movable_pfn[nid], zone_movable_limit[nid]).
+			 */
 			start_pfn = max(start_pfn, zone_movable_pfn[nid]);
 			if (start_pfn >= end_pfn)
 				continue;
 
+			if (zone_movable_limit[nid]) {
+				end_pfn = min(end_pfn, zone_movable_limit[nid]);
+				/* No range left for kernelcore in this node */
+				if (start_pfn >= end_pfn) {
+					zone_movable_pfn[nid] =
+							zone_movable_limit[nid];
+					break;
+				}
+			}
+
 			/* Account for what is only usable for kernelcore */
 			if (start_pfn < usable_startpfn) {
 				unsigned long kernel_pages;
@@ -4934,12 +4956,12 @@ restart:
 	if (usable_nodes && required_kernelcore > usable_nodes)
 		goto restart;
 
+out:
 	/* Align start of ZONE_MOVABLE on all nids to MAX_ORDER_NR_PAGES */
 	for (nid = 0; nid < MAX_NUMNODES; nid++)
 		zone_movable_pfn[nid] =
 			roundup(zone_movable_pfn[nid], MAX_ORDER_NR_PAGES);
 
-out:
 	/* restore the node_state */
 	node_states[N_HIGH_MEMORY] = saved_node_state;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
