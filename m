Subject: [PATCH/RFC/WIP]  cpuset-independent interleave policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070727194322.18614.68855.sendpatchset@localhost>
	 <20070731192241.380e93a0.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
	 <20070731200522.c19b3b95.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
	 <20070731203203.2691ca59.akpm@linux-foundation.org>
	 <1185977011.5059.36.camel@localhost>
	 <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 02 Aug 2007 16:05:56 -0400
Message-Id: <1186085156.5040.83.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Against:  2.6.23-rc1-mm2 atop memoryless node patches with my patch
          to exclude selected nodes from interleave.

Work in Progress -- for discussion and comment

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
the nodemask that one could use to indicate the context-dependent interleave
mask is the empty set.  Coding-wise this would be simple:

	if (nodes_empty(mpol->v.nodes)) ...

However, this will involve testing possibly several words of
bitmask.  Instead, I chose to encode the "context-dependent policy"
indication in the upper bits of the policy member of the mempolicy
structure.  This member must already be tested to determine the
policy mode, so no extra memory references should be required.
However, for testing the policy--e.g., in the several switch()
and if() statements--the context flag must be masked off using the
policy_mode() inline function.  On the upside, this allows additional
flags to be so encoded, should that become useful.

Another potential issue is that this requires fetching the interleave
nodemask--either from the mempolicy struct or current_cpuset_mems_allowed,
depending on the context flag, during page allocation time.  However,
interleaving is already a fairly heavy-weight policy, so maybe this won't
be noticable.  I WILL take some performance data, "real soon now".

Functionally tested OK.  i.e., it appears to work.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mempolicy.h |   16 ++++++++++
 mm/mempolicy.c            |   72 +++++++++++++++++++++++++++++++---------------
 2 files changed, 66 insertions(+), 22 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-08-02 15:42:18.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-08-02 15:42:20.000000000 -0400
@@ -123,12 +123,15 @@ static int mpol_check_policy(int mode, n
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
 	return nodes_subset(*nodes, node_online_map) ? 0 : -EINVAL;
 }
