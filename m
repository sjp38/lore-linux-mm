Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m4F2P9vZ021728
	for <linux-mm@kvack.org>; Thu, 15 May 2008 03:25:10 +0100
Received: from an-out-0708.google.com (ancc5.prod.google.com [10.100.29.5])
	by zps75.corp.google.com with ESMTP id m4F2P8Qo012920
	for <linux-mm@kvack.org>; Wed, 14 May 2008 19:25:08 -0700
Received: by an-out-0708.google.com with SMTP id c5so54336anc.0
        for <linux-mm@kvack.org>; Wed, 14 May 2008 19:25:08 -0700 (PDT)
Message-ID: <6599ad830805141925mf8a13daq7309148153a3c2df@mail.gmail.com>
Date: Wed, 14 May 2008 19:25:07 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and control (v4)
In-Reply-To: <20080514132529.GA25653@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain>
	 <20080514130951.24440.73671.sendpatchset@localhost.localdomain>
	 <20080514132529.GA25653@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 14, 2008 at 6:25 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  +
>  +int memrlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
>  +{
>  +       int ret;
>  +       struct memrlimit_cgroup *memrcg;
>  +
>  +       rcu_read_lock();
>  +       memrcg = memrlimit_cgroup_from_task(rcu_dereference(mm->owner));
>  +       css_get(&memrcg->css);
>  +       rcu_read_unlock();
>  +
>  +       ret = res_counter_charge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
>  +       css_put(&memrcg->css);
>  +       return ret;
>  +}

Assuming that we're holding a write lock on mm->mmap_sem here, and we
additionally hold mmap_sem for the whole of mm_update_next_owner(),
then maybe we don't need any extra synchronization here? Something
like simply:

int memrlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
{
       struct memrlimit_cgroup *memrcg = memrlimit_cgroup_from_task(mm->owner);
       return res_counter_charge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
}

Seems good to minimize additional synchronization on the fast path.

The only thing that's still broken is that the task_struct.cgroups
pointer gets updated only under the synchronization of task_lock(), so
we've still got the race of:

A: attach_task() updates B->cgroups

B: memrlimit_cgroup_charge_as() charges the new res counter and
updates mm->total_vm

A: memrlimit_cgroup_move_task() moves mm->total_vm from the old
counter to the new counter

Here's one way I see to fix this:

We change attach_task() so that rather than updating the
task_struct.cgroups pointer once from the original css_set to the
final css_set, it goes through a series of intermediate css_set
structures, one for each subsystem in the hierarchy, transitioning
from the old set to the final set. Then for each subsystem ss, it
would do:

next_css = <old css with pointer for ss updated>
if (ss->attach) {
  ss->attach(ss, p, next_css);
} else {
  task_lock(p);
  rcu_assign_ptr(p->cgroups, next_css);
  task_unlock(p);
}

i.e. the subsystem would be free to implement any synchronization it
desired in the attach() code. The attach() method's responsibility
would be to ensure that p->cgroups was updated to point to next_css
before returning. This should make it much simpler for a subsystem to
handle potential races between attach() and accounting. The current
semantics of can_attach()/update/attach() are sufficient for cpusets,
but probably not for systems with more complex accounting. I'd still
need to figure out a nice way to get the kind of transactional
semantics that you want from can_attach().

