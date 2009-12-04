Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4C0CB6007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 02:17:38 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB47HX9m022660
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Dec 2009 16:17:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ACC4745DE4D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 16:17:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 712B045DE52
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 16:17:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3928C1DB803A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 16:17:33 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DFC6F1DB803E
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 16:17:32 +0900 (JST)
Date: Fri, 4 Dec 2009 16:14:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 5/7] memcg: avoid oom during moving charge
Message-Id: <20091204161439.2e584630.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091204145154.4d184f1d.nishimura@mxp.nes.nec.co.jp>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
	<20091204145154.4d184f1d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009 14:51:54 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This move-charge-at-task-migration feature has extra charges on "to"(pre-charges)
> and "from"(leftover charges) during moving charge. This means unnecessary oom
> can happen.
> 
> This patch tries to avoid such oom.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Changelog: 2009/12/04
> - take account of "from" too, because we uncharge from "from" at once in
>   mem_cgroup_clear_mc(), so leftover charges exist during moving charge.
> - check use_hierarchy of "mem_over_limit", instead of "to" or "from"(bugfix).
> ---
>  mm/memcontrol.c |   38 ++++++++++++++++++++++++++++++++++++++
>  1 files changed, 38 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 769b85a..f50ad15 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -253,6 +253,7 @@ struct move_charge_struct {
>  	struct mem_cgroup *to;
>  	unsigned long precharge;
>  	unsigned long moved_charge;
> +	struct task_struct *moving_task;	/* a task moving charges */
>  };
>  static struct move_charge_struct mc;
>  
> @@ -1504,6 +1505,40 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  		if (mem_cgroup_check_under_limit(mem_over_limit))
>  			continue;
>  
> +		/* try to avoid oom while someone is moving charge */
> +		if (mc.moving_task && current != mc.moving_task) {
> +			struct mem_cgroup *from, *to;
> +			bool do_continue = false;
> +			/*
> +			 * There is a small race that "from" or "to" can be
> +			 * freed by rmdir, so we use css_tryget().
> +			 */
> +			rcu_read_lock();
> +			from = mc.from;
> +			to = mc.to;
> +			if (from && css_tryget(&from->css)) {
> +				if (mem_over_limit->use_hierarchy)
> +					do_continue = css_is_ancestor(
> +							&from->css,
> +							&mem_over_limit->css);
> +				else
> +					do_continue = (from == mem_over_limit);
> +				css_put(&from->css);
> +			}
> +			if (!do_continue && to && css_tryget(&to->css)) {
> +				if (mem_over_limit->use_hierarchy)
> +					do_continue = css_is_ancestor(
> +							&to->css,
> +							&mem_over_limit->css);
> +				else
> +					do_continue = (to == mem_over_limit);
> +				css_put(&to->css);
> +			}
> +			rcu_read_unlock();
> +			if (do_continue)
> +				continue;

Hmm. do countine without any relaxing ? can't this occupy cpu ?
Can't we add schedule() or some and put into sleep ?

Maybe the best way is enqueue this thread to mc.wait_queue and wait for
the end of task moving.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
