Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 58BB96B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 00:48:33 -0500 (EST)
Date: Mon, 21 Dec 2009 14:37:09 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 6/8] memcg: avoid oom during moving charge
Message-Id: <20091221143709.112c7fad.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This move-charge-at-task-migration feature has extra charges on "to"(pre-charges)
and "from"(left-over charges) during moving charge. This means unnecessary oom
can happen.

This patch tries to avoid such oom.

Changelog: 2009/12/21
- minor cleanup.
Changelog: 2009/12/14
- instead of continuing to charge by busy loop, make use of waitq.
Changelog: 2009/12/04
- take account of "from" too, because we uncharge from "from" at once in
  mem_cgroup_clear_mc(), so left-over charges exist during moving charge.
- check use_hierarchy of "mem_over_limit", instead of "to" or "from"(bugfix).

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   54 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 86e3202..ddb3c6c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -253,8 +253,13 @@ struct move_charge_struct {
 	struct mem_cgroup *to;
 	unsigned long precharge;
 	unsigned long moved_charge;
+	struct task_struct *moving_task;	/* a task moving charges */
+	wait_queue_head_t waitq;		/* a waitq for other context */
+						/* not to cause oom */
+};
+static struct move_charge_struct mc = {
+	.waitq = __WAIT_QUEUE_HEAD_INITIALIZER(mc.waitq),
 };
-static struct move_charge_struct mc;
 
 
 /*
@@ -1509,6 +1514,48 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		if (mem_cgroup_check_under_limit(mem_over_limit))
 			continue;
 
+		/* try to avoid oom while someone is moving charge */
+		if (mc.moving_task && current != mc.moving_task) {
+			struct mem_cgroup *from, *to;
+			bool do_continue = false;
+			/*
+			 * There is a small race that "from" or "to" can be
+			 * freed by rmdir, so we use css_tryget().
+			 */
+			rcu_read_lock();
+			from = mc.from;
+			to = mc.to;
+			if (from && css_tryget(&from->css)) {
+				if (mem_over_limit->use_hierarchy)
+					do_continue = css_is_ancestor(
+							&from->css,
+							&mem_over_limit->css);
+				else
+					do_continue = (from == mem_over_limit);
+				css_put(&from->css);
+			}
+			if (!do_continue && to && css_tryget(&to->css)) {
+				if (mem_over_limit->use_hierarchy)
+					do_continue = css_is_ancestor(
+							&to->css,
+							&mem_over_limit->css);
+				else
+					do_continue = (to == mem_over_limit);
+				css_put(&to->css);
+			}
+			rcu_read_unlock();
+			if (do_continue) {
+				DEFINE_WAIT(wait);
+				prepare_to_wait(&mc.waitq, &wait,
+							TASK_INTERRUPTIBLE);
+				/* moving charge context might have finished. */
+				if (mc.moving_task)
+					schedule();
+				finish_wait(&mc.waitq, &wait);
+				continue;
+			}
+		}
+
 		if (!nr_retries--) {
 			if (oom) {
 				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
@@ -3385,7 +3432,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 			INIT_WORK(&stock->work, drain_local_stock);
 		}
 		hotcpu_notifier(memcg_stock_cpu_callback, 0);
-
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
@@ -3645,6 +3691,8 @@ static void mem_cgroup_clear_mc(void)
 	}
 	mc.from = NULL;
 	mc.to = NULL;
+	mc.moving_task = NULL;
+	wake_up_all(&mc.waitq);
 }
 
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
@@ -3670,10 +3718,12 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 			VM_BUG_ON(mc.to);
 			VM_BUG_ON(mc.precharge);
 			VM_BUG_ON(mc.moved_charge);
+			VM_BUG_ON(mc.moving_task);
 			mc.from = from;
 			mc.to = mem;
 			mc.precharge = 0;
 			mc.moved_charge = 0;
+			mc.moving_task = current;
 
 			ret = mem_cgroup_precharge_mc(mm);
 			if (ret)
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
