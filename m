Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 02C106B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 23:46:39 -0500 (EST)
Date: Thu, 19 Nov 2009 13:30:30 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 4/5] memcg: avoid oom during recharge at task move
Message-Id: <20091119133030.8ef46be0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
References: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This recharge-at-task-move feature has extra charges(pre-charges) on "to"
mem_cgroup during recharging. This means unnecessary oom can happen.

This patch tries to avoid such oom.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index df363da..3a07383 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -249,6 +249,7 @@ struct recharge_struct {
 	struct mem_cgroup *from;
 	struct mem_cgroup *to;
 	unsigned long precharge;
+	struct task_struct *working;	/* a task moving the target task */
 };
 static struct recharge_struct recharge;
 
@@ -1494,6 +1495,30 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		if (mem_cgroup_check_under_limit(mem_over_limit))
 			continue;
 
+		/* try to avoid oom while someone is recharging */
+		if (recharge.working && current != recharge.working) {
+			struct mem_cgroup *dest;
+			bool do_continue = false;
+			/*
+			 * There is a small race that "dest" can be freed by
+			 * rmdir, so we use css_tryget().
+			 */
+			rcu_read_lock();
+			dest = recharge.to;
+			if (dest && css_tryget(&dest->css)) {
+				if (dest->use_hierarchy)
+					do_continue = css_is_ancestor(
+							&dest->css,
+							&mem_over_limit->css);
+				else
+					do_continue = (dest == mem_over_limit);
+				css_put(&dest->css);
+			}
+			rcu_read_unlock();
+			if (do_continue)
+				continue;
+		}
+
 		if (!nr_retries--) {
 			if (oom) {
 				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
@@ -3474,6 +3499,7 @@ static void mem_cgroup_clear_recharge(void)
 	}
 	recharge.from = NULL;
 	recharge.to = NULL;
+	recharge.working = NULL;
 }
 
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
@@ -3498,9 +3524,11 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 			VM_BUG_ON(recharge.from);
 			VM_BUG_ON(recharge.to);
 			VM_BUG_ON(recharge.precharge);
+			VM_BUG_ON(recharge.working);
 			recharge.from = from;
 			recharge.to = mem;
 			recharge.precharge = 0;
+			recharge.working = current;
 
 			ret = mem_cgroup_prepare_recharge(mm);
 			if (ret)
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
