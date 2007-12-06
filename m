From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 06 Dec 2007 16:21:23 -0500
Message-Id: <20071206212123.6279.22285.sendpatchset@localhost>
In-Reply-To: <20071206212047.6279.10881.sendpatchset@localhost>
References: <20071206212047.6279.10881.sendpatchset@localhost>
Subject: [PATCH/RFC 6/8] Mem Policy:  Use MPOL_PREFERRED for system-wide default policy
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, clameter@sgi.com, ak@suse.de, eric.whitney@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

PATCH/RFC 06/08 Mem Policy:  Use MPOL_PREFERRED for system-wide default policy

Against:  2.6.24-rc2-mm1

V2 -> V3:
+ mpol_to_str():  show "default" policy when &default_policy is
  passed in, rather than the details of the default_policy, in
  /proc/<pid>/numa_maps.

V1 -> V2:
+ restore BUG()s in switch(policy) default cases -- per
  Christoph
+ eliminate unneeded re-init of struct mempolicy policy member
  before freeing

Currently, when one specifies MPOL_DEFAULT via a NUMA memory
policy API [set_mempolicy(), mbind() and internal versions],
the kernel simply installs a NULL struct mempolicy pointer in
the appropriate context:  task policy, vma policy, or shared
policy.  This causes any use of that policy to "fall back" to
the next most specific policy scope.

The only use of MPOL_DEFAULT to mean "local allocation" is in
the system default policy.  This requires extra checks/cases
for MPOL_DEFAULT in many mempolicy.c functions.

There is another, "preferred" way to specify local allocation via
the APIs.  That is using the MPOL_PREFERRED policy mode with an
empty nodemask.  Internally, the empty nodemask gets converted to
a preferred_node id of '-1'.  All internal usage of MPOL_PREFERRED
will convert the '-1' to the id of the node local to the cpu 
where the allocation occurs.

System default policy, except during boot, is hard-coded to
"local allocation".  By using the MPOL_PREFERRED mode with a
negative value of preferred node for system default policy,
MPOL_DEFAULT will never occur in the 'policy' member of a
struct mempolicy.  Thus, we can remove all checks for
MPOL_DEFAULT when converting policy to a node id/zonelist in
the allocation paths.

In slab_node() return local node id when policy pointer is NULL.
No need to set a pol value to take the switch default.  Replace
switch default with BUG()--i.e., shouldn't happen.

With this patch MPOL_DEFAULT is only used in the APIs, including
internal calls to do_set_mempolicy() and in the display of policy
in /proc/<pid>/numa_maps.  It always means "fall back" to the the
next most specific policy scope.  This simplifies the description
of memory policies quite a bit, with no visible change in behavior.
This patch updates Documentation to reflect this change.

Tested with set_mempolicy() using numactl with memtoy, and
tested mbind() with memtoy.  All seems to work "as expected".

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/numa_memory_policy.txt |   70 ++++++++++++--------------------
 mm/mempolicy.c                          |   38 +++++++++--------
 2 files changed, 47 insertions(+), 61 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-12-06 14:18:34.000000000 -0500
+++ Linux/mm/mempolicy.c	2007-12-06 14:20:17.000000000 -0500
@@ -105,9 +105,13 @@ static struct kmem_cache *sn_cache;
    policied. */
 enum zone_type policy_zone = 0;
 
