Subject: Re: [NUMA] Fix memory policy refcounting
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0710261638020.29369@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710261638020.29369@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 29 Oct 2007 11:48:49 -0400
Message-Id: <1193672929.5035.69.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-26 at 16:41 -0700, Christoph Lameter wrote:
> The refcounting fix that went into 2.6.23 left race conditions open because:

Christoph:  I've been testing a set of patches to address the races,
based on our recent discussions [your feed back to my last attempt].
I'll send that along for comment shortly.  Below, a few comments on this
patch.

> 
> 1. Reference counts were taken in get_vma_policy without necessarily
>    holding another lock that guaranteed the existence of the object
>    on which the reference count was taken.

Yes, this was true for the show_numa_maps() case, as we've discussed.  I
agree we need to take the mmap_sem for write in do_set_mempolicy() as we
do in do_mbind().

> 
> 2. For shared memory policies we were taking reference counts twice
>    but only release one reference. So the memory leak was not fixed.

I don't think this was the case.  You removed the code that attempted to
prevent this.  But, I admit I might have missed something...

> 
> 3. The patch figures out in multiple places if a reference
>    count on the memory policy was taken or not. However, the refcount
>    is only taken under certain conditions and these conditions may
>    change. The logic to figure out when to drop the refcount is resulting
>    in code that easily breaks.

Agreed, especially since with the fix for "other task's policy" and
noting that vma policy is protected by mmap_sem, we only need the extra
ref for shared policy and need a way to determine that we need to remove
that.

> 
> This patch fixes the issues by:
> 
> 1. Removing the logic to determine if a refcount was taken earlier.
> 
> 2. Adding a flag to all functions that can potentially take a refcount
>    on a memory. That flag is set if the refcount was taken. The code
>    using the memory policy can then just free the refcount if it was
>    actually taken.

This does add some additional code in the alloc path and adds an
additional arg to a lot of functions that I think we can remove by
marking shared policies as such and only derefing those.  

> 
> 3. Protect against races between set_mem_policy and numa_maps by taking
>    an mmap_sem writelock when a tasks memory policy is changed.

Agreed.

> 
> 4. There were a couple of places where get_vma_policy() etc is used that
>    were missed in the 2.6.23 fix. Fix those too.
> 
> Note: IMHO removing the shared memory policy support would be preferable.
> Shared policies can still interact in surprising ways with cpusets
> and cannot be handled in a reasonable way by page migration.

Yeah, yeah, yeah.  But I consider that to be cpusets' fault and not
shared memory policy.  I still have use for the latter.  We need to find
a way to accomodate all of our requirements, even if it means
documenting that shared memory policy must be used very carefully with
cpusets--or not at all with dynamically changing cpusets.  I can
certainly live with that.

> 
> The removal of shared policy support would result in the refcount issues
> going away and code would be much simpler. Semantics would be consistent in
> that memory policies only apply to a single process. Sharing of memory policies
> would only occur in a controlled way that does not require extra refcounting
> for the use of a policy.

Yes, and we'd loose control over placement of shared pages except by
hacking our task policy and prefaulting, or requiring every program that
attaches to be aware of the numa policy of the overall application.  I
find this as objectionable as you find shared policies.  

> 
> We have already vma policy pointers that are currently unused for shmem areas
> and could replicate shared policies by setting these pointers in each vma that
> is pointing to a shmem area. 

Doesn't work for me. :(

> Changing a shared policy would then require
> iterating over all processes using the policy using the reverse maps. At that
> point cpuset constraints etc could be considered and eventually a policy change
> could even be rejected on the ground that a consistent change is not possible
> given the other constraints of the shmem area.

Policy remapping isn't already complex enough for you, huh? :-)

> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/linux/mempolicy.h |    7 +-
>  include/linux/mm.h        |    2 
>  ipc/shm.c                 |    4 -
>  mm/hugetlb.c              |    6 +-
>  mm/mempolicy.c            |  113 ++++++++++++++++++----------------------------
>  mm/shmem.c                |   17 ++++--
>  6 files changed, 67 insertions(+), 82 deletions(-)
> 
> Index: linux-2.6/include/linux/mempolicy.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mempolicy.h	2007-10-26 15:46:53.000000000 -0700
> +++ linux-2.6/include/linux/mempolicy.h	2007-10-26 15:50:00.000000000 -0700
> @@ -140,7 +140,7 @@ int mpol_set_shared_policy(struct shared
>  				struct mempolicy *new);
>  void mpol_free_shared_policy(struct shared_policy *p);
>  struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
> -					    unsigned long idx);
> +			    unsigned long idx, int *ref);
>  
>  extern void numa_default_policy(void);
>  extern void numa_policy_init(void);
> @@ -151,7 +151,8 @@ extern void mpol_fix_fork_child_flag(str
>  
>  extern struct mempolicy default_policy;
>  extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
> -		unsigned long addr, gfp_t gfp_flags, struct mempolicy **mpol);
> +			unsigned long addr, gfp_t gfp_flags,
> +			struct mempolicy **mpol, int *ref);
>  extern unsigned slab_node(struct mempolicy *policy);
>  
>  extern enum zone_type policy_zone;
> @@ -239,7 +240,7 @@ static inline void mpol_fix_fork_child_f
>  }
>  
>  static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
> - 		unsigned long addr, gfp_t gfp_flags, struct mempolicy **mpol)
> +		unsigned long addr, gfp_t gfp_flags, int *ref)
>  {
>  	return NODE_DATA(0)->node_zonelists + gfp_zone(gfp_flags);
>  }
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c	2007-10-26 15:46:53.000000000 -0700
> +++ linux-2.6/mm/hugetlb.c	2007-10-26 15:50:46.000000000 -0700
> @@ -75,9 +75,10 @@ static struct page *dequeue_huge_page(st
>  {
>  	int nid;
>  	struct page *page = NULL;
> +	int ref = 0;
>  	struct mempolicy *mpol;
>  	struct zonelist *zonelist = huge_zonelist(vma, address,
> -					htlb_alloc_mask, &mpol);
> +					htlb_alloc_mask, &mpol, &ref);
>  	struct zone **z;
>  
>  	for (z = zonelist->zones; *z; z++) {
> @@ -94,7 +95,8 @@ static struct page *dequeue_huge_page(st
>  			break;
>  		}
>  	}
> -	mpol_free(mpol);	/* unref if mpol !NULL */
> +	if (ref)
> +		mpol_free(mpol);
This shouldn't be necessary if huge_zonelist only returns a non-NULL
mpol if the unref is required, as I had done.  mpol_free() on a NULL
mpol is a no-op, as the comment was intended to convey.  You could drop
the extra ref argument to huge_zonelist--not that this should be much of
a fast path.

>  	return page;
>  }
>  
> Index: linux-2.6/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.orig/mm/mempolicy.c	2007-10-26 15:46:53.000000000 -0700
> +++ linux-2.6/mm/mempolicy.c	2007-10-26 16:23:54.000000000 -0700
> @@ -531,6 +531,7 @@ static long do_get_mempolicy(int *policy
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma = NULL;
>  	struct mempolicy *pol = current->mempolicy;
> +	int ref = 0;
>  
>  	cpuset_update_task_memory_state();
>  	if (flags &
> @@ -553,7 +554,7 @@ static long do_get_mempolicy(int *policy
>  			return -EFAULT;
>  		}
>  		if (vma->vm_ops && vma->vm_ops->get_policy)
> -			pol = vma->vm_ops->get_policy(vma, addr);
> +			pol = vma->vm_ops->get_policy(vma, addr, &ref);
>  		else
>  			pol = vma->vm_policy;
>  	} else if (addr)
> @@ -587,7 +588,9 @@ static long do_get_mempolicy(int *policy
>  	if (nmask)
>  		get_zonemask(pol, nmask);
>  
> - out:
> +out:
> +	if (ref)
> +		mpol_free(pol);
>  	if (vma)
>  		up_read(&current->mm->mmap_sem);
>  	return err;
> @@ -917,7 +920,10 @@ asmlinkage long sys_set_mempolicy(int mo
>  	err = get_nodes(&nodes, nmask, maxnode);
>  	if (err)
>  		return err;
> -	return do_set_mempolicy(mode, &nodes);
> +	down_write(&current->mm->mmap_sem);
> +	err = do_set_mempolicy(mode, &nodes);
> +	up_write(&current->mm->mmap_sem);
> +	return err;
>  }
>  
>  asmlinkage long sys_migrate_pages(pid_t pid, unsigned long maxnode,
> @@ -1097,35 +1103,31 @@ asmlinkage long compat_sys_mbind(compat_
>  
>  /*
>   * get_vma_policy(@task, @vma, @addr)
> - * @task - task for fallback if vma policy == default
> + * @task  - task for fallback if vma policy == default
>   * @vma   - virtual memory area whose policy is sought
>   * @addr  - address in @vma for shared policy lookup
> + * @ref   - reference was taken against policy
>   *
>   * Returns effective policy for a VMA at specified address.
>   * Falls back to @task or system default policy, as necessary.
> - * Returned policy has extra reference count if shared, vma,
> - * or some other task's policy [show_numa_maps() can pass
> - * @task != current].  It is the caller's responsibility to
> - * free the reference in these cases.
> - */
> -static struct mempolicy * get_vma_policy(struct task_struct *task,
> -		struct vm_area_struct *vma, unsigned long addr)
> + * It is the caller's responsibility to free the reference count
> + * on the policy if any was taken. The refcount guarantees that
> + * the memory policy does not vanish from under us.
> +*/
> +static struct mempolicy *get_vma_policy(struct task_struct *task,
> +		struct vm_area_struct *vma, unsigned long addr, int *ref)
>  {
>  	struct mempolicy *pol = task->mempolicy;
> -	int shared_pol = 0;
>  
>  	if (vma) {
> -		if (vma->vm_ops && vma->vm_ops->get_policy) {
> -			pol = vma->vm_ops->get_policy(vma, addr);
> -			shared_pol = 1;	/* if pol non-NULL, add ref below */
Mea culpa.  Comment is wrong here.  It AVOIDS adding a ref to shared
pols.

> -		} else if (vma->vm_policy &&
> +		if (vma->vm_ops && vma->vm_ops->get_policy)
> +			pol = vma->vm_ops->get_policy(vma, addr, ref);
> +		else if (vma->vm_policy &&
>  				vma->vm_policy->policy != MPOL_DEFAULT)
>  			pol = vma->vm_policy;
>  	}
>  	if (!pol)
>  		pol = &default_policy;
> -	else if (!shared_pol && pol != current->mempolicy)
                   ^^^^^^^^^^^  won't do the get if shared_pol is true
> -		mpol_get(pol);	/* vma or other task's policy */
>  	return pol;
>  }
>  
> @@ -1247,39 +1249,23 @@ static inline unsigned interleave_nid(st
>   * @addr = address in @vma for shared policy lookup and interleave policy
>   * @gfp_flags = for requested zone
>   * @mpol = pointer to mempolicy pointer for reference counted 'BIND policy
> + * @ref = indicates that a refcount was taken against mpol.
>   *
> - * Returns a zonelist suitable for a huge page allocation.
> - * If the effective policy is 'BIND, returns pointer to policy's zonelist.
> - * If it is also a policy for which get_vma_policy() returns an extra
> - * reference, we must hold that reference until after allocation.
> - * In that case, return policy via @mpol so hugetlb allocation can drop
> - * the reference.  For non-'BIND referenced policies, we can/do drop the
> - * reference here, so the caller doesn't need to know about the special case
> - * for default and current task policy.
> + * Returns a zonelist suitable for a huge page allocation. The caller must
> + * release the memory policy refcount if ref != 0. The zonelist may be freed
> + * at any time after the reference count is released.
>   */
>  struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
> -				gfp_t gfp_flags, struct mempolicy **mpol)
> +			gfp_t gfp_flags, struct mempolicy **mpol, int *ref)
>  {
> -	struct mempolicy *pol = get_vma_policy(current, vma, addr);
> -	struct zonelist *zl;
> -
> -	*mpol = NULL;		/* probably no unref needed */
> -	if (pol->policy == MPOL_INTERLEAVE) {
> +	*mpol = get_vma_policy(current, vma, addr, ref);
> +	if ((*mpol)->policy == MPOL_INTERLEAVE) {
>  		unsigned nid;
>  
> -		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
> -		__mpol_free(pol);		/* finished with pol */

Again, his was an error on my part.  Should have unconditionally free'd.
Most recent series fixes this.

> +		nid = interleave_nid(*mpol, vma, addr, HPAGE_SHIFT);
>  		return NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_flags);
>  	}
> -
> -	zl = zonelist_policy(GFP_HIGHUSER, pol);
> -	if (unlikely(pol != &default_policy && pol != current->mempolicy)) {
> -		if (pol->policy != MPOL_BIND)
> -			__mpol_free(pol);	/* finished with pol */
> -		else
> -			*mpol = pol;	/* unref needed after allocation */
> -	}
> -	return zl;
> +	return zonelist_policy(GFP_HIGHUSER, *mpol);
>  }
>  #endif
>  
> @@ -1323,8 +1309,9 @@ static struct page *alloc_page_interleav
>  struct page *
>  alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
>  {
> -	struct mempolicy *pol = get_vma_policy(current, vma, addr);
> -	struct zonelist *zl;
> +	int ref = 0;
> +	struct mempolicy *pol = get_vma_policy(current, vma, addr, &ref);
> +	struct page *page;
>  
>  	cpuset_update_task_memory_state();
>  
> @@ -1332,21 +1319,12 @@ alloc_page_vma(gfp_t gfp, struct vm_area
>  		unsigned nid;
>  
>  		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
I also missed an unref here.  Fixed in soon to come series.

> -		return alloc_page_interleave(gfp, 0, nid);
> -	}
> -	zl = zonelist_policy(gfp, pol);
> -	if (pol != &default_policy && pol != current->mempolicy) {
With my latest attempt, this is only necessary for shared policies.
> -		/*
> -		 * slow path: ref counted policy -- shared or vma
> -		 */
> -		struct page *page =  __alloc_pages(gfp, 0, zl);
> -		__mpol_free(pol);
> -		return page;
> -	}
> -	/*
> -	 * fast path:  default or task policy
> -	 */
> -	return __alloc_pages(gfp, 0, zl);
> +		page = alloc_page_interleave(gfp, 0, nid);
> +	} else
> +		page = __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
> +	if (ref)
> +		mpol_free(pol);
> +	return page;

Andi wanted to keep the fast path as a tail-call here.  I was trying to
preserve that.  
>  }
>  
>  /**
> @@ -1519,7 +1497,8 @@ static void sp_insert(struct shared_poli
>  
>  /* Find shared policy intersecting idx */
>  struct mempolicy *
> -mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
> +mpol_shared_policy_lookup(struct shared_policy *sp,
> +			unsigned long idx, int *ref)
>  {
>  	struct mempolicy *pol = NULL;
>  	struct sp_node *sn;
> @@ -1531,6 +1510,7 @@ mpol_shared_policy_lookup(struct shared_
>  	if (sn) {
>  		mpol_get(sn->policy);
>  		pol = sn->policy;
> +		(*ref)++;
>  	}
>  	spin_unlock(&sp->lock);
>  	return pol;
> @@ -1945,8 +1925,9 @@ int show_numa_map(struct seq_file *m, vo
>  	struct numa_maps *md;
>  	struct file *file = vma->vm_file;
>  	struct mm_struct *mm = vma->vm_mm;
> -	struct mempolicy *pol;
>  	int n;
> +	int ref = 0;
> +	struct mempolicy *mpol;
>  	char buffer[50];
>  
>  	if (!mm)
> @@ -1956,13 +1937,10 @@ int show_numa_map(struct seq_file *m, vo
>  	if (!md)
>  		return 0;
>  
> -	pol = get_vma_policy(priv->task, vma, vma->vm_start);
> -	mpol_to_str(buffer, sizeof(buffer), pol);
> -	/*
> -	 * unref shared or other task's mempolicy
> -	 */
> -	if (pol != &default_policy && pol != current->mempolicy)
> -		__mpol_free(pol);
> +	mpol = get_vma_policy(priv->task, vma, vma->vm_start, &ref);
> +	mpol_to_str(buffer, sizeof(buffer), mpol);
> +	if (ref)
> +		mpol_free(mpol);
If we really want to add the ref argument to get_vma_policy(), we could
avoid bringing it down this deeply by requiring that all get_policy()
vm_ops add the extra ref [these are only used for shared memory policy
now] and set ref !0 when get_policy() returns a non-null policy.  This
would be an alternative to marking shared policies as such.

>  
>  	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
>  
> Index: linux-2.6/mm/shmem.c
> ===================================================================
> --- linux-2.6.orig/mm/shmem.c	2007-10-26 15:46:53.000000000 -0700
> +++ linux-2.6/mm/shmem.c	2007-10-26 15:50:00.000000000 -0700
> @@ -1015,14 +1015,16 @@ static struct page *shmem_swapin_async(s
>  {
>  	struct page *page;
>  	struct vm_area_struct pvma;
> +	int ref = 0;
>  
>  	/* Create a pseudo vma that just contains the policy */
>  	memset(&pvma, 0, sizeof(struct vm_area_struct));
>  	pvma.vm_end = PAGE_SIZE;
>  	pvma.vm_pgoff = idx;
> -	pvma.vm_policy = mpol_shared_policy_lookup(p, idx);
> +	pvma.vm_policy = mpol_shared_policy_lookup(p, idx, &ref);
>  	page = read_swap_cache_async(entry, &pvma, 0);
> -	mpol_free(pvma.vm_policy);

By the way, my shared policy series, that you love so much ;), obviates
all of this pseudo-vma stuff.  This function becomes practically a
one-liner.  I've been holding off on that while all the other mempolicy
stuff [Mel's work, ref counting, ...] settles down.

> +	if (ref)
> +		mpol_free(pvma.vm_policy);
>  	return page;
>  }
>  
> @@ -1052,13 +1054,16 @@ shmem_alloc_page(gfp_t gfp, struct shmem
>  {
>  	struct vm_area_struct pvma;
>  	struct page *page;
> +	int ref = 0;
>  
>  	memset(&pvma, 0, sizeof(struct vm_area_struct));
> -	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
> +	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy,
> +							idx, &ref);
>  	pvma.vm_pgoff = idx;
>  	pvma.vm_end = PAGE_SIZE;
>  	page = alloc_page_vma(gfp | __GFP_ZERO, &pvma, 0);

Again, we can dispense with pseudo-vma's here, in time.

> -	mpol_free(pvma.vm_policy);
> +	if (ref)
> +		mpol_free(pvma.vm_policy);
>  	return page;
>  }
>  #else
> @@ -1336,13 +1341,13 @@ static int shmem_set_policy(struct vm_ar
>  }
>  
>  static struct mempolicy *shmem_get_policy(struct vm_area_struct *vma,
> -					  unsigned long addr)
> +				 unsigned long addr, int *ref)
>  {
>  	struct inode *i = vma->vm_file->f_path.dentry->d_inode;
>  	unsigned long idx;
>  
>  	idx = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> -	return mpol_shared_policy_lookup(&SHMEM_I(i)->policy, idx);
> +	return mpol_shared_policy_lookup(&SHMEM_I(i)->policy, idx, ref);
>  }
>  #endif
>  
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h	2007-10-26 15:46:53.000000000 -0700
> +++ linux-2.6/include/linux/mm.h	2007-10-26 15:50:00.000000000 -0700
> @@ -173,7 +173,7 @@ struct vm_operations_struct {
>  #ifdef CONFIG_NUMA
>  	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
>  	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
> -					unsigned long addr);
> +				unsigned long addr, int *ref);
>  	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
>  		const nodemask_t *to, unsigned long flags);
>  #endif
> Index: linux-2.6/ipc/shm.c
> ===================================================================
> --- linux-2.6.orig/ipc/shm.c	2007-10-26 15:46:53.000000000 -0700
> +++ linux-2.6/ipc/shm.c	2007-10-26 15:50:00.000000000 -0700
> @@ -279,14 +279,14 @@ static int shm_set_policy(struct vm_area
>  }
>  
>  static struct mempolicy *shm_get_policy(struct vm_area_struct *vma,
> -					unsigned long addr)
> +					unsigned long addr, int *ref)
>  {
>  	struct file *file = vma->vm_file;
>  	struct shm_file_data *sfd = shm_file_data(file);
>  	struct mempolicy *pol = NULL;
>  
>  	if (sfd->vm_ops->get_policy)
> -		pol = sfd->vm_ops->get_policy(vma, addr);
> +		pol = sfd->vm_ops->get_policy(vma, addr, ref);
>  	else if (vma->vm_policy)
>  		pol = vma->vm_policy;
>  	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
