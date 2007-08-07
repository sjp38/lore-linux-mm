Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l77NYcfh016675
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 19:34:38 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l77NYcg8106528
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 17:34:38 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l77NYb7O006653
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 17:34:38 -0600
Date: Tue, 7 Aug 2007 16:34:37 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 1/2][UPDATED] hugetlb: search harder for memory in alloc_fresh_huge_page()
Message-ID: <20070807233437.GD15714@us.ibm.com>
References: <20070807171432.GY15714@us.ibm.com> <1186517722.5067.31.camel@localhost> <20070807221240.GB15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070807221240.GB15714@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: clameter@sgi.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.08.2007 [15:12:40 -0700], Nishanth Aravamudan wrote:
> On 07.08.2007 [16:15:22 -0400], Lee Schermerhorn wrote:
> > On Tue, 2007-08-07 at 10:14 -0700, Nishanth Aravamudan wrote:
> > > hugetlb: search harder for memory in alloc_fresh_huge_page()
> > > 
> > > Currently, alloc_fresh_huge_page() returns NULL when it is not able to
> > > allocate a huge page on the current node, as specified by its custom
> > > interleave variable. The callers of this function, though, assume that a
> > > failure in alloc_fresh_huge_page() indicates no hugepages can be
> > > allocated on the system period. This might not be the case, for
> > > instance, if we have an uneven NUMA system, and we happen to try to
> > > allocate a hugepage on a node with less memory and fail, while there is
> > > still plenty of free memory on the other nodes.
> > > 
> > > To correct this, make alloc_fresh_huge_page() search through all online
> > > nodes before deciding no hugepages can be allocated. Add a helper
> > > function for actually allocating the hugepage.
> > > 
> > > While there are interleave interfaces that could be exported from the
> > > mempolicy layer, that seems like an inappropriate design decision. Work
> > > is needed on a subsystem-level interleaving interface, but I'm still not
> > > quite sure how that should look. Hence the custom interleaving here.
> > > 
> > > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > > 
> 
> <snip>
> 
> > > -	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
> > > -					HUGETLB_PAGE_ORDER);
> > > +	page = alloc_pages_node(nid,
> > > +		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
> > > +		HUGETLB_PAGE_ORDER);
> > >  	if (page) {
> > >  		set_compound_page_dtor(page, free_huge_page);
> > >  		spin_lock(&hugetlb_lock);
> > >  		nr_huge_pages++;
> > > -		nr_huge_pages_node[page_to_nid(page)]++;
> > > +		nr_huge_pages_node[nid]++;
> > 
> > Not that I don't trust __GFP_THISNODE, but may I suggest a
> > "VM_BUG_ON(page_to_nid(page) != nid)" -- up above the spin_lock(), of
> > course.  Better yet, add the assertion and drop this one line change?
> > This isn't a hot path, I think.
> 
> Hrm, I think if it's really a concern then the VM_BUG_ON should be in
> alloc_pages_node() itself? Or somewhere lower level, I mean, it's a bug
> everywhere, not just in hugetlb.c. And, more importantly, if
> __GFP_THISNODE doesn't work, it pretty much defeats the purpose of my
> sysfs attribute patch. Echo'ing a value for node 0 and getting hugepages
> on node 1 would be bad :)
> 
> But here's the patch respun, as requested:
> 
> hugetlb: search harder for memory in alloc_fresh_huge_page()
> 
> Currently, alloc_fresh_huge_page() returns NULL when it is not able to
> allocate a huge page on the current node, as specified by its custom
> interleave variable. The callers of this function, though, assume that a
> failure in alloc_fresh_huge_page() indicates no hugepages can be
> allocated on the system period. This might not be the case, for
> instance, if we have an uneven NUMA system, and we happen to try to
> allocate a hugepage on a node with less memory and fail, while there is
> still plenty of free memory on the other nodes.
> 
> To correct this, make alloc_fresh_huge_page() search through all online
> nodes before deciding no hugepages can be allocated. Add a helper
> function for actually allocating the hugepage. Also, since we expect
> particular semantics for __GFP_THISNODE, which are newly enforced, add a
> VM_BUG_ON when allocations occur off the requested node.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index d7ca59d..e7b103d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -101,36 +101,60 @@ static void free_huge_page(struct page *page)
>  	spin_unlock(&hugetlb_lock);
>  }
>  
> -static int alloc_fresh_huge_page(void)
> +static struct page *alloc_fresh_huge_page_node(int nid)
>  {
> -	static int prev_nid;
>  	struct page *page;
> -	int nid;
> -
> -	/*
> -	 * Copy static prev_nid to local nid, work on that, then copy it
> -	 * back to prev_nid afterwards: otherwise there's a window in which
> -	 * a racer might pass invalid nid MAX_NUMNODES to alloc_pages_node.
> -	 * But we don't need to use a spin_lock here: it really doesn't
> -	 * matter if occasionally a racer chooses the same nid as we do.
> -	 */
> -	nid = next_node(prev_nid, node_online_map);
> -	if (nid == MAX_NUMNODES)
> -		nid = first_node(node_online_map);
> -	prev_nid = nid;
>  
> -	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
> -					HUGETLB_PAGE_ORDER);
> +	page = alloc_pages_node(nid,
> +		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
> +		HUGETLB_PAGE_ORDER);
>  	if (page) {
> +		VM_BUG_ON(nid != page_to_nid(page));
>  		set_compound_page_dtor(page, free_huge_page);
>  		spin_lock(&hugetlb_lock);
>  		nr_huge_pages++;
> -		nr_huge_pages_node[page_to_nid(page)]++;
> +		nr_huge_pages_node[page_to_nid(nid)]++;

Sigh, should check the patch before sending :)

This bit should not be there... Still waiting to hear from Christoph as
to which way he wants it to look, but here is the correct patch for this
version:

hugetlb: search harder for memory in alloc_fresh_huge_page()

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
function for actually allocating the hugepage. Also, since we expect
particular semantics for __GFP_THISNODE, which are newly enforced, add a
VM_BUG_ON when allocations occur off the requested node.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d7ca59d..83c8026 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -101,36 +101,60 @@ static void free_huge_page(struct page *page)
 	spin_unlock(&hugetlb_lock);
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
+		VM_BUG_ON(nid != page_to_nid(page));
 		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);
 		nr_huge_pages++;
 		nr_huge_pages_node[page_to_nid(page)]++;
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
+	static int nid = -1;
+	struct page *page;
+	int start_nid;
+	int next_nid;
+	int ret = 0;
+
+	if (nid < 0)
+		nid = first_node(node_online_map);
+	start_nid = nid;
+
+	do {
+		page = alloc_fresh_huge_page_node(nid);
+		if (page)
+			ret = 1;
+		/*
+		 * Use a helper variable to find the next node and then
+		 * copy it back to nid nid afterwards: otherwise there's
+		 * a window in which a racer might pass invalid nid
+		 * MAX_NUMNODES to alloc_pages_node.  But we don't need
+		 * to use a spin_lock here: it really doesn't matter if
+		 * occasionally a racer chooses the same nid as we do.
+		 * Move nid forward in the mask even if we just
+		 * successfully allocated a hugepage so that the next
+		 * caller gets hugepages on the next node.
+		 */
+		next_nid = next_node(nid, node_online_map);
+		if (next_nid == MAX_NUMNODES)
+			next_nid = first_node(node_online_map);
+		nid = next_nid;
+	} while (!page && nid != start_nid);
+
+	return ret;
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
