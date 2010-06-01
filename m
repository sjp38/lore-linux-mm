Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E62866B01E4
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:23:27 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o51CGhFT015863
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 06:16:43 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o51CNAnm056436
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 06:23:11 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o51CNAYX028607
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 06:23:10 -0600
Received: from balbir-laptop ([9.77.209.155])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id o51CN8j0028528
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 06:23:09 -0600
Resent-Message-ID: <20100601122306.GI2804@balbir.in.ibm.com>
Resent-To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Date: Tue, 1 Jun 2010 17:06:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][1/3] memcg clean up try charge
Message-ID: <20100601113658.GF2804@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-01 18:24:06]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> mem_cgroup_try_charge() has a big loop (doesn't fits in screee) and seems to be
> hard to read. Most of routines are for slow paths. This patch moves codes out
> from the loop and make it clear what's done.
> 
> Summary:
>  - cut out a function to detect a memcg is under acccount move or not.
>  - cut out a function to wait for the end of moving task acct.
>  - cut out a main loop('s slow path) as a function and make it clear

I prefer the work refactor as compared to cut out, just a minor nit
pick on the terminology.

>    why we retry or quit by return code.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |  244 +++++++++++++++++++++++++++++++++-----------------------
>  1 file changed, 145 insertions(+), 99 deletions(-)
> 
> Index: mmotm-2.6.34-May21/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.34-May21.orig/mm/memcontrol.c
> +++ mmotm-2.6.34-May21/mm/memcontrol.c
> @@ -1072,6 +1072,49 @@ static unsigned int get_swappiness(struc
>  	return swappiness;
>  }
> 
> +/* A routine for testing mem is not under move_account */
> +
> +static bool mem_cgroup_under_move(struct mem_cgroup *mem)
> +{
> +	struct mem_cgroup *from = mc.from;
> +	struct mem_cgroup *to = mc.to;
> +	bool ret = false;
> +
> +	if (from == mem || to == mem)
> +		return true;
> +
> +	if (!from || !to || !mem->use_hierarchy)
> +		return false;
> +
> +	rcu_read_lock();
> +	if (css_tryget(&from->css)) {
> +		ret = css_is_ancestor(&from->css, &mem->css);
> +		css_put(&from->css);
> +	}
> +	if (!ret && css_tryget(&to->css)) {
> +		ret = css_is_ancestor(&to->css,	&mem->css);
> +		css_put(&to->css);
> +	}
> +	rcu_read_unlock();
> +	return ret;
> +}
> +
> +static bool mem_cgroup_wait_acct_move(struct mem_cgroup *mem)
> +{
> +	if (mc.moving_task && current != mc.moving_task) {
> +		if (mem_cgroup_under_move(mem)) {
> +			DEFINE_WAIT(wait);
> +			prepare_to_wait(&mc.waitq, &wait, TASK_INTERRUPTIBLE);
> +			/* moving charge context might have finished. */
> +			if (mc.moving_task)
> +				schedule();

If we sleep with TASK_INTERRUPTIBLE, we should also check for
signal_pending() at the end of the schedule and handle it
appropriately to cancel the operation. 


Looks good to me otherwise.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
