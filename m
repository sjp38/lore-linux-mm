Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3507A5F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 07:59:38 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n12CxZ8X023954
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 2 Feb 2009 21:59:35 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 666CD45DE55
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 21:59:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FA7045DE51
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 21:59:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 287661DB803F
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 21:59:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D5DA91DB803C
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 21:59:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm patch] Show memcg information during OOM
In-Reply-To: <20090202125240.GA918@balbir.in.ibm.com>
References: <20090202125240.GA918@balbir.in.ibm.com>
Message-Id: <20090202215527.EC92.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  2 Feb 2009 21:59:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

> +void mem_cgroup_print_mem_info(struct mem_cgroup *memcg)
> +{
> +	printk(KERN_WARNING "Memory cgroups's name %s\n",
> +		memcg->css.cgroup->dentry->d_name.name);
> +	printk(KERN_WARNING "Memory cgroup RSS : usage %llu, limit %llu"
> +		" failcnt %llu\n", res_counter_read_u64(&memcg->res, RES_USAGE),
> +		res_counter_read_u64(&memcg->res, RES_LIMIT),
> +		res_counter_read_u64(&memcg->res, RES_FAILCNT));
> +	printk(KERN_WARNING "Memory cgroup swap: usage %llu, limit %llu "
> +		"failcnt %llu\n", res_counter_read_u64(&memcg->res, RES_USAGE),
> +		res_counter_read_u64(&memcg->res, RES_LIMIT),
> +		res_counter_read_u64(&memcg->res, RES_FAILCNT));

s/res/memsw/ ?

and, I don't like the name of "Memory cgroup RSS" and "Memory cgroup swap".
it seems misleading. memcg->res doesn't only count count rss, but also cache.
memcg->memsw doesn't only count swap, but also memory.

otherthing, I think it is good patch for me :)


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
>  		task_unlock(current);
>  		dump_stack();
>  		show_mem();
> 
> -- 
> 	Balbir
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
