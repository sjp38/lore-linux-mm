Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CDB5B6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 09:16:29 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id x11so33132945qka.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:16:29 -0700 (PDT)
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com. [209.85.220.176])
        by mx.google.com with ESMTPS id b124si3601550qke.101.2016.10.12.06.16.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 06:16:29 -0700 (PDT)
Received: by mail-qk0-f176.google.com with SMTP id z190so30689120qkc.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:16:29 -0700 (PDT)
Date: Wed, 12 Oct 2016 15:16:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: MPOL_BIND on memory only nodes
Message-ID: <20161012131626.GL17128@dhcp22.suse.cz>
References: <57FE0184.6030008@linux.vnet.ibm.com>
 <20161012094337.GH17128@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161012094337.GH17128@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

On Wed 12-10-16 11:43:37, Michal Hocko wrote:
> On Wed 12-10-16 14:55:24, Anshuman Khandual wrote:
[...]
> > Why we insist on __GFP_THISNODE ?
> 
> AFAIU __GFP_THISNODE just overrides the given node to the policy
> nodemask in case the current node is not part of that node mask. In
> other words we are ignoring the given node and use what the policy says. 
> I can see how this can be confusing especially when confronting the
> documentation:
> 
>  * __GFP_THISNODE forces the allocation to be satisified from the requested
>  *   node with no fallbacks or placement policy enforcements.

You made me think and look into this deeper. I came to the conclusion
that this is actually a relict from the past. policy_zonelist is called
only from 3 places:
- huge_zonelist - never should do __GFP_THISNODE when going this path
- alloc_pages_vma - which shouldn't depend on __GFP_THISNODE either
- alloc_pages_current - which uses default_policy id __GFP_THISNODE is
  used

So AFAICS this is essentially a dead code or I am missing something. Mel
do you remember why we needed it in the past? I would be really tempted
to just get rid of this confusing code and this instead:
---
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index ad1c96ac313c..98beec47bba9 100644
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
+		WARN_ON_ONCE(polic->mode == MPOL_BIND && (gfp && __GFP_THISNODE));
 	}
+
 	return node_zonelist(nd, gfp);
 }
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
