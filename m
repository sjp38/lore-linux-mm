Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC2466B4500
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 03:53:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m25-v6so646848pgv.14
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 00:53:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c31-v6si382537pgl.126.2018.08.28.00.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 00:53:25 -0700 (PDT)
Date: Tue, 28 Aug 2018 09:53:21 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180828075321.GD10223@dhcp22.suse.cz>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz>
 <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz>
 <20180822155250.GP13047@redhat.com>
 <20180823105253.GB29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823105253.GB29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu 23-08-18 12:52:53, Michal Hocko wrote:
> On Wed 22-08-18 11:52:50, Andrea Arcangeli wrote:
> > On Wed, Aug 22, 2018 at 11:02:14AM +0200, Michal Hocko wrote:
> [...]
> > > I still have to digest the __GFP_THISNODE thing but I _think_ that the
> > > alloc_pages_vma code is just trying to be overly clever and
> > > __GFP_THISNODE is not a good fit for it. 
> > 
> > My option 2 did just that, it removed __GFP_THISNODE but only for
> > MADV_HUGEPAGE and in general whenever reclaim was activated by
> > __GFP_DIRECT_RECLAIM. That is also signal that the user really wants
> > THP so then it's less bad to prefer THP over NUMA locality.
> > 
> > For the default which is tuned for short lived allocation, preferring
> > local memory is most certainly better win for short lived allocation
> > where THP can't help much, this is why I didn't remove __GFP_THISNODE
> > from the default defrag policy.
> 
> Yes I agree.

I finally got back to this again. I have checked your patch and I am
really wondering whether alloc_pages_vma is really the proper place to
play these tricks. We already have that mind blowing alloc_hugepage_direct_gfpmask
and it should be the proper place to handle this special casing. So what
do you think about the following. It should be essentially the same
thing. Aka use __GFP_THIS_NODE only when we are doing an optimistic THP
allocation. Madvise signalizes you know what you are doing and THP has
the top priority. If you care enough about the numa placement then you
should better use mempolicy.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c3bc7e9c9a2a..3cdb62f6aea7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -634,16 +634,16 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
 
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
+		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY | __GFP_THISNODE);
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
+		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | __GFP_THISNODE;
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
 		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
-							     __GFP_KSWAPD_RECLAIM);
+							     __GFP_KSWAPD_RECLAIM | __GFP_THISNODE);
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
 		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
-							     0);
-	return GFP_TRANSHUGE_LIGHT;
+							     __GFP_THIS_NODE);
+	return GFP_TRANSHUGE_LIGHT | __GFP_THISNODE;
 }
 
 /* Caller must hold page table lock. */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index da858f794eb6..9f0800885613 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2026,32 +2026,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		goto out;
 	}
 
-	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
-		int hpage_node = node;
-
-		/*
-		 * For hugepage allocation and non-interleave policy which
-		 * allows the current node (or other explicitly preferred
-		 * node) we only try to allocate from the current/preferred
-		 * node and don't fall back to other nodes, as the cost of
-		 * remote accesses would likely offset THP benefits.
-		 *
-		 * If the policy is interleave, or does not allow the current
-		 * node in its nodemask, we allocate the standard way.
-		 */
-		if (pol->mode == MPOL_PREFERRED &&
-						!(pol->flags & MPOL_F_LOCAL))
-			hpage_node = pol->v.preferred_node;
-
-		nmask = policy_nodemask(gfp, pol);
-		if (!nmask || node_isset(hpage_node, *nmask)) {
-			mpol_cond_put(pol);
-			page = __alloc_pages_node(hpage_node,
-						gfp | __GFP_THISNODE, order);
-			goto out;
-		}
-	}
-
 	nmask = policy_nodemask(gfp, pol);
 	preferred_nid = policy_node(gfp, pol, node);
 	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
-- 
Michal Hocko
SUSE Labs
