Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB11Cux9001147
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Dec 2008 10:12:56 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3826A45DD79
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 10:12:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 064EA45DD76
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 10:12:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D37E91DB8044
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 10:12:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E84E1DB803E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 10:12:55 +0900 (JST)
Date: Mon, 1 Dec 2008 10:12:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Unused check for thread group leader in
 mem_cgroup_move_task
Message-Id: <20081201101208.08e0aa98.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200811291259.27681.knikanth@suse.de>
References: <200811291259.27681.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: balbir@linux.vnet.ibm.com, containers@lists.linux-foundation.org, xemul@openvz.org, linux-mm@kvack.org, nikanth@gmail.com
List-ID: <linux-mm.kvack.org>

On Sat, 29 Nov 2008 12:59:27 +0530
Nikanth Karthikesan <knikanth@suse.de> wrote:

> Currently we just check for thread group leader in attach() handler but do 
> nothing!  Either (1) move it to can_attach handler or (2) remove the test 
> itself. I am attaching patches for both below.
> 
> Thanks
> Nikanth Karthikesan
> 
> Move thread group leader check to can_attach handler, but this may prevent non 
> thread group leaders to be moved at all! 
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> 
It's allowed.

Nack.

-Kame



> ---
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 866dcc7..26bc823 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1136,6 +1136,18 @@ static int mem_cgroup_populate(struct cgroup_subsys 
> *ss,
>  					ARRAY_SIZE(mem_cgroup_files));
>  }
>  
> +static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> +                          struct cgroup *cgrp, struct task_struct *tsk)
> +{
> +	/*
> +	 * Only thread group leaders are allowed to migrate, the mm_struct is
> +	 * in effect owned by the leader
> +	 */
> +	if (!thread_group_leader(tsk))
> +		return -EINVAL;
> +	return 0;
> +}
> +
>  static void mem_cgroup_move_task(struct cgroup_subsys *ss,
>  				struct cgroup *cont,
>  				struct cgroup *old_cont,
> @@ -1151,14 +1163,6 @@ static void mem_cgroup_move_task(struct cgroup_subsys 
> *ss,
>  	mem = mem_cgroup_from_cont(cont);
>  	old_mem = mem_cgroup_from_cont(old_cont);
>  
> -	/*
> -	 * Only thread group leaders are allowed to migrate, the mm_struct is
> -	 * in effect owned by the leader
> -	 */
> -	if (!thread_group_leader(p))
> -		goto out;
> -
> -out:
>  	mmput(mm);
>  }
>  
> @@ -1169,6 +1173,7 @@ struct cgroup_subsys mem_cgroup_subsys = {
>  	.pre_destroy = mem_cgroup_pre_destroy,
>  	.destroy = mem_cgroup_destroy,
>  	.populate = mem_cgroup_populate,
> +	.can_attach = mem_cgroup_can_attach,
>  	.attach = mem_cgroup_move_task,
>  	.early_init = 0,
>  };
> 
> 
> 
> The patch to remove unused code follows.
> 
> Remove the unused test for thread group leader.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> 
> ---
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 866dcc7..8e9287d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1151,14 +1151,6 @@ static void mem_cgroup_move_task(struct cgroup_subsys 
> *ss,
>  	mem = mem_cgroup_from_cont(cont);
>  	old_mem = mem_cgroup_from_cont(old_cont);
>  
> -	/*
> -	 * Only thread group leaders are allowed to migrate, the mm_struct is
> -	 * in effect owned by the leader
> -	 */
> -	if (!thread_group_leader(p))
> -		goto out;
> -
> -out:
>  	mmput(mm);
>  }
>  
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
