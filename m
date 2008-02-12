Date: Tue, 12 Feb 2008 09:43:11 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to allowed nodes V3
In-Reply-To: <1202748459.5014.50.camel@localhost>
References: <alpine.LFD.1.00.0802092340400.2896@woody.linux-foundation.org> <1202748459.5014.50.camel@localhost>
Message-Id: <20080212091910.29A0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew Lee-san

# remove almost CC'd

> Kosaki-san:  You've tested V3 on '.24.  Do you want to repost the patch
> refreshed against .24, adding your "Tested-by:"  [and "Signed-off-by:",
> as the folding of the contextualization into mpol_check_policy() is
> based on your code--apologies for not adding it myself]?  I'm tied up
> with something else for most of this week and won't get to it until
> Friday, earliest.

OK.
I append my Tested-by.(but not Singed-off-by because my work is very little).

and, I attached .24 adjusted patch.
my change is only line number change and remove extra space.


> P.S., As Andrew pointed out, I forgot to run checkpatch and the patch
> does include a violation thereof.

fixed.
the violation is only 1 extra white space :)


-------------------------------------------------------------------
Was "Re: [2.6.24 regression][BUGFIX] numactl --interleave=all doesn't
works on memoryless node."

[Aside:  I noticed there were two slightly different distributions for
this topic.  I've unified the distribution lists w/o dropping anyone, I
think.  Apologies if you'd rather have been dropped...]

Here's V3 of the patch, accomodating Kosaki Motohiro's suggestion for
folding contextualize_policy() into mpol_check_policy() [because my
"was_empty" argument "was ugly" ;-)].  It does seem to clean up the
code.

I'm still deferring David Rientjes' suggestion to fold
mpol_check_policy() into mpol_new().  We need to sort out whether
mempolicies specified for tmpfs and hugetlbfs mounts always need the
same "contextualization" as user/application installed policies.  I
don't want to hold up this bug fix for that discussion.  This is
something Paul J will need to address with his cpuset/mempolicy rework,
so we can sort it out in that context.

Again, tested with "numactl --interleave=all" and memtoy on ia64 using
mem= command line argument to simulate memoryless node.


Lee

============================
[PATCH] 2.6.24-mm1 - mempolicy:  silently restrict nodemask to allowed nodes

V2 -> V3:
+ As suggested by Kosaki Motohito, fold the "contextualization"
  of policy nodemask into mpol_check_policy().  Looks a little
  cleaner. 

V1 -> V2:
+ Communicate whether or not incoming node mask was empty to
  mpol_check_policy() for better error checking.
+ As suggested by David Rientjes, remove the now unused
   cpuset_nodes_subset_current_mems_allowed() from cpuset.h

Kosaki Motohito noted that "numactl --interleave=all ..." failed in the
presence of memoryless nodes.  This patch attempts to fix that problem.

Some background:  

numactl --interleave=all calls set_mempolicy(2) with a fully
populated [out to MAXNUMNODES] nodemask.  set_mempolicy()
[in do_set_mempolicy()] calls contextualize_policy() which
requires that the nodemask be a subset of the current task's
mems_allowed; else EINVAL will be returned.  A task's
mems_allowed will always be a subset of node_states[N_HIGH_MEMORY]--
i.e., nodes with memory.  So, a fully populated nodemask will
be declared invalid if it includes memoryless nodes.

  NOTE:  the same thing will occur when running in a cpuset
         with restricted mem_allowed--for the same reason:
         node mask contains dis-allowed nodes.

mbind(2), on the other hand, just masks off any nodes in the 
nodemask that are not included in the caller's mems_allowed.

In each case [mbind() and set_mempolicy()], mpol_check_policy()
will complain [again, resulting in EINVAL] if the nodemask contains 
any memoryless nodes.  This is somewhat redundant as mpol_new() 
will remove memoryless nodes for interleave policy, as will 
bind_zonelist()--called by mpol_new() for BIND policy.

Proposed fix:

1) modify contextualize_policy logic to:
   a) remember whether the incoming node mask is empty.
   b) if not, restrict the nodemask to allowed nodes, as is
      currently done in-line for mbind().  This guarantees
      that the resulting mask includes only nodes with memory.

      NOTE:  this is a [benign, IMO] change in behavior for
             set_mempolicy().  Dis-allowed nodes will be
             silently ignored, rather than returning an error.

   c) fold this code into mpol_check_policy(), replace 2 calls to
      contextualize_policy() to call mpol_check_policy() directly
      and remove contextualize_policy().

2) In existing mpol_check_policy() logic, after "contextualization":
   a) MPOL_DEFAULT:  require that in coming mask "was_empty"
   b) MPOL_{BIND|INTERLEAVE}:  require that contextualized nodemask
      contains at least one node.
   c) add a case for MPOL_PREFERRED:  if in coming was not empty
      and resulting mask IS empty, user specified invalid nodes.
      Return EINVAL.
   c) remove the now redundant check for memoryless nodes

3) remove the now redundant masking of policy nodes for interleave
   policy from mpol_new().

4) Now that mpol_check_policy() contextualizes the nodemask, remove
   the in-line nodes_and() from sys_mbind().  I believe that this
   restores mbind() to the behavior before the memoryless-nodes
   patch series.  E.g., we'll no longer treat an invalid nodemask
   with MPOL_PREFERRED as local allocation.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Tested-by:      KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

 include/linux/cpuset.h |    3 --
 mm/mempolicy.c         |   61 ++++++++++++++++++++++++++++---------------------
 2 files changed, 36 insertions(+), 28 deletions(-)

