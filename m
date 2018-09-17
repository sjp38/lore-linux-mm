Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 561178E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 02:11:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b4-v6so6785128ede.4
        for <linux-mm@kvack.org>; Sun, 16 Sep 2018 23:11:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u22-v6si3583716eds.144.2018.09.16.23.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Sep 2018 23:11:08 -0700 (PDT)
Date: Mon, 17 Sep 2018 08:11:07 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180917061107.GB26286@dhcp22.suse.cz>
References: <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <20180912172925.GK1719@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912172925.GK1719@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

[sorry I've missed your reply]

On Wed 12-09-18 18:29:25, Mel Gorman wrote:
> On Wed, Aug 29, 2018 at 09:24:51PM +0200, Michal Hocko wrote:
[...]
> I recognise that this fix means that users that expect zone_reclaim_mode==1
> type behaviour may get burned but the users that benefit from that should
> also be users that benefit from sizing their workload to a node. They should
> be able to replicate that with mempolicies or at least use prepation scripts
> to clear memory on a target node (e.g. membind a memhog to the desired size,
> exit and then start the target workload).

As I've said in other email. We probably want to add a new mempolicy
which has zone_reclaim_mode-like semantic.

[...]

> > diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> > index 5228c62af416..bac395f1d00a 100644
> > --- a/include/linux/mempolicy.h
> > +++ b/include/linux/mempolicy.h
> > @@ -139,6 +139,8 @@ struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
> >  struct mempolicy *get_task_policy(struct task_struct *p);
> >  struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
> >  		unsigned long addr);
> > +struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
> > +						unsigned long addr);
> >  bool vma_policy_mof(struct vm_area_struct *vma);
> >  
> >  extern void numa_default_policy(void);
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index c3bc7e9c9a2a..94472bf9a31b 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -629,21 +629,30 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
> >   *	    available
> >   * never: never stall for any thp allocation
> >   */
> > -static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
> > +static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
> >  {
> >  	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
> > +	gfp_t this_node = 0;
> > +	struct mempolicy *pol;
> > +
> > +#ifdef CONFIG_NUMA
> > +	/* __GFP_THISNODE makes sense only if there is no explicit binding */
> > +	pol = get_vma_policy(vma, addr);
> > +	if (pol->mode != MPOL_BIND)
> > +		this_node = __GFP_THISNODE;
> > +#endif
> >  
> 
> Where is the mpol_cond_put? Historically it might not have mattered
> because THP could not be used with a shared possibility but it probably
> matters now that tmpfs can be backed by THP.

http://lkml.kernel.org/r/20180830064732.GA2656@dhcp22.suse.cz

> The comment needs more expansion as well. Arguably it only makes sense in
> the event we are explicitly bound to one node because if we are bound to
> two nodes without interleaving then why not fall back? The answer to that
> is outside the scope of the patch but the comment as-is will cause head
> scratches in a years time.

Do you have any specific wording in mind? I have a bit hard time to come
up with something more precise and do not go into details too much.
 
> >  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> > -		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
> > +		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY | this_node);
> >  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> > -		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
> > +		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | this_node;
> >  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
> >  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> > -							     __GFP_KSWAPD_RECLAIM);
> > +							     __GFP_KSWAPD_RECLAIM | this_node);
> >  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
> >  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> > -							     0);
> > -	return GFP_TRANSHUGE_LIGHT;
> > +							     this_node);
> > +	return GFP_TRANSHUGE_LIGHT | this_node;
> >  }
> >  
> >  /* Caller must hold page table lock. */
> > @@ -715,7 +724,7 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
> >  			pte_free(vma->vm_mm, pgtable);
> >  		return ret;
> >  	}
> > -	gfp = alloc_hugepage_direct_gfpmask(vma);
> > +	gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
> >  	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
> >  	if (unlikely(!page)) {
> >  		count_vm_event(THP_FAULT_FALLBACK);
> > @@ -1290,7 +1299,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
> >  alloc:
> >  	if (transparent_hugepage_enabled(vma) &&
> >  	    !transparent_hugepage_debug_cow()) {
> > -		huge_gfp = alloc_hugepage_direct_gfpmask(vma);
> > +		huge_gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
> >  		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
> >  	} else
> >  		new_page = NULL;
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index da858f794eb6..75bbfc3d6233 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -1648,7 +1648,7 @@ struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
> >   * freeing by another task.  It is the caller's responsibility to free the
> >   * extra reference for shared policies.
> >   */
> > -static struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
> > +struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
> >  						unsigned long addr)
> >  {
> >  	struct mempolicy *pol = __get_vma_policy(vma, addr);
> > @@ -2026,32 +2026,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
> >  		goto out;
> >  	}
> >  
> > -	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
> > -		int hpage_node = node;
> > -
> > -		/*
> > -		 * For hugepage allocation and non-interleave policy which
> > -		 * allows the current node (or other explicitly preferred
> > -		 * node) we only try to allocate from the current/preferred
> > -		 * node and don't fall back to other nodes, as the cost of
> > -		 * remote accesses would likely offset THP benefits.
> > -		 *
> > -		 * If the policy is interleave, or does not allow the current
> > -		 * node in its nodemask, we allocate the standard way.
> > -		 */
> > -		if (pol->mode == MPOL_PREFERRED &&
> > -						!(pol->flags & MPOL_F_LOCAL))
> > -			hpage_node = pol->v.preferred_node;
> > -
> > -		nmask = policy_nodemask(gfp, pol);
> > -		if (!nmask || node_isset(hpage_node, *nmask)) {
> > -			mpol_cond_put(pol);
> > -			page = __alloc_pages_node(hpage_node,
> > -						gfp | __GFP_THISNODE, order);
> > -			goto out;
> > -		}
> > -	}
> > -
> 
> The hugepage flag passed into this function is now redundant and that
> means that callers of alloc_hugepage_vma need to move back to using
> alloc_pages_vma() directly and remove the API entirely. This block of
> code is about both GFP flag settings and node selection but at a glance I
> cannot see the point of it because it's very similar to the base page code.
> The whole point may be to get around the warning in policy_node and that
> could just as easily be side-stepped in alloc_hugepage_direct_gfpmask
> as you do already in this patch. There should be no reason why THP has a
> different policy than a base page within a single VMA.

OK, I can follow up with a cleanup patch once we settle down with this
approach to fix the issue.

Thanks!
-- 
Michal Hocko
SUSE Labs
