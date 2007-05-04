Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070503022107.GA13592@kryten>
References: <20070503022107.GA13592@kryten>
Content-Type: text/plain
Date: Fri, 04 May 2007 16:29:02 -0400
Message-Id: <1178310543.5236.43.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: linux-mm@kvack.org, clameter@SGI.com, ak@suse.de, nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-02 at 21:21 -0500, Anton Blanchard wrote:
> An interesting bug was pointed out to me where we failed to allocate
> hugepages evenly. In the example below node 7 has no memory (it only has
> CPUs). Node 0 and 1 have plenty of free memory. After doing:

Here's my attempt to fix the problem [I see it on HP platforms as well],
without removing the population check in build_zonelists_node().  Seems
to work.

[Because I had to rebase the patch to 21-rc7-mm2 where I'm working, I
just refreshed the entire patch, instead of creating an incremental
patch on top of Anton's.]

---------------------------------------------------------------------

[PATCH] Fix hugetlb pool allocation with empty nodes V2

Against 2.6.21-rc7-mm2

Changes V1 [Anton]  -> V2 [Lee]:

1) reverted the populated_zone() check in build_zonelists_node to avoid
   empty zones in the allocation zonelists.

2) added a populated_zone() check to alloc_fresh_huge_page().  Skip
   nodes whose zone corresponding to GFP_HIGHUSER is empty.

--------
Original description:

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

<snip bit about removing pop check from build_zonelists_node...>

Add zone population check to alloc_fresh_huge_page() and skip nodes 
with unpopulated zone.

V2 testing:

Tested on 4-node, 32GB HP NUMA platform with funky 512MB pseudo-zone
for hardware interleaved memory.  The pseudo-zone contains only ZONE_DMA
memory.  Without this patch, after "echo 64 >/proc/sys/vm/nr_hugepages",
"cat /sys/devices/system/node/node*/meminfo | grep HugeP" would yield:

Node 0 HugePages_Total:    25
Node 0 HugePages_Free:     25
Node 1 HugePages_Total:    13
Node 1 HugePages_Free:     13
Node 2 HugePages_Total:    13
Node 2 HugePages_Free:     13
Node 3 HugePages_Total:    13
Node 3 HugePages_Free:     13
Node 4 HugePages_Total:     0
Node 4 HugePages_Free:      0

With patch:

Node 0 HugePages_Total:    16
Node 0 HugePages_Free:     16
Node 1 HugePages_Total:    16
Node 1 HugePages_Free:     16
Node 2 HugePages_Total:    16
Node 2 HugePages_Free:     16
Node 3 HugePages_Total:    16
Node 3 HugePages_Free:     16
Node 4 HugePages_Total:     0
Node 4 HugePages_Free:      0


Originally
Signed-off-by: Anton Blanchard <anton@samba.org>

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/hugetlb.c |   23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

Index: Linux/mm/hugetlb.c
===================================================================
--- Linux.orig/mm/hugetlb.c	2007-05-04 15:41:10.000000000 -0400
+++ Linux/mm/hugetlb.c	2007-05-04 15:48:22.000000000 -0400
@@ -107,11 +107,24 @@ static int alloc_fresh_huge_page(void)
 {
 	static int nid = 0;
 	struct page *page;
-	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
-					HUGETLB_PAGE_ORDER);
-	nid = next_node(nid, node_online_map);
-	if (nid == MAX_NUMNODES)
-		nid = first_node(node_online_map);
+	int start_nid = nid;
+
+	do {
+		pg_data_t *pgdat =  NODE_DATA(nid);
+		struct zone *zone = pgdat->node_zones + gfp_zone(GFP_HIGHUSER);
+
+		/*
+		 * accept only nodes with populated "HIGHUSER" zone
+		 */
+		if (populated_zone(zone))
+			page = alloc_pages_node(nid,
+					GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
+  					HUGETLB_PAGE_ORDER);
+
+		nid = next_node(nid, node_online_map);
+		if (nid == MAX_NUMNODES)
+			nid = first_node(node_online_map);
+	} while (!page && nid != start_nid);
 	if (page) {
 		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
