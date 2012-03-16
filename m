Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id A83EA6B00F6
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:06 -0400 (EDT)
Message-Id: <20120316144240.368911012@chello.nl>
Date: Fri, 16 Mar 2012 15:40:32 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 04/26] mm, mpol: add MPOL_MF_NOOP
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=migrate-on-fault-07-mbind-noop-policy.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

This patch augments the MPOL_MF_LAZY feature by adding a "NOOP"
policy to mbind().  When the NOOP policy is used with the 'MOVE
and 'LAZY flags, mbind() [check_range()] will walk the specified
range and unmap eligible pages so that they will be migrated on
next touch.

This allows an application to prepare for a new phase of operation
where different regions of shared storage will be assigned to
worker threads, w/o changing policy.  Note that we could just use
"default" policy in this case.  However, this also allows an
application to request that pages be migrated, only if necessary,
to follow any arbitrary policy that might currently apply to a
range of pages, without knowing the policy, or without specifying
multiple mbind()s for ranges with different policies.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mempolicy.h |    1 +
 mm/mempolicy.c            |    8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -20,6 +20,7 @@ enum {
 	MPOL_PREFERRED,
 	MPOL_BIND,
 	MPOL_INTERLEAVE,
+	MPOL_NOOP,		/* retain existing policy for range */
 	MPOL_MAX,	/* always last member of enum */
 };
 
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -251,10 +251,10 @@ static struct mempolicy *mpol_new(unsign
 	pr_debug("setting mode %d flags %d nodes[0] %lx\n",
 		 mode, flags, nodes ? nodes_addr(*nodes)[0] : -1);
 
-	if (mode == MPOL_DEFAULT) {
+	if (mode == MPOL_DEFAULT || mode == MPOL_NOOP) {
 		if (nodes && !nodes_empty(*nodes))
 			return ERR_PTR(-EINVAL);
-		return NULL;	/* simply delete any existing policy */
+		return NULL;
 	}
 	VM_BUG_ON(!nodes);
 
@@ -1121,7 +1121,7 @@ static long do_mbind(unsigned long start
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
 
-	if (mode == MPOL_DEFAULT)
+	if (mode == MPOL_DEFAULT || mode == MPOL_NOOP)
 		flags &= ~MPOL_MF_STRICT;
 
 	len = (len + PAGE_SIZE - 1) & PAGE_MASK;
@@ -1173,7 +1173,7 @@ static long do_mbind(unsigned long start
 			  flags | MPOL_MF_INVERT, &pagelist);
 
 	err = PTR_ERR(vma);	/* maybe ... */
-	if (!IS_ERR(vma))
+	if (!IS_ERR(vma) && mode != MPOL_NOOP)
 		err = mbind_range(mm, start, end, new);
 
 	if (!err) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
