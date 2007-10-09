Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l991RRP0005288
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 21:27:27 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l991RRW4485754
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 19:27:27 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l991RQUD003303
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 19:27:26 -0600
Date: Mon, 8 Oct 2007 18:27:24 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] hugetlb: fix hugepage allocation with memoryless nodes
Message-ID: <20071009012724.GA26472@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: anton@samba.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, mel@csn.ul.ie, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Anton found a problem with the hugetlb pool allocation when some nodes
have no memory (http://marc.info/?l=linux-mm&m=118133042025995&w=2). Lee
worked on versions that tried to fix it, but none were accepted.
Christoph has created a set of patches which allow for GFP_THISNODE
allocations to fail if the node has no memory.

Currently, alloc_fresh_huge_page() returns NULL when it is not able to
allocate a huge page on the current node, as specified by its custom
interleave variable. The callers of this function, though, assume that a
failure in alloc_fresh_huge_page() indicates no hugepages can be
allocated on the system period. This might not be the case, for
instance, if we have an uneven NUMA system, and we happen to try to
allocate a hugepage on a node with less memory and fail, while there is
still plenty of free memory on the other nodes.

To correct this, make alloc_fresh_huge_page() search through all online
nodes before deciding no hugepages can be allocated. Add a helper
function for actually allocating the hugepage.

Note: we expect particular semantics for __GFP_THISNODE, which are now
enforced even for memoryless nodes. That is, there is should be no
fallback to other nodes. Therefore, we rely on the nid passed into
alloc_pages_node() to be the nid the page comes from. If this is
incorrect, accounting will break.

Tested on x86 !NUMA, x86 NUMA, x86_64 NUMA and ppc64 NUMA (with 2
memoryless nodes).

Before on the ppc64 box:
Trying to clear the hugetlb pool
Done.       0 free
Trying to resize the pool to 100
Node 0 HugePages_Free:     25
Node 1 HugePages_Free:     75
Node 2 HugePages_Free:      0
Node 3 HugePages_Free:      0
Done. Initially     100 free
Trying to resize the pool to 200
Node 0 HugePages_Free:     50
Node 1 HugePages_Free:    150
Node 2 HugePages_Free:      0
Node 3 HugePages_Free:      0
Done.     200 free

After:
Trying to clear the hugetlb pool
Done.       0 free
Trying to resize the pool to 100
Node 0 HugePages_Free:     50
Node 1 HugePages_Free:     50
Node 2 HugePages_Free:      0
Node 3 HugePages_Free:      0
Done. Initially     100 free
Trying to resize the pool to 200
Node 0 HugePages_Free:    100
Node 1 HugePages_Free:    100
Node 2 HugePages_Free:      0
Node 3 HugePages_Free:      0
Done.     200 free

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Christoph Lameter <clameter@sgi.com>
Cc: Anton Blanchard <anton@samba.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Adam Litke <agl@us.ibm.com>
Cc: William Lee Irwin III <wli@holomorphy.com>

---
 mm/hugetlb.c |   63 ++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 43 insertions(+), 20 deletions(-)

Andrew, this patch alone suffices to fix the hugetlb pool allocation
with memoryless nodes and is rebased on 2.6.23-rc8-mm2 + Adam's 5
patches. What I had been sending as patch 2/2 (which pretty much just
did `sed -i s/node_online_map/node_states[N_HIGH_MEMORY]/ mm/hugetlb.c`)
will need to be extended/tested for the new loops in hugetlb.c, but that
is an efficiency concern, not a correctness one. I'd like to see if we
can get this patch in 2.6.24, so if you could pick it up for the next
-mm, I'd greatly appreciate it.

Also, I wonder (and have suggested this before): would it make sense to
put a VM_BUG_ON (VM_BUG_ON_ONCE, if it exists) for GFP_THISNODE
allocations coming from a node other than the one specified in the core
VM under DEBUG_VM or something? That would have caught the case that
Mel's one-zonelist stack created, I think.

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3d1b111..098e608 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -32,6 +32,7 @@ static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 int hugetlb_dynamic_pool;
+static int last_allocated_nid;
 
 /*
  * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
@@ -165,36 +166,56 @@ static int adjust_pool_surplus(int delta)
 	return ret;
 }
 
-static int alloc_fresh_huge_page(void)
+static struct page *alloc_fresh_huge_page_node(int nid)
 {
-	static int prev_nid;
 	struct page *page;
-	int nid;
-
-	/*
-	 * Copy static prev_nid to local nid, work on that, then copy it
-	 * back to prev_nid afterwards: otherwise there's a window in which
-	 * a racer might pass invalid nid MAX_NUMNODES to alloc_pages_node.
-	 * But we don't need to use a spin_lock here: it really doesn't
-	 * matter if occasionally a racer chooses the same nid as we do.
-	 */
-	nid = next_node(prev_nid, node_online_map);
-	if (nid == MAX_NUMNODES)
-		nid = first_node(node_online_map);
-	prev_nid = nid;
 
-	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
-					HUGETLB_PAGE_ORDER);
+	page = alloc_pages_node(nid,
+		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
+		HUGETLB_PAGE_ORDER);
 	if (page) {
 		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);
 		nr_huge_pages++;
-		nr_huge_pages_node[page_to_nid(page)]++;
+		nr_huge_pages_node[nid]++;
 		spin_unlock(&hugetlb_lock);
 		put_page(page); /* free it into the hugepage allocator */
-		return 1;
 	}
-	return 0;
+
+	return page;
+}
+
+static int alloc_fresh_huge_page(void)
+{
+	struct page *page;
+	int start_nid;
+	int next_nid;
+	int ret = 0;
+
+	start_nid = last_allocated_nid;
+
+	do {
+		page = alloc_fresh_huge_page_node(last_allocated_nid);
+		if (page)
+			ret = 1;
+		/*
+		 * Use a helper variable to find the next node and then
+		 * copy it back to last_allocated_nid afterwards:
+		 * otherwise there's a window in which a racer might
+		 * pass invalid nid MAX_NUMNODES to alloc_pages_node.
+		 * But we don't need to use a spin_lock here: it really
+		 * doesn't matter if occasionally a racer chooses the
+		 * same nid as we do.  Move nid forward in the mask even
+		 * if we just successfully allocated a hugepage so that
+		 * the next caller gets hugepages on the next node.
+		 */
+		next_nid = next_node(last_allocated_nid, node_online_map);
+		if (next_nid == MAX_NUMNODES)
+			next_nid = first_node(node_online_map);
+		last_allocated_nid = next_nid;
+	} while (!page && last_allocated_nid != start_nid);
+
+	return ret;
 }
 
 static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
@@ -365,6 +386,8 @@ static int __init hugetlb_init(void)
 	for (i = 0; i < MAX_NUMNODES; ++i)
 		INIT_LIST_HEAD(&hugepage_freelists[i]);
 
+	last_allocated_nid = first_node(node_online_map);
+
 	for (i = 0; i < max_huge_pages; ++i) {
 		if (!alloc_fresh_huge_page())
 			break;

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
