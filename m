Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A56115F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 02:27:12 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id n137R4s0012700
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 12:57:04 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n137R9ua4018240
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 12:57:09 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n137R39i025698
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 18:27:04 +1100
Date: Tue, 3 Feb 2009 12:57:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM (v2)
Message-ID: <20090203072701.GV918@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090203072013.GU918@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090203072013.GU918@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Checkpatch caught an additional space, so here is the patch again


Description: Add RSS and swap to OOM output from memcg

From: Balbir Singh <balbir@linux.vnet.ibm.com>

Changelog v2..v1:

1. Add more information about task's memcg and the memcg
   over it's limit
2. Print data in KB
3. Move the print routine outside task_lock()
4. Use rcu_read_lock() around cgroup_path, strictly speaking it
   is not required, but relying on the current memcg implementation
   is not a good idea.


This patch displays memcg values like failcnt, usage and limit
when an OOM occurs due to memcg.

Thanks go out to Johannes Weiner, Li Zefan, David Rientjes,
Kamezawa Hiroyuki, Daisuke Nishimura and KOSAKI Motohiro for
review.

Sample output
-------------

Task in /a/x killed as a result of limit of /a
memory: usage 1048576kB, limit 1048576kB, failcnt 4183
memory+swap: usage 1400964kB, limit 9007199254740991kB, failcnt 0

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h |    6 ++++
 mm/memcontrol.c            |   61 ++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill.c              |    1 +
 3 files changed, 68 insertions(+), 0 deletions(-)


diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 326f45c..56f1af2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -104,6 +104,8 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone);
 struct zone_reclaim_stat*
 mem_cgroup_get_reclaim_stat_from_page(struct page *page);
+extern void mem_cgroup_print_mem_info(struct mem_cgroup *memcg,
+					struct task_struct *p);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
@@ -270,6 +272,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	return NULL;
 }
 
+void mem_cgroup_print_mem_info(struct mem_cgroup *memcg, struct task_struct *p)
+{
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8e4be9c..ee3bae4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -42,6 +42,7 @@
 
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
+#define MEM_CGROUP_OOM_BUF_SIZE		128
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 /* Turned on only when memory cgroup is enabled && really_do_swap_account = 0 */
@@ -813,6 +814,66 @@ bool mem_cgroup_oom_called(struct task_struct *task)
 	rcu_read_unlock();
 	return ret;
 }
+
+/**
+ * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in
+ * read mode.
+ * @memcg: The memory cgroup that went over limit
+ * @p: Task that is going to be killed
+ *
+ * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
+ * enabled
+ */
+void mem_cgroup_print_mem_info(struct mem_cgroup *memcg, struct task_struct *p)
+{
+	struct cgroup *task_cgrp;
+	struct cgroup *mem_cgrp;
+	/*
+	 * Need a buffer on stack, can't rely on allocations.
+	 */
+	char task_memcg_name[MEM_CGROUP_OOM_BUF_SIZE];
+	char memcg_name[MEM_CGROUP_OOM_BUF_SIZE];
+	int ret;
+
+	if (!memcg)
+		return;
+
+	mem_cgrp = memcg->css.cgroup;
+	task_cgrp = mem_cgroup_from_task(p)->css.cgroup;
+
+	rcu_read_lock();
+	ret = cgroup_path(task_cgrp, task_memcg_name, MEM_CGROUP_OOM_BUF_SIZE);
+	if (ret < 0) {
+		/*
+		 * Unfortunately, we are unable to convert to a useful name
+		 * But we'll still print out the usage information
+		 */
+		rcu_read_unlock();
+		goto done;
+	}
+	ret = cgroup_path(mem_cgrp, memcg_name, MEM_CGROUP_OOM_BUF_SIZE);
+	 if (ret < 0) {
+		rcu_read_unlock();
+		goto done;
+	}
+
+	rcu_read_unlock();
+
+	printk(KERN_INFO "Task in %s killed as a result of limit of %s\n",
+			task_memcg_name, memcg_name);
+done:
+
+	printk(KERN_INFO "memory: usage %llukB, limit %llukB, failcnt %llu\n",
+		res_counter_read_u64(&memcg->res, RES_USAGE) >> 10,
+		res_counter_read_u64(&memcg->res, RES_LIMIT) >> 10,
+		res_counter_read_u64(&memcg->res, RES_FAILCNT));
+	printk(KERN_INFO "memory+swap: usage %llukB, limit %llukB, "
+		"failcnt %llu\n",
+		res_counter_read_u64(&memcg->memsw, RES_USAGE) >> 10,
+		res_counter_read_u64(&memcg->memsw, RES_LIMIT) >> 10,
+		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
+}
+
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d3b9bac..951356f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -394,6 +394,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		cpuset_print_task_mems_allowed(current);
 		task_unlock(current);
 		dump_stack();
+		mem_cgroup_print_mem_info(mem, current);
 		show_mem();
 		if (sysctl_oom_dump_tasks)
 			dump_tasks(mem);

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
