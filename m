Date: Tue, 18 Sep 2007 11:36:46 +0100
Subject: Re: [PATCH] Fix NUMA Memory Policy Reference Counting
Message-ID: <20070918103645.GC2035@skynet.ie>
References: <20070830185053.22619.96398.sendpatchset@localhost> <1190055637.5460.105.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1190055637.5460.105.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, clameter@sgi.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On (17/09/07 15:00), Lee Schermerhorn didst pronounce:
> Andi pinged me to submit this patch as stand alone.  He would like to
> see this go into 2.6.23, as he considers it a high priority bug.  This
> verion of the patch is against 23-rc4-mm1.  I have another version
> rebased against 23-rc6.  I would understand if folks were not
> comfortable with this going in at this late date.  However, I will post
> that version so that it can be added to .23 or one of the subsequent
> stable release, if folks so choose.
> 
> Christoph L was concerned about performance regression in the page
> allocation path, so I've included the results of some page allocation
> micro-benchmarks, plus kernel build results on the version of the patch
> against 23-rc6.
> 
> Note that this patch will collide with Mel Gorman's one zonelist series.
> I can rebase atop that, if Mel's series makes it into -mm before this
> one.
> 
> Mel suggested renaming mpol_free() to mpol_put() because it removes a
> reference and frees only if ref count goes to zero.  I haven't gotten
> around to that in this patch.  I would welcome other opinions on this.
> 

If this is being pushed as a fix to 2.6.23, then do the clean-up separetly
in the next cycle to avoid obscuring the fix this close to release. I still
think that mpol_put() is a much better name for a drop-ref-and-free-if-0
function than mpol_free.

> Lee
> 
> --------------------------------
> PATCH  Memory Policy: fix reference counting
> 
> Against 2.6.23-rc4-mm1
> 
> This patch proposes fixes to the reference counting of memory policy
> in the page allocation paths and in show_numa_map().  Extracted from
> my "Memory Policy Cleanups and Enhancements" series as stand-alone.
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
> Handling policy ref counts for hugepages is a bit trickier.
> huge_zonelist() returns a zone list that might come from a 
> shared or vma 'BIND policy.  In this case, we should hold the
> reference until after the huge page allocation in 
> dequeue_hugepage().  The patch modifies huge_zonelist() to
> return a pointer to the mempolicy if it needs to be unref'd
> after allocation.
> 
> Page allocation micro-benchmark:
> 
> Time to fault in 256K 16k pages [ia64] into a 4G anon segment.
> 
> Test                    23-rc4-mm1      +mempol ref count
> sys default policy        2.769s        >       2.763s [-0.006ms = 0.22%]
> task pol bind local(1)    2.789s        ~=      2.790s
> task pol bind remote(2)   3.774s        <       3.777s
> vma pol bind local(3)     2.793s        >       2.790s
> vma pol bind remote(4)    3.768s        >       3.764s
> vma pol pref local(5)     2.774s        <       2.780s [+0.006ms = 0.22%]
> vma interleave 0-3        3.445s        ~=      3.444s
> 
> Notes:
> 1) numactl -c3 -m3 
> 2) numactl -c1 -m3
> 3) memtoy bound to node 3, mbind MPOL_BIND to node 3
> 4) memtoy bound to node 1, mbind MPOL_BIND to node 3
> 5) mbind MPOL_PREFERRED, null nodemask [preferred_node == -1 internally]
> 
> I think the difference in performance, for these tests, is in the noise:  0.22% max.
> In one case in favor of the patch [system default policy] and in the other case,
> in favor of unpatched kernel [explicit local policy].
> 
> Kernel Build [16cpu, 32GB, ia64] - same patch, but atop 2.6.23-rc6;
> average of 10 runs:
> 		w/o patch	w/ refcount patch
> 	    Avg	  Std Devn	   Avg	  Std Devn
> Real:	 100.59	    0.38	 100.63	    0.43
> User:	1209.60	    0.37	1209.91	    0.31
> System:   81.52	    0.42	  81.64	    0.34
> 
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
> --- Linux.orig/mm/mempolicy.c	2007-09-17 12:18:47.000000000 -0400
> +++ Linux/mm/mempolicy.c	2007-09-17 14:48:08.000000000 -0400
> @@ -1086,21 +1086,37 @@ asmlinkage long compat_sys_mbind(compat_
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
> +			shared_pol = 1;	/* if pol non-NULL, add ref below */
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
> @@ -1216,19 +1232,45 @@ static inline unsigned interleave_nid(st
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
> +		__mpol_free(pol);		/* finished with pol */
>  		return NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_flags);
>  	}

This different handling of pol vs mpol is a bit confusing. It took me a
few minutes to pick apart what is going on despite the comment before
the function. What would the consequence be of always passing back mpol
and having the caller drop the reference?

Again, not big enough to actually halt the fix.

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
> @@ -1273,6 +1315,7 @@ struct page *
>  alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
>  {
>  	struct mempolicy *pol = get_vma_policy(current, vma, addr);
> +	struct zonelist *zl;
>  
>  	cpuset_update_task_memory_state();
>  
> @@ -1282,7 +1325,19 @@ alloc_page_vma(gfp_t gfp, struct vm_area
>  		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
>  		return alloc_page_interleave(gfp, 0, nid);
>  	}
> -	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
> +	zl = zonelist_policy(gfp, pol);
> +	if (pol != &default_policy && pol != current->mempolicy) {

Bit of a nit-pick. This

if (pol != &default_policy && pol != current->mempolicy)

check happens quite frequently. Consider making it a helper function like
is_foreign_policy() or something as a future clean-up. That's not a great
name but you get the idea. It's not vital to address as part of a fix.

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
> @@ -1881,6 +1936,7 @@ int show_numa_map(struct seq_file *m, vo
>  	struct numa_maps *md;
>  	struct file *file = vma->vm_file;
>  	struct mm_struct *mm = vma->vm_mm;
> +	struct mempolicy *pol;
>  	int n;
>  	char buffer[50];
>  
> @@ -1891,8 +1947,13 @@ int show_numa_map(struct seq_file *m, vo
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
> --- Linux.orig/include/linux/mempolicy.h	2007-09-17 12:18:47.000000000 -0400
> +++ Linux/include/linux/mempolicy.h	2007-09-17 14:47:58.000000000 -0400
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
> --- Linux.orig/mm/hugetlb.c	2007-09-17 14:47:54.000000000 -0400
> +++ Linux/mm/hugetlb.c	2007-09-17 14:47:58.000000000 -0400
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

If you always passed back mpol and did the free here, it ref/unref
should be clearer.

>  	return page;
>  }
>  

I haven't tested it but it looks good. Any problems I have are of the
cleanup or nit-pick nature and not sufficent to warrent another
revision. I would like to see the cleanups after 2.6.23 though.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
