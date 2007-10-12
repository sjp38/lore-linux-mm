From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 12 Oct 2007 11:49:12 -0400
Message-Id: <20071012154912.8157.16517.sendpatchset@localhost>
In-Reply-To: <20071012154854.8157.51441.sendpatchset@localhost>
References: <20071012154854.8157.51441.sendpatchset@localhost>
Subject: [PATCH/RFC 3/4] Mem Policy: Fixup Interleave Policy Reference Counting
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, ak@suse.de, mel@skynet.ie, clameter@sgi.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 3/4 Mempolicy:  Fixup Interleave Policy Reference Counting

Against: 2.6.23-rc8-mm2

Separated from multi-issue patch 2/2

In the memory policy reference counting cleanup patch,  I missed
one path that needs to unreference the memory policy.  After
computing the target node for interleave policy, we need to
drop the reference if the policy is not the system default nor
the current task's policy.

In huge_zonelist(), I was unconditionally unref'ing the policy
in the interleave path, even when it was a policy that didn't 
need it.  Fix this!

Note:  I investigated moving the check for "policy_needs_unref"
to the mpol_free() wrapper, but this led to nasty circular header
dependencies.  If we wanted to make mpol_free() an external 
function, rather than a static inline, I could do this and 
remove several checks.  I'd still need to keep an explicit
check in alloc_page_vma() if we want to use a tail-call for
the fast path.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-10-12 10:48:03.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-10-12 10:50:05.000000000 -0400
@@ -1262,18 +1262,21 @@ struct zonelist *huge_zonelist(struct vm
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 	struct zonelist *zl;
+	int policy_needs_unref = (pol != &default_policy && \
+					pol != current->mempolicy);
 
 	*mpol = NULL;		/* probably no unref needed */
 	if (pol->policy == MPOL_INTERLEAVE) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
-		__mpol_free(pol);		/* finished with pol */
+		if (unlikely(policy_needs_unref))
+			__mpol_free(pol);	/* finished with pol */
 		return NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_flags);
 	}
 
 	zl = zonelist_policy(GFP_HIGHUSER, pol);
-	if (unlikely(pol != &default_policy && pol != current->mempolicy)) {
+	if (unlikely(policy_needs_unref)) {
 		if (pol->policy != MPOL_BIND)
 			__mpol_free(pol);	/* finished with pol */
 		else
@@ -1325,6 +1328,9 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 	struct zonelist *zl;
+	int policy_needs_unref = (pol != &default_policy && \
+				pol != current->mempolicy);
+
 
 	cpuset_update_task_memory_state();
 
@@ -1332,10 +1338,12 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
+		if (unlikely(policy_needs_unref))
+			__mpol_free(pol);
 		return alloc_page_interleave(gfp, 0, nid);
 	}
 	zl = zonelist_policy(gfp, pol);
-	if (pol != &default_policy && pol != current->mempolicy) {
+	if (unlikely(policy_needs_unref)) {
 		/*
 		 * slow path: ref counted policy -- shared or vma
 		 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
