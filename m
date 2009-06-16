Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B7E076B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 23:12:55 -0400 (EDT)
Date: Tue, 16 Jun 2009 11:47:35 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX] memcg: rmdir doesn't return
Message-Id: <20090616114735.c7a91b8b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090615171715.53743dce.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090612143346.68e1f006.nishimura@mxp.nes.nec.co.jp>
	<20090612151924.2d305ce8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090615115021.c79444cb.nishimura@mxp.nes.nec.co.jp>
	<20090615120213.e9a3bd1d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090615171715.53743dce.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jun 2009 17:17:15 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 15 Jun 2009 12:02:13 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > I don't like implict resource move. I'll try some today. plz see it.
> > _But_ this case just happens when swap is shared between cgroups and _very_ heavy
> > swap-in continues very long. I don't think this is a fatal and BUG.
> > 
> > But ok, maybe wake-up path is not enough.
> > 
> Here.
> Anyway, there is an unfortunate complexity in cgroup's rmdir() path.
> I think this will remove all concern in
> 	pre_destroy -> check -> start rmdir path
> if subsys is aware of what they does.
> Usual subsys just consider "tasks" and no extra references I hope.
> If your test result is good, I'll post again (after merge window ?).
> 
Thank you for your patch.

At first, I thought this problem can be solved by this direction, but
there is a race window yet.

The root cause of this problem is that mem.usage can be incremented
by swap-in behavior of memcg even after it has become 0 once.
So, mem.usage can also be incremented between cgroup_need_restart_rmdir()
and schedule().
I can see rmdir being locked up actually in my test.

hmm, sleeping until being waken up might not be good if we don't change
swap-in behavior of memcg in some way.


Thanks,
Daisuke Nishimura.

> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Cgroup is designed for do some work against _tasks_. But when it comes to
> memcg, a cgroup can be obtained by something other...i.e. page and swap entry.
> Then, pre_destroy at el. are provided. Historically, there are some races
> around this...this is new one.
> 
> Now, rmdir() path uses following logic.
> 
> 	pre_destroy();	   # drop all css->refcnt to be 0.
> 	lock cgroup mutex  # no new task after this
> 	check cgroup has no tasks.
> 	check cgroup has no children.
> 	check css refcnt 
> 	(*)	if refcnt is not 0, sleep and wait for refcnt goes down to 0.
> 
> The logic (*) assumes the refcnt will goes down soon, but in some case(memcg),
> it's better to call pre_destroy() again if pre_destroy() can handle it.
> (The most unfortunate in above logic is that we can't have some trustable
>  lock in this path..but..we may never be able to do.)
> 
> This patch adds ss->restart_rmdir() callback to subsys and allow immediate
> retry of pre_destroy() if necessary.
> 
> Reported-by: Daisuke Nishimura  <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> Index: linux-2.6.30.org/include/linux/cgroup.h
> ===================================================================
> --- linux-2.6.30.org.orig/include/linux/cgroup.h
> +++ linux-2.6.30.org/include/linux/cgroup.h
> @@ -374,6 +374,7 @@ struct cgroup_subsys {
>  	struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
>  						  struct cgroup *cgrp);
>  	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
> +	bool (*restart_rmdir)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  	int (*can_attach)(struct cgroup_subsys *ss,
>  			  struct cgroup *cgrp, struct task_struct *tsk);
> Index: linux-2.6.30.org/kernel/cgroup.c
> ===================================================================
> --- linux-2.6.30.org.orig/kernel/cgroup.c
> +++ linux-2.6.30.org/kernel/cgroup.c
> @@ -635,6 +635,23 @@ static int cgroup_call_pre_destroy(struc
>  		}
>  	return ret;
>  }
> +/*
> + * Check we have to restart rmdir immediately or not. Because we don't have any
> + * system which prevents "new reference comes after pre_destroy", we checks
> + * whether we have to call pre_destroy() again or not.
> + * i.e. if css_get()'s refcnt is not a temporal one, we can't expect css_put()
> + * is called and need to call pre_destroy().
> + */
> +static bool cgroup_need_restart_rmdir(struct cgroup *cgrp)
> +{
> +	struct cgroup_subsys *ss;
> +
> +	for_each_subsys(cgrp->root, ss)
> +		if (ss->restart_rmdir)
> +			if (ss->restart_rmdir(ss, cgrp))
> +				return true;
> +	return false;
> +}
>  
>  static void free_cgroup_rcu(struct rcu_head *obj)
>  {
> @@ -2705,7 +2722,8 @@ again:
>  
>  	if (!cgroup_clear_css_refs(cgrp)) {
>  		mutex_unlock(&cgroup_mutex);
> -		schedule();
> +		if (!cgroup_need_restart_rmdir(cgrp))
> +			schedule();
>  		finish_wait(&cgroup_rmdir_waitq, &wait);
>  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>  		if (signal_pending(current))
> Index: linux-2.6.30.org/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.30.org.orig/mm/memcontrol.c
> +++ linux-2.6.30.org/mm/memcontrol.c
> @@ -2462,6 +2462,18 @@ static int mem_cgroup_pre_destroy(struct
>  	return mem_cgroup_force_empty(mem, false);
>  }
>  
> +static bool mem_cgroup_restart_rmdir(struct cgroup_subsys *ss,
> +					struct cgroup *cont)
> +{
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> +	unsigned long long usage;
> +
> +	usage = res_counter_read_u64(&mem->res, RES_USAGE);
> +	if (usage)/* some charge after pre_destroy() (via swap)....*/
> +		return true;
> +	return false;
> +}
> +
>  static void mem_cgroup_destroy(struct cgroup_subsys *ss,
>  				struct cgroup *cont)
>  {
> @@ -2501,6 +2513,7 @@ struct cgroup_subsys mem_cgroup_subsys =
>  	.subsys_id = mem_cgroup_subsys_id,
>  	.create = mem_cgroup_create,
>  	.pre_destroy = mem_cgroup_pre_destroy,
> +	.restart_rmdir = mem_cgroup_restart_rmdir,
>  	.destroy = mem_cgroup_destroy,
>  	.populate = mem_cgroup_populate,
>  	.attach = mem_cgroup_move_task,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
