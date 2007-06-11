Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BM7SRT007812
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 18:07:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BNADe5534528
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:10:13 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BNACNq016969
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:10:13 -0400
Date: Mon, 11 Jun 2007 16:10:08 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070611231008.GD14458@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070611230829.GC14458@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Applies to 2.6.22-rc4-mm2 with
add-populated_map-to-account-for-memoryless-nodes
fix-interleave-with-memoryless-nodes
applied.

Split Lee and Anton's patch
(http://marc.info/?l=linux-mm&m=118133042025995&w=2) into two parts.

Only attempt to allocate huge pages on nodes that contain memory, as
specified by node_populated_map.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 858c0b3..97ae1a3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -105,13 +105,22 @@ static void free_huge_page(struct page *page)
 
 static int alloc_fresh_huge_page(void)
 {
-	static int nid = 0;
+	static int nid = -1;
 	struct page *page;
-	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
-					HUGETLB_PAGE_ORDER);
-	nid = next_node(nid, node_online_map);
-	if (nid == MAX_NUMNODES)
-		nid = first_node(node_online_map);
+	int start_nid;
+
+	if (nid < 0)
+		nid = first_node(node_populated_map);
+	start_nid = nid;
+
+	do {
+		page = alloc_pages_node(nid,
+				GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
+				HUGETLB_PAGE_ORDER);
+		nid = next_node(nid, node_populated_map);
+		if (nid >= nr_node_ids)
+			nid = first_node(node_populated_map);
+	} while (!page && nid != start_nid);
 	if (page) {
 		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
