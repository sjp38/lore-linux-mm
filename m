Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8J3STEA001437
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 13:28:29 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8J3Sjxh266904
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 13:29:18 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8J3Sit5024645
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 13:28:45 +1000
Message-ID: <48D31C59.7050404@linux.vnet.ibm.com>
Date: Thu, 18 Sep 2008 20:28:25 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm] memrlimit: fix task_lock() recursive locking (v2)
References: <48D2CD1D.9040202@gmail.com>
In-Reply-To: <48D2CD1D.9040202@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righi.andrea@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrea Righi wrote:

> Since we hold task_lock(), we know that p->mm cannot change and we don't have
> to worry about incrementing mm_users. So, just use p->mm directly and
> check that we've not picked a kernel thread.
> 
> Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
> ---
>  kernel/cgroup.c      |    3 ++-
>  mm/memrlimitcgroup.c |   10 ++++------
>  2 files changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 678a680..03cc925 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2757,7 +2757,8 @@ void cgroup_fork_callbacks(struct task_struct *child)
>   * invoke this routine, since it assigns the mm->owner the first time
>   * and does not change it.
>   *
> - * The callbacks are invoked with mmap_sem held in read mode.
> + * The callbacks are invoked with task_lock held and mmap_sem held in read
> + * mode.
>   */
>  void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
>  {
> diff --git a/mm/memrlimitcgroup.c b/mm/memrlimitcgroup.c
> index 8ee74f6..b3d20f5 100644
> --- a/mm/memrlimitcgroup.c
> +++ b/mm/memrlimitcgroup.c
> @@ -238,7 +238,7 @@ out:
>  }
> 
>  /*
> - * This callback is called with mmap_sem held
> + * This callback is called with mmap_sem and task_lock held
>   */
>  static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  						struct cgroup *old_cgrp,
> @@ -246,9 +246,9 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  						struct task_struct *p)
>  {
>  	struct memrlimit_cgroup *memrcg, *old_memrcg;
> -	struct mm_struct *mm = get_task_mm(p);
> +	struct mm_struct *mm = p->mm;
> 
> -	BUG_ON(!mm);
> +	BUG_ON(!mm || (p->flags & PF_KTHREAD));
> 
>  	/*
>  	 * If we don't have a new cgroup, we just uncharge from the old one.
> @@ -258,7 +258,7 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  		memrcg = memrlimit_cgroup_from_cgrp(cgrp);
>  		if (res_counter_charge(&memrcg->as_res,
>  				mm->total_vm << PAGE_SHIFT))
> -			goto out;
> +			return;
>  	}
> 
>  	if (old_cgrp) {
> @@ -266,8 +266,6 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  		res_counter_uncharge(&old_memrcg->as_res,
>  				mm->total_vm << PAGE_SHIFT);
>  	}
> -out:
> -	mmput(mm);
>  }

Seems reasonable

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
