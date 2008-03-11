Subject: [PATCH -mm v3] mempolicy: disallow static or relative flags for
	local preferred mode
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0803081409260.12095@chino.kir.corp.google.com>
References: <alpine.DEB.1.00.0803081409260.12095@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Tue, 11 Mar 2008 15:21:51 -0400
Message-Id: <1205263312.5293.19.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

David, Andrew:  I've rebased David's recent patch--the one with
"significant-looking reject"--atop 25-rc5-mm1 and retested.

Lee

mempolicy: disallow static or relative flags for local preferred mode

Against:  2.6.25-rc5-mm1

V2 -> V3 [lts]:
+ rebased to 25-rc5-mm1
+ preserved behavior of MPOL_PREFERRED w/ non-empty nodemask containing
  only dis-allowed nodes.
+ pulled the setting of policy->flags outside of the "if(nodes)..."
  block as future flags might not be associated only with nodemasks
  as STATIC and RELATIVE are.  This is safe, now that David disallows
  these flags for the case of MPOL_PREFERRED with empty nodemask.
+ dropped the localalloc variable in favor of just NULLing out nodes
  pointer to indicate "local preferred" mode.  

MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES don't mean anything for
MPOL_PREFERRED policies that were created with an empty nodemask (for
purely local allocations).  They'll never be invalidated because the
allowed mems of a task changes or need to be rebound relative to a
cpuset's placement.

Also fixes a bug identified by Lee Schermerhorn that disallowed empty
nodemasks to be passed to MPOL_PREFERRED to specify local allocations.
[A different, somewhat incomplete, patch already existed in 25-rc5-mm1.]

Cc: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: David Rientjes <rientjes@google.com>

 Documentation/vm/numa_memory_policy.txt |   16 ++++++++++--
 mm/mempolicy.c                          |   42 +++++++++++++++++++-------------
 2 files changed, 40 insertions(+), 18 deletions(-)

Index: linux-2.6.25-rc5-mm1/Documentation/vm/numa_memory_policy.txt
===================================================================
--- linux-2.6.25-rc5-mm1.orig/Documentation/vm/numa_memory_policy.txt	2008-03-11 14:22:56.000000000 -0400
+++ linux-2.6.25-rc5-mm1/Documentation/vm/numa_memory_policy.txt	2008-03-11 14:32:40.000000000 -0400
@@ -205,6 +205,12 @@ Components of Memory Policies
 	    local allocation for a specific range of addresses--i.e. for
 	    VMA policies.
 
+	    It is possible for the user to specify that local allocation is
+	    always preferred by passing an empty nodemask with this mode.
+	    If an empty nodemask is passed, the policy cannot use the
+	    MPOL_F_STATIC_NODES or MPOL_F_RELATIVE_NODES flags described
+	    below.
+
 	MPOL_INTERLEAVED:  This mode specifies that page allocations be
 	interleaved, on a page granularity, across the nodes specified in
 	the policy.  This mode also behaves slightly differently, based on
@@ -254,7 +260,10 @@ Components of Memory Policies
 	    occurs over that node.  If no nodes from the user's nodemask are
 	    now allowed, the Default behavior is used.
 
-	    MPOL_F_STATIC_NODES cannot be used with MPOL_F_RELATIVE_NODES.
+	    MPOL_F_STATIC_NODES cannot be combined with the
+	    MPOL_F_RELATIVE_NODES flag.  It also cannot be used for
+	    MPOL_PREFERRED policies that were created with an empty nodemask
+	    (local allocation).
 
 	MPOL_F_RELATIVE_NODES:  This flag specifies that the nodemask passed
 	by the user will be mapped relative to the set of the task or VMA's
@@ -301,7 +310,10 @@ Components of Memory Policies
 	    set of memory nodes allowed by the task's cpuset, as that may
 	    change over time.
 
-	    MPOL_F_RELATIVE_NODES cannot be used with MPOL_F_STATIC_NODES.
+	    MPOL_F_RELATIVE_NODES cannot be combined with the
+	    MPOL_F_STATIC_NODES flag.  It also cannot be used for
+	    MPOL_PREFERRED policies that were created with an empty nodemask
+	    (local allocation).
 
 MEMORY POLICY APIs
 
