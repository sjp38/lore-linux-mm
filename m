Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2487A6B0044
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 02:02:15 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id nANI27DL002653
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 05:02:07 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAN724hF1417268
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 18:02:07 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAN7249U013987
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 18:02:04 +1100
Date: Mon, 23 Nov 2009 10:40:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 4/5] memcg: avoid oom during recharge at task
 move
Message-ID: <20091123051041.GQ31961@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
 <20091119133030.8ef46be0.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091119133030.8ef46be0.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-19 13:30:30]:

> This recharge-at-task-move feature has extra charges(pre-charges) on "to"
> mem_cgroup during recharging. This means unnecessary oom can happen.
> 
> This patch tries to avoid such oom.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   28 ++++++++++++++++++++++++++++
>  1 files changed, 28 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index df363da..3a07383 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -249,6 +249,7 @@ struct recharge_struct {
>  	struct mem_cgroup *from;
>  	struct mem_cgroup *to;
>  	unsigned long precharge;
> +	struct task_struct *working;	/* a task moving the target task */

working does not sound like an appropriate name

>  };
>  static struct recharge_struct recharge;
> 
> @@ -1494,6 +1495,30 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  		if (mem_cgroup_check_under_limit(mem_over_limit))
>  			continue;
> 
> +		/* try to avoid oom while someone is recharging */
> +		if (recharge.working && current != recharge.working) {
> +			struct mem_cgroup *dest;
> +			bool do_continue = false;
> +			/*
> +			 * There is a small race that "dest" can be freed by
> +			 * rmdir, so we use css_tryget().
> +			 */
> +			rcu_read_lock();
> +			dest = recharge.to;
> +			if (dest && css_tryget(&dest->css)) {
> +				if (dest->use_hierarchy)
> +					do_continue = css_is_ancestor(
> +							&dest->css,
> +							&mem_over_limit->css);
> +				else
> +					do_continue = (dest == mem_over_limit);
> +				css_put(&dest->css);
> +			}
> +			rcu_read_unlock();
> +			if (do_continue)
> +				continue;

IIUC, if dest is the current cgroup we are trying to charge to or an
ancestor of the current cgroup, we don't OOM?

> +		}
> +
>  		if (!nr_retries--) {
>  			if (oom) {
>  				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
> @@ -3474,6 +3499,7 @@ static void mem_cgroup_clear_recharge(void)
>  	}
>  	recharge.from = NULL;
>  	recharge.to = NULL;
> +	recharge.working = NULL;
>  }
> 
>  static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> @@ -3498,9 +3524,11 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
>  			VM_BUG_ON(recharge.from);
>  			VM_BUG_ON(recharge.to);
>  			VM_BUG_ON(recharge.precharge);
> +			VM_BUG_ON(recharge.working);
>  			recharge.from = from;
>  			recharge.to = mem;
>  			recharge.precharge = 0;
> +			recharge.working = current;
> 
>  			ret = mem_cgroup_prepare_recharge(mm);
>  			if (ret)

Sorry, if I missed it, but I did not see any time overhead of moving a
task after these changes. Could you please help me understand the cost
of moving say a task with 1G anonymous memory to another group and
the cost of moving a task with 512MB anonymous and 512 page cache
mapped, etc. It would be nice to understand the overall cost.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
