Subject: Re: [PATCH v7][RFC] Fix hugetlb pool allocation with empty nodes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070613000446.GL3798@us.ibm.com>
References: <20070611225213.GB14458@us.ibm.com>
	 <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com>
	 <20070612001542.GJ14458@us.ibm.com> <20070612034407.GB11773@holomorphy.com>
	 <20070612050910.GU3798@us.ibm.com> <20070612051512.GC11773@holomorphy.com>
	 <20070612174503.GB3798@us.ibm.com> <20070612191347.GE11781@holomorphy.com>
	 <20070613000446.GL3798@us.ibm.com>
Content-Type: text/plain
Date: Wed, 13 Jun 2007 17:04:40 -0400
Message-Id: <1181768681.6148.109.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-06-12 at 17:04 -0700, Nishanth Aravamudan wrote:
> On 12.06.2007 [12:13:47 -0700], William Lee Irwin III wrote:
> > On 11.06.2007 [22:15:12 -0700], William Lee Irwin III wrote:
> > >> For initially filling the pool one can just loop over nid's modulo the
> > >> number of populated nodes and pass down a stack-allocated variable.
> > 
> > On Tue, Jun 12, 2007 at 10:45:03AM -0700, Nishanth Aravamudan wrote:
> > > But how does one differentiate between "initally filling" the pool and a
> > > later attempt to add to the pool (or even just marginally later).
> > > I guess I don't see why folks are so against this static variable :) It
> > > does the job and removing it seems like it could be an independent
> > > cleanup?
> > 
> > Well, another approach is to just statically initialize it to something
> > and then always check to make sure the node for the nid has memory, and
> > if not, find the next nid with a node with memory from the populated map.
> 
> How does something like this look? Or is it overkill?
> 
> [PATCH 2.6.22-rc4-mm2] Fix hugetlb pool allocation with empty nodes V7
> 
> Anton found a problem with the hugetlb pool allocation when some nodes
> have no memory (http://marc.info/?l=linux-mm&m=118133042025995&w=2). Lee
> worked on versions that tried to fix it, but none were accepted.
> Christoph has created a set of patches which allow for GFP_THISNODE
> allocations to fail if the node has no memory and for exporting a
> node_memory_map indicating which nodes have memory. Since mempolicy.c
> already has a number of functions which support interleaving, create a
> mempolicy when we invoke alloc_fresh_huge_page() that specifies
> interleaving across all the nodes in node_memory_map, rather than custom
> interleaving code in hugetlb.c.  This requires adding some dummy
> functions, and some declarations, in mempolicy.h to compile with NUMA or
> !NUMA.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Cc: Anton Blanchard <anton@samba.org>
> Cc: Lee Schermerhorn <lee.schermerhon@hp.com>
> Cc: Christoph Lameter <clameter@sgi.com>
> Cc: William Lee Irwin III <wli@holomorphy.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> 
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 22b668c..c8a68b8 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -76,6 +76,8 @@ struct mempolicy {
>   * The default fast path of a NULL MPOL_DEFAULT policy is always inlined.
>   */
>  
> +extern struct mempolicy *mpol_new(int mode, nodemask_t *nodes);
> +
>  extern void __mpol_free(struct mempolicy *pol);
>  static inline void mpol_free(struct mempolicy *pol)
>  {
> @@ -164,6 +166,8 @@ static inline void check_highest_zone(enum zone_type k)
>  		policy_zone = k;
>  }
>  
> +extern unsigned interleave_nodes(struct mempolicy *policy);
> +
>  int do_migrate_pages(struct mm_struct *mm,
>  	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags);
>  
> @@ -179,6 +183,11 @@ static inline int mpol_equal(struct mempolicy *a, struct mempolicy *b)
>  
>  #define mpol_set_vma_default(vma) do {} while(0)
>  
> +static inline struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
> +{
> +	return NULL;
> +}
> +
>  static inline void mpol_free(struct mempolicy *p)
>  {
>  }
> @@ -267,6 +276,11 @@ static inline int do_migrate_pages(struct mm_struct *mm,
>  static inline void check_highest_zone(int k)
>  {
>  }
> +
> +static inline unsigned interleave_nodes(struct mempolicy *policy)
> +{
> +	return 0;
> +}
>  #endif /* CONFIG_NUMA */
>  #endif /* __KERNEL__ */
>  
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 858c0b3..1c13687 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -103,15 +103,20 @@ static void free_huge_page(struct page *page)
>  	spin_unlock(&hugetlb_lock);
>  }
>  
> -static int alloc_fresh_huge_page(void)
> +static int alloc_fresh_huge_page(struct mempolicy *policy)
>  {
> -	static int nid = 0;
> +	int nid;
>  	struct page *page;
> -	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
> -					HUGETLB_PAGE_ORDER);
> -	nid = next_node(nid, node_online_map);
> -	if (nid == MAX_NUMNODES)
> -		nid = first_node(node_online_map);
> +	int start_nid = interleave_nodes(policy);
> +
> +	nid = start_nid;
> +
> +	do {
> +		page = alloc_pages_node(nid,
> +				htlb_alloc_mask|__GFP_COMP|GFP_THISNODE,
> +				HUGETLB_PAGE_ORDER);
> +		nid = interleave_nodes(policy);

This needs to be:

		if (!page)
			nid = interleave_nodes(policy);

Otherwise, you skip every other populated node, because you call
interleave_nodes() at the top when you initialize start_nid.  You only
want to advance to the next node here if the allocation failed.

<snip>

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
