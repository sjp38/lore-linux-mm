Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4F6Hp8k002565
	for <linux-mm@kvack.org>; Thu, 15 May 2008 11:47:51 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4F6He5x516104
	for <linux-mm@kvack.org>; Thu, 15 May 2008 11:47:41 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4F6HnnB023729
	for <linux-mm@kvack.org>; Thu, 15 May 2008 11:47:50 +0530
Date: Thu, 15 May 2008 11:47:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and
	control (v4)
Message-ID: <20080515061727.GC31115@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130951.24440.73671.sendpatchset@localhost.localdomain> <20080514132529.GA25653@balbir.in.ibm.com> <6599ad830805141925mf8a13daq7309148153a3c2df@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <6599ad830805141925mf8a13daq7309148153a3c2df@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Paul Menage <menage@google.com> [2008-05-14 19:25:07]:

> On Wed, May 14, 2008 at 6:25 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >  +
> >  +int memrlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
> >  +{
> >  +       int ret;
> >  +       struct memrlimit_cgroup *memrcg;
> >  +
> >  +       rcu_read_lock();
> >  +       memrcg = memrlimit_cgroup_from_task(rcu_dereference(mm->owner));
> >  +       css_get(&memrcg->css);
> >  +       rcu_read_unlock();
> >  +
> >  +       ret = res_counter_charge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
> >  +       css_put(&memrcg->css);
> >  +       return ret;
> >  +}
> 
> Assuming that we're holding a write lock on mm->mmap_sem here, and we
> additionally hold mmap_sem for the whole of mm_update_next_owner(),
> then maybe we don't need any extra synchronization here? Something
> like simply:
> 
> int memrlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
> {
>        struct memrlimit_cgroup *memrcg = memrlimit_cgroup_from_task(mm->owner);
>        return res_counter_charge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
> }

The charge_as routine is not always called with mmap_sem held, since
the undo path gets more complicated under the lock. We already have
our own locking mechanism for the counters. We're not really accessing
any member of the mm here except the owner. Do we need to be called
with mmap_sem held?

> 
> Seems good to minimize additional synchronization on the fast path.
>
> The only thing that's still broken is that the task_struct.cgroups
> pointer gets updated only under the synchronization of task_lock(), so
> we've still got the race of:
> 
> A: attach_task() updates B->cgroups
> 
> B: memrlimit_cgroup_charge_as() charges the new res counter and
> updates mm->total_vm
> 
> A: memrlimit_cgroup_move_task() moves mm->total_vm from the old
> counter to the new counter
> 
> Here's one way I see to fix this:
> 
> We change attach_task() so that rather than updating the
> task_struct.cgroups pointer once from the original css_set to the
> final css_set, it goes through a series of intermediate css_set
> structures, one for each subsystem in the hierarchy, transitioning
> from the old set to the final set. Then for each subsystem ss, it
> would do:
> 
> next_css = <old css with pointer for ss updated>
> if (ss->attach) {
>   ss->attach(ss, p, next_css);
> } else {
>   task_lock(p);
>   rcu_assign_ptr(p->cgroups, next_css);
>   task_unlock(p);
> }
> 
> i.e. the subsystem would be free to implement any synchronization it
> desired in the attach() code. The attach() method's responsibility
> would be to ensure that p->cgroups was updated to point to next_css
> before returning. This should make it much simpler for a subsystem to
> handle potential races between attach() and accounting. The current
> semantics of can_attach()/update/attach() are sufficient for cpusets,
> but probably not for systems with more complex accounting. I'd still
> need to figure out a nice way to get the kind of transactional
> semantics that you want from can_attach().
> 

A transaction manager would be great. We do the
mm_update_owner_changes under the task_lock(), may be the attach
callback should do the same to ensure that


