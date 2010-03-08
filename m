Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C011B6B0078
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 16:46:17 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o28LkF9o021312
	for <linux-mm@kvack.org>; Mon, 8 Mar 2010 13:46:15 -0800
Received: from pxi37 (pxi37.prod.google.com [10.243.27.37])
	by kpbe11.cbf.corp.google.com with ESMTP id o28LkEHe001410
	for <linux-mm@kvack.org>; Mon, 8 Mar 2010 15:46:14 -0600
Received: by pxi37 with SMTP id 37so2212299pxi.11
        for <linux-mm@kvack.org>; Mon, 08 Mar 2010 13:46:14 -0800 (PST)
Date: Mon, 8 Mar 2010 13:46:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V2 4/4] cpuset,mm: update task's mems_allowed lazily
In-Reply-To: <4B94CD2D.8070401@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003081330370.18502@chino.kir.corp.google.com>
References: <4B94CD2D.8070401@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Mar 2010, Miao Xie wrote:

> Changes from V1 to V2:
> - Update task->mems_allowed lazily, instead of using a lock to protect it
> 
> Before applying this patch, cpuset updates task->mems_allowed by setting all
> new bits in the nodemask first, and clearing all old unallowed bits later.
> But in the way, the allocator is likely to see an empty nodemask.
> 

Likely?  It's probably rarer than one in a million.

> The problem is following:
> The size of nodemask_t is greater than the size of long integer, so loading
> and storing of nodemask_t are not atomic operations. If task->mems_allowed
> don't intersect with new_mask, such as the first word of the mask is empty
> and only the first word of new_mask is not empty. When the allocator
> loads a word of the mask before
> 
> 	current->mems_allowed |= new_mask;
> 
> and then loads another word of the mask after
> 
> 	current->mems_allowed = new_mask;
> 
> the allocator gets an empty nodemask.
> 
> Considering the change of task->mems_allowed is not frequent, so in this patch,
> I use two variables as a tag to indicate whether task->mems_allowed need be
> update or not. And before setting the tag, cpuset caches the new mask of every
> task at its task_struct.
> 

So what exactly is the benefit of 58568d2 from last June that caused this 
issue to begin with?  It seems like this entire patchset is a revert of 
that commit.  So why shouldn't we just revert that one commit and then add 
the locking and updating necessary for configs where
MAX_NUMNODES > BITS_PER_LONG on top?

> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index a5740fc..2eb0fa7 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -93,6 +93,44 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
>  static inline void set_mems_allowed(nodemask_t nodemask)
>  {
>  	current->mems_allowed = nodemask;
> +	current->mems_allowed_for_update = nodemask;
> +}
> +
> +#define task_mems_lock_irqsave(p, flags)			\
> +	do {							\
> +		spin_lock_irqsave(&p->mems_lock, flags);	\
> +	} while (0)
> +
> +#define task_mems_unlock_irqrestore(p, flags)			\
> +	do {							\
> +		spin_unlock_irqrestore(&p->mems_lock, flags);	\
> +	} while (0)

We don't need mems_lock at all for 99% of the machines running Linux where 
the update can be done atomically, so these need to be redefined to be a 
no-op for those users.

> +
> +#include <linux/mempolicy.h>

#includes should be at the top of include/linux/cpuset.h.

> +/**
> + * cpuset_update_task_mems_allowed - update task memory placement
> + *
> + * If the current task's mems_allowed_for_update and mempolicy_for_update are
> + * changed by cpuset behind our backs, update current->mems_allowed,
> + * mems_generation and task NUMA mempolicy to the new value.
> + *
> + * Call WITHOUT mems_lock held.
> + * 
> + * This routine is needed to update the pre-task mems_allowed and mempolicy
> + * within the tasks context, when it is trying to allocate memory.
> + */
> +static __always_inline void cpuset_update_task_mems_allowed(void)
> +{
> +	struct task_struct *tsk = current;
> +	unsigned long flags;
> +
> +	if (unlikely(tsk->mems_generation != tsk->mems_generation_for_update)) {
> +		task_mems_lock_irqsave(tsk, flags);
> +		tsk->mems_allowed = tsk->mems_allowed_for_update;
> +		tsk->mems_generation = tsk->mems_generation_for_update;
> +		task_mems_unlock_irqrestore(tsk, flags);

By this synchronization, you're guaranteeing that no other kernel code 
ever reads tsk->mems_allowed when tsk != current?  Otherwise, you're 
simply protecting the store to tsk->mems_allowed here and not serializing 
on the loads that can return empty nodemasks.

> +		mpol_rebind_task(tsk, &tsk->mems_allowed);
> +	}
>  }
>  
>  #else /* !CONFIG_CPUSETS */
> @@ -193,6 +231,13 @@ static inline void set_mems_allowed(nodemask_t nodemask)
>  {
>  }
>  
> +static inline void cpuset_update_task_mems_allowed(void)
> +{
> +}
> +
> +#define task_mems_lock_irqsave(p, flags)	do { (void)(flags); } while (0)
> +
> +#define task_mems_unlock_irqrestore(p, flags)	do { (void)(flags); } while (0)
>  #endif /* !CONFIG_CPUSETS */
>  
>  #endif /* _LINUX_CPUSET_H */
> diff --git a/include/linux/init_task.h b/include/linux/init_task.h
> index abec69b..be016f0 100644
> --- a/include/linux/init_task.h
> +++ b/include/linux/init_task.h
> @@ -103,7 +103,7 @@ extern struct group_info init_groups;
>  extern struct cred init_cred;
>  
>  #ifdef CONFIG_PERF_EVENTS
> -# define INIT_PERF_EVENTS(tsk)					\
> +# define INIT_PERF_EVENTS(tsk)						\

