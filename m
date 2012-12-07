Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 4577B6B00A9
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:39 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 24/49] mm: mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now
Date: Fri,  7 Dec 2012 10:23:27 +0000
Message-Id: <1354875832-9700-25-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The use of MPOL_NOOP and MPOL_MF_LAZY to allow an application to
explicitly request lazy migration is a good idea but the actual
API has not been well reviewed and once released we have to support it.
For now this patch prevents an application using the services. This
will need to be revisited.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/uapi/linux/mempolicy.h |    4 +---
 mm/mempolicy.c                 |    9 ++++-----
 2 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 6a1baae..16fb4e6 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -21,7 +21,6 @@ enum {
 	MPOL_BIND,
 	MPOL_INTERLEAVE,
 	MPOL_LOCAL,
-	MPOL_NOOP,		/* retain existing policy for range */
 	MPOL_MAX,	/* always last member of enum */
 };
 
@@ -57,8 +56,7 @@ enum mpol_rebind_step {
 
 #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
 			 MPOL_MF_MOVE     | 	\
-			 MPOL_MF_MOVE_ALL |	\
-			 MPOL_MF_LAZY)
+			 MPOL_MF_MOVE_ALL)
 
 /*
  * Internal flags that share the struct mempolicy flags word with
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 75d4600..a7a62fe 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -252,7 +252,7 @@ static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
 	pr_debug("setting mode %d flags %d nodes[0] %lx\n",
 		 mode, flags, nodes ? nodes_addr(*nodes)[0] : -1);
 
-	if (mode == MPOL_DEFAULT || mode == MPOL_NOOP) {
+	if (mode == MPOL_DEFAULT) {
 		if (nodes && !nodes_empty(*nodes))
 			return ERR_PTR(-EINVAL);
 		return NULL;
@@ -1186,7 +1186,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
 
-	if (mode == MPOL_DEFAULT || mode == MPOL_NOOP)
+	if (mode == MPOL_DEFAULT)
 		flags &= ~MPOL_MF_STRICT;
 
 	len = (len + PAGE_SIZE - 1) & PAGE_MASK;
@@ -1241,7 +1241,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 			  flags | MPOL_MF_INVERT, &pagelist);
 
 	err = PTR_ERR(vma);	/* maybe ... */
-	if (!IS_ERR(vma) && mode != MPOL_NOOP)
+	if (!IS_ERR(vma))
 		err = mbind_range(mm, start, end, new);
 
 	if (!err) {
@@ -2530,7 +2530,6 @@ static const char * const policy_modes[] =
 	[MPOL_BIND]       = "bind",
 	[MPOL_INTERLEAVE] = "interleave",
 	[MPOL_LOCAL]      = "local",
-	[MPOL_NOOP]	  = "noop",	/* should not actually be used */
 };
 
 
@@ -2581,7 +2580,7 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 			break;
 		}
 	}
-	if (mode >= MPOL_MAX || mode == MPOL_NOOP)
+	if (mode >= MPOL_MAX)
 		goto out;
 
 	switch (mode) {
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
