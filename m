Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2
 [7/8] bacground reclaim for memory controller
In-Reply-To: Your message of "Mon, 3 Dec 2007 18:42:44 +0900"
	<20071203184244.200faee8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071203184244.200faee8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20071204030756.25A971D0B8F@siro.lan>
Date: Tue,  4 Dec 2007 12:07:55 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: riel@redhat.com, linux-mm@kvack.org, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

> @@ -1186,6 +1251,16 @@ static void free_mem_cgroup_per_zone_inf
>  
>  static struct mem_cgroup init_mem_cgroup;
>  
> +static int __init mem_cgroup_reclaim_init(void)
> +{
> +	init_mem_cgroup.daemon.thread = kthread_run(mem_cgroup_reclaim_daemon,
> +					&init_mem_cgroup, "memcontd");
> +	if (IS_ERR(init_mem_cgroup.daemon.thread))
> +		BUG();
> +	return 0;
> +}
> +late_initcall(mem_cgroup_reclaim_init);
> +
>  static struct cgroup_subsys_state *
>  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  {
> @@ -1213,6 +1288,17 @@ mem_cgroup_create(struct cgroup_subsys *
>  		if (alloc_mem_cgroup_per_zone_info(mem, node))
>  			goto free_out;
>  
> +	/* Memory Reclaim Daemon per cgroup */
> +	init_waitqueue_head(&mem->daemon.waitq);
> +	if (mem != &init_mem_cgroup) {
> +		/* Complicated...but we cannot call kthread create here..*/
> +		/* init call will later assign kthread */
> +		mem->daemon.thread = kthread_run(mem_cgroup_reclaim_daemon,
> +					mem, "memcontd");
> +		if (IS_ERR(mem->daemon.thread))
> +			goto free_out;
> +	}
> +
>  	return &mem->css;
>  free_out:
>  	for_each_node_state(node, N_POSSIBLE)

you don't need the kthread as far as RES_HWMARK is "infinite".
given the current default value of RES_HWMARK, you can simplify
initialization by deferring the kthread creation to mem_cgroup_write.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