> >  +
> >  +void memrlimit_cgroup_uncharge_as(struct mm_struct *mm, unsigned long nr_pages)
> >  +{
> >  +       struct memrlimit_cgroup *memrcg;
> >  +
> >  +       rcu_read_lock();
> >  +       memrcg = memrlimit_cgroup_from_task(rcu_dereference(mm->owner));
> >  +       css_get(&memrcg->css);
> >  +       rcu_read_unlock();
> >  +
> >  +       res_counter_uncharge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
> >  +       css_put(&memrcg->css);
> >  +}
> >  +
> >   static struct cgroup_subsys_state *
> >   memrlimit_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
> >   {
> >  @@ -134,11 +169,70 @@ static int memrlimit_cgroup_populate(str
> >                                 ARRAY_SIZE(memrlimit_cgroup_files));
> >   }
> >
> >  +static void memrlimit_cgroup_move_task(struct cgroup_subsys *ss,
> >  +                                       struct cgroup *cgrp,
> >  +                                       struct cgroup *old_cgrp,
> >  +                                       struct task_struct *p)
> >  +{
> >  +       struct mm_struct *mm;
> >  +       struct memrlimit_cgroup *memrcg, *old_memrcg;
> >  +
> >  +       mm = get_task_mm(p);
> >  +       if (mm == NULL)
> >  +               return;
> >  +
> >  +       rcu_read_lock();
> >  +       if (p != rcu_dereference(mm->owner))
> >  +               goto out;
> 
> out: does up_read() on mmap_sem, which you don't currently hold.
> 

Yes, good catch!

> Can you add more comments about why you're using RCU here?
>

Sure, I will. One of things we want to ensure is that mm->owner does
not go away.

> You have a refcounted pointer on mm, so mm can't go away, and you
> never dereference the result of the rcu_dereference(mm->owner), so
> you're not protecting the validity of that pointer. The only way this
> could help would be if anything that changes mm->owner calls
> synchronize_rcu() before, say, doing accounting changes, and I don't
> believe that's the case.
> 
> Would it be simpler to use task_lock(p) here to ensure that it doesn't
> lose its owner status (by exiting or execing) while we're moving it?
> 

That's what I've been thinking as well, based on the discussion above.

> i.e., something like: [ this assumes the new semantics of attach that
> I proposed above ]
> 
> 
> static void memrlimit_cgroup_move_task(struct cgroup_subsys *ss,
>                                        struct cgroup *cgrp,
>                                        struct cgroup *old_cgrp,
>                                        struct task_struct *p,
>                                        struct css_set new_css_set)
> {
>         struct mm_struct *mm;
>         struct memrlimit_cgroup *memrcg, *old_memrcg;
> 
>  retry:
>         mm = get_task_mm(p);
>         if (mm == NULL) {
>           task_lock(p);
>           rcu_assign_ptr(p->cgroups, new_css_set);

Will each callback assign p->cgroups to new_css_set?

>           task_unlock(p);
>           return;
>         }
> 
>         /* Take mmap_sem to prevent address space changes */
>         down_read(&mm->mmap_sem);
>         /* task_lock(p) to prevent mm ownership changes */
>         task_lock(p);
>         if (p->mm != mm) {
>                 /* We raced */

With exit_mmap() or exec_mmap() right?

>                 task_unlock(p);
>                 up_read(&mm->mmap_sem);
>                 mmput(mm);
>                 goto retry;
>         }
>         if (p != mm->owner)
>                 goto out_assign;
> 
>         memrcg = memrlimit_cgroup_from_cgrp(cgrp);
>         old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);
> 
>         if (memrcg == old_memrcg)
>                 goto out_assign;
> 
>         if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
>                 goto out_assign;
>         res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
>   out_assign:
>         rcu_assign_ptr(p->cgroups, new_css_set);
>         task_unlock(p);
>         up_read(&mm->mmap_sem);
>         mmput(mm);
> }
> 

Taking the mmap_sem here would mean, we would need to document
(something I should have done earlier), that mmap_sem nests under
cgroup_mutex


Looking at the mm->owner patches, I am thinking of writing down a race
scenario card


        Race conditions

        R1: mm->owner can change dynamically under task_lock
        R2: mm->owner's cgroup can change under cgroup_mutex

                        Read            Write

        mm->owner       Prevent         hold task_lock 
                        cgroup from
                        changing

                        Prevent owner
                        from changing

        Scenarios requiring protection/consistency

        R1: causes no problem, since we expect to make appropriate
            adjustment in mm_owner_changed
        R2: Is handled by the attach() callback

        Which leaves us with the following conclusion

        We don't have move_task(), mm_owner_changed() and charge/uncharge()
        running in parallel at the same time.

If we agree with the assertion/conclusion above, then a simple lock
might be able to protect us, assuming that it does not create a
interwined locking hierarchy.

> 
> 
> 
> >  +
> >  +       memrcg = memrlimit_cgroup_from_cgrp(cgrp);
> >  +       old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);
> >  +
> >  +       if (memrcg == old_memrcg)
> >  +               goto out;
> 
> mmap_sem is also not held here.
> 

Will fix

> >  +
> >  +       /*
> >  +        * Hold mmap_sem, so that total_vm does not change underneath us
> >  +        */
> >  +       down_read(&mm->mmap_sem);
> 
> You can't block inside rcu_read_lock().
>

Good catch!
 
> >  +       if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
> >  +               goto out;
> >  +       res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
> >  +out:
> >  +       up_read(&mm->mmap_sem);
> >  +       rcu_read_unlock();
> >  +       mmput(mm);
> >  +}
> >  +
> >  +static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
> >  +                                               struct cgroup *cgrp,
> >  +                                               struct cgroup *old_cgrp,
> >  +                                               struct task_struct *p)
> >  +{
> >  +       struct memrlimit_cgroup *memrcg, *old_memrcg;
> >  +       struct mm_struct *mm = get_task_mm(p);
> >  +
> >  +       BUG_ON(!mm);
> >  +       memrcg = memrlimit_cgroup_from_cgrp(cgrp);
> >  +       old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);
> >  +
> >  +       down_read(&mm->mmap_sem);
> 
> At this point we're holding p->alloc_lock, so we can't do a blocking
> down_read().
> 

Good catch!

> How about if we down_read(&mm->mmap_sem) in mm_update_next_owner()
> prior to taking tasklist_lock? That will ensure that mm ownership
> changes are synchronized against mmap/munmap operations on that mm,
> and since the cgroups-based owners are likely to be wanting to track
> the ownership changes for accounting purposes, this seems like an
> appropriate lock to hold.

Hmmm.. may be worth doing

> 
> >  +       if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
> >  +               goto out;
> >  +       res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
> >  +out:
> >  +       up_read(&mm->mmap_sem);
> >  +
> >  +       mmput(mm);
> >  +}
> >  +
> 

Thanks for the detailed review.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

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
