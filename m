Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A97AA6B01DA
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:23:15 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o51CCqGc023764
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 06:12:52 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o51CN6ne100090
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 06:23:07 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o51CN6rO028431
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 06:23:06 -0600
Received: from balbir-laptop ([9.77.209.155])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id o51CN4nx028355
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 06:23:05 -0600
Resent-Message-ID: <20100601122303.GH2804@balbir.in.ibm.com>
Resent-To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Date: Tue, 1 Jun 2010 16:55:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][2/3] memcg safe operaton for checking a cgroup is under
 move accounts
Message-ID: <20100601112529.GE2804@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
 <20100601182720.f1562de6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100601182720.f1562de6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-01 18:27:20]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, for checking a memcg is under task-account-moving, we do css_tryget()
> against mc.to and mc.from. But this ust complicates things. This patch
> makes the check easier. (And I doubt the current code has some races..)
> 
> This patch adds a spinlock to move_charge_struct and guard modification
> of mc.to and mc.from. By this, we don't have to think about complicated
> races around this not-critical path.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   48 ++++++++++++++++++++++++++++--------------------
>  1 file changed, 28 insertions(+), 20 deletions(-)
> 
> Index: mmotm-2.6.34-May21/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.34-May21.orig/mm/memcontrol.c
> +++ mmotm-2.6.34-May21/mm/memcontrol.c
> @@ -268,6 +268,7 @@ enum move_type {
> 
>  /* "mc" and its members are protected by cgroup_mutex */
>  static struct move_charge_struct {
> +	spinlock_t	  lock; /* for from, to, moving_task */
>  	struct mem_cgroup *from;
>  	struct mem_cgroup *to;
>  	unsigned long precharge;
> @@ -276,6 +277,7 @@ static struct move_charge_struct {
>  	struct task_struct *moving_task;	/* a task moving charges */
>  	wait_queue_head_t waitq;		/* a waitq for other context */
>  } mc = {
> +	.lock = __SPIN_LOCK_UNLOCKED(mc.lock),
>  	.waitq = __WAIT_QUEUE_HEAD_INITIALIZER(mc.waitq),
>  };
> 
> @@ -1076,26 +1078,25 @@ static unsigned int get_swappiness(struc
> 
>  static bool mem_cgroup_under_move(struct mem_cgroup *mem)
>  {
> -	struct mem_cgroup *from = mc.from;
> -	struct mem_cgroup *to = mc.to;
> +	struct mem_cgroup *from;
> +	struct mem_cgroup *to;
>  	bool ret = false;
> -
> -	if (from == mem || to == mem)
> -		return true;
> -
> -	if (!from || !to || !mem->use_hierarchy)
> -		return false;
> -
> -	rcu_read_lock();
> -	if (css_tryget(&from->css)) {
> -		ret = css_is_ancestor(&from->css, &mem->css);
> -		css_put(&from->css);
> -	}
> -	if (!ret && css_tryget(&to->css)) {
> -		ret = css_is_ancestor(&to->css,	&mem->css);
> +	/*
> +	 * Unlike task_move routines, we access mc.to, mc.from not under
> +	 * mutual execution by cgroup_mutex. Here, we take spinlock instead.
                 ^^^^^
        Typo should be exclusion

> +	 */
> +	spin_lock_irq(&mc.lock);

Why do we use the _irq variant here?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
