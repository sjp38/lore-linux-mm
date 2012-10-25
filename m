Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id C8B176B0092
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:09:30 -0400 (EDT)
Message-Id: <20121025124833.400431442@chello.nl>
Date: Thu, 25 Oct 2012 14:16:29 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 12/31] mm/mpol: Add MPOL_MF_NOOP
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0012-mm-mpol-Add-MPOL_MF_NOOP.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>

From: Lee Schermerhorn <lee.schermerhorn@hp.com>

This patch augments the MPOL_MF_LAZY feature by adding a "NOOP" policy
to mbind().  When the NOOP policy is used with the 'MOVE and 'LAZY
flags, mbind() will map the pages PROT_NONE so that they will be
migrated on the next touch.

This allows an application to prepare for a new phase of operation
where different regions of shared storage will be assigned to
worker threads, w/o changing policy.  Note that we could just use
"default" policy in this case.  However, this also allows an
application to request that pages be migrated, only if necessary,
to follow any arbitrary policy that might currently apply to a
range of pages, without knowing the policy, or without specifying
multiple mbind()s for ranges with different policies.

[ Bug in early version of mpol_parse_str() reported by Fengguang Wu. ]

Bug-Reported-by: Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/uapi/linux/mempolicy.h |    1 +
 mm/mempolicy.c                 |   11 ++++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

Index: tip/include/uapi/linux/mempolicy.h
===================================================================
--- tip.orig/include/uapi/linux/mempolicy.h
+++ tip/include/uapi/linux/mempolicy.h
@@ -21,6 +21,7 @@ enum {
 	MPOL_BIND,
 	MPOL_INTERLEAVE,
 	MPOL_LOCAL,
+	MPOL_NOOP,		/* retain existing policy for range */
 	MPOL_MAX,	/* always last member of enum */
 };
 
Index: tip/mm/mempolicy.c
===================================================================
--- tip.orig/mm/mempolicy.c
+++ tip/mm/mempolicy.c
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
 
@@ -1146,7 +1146,7 @@ static long do_mbind(unsigned long start
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
 
-	if (mode == MPOL_DEFAULT)
+	if (mode == MPOL_DEFAULT || mode == MPOL_NOOP)
 		flags &= ~MPOL_MF_STRICT;
 
 	len = (len + PAGE_SIZE - 1) & PAGE_MASK;
@@ -2381,7 +2381,8 @@ static const char * const policy_modes[]
 	[MPOL_PREFERRED]  = "prefer",
 	[MPOL_BIND]       = "bind",
 	[MPOL_INTERLEAVE] = "interleave",
-	[MPOL_LOCAL]      = "local"
+	[MPOL_LOCAL]      = "local",
+	[MPOL_NOOP]	  = "noop",	/* should not actually be used */
 };
 
 
@@ -2432,7 +2433,7 @@ int mpol_parse_str(char *str, struct mem
 			break;
 		}
 	}
-	if (mode >= MPOL_MAX)
+	if (mode >= MPOL_MAX || mode == MPOL_NOOP)
 		goto out;
 
 	switch (mode) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
