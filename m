Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10CF86B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 09:00:06 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x11so52442907qka.5
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:00:06 -0700 (PDT)
Received: from mail-qt0-f195.google.com (mail-qt0-f195.google.com. [209.85.216.195])
        by mx.google.com with ESMTPS id 3si6364226qkg.109.2016.10.13.06.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 06:00:05 -0700 (PDT)
Received: by mail-qt0-f195.google.com with SMTP id f6so2642614qtd.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:00:05 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, mempolicy: clean up __GFP_THISNODE confusion in policy_zonelist
Date: Thu, 13 Oct 2016 14:59:58 +0200
Message-Id: <20161013125958.32155-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__GFP_THISNODE is documented to enforce the allocation to be satisified
from the requested node with no fallbacks or placement policy
enforcements. policy_zonelist seemingly breaks this semantic if the
current policy is MPOL_MBIND and instead of taking the node it will
fallback to the first node in the mask if the requested one is not in
the mask. This is confusing to say the least because it fact we
shouldn't ever go that path. First tasks shouldn't be scheduled on CPUs
with nodes outside of their mempolicy binding. And secondly
policy_zonelist is called only from 3 places:
- huge_zonelist - never should do __GFP_THISNODE when going this path
- alloc_pages_vma - which shouldn't depend on __GFP_THISNODE either
- alloc_pages_current - which uses default_policy id __GFP_THISNODE is
  used

So we shouldn't even need to care about this possibility and can drop
the confusing code. Let's keep a WARN_ON_ONCE in place to catch
potential users and fix them up properly (aka use a different allocation
function which ignores mempolicy).

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
I have noticed this while discussing this code [1]. The code as is
quite confusing and I think it is worth cleaning up. I decided to be
conservative and keep at least WARN_ON_ONCE if we have some caller which
relies on __GFP_THISNODE in a mempolicy context so that we can fix it up.

[1] http://lkml.kernel.org/r/57FE0184.6030008@linux.vnet.ibm.com

 mm/mempolicy.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index ad1c96ac313c..33a305397bd4 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1679,25 +1679,17 @@ static nodemask_t *policy_nodemask(gfp_t gfp, struct mempolicy *policy)
 static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
 	int nd)
 {
-	switch (policy->mode) {
-	case MPOL_PREFERRED:
-		if (!(policy->flags & MPOL_F_LOCAL))
-			nd = policy->v.preferred_node;
-		break;
-	case MPOL_BIND:
+	if (policy->mode == MPOL_PREFERRED && !(policy->flags & MPOL_F_LOCAL))
+		nd = policy->v.preferred_node;
+	else {
 		/*
-		 * Normally, MPOL_BIND allocations are node-local within the
-		 * allowed nodemask.  However, if __GFP_THISNODE is set and the
-		 * current node isn't part of the mask, we use the zonelist for
-		 * the first node in the mask instead.
+		 * __GFP_THISNODE shouldn't even be used with the bind policy because
+		 * we might easily break the expectation to stay on the requested node
+		 * and not break the policy.
 		 */
-		if (unlikely(gfp & __GFP_THISNODE) &&
-				unlikely(!node_isset(nd, policy->v.nodes)))
-			nd = first_node(policy->v.nodes);
-		break;
-	default:
-		BUG();
+		WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
 	}
+
 	return node_zonelist(nd, gfp);
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
