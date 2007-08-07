Subject: Re: [RFC][PATCH 1/2] hugetlb: search harder for memory in
	alloc_fresh_huge_page()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070807171432.GY15714@us.ibm.com>
References: <20070807171432.GY15714@us.ibm.com>
Content-Type: text/plain
Date: Tue, 07 Aug 2007 16:15:22 -0400
Message-Id: <1186517722.5067.31.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: clameter@sgi.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-07 at 10:14 -0700, Nishanth Aravamudan wrote:
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
> function for actually allocating the hugepage.
> 
> While there are interleave interfaces that could be exported from the
> mempolicy layer, that seems like an inappropriate design decision. Work
> is needed on a subsystem-level interleaving interface, but I'm still not
> quite sure how that should look. Hence the custom interleaving here.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> ---
> I split up patch 1/5 into two bits, as they are really two logical
> changes. Does this look better, Christoph?
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index d7ca59d..17a377e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -101,36 +101,59 @@ static void free_huge_page(struct page *page)
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
>  		set_compound_page_dtor(page, free_huge_page);
>  		spin_lock(&hugetlb_lock);
>  		nr_huge_pages++;
> -		nr_huge_pages_node[page_to_nid(page)]++;
> +		nr_huge_pages_node[nid]++;

Not that I don't trust __GFP_THISNODE, but may I suggest a
"VM_BUG_ON(page_to_nid(page) != nid)" -- up above the spin_lock(), of
course.  Better yet, add the assertion and drop this one line change?
This isn't a hot path, I think.

>  		spin_unlock(&hugetlb_lock);
>  		put_page(page); /* free it into the hugepage allocator */
> -		return 1;
>  	}
> -	return 0;
> +
> +	return page;
> +}
> +
> +static int alloc_fresh_huge_page(void)
> +{
> +	static int nid = -1;
> +	struct page *page;
> +	int start_nid;
> +	int next_nid;
> +	int ret = 0;
> +
> +	if (nid < 0)
> +		nid = first_node(node_online_map);
> +	start_nid = nid;
> +
> +	do {
> +		page = alloc_fresh_huge_page_node(nid);
> +		if (page)
> +			ret = 1;
> +		/*
> +		 * Use a helper variable to find the next node and then
> +		 * copy it back to nid nid afterwards: otherwise there's
> +		 * a window in which a racer might pass invalid nid
> +		 * MAX_NUMNODES to alloc_pages_node.  But we don't need
> +		 * to use a spin_lock here: it really doesn't matter if
> +		 * occasionally a racer chooses the same nid as we do.
> +		 * Move nid forward in the mask even if we just
> +		 * successfully allocated a hugepage so that the next
> +		 * caller gets hugepages on the next node.
> +		 */
> +		next_nid = next_node(nid, node_online_map);
> +		if (next_nid == MAX_NUMNODES)
> +			next_nid = first_node(node_online_map);
> +		nid = next_nid;
> +	} while (!page && nid != start_nid);
> +
> +	return ret;
>  }
>  
>  static struct page *alloc_huge_page(struct vm_area_struct *vma,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
