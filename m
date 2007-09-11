Subject: Re: [PATCH/RFC 1/5] Mem Policy:  fix reference counting
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1189536502.32731.83.camel@localhost>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <20070830185100.22619.197.sendpatchset@localhost>
	 <1189536502.32731.83.camel@localhost>
Content-Type: text/plain
Date: Tue, 11 Sep 2007 14:12:13 -0400
Message-Id: <1189534333.5036.48.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-09-11 at 19:48 +0100, Mel Gorman wrote:
> You know this stuff better than I do. Take suggestions here with a large
> grain of salt.

Your comments are on the mark.  See responses below.

> 
> On Thu, 2007-08-30 at 14:51 -0400, Lee Schermerhorn wrote:
<patch description snipped>
> > Index: Linux/mm/mempolicy.c
> > ===================================================================
> > --- Linux.orig/mm/mempolicy.c	2007-08-29 10:05:19.000000000 -0400
> > +++ Linux/mm/mempolicy.c	2007-08-29 13:31:42.000000000 -0400
> > @@ -1083,21 +1083,37 @@ asmlinkage long compat_sys_mbind(compat_
> >  
> >  #endif
> >  
> > -/* Return effective policy for a VMA */
> > +/*
> > + * get_vma_policy(@task, @vma, @addr)
> > + * @task - task for fallback if vma policy == default
> > + * @vma   - virtual memory area whose policy is sought
> > + * @addr  - address in @vma for shared policy lookup
> > + *
> > + * Returns effective policy for a VMA at specified address.
> > + * Falls back to @task or system default policy, as necessary.
> > + * Returned policy has extra reference count if shared, vma,
> > + * or some other task's policy [show_numa_maps() can pass
> > + * @task != current].  It is the caller's responsibility to
> > + * free the reference in these cases.
> > + */
> >  static struct mempolicy * get_vma_policy(struct task_struct *task,
> >  		struct vm_area_struct *vma, unsigned long addr)
> >  {
> >  	struct mempolicy *pol = task->mempolicy;
> > +	int shared_pol = 0;
> >  
> >  	if (vma) {
> > -		if (vma->vm_ops && vma->vm_ops->get_policy)
> > +		if (vma->vm_ops && vma->vm_ops->get_policy) {
> >  			pol = vma->vm_ops->get_policy(vma, addr);
> > -		else if (vma->vm_policy &&
> > +			shared_pol = 1;	/* if pol non-NULL, that is */
> 
> What do you mean here by "pol non-NULL, that is". Where do you check
> that vm_ops->get_policy() returned a non-NULL value?
> 
> Should the comment be 
> 
> /* Policy if set is shared, check later */
> 
> and rename the variable to check_shared_pol?

You interpret my cryptic comment correctly.  However, your suggested fix
doesn't quite capture my way of looking at it.  Would it work for you if
I change it to:  /* if pol non-NULL, add ref below */  ???  That fits in
80 columns ;-)!

> 
> > +		} else if (vma->vm_policy &&
> >  				vma->vm_policy->policy != MPOL_DEFAULT)
> >  			pol = vma->vm_policy;
> >  	}
> >  	if (!pol)
> >  		pol = &default_policy;
> > +	else if (!shared_pol && pol != current->mempolicy)
> > +		mpol_get(pol);	/* vma or other task's policy */
> >  	return pol;
> >  }
> >  
> > @@ -1213,19 +1229,45 @@ static inline unsigned interleave_nid(st
> >  }
> >  
> >  #ifdef CONFIG_HUGETLBFS
> > -/* Return a zonelist suitable for a huge page allocation. */
> > +/*
> > + * huge_zonelist(@vma, @addr, @gfp_flags, @mpol)
> > + * @vma = virtual memory area whose policy is sought
> > + * @addr = address in @vma for shared policy lookup and interleave policy
> > + * @gfp_flags = for requested zone
> > + * @mpol = pointer to mempolicy pointer for reference counted 'BIND policy
> > + *
> > + * Returns a zonelist suitable for a huge page allocation.
> > + * If the effective policy is 'BIND, returns pointer to policy's zonelist.
> 
> This comment here becomes redundant if applied on top of one-zonelist as
> you suggest you will be doing later. The zonelist returned for MPOL_BIND
> is the nodes zonelist but it is filtered based on a nodemask.

Agreed.  When I get around to rebasing atop your patches [under the
assumption they'll hit the mm tree before these] I'll fix this up.  For
now, I've added myself a 'TODO' comment.

Note, however, that unless we take a copy of the policy's nodemask,
we'll still need to hold the reference over the allocation, I think.
Haven't looked that closely, yet.

> 
> > + * If it is also a policy for which get_vma_policy() returns an extra
> > + * reference, we must hold that reference until after allocation.
> > + * In that case, return policy via @mpol so hugetlb allocation can drop
> > + * the reference.  For non-'BIND referenced policies, we can/do drop the
> > + * reference here, so the caller doesn't need to know about the special case
> > + * for default and current task policy.
> > + */
> >  struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
> > -							gfp_t gfp_flags)
> > +				gfp_t gfp_flags, struct mempolicy **mpol)
> >  {
> >  	struct mempolicy *pol = get_vma_policy(current, vma, addr);
> > +	struct zonelist *zl;
> >  
> > +	*mpol = NULL;		/* probably no unref needed */
> >  	if (pol->policy == MPOL_INTERLEAVE) {
> >  		unsigned nid;
> >  
> >  		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
> > +		__mpol_free(pol);
> 
> So, __mpol_free() here acts as a put on the get_vma_policy() right?
> Either that needs commenting or __mpol_free() needs to be renamed to
> __mpol_put() assuming that when the count reaches 0, it really gets
> free.

Yes, the '__' version of mpol_free() takes a non-NULL policy pointer and
decrements the reference.  [w/o the '__', a NULL policy pointer is a
no-op.]  If the resulting count is zero, the policy structure, and any
attached zonelist [or nodemask, if we make those remote, as discussed in
Cambridge] is freed.   The 'free notation is Andi's original naming.
For now, rather than change that throughout the code, I'll comment this
instance.


Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
