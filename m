Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B0CA46B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 01:28:17 -0500 (EST)
Date: Mon, 14 Dec 2009 15:24:43 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 6/8] memcg: avoid oom during moving charge
Message-Id: <20091214152443.05871e9c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
References: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This move-charge-at-task-migration feature has extra charges on "to"(pre-charges)
and "from"(left-over charges) during moving charge. This means unnecessary oom
can happen.

This patch tries to avoid such oom.

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
index 8d86a20..9c8719a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -253,6 +253,9 @@ struct move_charge_struct {
 	struct mem_cgroup *to;
 	unsigned long precharge;
 	unsigned long moved_charge;
+	struct task_struct *moving_task;	/* a task moving charges */
+	wait_queue_head_t waitq;		/* a waitq for other context */
+						/* not to cause oom */
 };
 static struct move_charge_struct mc;
 
@@ -1509,6 +1512,48 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
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
@@ -3385,7 +3430,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 			INIT_WORK(&stock->work, drain_local_stock);
 		}
 		hotcpu_notifier(memcg_stock_cpu_callback, 0);
-
+		mc.waitq = (wait_queue_head_t)
+					__WAIT_QUEUE_HEAD_INITIALIZER(mc.waitq);
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
@@ -3670,9 +3718,11 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 			VM_BUG_ON(mc.to);
 			VM_BUG_ON(mc.precharge);
 			VM_BUG_ON(mc.moved_charge);
+			VM_BUG_ON(mc.moving_task);
 			mc = (struct move_charge_struct) {
 				.from = from, .to = mem, .precharge = 0,
-				.moved_charge = 0
+				.moved_charge = 0,
+				.moving_task = current, .waitq = mc.waitq
 			};
 
 			ret = mem_cgroup_precharge_mc(mm);
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
