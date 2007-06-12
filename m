Date: Mon, 11 Jun 2007 17:57:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2][RFC] Fix INTERLEAVE with memoryless nodes
Message-Id: <20070611175700.e5268342.akpm@linux-foundation.org>
In-Reply-To: <20070612001436.GI14458@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com>
	<Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
	<20070611221036.GA14458@us.ibm.com>
	<Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
	<20070611225213.GB14458@us.ibm.com>
	<20070611230829.GC14458@us.ibm.com>
	<Pine.LNX.4.64.0706111613100.23857@schroedinger.engr.sgi.com>
	<20070612001436.GI14458@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, lee.schermerhorn@hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007 17:14:36 -0700 Nishanth Aravamudan <nacc@us.ibm.com> wrote:

> 
> Christoph said:
> "This does not work for the address based interleaving for anonymous
> vmas.  I am not sure what to do there. We could change the calculation
> of the node to be based only on nodes with memory and then skip the
> memoryless ones. I have only added a comment to describe its brokennes
> for now."
> 
> I have copied his draft's comment.
> 
> Change alloc_pages_node() to fail __GFP_THISNODE allocations if the node
> is not populated.
> 
> Again, Christoph said:
> "This will fix the alloc_pages_node case but not the alloc_pages() case.
> In the alloc_pages() case we do not specify a node. Implicitly it is
> understood that we (in the case of no memory policy / cpuset options)
> allocate from the nearest node. So it may be argued there that the
> GFP_THISNODE behavior of taking the first node from the zonelist is
> okay."
> 
> Christoph was also worried about the performance impact on these paths,
> as am I.
> 
> Finally, as he suggested, uninline alloc_pages_node() and move it to
> mempolicy.c.
> 

All confused.

> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 49dcc2f..c83e56a 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -165,19 +165,7 @@ static inline void arch_alloc_page(struct page *page, int order) { }
>  extern struct page *
>  FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
>  
> -static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
> -						unsigned int order)
> -{
> -	if (unlikely(order >= MAX_ORDER))
> -		return NULL;
> -
> -	/* Unknown node is current node */
> -	if (nid < 0)
> -		nid = numa_node_id();
> -
> -	return __alloc_pages(gfp_mask, order,
> -		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
> -}
> +extern struct page * alloc_pages_node(int, gfp_t, unsigned int);
>  
>  #ifdef CONFIG_NUMA
>  extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 144805c..abadbf4 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -174,6 +174,7 @@ static struct zonelist *bind_zonelist(nodemask_t *nodes)
>  static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
>  {
>  	struct mempolicy *policy;
> +	unsigned nid;

This variable appears to be unneeded.

>  	PDprintk("setting mode %d nodes[0] %lx\n", mode, nodes_addr(*nodes)[0]);
>  	if (mode == MPOL_DEFAULT)
> @@ -184,8 +185,12 @@ static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
>  	atomic_set(&policy->refcnt, 1);
>  	switch (mode) {
>  	case MPOL_INTERLEAVE:
> -		policy->v.nodes = *nodes;
> -		if (nodes_weight(*nodes) == 0) {
> +		/*
> +		 * Clear any memoryless nodes here so that v.nodes can be used
> +		 * without extra checks
> +		 */
> +		nodes_and(policy->v.nodes, *nodes, node_populated_mask);
> +		if (nodes_weight(policy->v.nodes) == 0) {
>  			kmem_cache_free(policy_cache, policy);
>  			return ERR_PTR(-EINVAL);
>  		}

I have no node_populated_mask.

The below improves the situation, but I wonder about, ahem, the maturity of
this code.



From: Andrew Morton <akpm@linux-foundation.org>

- Fix checkpatch.pl warning

- Fix build

- Fix unused var warning

Cc: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/gfp.h |    2 +-
 mm/mempolicy.c      |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff -puN include/linux/gfp.h~fix-interleave-with-memoryless-nodes-fix include/linux/gfp.h
--- a/include/linux/gfp.h~fix-interleave-with-memoryless-nodes-fix
+++ a/include/linux/gfp.h
@@ -130,7 +130,7 @@ static inline void arch_alloc_page(struc
 extern struct page *
 FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
 
-extern struct page * alloc_pages_node(int, gfp_t, unsigned int);
+extern struct page *alloc_pages_node(int, gfp_t, unsigned int);
 
 #ifdef CONFIG_NUMA
 extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
diff -puN mm/mempolicy.c~fix-interleave-with-memoryless-nodes-fix mm/mempolicy.c
--- a/mm/mempolicy.c~fix-interleave-with-memoryless-nodes-fix
+++ a/mm/mempolicy.c
@@ -172,7 +172,6 @@ static struct zonelist *bind_zonelist(no
 static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
 {
 	struct mempolicy *policy;
-	unsigned nid;
 
 	pr_debug("setting mode %d nodes[0] %lx\n",
 		 mode, nodes ? nodes_addr(*nodes)[0] : -1);
@@ -189,7 +188,7 @@ static struct mempolicy *mpol_new(int mo
 		 * Clear any memoryless nodes here so that v.nodes can be used
 		 * without extra checks
 		 */
-		nodes_and(policy->v.nodes, *nodes, node_populated_mask);
+		nodes_and(policy->v.nodes, *nodes, node_populated_map);
 		if (nodes_weight(policy->v.nodes) == 0) {
 			kmem_cache_free(policy_cache, policy);
 			return ERR_PTR(-EINVAL);
_



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
