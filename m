Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2SCeKSa009885
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 23:40:20 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2SCecO24579452
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 23:40:39 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2SCebxI013322
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 23:40:38 +1100
Message-ID: <47ECE662.3060506@linux.vnet.ibm.com>
Date: Fri, 28 Mar 2008 18:06:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain> <6599ad830803280401r68d30e91waaea8eb1de36eb52@mail.gmail.com>
In-Reply-To: <6599ad830803280401r68d30e91waaea8eb1de36eb52@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Fri, Mar 28, 2008 at 1:23 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  diff -puN include/linux/mm_types.h~memory-controller-add-mm-owner include/linux/mm_types.h
>>  --- linux-2.6.25-rc5/include/linux/mm_types.h~memory-controller-add-mm-owner    2008-03-28 09:30:47.000000000 +0530
>>  +++ linux-2.6.25-rc5-balbir/include/linux/mm_types.h    2008-03-28 12:26:59.000000000 +0530
>>  @@ -227,8 +227,10 @@ struct mm_struct {
>>         /* aio bits */
>>         rwlock_t                ioctx_list_lock;
>>         struct kioctx           *ioctx_list;
>>  -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>>  -       struct mem_cgroup *mem_cgroup;
>>  +#ifdef CONFIG_MM_OWNER
>>  +       spinlock_t owner_lock;
>>  +       struct task_struct *owner;      /* The thread group leader that */
>>  +                                       /* owns the mm_struct.          */
>>   #endif
> 
> I'm not convinced that we need the spinlock. Just use the simple rule
> that you can only modify mm->owner if:
> 
> - mm->owner points to current
> - the new owner is a user of mm

This will always hold, otherwise it cannot be the new owner :)

> - you hold task_lock() for the new owner (which is necessary anyway to
> ensure that the new owner's mm doesn't change while you're updating
> mm->owner)
> 

tsk->mm should not change unless the task is exiting or when a kernel thread
does use_mm() (PF_BORROWED_MM).

I see mm->owner changing when

1. The mm->owner exits
2. At fork time for clone calls with CLONE_VM

May be your rules will work, but I am yet to try that out.

