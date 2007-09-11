Subject: Re: [PATCH/RFC 1/5] Mem Policy:  fix reference counting
From: Mel Gorman <mel@csn.ul.ie>
In-Reply-To: <20070830185100.22619.197.sendpatchset@localhost>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <20070830185100.22619.197.sendpatchset@localhost>
Content-Type: text/plain
Date: Tue, 11 Sep 2007 19:48:22 +0100
Message-Id: <1189536502.32731.83.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

You know this stuff better than I do. Take suggestions here with a large
grain of salt.

On Thu, 2007-08-30 at 14:51 -0400, Lee Schermerhorn wrote:
> PATCHRFC  1/5 Memory Policy: fix reference counting
> 
> Against 2.6.23-rc3-mm1
> 
> This patch proposes fixes to the reference counting of memory policy
> in the page allocation paths and in show_numa_map().
> 
> Shared policy lookup [shmem] has always added a reference to the
> policy, but this was never unrefed after page allocation or after
> formatting the numa map data.  
> 
> Default system policy should not require additional ref counting,
> nor should the current task's task policy.  However, show_numa_map()
> calls get_vma_policy() to examine what may be [likely is] another
> task's policy.  The latter case needs protection against freeing
> of the policy.
> 
> This patch adds a reference count to a mempolicy returned by
> get_vma_policy() when the policy is a vma policy or another
> task's mempolicy.  Again, shared policy is already reference
> counted on lookup.  A matching "unref" [__mpol_free()] is performed
> in alloc_page_vma() for shared and vma policies, and in
> show_numa_map() for shared and another task's mempolicy.
> We can call __mpol_free() directly, saving an admittedly
> inexpensive inline NULL test, because we know we have a non-NULL
> policy.
> 
> Handling policy ref counts for hugepages is a bit tricker.
> huge_zonelist() returns a zone list that might come from a 
> shared or vma 'BIND policy.  In this case, we should hold the
> reference until after the huge page allocation in 
> dequeue_hugepage().  The patch modifies huge_zonelist() to
> return a pointer to the mempolicy if it needs to be unref'd
> after allocation.
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  include/linux/mempolicy.h |    4 +-
>  mm/hugetlb.c              |    4 +-
>  mm/mempolicy.c            |   79 ++++++++++++++++++++++++++++++++++++++++------
>  3 files changed, 75 insertions(+), 12 deletions(-)
> 
> Index: Linux/mm/mempolicy.c
> ===================================================================
> --- Linux.orig/mm/mempolicy.c	2007-08-29 10:05:19.000000000 -0400
> +++ Linux/mm/mempolicy.c	2007-08-29 13:31:42.000000000 -0400
> @@ -1083,21 +1083,37 @@ asmlinkage long compat_sys_mbind(compat_
>  
>  #endif
>  
> -/* Return effective policy for a VMA */
> +/*
> + * get_vma_policy(@task, @vma, @addr)
> + * @task - task for fallback if vma policy == default
> + * @vma   - virtual memory area whose policy is sought
> + * @addr  - address in @vma for shared policy lookup
> + *
> + * Returns effective policy for a VMA at specified address.
> + * Falls back to @task or system default policy, as necessary.
> + * Returned policy has extra reference count if shared, vma,
> + * or some other task's policy [show_numa_maps() can pass
> + * @task != current].  It is the caller's responsibility to
> + * free the reference in these cases.
> + */
>  static struct mempolicy * get_vma_policy(struct task_struct *task,
>  		struct vm_area_struct *vma, unsigned long addr)
>  {
>  	struct mempolicy *pol = task->mempolicy;
> +	int shared_pol = 0;
>  
>  	if (vma) {
> -		if (vma->vm_ops && vma->vm_ops->get_policy)
> +		if (vma->vm_ops && vma->vm_ops->get_policy) {
>  			pol = vma->vm_ops->get_policy(vma, addr);
> -		else if (vma->vm_policy &&
> +			shared_pol = 1;	/* if pol non-NULL, that is */

What do you mean here by "pol non-NULL, that is". Where do you check
that vm_ops->get_policy() returned a non-NULL value?

Should the comment be 

/* Policy if set is shared, check later */

and rename the variable to check_shared_pol?

> +		} else if (vma->vm_policy &&
>  				vma->vm_policy->policy != MPOL_DEFAULT)
>  			pol = vma->vm_policy;
>  	}
>  	if (!pol)
>  		pol = &default_policy;
> +	else if (!shared_pol && pol != current->mempolicy)
> +		mpol_get(pol);	/* vma or other task's policy */
>  	return pol;
>  }
>  
> @@ -1213,19 +1229,45 @@ static inline unsigned interleave_nid(st
>  }
>  
>  #ifdef CONFIG_HUGETLBFS
> -/* Return a zonelist suitable for a huge page allocation. */
> +/*
> + * huge_zonelist(@vma, @addr, @gfp_flags, @mpol)
> + * @vma = virtual memory area whose policy is sought
> + * @addr = address in @vma for shared policy lookup and interleave policy
> + * @gfp_flags = for requested zone
> + * @mpol = pointer to mempolicy pointer for reference counted 'BIND policy
> + *
> + * Returns a zonelist suitable for a huge page allocation.
> + * If the effective policy is 'BIND, returns pointer to policy's zonelist.

This comment here becomes redundant if applied on top of one-zonelist as
you suggest you will be doing later. The zonelist returned for MPOL_BIND
is the nodes zonelist but it is filtered based on a nodemask.

> + * If it is also a policy for which get_vma_policy() returns an extra
> + * reference, we must hold that reference until after allocation.
> + * In that case, return policy via @mpol so hugetlb allocation can drop
> + * the reference.  For non-'BIND referenced policies, we can/do drop the
> + * reference here, so the caller doesn't need to know about the special case
> + * for default and current task policy.
> + */
>  struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
> -							gfp_t gfp_flags)
> +				gfp_t gfp_flags, struct mempolicy **mpol)
>  {
>  	struct mempolicy *pol = get_vma_policy(current, vma, addr);
> +	struct zonelist *zl;
>  
> +	*mpol = NULL;		/* probably no unref needed */
>  	if (pol->policy == MPOL_INTERLEAVE) {
>  		unsigned nid;
>  
>  		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
> +		__mpol_free(pol);

So, __mpol_free() here acts as a put on the get_vma_policy() right?
Either that needs commenting or __mpol_free() needs to be renamed to
__mpol_put() assuming that when the count reaches 0, it really gets
free.

>  		return NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_flags);
>  	}
> -	return zonelist_policy(GFP_HIGHUSER, pol);
> +
> +	zl = zonelist_policy(GFP_HIGHUSER, pol);
> +	if (unlikely(pol != &default_policy && pol != current->mempolicy)) {
> +		if (pol->policy != MPOL_BIND)
> +			__mpol_free(pol);	/* finished with pol */
> +		else
> +			*mpol = pol;	/* unref needed after allocation */
> +	}
> +	return zl;
>  }
>  #endif
>  
> @@ -1270,6 +1312,7 @@ struct page *
>  alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
>  {
>  	struct mempolicy *pol = get_vma_policy(current, vma, addr);
> +	struct zonelist *zl;
>  
>  	cpuset_update_task_memory_state();
>  
> @@ -1279,7 +1322,19 @@ alloc_page_vma(gfp_t gfp, struct vm_area
>  		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
>  		return alloc_page_interleave(gfp, 0, nid);
>  	}
> -	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
> +	zl = zonelist_policy(gfp, pol);
> +	if (pol != &default_policy && pol != current->mempolicy) {
> +		/*
> +		 * slow path: ref counted policy -- shared or vma
> +		 */
> +		struct page *page =  __alloc_pages(gfp, 0, zl);
> +		__mpol_free(pol);
> +		return page;
> +	}
> +	/*
> +	 * fast path:  default or task policy
> +	 */
> +	return __alloc_pages(gfp, 0, zl);
>  }
>  
>  /**
> @@ -1878,6 +1933,7 @@ int show_numa_map(struct seq_file *m, vo
>  	struct numa_maps *md;
>  	struct file *file = vma->vm_file;
>  	struct mm_struct *mm = vma->vm_mm;
> +	struct mempolicy *pol;
>  	int n;
>  	char buffer[50];
>  
> @@ -1888,8 +1944,13 @@ int show_numa_map(struct seq_file *m, vo
>  	if (!md)
>  		return 0;
>  
> -	mpol_to_str(buffer, sizeof(buffer),
> -			    get_vma_policy(priv->task, vma, vma->vm_start));
> +	pol = get_vma_policy(priv->task, vma, vma->vm_start);
> +	mpol_to_str(buffer, sizeof(buffer), pol);
> +	/*
> +	 * unref shared or other task's mempolicy
> +	 */
> +	if (pol != &default_policy && pol != current->mempolicy)
> +		__mpol_free(pol);
>  
>  	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
>  
> Index: Linux/include/linux/mempolicy.h
> ===================================================================
> --- Linux.orig/include/linux/mempolicy.h	2007-08-29 10:56:14.000000000 -0400
> +++ Linux/include/linux/mempolicy.h	2007-08-29 13:32:05.000000000 -0400
> @@ -150,7 +150,7 @@ extern void mpol_fix_fork_child_flag(str
>  
>  extern struct mempolicy default_policy;
>  extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
> -		unsigned long addr, gfp_t gfp_flags);
> +		unsigned long addr, gfp_t gfp_flags, struct mempolicy **mpol);
>  extern unsigned slab_node(struct mempolicy *policy);
>  
>  extern enum zone_type policy_zone;
> @@ -238,7 +238,7 @@ static inline void mpol_fix_fork_child_f
>  }
>  
>  static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
> -		unsigned long addr, gfp_t gfp_flags)
> +		unsigned long addr, gfp_t gfp_flags, struct mempolicy **mpol)
>  {
>  	return NODE_DATA(0)->node_zonelists + gfp_zone(gfp_flags);
>  }
> Index: Linux/mm/hugetlb.c
> ===================================================================
> --- Linux.orig/mm/hugetlb.c	2007-08-29 10:56:13.000000000 -0400
> +++ Linux/mm/hugetlb.c	2007-08-29 13:19:39.000000000 -0400
> @@ -71,8 +71,9 @@ static struct page *dequeue_huge_page(st
>  {
>  	int nid;
>  	struct page *page = NULL;
> +	struct mempolicy *mpol;
>  	struct zonelist *zonelist = huge_zonelist(vma, address,
> -						htlb_alloc_mask);
> +					htlb_alloc_mask, &mpol);
>  	struct zone **z;
>  
>  	for (z = zonelist->zones; *z; z++) {
> @@ -87,6 +88,7 @@ static struct page *dequeue_huge_page(st
>  			break;
>  		}
>  	}
> +	mpol_free(mpol);	/* maybe need unref */
>  	return page;
>  }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
