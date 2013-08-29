Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 1ACE06B0037
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 02:03:58 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so7344390pdj.1
        for <linux-mm@kvack.org>; Wed, 28 Aug 2013 23:03:57 -0700 (PDT)
Date: Wed, 28 Aug 2013 23:03:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: store memcg name for oom kill log consistency
Message-ID: <alpine.DEB.2.02.1308282302450.14291@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A shared buffer is currently used for the name of the oom memcg and the
memcg of the killed process.  There is no serialization of memcg oom
kills, so this buffer can easily be overwritten if there is a concurrent
oom kill in another memcg.

This patch stores the names of the memcgs directly in struct mem_cgroup.
This allows it to be printed anytime during the oom kill without fearing
that it will change or become corrupted.  It also ensures that the name
of the memcg that is oom and the memcg of the killed process are the same
even if renamed at the same time.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memcontrol.c | 49 +++++++++++++++++++++++--------------------------
 1 file changed, 23 insertions(+), 26 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -83,6 +83,8 @@ static int really_do_swap_account __initdata = 0;
 #define do_swap_account		0
 #endif
 
+/* First 128 bytes of memcg name should be unique */
+#define MEM_CGROUP_STORE_NAME_LEN	128
 
 static const char * const mem_cgroup_stat_names[] = {
 	"cache",
@@ -247,6 +249,9 @@ struct mem_cgroup {
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
+	/* name of memcg for display purposes only */
+	char		name[MEM_CGROUP_STORE_NAME_LEN];
+
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
 
@@ -1538,27 +1543,22 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
  */
 void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
+	struct mem_cgroup *task_memcg;
+	struct mem_cgroup *iter;
 	struct cgroup *task_cgrp;
 	struct cgroup *mem_cgrp;
-	/*
-	 * Need a buffer in BSS, can't rely on allocations. The code relies
-	 * on the assumption that OOM is serialized for memory controller.
-	 * If this assumption is broken, revisit this code.
-	 */
-	static char memcg_name[PATH_MAX];
 	int ret;
-	struct mem_cgroup *iter;
 	unsigned int i;
 
 	if (!p)
 		return;
 
 	rcu_read_lock();
-
-	mem_cgrp = memcg->css.cgroup;
+	task_memcg = mem_cgroup_from_task(p);
 	task_cgrp = task_cgroup(p, mem_cgroup_subsys_id);
+	mem_cgrp = memcg->css.cgroup;
 
-	ret = cgroup_path(task_cgrp, memcg_name, PATH_MAX);
+	ret = cgroup_path(task_cgrp, task_memcg->name, MEM_CGROUP_STORE_NAME_LEN);
 	if (ret < 0) {
 		/*
 		 * Unfortunately, we are unable to convert to a useful name
@@ -1567,24 +1567,20 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 		rcu_read_unlock();
 		goto done;
 	}
-	rcu_read_unlock();
 
-	pr_info("Task in %s killed", memcg_name);
+	if (task_memcg != memcg) {
+		ret = cgroup_path(mem_cgrp, memcg->name, MEM_CGROUP_STORE_NAME_LEN);
+		if (ret < 0) {
+			rcu_read_unlock();
+			goto done;
+		}
+	} else
+		strncpy(memcg->name, task_memcg->name, MEM_CGROUP_STORE_NAME_LEN);
 
-	rcu_read_lock();
-	ret = cgroup_path(mem_cgrp, memcg_name, PATH_MAX);
-	if (ret < 0) {
-		rcu_read_unlock();
-		goto done;
-	}
+	pr_info("Task in %s killed as a result of limit of %s\n",
+		task_memcg->name, memcg->name);
 	rcu_read_unlock();
-
-	/*
-	 * Continues from above, so we don't need an KERN_ level
-	 */
-	pr_cont(" as a result of limit of %s\n", memcg_name);
 done:
-
 	pr_info("memory: usage %llukB, limit %llukB, failcnt %llu\n",
 		res_counter_read_u64(&memcg->res, RES_USAGE) >> 10,
 		res_counter_read_u64(&memcg->res, RES_LIMIT) >> 10,
@@ -1602,9 +1598,10 @@ done:
 		pr_info("Memory cgroup stats");
 
 		rcu_read_lock();
-		ret = cgroup_path(iter->css.cgroup, memcg_name, PATH_MAX);
+		ret = cgroup_path(iter->css.cgroup, iter->name,
+				  MEM_CGROUP_STORE_NAME_LEN);
 		if (!ret)
-			pr_cont(" for %s", memcg_name);
+			pr_cont(" for %s", iter->name);
 		rcu_read_unlock();
 		pr_cont(":");
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
