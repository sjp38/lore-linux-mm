Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EE23E6B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:32:42 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id o3N3WPPF013477
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 13:32:25 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3N3PkYG1523876
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 13:25:46 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3N3WRc9000399
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 13:32:28 +1000
Date: Fri, 23 Apr 2010 09:02:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] memcg rcu lock fix in swap code (Was Re: [BUG]
 an RCU warning in memcg
Message-ID: <20100423033223.GR3994@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <4BD10D59.9090504@cn.fujitsu.com>
 <20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-04-23 12:14:24]:

> On Fri, 23 Apr 2010 11:00:41 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
> > with CONFIG_PROVE_RCU=y, I saw this warning, it's because
> > css_id() is not under rcu_read_lock().
> > 
> 
> Ok. Thank you for reporting.
> This is ok ? 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> css_id() should be called under rcu_read_lock().
> Following is a report from Li Zefan.
> ==
> ===================================================
> [ INFO: suspicious rcu_dereference_check() usage. ]
> ---------------------------------------------------
> kernel/cgroup.c:4438 invoked rcu_dereference_check() without protection!
> 
> other info that might help us debug this:
> 
> 
> rcu_scheduler_active = 1, debug_locks = 1
> 1 lock held by kswapd0/31:
>  #0:  (swap_lock){+.+.-.}, at: [<c05058bb>] swap_info_get+0x4b/0xd0
> 
> stack backtrace:
> Pid: 31, comm: kswapd0 Not tainted 2.6.34-rc5-tip+ #13
> Call Trace:
>  [<c083c5d6>] ? printk+0x1d/0x1f
>  [<c0480744>] lockdep_rcu_dereference+0x94/0xb0
>  [<c049d6ed>] css_id+0x5d/0x60
>  [<c05165a5>] mem_cgroup_uncharge_swapcache+0x45/0xa0
>  [<c0505e4f>] swapcache_free+0x3f/0x60
>  [<c04e79e2>] __remove_mapping+0xb2/0xf0
>  [<c04e7cbb>] shrink_page_list+0x26b/0x490
>  [<c047f85d>] ? put_lock_stats+0xd/0x30
>  [<c083fd67>] ? _raw_spin_unlock_irq+0x27/0x50
>  [<c0482566>] ? trace_hardirqs_on_caller+0xb6/0x220
>  [<c04e8158>] shrink_inactive_list+0x278/0x620
>  [<c04729e1>] ? sched_clock_cpu+0x121/0x180
>  [<c047e9b8>] ? trace_hardirqs_off_caller+0x18/0x130
>  [<c047eadb>] ? trace_hardirqs_off+0xb/0x10
>  [<c0843438>] ? sub_preempt_count+0x8/0x90
>  [<c047f85d>] ? put_lock_stats+0xd/0x30
>  [<c04e8704>] shrink_zone+0x204/0x3c0
>  [<c083fcac>] ? _raw_spin_unlock+0x2c/0x50
>  [<c04e951e>] kswapd+0x61e/0x7c0
>  [<c04e6ed0>] ? isolate_pages_global+0x0/0x1f0
>  [<c046bae0>] ? autoremove_wake_function+0x0/0x50
>  [<c04e8f00>] ? kswapd+0x0/0x7c0
>  [<c046b5e4>] kthread+0x74/0x80
>  [<c046b570>] ? kthread+0x0/0x80
>  [<c04035ba>] kernel_thread_helper+0x6/0x10
> 
> Reported-by: Li Zefan <lizf@cn.fujitsu.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> Index: linux-2.6.34-rc5-mm1/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.34-rc5-mm1.orig/mm/memcontrol.c
> +++ linux-2.6.34-rc5-mm1/mm/memcontrol.c
> @@ -2401,7 +2401,9 @@ mem_cgroup_uncharge_swapcache(struct pag
> 
>  	/* record memcg information */
>  	if (do_swap_account && swapout && memcg) {
> +		rcu_read_lock();
>  		swap_cgroup_record(ent, css_id(&memcg->css));
> +		rcu_read_unlock();
>  		mem_cgroup_get(memcg);

Excellent Catch!

Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