Index: linux-2.6.25-rc5-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/mm/mempolicy.c	2008-03-11 14:32:17.000000000 -0400
+++ linux-2.6.25-rc5-mm1/mm/mempolicy.c	2008-03-11 15:14:49.000000000 -0400
@@ -181,27 +181,43 @@ static struct mempolicy *mpol_new(unsign
 {
 	struct mempolicy *policy;
 	nodemask_t cpuset_context_nmask;
-	int localalloc = 0;
 	int ret;
 
 	pr_debug("setting mode %d flags %d nodes[0] %lx\n",
 		 mode, flags, nodes ? nodes_addr(*nodes)[0] : -1);
 
-	if (mode == MPOL_DEFAULT)
-		return NULL;
-	if (!nodes || nodes_empty(*nodes)) {
-		if (mode != MPOL_PREFERRED)
+	if (mode == MPOL_DEFAULT) {
+		if (nodes && !nodes_empty(*nodes))
 			return ERR_PTR(-EINVAL);
-		localalloc = 1;	/* special case:  no mode flags */
+		return NULL;
 	}
+	VM_BUG_ON(!nodes);
+
+	/*
+	 * MPOL_PREFERRED cannot be used with MPOL_F_STATIC_NODES or
+	 * MPOL_F_RELATIVE_NODES if the nodemask is empty (local allocation).
+	 * All other modes require a valid pointer to a non-empty nodemask.
+	 */
+	if (mode == MPOL_PREFERRED) {
+		if (nodes_empty(*nodes)) {
+			if (((flags & MPOL_F_STATIC_NODES) ||
+			     (flags & MPOL_F_RELATIVE_NODES)))
+				return ERR_PTR(-EINVAL);
+			nodes = NULL;	/* flag local alloc */
+		}
+	} else if (nodes_empty(*nodes))
+		return ERR_PTR(-EINVAL);
 	policy = kmem_cache_alloc(policy_cache, GFP_KERNEL);
 	if (!policy)
 		return ERR_PTR(-ENOMEM);
 	atomic_set(&policy->refcnt, 1);
 	policy->policy = mode;
+	policy->flags = flags;
 
-	if (!localalloc) {
-		policy->flags = flags;
+	if (nodes) {
+		/*
+		 * cpuset related setup doesn't apply to local allocation
+		 */
 		cpuset_update_task_memory_state();
 		if (flags & MPOL_F_RELATIVE_NODES)
 			mpol_relative_nodemask(&cpuset_context_nmask, nodes,
@@ -217,7 +233,7 @@ static struct mempolicy *mpol_new(unsign
 	}
 
 	ret = mpol_ops[mode].create(policy,
-				localalloc ? NULL : &cpuset_context_nmask);
+				nodes ? &cpuset_context_nmask : NULL);
 	if (ret < 0) {
 		kmem_cache_free(policy_cache, policy);
 		return ERR_PTR(ret);
@@ -259,10 +275,6 @@ static void mpol_rebind_preferred(struct
 {
 	nodemask_t tmp;
 
-	/*
-	 * check 'STATIC_NODES first, as preferred_node == -1 may be
-	 * a temporary, "fallback" state for this policy.
-	 */
 	if (pol->flags & MPOL_F_STATIC_NODES) {
 		int node = first_node(pol->w.user_nodemask);
 
@@ -270,12 +282,10 @@ static void mpol_rebind_preferred(struct
 			pol->v.preferred_node = node;
 		else
 			pol->v.preferred_node = -1;
-	} else if (pol->v.preferred_node == -1) {
-		return;	/* no remap required for explicit local alloc */
 	} else if (pol->flags & MPOL_F_RELATIVE_NODES) {
 		mpol_relative_nodemask(&tmp, &pol->w.user_nodemask, nodes);
 		pol->v.preferred_node = first_node(tmp);
-	} else {
+	} else if (pol->v.preferred_node != -1) {
 		pol->v.preferred_node = node_remap(pol->v.preferred_node,
 						   pol->w.cpuset_mems_allowed,
 						   *nodes);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
