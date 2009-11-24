Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 25F7F6B008C
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 00:59:58 -0500 (EST)
Date: Tue, 24 Nov 2009 14:57:59 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [BUGFIX][PATCH -mmotm] memcg: avoid oom-killing innocent task in
 case of use_hierarchy
Message-Id: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, stable <stable@kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

task_in_mem_cgroup(), which is called by select_bad_process() to check whether
a task can be a candidate for being oom-killed from memcg's limit, checks
"curr->use_hierarchy"("curr" is the mem_cgroup the task belongs to).

But this check return true(it's false positive) when:

	<some path>/00		use_hierarchy == 0	<- hitting limit
	  <some path>/00/aa	use_hierarchy == 1	<- "curr"

This leads to killing an innocent task in 00/aa. This patch is a fix for this
bug. And this patch also fixes the arg for mem_cgroup_print_oom_info(). We
should print information of mem_cgroup which the task being killed, not current,
belongs to.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
The bug exists and should be fixed in 2.6.31.y too.
I'll post a patch for -stable later.

 mm/memcontrol.c |    4 ++--
 mm/oom_kill.c   |   13 +++++++------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ea00a93..d02f9f8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -783,7 +783,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 	task_unlock(task);
 	if (!curr)
 		return 0;
-	if (curr->use_hierarchy)
+	if (mem->use_hierarchy)
 		ret = css_is_ancestor(&curr->css, &mem->css);
 	else
 		ret = (curr == mem);
@@ -1032,7 +1032,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	static char memcg_name[PATH_MAX];
 	int ret;
 
-	if (!memcg)
+	if (!memcg || !p)
 		return;
 
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ab04537..be56461 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -356,7 +356,8 @@ static void dump_tasks(const struct mem_cgroup *mem)
 	} while_each_thread(g, p);
 }
 
-static void dump_header(gfp_t gfp_mask, int order, struct mem_cgroup *mem)
+static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
+							struct mem_cgroup *mem)
 {
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
 		"oom_adj=%d\n",
@@ -365,7 +366,7 @@ static void dump_header(gfp_t gfp_mask, int order, struct mem_cgroup *mem)
 	cpuset_print_task_mems_allowed(current);
 	task_unlock(current);
 	dump_stack();
-	mem_cgroup_print_oom_info(mem, current);
+	mem_cgroup_print_oom_info(mem, p);
 	show_mem();
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(mem);
@@ -440,7 +441,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	struct task_struct *c;
 
 	if (printk_ratelimit())
-		dump_header(gfp_mask, order, mem);
+		dump_header(p, gfp_mask, order, mem);
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -576,7 +577,7 @@ retry:
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
 		read_unlock(&tasklist_lock);
-		dump_header(gfp_mask, order, NULL);
+		dump_header(NULL, gfp_mask, order, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
 
@@ -644,7 +645,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		return;
 
 	if (sysctl_panic_on_oom == 2) {
-		dump_header(gfp_mask, order, NULL);
+		dump_header(NULL, gfp_mask, order, NULL);
 		panic("out of memory. Compulsory panic_on_oom is selected.\n");
 	}
 
@@ -663,7 +664,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 
 	case CONSTRAINT_NONE:
 		if (sysctl_panic_on_oom) {
-			dump_header(gfp_mask, order, NULL);
+			dump_header(NULL, gfp_mask, order, NULL);
 			panic("out of memory. panic_on_oom is selected\n");
 		}
 		/* Fall-through */
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
