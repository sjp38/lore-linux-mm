Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3112D6B00AB
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 01:00:47 -0400 (EDT)
Date: Tue, 13 Oct 2009 13:53:53 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH 4/8] memcg: add interface to recharge at task move
Message-Id: <20091013135353.0be05136.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
References: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

In current memcg, charges associated with a task aren't moved to the new cgroup
at task move. These patches are for this feature, that is, for recharging to
the new cgroup and, of course, uncharging from old cgroup at task move.

This patch adds "memory.recharge_at_immigrate" file, which is a flag file to
determine whether charges should be moved to the new cgroup at task move or
not, and read/write handlers of the file.
This patch also adds no-op handlers for this feature. These handlers will be
implemented in later patche.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   65 +++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 59 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7084cb1..66206cc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -185,6 +185,12 @@ struct mem_cgroup {
 	bool		memsw_is_minimum;
 
 	/*
+	 * Should we recharge charges of a task when a task is moved into this
+	 * mem_cgroup ?
+	 */
+	bool	 	recharge_at_immigrate;
+
+	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
 	struct mem_cgroup_stat stat;
@@ -2885,6 +2891,30 @@ static int mem_cgroup_reset(struct cgroup *cgroup, unsigned int event)
 	return 0;
 }
 
+static u64 mem_cgroup_recharge_read(struct cgroup *cgrp,
+					struct cftype *cft)
+{
+	return mem_cgroup_from_cgroup(cgrp)->recharge_at_immigrate;
+}
+
+static int mem_cgroup_recharge_write(struct cgroup *cgrp,
+					struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cgrp);
+
+	if (val != 0 && val != 1)
+		return -EINVAL;
+	/*
+	 * We check this value both in can_attach() and attach(), so we need
+	 * cgroup lock to prevent this value from being inconsistent.
+	 */
+	cgroup_lock();
+	mem->recharge_at_immigrate = val;
+	cgroup_unlock();
+
+	return 0;
+}
+
 
 /* For read statistics */
 enum {
@@ -3118,6 +3148,11 @@ static struct cftype mem_cgroup_files[] = {
 		.read_u64 = mem_cgroup_swappiness_read,
 		.write_u64 = mem_cgroup_swappiness_write,
 	},
+	{
+		.name = "recharge_at_immigrate",
+		.read_u64 = mem_cgroup_recharge_read,
+		.write_u64 = mem_cgroup_recharge_write,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -3359,6 +3394,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgroup)
 	if (parent)
 		mem->swappiness = get_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
+	mem->recharge_at_immigrate = 0;
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
@@ -3395,13 +3431,26 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 	return ret;
 }
 
+/* Handlers for recharge at task move. */
+static int mem_cgroup_can_recharge(struct mem_cgroup *mem,
+					struct task_struct *p)
+{
+	return 0;
+}
+
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
 				struct task_struct *p,
 				bool threadgroup)
 {
-	mutex_lock(&memcg_tasklist);
-	return 0;
+	int ret = 0;
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cgroup);
+
+	if (mem->recharge_at_immigrate && thread_group_leader(p))
+		ret = mem_cgroup_can_recharge(mem, p);
+	if (!ret)
+		mutex_lock(&memcg_tasklist);
+	return ret;
 }
 
 static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
@@ -3412,17 +3461,21 @@ static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
 	mutex_unlock(&memcg_tasklist);
 }
 
+static void mem_cgroup_recharge(void)
+{
+}
+
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
 				struct cgroup *old_cgroup,
 				struct task_struct *p,
 				bool threadgroup)
 {
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cgroup);
+
 	mutex_unlock(&memcg_tasklist);
-	/*
-	 * FIXME: It's better to move charges of this process from old
-	 * memcg to new memcg. But it's just on TODO-List now.
-	 */
+	if (mem->recharge_at_immigrate && thread_group_leader(p))
+		mem_cgroup_recharge();
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
