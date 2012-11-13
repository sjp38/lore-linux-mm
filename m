Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 3DBD96B008A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 12:15:06 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so65876eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:15:05 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 11/31] mm/mpol: Make MPOL_LOCAL a real policy
Date: Tue, 13 Nov 2012 18:13:34 +0100
Message-Id: <1352826834-11774-12-git-send-email-mingo@kernel.org>
In-Reply-To: <1352826834-11774-1-git-send-email-mingo@kernel.org>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

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
 include/uapi/linux/mempolicy.h | 1 +
 mm/mempolicy.c                 | 9 ++++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 23e62e0..3e835c9 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -20,6 +20,7 @@ enum {
 	MPOL_PREFERRED,
 	MPOL_BIND,
 	MPOL_INTERLEAVE,
+	MPOL_LOCAL,
 	MPOL_MAX,	/* always last member of enum */
 };
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d04a8a5..72f50ba 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -269,6 +269,10 @@ static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
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
@@ -2397,7 +2401,6 @@ void numa_default_policy(void)
  * "local" is pseudo-policy:  MPOL_PREFERRED with MPOL_F_LOCAL flag
  * Used only for mpol_parse_str() and mpol_to_str()
  */
-#define MPOL_LOCAL MPOL_MAX
 static const char * const policy_modes[] =
 {
 	[MPOL_DEFAULT]    = "default",
@@ -2450,12 +2453,12 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
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
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
