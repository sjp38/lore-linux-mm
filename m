Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5563E6B00FB
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 15:06:31 -0500 (EST)
Message-Id: <20100105200303.273164182@mini.kroah.org>
Date: Tue, 05 Jan 2010 12:02:29 -0800
From: Greg KH <gregkh@suse.de>
Subject: [33/39] memcg: avoid oom-killing innocent task in case of use_hierarchy
In-Reply-To: <20100105195007.GA23952@kroah.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, stable@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, stable-review@kernel.org, Greg KH <greg@kroah.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

2.6.31-stable review patch.  If anyone has any objections, please let us know.

------------------


From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

commit d31f56dbf8bafaacb0c617f9a6f137498d5c7aed upstream

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
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 mm/memcontrol.c |    8 +++++++-
 mm/oom_kill.c   |    2 +-
 2 files changed, 8 insertions(+), 2 deletions(-)

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -496,7 +496,13 @@ int task_in_mem_cgroup(struct task_struc
 	task_unlock(task);
 	if (!curr)
 		return 0;
-	if (curr->use_hierarchy)
+	/*
+	 * We should check use_hierarchy of "mem" not "curr". Because checking
+	 * use_hierarchy of "curr" here make this function true if hierarchy is
+	 * enabled in "curr" and "curr" is a child of "mem" in *cgroup*
+	 * hierarchy(even if use_hierarchy is disabled in "mem").
+	 */
+	if (mem->use_hierarchy)
 		ret = css_is_ancestor(&curr->css, &mem->css);
 	else
 		ret = (curr == mem);
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -400,7 +400,7 @@ static int oom_kill_process(struct task_
 		cpuset_print_task_mems_allowed(current);
 		task_unlock(current);
 		dump_stack();
-		mem_cgroup_print_oom_info(mem, current);
+		mem_cgroup_print_oom_info(mem, p);
 		show_mem();
 		if (sysctl_oom_dump_tasks)
 			dump_tasks(mem);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
