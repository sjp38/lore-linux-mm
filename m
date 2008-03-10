Subject: [PATCH/RFC] Mempolicy:  Use MPOL_PREFERRED for system-wide default
	policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Mon, 10 Mar 2008 15:02:52 -0400
Message-Id: <1205175772.5579.64.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

PATCH/RFC Mempolicy:  Use MPOL_PREFERRED for system-wide default policy

Against:  2.6.25-rc3-mm1 atop the following patches already in 
Andrew's tree:
[patch 1/6] mempolicy: convert MPOL constants to enum
[patch 2/6] mempolicy: support optional mode flags
[patch 3/6] mempolicy: add MPOL_F_STATIC_NODES flag
[patch 4/6] mempolicy: add bitmap_onto() and bitmap_fold() operations
[patch 5/6] mempolicy: add MPOL_F_RELATIVE_NODES flag
[patch 6/6] mempolicy: update NUMA memory policy documentation
[patch -mm 1/4] mempolicy: move rebind functions
[patch -mm 2/4] mempolicy: create mempolicy_operations structure
[patch -mm 3/4] mempolicy: small header file cleanup

and the following two patches currently under discussion:
[patch -mm v2] mempolicy: disallow static or relative flags for local preferred mode
+ fix to the "disallow..." patch

Note:  This patch belongs further down in a series of pending mempolicy
cleanup and fixes.  I'm resending as an RFC because there has been some
movement in this area that I think is better addressed by this cleanup.
Pending the results of the RFC, I would like to defer this patch and
submit with the rest of the series.  I plan to do that when mempolicy.c
has stabilized with the patches listed above.

V3 -> V4:
+ do_get_mempolicy():  return MPOL_DEFAULT and empty nodemask when
  specified policy "falls back" to system default policy.  Then, if
  the application uses these results in a subsequent syscall, we'll
  "do the right thing".

  NOTE:  do_get_mempolicy() incorrectly "falls back" to system
  default policy, instead of a non-default task policy, if a vma
  get_mempolicy() op returns NULL.  Fixed by a separate patch.

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
for MPOL_DEFAULT in many mempolicy.c functions.  It also requires
explanation of this dual meaning for MPOL_DEFAULT in the man pages
and kernel documentation.

There is another, "preferred", way to specify local allocation via
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

 Documentation/vm/numa_memory_policy.txt |   53 ++++++++++----------------------
 mm/mempolicy.c                          |   40 ++++++++++++++----------
 2 files changed, 41 insertions(+), 52 deletions(-)

Index: linux-2.6.25-rc3-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/mempolicy.c	2008-03-10 12:12:19.000000000 -0400
+++ linux-2.6.25-rc3-mm1/mm/mempolicy.c	2008-03-10 13:02:45.000000000 -0400
@@ -104,9 +104,13 @@ static struct kmem_cache *sn_cache;
    policied. */
 enum zone_type policy_zone = 0;
 
