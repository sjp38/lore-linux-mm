Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 3DEB06B0075
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 04:15:11 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/19] mm: mempolicy: Add MPOL_MF_NOOP
Date: Tue,  6 Nov 2012 09:14:46 +0000
Message-Id: <1352193295-26815-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1352193295-26815-1-git-send-email-mgorman@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Lee Schermerhorn <lee.schermerhorn@hp.com>

NOTE: I have not yet addressed by own review feedback of this patch. At
	this point I'm trying to construct a baseline tree and will apply
	my own review feedback later and then fold it in.

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
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/uapi/linux/mempolicy.h |    1 +
 mm/mempolicy.c                 |   11 ++++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 3e835c9..d23dca8 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -21,6 +21,7 @@ enum {
 	MPOL_BIND,
 	MPOL_INTERLEAVE,
 	MPOL_LOCAL,
+	MPOL_NOOP,		/* retain existing policy for range */
 	MPOL_MAX,	/* always last member of enum */
 };
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 54bd3e5..c21e914 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -251,10 +251,10 @@ static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
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
 
@@ -1147,7 +1147,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
 
-	if (mode == MPOL_DEFAULT)
+	if (mode == MPOL_DEFAULT || mode == MPOL_NOOP)
 		flags &= ~MPOL_MF_STRICT;
 
 	len = (len + PAGE_SIZE - 1) & PAGE_MASK;
@@ -2409,7 +2409,8 @@ static const char * const policy_modes[] =
 	[MPOL_PREFERRED]  = "prefer",
 	[MPOL_BIND]       = "bind",
 	[MPOL_INTERLEAVE] = "interleave",
-	[MPOL_LOCAL]      = "local"
+	[MPOL_LOCAL]      = "local",
+	[MPOL_NOOP]	  = "noop",	/* should not actually be used */
 };
 
 
@@ -2460,7 +2461,7 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 			break;
 		}
 	}
-	if (mode >= MPOL_MAX)
+	if (mode >= MPOL_MAX || mode == MPOL_NOOP)
 		goto out;
 
 	switch (mode) {
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
