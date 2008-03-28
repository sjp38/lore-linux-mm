Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2SEtX1R016246
	for <linux-mm@kvack.org>; Sat, 29 Mar 2008 01:55:33 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2SExoHE154304
	for <linux-mm@kvack.org>; Sat, 29 Mar 2008 01:59:50 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2SEu1vM019107
	for <linux-mm@kvack.org>; Sat, 29 Mar 2008 01:56:02 +1100
Message-ID: <47ED0621.4050304@linux.vnet.ibm.com>
Date: Fri, 28 Mar 2008 20:22:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain> <6599ad830803280401r68d30e91waaea8eb1de36eb52@mail.gmail.com> <47ECE662.3060506@linux.vnet.ibm.com> <6599ad830803280705o4213c448r991cbf9da6ffe2f1@mail.gmail.com>
In-Reply-To: <6599ad830803280705o4213c448r991cbf9da6ffe2f1@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Fri, Mar 28, 2008 at 5:36 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  > - you hold task_lock() for the new owner (which is necessary anyway to
>>  > ensure that the new owner's mm doesn't change while you're updating
>>  > mm->owner)
>>  >
>>
>>  tsk->mm should not change unless the task is exiting or when a kernel thread
>>  does use_mm() (PF_BORROWED_MM).
>>
> 
> Or the task calls execve().
> 
>>  I see mm->owner changing when
>>
>>  1. The mm->owner exits
>>  2. At fork time for clone calls with CLONE_VM
> 

This was supposed to be deleted, ignore it

> Why would a clone() call with CLONE_VM change mm->owner? We're sharing
> with the existing owner, who is still using the mm, so we should leave
> it as it is.
> 
> I don't see what invariant you're trying to protect with
> mm->owner_lock. Can you explain it?
> 

mm->owner_lock is there to protect mm->owner field from changing simultaneously
as tasks fork/exit.

