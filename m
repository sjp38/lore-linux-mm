Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CC53E6B0055
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 12:28:08 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 09 Sep 2009 12:31:33 -0400
Message-Id: <20090909163133.12963.94488.sendpatchset@localhost.localdomain>
In-Reply-To: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
Subject: [PATCH 1/6] hugetlb:  rework hstate_next_node_* functions
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 1/6] hugetlb:  rework hstate_next_node* functions

Against:  2.6.31-rc7-mmotm-090827-1651

V2: + cleaned up comments, removed some deemed unnecessary,
      add some suggested by review
    + removed check for !current in huge_mpol_nodes_allowed().
    + added 'current->comm' to warning message in huge_mpol_nodes_allowed().
    + added VM_BUG_ON() assertion in hugetlb.c next_node_allowed() to
      catch out of range node id.
    + add examples to patch description

V3: + factored this "cleanup" patch out of V2 patch 2/3
    + moved ahead of patch to add nodes_allowed mask to alloc funcs
      as this patch is somewhat independent from using task mempolicy
      to control huge page allocation and freeing.

Modify the hstate_next_node* functions to allow them to be called to
obtain the "start_nid".  Then, whereas prior to this patch we
unconditionally called hstate_next_node_to_{alloc|free}(), whether
or not we successfully allocated/freed a huge page on the node,
now we only call these functions on failure to alloc/free to advance
to next allowed node.

Factor out the next_node_allowed() function to handle wrap at end
of node_online_map.  In this version, the allowed nodes include all 
of the online nodes.

Acked-by: David Rientjes <rientjes@google.com>
Reviewed-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/hugetlb.c |   70 +++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 45 insertions(+), 25 deletions(-)

Index: linux-2.6.31-rc7-mmotm-090827-1651/mm/hugetlb.c
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-1651.orig/mm/hugetlb.c	2009-09-09 11:57:32.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-1651/mm/hugetlb.c	2009-09-09 11:57:34.000000000 -0400
@@ -622,6 +622,20 @@ static struct page *alloc_fresh_huge_pag
 }
 
 /*
+ * common helper function for hstate_next_node_to_{alloc|free}.
+ * return next node in node_online_map, wrapping at end.
+ */
+static int next_node_allowed(int nid)
+{
+	nid = next_node(nid, node_online_map);
+	if (nid == MAX_NUMNODES)
+		nid = first_node(node_online_map);
+	VM_BUG_ON(nid >= MAX_NUMNODES);
+
+	return nid;
+}
+
+/*
  * Use a helper variable to find the next node and then
  * copy it back to next_nid_to_alloc afterwards:
  * otherwise there's a window in which a racer might
@@ -634,12 +648,12 @@ static struct page *alloc_fresh_huge_pag
  */
 static int hstate_next_node_to_alloc(struct hstate *h)
 {
-	int next_nid;
-	next_nid = next_node(h->next_nid_to_alloc, node_online_map);
-	if (next_nid == MAX_NUMNODES)
-		next_nid = first_node(node_online_map);
+	int nid, next_nid;
+
+	nid = h->next_nid_to_alloc;
+	next_nid = next_node_allowed(nid);
 	h->next_nid_to_alloc = next_nid;
-	return next_nid;
+	return nid;
 }
 
 static int alloc_fresh_huge_page(struct hstate *h)
@@ -649,15 +663,17 @@ static int alloc_fresh_huge_page(struct
 	int next_nid;
 	int ret = 0;
 
-	start_nid = h->next_nid_to_alloc;
+	start_nid = hstate_next_node_to_alloc(h);
 	next_nid = start_nid;
 
 	do {
 		page = alloc_fresh_huge_page_node(h, next_nid);
-		if (page)
+		if (page) {
 			ret = 1;
+			break;
+		}
 		next_nid = hstate_next_node_to_alloc(h);
-	} while (!page && next_nid != start_nid);
+	} while (next_nid != start_nid);
 
 	if (ret)
 		count_vm_event(HTLB_BUDDY_PGALLOC);
@@ -668,17 +684,19 @@ static int alloc_fresh_huge_page(struct
 }
 
 /*
- * helper for free_pool_huge_page() - find next node
- * from which to free a huge page
+ * helper for free_pool_huge_page() - return the next node
+ * from which to free a huge page.  Advance the next node id
+ * whether or not we find a free huge page to free so that the
+ * next attempt to free addresses the next node.
  */
 static int hstate_next_node_to_free(struct hstate *h)
 {
-	int next_nid;
-	next_nid = next_node(h->next_nid_to_free, node_online_map);
-	if (next_nid == MAX_NUMNODES)
-		next_nid = first_node(node_online_map);
+	int nid, next_nid;
+
+	nid = h->next_nid_to_free;
+	next_nid = next_node_allowed(nid);
 	h->next_nid_to_free = next_nid;
-	return next_nid;
+	return nid;
 }
 
 /*
@@ -693,7 +711,7 @@ static int free_pool_huge_page(struct hs
 	int next_nid;
 	int ret = 0;
 
-	start_nid = h->next_nid_to_free;
+	start_nid = hstate_next_node_to_free(h);
 	next_nid = start_nid;
 
 	do {
@@ -715,9 +733,10 @@ static int free_pool_huge_page(struct hs
 			}
 			update_and_free_page(h, page);
 			ret = 1;
+			break;
 		}
 		next_nid = hstate_next_node_to_free(h);
-	} while (!ret && next_nid != start_nid);
+	} while (next_nid != start_nid);
 
 	return ret;
 }
@@ -1028,10 +1047,9 @@ int __weak alloc_bootmem_huge_page(struc
 		void *addr;
 
 		addr = __alloc_bootmem_node_nopanic(
-				NODE_DATA(h->next_nid_to_alloc),
+				NODE_DATA(hstate_next_node_to_alloc(h)),
 				huge_page_size(h), huge_page_size(h), 0);
 
-		hstate_next_node_to_alloc(h);
 		if (addr) {
 			/*
 			 * Use the beginning of the huge page to store the
@@ -1167,29 +1185,31 @@ static int adjust_pool_surplus(struct hs
 	VM_BUG_ON(delta != -1 && delta != 1);
 
 	if (delta < 0)
-		start_nid = h->next_nid_to_alloc;
+		start_nid = hstate_next_node_to_alloc(h);
 	else
-		start_nid = h->next_nid_to_free;
+		start_nid = hstate_next_node_to_free(h);
 	next_nid = start_nid;
 
 	do {
 		int nid = next_nid;
 		if (delta < 0)  {
-			next_nid = hstate_next_node_to_alloc(h);
 			/*
 			 * To shrink on this node, there must be a surplus page
 			 */
-			if (!h->surplus_huge_pages_node[nid])
+			if (!h->surplus_huge_pages_node[nid]) {
+				next_nid = hstate_next_node_to_alloc(h);
 				continue;
+			}
 		}
 		if (delta > 0) {
-			next_nid = hstate_next_node_to_free(h);
 			/*
 			 * Surplus cannot exceed the total number of pages
 			 */
 			if (h->surplus_huge_pages_node[nid] >=
-						h->nr_huge_pages_node[nid])
+						h->nr_huge_pages_node[nid]) {
+				next_nid = hstate_next_node_to_free(h);
 				continue;
+			}
 		}
 
 		h->surplus_huge_pages += delta;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