+/*
+ * run-time system-wide default policy => local allocation
+ */
 struct mempolicy default_policy = {
 	.refcnt = ATOMIC_INIT(1), /* never free it */
-	.policy = MPOL_DEFAULT,
+	.policy = MPOL_PREFERRED,
+	.v =  { .preferred_node =  -1 },
 };
 
 static const struct mempolicy_operations {
@@ -605,9 +609,10 @@ static long do_set_mempolicy(unsigned sh
 static void get_zonemask(struct mempolicy *p, nodemask_t *nodes)
 {
 	nodes_clear(*nodes);
+	if (p == &default_policy)
+		return;			/* backwards compatibility */
+
 	switch (p->policy) {
-	case MPOL_DEFAULT:
-		break;
 	case MPOL_BIND:
 		/* Fall through */
 	case MPOL_INTERLEAVE:
@@ -690,7 +695,9 @@ static long do_get_mempolicy(int *policy
 			err = -EINVAL;
 			goto out;
 		}
-	} else
+	} else if (pol == &default_policy)
+		*policy = MPOL_DEFAULT;		/* backwards compatibility */
+	else
 		*policy = pol->policy | pol->flags;
 
 	if (vma) {
@@ -1256,8 +1263,7 @@ static struct mempolicy * get_vma_policy
 		if (vma->vm_ops && vma->vm_ops->get_policy) {
 			pol = vma->vm_ops->get_policy(vma, addr);
 			shared_pol = 1;	/* if pol non-NULL, add ref below */
-		} else if (vma->vm_policy &&
-				vma->vm_policy->policy != MPOL_DEFAULT)
+		} else if (vma->vm_policy)
 			pol = vma->vm_policy;
 	}
 	if (!pol)
@@ -1303,7 +1309,6 @@ static struct zonelist *zonelist_policy(
 			nd = first_node(policy->v.nodes);
 		break;
 	case MPOL_INTERLEAVE: /* should not happen */
-	case MPOL_DEFAULT:
 		nd = numa_node_id();
 		break;
 	default:
@@ -1334,9 +1339,10 @@ static unsigned interleave_nodes(struct 
  */
 unsigned slab_node(struct mempolicy *policy)
 {
-	unsigned short pol = policy ? policy->policy : MPOL_DEFAULT;
+	if (!policy)
+		return numa_node_id();
 
-	switch (pol) {
+	switch (policy->policy) {
 	case MPOL_INTERLEAVE:
 		return interleave_nodes(policy);
 
@@ -1357,10 +1363,10 @@ unsigned slab_node(struct mempolicy *pol
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
 
@@ -1605,8 +1611,6 @@ int __mpol_equal(struct mempolicy *a, st
 	if (a->policy != MPOL_DEFAULT && !mpol_match_intent(a, b))
 		return 0;
 	switch (a->policy) {
-	case MPOL_DEFAULT:
-		return 1;
 	case MPOL_BIND:
 		/* Fall through */
 	case MPOL_INTERLEAVE:
@@ -1624,7 +1628,6 @@ void __mpol_free(struct mempolicy *p)
 {
 	if (!atomic_dec_and_test(&p->refcnt))
 		return;
-	p->policy = MPOL_DEFAULT;
 	kmem_cache_free(policy_cache, p);
 }
 
@@ -1791,7 +1794,7 @@ void mpol_shared_policy_init(struct shar
 	if (policy != MPOL_DEFAULT) {
 		struct mempolicy *newpol;
 
-		/* Falls back to MPOL_DEFAULT on any error */
+		/* Falls back to NULL policy [MPOL_DEFAULT] on any error */
 		newpol = mpol_new(policy, flags, policy_nodes);
 		if (!IS_ERR(newpol)) {
 			/* Create pseudo-vma that contains just the policy */
@@ -1915,9 +1918,14 @@ static inline int mpol_to_str(char *buff
 	char *p = buffer;
 	int l;
 	nodemask_t nodes;
-	unsigned short mode = pol ? pol->policy : MPOL_DEFAULT;
+	unsigned short mode;
 	unsigned short flags = pol ? pol->flags : 0;
 
+	if (!pol || pol == &default_policy)
+		mode = MPOL_DEFAULT;	/* compatibility:  display "default" */
+	else
+		mode = pol->policy;
+
 	switch (mode) {
 	case MPOL_DEFAULT:
 		nodes_clear(nodes);
Index: linux-2.6.25-rc3-mm1/Documentation/vm/numa_memory_policy.txt
===================================================================
--- linux-2.6.25-rc3-mm1.orig/Documentation/vm/numa_memory_policy.txt	2008-03-10 10:25:58.000000000 -0400
+++ linux-2.6.25-rc3-mm1/Documentation/vm/numa_memory_policy.txt	2008-03-10 12:49:12.000000000 -0400
@@ -151,35 +151,18 @@ Components of Memory Policies
 
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
+	    When specified in one of the memory policy APIs, the Default mode
+	    does not use the optional set of nodes.
 
 	    It is an error for the set of nodes specified for this policy to
 	    be non-empty.
@@ -191,19 +174,17 @@ Components of Memory Policies
 
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
 
 	    It is possible for the user to specify that local allocation is
 	    always preferred by passing an empty nodemask with this mode.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