>>   #ifdef CONFIG_PROC_FS
>>  diff -puN kernel/fork.c~memory-controller-add-mm-owner kernel/fork.c
>>  --- linux-2.6.25-rc5/kernel/fork.c~memory-controller-add-mm-owner       2008-03-28 09:30:47.000000000 +0530
>>  +++ linux-2.6.25-rc5-balbir/kernel/fork.c       2008-03-28 12:33:12.000000000 +0530
>>  @@ -359,6 +359,7 @@ static struct mm_struct * mm_init(struct
>>         mm->free_area_cache = TASK_UNMAPPED_BASE;
>>         mm->cached_hole_size = ~0UL;
>>         mm_init_cgroup(mm, p);
>>  +       mm_init_owner(mm, p);
>>
>>         if (likely(!mm_alloc_pgd(mm))) {
>>                 mm->def_flags = 0;
>>  @@ -995,6 +996,27 @@ static void rt_mutex_init_task(struct ta
>>   #endif
>>   }
>>
>>  +#ifdef CONFIG_MM_OWNER
>>  +void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
>>  +{
>>  +       spin_lock_init(&mm->owner_lock);
>>  +       mm->owner = p;
>>  +}
>>  +
>>  +void mm_fork_init_owner(struct task_struct *p)
>>  +{
>>  +       struct mm_struct *mm = get_task_mm(p);
> 
> Do we need this? p->mm can't go away if we're in the middle of forking it.
> 

There are other cases why I preferred to use it, specifically for PF_BORROWED_MM
cases. What if a kernel thread does use_mm() and fork()? Very unlikely, I'll
remove it and use p->mm directly.

>>  +       if (!mm)
>>  +               return;
>>  +
>>  +       spin_lock(&mm->owner);
> 
> I suspect that you meant this to be spin_lock(&mm->owner_lock).
> 

Yes, thats a typo. A bad one :)

>>  +       if (mm->owner != p)
>>  +               rcu_assign_pointer(mm->owner, p->group_leader);
>>  +       spin_unlock(&mm->owner);
>>  +       mmput(mm);
>>  +}
>>  +#endif /* CONFIG_MM_OWNER */
>>  +
>>   /*
>>   * This creates a new process as a copy of the old one,
>>   * but does not actually start it yet.
>>  @@ -1357,6 +1379,10 @@ static struct task_struct *copy_process(
>>         write_unlock_irq(&tasklist_lock);
>>         proc_fork_connector(p);
>>         cgroup_post_fork(p);
>>  +
>>  +       if (!(clone_flags & CLONE_VM) && (p != p->group_leader))
>>  +               mm_fork_init_owner(p);
>>  +
> 
> I'm not sure I understand what this is doing.
> 
> I read it as "if p has its own mm and p is a child thread, set
> p->mm->owner to p->group_leader". But by definition if p has its own
> mm, then p->group_leader->mm will be different to p->mm, therefore
> we'd end up with mm->owner->mm != mm, which seems very bad.
> 
> What's the intention of this bit of code?
> 

The intention is to handle the case when clone is called without CLONE_VM and
with CLONE_THREAD. This means that p can have it's own mm and a shared group_leader.


>>         return p;
>>
>>   bad_fork_free_pid:
>>  diff -puN include/linux/memcontrol.h~memory-controller-add-mm-owner include/linux/memcontrol.h
>>  --- linux-2.6.25-rc5/include/linux/memcontrol.h~memory-controller-add-mm-owner  2008-03-28 09:30:47.000000000 +0530
>>  +++ linux-2.6.25-rc5-balbir/include/linux/memcontrol.h  2008-03-28 09:30:47.000000000 +0530
>>  @@ -29,6 +29,7 @@ struct mm_struct;
>>
>>   extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
>>   extern void mm_free_cgroup(struct mm_struct *mm);
>>  +extern void mem_cgroup_fork_init(struct task_struct *p);
>>
>>   #define page_reset_bad_cgroup(page)    ((page)->page_cgroup = 0)
>>
>>  @@ -49,7 +50,7 @@ extern void mem_cgroup_out_of_memory(str
>>   int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
>>
>>   #define mm_match_cgroup(mm, cgroup)    \
>>  -       ((cgroup) == rcu_dereference((mm)->mem_cgroup))
>>  +       ((cgroup) == mem_cgroup_from_task((mm)->owner))
>>
>>   extern int mem_cgroup_prepare_migration(struct page *page);
>>   extern void mem_cgroup_end_migration(struct page *page);
>>  @@ -72,6 +73,8 @@ extern long mem_cgroup_calc_reclaim_acti
>>   extern long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
>>                                 struct zone *zone, int priority);
>>
>>  +extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
>>  +
>>   #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>>   static inline void mm_init_cgroup(struct mm_struct *mm,
>>                                         struct task_struct *p)
>>  @@ -82,6 +85,10 @@ static inline void mm_free_cgroup(struct
>>   {
>>   }
>>
>>  +static inline void mem_cgroup_fork_init(struct task_struct *p)
>>  +{
>>  +}
>>  +
> 
> Is this stale?
> 

Yes, there is some stale code in mm/memcontrol.c and include/linux/memcontrol.h
(my bad)

>>   static inline void page_reset_bad_cgroup(struct page *page)
>>   {
>>   }
>>  @@ -172,6 +179,11 @@ static inline long mem_cgroup_calc_recla
>>   {
>>         return 0;
>>   }
>>  +
>>  +static void mm_free_fork_cgroup(struct task_struct *p)
>>  +{
>>  +}
>>  +
> 
> And this?
> 

Yes

>>   #endif /* CONFIG_CGROUP_MEM_CONT */
>>  -static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>>  +struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>>   {
>>         return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
>>                                 struct mem_cgroup, css);
> 
> I think it would be better to make this static inline in the header
> file - it's just two indexed dereferences, so hardly worth the
> function call overhead.
> 

Yes, will do

>>  @@ -250,12 +250,17 @@ void mm_init_cgroup(struct mm_struct *mm
>>
>>         mem = mem_cgroup_from_task(p);
>>         css_get(&mem->css);
>>  -       mm->mem_cgroup = mem;
>>   }
>>
>>   void mm_free_cgroup(struct mm_struct *mm)
>>   {
>>  -       css_put(&mm->mem_cgroup->css);
>>  +       struct mem_cgroup *mem;
>>  +
>>  +       /*
>>  +        * TODO: Should we assign mm->owner to NULL here?
> 
> No, controller code shouldn't be changing mm->owner.
> 
> And surely we don't need mm_init_cgroup() and mm_free_cgroup() any longer?
> 

We don't need it and the comment is stale :)

>>  -       rcu_read_lock();
>>  -       mem = rcu_dereference(mm->mem_cgroup);
>>  +       mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
>>         /*
>>          * For every charge from the cgroup, increment reference count
>>          */
>>         css_get(&mem->css);
>>  -       rcu_read_unlock();
> 
> Why is it OK to take away the rcu_read_lock() here? We're still doing
> an rcu_dereference().
> 

Nope, my bad -- stale code. Will fix

>>         while (res_counter_charge(&mem->res, PAGE_SIZE)) {
>>                 if (!(gfp_mask & __GFP_WAIT))
>>  @@ -990,8 +994,8 @@ mem_cgroup_create(struct cgroup_subsys *
>>
>>         if (unlikely((cont->parent) == NULL)) {
>>                 mem = &init_mem_cgroup;
>>  -               init_mm.mem_cgroup = mem;
>>                 page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
>>  +               init_mm.owner = &init_task;
> 
> This shouldn't be in here - it should be in the core code that sets up init_mm.
> 

Yes, good point. Will do

>>  +#ifdef CONFIG_MM_OWNER
>>  +extern void mm_update_next_owner(struct mm_struct *mm, struct task_struct *p);
>>  +extern void mm_fork_init_owner(struct task_struct *p);
>>  +extern void mm_init_owner(struct mm_struct *mm, struct task_struct *p);
>>  +#else
>>  +static inline void
>>  +mm_update_next_owner(struct mm_struct *mm, struct task_struct *p)
>>  +{
>>  +}
>>  +
>>  +static inline void mm_fork_init_owner(struct task_struct *p)
>>  +{
>>  +}
>>  +
>>  +static inline void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
>>  +{
>>  +}
>>  +#endif /* CONFIG_MM_OWNER */
>>  +
>>   #endif /* __KERNEL__ */
>>
>>   #endif
>>  diff -puN kernel/exit.c~memory-controller-add-mm-owner kernel/exit.c
>>  --- linux-2.6.25-rc5/kernel/exit.c~memory-controller-add-mm-owner       2008-03-28 09:30:47.000000000 +0530
>>  +++ linux-2.6.25-rc5-balbir/kernel/exit.c       2008-03-28 12:35:39.000000000 +0530
>>  @@ -579,6 +579,71 @@ void exit_fs(struct task_struct *tsk)
>>
>>   EXPORT_SYMBOL_GPL(exit_fs);
>>
>>  +#ifdef CONFIG_MM_OWNER
>>  +/*
>>  + * Task p is exiting and it owned p, so lets find a new owner for it
>>  + */
>>  +static inline int
>>  +mm_need_new_owner(struct mm_struct *mm, struct task_struct *p)
>>  +{
>>  +       int ret;
>>  +
>>  +       rcu_read_lock();
>>  +       ret = (mm && (rcu_dereference(mm->owner) == p) &&
>>  +               (atomic_read(&mm->mm_users) > 1));
>>  +       rcu_read_unlock();
>>  +       return ret;
> 
> The only way that rcu_read_lock() helps here is if mm freeing is
> protected by RCU, which I don't think is the case.
> 

rcu_read_lock() also ensures that preemption does not cause us to see incorrect
values.

> But as long as p==current, there's no race, since no other process
> will re-point mm->owner at themselves, so mm can't go away anyway
> since we have a reference to it that we're going to be dropping soon.
>

mm cannot go away, but mm->owner can be different from current and could be
going away.

> Is there ever a case where we'd want to call this on anything other
> than current? It would simplify the code to just refer to current
> rather than tsk.
> 

Not at the moment, yes, we can remove the second parameter

>>  +}
>>  +
>>  +void mm_update_next_owner(struct mm_struct *mm, struct task_struct *p)
>>  +{
>>  +       struct task_struct *c, *g;
>>  +
>>  +       /*
>>  +        * This should not be called for init_task
>>  +        */
>>  +       BUG_ON(p == p->parent);
> 
> I'd be inclined to make this BUG_ON(p != current), or just have p as a
> local variable initialized from current. (If you're trying to save
> multiple calls to current on arches where it's not just a simple
> register).
> 

OK

>>  +
>>  +       if (!mm_need_new_owner(mm, p))
>>  +               return;
>>  +
>>  +       /*
>>  +        * Search in the children
>>  +        */
>>  +       list_for_each_entry(c, &p->children, sibling) {
>>  +               if (c->mm == p->mm)
>>  +                       goto assign_new_owner;
>>  +       }
> 
> We need to keep checking mm_need_new_owner() since it can become false
> if the only other user of the mm exits at the same time that we do.
> (In which case there's nothing to do).
> 

I would rather deal with the case where mm->owner is NULL, rather than keep
checking (since even with constant checking we cannot guarantee that mm->owner
will not become NULL)

>>  +        * Search through everything else. We should not get
>>  +        * here often
>>  +        */
>>  +       for_each_process(c) {
>>  +               g = c;
>>  +               do {
>>  +                       if (c->mm && (c->mm == p->mm))
>>  +                                       goto assign_new_owner;
>>  +               } while ((c = next_thread(c)) != g);
>>  +       }
> 
> Is there a reason to not code this as for_each_thread?
> 

Is there a for_each_thread()?

>>  +
>>  +       BUG();
>>  +
>>  +assign_new_owner:
>>  +       spin_lock(&mm->owner_lock);
>>  +       rcu_assign_pointer(mm->owner, c);
>>  +       spin_unlock(&mm->owner_lock);
>>  +}
> 
> This can break if c is also exiting and has passed the call to
> mm_update_next_owner() by the time we assign mm->owner. That's why my
> original suggested version had a function like:
> 

Won't it better to check for c->flags & PF_EXITING?

> static inline void try_give_mm_ownership(struct task_struct *task,
> struct mm_struct *mm) {
>   if (task->mm != mm) return;
>   task_lock(task);
>   if (task->mm == mm) {
>     mm->owner = task;
>   }
>   task_unlock(task);
> }
> 
> i.e. determining that a task is a valid candidate and updating the
> owner pointer has to be done in the same critical section.
> 

Let me try and revamp the locking rules and see what that leads to. But, I don't
like protecting an mm_struct's member with a task_struct's lock.


> Also, looking forward to when we have the virtual AS limits
> controller, in the (unlikely?) event that the new owner is in a
> different virtual AS limit control group, this code will need to be
> able to handle shifting the mm->total_mm from the old AS cgroup to the
> new one. That's the "fiddly layer violation" that I mentioned earlier.
> 
> It might be cleaner to be able to specify on a per-subsystem basis
> whether we require that all users of an mm be in the same cgroup.
> 

I don't expect to see that kind of restriction.

>>   config CGROUP_MEM_RES_CTLR
>>         bool "Memory Resource Controller for Control Groups"
>>  -       depends on CGROUPS && RESOURCE_COUNTERS
>>  +       depends on CGROUPS && RESOURCE_COUNTERS && MM_OWNER
> 
> Maybe this should select MM_OWNER rather than depending on it?
> 

I thought of it, but wondered if the user should make an informed choice about
MM_OWNER and the overhead it brings along.

> Paul
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
