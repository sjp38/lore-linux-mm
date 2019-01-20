Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 385BB8E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 22:31:08 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id e68so10654789plb.3
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 19:31:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 43sor12796381plc.28.2019.01.19.19.31.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 Jan 2019 19:31:06 -0800 (PST)
From: Xiongchun Duan <duanxiongchun@bytedance.com>
Subject: [PATCH 4/5] Memcgroup:Implement force empty work function
Date: Sat, 19 Jan 2019 22:30:20 -0500
Message-Id: <1547955021-11520-5-git-send-email-duanxiongchun@bytedance.com>
In-Reply-To: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
References: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: shy828301@gmail.com, mhocko@kernel.org, tj@kernel.org, hannes@cmpxchg.org, zhangyongsu@bytedance.com, liuxiaozhou@bytedance.com, zhengfeiran@bytedance.com, wangdongdong.6@bytedance.com, Xiongchun Duan <duanxiongchun@bytedance.com>

Implement force empty work function and add trigger by global work.
force_empty_list : offline cgroup wait for trigger force empty.
empty_fail_list: offline cgroup which had been trigger for too
many time will not auto retrigger.

Signed-off-by: Xiongchun Duan <duanxiongchun@bytedance.com>
---
 include/linux/memcontrol.h |  4 +++
 mm/memcontrol.c            | 81 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 85 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0a29f7f..064192e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -315,6 +315,10 @@ struct mem_cgroup {
 	int current_retry;
 	unsigned long timer_jiffies;
 
+	struct list_head force_empty_node;
+	struct list_head empty_fail_node;
+	struct work_struct force_empty_work;
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fad1aae..21b4432 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -86,6 +86,10 @@
 
 struct mem_cgroup *root_mem_cgroup __read_mostly;
 
+static DEFINE_MUTEX(offline_cgroup_mutex);
+static LIST_HEAD(force_empty_list);
+static LIST_HEAD(empty_fail_list);
+
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
 /* Socket memory accounting disabled? */
@@ -2939,9 +2943,52 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
 
 static void add_force_empty_list(struct mem_cgroup *memcg)
 {
+	struct list_head *pos, *n;
+	struct mem_cgroup *pos_memcg;
+	unsigned long tmp = memcg->timer_jiffies;
+
+	mutex_lock(&offline_cgroup_mutex);
+	list_for_each_safe(pos, n, &force_empty_list) {
+		pos_memcg = container_of(pos,
+				struct mem_cgroup, force_empty_node);
+		if	(time_after(tmp, pos_memcg->timer_jiffies))
+			tmp = pos_memcg->timer_jiffies;
+		if (time_after(pos_memcg->timer_jiffies, memcg->timer_jiffies))
+			break;
+	}
+	list_add_tail(&memcg->force_empty_node, pos);
+	mutex_unlock(&offline_cgroup_mutex);
+	mod_timer(&empty_trigger, tmp);
 
 }
 
+static void mem_cgroup_force_empty_delay(struct work_struct *work)
+{
+	unsigned int order;
+	struct mem_cgroup *memcg = container_of(work,
+			struct mem_cgroup, force_empty_work);
+
+	if (page_counter_read(&memcg->memory)) {
+		mem_cgroup_force_empty(memcg);
+		memcg->current_retry += 1;
+		if (page_counter_read(&memcg->memory)) {
+			if (memcg->current_retry >= memcg->max_retry) {
+				if (list_empty(&memcg->empty_fail_node)) {
+					mutex_lock(&offline_cgroup_mutex);
+					list_add(&memcg->empty_fail_node,
+							&empty_fail_list);
+					mutex_unlock(&offline_cgroup_mutex);
+				}
+			} else {
+				order = 1 << (memcg->current_retry - 1);
+				memcg->timer_jiffies = jiffies + HZ * order;
+				add_force_empty_list(memcg);
+			}
+		}
+	}
+	css_put(&memcg->css);
+}
+
 static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
 				     struct cftype *cft)
 {
@@ -4545,6 +4592,9 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_inc(&memcg_sockets_enabled_key);
+
+	INIT_LIST_HEAD(&memcg->force_empty_node);
+	INIT_LIST_HEAD(&memcg->empty_fail_node);
 	memcg->max_retry = sysctl_cgroup_default_retry;
 	memcg->current_retry  = 0;
 
@@ -4577,7 +4627,26 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 
 static void trigger_force_empty(struct work_struct *work)
 {
+	struct list_head *pos, *n;
+	struct mem_cgroup *memcg;
 
+	mutex_lock(&offline_cgroup_mutex);
+	list_for_each_safe(pos, n, &force_empty_list) {
+		memcg = container_of(pos, struct mem_cgroup,
+				force_empty_node);
+		if (time_after(jiffies, memcg->timer_jiffies)) {
+			if (atomic_long_add_unless(&memcg->css.refcnt.count,
+						1, 0) == 0) {
+				continue;
+			} else if (!queue_work(memcg_force_empty_wq,
+						&memcg->force_empty_work)) {
+				css_put(&memcg->css);
+			} else {
+				list_del_init(&memcg->force_empty_node);
+			}
+		}
+	}
+	mutex_unlock(&offline_cgroup_mutex);
 }
 
 static void empty_timer_trigger(struct timer_list *t)
@@ -4595,6 +4664,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 		mem_cgroup_force_empty(memcg);
 		if (page_counter_read(&memcg->memory) &&
 				memcg->max_retry != 1) {
+			INIT_WORK(&memcg->force_empty_work,
+					mem_cgroup_force_empty_delay);
 			memcg->timer_jiffies = jiffies + HZ;
 			add_force_empty_list(memcg);
 		}
@@ -4626,6 +4697,16 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 static void mem_cgroup_css_released(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	if (!list_empty(&memcg->force_empty_node)) {
+		mutex_lock(&offline_cgroup_mutex);
+		list_del_init(&memcg->force_empty_node);
+		mutex_unlock(&offline_cgroup_mutex);
+	}
+	if (!list_empty(&memcg->empty_fail_node)) {
+		mutex_lock(&offline_cgroup_mutex);
+		list_del_init(&memcg->empty_fail_node);
+		mutex_unlock(&offline_cgroup_mutex);
+	}
 
 	invalidate_reclaim_iterators(memcg);
 }
-- 
1.8.3.1
