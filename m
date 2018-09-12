Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF488E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:29:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g15-v6so1154575edm.11
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:29:29 -0700 (PDT)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id 4-v6si1507171eds.302.2018.09.12.10.29.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 10:29:27 -0700 (PDT)
Received: from mail.blacknight.com (unknown [81.17.254.10])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 277131C2C99
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 18:29:27 +0100 (IST)
Date: Wed, 12 Sep 2018 18:29:25 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180912172925.GK1719@techsingularity.net>
References: <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180829192451.GG10223@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On Wed, Aug 29, 2018 at 09:24:51PM +0200, Michal Hocko wrote:
> From 4dc2f772756e6f91b9e64d1a3e2df4dca3475f5b Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 28 Aug 2018 09:59:19 +0200
> Subject: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
> 
> Andrea has noticed [1] that a THP allocation might be really disruptive
> when allocated on NUMA system with the local node full or hard to
> reclaim. Stefan has posted an allocation stall report on 4.12 based
> SLES kernel which suggests the same issue:

Note that this behaviour is unhelpful but it is not against the defined
semantic of the "madvise" defrag option.

> Andrea has identified that the main source of the problem is
> __GFP_THISNODE usage:
> 
> : The problem is that direct compaction combined with the NUMA
> : __GFP_THISNODE logic in mempolicy.c is telling reclaim to swap very
> : hard the local node, instead of failing the allocation if there's no
> : THP available in the local node.
> :
> : Such logic was ok until __GFP_THISNODE was added to the THP allocation
> : path even with MPOL_DEFAULT.
> :
> : The idea behind the __GFP_THISNODE addition, is that it is better to
> : provide local memory in PAGE_SIZE units than to use remote NUMA THP
> : backed memory. That largely depends on the remote latency though, on
> : threadrippers for example the overhead is relatively low in my
> : experience.
> :
> : The combination of __GFP_THISNODE and __GFP_DIRECT_RECLAIM results in
> : extremely slow qemu startup with vfio, if the VM is larger than the
> : size of one host NUMA node. This is because it will try very hard to
> : unsuccessfully swapout get_user_pages pinned pages as result of the
> : __GFP_THISNODE being set, instead of falling back to PAGE_SIZE
> : allocations and instead of trying to allocate THP on other nodes (it
> : would be even worse without vfio type1 GUP pins of course, except it'd
> : be swapping heavily instead).
> 
> Fix this by removing __GFP_THISNODE handling from alloc_pages_vma where
> it doesn't belong and move it to alloc_hugepage_direct_gfpmask where we
> juggle gfp flags for different allocation modes.

For the short term, I think you might be better off simply avoiding the
combination of __GFP_THISNODE and __GFP_DIRECT_RECLAIM and declaring
that the fix. That would be easier for -stable and the layering can be
dealt with as a cleanup.

I recognise that this fix means that users that expect zone_reclaim_mode==1
type behaviour may get burned but the users that benefit from that should
also be users that benefit from sizing their workload to a node. They should
be able to replicate that with mempolicies or at least use prepation scripts
to clear memory on a target node (e.g. membind a memhog to the desired size,
exit and then start the target workload).

I think this is a more appropriate solution than prematurely introducing a
GFP flag as it's not guaranteed that a user is willing to pay a compaction
penalty until it fails. That should be decided separately when the immediate
problem is resolved.

That said, I do think that sorting out where GFP flags are set for THP
should be done in the context of THP code and not alloc_pages_vma. The
current layering is a bit odd.

