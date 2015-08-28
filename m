Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 41A4A6B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 11:25:37 -0400 (EDT)
Received: by ykba134 with SMTP id a134so5670894ykb.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 08:25:37 -0700 (PDT)
Received: from mail-yk0-x232.google.com (mail-yk0-x232.google.com. [2607:f8b0:4002:c07::232])
        by mx.google.com with ESMTPS id l127si3646333ywd.127.2015.08.28.08.25.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 08:25:36 -0700 (PDT)
Received: by ykay144 with SMTP id y144so3325272yka.2
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 08:25:35 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/4] memcg: flatten task_struct->memcg_oom
Date: Fri, 28 Aug 2015 11:25:28 -0400
Message-Id: <1440775530-18630-3-git-send-email-tj@kernel.org>
In-Reply-To: <1440775530-18630-1-git-send-email-tj@kernel.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

task_struct->memcg_oom is a sub-struct containing fields which are
used for async memcg oom handling.  Most task_struct fields aren't
packaged this way and it can lead to unnecessary alignment paddings.
This patch flattens it.

* task.memcg_oom.memcg		-> task.memcg_in_oom
* task.memcg_oom.gfp_mask	-> task.memcg_oom_gfp_mask
* task.memcg_oom.order		-> task.memcg_oom_order
* task.memcg_oom.may_oom	-> task.memcg_may_oom

In addition, task.memcg_may_oom is relocated to where other bitfields
are which reduces the size of task_struct.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h | 10 +++++-----
 include/linux/sched.h      | 13 ++++++-------
 mm/memcontrol.c            | 16 ++++++++--------
 3 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ad800e6..3d28656 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -407,19 +407,19 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 
 static inline void mem_cgroup_oom_enable(void)
 {
-	WARN_ON(current->memcg_oom.may_oom);
-	current->memcg_oom.may_oom = 1;
+	WARN_ON(current->memcg_may_oom);
+	current->memcg_may_oom = 1;
 }
 
 static inline void mem_cgroup_oom_disable(void)
 {
-	WARN_ON(!current->memcg_oom.may_oom);
-	current->memcg_oom.may_oom = 0;
+	WARN_ON(!current->memcg_may_oom);
+	current->memcg_may_oom = 0;
 }
 
 static inline bool task_in_memcg_oom(struct task_struct *p)
 {
-	return p->memcg_oom.memcg;
+	return p->memcg_in_oom;
 }
 
 bool mem_cgroup_oom_synchronize(bool wait);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a4ab9da..ef73b54 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1451,7 +1451,9 @@ struct task_struct {
 	unsigned sched_reset_on_fork:1;
 	unsigned sched_contributes_to_load:1;
 	unsigned sched_migrated:1;
-
+#ifdef CONFIG_MEMCG
+	unsigned memcg_may_oom:1;
+#endif
 #ifdef CONFIG_MEMCG_KMEM
 	unsigned memcg_kmem_skip_account:1;
 #endif
@@ -1782,12 +1784,9 @@ struct task_struct {
 	unsigned long trace_recursion;
 #endif /* CONFIG_TRACING */
 #ifdef CONFIG_MEMCG
-	struct memcg_oom_info {
-		struct mem_cgroup *memcg;
-		gfp_t gfp_mask;
-		int order;
-		unsigned int may_oom:1;
-	} memcg_oom;
+	struct mem_cgroup *memcg_in_oom;
+	gfp_t memcg_oom_gfp_mask;
+	int memcg_oom_order;
 #endif
 #ifdef CONFIG_UPROBES
 	struct uprobe_task *utask;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 18ecf75..74abb31 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1652,7 +1652,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 
 static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
-	if (!current->memcg_oom.may_oom)
+	if (!current->memcg_may_oom)
 		return;
 	/*
 	 * We are in the middle of the charge context here, so we
@@ -1669,9 +1669,9 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 	 * and when we know whether the fault was overall successful.
 	 */
 	css_get(&memcg->css);
-	current->memcg_oom.memcg = memcg;
-	current->memcg_oom.gfp_mask = mask;
-	current->memcg_oom.order = order;
+	current->memcg_in_oom = memcg;
+	current->memcg_oom_gfp_mask = mask;
+	current->memcg_oom_order = order;
 }
 
 /**
@@ -1693,7 +1693,7 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
  */
 bool mem_cgroup_oom_synchronize(bool handle)
 {
-	struct mem_cgroup *memcg = current->memcg_oom.memcg;
+	struct mem_cgroup *memcg = current->memcg_in_oom;
 	struct oom_wait_info owait;
 	bool locked;
 
@@ -1721,8 +1721,8 @@ bool mem_cgroup_oom_synchronize(bool handle)
 	if (locked && !memcg->oom_kill_disable) {
 		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
-		mem_cgroup_out_of_memory(memcg, current->memcg_oom.gfp_mask,
-					 current->memcg_oom.order);
+		mem_cgroup_out_of_memory(memcg, current->memcg_oom_gfp_mask,
+					 current->memcg_oom_order);
 	} else {
 		schedule();
 		mem_cgroup_unmark_under_oom(memcg);
@@ -1739,7 +1739,7 @@ bool mem_cgroup_oom_synchronize(bool handle)
 		memcg_oom_recover(memcg);
 	}
 cleanup:
-	current->memcg_oom.memcg = NULL;
+	current->memcg_in_oom = NULL;
 	css_put(&memcg->css);
 	return true;
 }
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
