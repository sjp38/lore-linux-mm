Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B4D3C6B00C7
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 10:43:00 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id nAKFgoSO004320
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 21:12:50 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAKFgnax3100784
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 21:12:49 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAKFgn8O014546
	for <linux-mm@kvack.org>; Sat, 21 Nov 2009 02:42:49 +1100
Date: Fri, 20 Nov 2009 21:12:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 2/5] memcg: add interface to recharge at task
 move
Message-ID: <20091120154245.GN31961@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
 <20091119132907.c63e6c24.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091119132907.c63e6c24.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-19 13:29:07]:

> In current memcg, charges associated with a task aren't moved to the new cgroup
> at task move. Some users feel this behavior to be strange.
> These patches are for this feature, that is, for recharging to the new cgroup
> and, of course, uncharging from old cgroup at task move.
> 
> This patch adds "memory.recharge_at_immigrate" file, which is a flag file to
> determine whether charges should be moved to the new cgroup at task move or
> not and what type of charges should be recharged. This patch also adds read
> and write handlers of the file.
> 
> This patch also adds no-op handlers for this feature. These handlers will be
> implemented in later patches. And you cannot write any values other than 0
> to recharge_at_immigrate yet.

A basic question that we can clarify in the document, charge will move
only when mm->owner moves right?

> 
> Changelog: 2009/11/19
> - consolidate changes in Documentation/cgroup/memory.txt, which were made in
>   other patches separately.
> - handle recharge_at_immigrate as bitmask(as I did in first version).
> - use mm->owner instead of thread_group_leader().
> Changelog: 2009/09/24
> - change the term "migration" to "recharge".
> - handle the flag as bool not bitmask to make codes simple.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  Documentation/cgroups/memory.txt |   42 ++++++++++++++++-
>  mm/memcontrol.c                  |   93 ++++++++++++++++++++++++++++++++++++--
>  2 files changed, 129 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index b871f25..809585e 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -262,10 +262,12 @@ some of the pages cached in the cgroup (page cache pages).
>  4.2 Task migration
> 
>  When a task migrates from one cgroup to another, it's charge is not
> -carried forward. The pages allocated from the original cgroup still
> +carried forward by default. The pages allocated from the original cgroup still
>  remain charged to it, the charge is dropped when the page is freed or
>  reclaimed.
> 
> +Note: You can move charges of a task along with task migration. See 8.
> +
>  4.3 Removing a cgroup
> 
>  A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
> @@ -414,7 +416,43 @@ NOTE1: Soft limits take effect over a long period of time, since they involve
>  NOTE2: It is recommended to set the soft limit always below the hard limit,
>         otherwise the hard limit will take precedence.
> 
> -8. TODO
> +8. Recharge at task move
> +
> +Users can move charges associated with a task along with task move, that is,
> +uncharge from the old cgroup and charge to the new cgroup.
> +
> +8.1 Interface
> +
> +This feature is disabled by default. It can be enabled(and disabled again) by
> +writing to memory.recharge_at_immigrate of the destination cgroup.
> +
> +If you want to enable it:
> +
> +# echo (some positive value) > memory.recharge_at_immigrate
> +
> +Note: Each bits of recharge_at_immigrate has its own meaning about what type of
> +charges should be recharged. See 8.2 for details.
> +
> +And if you want disable it again:
> +
> +# echo 0 > memory.recharge_at_immigrate
> +
> +8.2 Type of charges which can be recharged
> +
> +Each bits of recharge_at_immigrate has its own meaning about what type of
> +charges should be recharged.
> +
> +  bit | what type of charges would be recharged ?
> + -----+------------------------------------------------------------------------
> +   0  | A charge of an anonymous page(or swap of it) used by the target task.
> +      | Those pages and swaps must be used only by the target task. You must
> +      | enable Swap Extension(see 2.4) to enable recharge of swap.
> +
> +Note: Those pages and swaps must be charged to the old cgroup.
> +Note: More type of pages(e.g. file cache, shmem,) will be supported by other
> +bits in future.
> +
> +9. TODO
> 
>  1. Add support for accounting huge pages (as a separate controller)
>  2. Make per-cgroup scanner reclaim not-shared pages first
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fc16f08..13fe93d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -226,11 +226,23 @@ struct mem_cgroup {
>  	bool		memsw_is_minimum;
> 
>  	/*
> +	 * Should we recharge charges of a task when a task is moved into this
> +	 * mem_cgroup ? And what type of charges should we recharge ?
> +	 */
> +	unsigned long 	recharge_at_immigrate;

recharge sounds confusing, should be use migrate_charge or
move_charge?

> +
> +	/*
>  	 * statistics. This must be placed at the end of memcg.
>  	 */
>  	struct mem_cgroup_stat stat;
>  };
> 
> +/* Stuffs for recharge at task move. */
> +/* Types of charges to be recharged */
> +enum recharge_type {
> +	NR_RECHARGE_TYPE,
> +};