@@ -187,6 +190,10 @@ static struct mempolicy *mpol_new(int mo
 	switch (mode) {
 	case MPOL_INTERLEAVE:
 		policy->v.nodes = *nodes;
+ 		if (nodes_weight(*nodes) == 0) {
+ 			mode |= MPOL_CONTEXT;
+			break;
+		}
 		nodes_and(policy->v.nodes, policy->v.nodes,
 					node_states[N_INTERLEAVE]);
 		if (nodes_weight(policy->v.nodes) == 0) {
@@ -462,6 +469,19 @@ static void mpol_set_task_struct_flag(vo
 	mpol_fix_fork_child_flag(current);
 }
 
+/*
+ * Return node mask of specified [possibly contextualized] interleave policy.
+ */
+static nodemask_t *get_interleave_nodes(struct mempolicy *p)
+{
+	VM_BUG_ON(policy_mode(p) != MPOL_INTERLEAVE);
+
+	if (unlikely(p->policy & MPOL_CONTEXT)) {
+		return &cpuset_current_mems_allowed;
+	}
+	return &p->v.nodes;
+}
+
 /* Set the process memory policy */
 static long do_set_mempolicy(int mode, nodemask_t *nodes)
 {
@@ -475,8 +495,8 @@ static long do_set_mempolicy(int mode, n
 	mpol_free(current->mempolicy);
 	current->mempolicy = new;
 	mpol_set_task_struct_flag();
-	if (new && new->policy == MPOL_INTERLEAVE)
-		current->il_next = first_node(new->v.nodes);
+	if (new && policy_mode(new) == MPOL_INTERLEAVE)
+		current->il_next = first_node(*get_interleave_nodes(new));
 	return 0;
 }
 
@@ -488,7 +508,7 @@ static void get_nodemask(struct mempolic
 	int i;
 
 	nodes_clear(*nodes);
-	switch (p->policy) {
+	switch (policy_mode(p)) {
 	case MPOL_BIND:
 		for (i = 0; p->v.zonelist->zones[i]; i++)
 			node_set(zone_to_nid(p->v.zonelist->zones[i]),
@@ -497,7 +517,7 @@ static void get_nodemask(struct mempolic
 	case MPOL_DEFAULT:
 		break;
 	case MPOL_INTERLEAVE:
-		*nodes = p->v.nodes;
+		*nodes = *get_interleave_nodes(p);
 		break;
 	case MPOL_PREFERRED:
 		/*
@@ -562,7 +582,7 @@ static long do_get_mempolicy(int *policy
 				goto out;
 			*policy = err;
 		} else if (pol == current->mempolicy &&
-				pol->policy == MPOL_INTERLEAVE) {
+				policy_mode(pol) == MPOL_INTERLEAVE) {
 			*policy = current->il_next;
 		} else {
 			err = -EINVAL;
@@ -1105,7 +1125,7 @@ static struct zonelist *zonelist_policy(
 {
 	int nd;
 
-	switch (policy->policy) {
+	switch (policy_mode(policy)) {
 	case MPOL_PREFERRED:
 		nd = policy->v.preferred_node;
 		if (nd < 0)
@@ -1133,13 +1153,13 @@ static struct zonelist *zonelist_policy(
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
 
@@ -1149,7 +1169,7 @@ static unsigned interleave_nodes(struct 
  */
 unsigned slab_node(struct mempolicy *policy)
 {
-	int pol = policy ? policy->policy : MPOL_DEFAULT;
+	int pol = policy ? policy_mode(policy) : MPOL_DEFAULT;
 
 	switch (pol) {
 	case MPOL_INTERLEAVE:
@@ -1176,14 +1196,15 @@ unsigned slab_node(struct mempolicy *pol
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
@@ -1218,7 +1239,7 @@ struct zonelist *huge_zonelist(struct vm
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 
-	if (pol->policy == MPOL_INTERLEAVE) {
+	if (policy_mode(pol) == MPOL_INTERLEAVE) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
@@ -1272,7 +1293,7 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 
 	cpuset_update_task_memory_state();
 
-	if (unlikely(pol->policy == MPOL_INTERLEAVE)) {
+	if (unlikely(policy_mode(pol) == MPOL_INTERLEAVE)) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
@@ -1308,7 +1329,7 @@ struct page *alloc_pages_current(gfp_t g
 		cpuset_update_task_memory_state();
 	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
 		pol = &default_policy;
-	if (pol->policy == MPOL_INTERLEAVE)
+	if (policy_mode(pol) == MPOL_INTERLEAVE)
 		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
 	return __alloc_pages(gfp, order, zonelist_policy(gfp, pol));
 }
@@ -1353,11 +1374,12 @@ int __mpol_equal(struct mempolicy *a, st
 		return 0;
 	if (a->policy != b->policy)
 		return 0;
-	switch (a->policy) {
+	switch (policy_mode(a)) {
 	case MPOL_DEFAULT:
 		return 1;
 	case MPOL_INTERLEAVE:
-		return nodes_equal(a->v.nodes, b->v.nodes);
+		return a->policy & MPOL_CONTEXT ||
+			nodes_equal(a->v.nodes, b->v.nodes);
 	case MPOL_PREFERRED:
 		return a->v.preferred_node == b->v.preferred_node;
 	case MPOL_BIND: {
@@ -1679,6 +1701,11 @@ static void mpol_rebind_policy(struct me
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
@@ -1765,7 +1792,7 @@ static inline int mpol_to_str(char *buff
 	char *p = buffer;
 	int nid, l;
 	nodemask_t nodes;
-	int mode = pol ? pol->policy : MPOL_DEFAULT;
+	int mode = pol ? policy_mode(pol) : MPOL_DEFAULT;
 
 	switch (mode) {
 	case MPOL_DEFAULT:
@@ -1790,7 +1817,8 @@ static inline int mpol_to_str(char *buff
 		break;
 
 	case MPOL_INTERLEAVE:
-		nodes = pol->v.nodes;
+		nodes = *get_interleave_nodes(pol);
+		// TODO:  or show indication of context-dependent interleave?
 		break;
 
 	default:
Index: Linux/include/linux/mempolicy.h
===================================================================
--- Linux.orig/include/linux/mempolicy.h	2007-08-02 15:42:18.000000000 -0400
+++ Linux/include/linux/mempolicy.h	2007-08-02 15:42:20.000000000 -0400
@@ -15,6 +15,13 @@
 #define MPOL_INTERLEAVE	3
 
 #define MPOL_MAX MPOL_INTERLEAVE
+#define MPOL_MODE 0x0ff		/* reserve 8 bits for policy "mode" */
+
+/*
+ * OR'd into struct mempolicy 'policy' member for "context-dependent interleave" --
+ * i.e., interleave across all nodes allowed in current context.
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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