> The rationale is that
> __GFP_THISNODE is helpful in relaxed defrag modes because falling back
> to a different node might be more harmful than the benefit of a large page.
> If the user really requires THP (e.g. by MADV_HUGEPAGE) then the THP has
> a higher priority than local NUMA placement.
> 
> Be careful when the vma has an explicit numa binding though, because
> __GFP_THISNODE is not playing well with it. We want to follow the
> explicit numa policy rather than enforce a node which happens to be
> local to the cpu we are running on.
> 
> [1] http://lkml.kernel.org/r/20180820032204.9591-1-aarcange@redhat.com
> 
> Fixes: 5265047ac301 ("mm, thp: really limit transparent hugepage allocation to local node")
> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> Debugged-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/mempolicy.h |  2 ++
>  mm/huge_memory.c          | 25 +++++++++++++++++--------
>  mm/mempolicy.c            | 28 +---------------------------
>  3 files changed, 20 insertions(+), 35 deletions(-)
> 
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 5228c62af416..bac395f1d00a 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -139,6 +139,8 @@ struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
>  struct mempolicy *get_task_policy(struct task_struct *p);
>  struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
>  		unsigned long addr);
> +struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
> +						unsigned long addr);
>  bool vma_policy_mof(struct vm_area_struct *vma);
>  
>  extern void numa_default_policy(void);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c3bc7e9c9a2a..94472bf9a31b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -629,21 +629,30 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
>   *	    available
>   * never: never stall for any thp allocation
>   */
> -static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
> +static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
>  {
>  	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
> +	gfp_t this_node = 0;
> +	struct mempolicy *pol;
> +
> +#ifdef CONFIG_NUMA
> +	/* __GFP_THISNODE makes sense only if there is no explicit binding */
> +	pol = get_vma_policy(vma, addr);
> +	if (pol->mode != MPOL_BIND)
> +		this_node = __GFP_THISNODE;
> +#endif
>  

Where is the mpol_cond_put? Historically it might not have mattered
because THP could not be used with a shared possibility but it probably
matters now that tmpfs can be backed by THP.

The comment needs more expansion as well. Arguably it only makes sense in
the event we are explicitly bound to one node because if we are bound to
two nodes without interleaving then why not fall back? The answer to that
is outside the scope of the patch but the comment as-is will cause head
scratches in a years time.

>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> -		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
> +		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY | this_node);
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> -		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
> +		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | this_node;
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
>  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> -							     __GFP_KSWAPD_RECLAIM);
> +							     __GFP_KSWAPD_RECLAIM | this_node);
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
>  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> -							     0);
> -	return GFP_TRANSHUGE_LIGHT;
> +							     this_node);
> +	return GFP_TRANSHUGE_LIGHT | this_node;
>  }
>  
>  /* Caller must hold page table lock. */
> @@ -715,7 +724,7 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
>  			pte_free(vma->vm_mm, pgtable);
>  		return ret;
>  	}
> -	gfp = alloc_hugepage_direct_gfpmask(vma);
> +	gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
>  	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
>  	if (unlikely(!page)) {
>  		count_vm_event(THP_FAULT_FALLBACK);
> @@ -1290,7 +1299,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
>  alloc:
>  	if (transparent_hugepage_enabled(vma) &&
>  	    !transparent_hugepage_debug_cow()) {
> -		huge_gfp = alloc_hugepage_direct_gfpmask(vma);
> +		huge_gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
>  		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
>  	} else
>  		new_page = NULL;
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index da858f794eb6..75bbfc3d6233 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1648,7 +1648,7 @@ struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
>   * freeing by another task.  It is the caller's responsibility to free the
>   * extra reference for shared policies.
>   */
> -static struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
> +struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
>  						unsigned long addr)
>  {
>  	struct mempolicy *pol = __get_vma_policy(vma, addr);
> @@ -2026,32 +2026,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  		goto out;
>  	}
>  
> -	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
> -		int hpage_node = node;
> -
> -		/*
> -		 * For hugepage allocation and non-interleave policy which
> -		 * allows the current node (or other explicitly preferred
> -		 * node) we only try to allocate from the current/preferred
> -		 * node and don't fall back to other nodes, as the cost of
> -		 * remote accesses would likely offset THP benefits.
> -		 *
> -		 * If the policy is interleave, or does not allow the current
> -		 * node in its nodemask, we allocate the standard way.
> -		 */
> -		if (pol->mode == MPOL_PREFERRED &&
> -						!(pol->flags & MPOL_F_LOCAL))
> -			hpage_node = pol->v.preferred_node;
> -
> -		nmask = policy_nodemask(gfp, pol);
> -		if (!nmask || node_isset(hpage_node, *nmask)) {
> -			mpol_cond_put(pol);
> -			page = __alloc_pages_node(hpage_node,
> -						gfp | __GFP_THISNODE, order);
> -			goto out;
> -		}
> -	}
> -

The hugepage flag passed into this function is now redundant and that
means that callers of alloc_hugepage_vma need to move back to using
alloc_pages_vma() directly and remove the API entirely. This block of
code is about both GFP flag settings and node selection but at a glance I
cannot see the point of it because it's very similar to the base page code.
The whole point may be to get around the warning in policy_node and that
could just as easily be side-stepped in alloc_hugepage_direct_gfpmask
as you do already in this patch. There should be no reason why THP has a
different policy than a base page within a single VMA.

-- 
Mel Gorman
SUSE Labs
