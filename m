Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 178F76B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 14:44:27 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so7012968pad.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 11:44:26 -0700 (PDT)
Date: Tue, 16 Oct 2012 11:44:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
In-Reply-To: <1350382328-28977-1-git-send-email-handai.szj@taobao.com>
Message-ID: <alpine.DEB.2.00.1210161142390.2910@chino.kir.corp.google.com>
References: <1350382328-28977-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Tue, 16 Oct 2012, Sha Zhengju wrote:

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e4e9b18..c329940 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1486,6 +1486,15 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  
>  	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
>  	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
> +	if (sysctl_oom_kill_allocating_task && current->mm &&
> +	    !oom_unkillable_task(current, memcg, NULL) &&
> +	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> +		get_task_struct(current);
> +		oom_kill_process(current, gfp_mask, order, 0, totalpages, memcg, NULL,
> +				 "Memory cgroup out of memory (oom_kill_allocating_task)");
> +		return;
> +	}
> +
>  	for_each_mem_cgroup_tree(iter, memcg) {
>  		struct cgroup *cgroup = iter->css.cgroup;
>  		struct cgroup_iter it;

Please try to compile your patches and run scripts/checkpatch.pl on them 
before proposing them.

You'll also need to update Documentation/sysctl/vm.txt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
