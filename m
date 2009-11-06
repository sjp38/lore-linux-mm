Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 40F7E6B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 01:42:00 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA66fvdG022483
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 15:41:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 55D1245DE4F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:41:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CE0045DE4E
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:41:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D9F7B1DB8040
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:41:56 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9317A1DB8038
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:41:56 +0900 (JST)
Date: Fri, 6 Nov 2009 15:39:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 7/8] memcg: avoid oom during recharge at task
 move
Message-Id: <20091106153923.753b0238.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091106141532.a2fe1187.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091106141532.a2fe1187.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009 14:15:32 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This recharge-at-task-move feature has extra charges(pre-charges) on "to"
> mem_cgroup during recharging. This means unnecessary oom can happen.
> 
> This patch tries to avoid such oom.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   27 +++++++++++++++++++++++++++
>  1 files changed, 27 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f4b7116..7e96f3b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -248,6 +248,7 @@ struct recharge_struct {
>  	struct mem_cgroup *from;
>  	struct mem_cgroup *to;
>  	struct task_struct *target;	/* the target task being moved */
> +	struct task_struct *working;	/* a task moving the target task */
>  	unsigned long precharge;
>  };
>  static struct recharge_struct recharge;
> @@ -1493,6 +1494,30 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
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
> +		}

I think it's better to do this here, rather than continue.

==
	if (do_continue) {
		mutex_lock(&memcg_tasklist_lock);
		mutex_unlock(&memcg_tasklist_lock);
		contiue;
	}
==

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
