From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v7)
Date: Thu, 03 Apr 2008 11:25:13 -0700
Message-ID: <1207247113.21922.63.camel@nimitz.home.sr71.net>
References: <20080403174433.26356.42121.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759041AbYDCSZ3@vger.kernel.org>
In-Reply-To: <20080403174433.26356.42121.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Thu, 2008-04-03 at 23:14 +0530, Balbir Singh wrote:
> diff -puN include/linux/init_task.h~memory-controller-add-mm-owner include/linux/init_task.h
> --- linux-2.6.25-rc8/include/linux/init_task.h~memory-controller-add-mm-owner	2008-04-03 22:43:27.000000000 +0530
> +++ linux-2.6.25-rc8-balbir/include/linux/init_task.h	2008-04-03 22:43:27.000000000 +0530
> @@ -199,7 +199,6 @@ extern struct group_info init_groups;
>  	INIT_LOCKDEP							\
>  }
> 
> -
>  #define INIT_CPU_TIMERS(cpu_timers)					\
>  {									\
>  	LIST_HEAD_INIT(cpu_timers[0]),					\

I assume you didn't mean to do that one.

> diff -puN include/linux/memcontrol.h~memory-controller-add-mm-owner include/linux/memcontrol.h
> --- linux-2.6.25-rc8/include/linux/memcontrol.h~memory-controller-add-mm-owner	2008-04-03 22:43:27.000000000 +0530
> +++ linux-2.6.25-rc8-balbir/include/linux/memcontrol.h	2008-04-03 22:43:27.000000000 +0530
> @@ -27,9 +27,6 @@ struct mm_struct;
> 
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> 
> -extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
> -extern void mm_free_cgroup(struct mm_struct *mm);
> -
>  #define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
> 
>  extern struct page_cgroup *page_get_page_cgroup(struct page *page);
> @@ -48,8 +45,10 @@ extern unsigned long mem_cgroup_isolate_
>  extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
>  int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
> 
> +extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> +
>  #define mm_match_cgroup(mm, cgroup)	\
> -	((cgroup) == rcu_dereference((mm)->mem_cgroup))
> +	((cgroup) == mem_cgroup_from_task((mm)->owner))

Now that you've mucked with this one, can you just turn this into a
static inline?

...
> +#ifdef CONFIG_MM_OWNER
> +/*
> + * Task p is exiting and it owned p, so lets find a new owner for it
> + */
> +static inline int
> +mm_need_new_owner(struct mm_struct *mm, struct task_struct *p)
> +{
> +	int ret;
> +
> +	/*
> +	 * If there are other users of the mm and the owner (us) is exiting
> +	 * we need to find a new owner to take on the responsibility.
> +	 * When we use thread groups (CLONE_THREAD), the thread group
> +	 * leader is kept around in zombie state, even after it exits.
> +	 * delay_group_leader() ensures that if the group leader is around
> +	 * we need not select a new owner.
> +	 */
> +	ret = (mm && (atomic_read(&mm->mm_users) > 1) && (mm->owner == p) &&
> +		!delay_group_leader(p));
> +	return ret;
> +}

Ugh.  Could you please spell this out a bit more.  I find that stuff
above really hard to read.  Something like:

	if (!mm)
		return 0;
	if (atomic_read(&mm->mm_users) <= 1)
		return 0;
	if (mm->owner != p)
		return 0;
	if (delay_group_leader(p))
		return 0;
	return 1;

It also gives you a nice spot to stick comments for each particular
check.

> +void mm_update_next_owner(struct mm_struct *mm)
> +{
> +	struct task_struct *c, *g, *p = current;

Any chance I can talk you into spelling these out a bit?  By the time I
get down in the function, it's easy to forget what they are.

> +retry:
> +	if (!mm_need_new_owner(mm, p))
> +		return;
> +
> +	rcu_read_lock();
> +	/*
> +	 * Search in the children
> +	 */
> +	list_for_each_entry(c, &p->children, sibling) {
> +		if (c->mm == mm)
> +			goto assign_new_owner;
> +	}
> +
> +	/*
> +	 * Search in the siblings
> +	 */
> +	list_for_each_entry(c, &p->parent->children, sibling) {
> +		if (c->mm == mm)
> +			goto assign_new_owner;
> +	}
> +
> +	/*
> +	 * Search through everything else. We should not get
> +	 * here often
> +	 */
> +	do_each_thread(g, c) {
> +		if (c->mm == mm)
> +			goto assign_new_owner;
> +	} while_each_thread(g, c);

What is the case in which we get here?  Threading that's two deep where
none of the immeidate siblings or children is still alive?

Have you happened to instrument this and see if it happens in practice
much?

> +	rcu_read_unlock();
> +	return;
> +
> +assign_new_owner:
> +	BUG_ON(c == p);
> +	get_task_struct(c);
> +	/*
> +	 * The task_lock protects c->mm from changing.
> +	 * We always want mm->owner->mm == mm
> +	 */
> +	task_lock(c);
> +	/*
> + 	 * Delay rcu_read_unlock() till we have the task_lock()
> + 	 * to ensure that c does not slip away underneath us
> + 	 */
> +	rcu_read_unlock();
> +	if (c->mm != mm) {
> +		task_unlock(c);
> +		put_task_struct(c);
> +		goto retry;
> +	}
> +	cgroup_mm_owner_callbacks(mm->owner, c);
> +	mm->owner = c;
> +	task_unlock(c);
> +	put_task_struct(c);
> +}
> +#endif /* CONFIG_MM_OWNER */



-- Dave