Can you document that these are left shifted and hence should
be treated as power of 2 or bits in a map.

> +
>  /*
>   * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
>   * limit reclaim to prevent infinite loops, if they ever occur.
> @@ -2860,6 +2872,31 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
>  	return 0;
>  }
> 
> +static u64 mem_cgroup_recharge_read(struct cgroup *cgrp,
> +					struct cftype *cft)
> +{
> +	return mem_cgroup_from_cont(cgrp)->recharge_at_immigrate;
> +}
> +
> +static int mem_cgroup_recharge_write(struct cgroup *cgrp,
> +					struct cftype *cft, u64 val)
> +{
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> +
> +	if (val >= (1 << NR_RECHARGE_TYPE))
> +		return -EINVAL;
> +	/*
> +	 * We check this value several times in both in can_attach() and
> +	 * attach(), so we need cgroup lock to prevent this value from being
> +	 * inconsistent.
> +	 */
> +	cgroup_lock();
> +	mem->recharge_at_immigrate = val;
> +	cgroup_unlock();
> +
> +	return 0;
> +}
> +
> 
>  /* For read statistics */
>  enum {
> @@ -3093,6 +3130,11 @@ static struct cftype mem_cgroup_files[] = {
>  		.read_u64 = mem_cgroup_swappiness_read,
>  		.write_u64 = mem_cgroup_swappiness_write,
>  	},
> +	{
> +		.name = "recharge_at_immigrate",
> +		.read_u64 = mem_cgroup_recharge_read,
> +		.write_u64 = mem_cgroup_recharge_write,
> +	},
>  };
> 
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> @@ -3340,6 +3382,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	if (parent)
>  		mem->swappiness = get_swappiness(parent);
>  	atomic_set(&mem->refcnt, 1);
> +	mem->recharge_at_immigrate = 0;

Should we not inherit this from the parent in a hierarchy?

>  	return &mem->css;
>  free_out:
>  	__mem_cgroup_free(mem);
> @@ -3376,16 +3419,56 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
>  	return ret;
>  }
> 
> +/* Handlers for recharge at task move. */
> +static int mem_cgroup_can_recharge(void)
> +{
> +	return 0;
> +}
> +
> +static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> +				struct cgroup *cgroup,
> +				struct task_struct *p,
> +				bool threadgroup)
> +{
> +	int ret = 0;
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cgroup);
> +
> +	if (mem->recharge_at_immigrate) {
> +		struct mm_struct *mm;
> +		struct mem_cgroup *from = mem_cgroup_from_task(p);
> +
> +		VM_BUG_ON(from == mem);
> +
> +		mm = get_task_mm(p);
> +		if (!mm)
> +			return 0;
> +
> +		if (mm->owner == p)
> +			ret = mem_cgroup_can_recharge();
> +
> +		mmput(mm);
> +	}
> +	return ret;
> +}
> +
> +static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
> +				struct cgroup *cgroup,
> +				struct task_struct *p,
> +				bool threadgroup)
> +{
> +}
> +
> +static void mem_cgroup_recharge(void)
> +{
> +}
> +
>  static void mem_cgroup_move_task(struct cgroup_subsys *ss,
>  				struct cgroup *cont,
>  				struct cgroup *old_cont,
>  				struct task_struct *p,
>  				bool threadgroup)
>  {
> -	/*
> -	 * FIXME: It's better to move charges of this process from old
> -	 * memcg to new memcg. But it's just on TODO-List now.
> -	 */
> +	mem_cgroup_recharge();
>  }
> 
>  struct cgroup_subsys mem_cgroup_subsys = {
> @@ -3395,6 +3478,8 @@ struct cgroup_subsys mem_cgroup_subsys = {
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
