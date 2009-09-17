Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9046B0055
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:12:49 -0400 (EDT)
Date: Thu, 17 Sep 2009 11:29:17 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH 8/8] memcg: avoid oom during charge migration
Message-Id: <20090917112917.3d766f8c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This charge migration feature has double charges on both "from" and "to" mem_cgroup
during charge migration.
This means unnecessary oom can happen because of charge migration.

This patch tries to avoid such oom.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c8542e7..73da7e7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -288,6 +288,8 @@ struct migrate_charge {
 	struct list_head list;
 };
 static struct migrate_charge *mc;
+static struct task_struct *mc_task;
+static DECLARE_WAIT_QUEUE_HEAD(mc_waitq);
 
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
@@ -1318,6 +1320,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	while (1) {
 		int ret = 0;
 		unsigned long flags = 0;
+		DEFINE_WAIT(wait);
 
 		if (mem_cgroup_is_root(mem))
 			goto done;
@@ -1359,6 +1362,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		if (mem_cgroup_check_under_limit(mem_over_limit))
 			continue;
 
+		/* try to avoid oom while someone is migrating charge */
+		if (current != mc_task) {
+			prepare_to_wait(&mc_waitq, &wait, TASK_INTERRUPTIBLE);
+			if (mc) {
+				schedule();
+				finish_wait(&mc_waitq, &wait);
+				continue;
+			}
+			finish_wait(&mc_waitq, &wait);
+		}
+
 		if (!nr_retries--) {
 			if (oom) {
 				mutex_lock(&memcg_tasklist);
@@ -3432,6 +3446,8 @@ static void mem_cgroup_clear_migrate_charge(void)
 
 	kfree(mc);
 	mc = NULL;
+	mc_task = NULL;
+	wake_up_all(&mc_waitq);
 }
 
 static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
@@ -3441,6 +3457,7 @@ static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
 	struct mem_cgroup *from = mem_cgroup_from_task(p);
 
 	VM_BUG_ON(mc);
+	VM_BUG_ON(mc_task);
 
 	if (from == mem)
 		return 0;
@@ -3453,6 +3470,7 @@ static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
 	mc->from = from;
 	mc->to = mem;
 	INIT_LIST_HEAD(&mc->list);
+	mc_task = current;
 
 	ret = migrate_charge_prepare();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
