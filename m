Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F0BF26B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 03:36:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8O7amBw002632
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 24 Sep 2009 16:36:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D062F45DE4D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 16:36:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 81CBE45DD75
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 16:36:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 447BEE1800B
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 16:36:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A56D3E18005
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 16:36:46 +0900 (JST)
Date: Thu, 24 Sep 2009 16:34:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/8] memcg: avoid oom during charge migration
Message-Id: <20090924163440.758ead95.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090924144902.f4e5854c.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
	<20090924144902.f4e5854c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Sep 2009 14:49:02 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This charge migration feature has double charges on both "from" and "to"
> mem_cgroup during charge migration.
> This means unnecessary oom can happen because of charge migration.
> 
> This patch tries to avoid such oom.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   19 +++++++++++++++++++
>  1 files changed, 19 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fbcc195..25de11c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -287,6 +287,8 @@ struct migrate_charge {
>  	unsigned long precharge;
>  };
>  static struct migrate_charge *mc;
> +static struct task_struct *mc_task;
> +static DECLARE_WAIT_QUEUE_HEAD(mc_waitq);
>  
>  static void mem_cgroup_get(struct mem_cgroup *mem);
>  static void mem_cgroup_put(struct mem_cgroup *mem);
> @@ -1317,6 +1319,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  	while (1) {
>  		int ret = 0;
>  		unsigned long flags = 0;
> +		DEFINE_WAIT(wait);
>  
>  		if (mem_cgroup_is_root(mem))
>  			goto done;
> @@ -1358,6 +1361,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  		if (mem_cgroup_check_under_limit(mem_over_limit))
>  			continue;
>  
> +		/* try to avoid oom while someone is migrating charge */
> +		if (mc_task && current != mc_task) {

Hmm, I like

==
	if (mc && mc->to == mem)
or
	if (mc) {
		if (mem is ancestor of mc->to)
			wait for a while
==

?


> +			prepare_to_wait(&mc_waitq, &wait, TASK_INTERRUPTIBLE);
> +			if (mc) {
> +				schedule();
> +				finish_wait(&mc_waitq, &wait);
> +				continue;
> +			}
> +			finish_wait(&mc_waitq, &wait);
> +		}
> +
>  		if (!nr_retries--) {
>  			if (oom) {
>  				mutex_lock(&memcg_tasklist);
> @@ -3345,6 +3359,8 @@ static void mem_cgroup_clear_migrate_charge(void)
>  		__mem_cgroup_cancel_charge(mc->to);
>  	kfree(mc);
>  	mc = NULL;
> +	mc_task = NULL;
> +	wake_up_all(&mc_waitq);
>  }

Hmm. I think this wake_up is too late.
How about waking up when we release page_table_lock() or
once per vma ?

Or, just skip nr_retries-- like

if (mc && mc->to_is_not_ancestor(mem) && nr_retries--) {
}

?

I think page-reclaim war itself is not bad.
(Anyway, we'll have to fix cgroup_lock if the move cost is a problem.)


Thanks,
-Kame

>  
>  static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
> @@ -3354,6 +3370,7 @@ static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
>  	struct mem_cgroup *from = mem_cgroup_from_task(p);
>  
>  	VM_BUG_ON(mc);
> +	VM_BUG_ON(mc_task);
>  
>  	if (from == mem)
>  		return 0;
> @@ -3367,6 +3384,8 @@ static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
>  	mc->to = mem;
>  	mc->precharge = 0;
>  
> +	mc_task = current;
> +
>  	ret = migrate_charge_prepare();
>  
>  	if (ret)
> -- 
> 1.5.6.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