+/*
+ * run-time system-wide default policy => local allocation
+ */
 struct mempolicy default_policy = {
 	.refcnt = ATOMIC_INIT(1), /* never free it */
-	.mode   = MPOL_DEFAULT,
+	.mode = MPOL_PREFERRED,
+	.v =  { .preferred_node =  -1 },
 };
 
 static struct mempolicy *get_vma_policy(struct task_struct *task,
@@ -166,7 +170,8 @@ static struct mempolicy *mpol_new(int mo
 		 mode, nodes ? nodes_addr(*nodes)[0] : -1);
 
 	if (mode == MPOL_DEFAULT)
-		return NULL;
+		return NULL;	/* simply delete any existing policy */
+
 	policy = kmem_cache_alloc(policy_cache, GFP_KERNEL);
 	if (!policy)
 		return ERR_PTR(-ENOMEM);
@@ -484,8 +489,6 @@ static void get_zonemask(struct mempolic
 {
 	nodes_clear(*nodes);
 	switch (policy_mode(p)) {
-	case MPOL_DEFAULT:
-		break;
 	case MPOL_BIND:
 		/* Fall through */
 	case MPOL_INTERLEAVE:
@@ -1130,8 +1133,7 @@ static struct mempolicy *get_vma_policy(
 									addr);
 			if (vpol)
 				pol = vpol;
-		} else if (vma->vm_policy &&
-				policy_mode(vma->vm_policy) != MPOL_DEFAULT)
+		} else if (vma->vm_policy)
 			pol = vma->vm_policy;
 	}
 	if (!pol)
@@ -1175,7 +1177,6 @@ static struct zonelist *zonelist_policy(
 			nd = first_node(policy->v.nodes);
 		break;
 	case MPOL_INTERLEAVE: /* should not happen */
-	case MPOL_DEFAULT:
 		nd = numa_node_id();
 		break;
 	default:
@@ -1209,9 +1210,10 @@ static unsigned interleave_nodes(struct 
  */
 unsigned slab_node(struct mempolicy *policy)
 {
-	int pol = policy ? policy_mode(policy) : MPOL_DEFAULT;
+	if (!policy)
+		return numa_node_id();
 
-	switch (pol) {
+	switch (policy_mode(policy)) {
 	case MPOL_INTERLEAVE:
 		return interleave_nodes(policy);
 
@@ -1232,10 +1234,10 @@ unsigned slab_node(struct mempolicy *pol
 	case MPOL_PREFERRED:
 		if (policy->v.preferred_node >= 0)
 			return policy->v.preferred_node;
-		/* Fall through */
+		return numa_node_id();
 
 	default:
-		return numa_node_id();
+		BUG();
 	}
 }
 
@@ -1450,8 +1452,6 @@ int __mpol_equal(struct mempolicy *a, st
 		return 0;
 
  	switch (policy_mode(a)) {
-	case MPOL_DEFAULT:
-		return 1;
 	case MPOL_BIND:
 		/* Fall through */
 	case MPOL_INTERLEAVE:
@@ -1469,7 +1469,6 @@ void __mpol_free(struct mempolicy *p)
 {
 	if (!atomic_dec_and_test(&p->refcnt))
 		return;
-	p->mode = MPOL_DEFAULT;
 	kmem_cache_free(policy_cache, p);
 }
 
@@ -1637,7 +1636,7 @@ void mpol_shared_policy_init(struct shar
 	if (policy != MPOL_DEFAULT) {
 		struct mempolicy *newpol;
 
-		/* Falls back to MPOL_DEFAULT on any error */
+		/* Falls back to NULL policy [MPOL_DEFAULT] on any error */
 		newpol = mpol_new(policy, policy_nodes);
 		if (!IS_ERR(newpol)) {
 			/* Create pseudo-vma that contains just the policy */
@@ -1758,8 +1757,6 @@ static void mpol_rebind_policy(struct me
 		return;
 
 	switch (policy_mode(pol)) {
-	case MPOL_DEFAULT:
-		break;
 	case MPOL_BIND:
 		/* Fall through */
 	case MPOL_INTERLEAVE:
@@ -1823,7 +1820,12 @@ static inline int mpol_to_str(char *buff
 	char *p = buffer;
 	int l;
 	nodemask_t nodes;
-	int mode = pol ? policy_mode(pol) : MPOL_DEFAULT;
+	int mode;
+
+	if (!pol || pol == &default_policy)
+		mode = MPOL_DEFAULT;
+	else
+		mode = policy_mode(pol);
 
 	switch (mode) {
 	case MPOL_DEFAULT:
Index: Linux/Documentation/vm/numa_memory_policy.txt
===================================================================
--- Linux.orig/Documentation/vm/numa_memory_policy.txt	2007-12-06 14:18:34.000000000 -0500
+++ Linux/Documentation/vm/numa_memory_policy.txt	2007-12-06 14:18:39.000000000 -0500
@@ -145,63 +145,47 @@ Components of Memory Policies
 
    Linux memory policy supports the following 4 behavioral modes:
 
-	Default Mode--MPOL_DEFAULT:  The behavior specified by this mode is
-	context or scope dependent.
+	Default Mode--MPOL_DEFAULT:  This mode is only used in the memory
+	policy APIs.  Internally, MPOL_DEFAULT is converted to the NULL
+	memory policy in all policy scopes.  Any existing non-default policy
+	will simply be removed when MPOL_DEFAULT is specified.  As a result,
+	MPOL_DEFAULT means "fall back to the next most specific policy scope."
+
+	    For example, a NULL or default task policy will fall back to the
+	    system default policy.  A NULL or default vma policy will fall
+	    back to the task policy.
 
-	    As mentioned in the Policy Scope section above, during normal
-	    system operation, the System Default Policy is hard coded to
-	    contain the Default mode.
-
-	    In this context, default mode means "local" allocation--that is
-	    attempt to allocate the page from the node associated with the cpu
-	    where the fault occurs.  If the "local" node has no memory, or the
-	    node's memory can be exhausted [no free pages available], local
-	    allocation will "fallback to"--attempt to allocate pages from--
-	    "nearby" nodes, in order of increasing "distance".
-
-		Implementation detail -- subject to change:  "Fallback" uses
-		a per node list of sibling nodes--called zonelists--built at
-		boot time, or when nodes or memory are added or removed from
-		the system [memory hotplug].  These per node zonelist are
-		constructed with nodes in order of increasing distance based
-		on information provided by the platform firmware.
-
-	    When a task/process policy or a shared policy contains the Default
-	    mode, this also means "local allocation", as described above.
-
-	    In the context of a VMA, Default mode means "fall back to task
-	    policy"--which may or may not specify Default mode.  Thus, Default
-	    mode can not be counted on to mean local allocation when used
-	    on a non-shared region of the address space.  However, see
-	    MPOL_PREFERRED below.
-
-	    The Default mode does not use the optional set of nodes.
+	    When specified in one of the memory policy APIs, the Default mode
+	    does not use the optional set of nodes.
 
 	MPOL_BIND:  This mode specifies that memory must come from the
 	set of nodes specified by the policy.
 
 	    The memory policy APIs do not specify an order in which the nodes
-	    will be searched.  However, unlike "local allocation", the Bind
-	    policy does not consider the distance between the nodes.  Rather,
-	    allocations will fallback to the nodes specified by the policy in
-	    order of numeric node id.  Like everything in Linux, this is subject
-	    to change.
+	    will be searched.  However, unlike "local allocation" discussed
+	    below, the Bind policy does not consider the distance between the
+	    nodes.  Rather, allocations will fallback to the nodes specified
+	    by the policy in order of numeric node id.  Like everything in
+	    Linux, this is subject to change.
 
 	MPOL_PREFERRED:  This mode specifies that the allocation should be
 	attempted from the single node specified in the policy.  If that
-	allocation fails, the kernel will search other nodes, exactly as
-	it would for a local allocation that started at the preferred node
-	in increasing distance from the preferred node.  "Local" allocation
-	policy can be viewed as a Preferred policy that starts at the node
-	containing the cpu where the allocation takes place.
+	allocation fails, the kernel will search other nodes, in order of
+	increasing distance from the preferred node based on information
+	provided by the platform firmware.
 
 	    Internally, the Preferred policy uses a single node--the
 	    preferred_node member of struct mempolicy.  A "distinguished
 	    value of this preferred_node, currently '-1', is interpreted
 	    as "the node containing the cpu where the allocation takes
-	    place"--local allocation.  This is the way to specify
-	    local allocation for a specific range of addresses--i.e. for
-	    VMA policies.
+	    place"--local allocation.  "Local" allocation policy can be
+	    viewed as a Preferred policy that starts at the node containing
+	    the cpu where the allocation takes place.
+
+	    As mentioned in the Policy Scope section above, during normal
+	    system operation, the System Default Policy is hard coded to
+	    specify "local allocation".  This policy uses the Preferred
+	    policy with the special negative value of preferred_node.
 
 	MPOL_INTERLEAVED:  This mode specifies that page allocations be
 	interleaved, on a page granularity, across the nodes specified in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
