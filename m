Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l5C0AEhm023837
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 20:10:14 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C0Efit227972
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 18:14:43 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C0EfSW031657
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 18:14:41 -0600
Date: Mon, 11 Jun 2007 17:14:36 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH v2][RFC] Fix INTERLEAVE with memoryless nodes
Message-ID: <20070612001436.GI14458@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <Pine.LNX.4.64.0706111613100.23857@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111613100.23857@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [16:15:15 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > Christoph was also worried about the performance impact on these paths,
> > so, as he suggested, uninline alloc_pages_node() and move it to
> > mempolicy.c.
> 
> uninlining does not address performance issues.
> 
> > @@ -184,6 +185,16 @@ static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
> >  	atomic_set(&policy->refcnt, 1);
> >  	switch (mode) {
> >  	case MPOL_INTERLEAVE:
> > +		/*
> > +		 * Clear any memoryless nodes here so that v.nodes can be used
> > +		 * without extra checks
> > +		 */
> > +		nid = first_node(*nodes);
> > +		while (nid < MAX_NUMNODES) {
> > +			if (!node_populated(nid))
> > +				node_clear(nid, *nodes);
> > +			nid = next_node(nid, *nodes);
> > +		}
> 
> There is a "nodes_and" function for this.

Right, fixed.

> > @@ -1126,9 +1153,11 @@ static unsigned interleave_nodes(struct mempolicy *policy)
> >  	struct task_struct *me = current;
> >  
> >  	nid = me->il_next;
> > -	next = next_node(nid, policy->v.nodes);
> > -	if (next >= MAX_NUMNODES)
> > -		next = first_node(policy->v.nodes);
> > +	do {
> > +		next = next_node(nid, policy->v.nodes);
> > +		if (next >= MAX_NUMNODES)
> > +			next = first_node(policy->v.nodes);
> > +	} while (!node_populated(next));
> 
> Is there a case where nodes has no node set?

Well, if the only place to get a "new" policy is mpol_new(), no, as just
after the above nodes_and(), we check the weight of the nodemask. Is
that sufficient?

Based on ideas from Christoph Lameter, add checks in the INTERLEAVE
paths for memoryless nodes. We do not want to try interleaving onto
those nodes.

Christoph said:
"This does not work for the address based interleaving for anonymous
vmas.  I am not sure what to do there. We could change the calculation
of the node to be based only on nodes with memory and then skip the
memoryless ones. I have only added a comment to describe its brokennes
for now."

I have copied his draft's comment.

Change alloc_pages_node() to fail __GFP_THISNODE allocations if the node
is not populated.

Again, Christoph said:
"This will fix the alloc_pages_node case but not the alloc_pages() case.
In the alloc_pages() case we do not specify a node. Implicitly it is
understood that we (in the case of no memory policy / cpuset options)
allocate from the nearest node. So it may be argued there that the
GFP_THISNODE behavior of taking the first node from the zonelist is
okay."

Christoph was also worried about the performance impact on these paths,
as am I.

Finally, as he suggested, uninline alloc_pages_node() and move it to
mempolicy.c.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 49dcc2f..c83e56a 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -165,19 +165,7 @@ static inline void arch_alloc_page(struct page *page, int order) { }
 extern struct page *
 FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
 
-static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
-						unsigned int order)
-{
-	if (unlikely(order >= MAX_ORDER))
-		return NULL;
-
-	/* Unknown node is current node */
-	if (nid < 0)
-		nid = numa_node_id();
-
-	return __alloc_pages(gfp_mask, order,
-		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
-}
+extern struct page * alloc_pages_node(int, gfp_t, unsigned int);
 
 #ifdef CONFIG_NUMA
 extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 144805c..abadbf4 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -174,6 +174,7 @@ static struct zonelist *bind_zonelist(nodemask_t *nodes)
 static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
 {
 	struct mempolicy *policy;
+	unsigned nid;
 
 	PDprintk("setting mode %d nodes[0] %lx\n", mode, nodes_addr(*nodes)[0]);
 	if (mode == MPOL_DEFAULT)
@@ -184,8 +185,12 @@ static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
 	atomic_set(&policy->refcnt, 1);
 	switch (mode) {
 	case MPOL_INTERLEAVE:
-		policy->v.nodes = *nodes;
-		if (nodes_weight(*nodes) == 0) {
+		/*
+		 * Clear any memoryless nodes here so that v.nodes can be used
+		 * without extra checks
+		 */
+		nodes_and(policy->v.nodes, *nodes, node_populated_mask);
+		if (nodes_weight(policy->v.nodes) == 0) {
 			kmem_cache_free(policy_cache, policy);
 			return ERR_PTR(-EINVAL);
 		}
@@ -578,6 +583,22 @@ long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	return err;
 }
 
+struct page *alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
+{
+	if (unlikely(order >= MAX_ORDER))
+		return NULL;
+
+	/* Unknown node is current node */
+	if (nid < 0)
+		nid = numa_node_id();
+
+	if ((gfp_mask & __GFP_THISNODE) && !node_populated(nid))
+		return NULL;
+
+	return __alloc_pages(gfp_mask, order,
+		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
+}
+
 #ifdef CONFIG_MIGRATION
 /*
  * page migration
@@ -1126,9 +1147,11 @@ static unsigned interleave_nodes(struct mempolicy *policy)
 	struct task_struct *me = current;
 
 	nid = me->il_next;
-	next = next_node(nid, policy->v.nodes);
-	if (next >= MAX_NUMNODES)
-		next = first_node(policy->v.nodes);
+	do {
+		next = next_node(nid, policy->v.nodes);
+		if (next >= MAX_NUMNODES)
+			next = first_node(policy->v.nodes);
+	} while (!node_populated(next));
 	me->il_next = next;
 	return nid;
 }
@@ -1192,6 +1215,11 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
 		 * for huge pages, since vm_pgoff is in units of small
 		 * pages, we need to shift off the always 0 bits to get
 		 * a useful offset.
+		 *
+		 * NOTE: For configurations with memoryless nodes this
+		 * is broken since the allocation attempts on that node
+		 * will fall back to other nodes and thus one
+		 * neighboring node will be overallocated from.
 		 */
 		BUG_ON(shift < PAGE_SHIFT);
 		off = vma->vm_pgoff >> (shift - PAGE_SHIFT);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
