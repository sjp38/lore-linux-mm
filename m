Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 995C56B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 14:14:46 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id nAAIw9Gw030747
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 00:28:09 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAAJEPdF3784716
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 00:44:25 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAAJEOua014947
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 06:14:25 +1100
Date: Wed, 11 Nov 2009 00:44:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 2/8] memcg: move memcg_tasklist mutex
Message-ID: <20091110191423.GD3314@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
 <20091106141149.9c7e94d5.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091106141149.9c7e94d5.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-06 14:11:49]:

> memcg_tasklist was introduced to serialize mem_cgroup_out_of_memory() and
> mem_cgroup_move_task() to ensure tasks cannot be moved to another cgroup
> during select_bad_process().
> 
> task_in_mem_cgroup(), which can be called by select_bad_process(), will check
> whether a task is in the mem_cgroup or not by dereferencing task->cgroups
> ->subsys[]. So, it would be desirable to change task->cgroups
> (rcu_assign_pointer() in cgroup_attach_task() does it) with memcg_tasklist held.
> 
> Now that we can define cancel_attach(), we can safely release memcg_tasklist
> on fail path even if we hold memcg_tasklist in can_attach(). So let's move
> mutex_lock/unlock() of memcg_tasklist.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   22 ++++++++++++++++++++--
>  1 files changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4bd3451..d3b2ac0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3395,18 +3395,34 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
>  	return ret;
>  }
> 
> +static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> +				struct cgroup *cgroup,
> +				struct task_struct *p,
> +				bool threadgroup)
> +{
> +	mutex_lock(&memcg_tasklist);
> +	return 0;
> +}
> +
> +static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
> +				struct cgroup *cgroup,
> +				struct task_struct *p,
> +				bool threadgroup)
> +{
> +	mutex_unlock(&memcg_tasklist);
> +}
> +
>  static void mem_cgroup_move_task(struct cgroup_subsys *ss,
>  				struct cgroup *cont,
>  				struct cgroup *old_cont,
>  				struct task_struct *p,
>  				bool threadgroup)
>  {
> -	mutex_lock(&memcg_tasklist);
> +	mutex_unlock(&memcg_tasklist);

What does this mean for nesting? I think the API's are called with
cgroup_mutex held, so memcg_tasklist nests under cgroup_mutex right?
Could you please document that at the mutex declaration point.
Shouldn't you be removing the FIXME as well?

>  	/*
>  	 * FIXME: It's better to move charges of this process from old
>  	 * memcg to new memcg. But it's just on TODO-List now.
>  	 */
> -	mutex_unlock(&memcg_tasklist);
>  }
> 
>  struct cgroup_subsys mem_cgroup_subsys = {
> @@ -3416,6 +3432,8 @@ struct cgroup_subsys mem_cgroup_subsys = {
>  	.pre_destroy = mem_cgroup_pre_destroy,
>  	.destroy = mem_cgroup_destroy,
>  	.populate = mem_cgroup_populate,
> +	.can_attach = mem_cgroup_can_attach,
> +	.cancel_attach = mem_cgroup_cancel_attach,
>  	.attach = mem_cgroup_move_task,
>  	.early_init = 0,
>  	.use_id = 1,
> -- 
> 1.5.6.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
