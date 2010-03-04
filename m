Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 01C7B6B0078
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 09:31:56 -0500 (EST)
Subject: Re: [PATCH 4/4] cpuset,mm: use rwlock to protect task->mempolicy
 and mems_allowed
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <4B8E3F77.6070201@cn.fujitsu.com>
References: <4B8E3F77.6070201@cn.fujitsu.com>
Content-Type: text/plain
Date: Thu, 04 Mar 2010 09:31:50 -0500
Message-Id: <1267713110.29020.26.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-03-03 at 18:52 +0800, Miao Xie wrote:
> if MAX_NUMNODES > BITS_PER_LONG, loading/storing task->mems_allowed or mems_allowed in
> task->mempolicy are not atomic operations, and the kernel page allocator gets an empty
> mems_allowed when updating task->mems_allowed or mems_allowed in task->mempolicy. So we
> use a rwlock to protect them to fix this probelm.
> 
> Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
> ---
>  include/linux/cpuset.h    |  104 +++++++++++++++++++++++++++++-
>  include/linux/init_task.h |    8 +++
>  include/linux/mempolicy.h |   24 ++++++--
>  include/linux/sched.h     |   17 ++++-
>  kernel/cpuset.c           |  113 +++++++++++++++++++++++++++------
>  kernel/exit.c             |    4 +
>  kernel/fork.c             |   13 ++++-
>  mm/hugetlb.c              |    3 +
>  mm/mempolicy.c            |  153 ++++++++++++++++++++++++++++++++++----------
>  mm/slab.c                 |   27 +++++++-
>  mm/slub.c                 |   10 +++
>  11 files changed, 403 insertions(+), 73 deletions(-)
> 
<snip>
> 
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 1cc966c..aae93bc 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -51,6 +51,7 @@ enum {
>   */
>  #define MPOL_F_SHARED  (1 << 0)	/* identify shared policies */
>  #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
> +#define MPOL_F_TASK    (1 << 2)	/* identify tasks' policies */
>  
>  #ifdef __KERNEL__
>  
> @@ -107,6 +108,12 @@ struct mempolicy {
>   * The default fast path of a NULL MPOL_DEFAULT policy is always inlined.
>   */
>  
> +extern struct mempolicy *__mpol_alloc(void);
> +static inline struct mempolicy *mpol_alloc(void)
> +{
> +	return __mpol_alloc();
> +}
> +
>  extern void __mpol_put(struct mempolicy *pol);
>  static inline void mpol_put(struct mempolicy *pol)
>  {
> @@ -125,7 +132,7 @@ static inline int mpol_needs_cond_ref(struct mempolicy *pol)
>  
>  static inline void mpol_cond_put(struct mempolicy *pol)
>  {
> -	if (mpol_needs_cond_ref(pol))
> +	if (mpol_needs_cond_ref(pol) || (pol && (pol->flags & MPOL_F_TASK)))
>  		__mpol_put(pol);
>  }
>  
> @@ -193,8 +200,8 @@ struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
>  
>  extern void numa_default_policy(void);
>  extern void numa_policy_init(void);
> -extern void mpol_rebind_task(struct task_struct *tsk,
> -					const nodemask_t *new);
> +extern int mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
> +				struct mempolicy *newpol);
>  extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
>  extern void mpol_fix_fork_child_flag(struct task_struct *p);
>  
> @@ -249,6 +256,11 @@ static inline int mpol_equal(struct mempolicy *a, struct mempolicy *b)
>  	return 1;
>  }
>  
> +static inline struct mempolicy *mpol_alloc(void)
> +{
> +	return NULL;
> +}
> +
>  static inline void mpol_put(struct mempolicy *p)
>  {
>  }
> @@ -307,9 +319,11 @@ static inline void numa_default_policy(void)
>  {
>  }
>  
> -static inline void mpol_rebind_task(struct task_struct *tsk,
> -					const nodemask_t *new)
> +static inline int mpol_rebind_task(struct task_struct *tsk,
> +					const nodemask_t *new,
> +					struct mempolicy *newpol)
>  {
> +	return 0;
>  }
>  
>  static inline void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
<snip>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 290fb5b..324dfc3 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -190,8 +190,9 @@ static int mpol_new_bind(struct mempolicy *pol, const nodemask_t *nodes)
>   * parameter with respect to the policy mode and flags.  But, we need to
>   * handle an empty nodemask with MPOL_PREFERRED here.
>   *
> - * Must be called holding task's alloc_lock to protect task's mems_allowed
> - * and mempolicy.  May also be called holding the mmap_semaphore for write.
> + * Must be called using write_mem_lock_irqsave()/write_mem_unlock_irqrestore()
> + * to protect task's mems_allowed and mempolicy.  May also be called holding
> + * the mmap_semaphore for write.
>   */
>  static int mpol_set_nodemask(struct mempolicy *pol,
>  		     const nodemask_t *nodes, struct nodemask_scratch *nsc)
> @@ -270,6 +271,16 @@ static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
>  	return policy;
>  }
>  
> +struct mempolicy *__mpol_alloc(void)
> +{
> +	struct mempolicy *pol;
> +
> +	pol = kmem_cache_alloc(policy_cache, GFP_KERNEL);
> +	if (pol)
> +		atomic_set(&pol->refcnt, 1);
> +	return pol;
> +}
> +
>  /* Slow path of a mpol destructor. */
>  void __mpol_put(struct mempolicy *p)
>  {
> @@ -347,12 +358,30 @@ static void mpol_rebind_policy(struct mempolicy *pol,
>   * Wrapper for mpol_rebind_policy() that just requires task
>   * pointer, and updates task mempolicy.
>   *
> - * Called with task's alloc_lock held.
> + * if task->pol==NULL, it will return -1, and tell us it is unnecessary to
> + * rebind task's mempolicy.
> + *
> + * Using write_mem_lock_irqsave()/write_mem_unlock_irqrestore() to protect it.
>   */
> -
> -void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new)
> +int mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
> +						struct mempolicy *newpol)
>  {
> +#if MAX_NUMNODES > BITS_PER_LONG
> +	struct mempolicy *pol = tsk->mempolicy;
> +
> +	if (!pol)
> +		return -1;
> +
> +	*newpol = *pol;
> +	atomic_set(&newpol->refcnt, 1);
> +
> +	mpol_rebind_policy(newpol, new);
> +	tsk->mempolicy = newpol;
> +	mpol_put(pol);
> +#else
>  	mpol_rebind_policy(tsk->mempolicy, new);
> +#endif
> +	return 0;
>  }
>  
>  /*
> @@ -621,12 +650,13 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
>  	struct mempolicy *new, *old;
>  	struct mm_struct *mm = current->mm;
>  	NODEMASK_SCRATCH(scratch);
> +	unsigned long irqflags;
>  	int ret;
>  
>  	if (!scratch)
>  		return -ENOMEM;
>  
> -	new = mpol_new(mode, flags, nodes);
> +	new = mpol_new(mode, flags | MPOL_F_TASK, nodes);
>  	if (IS_ERR(new)) {
>  		ret = PTR_ERR(new);
>  		goto out;
> @@ -639,10 +669,10 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
>  	 */
>  	if (mm)
>  		down_write(&mm->mmap_sem);
> -	task_lock(current);
> +	write_mem_lock_irqsave(current, irqflags);
>  	ret = mpol_set_nodemask(new, nodes, scratch);
>  	if (ret) {
> -		task_unlock(current);
> +		write_mem_unlock_irqrestore(current, irqflags);
>  		if (mm)
>  			up_write(&mm->mmap_sem);
>  		mpol_put(new);
> @@ -654,7 +684,7 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
>  	if (new && new->mode == MPOL_INTERLEAVE &&
>  	    nodes_weight(new->v.nodes))
>  		current->il_next = first_node(new->v.nodes);
> -	task_unlock(current);
> +	write_mem_unlock_irqrestore(current, irqflags);
>  	if (mm)
>  		up_write(&mm->mmap_sem);
>  
> @@ -668,7 +698,9 @@ out:
>  /*
>   * Return nodemask for policy for get_mempolicy() query
>   *
> - * Called with task's alloc_lock held
> + * Must be called using read_mempolicy_lock_irqsave()/
> + * read_mempolicy_unlock_irqrestore() to
> + * protect it.
>   */
>  static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
>  {
> @@ -712,7 +744,8 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  	int err;
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma = NULL;
> -	struct mempolicy *pol = current->mempolicy;
> +	struct mempolicy *pol = NULL;
> +	unsigned long irqflags;
>  
>  	if (flags &
>  		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
> @@ -722,9 +755,10 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  		if (flags & (MPOL_F_NODE|MPOL_F_ADDR))
>  			return -EINVAL;
>  		*policy = 0;	/* just so it's initialized */
> -		task_lock(current);
> +
> +		read_mempolicy_lock_irqsave(current, irqflags);
>  		*nmask  = cpuset_current_mems_allowed;
> -		task_unlock(current);
> +		read_mempolicy_unlock_irqrestore(current, irqflags);
>  		return 0;
>  	}
>  
> @@ -747,6 +781,13 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  	} else if (addr)
>  		return -EINVAL;
>  
> +	if (!pol) {
> +		read_mempolicy_lock_irqsave(current, irqflags);
> +		pol = current->mempolicy;
> +		mpol_get(pol);
> +		read_mempolicy_unlock_irqrestore(current, irqflags);
> +	}
> +
>  	if (!pol)
>  		pol = &default_policy;	/* indicates default behavior */
>  
> @@ -756,9 +797,11 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  			if (err < 0)
>  				goto out;
>  			*policy = err;
> -		} else if (pol == current->mempolicy &&
> +		} else if (pol->flags & MPOL_F_TASK &&
>  				pol->mode == MPOL_INTERLEAVE) {
> +			read_mempolicy_lock_irqsave(current, irqflags);
>  			*policy = current->il_next;
> +			read_mempolicy_unlock_irqrestore(current, irqflags);
>  		} else {
>  			err = -EINVAL;
>  			goto out;
> @@ -780,9 +823,17 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  
>  	err = 0;
>  	if (nmask) {
> -		task_lock(current);
> +		/* Maybe task->mempolicy was updated by cpuset, so we must get
> +		 * a new one. */
> +		mpol_cond_put(pol);
> +		read_mempolicy_lock_irqsave(current, irqflags);
> +		pol = current->mempolicy;
> +		if (pol)
> +			mpol_get(pol);
> +		else
> +			pol = &default_policy;
>  		get_policy_nodemask(pol, nmask);
> -		task_unlock(current);
> +		read_mempolicy_unlock_irqrestore(current, irqflags);
>  	}
>  
>   out:
> @@ -981,6 +1032,7 @@ static long do_mbind(unsigned long start, unsigned long len,
>  	struct mempolicy *new;
>  	unsigned long end;
>  	int err;
> +	unsigned long irqflags;
>  	LIST_HEAD(pagelist);
>  
>  	if (flags & ~(unsigned long)(MPOL_MF_STRICT |
> @@ -1028,9 +1080,9 @@ static long do_mbind(unsigned long start, unsigned long len,
>  		NODEMASK_SCRATCH(scratch);
>  		if (scratch) {
>  			down_write(&mm->mmap_sem);
> -			task_lock(current);
> +			write_mem_lock_irqsave(current, irqflags);
>  			err = mpol_set_nodemask(new, nmask, scratch);
> -			task_unlock(current);
> +			write_mem_unlock_irqrestore(current, irqflags);
>  			if (err)
>  				up_write(&mm->mmap_sem);
>  		} else
> @@ -1370,7 +1422,8 @@ asmlinkage long compat_sys_mbind(compat_ulong_t start, compat_ulong_t len,
>  static struct mempolicy *get_vma_policy(struct task_struct *task,
>  		struct vm_area_struct *vma, unsigned long addr)
>  {
> -	struct mempolicy *pol = task->mempolicy;
> +	struct mempolicy *pol = NULL;
> +	unsigned long irqflags;
>  
>  	if (vma) {
>  		if (vma->vm_ops && vma->vm_ops->get_policy) {
> @@ -1381,8 +1434,16 @@ static struct mempolicy *get_vma_policy(struct task_struct *task,
>  		} else if (vma->vm_policy)
>  			pol = vma->vm_policy;
>  	}
> +	if (!pol) {
> +		read_mem_lock_irqsave(task, irqflags);
> +		pol = task->mempolicy;
> +		mpol_get(pol);
> +		read_mem_unlock_irqrestore(task, irqflags);
> +	}
> +

Please note that this change is in the fast path of task page
allocations.  We tried real hard when reworking the mempolicy reference
counts not to reference count the task's mempolicy because only the task
could change its' own task mempolicy.  cpuset rebinding breaks this
assumption, of course.

I'll run some page fault overhead tests on this series to see whether
the effect of the additional lock round trip and reference count is
measurable and unacceptable.  If so, you might consider forcing the task
to update it's own task memory policy on return to user space using the
TIF_NOTIFY_RESUME handler.  That is, allocated and construct the new
mempolicy and queue it to the task to be updated by do_notify_resume().
set_notify_resume() will kick the process so that it enters and exits
the kernel, servicing the pending thread flag.

Yeah, there might be a window where allocations will use the old policy
before the kick_process() takes effect, but any such allocations could
have completed before the policy update anyway, so it shouldn't be an
issue as long as the allocation uses one policy or the other and not a
mixture of the two, right?

Regards,
Lee
>  	if (!pol)
>  		pol = &default_policy;
> +
>  	return pol;
>  }
>  
> @@ -1584,11 +1645,15 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
>  {
>  	struct mempolicy *mempolicy;
>  	int nid;
> +	unsigned long irqflags;
>  
>  	if (!(mask && current->mempolicy))
>  		return false;
>  
> +	read_mempolicy_lock_irqsave(current, irqflags);
>  	mempolicy = current->mempolicy;
> +	mpol_get(mempolicy);
> +
>  	switch (mempolicy->mode) {
>  	case MPOL_PREFERRED:
>  		if (mempolicy->flags & MPOL_F_LOCAL)
> @@ -1608,6 +1673,9 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
>  		BUG();
>  	}
>  
> +	read_mempolicy_unlock_irqrestore(current, irqflags);
> +	mpol_cond_put(mempolicy);
> +
>  	return true;
>  }
>  #endif
> @@ -1654,6 +1722,7 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
>  {
>  	struct mempolicy *pol = get_vma_policy(current, vma, addr);
>  	struct zonelist *zl;
> +	struct page *page;
>  
>  	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
>  		unsigned nid;
> @@ -1667,15 +1736,17 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
>  		/*
>  		 * slow path: ref counted shared policy
>  		 */
> -		struct page *page =  __alloc_pages_nodemask(gfp, 0,
> -						zl, policy_nodemask(gfp, pol));
> +		page =  __alloc_pages_nodemask(gfp, 0, zl,
> +					policy_nodemask(gfp, pol));
>  		__mpol_put(pol);
>  		return page;
>  	}
>  	/*
>  	 * fast path:  default or task policy
>  	 */
> -	return __alloc_pages_nodemask(gfp, 0, zl, policy_nodemask(gfp, pol));
> +	page = __alloc_pages_nodemask(gfp, 0, zl, policy_nodemask(gfp, pol));
> +	mpol_cond_put(pol);
> +	return page;
>  }
>  
>  /**
> @@ -1692,26 +1763,36 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
>   *	Allocate a page from the kernel page pool.  When not in
>   *	interrupt context and apply the current process NUMA policy.
>   *	Returns NULL when no page can be allocated.
> - *
> - *	Don't call cpuset_update_task_memory_state() unless
> - *	1) it's ok to take cpuset_sem (can WAIT), and
> - *	2) allocating for current task (not interrupt).
>   */
>  struct page *alloc_pages_current(gfp_t gfp, unsigned order)
>  {
> -	struct mempolicy *pol = current->mempolicy;
> +	struct mempolicy *pol;
> +	struct page *page;
> +	unsigned long irqflags;
> +
> +	read_mem_lock_irqsave(current, irqflags);
> +	pol = current->mempolicy;
> +	mpol_get(pol);
> +	read_mem_unlock_irqrestore(current, irqflags);
>  
> -	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
> +	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE)) {
> +		mpol_put(pol);
>  		pol = &default_policy;
> +	}
>  
>  	/*
>  	 * No reference counting needed for current->mempolicy
>  	 * nor system default_policy
>  	 */
>  	if (pol->mode == MPOL_INTERLEAVE)
> -		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
> -	return __alloc_pages_nodemask(gfp, order,
> -			policy_zonelist(gfp, pol), policy_nodemask(gfp, pol));
> +		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
> +	else
> +		page =  __alloc_pages_nodemask(gfp, order,
> +					policy_zonelist(gfp, pol),
> +					policy_nodemask(gfp, pol));
> +
> +	mpol_cond_put(pol);
> +	return page;
>  }
>  EXPORT_SYMBOL(alloc_pages_current);
>  
> @@ -1961,6 +2042,7 @@ restart:
>   */
>  void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
>  {
> +	unsigned long irqflags;
>  	int ret;
>  
>  	sp->root = RB_ROOT;		/* empty tree == default mempolicy */
> @@ -1981,9 +2063,9 @@ void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
>  			return;		/* no valid nodemask intersection */
>  		}
>  
> -		task_lock(current);
> +		write_mem_lock_irqsave(current, irqflags);
>  		ret = mpol_set_nodemask(new, &mpol->w.user_nodemask, scratch);
> -		task_unlock(current);
> +		write_mem_unlock_irqrestore(current, irqflags);
>  		mpol_put(mpol);	/* drop our ref on sb mpol */
>  		if (ret) {
>  			NODEMASK_SCRATCH_FREE(scratch);
> @@ -2134,6 +2216,7 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
>  	char *nodelist = strchr(str, ':');
>  	char *flags = strchr(str, '=');
>  	int i;
> +	unsigned long irqflags;
>  	int err = 1;
>  
>  	if (nodelist) {
> @@ -2215,9 +2298,9 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
>  		int ret;
>  		NODEMASK_SCRATCH(scratch);
>  		if (scratch) {
> -			task_lock(current);
> +			write_mem_lock_irqsave(current, irqflags);
>  			ret = mpol_set_nodemask(new, &nodes, scratch);
> -			task_unlock(current);
> +			write_mem_unlock_irqrestore(current, irqflags);
>  		} else
>  			ret = -ENOMEM;
>  		NODEMASK_SCRATCH_FREE(scratch);
> diff --git a/mm/slab.c b/mm/slab.c
> index 7451bda..2df5185 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3145,14 +3145,25 @@ static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
>  static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t flags)
>  {
>  	int nid_alloc, nid_here;
> +	struct mempolicy *pol;
> +	unsigned long lflags;
>  
>  	if (in_interrupt() || (flags & __GFP_THISNODE))
>  		return NULL;
> +
> +	read_mem_lock_irqsave(current, lflags);
> +	pol = current->mempolicy;
> +	mpol_get(pol);
> +	read_mem_unlock_irqrestore(current, lflags);
> +
>  	nid_alloc = nid_here = numa_node_id();
>  	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
>  		nid_alloc = cpuset_mem_spread_node();
> -	else if (current->mempolicy)
> -		nid_alloc = slab_node(current->mempolicy);
> +	else if (pol)
> +		nid_alloc = slab_node(pol);
> +
> +	mpol_put(pol);
> +
>  	if (nid_alloc != nid_here)
>  		return ____cache_alloc_node(cachep, flags, nid_alloc);
>  	return NULL;
> @@ -3175,11 +3186,21 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
>  	enum zone_type high_zoneidx = gfp_zone(flags);
>  	void *obj = NULL;
>  	int nid;
> +	struct mempolicy *pol;
> +	unsigned long lflags;
>  
>  	if (flags & __GFP_THISNODE)
>  		return NULL;
>  
> -	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
> +	read_mem_lock_irqsave(current, lflags);
> +	pol = current->mempolicy;
> +	mpol_get(pol);
> +	read_mem_unlock_irqrestore(current, lflags);
> +
> +	zonelist = node_zonelist(slab_node(pol), flags);
> +
> +	mpol_put(pol);
> +
>  	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
>  
>  retry:
> diff --git a/mm/slub.c b/mm/slub.c
> index 8d71aaf..cb533d4 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1357,6 +1357,8 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
>  	struct zone *zone;
>  	enum zone_type high_zoneidx = gfp_zone(flags);
>  	struct page *page;
> +	struct mempolicy *pol;
> +	unsigned long lflags
>  
>  	/*
>  	 * The defrag ratio allows a configuration of the tradeoffs between
> @@ -1380,7 +1382,15 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
>  			get_cycles() % 1024 > s->remote_node_defrag_ratio)
>  		return NULL;
>  
> +	read_mem_lock_irqsave(current, lflags);
> +	pol = current->mempolicy;
> +	mpol_get(pol);
> +	read_mem_unlock_irqrestore(current, lflags);
> +
>  	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
> +
> +	mpol_put(pol);
> +
>  	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>  		struct kmem_cache_node *n;
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