Probably not intended.

>  	.perf_event_mutex = 						\
>  		 __MUTEX_INITIALIZER(tsk.perf_event_mutex),		\
>  	.perf_event_list = LIST_HEAD_INIT(tsk.perf_event_list),
> @@ -111,6 +111,22 @@ extern struct cred init_cred;
>  # define INIT_PERF_EVENTS(tsk)
>  #endif
>  
> +#ifdef CONFIG_CPUSETS
> +# define INIT_MEMS_ALLOWED(tsk)						\
> +	.mems_lock = __SPIN_LOCK_UNLOCKED(tsk.mems_lock),		\
> +	.mems_generation = 0,						\
> +	.mems_generation_for_update = 0,
> +#else
> +# define INIT_MEMS_ALLOWED(tsk)
> +#endif
> +
> +#ifdef CONFIG_NUMA
> +# define INIT_MEMPOLICY							\
> +	.mempolicy = NULL,

This has never been needed before.

> +#else
> +# define INIT_MEMPOLICY
> +#endif
> +
>  /*
>   *  INIT_TASK is used to set up the first task table, touch at
>   * your own risk!. Base=0, limit=0x1fffff (=2MB)
> @@ -180,6 +196,8 @@ extern struct cred init_cred;
>  	INIT_FTRACE_GRAPH						\
>  	INIT_TRACE_RECURSION						\
>  	INIT_TASK_RCU_PREEMPT(tsk)					\
> +	INIT_MEMS_ALLOWED(tsk)						\
> +	INIT_MEMPOLICY							\
>  }
>  
>  
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 46c6f8d..9e7f14f 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1351,8 +1351,9 @@ struct task_struct {
>  /* Thread group tracking */
>     	u32 parent_exec_id;
>     	u32 self_exec_id;
> -/* Protection of (de-)allocation: mm, files, fs, tty, keyrings, mems_allowed,
> - * mempolicy */
> +/*
> + * Protection of (de-)allocation: mm, files, fs, tty, keyrings
> + */
>  	spinlock_t alloc_lock;
>  
>  #ifdef CONFIG_GENERIC_HARDIRQS
> @@ -1420,8 +1421,36 @@ struct task_struct {
>  	cputime_t acct_timexpd;	/* stime + utime since last update */
>  #endif
>  #ifdef CONFIG_CPUSETS
> -	nodemask_t mems_allowed;	/* Protected by alloc_lock */
> +	/*
> +	 * It is unnecessary to protect mems_allowed, because it only can be
> +	 * loaded and stored by current task's self
> +	 */
> +	nodemask_t mems_allowed;
>  	int cpuset_mem_spread_rotor;
> +
> +	/* Protection of ->mems_allowed_for_update */
> +	spinlock_t mems_lock;
> +	/*
> +	 * This variable(mems_allowed_for_update) are just used for caching
> +	 * memory placement information.
> +	 *
> +	 * ->mems_allowed are used by the kernel allocator.
> +	 */
> +	nodemask_t mems_allowed_for_update;	/* Protected by mems_lock */

Another nodemask_t in struct task_struct for this?  And for all configs, 
including those that can do atomic updates to mems_allowed?

> +
> +	/*
> +	 * Increment this integer everytime ->mems_allowed_for_update is
> +	 * changed by cpuset. Task can compare this number with mems_generation,
> +	 * and if they are not the same, mems_allowed_for_update is changed and
> +	 * ->mems_allowed must be updated. In this way, tasks can avoid having
> +	 * to lock and reload mems_allowed_for_update unless it is changed.
> +	 */
> +	int mems_generation_for_update;
> +	/*
> +	 * After updating mems_allowed, set mems_generation to
> +	 * mems_generation_for_update.
> +	 */
> +	int mems_generation;

I don't see why you need two mems_generation numbers, one should belong in 
the task's cpuset.  Then you can compare tsk->mems_generation to 
task_cs(tsk)->mems_generation at cpuset_update_task_memory_state() if you 
set tsk->mems_generation = task_cs(tsk)->mems_generation on 
cpuset_attach() or update_nodemask().

>  #endif
>  #ifdef CONFIG_CGROUPS
>  	/* Control Group info protected by css_set_lock */
> @@ -1443,7 +1472,11 @@ struct task_struct {
>  	struct list_head perf_event_list;
>  #endif
>  #ifdef CONFIG_NUMA
> -	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
> +	/*
> +	 * It is unnecessary to protect mempolicy, because it only can be
> +	 * loaded/stored by current task's self.
> +	 */
> +	struct mempolicy *mempolicy;

That's going to change soon since my oom killer rewrite protects 
tsk->mempolicy under task_lock().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
