Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EC5BE6B004D
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:55:14 -0400 (EDT)
Received: by pwi4 with SMTP id 4so985193pwi.14
        for <linux-mm@kvack.org>; Tue, 16 Mar 2010 06:55:13 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] mempolicy: remove redundant check
Date: Tue, 16 Mar 2010 21:55:03 +0800
Message-Id: <1268747703-8343-1-git-send-email-user@bob-laptop>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Bob Liu <lliubbo@gmail.com>

1. Lee's patch "mempolicy: use MPOL_PREFERRED for system-wide
default policy" has made the MPOL_DEFAULT only used in the
memory policy APIs. So, no need to check in __mpol_equal also.

2. In policy_zonelist() mode MPOL_INTERLEAVE shouldn't happen,
so fall through to BUG() instead of break to return.I also fix
the comment.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/mempolicy.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 643f66e..c4b16c9 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1441,15 +1441,15 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy)
 		/*
 		 * Normally, MPOL_BIND allocations are node-local within the
 		 * allowed nodemask.  However, if __GFP_THISNODE is set and the
-		 * current node is part of the mask, we use the zonelist for
+		 * current node isn't part of the mask, we use the zonelist for
 		 * the first node in the mask instead.
 		 */
 		if (unlikely(gfp & __GFP_THISNODE) &&
 				unlikely(!node_isset(nd, policy->v.nodes)))
 			nd = first_node(policy->v.nodes);
 		break;
-	case MPOL_INTERLEAVE: /* should not happen */
-		break;
+	case MPOL_INTERLEAVE:
+		/* Should not happen, so fall through to BUG()*/
 	default:
 		BUG();
 	}
@@ -1806,7 +1806,7 @@ int __mpol_equal(struct mempolicy *a, struct mempolicy *b)
 		return 0;
 	if (a->mode != b->mode)
 		return 0;
-	if (a->mode != MPOL_DEFAULT && !mpol_match_intent(a, b))
+	if (!mpol_match_intent(a, b))
 		return 0;
 	switch (a->mode) {
 	case MPOL_BIND:
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
