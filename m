Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 85F626B005D
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 00:22:08 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H4MDYI001624
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Sep 2009 13:22:13 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E08745DE4F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 13:22:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BE9145DE4E
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 13:22:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 643BF1DB803F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 13:22:13 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0778C1DB8040
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 13:22:13 +0900 (JST)
Date: Thu, 17 Sep 2009 13:20:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/8] memcg: add interface to migrate charge
Message-Id: <20090917132007.8e371add.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090917112602.1db6e21e.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917112602.1db6e21e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 11:26:02 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch adds "memory.migrate_charge" file and handlers of it.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   69 +++++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 files changed, 65 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6d77c80..6466e3c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -225,6 +225,8 @@ struct mem_cgroup {
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
>  
> +	unsigned int 	migrate_charge;
> +
>  	/*
>  	 * statistics. This must be placed at the end of memcg.
>  	 */
> @@ -2826,6 +2828,31 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  	return 0;
>  }
>  
> +enum migrate_charge_type {
> +	NR_MIGRATE_CHARGE_TYPE,
> +};
> +

To be honest, I don't like this MIGRATE_CHARGE_TYPE.
Why is this necessary to be complicated rather than true/false here ?
Is there much variation of use-case ?

Thanks,
-Kame

> +static u64 mem_cgroup_migrate_charge_read(struct cgroup *cgrp,
> +					struct cftype *cft)
> +{
> +	return mem_cgroup_from_cont(cgrp)->migrate_charge;
> +}
> +
> +static int mem_cgroup_migrate_charge_write(struct cgroup *cgrp,
> +					struct cftype *cft, u64 val)
> +{
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> +
> +	if (val >= (1 << NR_MIGRATE_CHARGE_TYPE))
> +		return -EINVAL;
> +
> +	cgroup_lock();
> +	mem->migrate_charge = val;
> +	cgroup_unlock();
> +
> +	return 0;
> +}
> +
>  
>  static struct cftype mem_cgroup_files[] = {
>  	{
> @@ -2875,6 +2902,11 @@ static struct cftype mem_cgroup_files[] = {
>  		.read_u64 = mem_cgroup_swappiness_read,
>  		.write_u64 = mem_cgroup_swappiness_write,
>  	},
> +	{
> +		.name = "migrate_charge",
> +		.read_u64 = mem_cgroup_migrate_charge_read,
> +		.write_u64 = mem_cgroup_migrate_charge_write,
> +	},
>  };
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> @@ -3115,6 +3147,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	if (parent)
>  		mem->swappiness = get_swappiness(parent);
>  	atomic_set(&mem->refcnt, 1);
> +	mem->migrate_charge = 0;
>  	return &mem->css;
>  free_out:
>  	__mem_cgroup_free(mem);
> @@ -3151,6 +3184,35 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
>  	return ret;
>  }
>  
> +static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
> +					struct task_struct *p)
> +{
> +	return 0;
> +}
> +
> +static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> +				struct cgroup *cont,
> +				struct task_struct *p,
> +				bool threadgroup)
> +{
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> +
> +	if (mem->migrate_charge && thread_group_leader(p))
> +		return mem_cgroup_can_migrate_charge(mem, p);
> +	return 0;
> +}
> +
> +static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
> +				struct cgroup *cont,
> +				struct task_struct *p,
> +				bool threadgroup)
> +{
> +}
> +
> +static void mem_cgroup_migrate_charge(void)
> +{
> +}
> +
>  static void mem_cgroup_move_task(struct cgroup_subsys *ss,
>  				struct cgroup *cont,
>  				struct cgroup *old_cont,
> @@ -3158,10 +3220,7 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
>  				bool threadgroup)
>  {
>  	mutex_lock(&memcg_tasklist);
> -	/*
> -	 * FIXME: It's better to move charges of this process from old
> -	 * memcg to new memcg. But it's just on TODO-List now.
> -	 */
> +	mem_cgroup_migrate_charge();
>  	mutex_unlock(&memcg_tasklist);
>  }
>  
> @@ -3172,6 +3231,8 @@ struct cgroup_subsys mem_cgroup_subsys = {
>  	.pre_destroy = mem_cgroup_pre_destroy,
>  	.destroy = mem_cgroup_destroy,
>  	.populate = mem_cgroup_populate,
> +	.can_attach = mem_cgroup_can_attach,
> +	.cancel_attach = mem_cgroup_cancel_attach,
>  	.attach = mem_cgroup_move_task,
>  	.early_init = 0,
>  	.use_id = 1,
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
