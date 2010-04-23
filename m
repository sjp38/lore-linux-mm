Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D852D6B01E3
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 00:02:15 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3N42DRm019911
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 23 Apr 2010 13:02:13 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3140A45DE51
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 13:02:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F2A245DE4E
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 13:02:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E7B1C1DB805A
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 13:02:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B5D51DB8040
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 13:02:09 +0900 (JST)
Date: Fri, 23 Apr 2010 12:58:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg rcu lock fix v2
Message-Id: <20100423125814.01e95bce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4BD11A24.2070500@cn.fujitsu.com>
References: <4BD10D59.9090504@cn.fujitsu.com>
	<20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
	<4BD118E2.7080307@cn.fujitsu.com>
	<4BD11A24.2070500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 11:55:16 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> Li Zefan wrote:
> > KAMEZAWA Hiroyuki wrote:
> >> On Fri, 23 Apr 2010 11:00:41 +0800
> >> Li Zefan <lizf@cn.fujitsu.com> wrote:
> >>
> >>> with CONFIG_PROVE_RCU=y, I saw this warning, it's because
> >>> css_id() is not under rcu_read_lock().
> >>>
> >> Ok. Thank you for reporting.
> >> This is ok ? 
> > 
> > Yes, and I did some more simple tests on memcg, no more warning
> > showed up.
> > 
> 
> oops, after trigging oom, I saw 2 more warnings:
> 

Thank you for good testing.
=
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

css_id() should be called under rcu_read_lock().
And css_is_ancestor() should be called under rcu_read_lock().

Following is a report from Li Zefan.
==
===================================================
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
kernel/cgroup.c:4438 invoked rcu_dereference_check() without protection!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 1
1 lock held by kswapd0/31:
 #0:  (swap_lock){+.+.-.}, at: [<c05058bb>] swap_info_get+0x4b/0xd0

stack backtrace:
Pid: 31, comm: kswapd0 Not tainted 2.6.34-rc5-tip+ #13
Call Trace:
 [<c083c5d6>] ? printk+0x1d/0x1f
 [<c0480744>] lockdep_rcu_dereference+0x94/0xb0
 [<c049d6ed>] css_id+0x5d/0x60
 [<c05165a5>] mem_cgroup_uncharge_swapcache+0x45/0xa0
 [<c0505e4f>] swapcache_free+0x3f/0x60
 [<c04e79e2>] __remove_mapping+0xb2/0xf0
 [<c04e7cbb>] shrink_page_list+0x26b/0x490
 [<c047f85d>] ? put_lock_stats+0xd/0x30
 [<c083fd67>] ? _raw_spin_unlock_irq+0x27/0x50
 [<c0482566>] ? trace_hardirqs_on_caller+0xb6/0x220
 [<c04e8158>] shrink_inactive_list+0x278/0x620
 [<c04729e1>] ? sched_clock_cpu+0x121/0x180
 [<c047e9b8>] ? trace_hardirqs_off_caller+0x18/0x130
 [<c047eadb>] ? trace_hardirqs_off+0xb/0x10
 [<c0843438>] ? sub_preempt_count+0x8/0x90
 [<c047f85d>] ? put_lock_stats+0xd/0x30
 [<c04e8704>] shrink_zone+0x204/0x3c0
 [<c083fcac>] ? _raw_spin_unlock+0x2c/0x50
 [<c04e951e>] kswapd+0x61e/0x7c0
 [<c04e6ed0>] ? isolate_pages_global+0x0/0x1f0
 [<c046bae0>] ? autoremove_wake_function+0x0/0x50
 [<c04e8f00>] ? kswapd+0x0/0x7c0
 [<c046b5e4>] kthread+0x74/0x80
 [<c046b570>] ? kthread+0x0/0x80
 [<c04035ba>] kernel_thread_helper+0x6/0x10



Reported-by: Li Zefan <lizf@cn.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

Index: linux-2.6.34-rc5-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.34-rc5-mm1.orig/mm/memcontrol.c
+++ linux-2.6.34-rc5-mm1/mm/memcontrol.c
@@ -838,10 +838,12 @@ int task_in_mem_cgroup(struct task_struc
 	 * enabled in "curr" and "curr" is a child of "mem" in *cgroup*
 	 * hierarchy(even if use_hierarchy is disabled in "mem").
 	 */
+	rcu_read_lock();
 	if (mem->use_hierarchy)
 		ret = css_is_ancestor(&curr->css, &mem->css);
 	else
 		ret = (curr == mem);
+	rcu_read_unlock();
 	css_put(&curr->css);
 	return ret;
 }
@@ -1360,9 +1362,13 @@ static int memcg_oom_wake_function(wait_
 	 * Both of oom_wait_info->mem and wake_mem are stable under us.
 	 * Then we can use css_is_ancestor without taking care of RCU.
 	 */
+	rcu_read_lock();
 	if (!css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css) &&
-	    !css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css))
+	    !css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css)) {
+		rcu_read_unlock();
 		return 0;
+	}
+	rcu_read_unlock();
 
 wakeup:
 	return autoremove_wake_function(wait, mode, sync, arg);
@@ -2401,7 +2407,9 @@ mem_cgroup_uncharge_swapcache(struct pag
 
 	/* record memcg information */
 	if (do_swap_account && swapout && memcg) {
+		rcu_read_lock();
 		swap_cgroup_record(ent, css_id(&memcg->css));
+		rcu_read_unlock();
 		mem_cgroup_get(memcg);
 	}
 	if (swapout && memcg)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
