Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CBA156B007E
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 23:08:57 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id nAP48pNo026899
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 09:38:51 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAP48ogQ3645548
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 09:38:50 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAP48oTt028758
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 15:08:50 +1100
Date: Wed, 25 Nov 2009 09:38:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH -stable] memcg: avoid oom-killing innocent task
	in case of use_hierarchy
Message-ID: <20091125040845.GD3365@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp> <20091124162854.fb31e81e.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091124162854.fb31e81e.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: stable <stable@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-24 16:28:54]:

> task_in_mem_cgroup(), which is called by select_bad_process() to check whether
> a task can be a candidate for being oom-killed from memcg's limit, checks
> "curr->use_hierarchy"("curr" is the mem_cgroup the task belongs to).
> 
> But this check return true(it's false positive) when:
> 
> 	<some path>/00		use_hierarchy == 0	<- hitting limit
> 	  <some path>/00/aa	use_hierarchy == 1	<- "curr"
> 
> This leads to killing an innocent task in 00/aa. This patch is a fix for this
> bug. And this patch also fixes the arg for mem_cgroup_print_oom_info(). We
> should print information of mem_cgroup which the task being killed, not current,
> belongs to.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |    2 +-
>  mm/oom_kill.c   |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fd4529d..3acc226 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -496,7 +496,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
>  	task_unlock(task);
>  	if (!curr)
>  		return 0;
> -	if (curr->use_hierarchy)
> +	if (mem->use_hierarchy)
>  		ret = css_is_ancestor(&curr->css, &mem->css);
>  	else
>  		ret = (curr == mem);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index a7b2460..ed452e9 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -400,7 +400,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		cpuset_print_task_mems_allowed(current);
>  		task_unlock(current);
>  		dump_stack();
> -		mem_cgroup_print_oom_info(mem, current);
> +		mem_cgroup_print_oom_info(mem, p);
>  		show_mem();
>  		if (sysctl_oom_dump_tasks)
>  			dump_tasks(mem);
>

 
Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
