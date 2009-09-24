Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB2A6B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 01:51:18 -0400 (EDT)
Date: Thu, 24 Sep 2009 14:47:18 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH 4/8] memcg: add interface to migrate charge
Message-Id: <20090924144718.d779ed0e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds "memory.migrate_charge" file and handlers of it.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 61 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7e8874d..30499d9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -225,6 +225,8 @@ struct mem_cgroup {
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
 
+	bool	 	migrate_charge;
+
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -2843,6 +2845,27 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
+static u64 mem_cgroup_migrate_charge_read(struct cgroup *cgrp,
+					struct cftype *cft)
+{
+	return mem_cgroup_from_cont(cgrp)->migrate_charge;
+}
+
+static int mem_cgroup_migrate_charge_write(struct cgroup *cgrp,
+					struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+
+	if (val != 0 && val != 1)
+		return -EINVAL;
+
+	cgroup_lock();
+	mem->migrate_charge = val;
+	cgroup_unlock();
+
+	return 0;
+}
+
 
 static struct cftype mem_cgroup_files[] = {
 	{
@@ -2892,6 +2915,11 @@ static struct cftype mem_cgroup_files[] = {
 		.read_u64 = mem_cgroup_swappiness_read,
 		.write_u64 = mem_cgroup_swappiness_write,
 	},
+	{
+		.name = "migrate_charge",
+		.read_u64 = mem_cgroup_migrate_charge_read,
+		.write_u64 = mem_cgroup_migrate_charge_write,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -3132,6 +3160,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	if (parent)
 		mem->swappiness = get_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
+	mem->migrate_charge = 0;
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
@@ -3168,6 +3197,35 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 	return ret;
 }
 
+static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
+					struct task_struct *p)
+{
+	return 0;
+}
+
+static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
+				struct cgroup *cont,
+				struct task_struct *p,
+				bool threadgroup)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+
+	if (mem->migrate_charge && thread_group_leader(p))
+		return mem_cgroup_can_migrate_charge(mem, p);
+	return 0;
+}
+
+static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
+				struct cgroup *cont,
+				struct task_struct *p,
+				bool threadgroup)
+{
+}
+
+static void mem_cgroup_migrate_charge(void)
+{
+}
+
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *cont,
 				struct cgroup *old_cont,
@@ -3175,10 +3233,7 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				bool threadgroup)
 {
 	mutex_lock(&memcg_tasklist);
-	/*
-	 * FIXME: It's better to move charges of this process from old
-	 * memcg to new memcg. But it's just on TODO-List now.
-	 */
+	mem_cgroup_migrate_charge();
 	mutex_unlock(&memcg_tasklist);
 }
 
@@ -3189,6 +3244,8 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.pre_destroy = mem_cgroup_pre_destroy,
 	.destroy = mem_cgroup_destroy,
 	.populate = mem_cgroup_populate,
+	.can_attach = mem_cgroup_can_attach,
+	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
 	.early_init = 0,
 	.use_id = 1,
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
