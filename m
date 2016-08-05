Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9360B6B025E
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:00:51 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so465031686pab.1
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:00:51 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id w10si20654554pfd.81.2016.08.05.07.09.11
        for <linux-mm@kvack.org>;
        Fri, 05 Aug 2016 07:09:21 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: optimize find_zone_movable_pfns_for_nodes to avoid unnecessary loop.
Date: Fri, 5 Aug 2016 22:04:07 +0800
Message-ID: <1470405847-53322-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

when required_kernelcore decrease to zero, we should exit the loop in time.
because It will waste time to scan the remainder node.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/page_alloc.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ea759b9..be7df17 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6093,7 +6093,7 @@ static unsigned long __init early_calculate_totalpages(void)
 		unsigned long pages = end_pfn - start_pfn;
 
 		totalpages += pages;
-		if (pages)
+		if (!node_isset(nid, node_states[N_MEMORY]) && pages)
 			node_set_state(nid, N_MEMORY);
 	}
 	return totalpages;
@@ -6115,6 +6115,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	unsigned long totalpages = early_calculate_totalpages();
 	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
 	struct memblock_region *r;
+	bool avoid_loop = false;
 
 	/* Need to find movable_zone earlier when movable_node is specified. */
 	find_usable_zone_for_movable();
@@ -6275,6 +6276,8 @@ restart:
 			required_kernelcore -= min(required_kernelcore,
 								size_pages);
 			kernelcore_remaining -= size_pages;
+			if (!required_kernelcore && avoid_loop)
+				goto out2;
 			if (!kernelcore_remaining)
 				break;
 		}
@@ -6287,9 +6290,10 @@ restart:
 	 * satisfied
 	 */
 	usable_nodes--;
-	if (usable_nodes && required_kernelcore > usable_nodes)
+	if (usable_nodes && required_kernelcore > usable_nodes) {
+		avoid_loop = true;
 		goto restart;
-
+	}
 out2:
 	/* Align start of ZONE_MOVABLE on all nids to MAX_ORDER_NR_PAGES */
 	for (nid = 0; nid < MAX_NUMNODES; nid++)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
