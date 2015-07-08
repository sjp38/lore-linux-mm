Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C3D8B6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 13:33:05 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so135173592pac.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 10:33:05 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rq5si5137402pab.83.2015.07.08.10.33.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 10:33:04 -0700 (PDT)
Date: Wed, 8 Jul 2015 20:32:51 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 7/8] memcg: get rid of mm_struct::owner
Message-ID: <20150708173251.GG2436@esperanza>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-8-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1436358472-29137-8-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

I like the gist of this patch. A few comments below.

On Wed, Jul 08, 2015 at 02:27:51PM +0200, Michal Hocko wrote:
[...]
> diff --git a/fs/exec.c b/fs/exec.c
> index 1977c2a553ac..3ed9c0abc9f5 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -870,7 +870,7 @@ static int exec_mmap(struct mm_struct *mm)
>  		up_read(&old_mm->mmap_sem);
>  		BUG_ON(active_mm != old_mm);
>  		setmax_mm_hiwater_rss(&tsk->signal->maxrss, old_mm);
> -		mm_update_next_owner(old_mm);
> +		mm_inherit_memcg(mm, old_mm);
>  		mmput(old_mm);
>  		return 0;
>  	}
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 78e9d4ac57a1..8e6b2444ebfe 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -274,6 +274,52 @@ struct mem_cgroup {
>  extern struct cgroup_subsys_state *mem_cgroup_root_css;
>  
>  /**
> + * __mm_set_memcg - Set mm_struct:memcg to a given memcg.
> + * @mm: mm struct
> + * @memcg: mem_cgroup to be used
> + *
> + * Note that this function doesn't clean up the previous mm->memcg.
> + * This should be done by caller when necessary (e.g. when moving
> + * mm from one memcg to another).
> + */
> +static inline
> +void __mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
> +{
> +	if (memcg)
> +		css_get(&memcg->css);
> +	rcu_assign_pointer(mm->memcg, memcg);
> +}
> +
> +/**
> + * mm_inherit_memcg - Initialize mm_struct::memcg from an existing mm_struct
> + * @newmm: new mm struct
> + * @oldmm: old mm struct to inherit from
> + *
> + * Should be called for each new mm_struct.
> + */
> +static inline
> +void mm_inherit_memcg(struct mm_struct *newmm, struct mm_struct *oldmm)
> +{
> +	struct mem_cgroup *memcg = oldmm->memcg;

FWIW, if CONFIG_SPARSE_RCU_POINTER is on, this will trigger a compile
time warning, as well as any unannotated dereference of mm_struct->memcg
below.

> +
> +	__mm_set_memcg(newmm, memcg);
> +}
> +
> +/**
> + * mm_drop_iter - drop mm_struct::memcg association

s/mm_drop_iter/mm_drop_memcg

> + * @mm: mm struct
> + *
> + * Should be called after the mm has been removed from all tasks
> + * and before it is freed (e.g. from mmput)
> + */
> +static inline void mm_drop_memcg(struct mm_struct *mm)
> +{
> +	if (mm->memcg)
> +		css_put(&mm->memcg->css);
> +	mm->memcg = NULL;
> +}
> +
> +/**
>   * mem_cgroup_events - count memory events against a cgroup
>   * @memcg: the memory cgroup
>   * @idx: the event index
> @@ -305,7 +351,6 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
>  bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
>  
>  struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
> -struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
>  
>  struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
>  static inline
> @@ -335,7 +380,7 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
>  	bool match = false;
>  
>  	rcu_read_lock();
> -	task_memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +	task_memcg = rcu_dereference(mm->memcg);
>  	if (task_memcg)
>  		match = mem_cgroup_is_descendant(task_memcg, memcg);
>  	rcu_read_unlock();
> @@ -474,7 +519,7 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
>  		return;
>  
>  	rcu_read_lock();
> -	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +	memcg = rcu_dereference(mm->memcg);
>  	if (unlikely(!memcg))
>  		goto out;
>  

If I'm not mistaken, mm->memcg equals NULL for any task in the root
memory cgroup (BTW, it it's true, it's worth mentioning in the comment
to mm->memcg definition IMO). As a result, we won't account the stats
for such tasks, will we?

[...]
> @@ -4749,37 +4748,49 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
>  	 * tunable will only affect upcoming migrations, not the current one.
>  	 * So we need to save it, and keep it going.
>  	 */
> -	move_flags = READ_ONCE(memcg->move_charge_at_immigrate);
> +	move_flags = READ_ONCE(to->move_charge_at_immigrate);
>  	if (!move_flags)
>  		return 0;
>  
>  	p = cgroup_taskset_first(tset);
> -	from = mem_cgroup_from_task(p);
> -
> -	VM_BUG_ON(from == memcg);
> +	if (!thread_group_leader(p))
> +		return 0;
>  
>  	mm = get_task_mm(p);
>  	if (!mm)
>  		return 0;
> -	/* We move charges only when we move a owner of the mm */
> -	if (mm->owner == p) {
> -		VM_BUG_ON(mc.from);
> -		VM_BUG_ON(mc.to);
> -		VM_BUG_ON(mc.precharge);
> -		VM_BUG_ON(mc.moved_charge);
> -		VM_BUG_ON(mc.moved_swap);
> -
> -		spin_lock(&mc.lock);
> -		mc.from = from;
> -		mc.to = memcg;
> -		mc.flags = move_flags;
> -		spin_unlock(&mc.lock);
> -		/* We set mc.moving_task later */
> -
> -		ret = mem_cgroup_precharge_mc(mm);
> -		if (ret)
> -			mem_cgroup_clear_mc();
> -	}
> +
> +	/*
> +	 * tasks' cgroup might be different from the one p->mm is associated
> +	 * with because CLONE_VM is allowed without CLONE_THREAD. The task is
> +	 * moving so we have to migrate from the memcg associated with its
> +	 * address space.

> +	 * No need to take a reference here because the memcg is pinned by the
> +	 * mm_struct.
> +	 */

But after we drop the reference to the mm below, mc.from can pass away
and we can get use-after-free in mem_cgroup_move_task, can't we?

AFAIU the real reason why we can skip taking a reference to mc.from, as
well as to mc.to, is that task migration proceeds under cgroup_mutex,
which blocks cgroup destruction. Am I missing something? If not, please
remove this comment, because it's confusing.

> +	from = READ_ONCE(mm->memcg);
> +	if (!from)
> +		from = root_mem_cgroup;
> +	if (from == to)
> +		goto out;
> +
> +	VM_BUG_ON(mc.from);
> +	VM_BUG_ON(mc.to);
> +	VM_BUG_ON(mc.precharge);
> +	VM_BUG_ON(mc.moved_charge);
> +	VM_BUG_ON(mc.moved_swap);
> +
> +	spin_lock(&mc.lock);
> +	mc.from = from;
> +	mc.to = to;
> +	mc.flags = move_flags;
> +	spin_unlock(&mc.lock);
> +	/* We set mc.moving_task later */
> +
> +	ret = mem_cgroup_precharge_mc(mm);
> +	if (ret)
> +		mem_cgroup_clear_mc();
> +out:
>  	mmput(mm);
>  	return ret;
>  }
> @@ -4932,14 +4943,26 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
>  {
>  	struct task_struct *p = cgroup_taskset_first(tset);
>  	struct mm_struct *mm = get_task_mm(p);
> +	struct mem_cgroup *old_memcg = NULL;
>  
>  	if (mm) {
> +		old_memcg = READ_ONCE(mm->memcg);
> +		__mm_set_memcg(mm, mem_cgroup_from_css(css));
> +
>  		if (mc.to)
>  			mem_cgroup_move_charge(mm);
>  		mmput(mm);
>  	}
>  	if (mc.to)
>  		mem_cgroup_clear_mc();
> +
> +	/*
> +	 * Be careful and drop the reference only after we are done because
> +	 * p's task_css memcg might be different from p->memcg and nothing else
> +	 * might be pinning the old memcg.
> +	 */
> +	if (old_memcg)
> +		css_put(&old_memcg->css);

Please explain why the following race is impossible:

CPU0					CPU1
----					----
[current = T]
dup_mm or exec_mmap
 mm_inherit_memcg
  memcg = current->mm->memcg;
					mem_cgroup_move_task
					 p = T;
					 mm = get_task_mm(p);
					 old_memcg = mm->memcg;
					 css_put(&old_memcg->css);
					 /* old_memcg can be freed now */
  css_get(memcg); /* BUG */

>  }
>  #else	/* !CONFIG_MMU */
>  static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