>  +
>  +void memrlimit_cgroup_uncharge_as(struct mm_struct *mm, unsigned long nr_pages)
>  +{
>  +       struct memrlimit_cgroup *memrcg;
>  +
>  +       rcu_read_lock();
>  +       memrcg = memrlimit_cgroup_from_task(rcu_dereference(mm->owner));
>  +       css_get(&memrcg->css);
>  +       rcu_read_unlock();
>  +
>  +       res_counter_uncharge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
>  +       css_put(&memrcg->css);
>  +}
>  +
>   static struct cgroup_subsys_state *
>   memrlimit_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
>   {
>  @@ -134,11 +169,70 @@ static int memrlimit_cgroup_populate(str
>                                 ARRAY_SIZE(memrlimit_cgroup_files));
>   }
>
>  +static void memrlimit_cgroup_move_task(struct cgroup_subsys *ss,
>  +                                       struct cgroup *cgrp,
>  +                                       struct cgroup *old_cgrp,
>  +                                       struct task_struct *p)
>  +{
>  +       struct mm_struct *mm;
>  +       struct memrlimit_cgroup *memrcg, *old_memrcg;
>  +
>  +       mm = get_task_mm(p);
>  +       if (mm == NULL)
>  +               return;
>  +
>  +       rcu_read_lock();
>  +       if (p != rcu_dereference(mm->owner))
>  +               goto out;

out: does up_read() on mmap_sem, which you don't currently hold.

Can you add more comments about why you're using RCU here?

You have a refcounted pointer on mm, so mm can't go away, and you
never dereference the result of the rcu_dereference(mm->owner), so
you're not protecting the validity of that pointer. The only way this
could help would be if anything that changes mm->owner calls
synchronize_rcu() before, say, doing accounting changes, and I don't
believe that's the case.

Would it be simpler to use task_lock(p) here to ensure that it doesn't
lose its owner status (by exiting or execing) while we're moving it?

i.e., something like: [ this assumes the new semantics of attach that
I proposed above ]


static void memrlimit_cgroup_move_task(struct cgroup_subsys *ss,
                                       struct cgroup *cgrp,
                                       struct cgroup *old_cgrp,
                                       struct task_struct *p,
                                       struct css_set new_css_set)
{
        struct mm_struct *mm;
        struct memrlimit_cgroup *memrcg, *old_memrcg;

 retry:
        mm = get_task_mm(p);
        if (mm == NULL) {
          task_lock(p);
          rcu_assign_ptr(p->cgroups, new_css_set);
          task_unlock(p);
          return;
        }

        /* Take mmap_sem to prevent address space changes */
        down_read(&mm->mmap_sem);
        /* task_lock(p) to prevent mm ownership changes */
        task_lock(p);
        if (p->mm != mm) {
                /* We raced */
                task_unlock(p);
                up_read(&mm->mmap_sem);
                mmput(mm);
                goto retry;
        }
        if (p != mm->owner)
                goto out_assign;

        memrcg = memrlimit_cgroup_from_cgrp(cgrp);
        old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);

        if (memrcg == old_memrcg)
                goto out_assign;

        if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
                goto out_assign;
        res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
  out_assign:
        rcu_assign_ptr(p->cgroups, new_css_set);
        task_unlock(p);
        up_read(&mm->mmap_sem);
        mmput(mm);
}




>  +
>  +       memrcg = memrlimit_cgroup_from_cgrp(cgrp);
>  +       old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);
>  +
>  +       if (memrcg == old_memrcg)
>  +               goto out;

mmap_sem is also not held here.

>  +
>  +       /*
>  +        * Hold mmap_sem, so that total_vm does not change underneath us
>  +        */
>  +       down_read(&mm->mmap_sem);

You can't block inside rcu_read_lock().

>  +       if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
>  +               goto out;
>  +       res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
>  +out:
>  +       up_read(&mm->mmap_sem);
>  +       rcu_read_unlock();
>  +       mmput(mm);
>  +}
>  +
>  +static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  +                                               struct cgroup *cgrp,
>  +                                               struct cgroup *old_cgrp,
>  +                                               struct task_struct *p)
>  +{
>  +       struct memrlimit_cgroup *memrcg, *old_memrcg;
>  +       struct mm_struct *mm = get_task_mm(p);
>  +
>  +       BUG_ON(!mm);
>  +       memrcg = memrlimit_cgroup_from_cgrp(cgrp);
>  +       old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);
>  +
>  +       down_read(&mm->mmap_sem);

At this point we're holding p->alloc_lock, so we can't do a blocking
down_read().

How about if we down_read(&mm->mmap_sem) in mm_update_next_owner()
prior to taking tasklist_lock? That will ensure that mm ownership
changes are synchronized against mmap/munmap operations on that mm,
and since the cgroups-based owners are likely to be wanting to track
the ownership changes for accounting purposes, this seems like an
appropriate lock to hold.

>  +       if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
>  +               goto out;
>  +       res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
>  +out:
>  +       up_read(&mm->mmap_sem);
>  +
>  +       mmput(mm);
>  +}
>  +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