>>  >>  @@ -1357,6 +1379,10 @@ static struct task_struct *copy_process(
>>  >>         write_unlock_irq(&tasklist_lock);
>>  >>         proc_fork_connector(p);
>>  >>         cgroup_post_fork(p);
>>  >>  +
>>  >>  +       if (!(clone_flags & CLONE_VM) && (p != p->group_leader))
>>  >>  +               mm_fork_init_owner(p);
>>  >>  +
>>  >
>>  > I'm not sure I understand what this is doing.
>>  >
>>  > I read it as "if p has its own mm and p is a child thread, set
>>  > p->mm->owner to p->group_leader". But by definition if p has its own
>>  > mm, then p->group_leader->mm will be different to p->mm, therefore
>>  > we'd end up with mm->owner->mm != mm, which seems very bad.
>>  >
>>  > What's the intention of this bit of code?
>>  >
>>
>>  The intention is to handle the case when clone is called without CLONE_VM and
>>  with CLONE_THREAD. This means that p can have it's own mm and a shared group_leader.
>>
> 
> In which case p should be the owner of its new mm, not
> p->group_leader. mm_fork_init_owner() does:
> 

Oh! yes.. my bad again. The check should have been p == p->thread_group, but
that is not required either. The check should now ideally be

if (!(clone_flags & CLONE_VM))

>>  +       if (mm->owner != p)
>>  +               rcu_assign_pointer(mm->owner, p->group_leader);
> 
> Since we just created a fresh mm for p in copy_mm(), and set mm->owner
> = p, I don't see how this test can succeed. And if it does, then we
> end up setting p->mm->owner to p->group_leader, which has to be bad
> since we know that:
> 
> - p is the only user of its mm
> - p != p->group_leader
> 
> therefore we're setting p->mm->owner to point to a process that
> doesn't use p->mm. What am I missing?
> 
>>  >>  +/*
>>  >>  + * Task p is exiting and it owned p, so lets find a new owner for it
>>  >>  + */
>>  >>  +static inline int
>>  >>  +mm_need_new_owner(struct mm_struct *mm, struct task_struct *p)
>>  >>  +{
>>  >>  +       int ret;
>>  >>  +
>>  >>  +       rcu_read_lock();
>>  >>  +       ret = (mm && (rcu_dereference(mm->owner) == p) &&
>>  >>  +               (atomic_read(&mm->mm_users) > 1));
>>  >>  +       rcu_read_unlock();
>>  >>  +       return ret;
>>  >
>>  > The only way that rcu_read_lock() helps here is if mm freeing is
>>  > protected by RCU, which I don't think is the case.
>>  >
>>
>>  rcu_read_lock() also ensures that preemption does not cause us to see incorrect
>>  values.
>>
> 
> The only thing that RCU is protecting us against here is that if
> mm->owner is non-NULL, the task it points to won't be freed until the
> end of our RCU read section. But since we never dereference mm->owner
> in the RCU read section, that buys us nothing and is just confusing.
> 
>>  > But as long as p==current, there's no race, since no other process
>>  > will re-point mm->owner at themselves, so mm can't go away anyway
>>  > since we have a reference to it that we're going to be dropping soon.
>>  >
>>
>>  mm cannot go away, but mm->owner can be different from current and could be
>>  going away.
> 
> But that's a problem for mm->owner, not for current.
> 
> By this point we've already cleared current->mm, so we're no longer a
> candidate for becoming mm->owner if we're not already the owner.
> Therefore the truth or falsity of (mm->owner == current) can't be
> changed by races - either we are already the owner and no-one but us
> can change mm->owner, or we're not the owner and no one can point
> mm->owner at us.
> 
>>  >>  +
>>  >>  +       if (!mm_need_new_owner(mm, p))
>>  >>  +               return;
>>  >>  +
>>  >>  +       /*
>>  >>  +        * Search in the children
>>  >>  +        */
>>  >>  +       list_for_each_entry(c, &p->children, sibling) {
>>  >>  +               if (c->mm == p->mm)
> 
> Oh, and at the point in exit_mm() when you call
> mm_update_next_owner(), p->mm is NULL, so this will only match against
> tasks that have no mm.
> 

Yes.. I think we need to call it earlier.

>>  >>  +                       goto assign_new_owner;
>>  >>  +       }
>>  >
>>  > We need to keep checking mm_need_new_owner() since it can become false
>>  > if the only other user of the mm exits at the same time that we do.
>>  > (In which case there's nothing to do).
>>  >
>>
>>  I would rather deal with the case where mm->owner is NULL, rather than keep
>>  checking
> 
> I mean that it's possible that there's one other task using mm at the
> point when we enter mm_update_next_owner(), but while we're trying to
> find it, it does an exit() or execve() and stops being a user of mm.
> if that happens, we should bail from the search since we no longer
> need to find another user to pass it to (and there is no other user to
> find).
> 
>> (since even with constant checking we cannot guarantee that mm->owner
>>  will not become NULL)
>>
>>
>>  >>  +        * Search through everything else. We should not get
>>  >>  +        * here often
>>  >>  +        */
>>  >>  +       for_each_process(c) {
>>  >>  +               g = c;
>>  >>  +               do {
>>  >>  +                       if (c->mm && (c->mm == p->mm))
>>  >>  +                                       goto assign_new_owner;
>>  >>  +               } while ((c = next_thread(c)) != g);
>>  >>  +       }
>>  >
>>  > Is there a reason to not code this as for_each_thread?
>>  >
>>
>>  Is there a for_each_thread()?
>>
> 
> Sorry, I meant do_each_thread()/while_each_thread(). Isn't that
> basically the same thing as what you've explicitly coded here?
> 

Yes, it is.

>>  >>  +assign_new_owner:
>>  >>  +       spin_lock(&mm->owner_lock);
>>  >>  +       rcu_assign_pointer(mm->owner, c);
>>  >>  +       spin_unlock(&mm->owner_lock);
>>  >>  +}
>>  >
>>  > This can break if c is also exiting and has passed the call to
>>  > mm_update_next_owner() by the time we assign mm->owner. That's why my
>>  > original suggested version had a function like:
>>  >
>>
>>  Won't it better to check for c->flags & PF_EXITING?
>>
> 
> Or if c is execing and gives up the mm that way.
> 



>>  > static inline void try_give_mm_ownership(struct task_struct *task,
>>  > struct mm_struct *mm) {
>>  >   if (task->mm != mm) return;
>>  >   task_lock(task);
>>  >   if (task->mm == mm) {
>>  >     mm->owner = task;
>>  >   }
>>  >   task_unlock(task);
>>  > }
>>  >
>>  > i.e. determining that a task is a valid candidate and updating the
>>  > owner pointer has to be done in the same critical section.
>>  >
>>
>>  Let me try and revamp the locking rules and see what that leads to. But, I don't
>>  like protecting an mm_struct's member with a task_struct's lock.
> 
> We're not protecting mm->owner with task_lock(new_owner). As I said,
> the locking rule for mm->owner should that it can only be changed if
> (current==mm->owner). What we're protecting is new_owner->mm - i.e.
> we're ensuring that we don't break the invariant that (mm->owner->mm
> == mm)
> 

But there is no way to guarantee that, what is the new_owner exec's after we've
done the check and assigned. Won't we end up breaking the invariant? How about
we have mm_update_new_owner() call in exec_mmap() as well? That way, we can
still use owner_lock and keep the invariant.


>>  >>   config CGROUP_MEM_RES_CTLR
>>  >>         bool "Memory Resource Controller for Control Groups"
>>  >>  -       depends on CGROUPS && RESOURCE_COUNTERS
>>  >>  +       depends on CGROUPS && RESOURCE_COUNTERS && MM_OWNER
>>  >
>>  > Maybe this should select MM_OWNER rather than depending on it?
>>  >
>>
>>  I thought of it, but wondered if the user should make an informed choice about
>>  MM_OWNER and the overhead it brings along.
> 
> I would vote the other way on that - make it clear in the memory
> controller config help that the memory controller can introduce
> overhead, and have it implicitly enable MM_OWNER.
> 

That's a possibility

Thanks for your patience and review.

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
