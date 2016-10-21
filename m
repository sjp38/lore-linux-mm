Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA2A6B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 07:52:44 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x79so21328515lff.2
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 04:52:44 -0700 (PDT)
Received: from mail-lf0-f66.google.com (mail-lf0-f66.google.com. [209.85.215.66])
        by mx.google.com with ESMTPS id j123si1112499lfe.0.2016.10.21.04.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Oct 2016 04:52:43 -0700 (PDT)
Received: by mail-lf0-f66.google.com with SMTP id x23so5258269lfi.1
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 04:52:42 -0700 (PDT)
Date: Fri, 21 Oct 2016 13:52:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, mempolicy: clean up __GFP_THISNODE confusion in
 policy_zonelist
Message-ID: <20161021115240.GI6045@dhcp22.suse.cz>
References: <20161013125958.32155-1-mhocko@kernel.org>
 <877f92ue91.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877f92ue91.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 21-10-16 17:04:50, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > From: Michal Hocko <mhocko@suse.com>
> >
> > __GFP_THISNODE is documented to enforce the allocation to be satisified
> > from the requested node with no fallbacks or placement policy
> > enforcements. policy_zonelist seemingly breaks this semantic if the
> > current policy is MPOL_MBIND and instead of taking the node it will
> > fallback to the first node in the mask if the requested one is not in
> > the mask. This is confusing to say the least because it fact we
> > shouldn't ever go that path. First tasks shouldn't be scheduled on CPUs
> > with nodes outside of their mempolicy binding. And secondly
> > policy_zonelist is called only from 3 places:
> > - huge_zonelist - never should do __GFP_THISNODE when going this path
> > - alloc_pages_vma - which shouldn't depend on __GFP_THISNODE either
> > - alloc_pages_current - which uses default_policy id __GFP_THISNODE is
> >   used
> >
> > So we shouldn't even need to care about this possibility and can drop
> > the confusing code. Let's keep a WARN_ON_ONCE in place to catch
> > potential users and fix them up properly (aka use a different allocation
> > function which ignores mempolicy).
> >
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >
> > Hi,
> > I have noticed this while discussing this code [1]. The code as is
> > quite confusing and I think it is worth cleaning up. I decided to be
> > conservative and keep at least WARN_ON_ONCE if we have some caller which
> > relies on __GFP_THISNODE in a mempolicy context so that we can fix it up.
> >
> > [1] http://lkml.kernel.org/r/57FE0184.6030008@linux.vnet.ibm.com
> >
> >  mm/mempolicy.c | 24 ++++++++----------------
> >  1 file changed, 8 insertions(+), 16 deletions(-)
> >
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index ad1c96ac313c..33a305397bd4 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -1679,25 +1679,17 @@ static nodemask_t *policy_nodemask(gfp_t gfp, struct mempolicy *policy)
> >  static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
> >  	int nd)
> >  {
> > -	switch (policy->mode) {
> > -	case MPOL_PREFERRED:
> > -		if (!(policy->flags & MPOL_F_LOCAL))
> > -			nd = policy->v.preferred_node;
> > -		break;
> > -	case MPOL_BIND:
> > +	if (policy->mode == MPOL_PREFERRED && !(policy->flags & MPOL_F_LOCAL))
> > +		nd = policy->v.preferred_node;
> > +	else {
> >  		/*
> > -		 * Normally, MPOL_BIND allocations are node-local within the
> > -		 * allowed nodemask.  However, if __GFP_THISNODE is set and the
> > -		 * current node isn't part of the mask, we use the zonelist for
> > -		 * the first node in the mask instead.
> > +		 * __GFP_THISNODE shouldn't even be used with the bind policy because
> > +		 * we might easily break the expectation to stay on the requested node
> > +		 * and not break the policy.
> >  		 */
> > -		if (unlikely(gfp & __GFP_THISNODE) &&
> > -				unlikely(!node_isset(nd, policy->v.nodes)))
> > -			nd = first_node(policy->v.nodes);
> > -		break;
> > -	default:
> > -		BUG();
> > +		WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
> >  	}
> > +
> >  	return node_zonelist(nd, gfp);
> >  }
> >  
> 
> For both MPOL_PREFERED and MPOL_INTERLEAVE we pick the zone list from
> the node other than the current running node. Why don't we do that for
> MPOL_BIND ?ie, if the current node is not part of the policy node mask
> why are we not picking the first node from the policy node mask for
> MPOL_BIND ?

I am not sure I understand your question here. There is no
__GFP_THISNODE specific code for those policies.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
