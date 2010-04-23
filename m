Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4E46E6B01EF
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:18:26 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3N3IOnt017745
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 23 Apr 2010 12:18:24 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B857D45DE53
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:18:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8557E45DE51
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:18:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 539721DB8043
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:18:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EDDD21DB8038
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:18:22 +0900 (JST)
Date: Fri, 23 Apr 2010 12:14:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg rcu lock fix in swap code (Was Re: [BUG] an
 RCU warning in memcg
Message-Id: <20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4BD10D59.9090504@cn.fujitsu.com>
References: <4BD10D59.9090504@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 11:00:41 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> with CONFIG_PROVE_RCU=y, I saw this warning, it's because
> css_id() is not under rcu_read_lock().
> 

Ok. Thank you for reporting.
This is ok ? 
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

css_id() should be called under rcu_read_lock().
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
 mm/memcontrol.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6.34-rc5-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.34-rc5-mm1.orig/mm/memcontrol.c
+++ linux-2.6.34-rc5-mm1/mm/memcontrol.c
@@ -2401,7 +2401,9 @@ mem_cgroup_uncharge_swapcache(struct pag
 
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
