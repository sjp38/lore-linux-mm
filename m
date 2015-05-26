Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACBB6B0121
	for <linux-mm@kvack.org>; Tue, 26 May 2015 10:10:28 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so98461427wgb.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 07:10:27 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w13si23924102wjq.111.2015.05.26.07.10.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 07:10:26 -0700 (PDT)
Date: Tue, 26 May 2015 10:10:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150526141011.GA11065@cmpxchg.org>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432641006-8025-4-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, May 26, 2015 at 01:50:06PM +0200, Michal Hocko wrote:
> Please note that this patch introduces a USER VISIBLE CHANGE OF BEHAVIOR.
> Without mm->owner _all_ tasks associated with the mm_struct would
> initiate memcg migration while previously only owner of the mm_struct
> could do that. The original behavior was awkward though because the user
> task didn't have any means to find out the current owner (esp. after
> mm_update_next_owner) so the migration behavior was not well defined
> in general.
> New cgroup API (unified hierarchy) will discontinue tasks file which
> means that migrating threads will no longer be possible. In such a case
> having CLONE_VM without CLONE_THREAD could emulate the thread behavior
> but this patch prevents from isolating memcg controllers from others.
> Nevertheless I am not convinced such a use case would really deserve
> complications on the memcg code side.

I think such a change is okay.  The memcg semantics of moving threads
with the same mm into separate groups have always been arbitrary.  No
reasonable behavior can be expected of this, so what sane real life
usecase would rely on it?

> @@ -104,7 +105,12 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
>  	bool match = false;
>  
>  	rcu_read_lock();
> -	task_memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +	/*
> +	 * rcu_dereference would be better but mem_cgroup is not a complete
> +	 * type here
> +	 */
> +	task_memcg = READ_ONCE(mm->memcg);
> +	smp_read_barrier_depends();
>  	if (task_memcg)
>  		match = mem_cgroup_is_descendant(task_memcg, memcg);
>  	rcu_read_unlock();

This function has only one user in rmap.  If you inline it there, you
can use rcu_dereference() and get rid of the specialness & comment.

> @@ -195,6 +201,10 @@ void mem_cgroup_split_huge_fixup(struct page *head);
>  #else /* CONFIG_MEMCG */
>  struct mem_cgroup;
>  
> +void mm_drop_memcg(struct mm_struct *mm)
> +{}
> +void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
> +{}

static inline?

> @@ -292,94 +292,6 @@ kill_orphaned_pgrp(struct task_struct *tsk, struct task_struct *parent)
>  	}
>  }
>  
> -#ifdef CONFIG_MEMCG
> -/*
> - * A task is exiting.   If it owned this mm, find a new owner for the mm.
> - */
> -void mm_update_next_owner(struct mm_struct *mm)
> -{
> -	struct task_struct *c, *g, *p = current;
> -
> -retry:
> -	/*
> -	 * If the exiting or execing task is not the owner, it's
> -	 * someone else's problem.
> -	 */
> -	if (mm->owner != p)
> -		return;
> -	/*
> -	 * The current owner is exiting/execing and there are no other
> -	 * candidates.  Do not leave the mm pointing to a possibly
> -	 * freed task structure.
> -	 */
> -	if (atomic_read(&mm->mm_users) <= 1) {
> -		mm->owner = NULL;
> -		return;
> -	}
> -
> -	read_lock(&tasklist_lock);
> -	/*
> -	 * Search in the children
> -	 */
> -	list_for_each_entry(c, &p->children, sibling) {
> -		if (c->mm == mm)
> -			goto assign_new_owner;
> -	}
> -
> -	/*
> -	 * Search in the siblings
> -	 */
> -	list_for_each_entry(c, &p->real_parent->children, sibling) {
> -		if (c->mm == mm)
> -			goto assign_new_owner;
> -	}
> -
> -	/*
> -	 * Search through everything else, we should not get here often.
> -	 */
> -	for_each_process(g) {
> -		if (g->flags & PF_KTHREAD)
> -			continue;
> -		for_each_thread(g, c) {
> -			if (c->mm == mm)
> -				goto assign_new_owner;
> -			if (c->mm)
> -				break;
> -		}
> -	}
> -	read_unlock(&tasklist_lock);
> -	/*
> -	 * We found no owner yet mm_users > 1: this implies that we are
> -	 * most likely racing with swapoff (try_to_unuse()) or /proc or
> -	 * ptrace or page migration (get_task_mm()).  Mark owner as NULL.
> -	 */
> -	mm->owner = NULL;
> -	return;
> -
> -assign_new_owner:
> -	BUG_ON(c == p);
> -	get_task_struct(c);
> -	/*
> -	 * The task_lock protects c->mm from changing.
> -	 * We always want mm->owner->mm == mm
> -	 */
> -	task_lock(c);
> -	/*
> -	 * Delay read_unlock() till we have the task_lock()
> -	 * to ensure that c does not slip away underneath us
> -	 */
> -	read_unlock(&tasklist_lock);
> -	if (c->mm != mm) {
> -		task_unlock(c);
> -		put_task_struct(c);
> -		goto retry;
> -	}
> -	mm->owner = c;
> -	task_unlock(c);
> -	put_task_struct(c);
> -}
> -#endif /* CONFIG_MEMCG */

