Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 222815F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 20:29:52 -0500 (EST)
Message-ID: <49879DE5.8030505@cn.fujitsu.com>
Date: Tue, 03 Feb 2009 09:29:09 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [-mm patch] Show memcg information during OOM
References: <20090202125240.GA918@balbir.in.ibm.com> <20090202140849.GB918@balbir.in.ibm.com>
In-Reply-To: <20090202140849.GB918@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> +void mem_cgroup_print_mem_info(struct mem_cgroup *memcg)
> +{
> +	printk(KERN_WARNING "Memory cgroups's name %s\n",
> +		memcg->css.cgroup->dentry->d_name.name);
> +	printk(KERN_WARNING "Memory cgroup RSS : usage %llu, limit %llu"
> +		" failcnt %llu\n", res_counter_read_u64(&memcg->res, RES_USAGE),

", failcnt %llu\n" ?

> +		res_counter_read_u64(&memcg->res, RES_LIMIT),
> +		res_counter_read_u64(&memcg->res, RES_FAILCNT));
> +	printk(KERN_WARNING "Memory cgroup swap: usage %llu, limit %llu "
> +		"failcnt %llu\n",

", failcnt %llu\n" ?

> +		res_counter_read_u64(&memcg->memsw, RES_USAGE),
> +		res_counter_read_u64(&memcg->memsw, RES_LIMIT),
> +		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
> +}
> +
>  /*
>   * Unlike exported interface, "oom" parameter is added. if oom==true,
>   * oom-killer can be invoked.
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index d3b9bac..b8e53ae 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -392,6 +392,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			current->comm, gfp_mask, order, current->oomkilladj);
>  		task_lock(current);
>  		cpuset_print_task_mems_allowed(current);
> +		mem_cgroup_print_mem_info(mem);

I think this can be put outside the task lock. The lock is used to call task_cs() safely in
cpuset_print_task_mems_allowed().

>  		task_unlock(current);
>  		dump_stack();
>  		show_mem();
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
