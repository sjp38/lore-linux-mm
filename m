From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 30 Aug 2007 14:51:14 -0400
Message-Id: <20070830185114.22619.61260.sendpatchset@localhost>
In-Reply-To: <20070830185053.22619.96398.sendpatchset@localhost>
References: <20070830185053.22619.96398.sendpatchset@localhost>
Subject: [PATCH/RFC 3/5] Mem Policy:  MPOL_PREFERRED fixups for "local allocation"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, solo@google.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC 03/05 - MPOL_PREFERRED cleanups for "local allocation" - V4

Against: 2.6.23-rc3-mm1

V3 -> V4:
+  updated Documentation/vm/numa_memory_policy.txt to better explain
   [I think] the "local allocation" feature of MPOL_PREFERRED.

V2 -> V3:
+  renamed get_nodemask() to get_policy_nodemask() to more closely
   match what it's doing.

V1 -> V2:
+  renamed get_zonemask() to get_nodemask().  Mel Gorman suggested this
   was a valid "cleanup".

Here are a couple of "cleanups" for MPOL_PREFERRED behavior
when v.preferred_node < 0 -- i.e., "local allocation":

1)  [do_]get_mempolicy() calls the now renamed get_policy_nodemask()
    to fetch the nodemask associated with a policy.  Currently,
    get_policy_nodemask() returns the set of nodes with memory, when
    the policy 'mode' is 'PREFERRED, and the preferred_node is < 0.
    Return the set of allowed nodes instead.  This will already have
    been masked to include only nodes with memory.

2)  When a task is moved into a [new] cpuset, mpol_rebind_policy() is
    called to adjust any task and vma policy nodes to be valid in the
    new cpuset.  However, when the policy is MPOL_PREFERRED, and the
    preferred_node is <0, no rebind is necessary.  The "local allocation"
    indication is valid in any cpuset.  Existing code will "do the right
    thing" because node_remap() will just return the argument node when
    it is outside of the valid range of node ids.  However, I think it is
    clearer and cleaner to skip the remap explicitly in this case.

3)  mpol_to_str() produces a printable, "human readable" string from a
    struct mempolicy.  For MPOL_PREFERRED with preferred_node <0,  show
    the entire set of valid nodes.  Although, technically, MPOL_PREFERRED
    takes only a single node, preferred_node <0 is a local allocation policy,
    with the preferred node determined by the context where the task
    is executing.  All of the allowed nodes are possible, as the task
    migrates amoung the nodes in the cpuset.  Without this change, I believe
    that node_set() [via set_bit()] will set bit 31, resulting in a misleading
    display.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |   41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-08-30 13:20:13.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-08-30 13:36:04.000000000 -0400
@@ -486,8 +486,10 @@ static long do_set_mempolicy(int mode, n
 	return 0;
 }
 
-/* Fill a zone bitmap for a policy */
-static void get_zonemask(struct mempolicy *p, nodemask_t *nodes)
+/*
+ * Return a node bitmap for a policy
+ */
+static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 {
 	int i;
 
@@ -502,9 +504,11 @@ static void get_zonemask(struct mempolic
 		*nodes = p->v.nodes;
 		break;
 	case MPOL_PREFERRED:
-		/* or use current node instead of memory_map? */
+		/*
+		 * for "local policy", return allowed memories
+		 */
 		if (p->v.preferred_node < 0)
-			*nodes = node_states[N_HIGH_MEMORY];
+			*nodes = cpuset_current_mems_allowed;
 		else
 			node_set(p->v.preferred_node, *nodes);
 		break;
@@ -578,7 +582,7 @@ static long do_get_mempolicy(int *policy
 
 	err = 0;
 	if (nmask)
-		get_zonemask(pol, nmask);
+		get_policy_nodemask(pol, nmask);
 
  out:
 	if (vma)
@@ -1715,6 +1719,7 @@ static void mpol_rebind_policy(struct me
 {
 	nodemask_t *mpolmask;
 	nodemask_t tmp;
+	int nid;
 
 	if (!pol)
 		return;
@@ -1731,9 +1736,15 @@ static void mpol_rebind_policy(struct me
 						*mpolmask, *newmask);
 		break;
 	case MPOL_PREFERRED:
-		pol->v.preferred_node = node_remap(pol->v.preferred_node,
+		/*
+		 * no need to remap "local policy"
+		 */
+		nid = pol->v.preferred_node;
+		if (nid >= 0) {
+			pol->v.preferred_node = node_remap(nid,
 						*mpolmask, *newmask);
-		*mpolmask = *newmask;
+			*mpolmask = *newmask;
+		}
 		break;
 	case MPOL_BIND: {
 		nodemask_t nodes;
@@ -1808,7 +1819,7 @@ static const char * const policy_types[]
 static inline int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 {
 	char *p = buffer;
-	int l;
+	int nid, l;
 	nodemask_t nodes;
 	int mode = pol ? pol->policy : MPOL_DEFAULT;
 
@@ -1818,12 +1829,20 @@ static inline int mpol_to_str(char *buff
 		break;
 
 	case MPOL_PREFERRED:
-		nodes_clear(nodes);
-		node_set(pol->v.preferred_node, nodes);
+		nid = pol->v.preferred_node;
+		/*
+		 * local interleave, show all valid nodes
+		 */
+		if (nid < 0)
+			nodes = cpuset_current_mems_allowed;
+		else {
+			nodes_clear(nodes);
+			node_set(nid, nodes);
+		}
 		break;
 
 	case MPOL_BIND:
-		get_zonemask(pol, &nodes);
+		get_policy_nodemask(pol, &nodes);
 		break;
 
 	case MPOL_INTERLEAVE:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