Index: b/mm/mempolicy.c
===================================================================
--- a/mm/mempolicy.c	2008-02-10 14:27:58.000000000 +0900
+++ b/mm/mempolicy.c	2008-02-12 09:37:35.000000000 +0900
@@ -116,22 +116,51 @@ static void mpol_rebind_policy(struct me
 /* Do sanity checking on a policy */
 static int mpol_check_policy(int mode, nodemask_t *nodes)
 {
-	int empty = nodes_empty(*nodes);
+	int was_empty, is_empty;
+
+	if (!nodes)
+		return 0;
+
+	/*
+	 * "Contextualize" the in-coming nodemast for cpusets:
+	 * Remember whether in-coming nodemask was empty,  If not,
+	 * restrict the nodes to the allowed nodes in the cpuset.
+	 * This is guaranteed to be a subset of nodes with memory.
+	 */
+	cpuset_update_task_memory_state();
+	is_empty = was_empty = nodes_empty(*nodes);
+	if (!was_empty) {
+		nodes_and(*nodes, *nodes, cpuset_current_mems_allowed);
+		is_empty = nodes_empty(*nodes);	/* after "contextualization" */
+	}
 
 	switch (mode) {
 	case MPOL_DEFAULT:
-		if (!empty)
+		/*
+		 * require caller to specify an empty nodemask
+		 * before "contextualization"
+		 */
+		if (!was_empty)
 			return -EINVAL;
 		break;
 	case MPOL_BIND:
 	case MPOL_INTERLEAVE:
-		/* Preferred will only use the first bit, but allow
-		   more for now. */
-		if (empty)
+		/*
+		 * require at least 1 valid node after "contextualization"
+		 */
+		if (is_empty)
+			return -EINVAL;
+		break;
+	case MPOL_PREFERRED:
+		/*
+		 * Did caller specify invalid nodes?
+		 * Don't silently accept this as "local allocation".
+		 */
+		if (!was_empty && is_empty)
 			return -EINVAL;
 		break;
 	}
- 	return nodes_subset(*nodes, node_states[N_HIGH_MEMORY]) ? 0 : -EINVAL;
+	return 0;
 }
 
 /* Generate a custom zonelist for the BIND policy. */
@@ -188,8 +217,6 @@ static struct mempolicy *mpol_new(int mo
 	switch (mode) {
 	case MPOL_INTERLEAVE:
 		policy->v.nodes = *nodes;
-		nodes_and(policy->v.nodes, policy->v.nodes,
-					node_states[N_HIGH_MEMORY]);
 		if (nodes_weight(policy->v.nodes) == 0) {
 			kmem_cache_free(policy_cache, policy);
 			return ERR_PTR(-EINVAL);
@@ -421,18 +448,6 @@ static int mbind_range(struct vm_area_st
 	return err;
 }
 
-static int contextualize_policy(int mode, nodemask_t *nodes)
-{
-	if (!nodes)
-		return 0;
-
-	cpuset_update_task_memory_state();
-	if (!cpuset_nodes_subset_current_mems_allowed(*nodes))
-		return -EINVAL;
-	return mpol_check_policy(mode, nodes);
-}
-
-
 /*
  * Update task->flags PF_MEMPOLICY bit: set iff non-default
  * mempolicy.  Allows more rapid checking of this (combined perhaps
@@ -468,7 +483,7 @@ static long do_set_mempolicy(int mode, n
 {
 	struct mempolicy *new;
 
-	if (contextualize_policy(mode, nodes))
+	if (mpol_check_policy(mode, nodes))
 		return -EINVAL;
 	new = mpol_new(mode, nodes);
 	if (IS_ERR(new))
@@ -915,10 +930,6 @@ asmlinkage long sys_mbind(unsigned long 
 	err = get_nodes(&nodes, nmask, maxnode);
 	if (err)
 		return err;
-#ifdef CONFIG_CPUSETS
-	/* Restrict the nodes to the allowed nodes in the cpuset */
-	nodes_and(nodes, nodes, current->mems_allowed);
-#endif
 	return do_mbind(start, len, mode, &nodes, flags);
 }
 
Index: b/include/linux/cpuset.h
===================================================================
--- a/include/linux/cpuset.h	2008-02-10 14:27:58.000000000 +0900
+++ b/include/linux/cpuset.h	2008-02-10 14:33:40.000000000 +0900
@@ -26,8 +26,6 @@ extern nodemask_t cpuset_mems_allowed(st
 #define cpuset_current_mems_allowed (current->mems_allowed)
 void cpuset_init_current_mems_allowed(void);
 void cpuset_update_task_memory_state(void);
-#define cpuset_nodes_subset_current_mems_allowed(nodes) \
-		nodes_subset((nodes), current->mems_allowed)
 int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl);
 
 extern int __cpuset_zone_allowed_softwall(struct zone *z, gfp_t gfp_mask);
@@ -101,7 +99,6 @@ static inline nodemask_t cpuset_mems_all
 #define cpuset_current_mems_allowed (node_states[N_HIGH_MEMORY])
 static inline void cpuset_init_current_mems_allowed(void) {}
 static inline void cpuset_update_task_memory_state(void) {}
-#define cpuset_nodes_subset_current_mems_allowed(nodes) (1)
 
 static inline int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
 {




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
