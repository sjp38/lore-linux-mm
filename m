From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 30 Aug 2007 14:51:22 -0400
Message-Id: <20070830185122.22619.56636.sendpatchset@localhost>
In-Reply-To: <20070830185053.22619.96398.sendpatchset@localhost>
References: <20070830185053.22619.96398.sendpatchset@localhost>
Subject: [PATCH/RFC 4/5] Mem Policy:  cpuset-independent interleave policy
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, solo@google.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC 04/05 - cpuset-independent interleave policy

Against:  2.6.23-rc3-mm1

Interleave memory policy uses physical node ideas.  When
a task executes in a cpuset, any policies that it installs
are constrained to use only nodes that are valid in the cpuset.
This makes is difficult to use shared policies--e.g., on shmem/shm
segments--in this environment; especially in disjoint cpusets.  Any
policy installed by a task in one of the cpusets is invalid in a
disjoint cpuset.

Local allocation, whether as a result of default policy or preferred
policy with the local preferred_node token [-1 internally, null/empty
nodemask in the APIs], does not suffer from this problem.  It is a
"context dependent" or cpuset-independent policy.

This patch introduces a cpuset-independent interleave policy that will
work in shared policies applied to shared memory segments attached by
tasks in disjoint cpusets.  The cpuset-independent policy effectively
says "interleave across all valid nodes in the context where page
allocation occurs."

API:  following the lead of the "preferred local" policy, a null or
empty node mask specified with MPOL_INTERLEAVE specifies "all nodes
valid in the allocating context."  

Internally, it's not quite as easy as storing a special token [node
id == -1] in the preferred_node member.  MPOL_INTERLEAVE policy uses
a nodemask embedded in the mempolicy structure.  The nodemask is
"unioned" with preferred_node.   The only otherwise invalid value of
the nodemask that one could use to indicate the context-dependent
interleave mask is the empty set.  Coding-wise this would be simple:

	if (nodes_empty(mpol->v.nodes)) ...

However, this will involve testing possibly several words of
bitmask in the allocation path.  Instead, I chose to encode the
"context-dependent policy" indication in the upper bits of the
policy member of the mempolicy structure.  This member must
already be tested to determine the policy mode, so no extra
memory references should be required.  However, for testing the
policy--e.g., in the several switch() and if() statements--the
context flag must be masked off using the policy_mode() inline
function.  On the upside, this allows additional flags to be so
encoded, should that become useful.

Another potential issue is that this requires fetching the
interleave nodemask--either from the mempolicy struct or
current_cpuset_mems_allowed, depending on the context flag, during
page allocation time.  However, interleaving is already a fairly
heavy-weight policy, so maybe this won't be noticable.

Functionally tested OK.  i.e., tasks in disjoint cpusets sharing
shmem with shared, cpuset-independent interleave policy.  it
appears to work.

TODO:  see intentional '// TODO' in patch

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/numa_memory_policy.txt |   15 +++++-
 include/linux/mempolicy.h               |   16 ++++++
 mm/mempolicy.c                          |   74 ++++++++++++++++++++++----------
 3 files changed, 80 insertions(+), 25 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-08-30 13:36:04.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-08-30 13:37:51.000000000 -0400
@@ -128,12 +128,15 @@ static int mpol_check_policy(int mode, n
 			return -EINVAL;
 		break;
 	case MPOL_BIND:
-	case MPOL_INTERLEAVE:
 		/* Preferred will only use the first bit, but allow
 		   more for now. */
 		if (empty)
 			return -EINVAL;
 		break;
+	case MPOL_INTERLEAVE:
+		if (empty)
+			return 0;	/* context dependent interleave */
+		break;
 	}
  	return nodes_subset(*nodes, node_states[N_HIGH_MEMORY]) ? 0 : -EINVAL;
 }
