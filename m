Date: Thu, 10 Nov 2005 15:27:12 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] dequeue a huge page near to this node
Message-ID: <Pine.LNX.4.62.0511101521180.16770@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kenneth.w.chen@intel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

The following patch changes the dequeueing to select a huge page near
the node executing instead of always beginning to check for free 
nodes from node 0. This will result in a placement of the huge pages near
the executing processor improving performance.

The existing implementation can place the huge pages far away from 
the executing processor causing significant degradation of performance.
The search starting from zero also means that the lower zones quickly 
run out of memory. Selecting a huge page near the process distributed the 
huge pages better.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-mm1/mm/hugetlb.c
===================================================================
--- linux-2.6.14-mm1.orig/mm/hugetlb.c	2005-11-09 10:47:37.000000000 -0800
+++ linux-2.6.14-mm1/mm/hugetlb.c	2005-11-10 15:02:05.000000000 -0800
@@ -36,14 +36,16 @@ static struct page *dequeue_huge_page(vo
 {
 	int nid = numa_node_id();
 	struct page *page = NULL;
+	struct zonelist *zonelist = NODE_DATA(nid)->node_zonelists;
+	struct zone **z;
 
-	if (list_empty(&hugepage_freelists[nid])) {
-		for (nid = 0; nid < MAX_NUMNODES; ++nid)
-			if (!list_empty(&hugepage_freelists[nid]))
-				break;
+	for (z = zonelist->zones; *z; z++) {
+		nid = (*z)->zone_pgdat->node_id;
+		if (!list_empty(&hugepage_freelists[nid]))
+			break;
 	}
-	if (nid >= 0 && nid < MAX_NUMNODES &&
-	    !list_empty(&hugepage_freelists[nid])) {
+
+	if (z) {
 		page = list_entry(hugepage_freelists[nid].next,
 				  struct page, lru);
 		list_del(&page->lru);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
