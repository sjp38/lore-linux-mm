Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA5B6B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 00:33:28 -0500 (EST)
Date: Fri, 6 Nov 2009 14:15:32 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 7/8] memcg: avoid oom during recharge at task move
Message-Id: <20091106141532.a2fe1187.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
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
 mm/memcontrol.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f4b7116..7e96f3b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -248,6 +248,7 @@ struct recharge_struct {
 	struct mem_cgroup *from;
 	struct mem_cgroup *to;
 	struct task_struct *target;	/* the target task being moved */
+	struct task_struct *working;	/* a task moving the target task */
 	unsigned long precharge;
 };
 static struct recharge_struct recharge;
@@ -1493,6 +1494,30 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
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
 				mutex_lock(&memcg_tasklist);
@@ -3573,6 +3598,7 @@ static void mem_cgroup_clear_recharge(void)
 	recharge.from = NULL;
 	recharge.to = NULL;
 	recharge.target = NULL;
+	recharge.working = NULL;
 }
 
 static int mem_cgroup_can_recharge(struct mem_cgroup *mem,
@@ -3587,6 +3613,7 @@ static int mem_cgroup_can_recharge(struct mem_cgroup *mem,
 	recharge.from = from;
 	recharge.to = mem;
 	recharge.target = p;
+	recharge.working = current;
 	recharge.precharge = 0;
 
 	ret = mem_cgroup_recharge_prepare();
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