w00t!

> @@ -469,6 +469,46 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
>  	return mem_cgroup_from_css(css);
>  }
>  
> +static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
> +{
> +	if (!p->mm)
> +		return NULL;
> +	return rcu_dereference(p->mm->memcg);
> +}
> +
> +void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
> +{
> +	if (memcg)
> +		css_get(&memcg->css);
> +	rcu_assign_pointer(mm->memcg, memcg);
> +}
> +
> +void mm_drop_memcg(struct mm_struct *mm)
> +{
> +	/*
> +	 * This is the last reference to mm so nobody can see
> +	 * this memcg
> +	 */
> +	if (mm->memcg)
> +		css_put(&mm->memcg->css);
> +}

This is really simple and obvious and has only one caller, it would be
better to inline this into mmput().  The comment would also be easier
to understand in conjunction with the mmdrop() in the callsite:

	if (mm->memcg)
		css_put(&mm->memcg->css);
	/* We could reset mm->memcg, but this will free the mm: */
	mmdrop(mm);

The same goes for mm_set_memcg, there is no real need for obscuring a
simple get-and-store.

> +static void mm_move_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *old_memcg;
> +
> +	mm_set_memcg(mm, memcg);
> +
> +	/*
> +	 * wait for all current users of the old memcg before we
> +	 * release the reference.
> +	 */
> +	old_memcg = mm->memcg;
> +	synchronize_rcu();
> +	if (old_memcg)
> +		css_put(&old_memcg->css);
> +}

I'm not sure why we need that synchronize_rcu() in here, the css is
itself protected by RCU and a failing tryget will prevent you from
taking it outside a RCU-locked region.

Aside from that, there is again exactly one place that performs this
operation.  Please inline it into mem_cgroup_move_task().

> @@ -5204,6 +5251,12 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
>  	struct mm_struct *mm = get_task_mm(p);
>  
>  	if (mm) {
> +		/*
> +		 * Commit to a new memcg. mc.to points to the destination
> +		 * memcg even when the current charges are not moved.
> +		 */
> +		mm_move_memcg(mm, mc.to);
> +
>  		if (mc_move_charge())
>  			mem_cgroup_move_charge(mm);
>  		mmput(mm);

It's a little weird to use mc.to when not moving charges, as "mc"
stands for "move charge".  Why not derive the destination from @css,
just like can_attach does?  It's a mere cast.  That also makes patch
#2 in your series unnecessary.

Otherwise, the patch looks great to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
