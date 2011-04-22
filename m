Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B53E68D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:47:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2DE9F3EE0C1
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:47:51 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A67845DE5A
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:47:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E585445DE54
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:47:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D563BE08002
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:47:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ECE11DB8046
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:47:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V7 1/9] Add kswapd descriptor
In-Reply-To: <1303446260-21333-2-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com> <1303446260-21333-2-git-send-email-yinghan@google.com>
Message-Id: <20110422134804.FA5E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Apr 2011 13:47:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

Hi,

This seems to have no ugly parts.


nitpick:

> -	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
> +	const struct cpumask *cpumask;
>  
>  	lockdep_set_current_reclaim_state(GFP_KERNEL);
>  
> +	cpumask = cpumask_of_node(pgdat->node_id);

no effect change?


>  	if (!cpumask_empty(cpumask))
>  		set_cpus_allowed_ptr(tsk, cpumask);
>  	current->reclaim_state = &reclaim_state;
> @@ -2679,7 +2684,7 @@ static int kswapd(void *p)
>  			order = new_order;
>  			classzone_idx = new_classzone_idx;
>  		} else {
> -			kswapd_try_to_sleep(pgdat, order, classzone_idx);
> +			kswapd_try_to_sleep(kswapd_p, order, classzone_idx);
>  			order = pgdat->kswapd_max_order;
>  			classzone_idx = pgdat->classzone_idx;
>  			pgdat->kswapd_max_order = 0;
> @@ -2817,12 +2822,20 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
>  		for_each_node_state(nid, N_HIGH_MEMORY) {
>  			pg_data_t *pgdat = NODE_DATA(nid);
>  			const struct cpumask *mask;
> +			struct kswapd *kswapd_p;
> +			struct task_struct *kswapd_tsk;
> +			wait_queue_head_t *wait;
>  
>  			mask = cpumask_of_node(pgdat->node_id);
>  
> +			wait = &pgdat->kswapd_wait;

In kswapd_try_to_sleep(), this waitqueue is called wait_h. Can you
please keep naming consistency?


> +			kswapd_p = pgdat->kswapd;
> +			kswapd_tsk = kswapd_p->kswapd_task;
> +
>  			if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
>  				/* One of our CPUs online: restore mask */
> -				set_cpus_allowed_ptr(pgdat->kswapd, mask);
> +				if (kswapd_tsk)
> +					set_cpus_allowed_ptr(kswapd_tsk, mask);

Need adding commnets. What mean kswapd_tsk==NULL and When it occur.
I'm apologize if it done at later patch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
