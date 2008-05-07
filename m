Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m473HFFo026493
	for <linux-mm@kvack.org>; Wed, 7 May 2008 04:17:15 +0100
Received: from an-out-0708.google.com (andd11.prod.google.com [10.100.30.11])
	by zps36.corp.google.com with ESMTP id m473HD8u015005
	for <linux-mm@kvack.org>; Tue, 6 May 2008 20:17:14 -0700
Received: by an-out-0708.google.com with SMTP id d11so27625and.64
        for <linux-mm@kvack.org>; Tue, 06 May 2008 20:17:13 -0700 (PDT)
Message-ID: <6599ad830805062017n67d67f19w1469050d45e46ad6@mail.gmail.com>
Date: Tue, 6 May 2008 20:17:13 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm][PATCH 3/4] Add rlimit controller accounting and control
In-Reply-To: <20080503213814.3140.66080.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
	 <20080503213814.3140.66080.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sat, May 3, 2008 at 2:38 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  +
>  +int rlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
>  +{
>  +       int ret;
>  +       struct rlimit_cgroup *rcg;
>  +
>  +       rcu_read_lock();
>  +       rcg = rlimit_cgroup_from_task(rcu_dereference(mm->owner));
>  +       css_get(&rcg->css);
>  +       rcu_read_unlock();
>  +
>  +       ret = res_counter_charge(&rcg->as_res, (nr_pages << PAGE_SHIFT));
>  +       css_put(&rcg->css);
>  +       return ret;
>  +}

You need to synchronize against mm->owner changing, or
mm->owner->cgroups changing. How about:

int rlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
{
  int ret;
  struct rlimit_cgroup *rcg;
  struct task_struct *owner;

  rcu_read_lock();
 again:

  /* Find and lock the owner of the mm */
  owner = rcu_dereference(mm->owner);
  task_lock(owner);
  if (mm->owner != owner) {
    task_unlock(owner);
    goto again;
  }

  /* Charge the owner's cgroup with the new memory */
  rcg = rlimit_cgroup_from_task(owner);
  ret = res_counter_charge(&rcg->as_res, (nr_pages << PAGE_SHIFT));
  task_unlock(owner);
  rcu_read_unlock();
  return ret;
}

>  +
>  +void rlimit_cgroup_uncharge_as(struct mm_struct *mm, unsigned long nr_pages)
>  +{
>  +       struct rlimit_cgroup *rcg;
>  +
>  +       rcu_read_lock();
>  +       rcg = rlimit_cgroup_from_task(rcu_dereference(mm->owner));
>  +       css_get(&rcg->css);
>  +       rcu_read_unlock();
>  +
>  +       res_counter_uncharge(&rcg->as_res, (nr_pages << PAGE_SHIFT));
>  +       css_put(&rcg->css);
>  +}

Can't this be implemented as just a call to charge() with a negative
value? (Possibly fixing res_counter_charge() to handle negative values
if necessary) Seems simpler.

>
>  +/*
>  + * TODO: get the attach callbacks to fail and disallow task movement.
>  + */

You mean disallow all movement within a hierarchy that has this cgroup
mounted? Doesn't that make it rather hard to use?

>  +static void rlimit_cgroup_move_task(struct cgroup_subsys *ss,
>  +                                       struct cgroup *cgrp,
>  +                                       struct cgroup *old_cgrp,
>  +                                       struct task_struct *p)
>  +{
>  +       struct mm_struct *mm;
>  +       struct rlimit_cgroup *rcg, *old_rcg;
>  +
>  +       mm = get_task_mm(p);
>  +       if (mm == NULL)
>  +               return;
>  +
>  +       rcu_read_lock();
>  +       if (p != rcu_dereference(mm->owner))
>  +               goto out;
>  +
>  +       rcg = rlimit_cgroup_from_cgrp(cgrp);
>  +       old_rcg = rlimit_cgroup_from_cgrp(old_cgrp);
>  +
>  +       if (rcg == old_rcg)
>  +               goto out;
>  +
>  +       if (res_counter_charge(&rcg->as_res, (mm->total_vm << PAGE_SHIFT)))
>  +               goto out;
>  +       res_counter_uncharge(&old_rcg->as_res, (mm->total_vm << PAGE_SHIFT));
>  +out:
>  +       rcu_read_unlock();
>  +       mmput(mm);
>  +}
>  +

Since you need to protect against concurrent charges, and against
concurrent mm ownership changes, I think you should just do this under
task_lock(p).

>  +static void rlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  +                                               struct cgroup *cgrp,
>  +                                               struct cgroup *old_cgrp,
>  +                                               struct task_struct *p)
>  +{
>  +       struct rlimit_cgroup *rcg, *old_rcg;
>  +       struct mm_struct *mm = get_task_mm(p);
>  +
>  +       BUG_ON(!mm);
>  +       rcg = rlimit_cgroup_from_cgrp(cgrp);
>  +       old_rcg = rlimit_cgroup_from_cgrp(old_cgrp);
>  +       if (res_counter_charge(&rcg->as_res, (mm->total_vm << PAGE_SHIFT)))
>  +               goto out;
>  +       res_counter_uncharge(&old_rcg->as_res, (mm->total_vm << PAGE_SHIFT));
>  +out:
>  +       mmput(mm);
>  +}
>  +

Also needs to task_lock(p) to prevent concurrent charges or cgroup
reassignments?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