@@ -193,6 +196,10 @@ static struct mempolicy *mpol_new(int mo
 	switch (mode) {
 	case MPOL_INTERLEAVE:
 		policy->v.nodes = *nodes;
+		if (nodes_weight(*nodes) == 0) {
+			mode |= MPOL_CONTEXT;
+			break;
+		}
 		nodes_and(policy->v.nodes, policy->v.nodes,
 					node_states[N_HIGH_MEMORY]);
 		if (nodes_weight(policy->v.nodes) == 0) {
@@ -468,6 +475,19 @@ static void mpol_set_task_struct_flag(vo
 	mpol_fix_fork_child_flag(current);
 }
 
+/*
+ * Return node mask of specified [possibly contextualized] interleave policy.
+ */
+static nodemask_t *get_interleave_nodes(struct mempolicy *p)
+{
+	VM_BUG_ON(policy_mode(p) != MPOL_INTERLEAVE);
+
+	if (unlikely(p->policy & MPOL_CONTEXT))
+		return &cpuset_current_mems_allowed;
+
+	return &p->v.nodes;
+}
+
 /* Set the process memory policy */
 static long do_set_mempolicy(int mode, nodemask_t *nodes)
 {
@@ -481,8 +501,8 @@ static long do_set_mempolicy(int mode, n
 	mpol_free(current->mempolicy);
 	current->mempolicy = new;
 	mpol_set_task_struct_flag();
-	if (new && new->policy == MPOL_INTERLEAVE)
-		current->il_next = first_node(new->v.nodes);
+	if (new && policy_mode(new) == MPOL_INTERLEAVE)
+		current->il_next = first_node(*get_interleave_nodes(new));
 	return 0;
 }
 
@@ -494,14 +514,14 @@ static void get_policy_nodemask(struct m
 	int i;
 
 	nodes_clear(*nodes);
-	switch (p->policy) {
+	switch (policy_mode(p)) {
 	case MPOL_BIND:
 		for (i = 0; p->v.zonelist->zones[i]; i++)
 			node_set(zone_to_nid(p->v.zonelist->zones[i]),
 				*nodes);
 		break;
 	case MPOL_INTERLEAVE:
-		*nodes = p->v.nodes;
+		*nodes = *get_interleave_nodes(p);
 		break;
 	case MPOL_PREFERRED:
 		/*
@@ -566,7 +586,7 @@ static long do_get_mempolicy(int *policy
 				goto out;
 			*policy = err;
 		} else if (pol == current->mempolicy &&
-				pol->policy == MPOL_INTERLEAVE) {
+				policy_mode(pol) == MPOL_INTERLEAVE) {
 			*policy = current->il_next;
 		} else {
 			err = -EINVAL;
@@ -1128,7 +1148,7 @@ static struct zonelist *zonelist_policy(
 {
 	int nd;
 
-	switch (policy->policy) {
+	switch (policy_mode(policy)) {
 	case MPOL_PREFERRED:
 		nd = policy->v.preferred_node;
 		if (nd < 0)
@@ -1155,13 +1175,13 @@ static struct zonelist *zonelist_policy(
 static unsigned interleave_nodes(struct mempolicy *policy)
 {
 	unsigned nid, next;
-	struct task_struct *me = current;
+	nodemask_t *nodes = get_interleave_nodes(policy);
 
-	nid = me->il_next;
-	next = next_node(nid, policy->v.nodes);
+	nid = current->il_next;
+	next = next_node(nid, *nodes);
 	if (next >= MAX_NUMNODES)
-		next = first_node(policy->v.nodes);
-	me->il_next = next;
+		next = first_node(*nodes);
+	current->il_next = next;
 	return nid;
 }
 
@@ -1174,7 +1194,7 @@ unsigned slab_node(struct mempolicy *pol
 	if (!policy)
 		return numa_node_id();
 
-	switch (policy->policy) {
+	switch (policy_mode(policy)) {
 	case MPOL_INTERLEAVE:
 		return interleave_nodes(policy);
 
@@ -1199,14 +1219,15 @@ unsigned slab_node(struct mempolicy *pol
 static unsigned offset_il_node(struct mempolicy *pol,
 		struct vm_area_struct *vma, unsigned long off)
 {
-	unsigned nnodes = nodes_weight(pol->v.nodes);
+	nodemask_t *nodes = get_interleave_nodes(pol);
+	unsigned nnodes = nodes_weight(*nodes);
 	unsigned target = (unsigned)off % nnodes;
 	int c;
 	int nid = -1;
 
 	c = 0;
 	do {
-		nid = next_node(nid, pol->v.nodes);
+		nid = next_node(nid, *nodes);
 		c++;
 	} while (c <= target);
 	return nid;
@@ -1258,7 +1279,7 @@ struct zonelist *huge_zonelist(struct vm
 	struct zonelist *zl;
 
 	*mpol = NULL;		/* probably no unref needed */
-	if (pol->policy == MPOL_INTERLEAVE) {
+	if (policy_mode(pol) == MPOL_INTERLEAVE) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
@@ -1268,7 +1289,7 @@ struct zonelist *huge_zonelist(struct vm
 
 	zl = zonelist_policy(GFP_HIGHUSER, pol);
 	if (unlikely(pol != &default_policy && pol != current->mempolicy)) {
-		if (pol->policy != MPOL_BIND)
+		if (policy_mode(pol) != MPOL_BIND)
 			__mpol_free(pol);	/* finished with pol */
 		else
 			*mpol = pol;	/* unref needed after allocation */
@@ -1322,7 +1343,7 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 
 	cpuset_update_task_memory_state();
 
-	if (unlikely(pol->policy == MPOL_INTERLEAVE)) {
+	if (unlikely(policy_mode(pol) == MPOL_INTERLEAVE)) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
@@ -1370,7 +1391,7 @@ struct page *alloc_pages_current(gfp_t g
 		cpuset_update_task_memory_state();
 	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
 		pol = &default_policy;
-	if (pol->policy == MPOL_INTERLEAVE)
+	if (policy_mode(pol) == MPOL_INTERLEAVE)
 		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
 	return __alloc_pages(gfp, order, zonelist_policy(gfp, pol));
 }
@@ -1415,9 +1436,10 @@ int __mpol_equal(struct mempolicy *a, st
 		return 0;
 	if (a->policy != b->policy)
 		return 0;
-	switch (a->policy) {
+	switch (policy_mode(a)) {
 	case MPOL_INTERLEAVE:
-		return nodes_equal(a->v.nodes, b->v.nodes);
+		return a->policy & MPOL_CONTEXT ||
+			nodes_equal(a->v.nodes, b->v.nodes);
 	case MPOL_PREFERRED:
 		return a->v.preferred_node == b->v.preferred_node;
 	case MPOL_BIND: {
@@ -1735,6 +1757,11 @@ static void mpol_rebind_policy(struct me
 		current->il_next = node_remap(current->il_next,
 						*mpolmask, *newmask);
 		break;
+	case MPOL_INTERLEAVE|MPOL_CONTEXT:
+		/*
+		 * No remap necessary for contextual interleave
+		 */
+		break;
 	case MPOL_PREFERRED:
 		/*
 		 * no need to remap "local policy"
@@ -1821,7 +1848,7 @@ static inline int mpol_to_str(char *buff
 	char *p = buffer;
 	int nid, l;
 	nodemask_t nodes;
-	int mode = pol ? pol->policy : MPOL_DEFAULT;
+	int mode = pol ? policy_mode(pol) : MPOL_DEFAULT;
 
 	switch (mode) {
 	case MPOL_DEFAULT:
@@ -1846,7 +1873,8 @@ static inline int mpol_to_str(char *buff
 		break;
 
 	case MPOL_INTERLEAVE:
-		nodes = pol->v.nodes;
+		nodes = *get_interleave_nodes(pol);
+// TODO:  or show indication of context-dependent interleave?
 		break;
 
 	default:
Index: Linux/include/linux/mempolicy.h
===================================================================
--- Linux.orig/include/linux/mempolicy.h	2007-08-30 13:36:04.000000000 -0400
+++ Linux/include/linux/mempolicy.h	2007-08-30 13:38:33.000000000 -0400
@@ -15,6 +15,13 @@
 #define MPOL_INTERLEAVE	3
 
 #define MPOL_MAX MPOL_INTERLEAVE
+#define MPOL_MODE 0x0ff		/* reserve 8 bits for policy "mode" */
+
+/*
+ * OR'd into struct mempolicy 'policy' member for "context-dependent interleave"
+ * -- i.e., interleave across all nodes allowed in current context.
+ */
+#define MPOL_CONTEXT  (1 << 8)
 
 /* Flags for get_mem_policy */
 #define MPOL_F_NODE	(1<<0)	/* return next IL mode instead of node mask */
@@ -72,6 +79,15 @@ struct mempolicy {
 };
 
 /*
+ * Return 'policy' [a.k.a. 'mode'] member of mpol, less CONTEXT
+ * or any other modifiers.
+ */
+static inline int policy_mode(struct mempolicy *mpol)
+{
+	return mpol->policy & MPOL_MODE;
+}
+
+/*
  * Support for managing mempolicy data objects (clone, copy, destroy)
  * The default fast path of a NULL MPOL_DEFAULT policy is always inlined.
  */
Index: Linux/Documentation/vm/numa_memory_policy.txt
===================================================================
--- Linux.orig/Documentation/vm/numa_memory_policy.txt	2007-08-30 13:36:04.000000000 -0400
+++ Linux/Documentation/vm/numa_memory_policy.txt	2007-08-30 13:36:07.000000000 -0400
@@ -193,7 +193,15 @@ Components of Memory Policies
 
 	MPOL_INTERLEAVED:  This mode specifies that page allocations be
 	interleaved, on a page granularity, across the nodes specified in
-	the policy.  This mode also behaves slightly differently, based on
+	the policy.
+
+	If an empty nodemask is supplied to the MPOL_INTERLEAVED mode via one
+	of the memory policy APIs, the kernel treats this as "contextual
+	interleave".  That is, it will interleave allocates across all nodes
+	that are allowed in the context [cpuset] where the allocation occurs.
+	See the discussion of MEMORY POLICIES AND CPUSETS below.
+
+	The MPOL_INTERLEAVED mode also behaves slightly differently, based on
 	the context where it is used:
 
 	    For allocation of anonymous pages and shared memory pages,
@@ -313,4 +321,7 @@ couple of reasons:
    the memory policy APIs, as well as knowing in what cpusets other task might
    be attaching to the shared region, to use the cpuset information.
    Furthermore, if the cpusets' allowed memory sets are disjoint, "local"
-   allocation is the only valid policy.
+
+Note, however, that local allocation, whether specified by MPOL_DEFAULT or
+MPOL_PREFERRED with an empty nodemask and "contextual interleave"--
+MPOL_INTERLEAVE with an empty nodemask--are valid policies in any context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
