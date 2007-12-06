From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 06 Dec 2007 16:21:29 -0500
Message-Id: <20071206212129.6279.1028.sendpatchset@localhost>
In-Reply-To: <20071206212047.6279.10881.sendpatchset@localhost>
References: <20071206212047.6279.10881.sendpatchset@localhost>
Subject: [PATCH/RFC 7/8] Mem Policy: MPOL_PREFERRED cleanups for "local allocation"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ak@suse.de, mel@skynet.ie, clameter@sgi.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC 07/08 - Mem Policy: MPOL_PREFERRED cleanups for "local allocation" - V5

Against: 2.6.24-rc2-mm1

V4 -> V5:
+  change mpol_to_str() to show "local" policy for MPOL_PREFERRED with
   preferred_node == -1.  libnuma wrappers and numactl use the term
   "local allocation", so let's use it here.

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
    "local", as this indicates local allocation, as the task migrates
    among nodes.  Note that this matches the usage of "local allocation"
    in libnuma() and numactl.  Without this change, I believe that node_set()
    [via set_bit()] will set bit 31, resulting in a misleading display.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |   47 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 35 insertions(+), 12 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-11-21 11:28:33.000000000 -0500
+++ Linux/mm/mempolicy.c	2007-11-21 11:30:17.000000000 -0500
@@ -484,10 +484,13 @@ static long do_set_mempolicy(int mode, n
 	return 0;
 }
 
-/* Fill a zone bitmap for a policy */
-static void get_zonemask(struct mempolicy *p, nodemask_t *nodes)
+/*
+ * Fill a zone bitmap for a policy for mempolicy query
+ */
+static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 {
 	nodes_clear(*nodes);
+
 	switch (policy_mode(p)) {
 	case MPOL_BIND:
 		/* Fall through */
@@ -495,9 +498,11 @@ static void get_zonemask(struct mempolic
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
@@ -578,7 +583,7 @@ static long do_get_mempolicy(int *policy
 
 	err = 0;
 	if (nmask)
-		get_zonemask(pol, nmask);
+		get_policy_nodemask(pol, nmask);
 
  out:
 	mpol_cond_free(pol);
@@ -643,7 +648,7 @@ int do_migrate_pages(struct mm_struct *m
 	int err = 0;
 	nodemask_t tmp;
 
-  	down_read(&mm->mmap_sem);
+	down_read(&mm->mmap_sem);
 
 	err = migrate_vmas(mm, from_nodes, to_nodes, flags);
 	if (err)
@@ -1749,6 +1754,7 @@ static void mpol_rebind_policy(struct me
 {
 	nodemask_t *mpolmask;
 	nodemask_t tmp;
+	int nid;
 
 	if (!pol)
 		return;
@@ -1767,9 +1773,15 @@ static void mpol_rebind_policy(struct me
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
 	default:
 		BUG();
@@ -1807,8 +1819,13 @@ void mpol_rebind_mm(struct mm_struct *mm
  * Display pages allocated per node and memory policy via /proc.
  */
 
+/*
+ * "local" is pseudo-policy:  MPOL_PREFERRED with preferred_node == -1
+ * Used only for mpol_to_str()
+ */
+#define MPOL_LOCAL (MPOL_INTERLEAVE + 1)
 static const char * const policy_types[] =
-	{ "default", "prefer", "bind", "interleave" };
+	{ "default", "prefer", "bind", "interleave", "local" };
 
 /*
  * Convert a mempolicy into a string.
@@ -1818,6 +1835,7 @@ static const char * const policy_types[]
 static inline int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 {
 	char *p = buffer;
+	int nid;
 	int l;
 	nodemask_t nodes;
 	int mode;
@@ -1834,7 +1852,12 @@ static inline int mpol_to_str(char *buff
 
 	case MPOL_PREFERRED:
 		nodes_clear(nodes);
-		node_set(pol->v.preferred_node, nodes);
+		nid = pol->v.preferred_node;
+		if (nid < 0)
+			mode = MPOL_LOCAL;
+		else {
+			node_set(nid, nodes);
+		}
 		break;
 
 	case MPOL_BIND:
@@ -1849,8 +1872,8 @@ static inline int mpol_to_str(char *buff
 	}
 
 	l = strlen(policy_types[mode]);
- 	if (buffer + maxlen < p + l + 1)
- 		return -ENOSPC;
+	if (buffer + maxlen < p + l + 1)
+		return -ENOSPC;
 
 	strcpy(p, policy_types[mode]);
 	p += l;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
