Subject: [PATCH] Use MPOL_PREFERRED for system default policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Tue, 14 Aug 2007 15:44:31 -0400
Message-Id: <1187120671.6281.67.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Christoph, Andi:

What do you think of this?  OK to merge? 

Also, Michael Kerrisk has been pinging you about the man page updates I
posted.  If we can get those in, I'll post additional updates for any
cleanups like this.  I can send you patches/formatted copies of the
updated man pages, if you like.

Lee

------------------
PATCH/RFC Use MPOL_PREFERRED for system-wide default policy

Against:  2.6.23-rc2-mm2

Currently, when one specifies MPOL_DEFAULT via a NUMA memory
policy API [set_mempolicy(), mbind() and internal versions],
the kernel simply installs a NULL struct mempolicy pointer in
the appropriate context:  task policy, vma policy, or shared
policy.  This causes any use of that policy to "fall back" to
the next most specific policy scope.  The only use of MPOL_DEFAULT
to mean "local allocation" is in the system default policy.

There is another, "preferred" way to specify local allocation via
the APIs.  That is using the MPOL_PREFERRED policy mode with an
empty nodemask.  Internally, the empty nodemask gets converted to
a preferred_node id of '-1'.  All internal usage of MPOL_PREFERRED
will convert the '-1' to the local node id.

Now, system default policy, except during boot, is "local 
allocation".  By using the MPOL_PREFERRED mode with a negative
value of preferred node for system default policy, MPOL_DEFAULT
will never occur in the 'policy' member of a struct mempolicy.
Thus, we can remove all checks for MPOL_DEFAULT when converting
policy to a node id/zonelist in the allocation paths.

Note:  in slab_node() I kept the use of MPOL_DEFAULT when the
policy pointer is NULL to force the switch to take the default:
case.  This seemed more efficient than pointing policy at the
system default, and having to deref that.  Any value not covered
by one of the existing case's would have served, but MPOL_DEFAULT
is guaranteed to be a different value from any of the other MPOL_*
handled explicitly by the switch.

With this patch MPOL_DEFAULT is just used in the APIs, including
internal calls to do_set_mempolicy() and in the display of policy
in /proc/<pid>/numa_maps.  It always means "fall back" to the the
next most specific policy scope.  This simplifies the description
of memory policies quite a bit, with no visible change in behavior.

Change the "BUG()s" in default switch(policy) cases [unexpected
policy] to WARN_ON_ONCE(1), and try to do "something reasonable".
It doesn't seem worth bugging out, possibly leaving locks held,
for this condition.

Tested with set_mempolicy() using numactl with memtoy, and
tested mbind() with memtoy.  All seems to work "as expected".

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/numa_memory_policy.txt |   70 ++++++++++++--------------------
 mm/mempolicy.c                          |   37 ++++++++--------
 2 files changed, 46 insertions(+), 61 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-08-14 15:07:27.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-08-14 15:08:12.000000000 -0400
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
 
 static void mpol_rebind_policy(struct mempolicy *pol,
@@ -492,8 +496,6 @@ static void get_zonemask(struct mempolic
 			node_set(zone_to_nid(p->v.zonelist->zones[i]),
 				*nodes);
 		break;
-	case MPOL_DEFAULT:
-		break;
 	case MPOL_INTERLEAVE:
 		*nodes = p->v.nodes;
 		break;
@@ -505,7 +507,11 @@ static void get_zonemask(struct mempolic
 			node_set(p->v.preferred_node, *nodes);
 		break;
 	default:
-		BUG();
+		/*
+		 * shouldn't happen
+		 */
+		WARN_ON_ONCE(1);
+		node_set(numa_node_id(), *nodes);
 	}
 }
 
@@ -1087,8 +1093,7 @@ static struct mempolicy * get_vma_policy
 	if (vma) {
 		if (vma->vm_ops && vma->vm_ops->get_policy)
 			pol = vma->vm_ops->get_policy(vma, addr);
-		else if (vma->vm_policy &&
-				vma->vm_policy->policy != MPOL_DEFAULT)
+		else if (vma->vm_policy)
 			pol = vma->vm_policy;
 	}
 	if (!pol)
@@ -1115,12 +1120,11 @@ static struct zonelist *zonelist_policy(
 				return policy->v.zonelist;
 		/*FALL THROUGH*/
 	case MPOL_INTERLEAVE: /* should not happen */
-	case MPOL_DEFAULT:
 		nd = numa_node_id();
 		break;
 	default:
-		nd = 0;
-		BUG();
+		WARN_ON_ONCE(1);
+		nd = numa_node_id();
 	}
 	return NODE_DATA(nd)->node_zonelists + gfp_zone(gfp);
 }
@@ -1350,8 +1354,6 @@ int __mpol_equal(struct mempolicy *a, st
 	if (a->policy != b->policy)
 		return 0;
 	switch (a->policy) {
-	case MPOL_DEFAULT:
-		return 1;
 	case MPOL_INTERLEAVE:
 		return nodes_equal(a->v.nodes, b->v.nodes);
 	case MPOL_PREFERRED:
@@ -1364,7 +1366,7 @@ int __mpol_equal(struct mempolicy *a, st
 		return b->v.zonelist->zones[i] == NULL;
 	}
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
 		return 0;
 	}
 }
@@ -1376,7 +1378,8 @@ void __mpol_free(struct mempolicy *p)
 		return;
 	if (p->policy == MPOL_BIND)
 		kfree(p->v.zonelist);
-	p->policy = MPOL_DEFAULT;
+	p->policy = MPOL_PREFERRED;
+	p->v.preferred_node = -1;
 	kmem_cache_free(policy_cache, p);
 }
 
@@ -1543,7 +1546,7 @@ void mpol_shared_policy_init(struct shar
 	if (policy != MPOL_DEFAULT) {
 		struct mempolicy *newpol;
 
-		/* Falls back to MPOL_DEFAULT on any error */
+		/* Falls back to NULL policy [MPOL_DEFAULT] on any error */
 		newpol = mpol_new(policy, policy_nodes);
 		if (!IS_ERR(newpol)) {
 			/* Create pseudo-vma that contains just the policy */
@@ -1664,8 +1667,6 @@ static void mpol_rebind_policy(struct me
 		return;
 
 	switch (pol->policy) {
-	case MPOL_DEFAULT:
-		break;
 	case MPOL_INTERLEAVE:
 		nodes_remap(tmp, pol->v.nodes, *mpolmask, *newmask);
 		pol->v.nodes = tmp;
@@ -1705,7 +1706,7 @@ static void mpol_rebind_policy(struct me
 		break;
 	}
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
 		break;
 	}
 }
@@ -1774,7 +1775,7 @@ static inline int mpol_to_str(char *buff
 		break;
 
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
 		return -EFAULT;
 	}
 
Index: Linux/Documentation/vm/numa_memory_policy.txt
===================================================================
--- Linux.orig/Documentation/vm/numa_memory_policy.txt	2007-08-14 15:07:27.000000000 -0400
+++ Linux/Documentation/vm/numa_memory_policy.txt	2007-08-14 15:07:29.000000000 -0400
@@ -149,63 +149,47 @@ Components of Memory Policies
 
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
