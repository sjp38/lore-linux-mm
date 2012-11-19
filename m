Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 2079A6B0073
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 10:49:37 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 4/5] page_alloc: Make movablecore_map has higher priority.
Date: Mon, 19 Nov 2012 22:27:25 +0800
Message-Id: <1353335246-9127-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1353335246-9127-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1353335246-9127-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tangchen@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, rob@landley.net, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, yinghai@kernel.org, rusty@rustcorp.com.au
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

If kernelcore or movablecore is specified at the same time with movablecore_map,
movablecore_map will have higher priority to be satisfied.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 mm/page_alloc.c |   29 +++++++++++++++++++++++++++--
 1 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ae29970..c8dfb1e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4774,7 +4774,7 @@ static unsigned long __init early_calculate_totalpages(void)
 static void __init find_zone_movable_pfns_for_nodes(void)
 {
 	int i, nid;
-	unsigned long usable_startpfn;
+	unsigned long usable_startpfn, node_movable_limit;
 	unsigned long kernelcore_node, kernelcore_remaining;
 	/* save the state before borrow the nodemask */
 	nodemask_t saved_node_state = node_states[N_HIGH_MEMORY];
@@ -4803,7 +4803,6 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		required_kernelcore = max(required_kernelcore, corepages);
 	}
 
-	/* If kernelcore was not specified, there is no ZONE_MOVABLE */
 	if (!required_kernelcore)
 		goto out;
 
@@ -4817,6 +4816,9 @@ restart:
 	for_each_node_state(nid, N_HIGH_MEMORY) {
 		unsigned long start_pfn, end_pfn;
 
+		node_movable_limit = zone_movable_pfn[nid];
+		zone_movable_pfn[nid] = 0;
+
 		/*
 		 * Recalculate kernelcore_node if the division per node
 		 * now exceeds what is necessary to satisfy the requested
@@ -4840,6 +4842,29 @@ restart:
 			if (start_pfn >= end_pfn)
 				continue;
 
+			/*
+			 * If movablecore_map was specified with kernelcore
+			 * or movablecore, it will have higher priority to be
+			 * satisfied.
+			 */
+			if (start_pfn >= node_movable_limit) {
+				/*
+				 * Here, we meet the ZONE_MOVABLE boundary
+				 * specified by movablecore_map. We should
+				 * not spread any more, but keep the rest
+				 * of kernelcore_remaining and break out.
+				 * And also, usable_nodes should be decreased.
+				 */
+				usable_nodes--;
+				break;
+			}
+
+			/*
+			 * If ZONE_MOVABLE start_pfn is in the range, we need
+			 * to shrink end_pfn to ZONE_MOVABLE start_pfn.
+			 */
+			end_pfn = min(end_pfn, node_movable_limit);
+
 			/* Account for what is only usable for kernelcore */
 			if (start_pfn < usable_startpfn) {
 				unsigned long kernel_pages;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
