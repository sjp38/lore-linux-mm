Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2132D6B0269
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 16:17:55 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e6-v6so5344011pge.5
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 13:17:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v1-v6sor4561847plb.46.2018.10.04.13.17.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 13:17:54 -0700 (PDT)
Date: Thu, 4 Oct 2018 13:17:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm, thp: consolidate THP gfp handling into
 alloc_hugepage_direct_gfpmask
In-Reply-To: <20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1>
Message-ID: <alpine.DEB.2.21.1810041317010.16935@chino.kir.corp.google.com>
References: <20180925120326.24392-1-mhocko@kernel.org> <20180925120326.24392-3-mhocko@kernel.org> <20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, 26 Sep 2018, Kirill A. Shutemov wrote:

> On Tue, Sep 25, 2018 at 02:03:26PM +0200, Michal Hocko wrote:
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index c3bc7e9c9a2a..c0bcede31930 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -629,21 +629,40 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
> >   *	    available
> >   * never: never stall for any thp allocation
> >   */
> > -static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
> > +static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
> >  {
> >  	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
> > +	gfp_t this_node = 0;
> > +
> > +#ifdef CONFIG_NUMA
> > +	struct mempolicy *pol;
> > +	/*
> > +	 * __GFP_THISNODE is used only when __GFP_DIRECT_RECLAIM is not
> > +	 * specified, to express a general desire to stay on the current
> > +	 * node for optimistic allocation attempts. If the defrag mode
> > +	 * and/or madvise hint requires the direct reclaim then we prefer
> > +	 * to fallback to other node rather than node reclaim because that
> > +	 * can lead to excessive reclaim even though there is free memory
> > +	 * on other nodes. We expect that NUMA preferences are specified
> > +	 * by memory policies.
> > +	 */
> > +	pol = get_vma_policy(vma, addr);
> > +	if (pol->mode != MPOL_BIND)
> > +		this_node = __GFP_THISNODE;
> > +	mpol_cond_put(pol);
> > +#endif
> 
> I'm not very good with NUMA policies. Could you explain in more details how
> the code above is equivalent to the code below?
> 

It breaks mbind() because new_page() is now using numa_node_id() to 
allocate migration targets for instead of using the mempolicy.  I'm not 
sure that this patch was tested for mbind().
