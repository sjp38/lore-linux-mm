Date: Wed, 20 Aug 2008 15:59:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/1] mm_owner: fix cgroup null dereference
Message-Id: <20080820155909.cf3f73bc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48ABA9A8.1060806@cn.fujitsu.com>
References: <1218745013-9537-1-git-send-email-jirislaby@gmail.com>
	<20080819141344.GF25239@balbir.in.ibm.com>
	<48ABA9A8.1060806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Jiri Slaby <jirislaby@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Aug 2008 13:20:40 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> Balbir Singh wote:
> > * Jiri Slaby <jirislaby@gmail.com> [2008-08-14 22:16:53]:
> > 
> >> Hi,
> >>
> >> found this in mmotm, a fix for
> >> mm-owner-fix-race-between-swap-and-exit.patch
> >>
> > 
> > Does the patch below fix your problem, it's against mmotm 19th August
> > 2008.
> > 
> 
> I just triggered this bug. I think you also need the following change:
> 
> make memrlimit_cgroup_mm_owner_changed() aware that old_cgrp can be NULL,
> and note we can't call memrlimit_cgroup_from_cgrp() with NULL argument.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> 

Thank you, it seems you fixed a problem which I met in my test.

(*) When I migrate task under cpuset repeatedly, I can see Oops easily.

Tested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>





> diff --git a/mm/memrlimitcgroup.c.orig b/mm/memrlimitcgroup.c
> index f7536dc..6559470 100644
> --- a/mm/memrlimitcgroup.c.orig
> +++ b/mm/memrlimitcgroup.c
> @@ -249,17 +249,23 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  	struct mm_struct *mm = get_task_mm(p);
>  
>  	BUG_ON(!mm);
> -	memrcg = memrlimit_cgroup_from_cgrp(cgrp);
> -	old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);
>  
>  	/*
>  	 * If we don't have a new cgroup, we just uncharge from the old one.
>  	 * It means that the task is going away
>  	 */
> -	if (memrcg &&
> -	    res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
> -		goto out;
> -	res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
> +	if (cgrp) {
> +		memrcg = memrlimit_cgroup_from_cgrp(cgrp);
> +		if (res_counter_charge(&memrcg->as_res,
> +				       mm->total_vm << PAGE_SHIFT))
> +			goto out;
> +	}
> +
> +	if (old_cgrp) {
> +		old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);
> +		res_counter_uncharge(&old_memrcg->as_res,
> +				     mm->total_vm <<PAGE_SHIFT);
> +	}
>  out:
>  	mmput(mm);
>  }
> 
> 
> >  
> > Reported-by: jirislaby@gmail.com
> > 
> > Jiri reported a problem and saw an oops when the memrlimit-fix-race-with-swap
> > patch is applied. He sent his patch on top to fix the problem, but ran into
> > another issue. The root cause of the problem is that we are not suppose
> > to call task_cgroup on NULL tasks. This patch reverts Jiri's patch and
> > does not call task_cgroup if the passed task_struct (old) is NULL.
> > 
> > 
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > ---
> > 
> >  kernel/cgroup.c |    5 +++--
> >  kernel/exit.c   |    2 +-
> >  2 files changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff -puN kernel/exit.c~memrlimit-fix-race-with-swap-oops kernel/exit.c
> > --- linux-2.6.27-rc3/kernel/exit.c~memrlimit-fix-race-with-swap-oops	2008-08-19 18:50:39.000000000 +0530
> > +++ linux-2.6.27-rc3-balbir/kernel/exit.c	2008-08-19 18:51:05.000000000 +0530
> > @@ -641,8 +641,8 @@ retry:
> >  	 * the callback and take action
> >  	 */
> >  	down_write(&mm->mmap_sem);
> > -	cgroup_mm_owner_callbacks(mm->owner, NULL);
> >  	mm->owner = NULL;
> > +	cgroup_mm_owner_callbacks(mm->owner, NULL);
> >  	up_write(&mm->mmap_sem);
> >  	return;
> >  
> > diff -puN kernel/cgroup.c~memrlimit-fix-race-with-swap-oops kernel/cgroup.c
> > --- linux-2.6.27-rc3/kernel/cgroup.c~memrlimit-fix-race-with-swap-oops	2008-08-19 18:50:39.000000000 +0530
> > +++ linux-2.6.27-rc3-balbir/kernel/cgroup.c	2008-08-19 18:55:38.000000000 +0530
> > @@ -2743,13 +2743,14 @@ void cgroup_fork_callbacks(struct task_s
> >   */
> >  void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
> >  {
> > -	struct cgroup *oldcgrp, *newcgrp = NULL;
> > +	struct cgroup *oldcgrp = NULL, *newcgrp = NULL;
> >  
> >  	if (need_mm_owner_callback) {
> >  		int i;
> >  		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> >  			struct cgroup_subsys *ss = subsys[i];
> > -			oldcgrp = task_cgroup(old, ss->subsys_id);
> > +			if (old)
> > +				oldcgrp = task_cgroup(old, ss->subsys_id);
> >  			if (new)
> >  				newcgrp = task_cgroup(new, ss->subsys_id);
> >  			if (oldcgrp == newcgrp)
> > diff -puN mm/memrlimitcgroup.c~memrlimit-fix-race-with-swap-oops mm/memrlimitcgroup.c
> > _
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
