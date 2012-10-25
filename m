Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id E6C886B0098
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:09:34 -0400 (EDT)
Message-Id: <20121025124833.322016965@chello.nl>
Date: Thu, 25 Oct 2012 14:16:28 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 11/31] mm/mpol: Make MPOL_LOCAL a real policy
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0011-mm-mpol-Make-MPOL_LOCAL-a-real-policy.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>

Make MPOL_LOCAL a real and exposed policy such that applications that
relied on the previous default behaviour can explicitly request it.

Requested-by: Christoph Lameter <cl@linux.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/uapi/linux/mempolicy.h |    1 +
 mm/mempolicy.c                 |    9 ++++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

Index: tip/include/uapi/linux/mempolicy.h
===================================================================
--- tip.orig/include/uapi/linux/mempolicy.h
+++ tip/include/uapi/linux/mempolicy.h
@@ -20,6 +20,7 @@ enum {
 	MPOL_PREFERRED,
 	MPOL_BIND,
 	MPOL_INTERLEAVE,
+	MPOL_LOCAL,
 	MPOL_MAX,	/* always last member of enum */
 };
 
Index: tip/mm/mempolicy.c
===================================================================
--- tip.orig/mm/mempolicy.c
+++ tip/mm/mempolicy.c
@@ -269,6 +269,10 @@ static struct mempolicy *mpol_new(unsign
 			     (flags & MPOL_F_RELATIVE_NODES)))
 				return ERR_PTR(-EINVAL);
 		}
+	} else if (mode == MPOL_LOCAL) {
+		if (!nodes_empty(*nodes))
+			return ERR_PTR(-EINVAL);
+		mode = MPOL_PREFERRED;
 	} else if (nodes_empty(*nodes))
 		return ERR_PTR(-EINVAL);
 	policy = kmem_cache_alloc(policy_cache, GFP_KERNEL);
@@ -2371,7 +2375,6 @@ void numa_default_policy(void)
  * "local" is pseudo-policy:  MPOL_PREFERRED with MPOL_F_LOCAL flag
  * Used only for mpol_parse_str() and mpol_to_str()
  */
-#define MPOL_LOCAL MPOL_MAX
 static const char * const policy_modes[] =
 {
 	[MPOL_DEFAULT]    = "default",
@@ -2424,12 +2427,12 @@ int mpol_parse_str(char *str, struct mem
 	if (flags)
 		*flags++ = '\0';	/* terminate mode string */
 
-	for (mode = 0; mode <= MPOL_LOCAL; mode++) {
+	for (mode = 0; mode < MPOL_MAX; mode++) {
 		if (!strcmp(str, policy_modes[mode])) {
 			break;
 		}
 	}
-	if (mode > MPOL_LOCAL)
+	if (mode >= MPOL_MAX)
 		goto out;
 
 	switch (mode) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
