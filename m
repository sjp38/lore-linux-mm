Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9B5J4n5003000
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 01:19:04 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9B5J25C136100
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 01:19:04 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9B5J1hN005478
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 01:19:02 -0400
Date: Wed, 10 Oct 2007 22:18:59 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH][UPDATED] hugetlb: fix hugepage allocation with memoryless nodes
Message-ID: <20071011051859.GA18496@us.ibm.com>
References: <20071009012724.GA26472@us.ibm.com> <20071011041119.GB32657@us.ibm.com> <Pine.LNX.4.64.0710102112470.28507@schroedinger.engr.sgi.com> <20071011042948.GC32657@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071011042948.GC32657@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: anton@samba.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, mel@csn.ul.ie, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.10.2007 [21:29:48 -0700], Nishanth Aravamudan wrote:
> On 10.10.2007 [21:14:48 -0700], Christoph Lameter wrote:
> > On Wed, 10 Oct 2007, Nishanth Aravamudan wrote:
> > 
> > > > +++ b/mm/hugetlb.c
> > > > @@ -32,6 +32,7 @@ static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
> > > >  static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
> > > >  unsigned long hugepages_treat_as_movable;
> > > >  int hugetlb_dynamic_pool;
> > > > +static int last_allocated_nid;
> > > 
> > > While reworking patch 2/2 to incorporate the current state of hugetlb.c
> > > after Adam's stack is applied, I realized that this is not a very good
> > > name. It actually is the *current* nid to try to allocate hugepages on.
> > > 
> > > Christoph, since you proposed the name, do you think
> > > 
> > > hugetlb_current_nid
> > > 
> > > is ok, too? If so I'll change the name throughout the patch (no
> > > functional change).
> > 
> > Sure. However, current is bit ambiguous. Is it the node we used last
> > or the one to use next? Call it next_hugetlb_nid? Either way is fine
> > with me though.
> 
> Good point. Given the way the code is laid out now, it always represents
> the nid to allocate on next (so is the first one to try).
> 
> next_hugetlb_nid or hugetlb_next_nid it is.

hugetlb: fix hugepage allocation with memoryless nodes

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
function for actually allocating the hugepage. Use a new global nid
iterator to control which nid to allocate on.

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

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 68e8391..f246aee 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -32,6 +32,7 @@ static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 int hugetlb_dynamic_pool;
+static int hugetlb_next_nid;
 
 /*
  * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
@@ -166,36 +167,56 @@ static int adjust_pool_surplus(int delta)
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
+	start_nid = hugetlb_next_nid;
+
+	do {
+		page = alloc_fresh_huge_page_node(hugetlb_next_nid);
+		if (page)
+			ret = 1;
+		/*
+		 * Use a helper variable to find the next node and then
+		 * copy it back to hugetlb_next_nid afterwards:
+		 * otherwise there's a window in which a racer might
+		 * pass invalid nid MAX_NUMNODES to alloc_pages_node.
+		 * But we don't need to use a spin_lock here: it really
+		 * doesn't matter if occasionally a racer chooses the
+		 * same nid as we do.  Move nid forward in the mask even
+		 * if we just successfully allocated a hugepage so that
+		 * the next caller gets hugepages on the next node.
+		 */
+		next_nid = next_node(hugetlb_next_nid, node_online_map);
+		if (next_nid == MAX_NUMNODES)
+			next_nid = first_node(node_online_map);
+		hugetlb_next_nid = next_nid;
+	} while (!page && hugetlb_next_nid != start_nid);
+
+	return ret;
 }
 
 static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
@@ -366,6 +387,8 @@ static int __init hugetlb_init(void)
 	for (i = 0; i < MAX_NUMNODES; ++i)
 		INIT_LIST_HEAD(&hugepage_freelists[i]);
 
+	hugetlb_next_nid = first_node(node_online_map);
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
