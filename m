Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BF43D6B0062
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 00:30:45 -0500 (EST)
Date: Fri, 6 Nov 2009 14:11:49 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 2/8] memcg: move memcg_tasklist mutex
Message-Id: <20091106141149.9c7e94d5.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

memcg_tasklist was introduced to serialize mem_cgroup_out_of_memory() and
mem_cgroup_move_task() to ensure tasks cannot be moved to another cgroup
during select_bad_process().

task_in_mem_cgroup(), which can be called by select_bad_process(), will check
whether a task is in the mem_cgroup or not by dereferencing task->cgroups
->subsys[]. So, it would be desirable to change task->cgroups
(rcu_assign_pointer() in cgroup_attach_task() does it) with memcg_tasklist held.

Now that we can define cancel_attach(), we can safely release memcg_tasklist
on fail path even if we hold memcg_tasklist in can_attach(). So let's move
mutex_lock/unlock() of memcg_tasklist.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4bd3451..d3b2ac0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3395,18 +3395,34 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 	return ret;
 }
 
+static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
+				struct cgroup *cgroup,
+				struct task_struct *p,
+				bool threadgroup)
+{
+	mutex_lock(&memcg_tasklist);
+	return 0;
+}
+
+static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
+				struct cgroup *cgroup,
+				struct task_struct *p,
+				bool threadgroup)
+{
+	mutex_unlock(&memcg_tasklist);
+}
+
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *cont,
 				struct cgroup *old_cont,
 				struct task_struct *p,
 				bool threadgroup)
 {
-	mutex_lock(&memcg_tasklist);
+	mutex_unlock(&memcg_tasklist);
 	/*
 	 * FIXME: It's better to move charges of this process from old
 	 * memcg to new memcg. But it's just on TODO-List now.
 	 */
-	mutex_unlock(&memcg_tasklist);
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
@@ -3416,6 +3432,8 @@ struct cgroup_subsys mem_cgroup_subsys = {
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
