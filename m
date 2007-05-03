Date: Wed, 2 May 2007 21:21:07 -0500
From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070503022107.GA13592@kryten>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, clameter@SGI.com, ak@suse.de
Cc: nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

An interesting bug was pointed out to me where we failed to allocate
hugepages evenly. In the example below node 7 has no memory (it only has
CPUs). Node 0 and 1 have plenty of free memory. After doing:

# echo 16 > /proc/sys/vm/nr_hugepages

We see the imbalance:

# cat /sys/devices/system/node/node*/meminfo|grep HugePages_Total
Node 0 HugePages_Total:     6
Node 1 HugePages_Total:     10
Node 7 HugePages_Total:     0

It didnt take long to realise that alloc_fresh_huge_page is allocating
from node 7 without GFP_THISNODE set, so we fallback to its next
preferred node (ie 1). This means we end up with a 1/3 2/3 imbalance.

After fixing this it still didnt work, and after some more poking I see
why. When building our fallback zonelist in build_zonelists_node we
skip empty zones. This means zone 7 never registers node 7's empty
zonelists and instead registers node 1's. Therefore when we ask for a
page from node 7, using the GFP_THISNODE flag we end up with node 1
memory.

By removing the populated_zone() check in build_zonelists_node we fix
the problem:

# cat /sys/devices/system/node/node*/meminfo|grep HugePages_Total
Node 0 HugePages_Total:     8
Node 1 HugePages_Total:     8
Node 7 HugePages_Total:     0

Im guessing registering empty remote zones might make the SGI guys a bit
unhappy, maybe we should just force the registration of empty local
zones? Does anyone care?

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: kernel/mm/hugetlb.c
===================================================================
--- kernel.orig/mm/hugetlb.c	2007-05-02 20:46:03.000000000 -0500
+++ kernel/mm/hugetlb.c	2007-05-02 20:48:15.000000000 -0500
@@ -103,11 +103,18 @@ static int alloc_fresh_huge_page(void)
 {
 	static int nid = 0;
 	struct page *page;
-	page = alloc_pages_node(nid, GFP_HIGHUSER|__GFP_COMP|__GFP_NOWARN,
+	int start_nid = nid;
+
+	do {
+		page = alloc_pages_node(nid,
+					GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
 					HUGETLB_PAGE_ORDER);
-	nid = next_node(nid, node_online_map);
-	if (nid == MAX_NUMNODES)
-		nid = first_node(node_online_map);
+
+		nid = next_node(nid, node_online_map);
+		if (nid == MAX_NUMNODES)
+			nid = first_node(node_online_map);
+	} while (!page && nid != start_nid);
+
 	if (page) {
 		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);
Index: kernel/mm/page_alloc.c
===================================================================
--- kernel.orig/mm/page_alloc.c	2007-05-02 20:46:03.000000000 -0500
+++ kernel/mm/page_alloc.c	2007-05-02 20:47:59.000000000 -0500
@@ -1659,10 +1659,8 @@ static int __meminit build_zonelists_nod
 	do {
 		zone_type--;
 		zone = pgdat->node_zones + zone_type;
-		if (populated_zone(zone)) {
-			zonelist->zones[nr_zones++] = zone;
-			check_highest_zone(zone_type);
-		}
+		zonelist->zones[nr_zones++] = zone;
+		check_highest_zone(zone_type);
 
 	} while (zone_type);
 	return nr_zones;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
