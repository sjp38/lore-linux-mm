Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CAE398E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 22:30:59 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o17so11613463pgi.14
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 19:30:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k11sor12726020pll.39.2019.01.19.19.30.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 Jan 2019 19:30:58 -0800 (PST)
From: Xiongchun Duan <duanxiongchun@bytedance.com>
Subject: [PATCH 2/5] Memcgroup: Add timer to trigger workqueue
Date: Sat, 19 Jan 2019 22:30:18 -0500
Message-Id: <1547955021-11520-3-git-send-email-duanxiongchun@bytedance.com>
In-Reply-To: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
References: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: shy828301@gmail.com, mhocko@kernel.org, tj@kernel.org, hannes@cmpxchg.org, zhangyongsu@bytedance.com, liuxiaozhou@bytedance.com, zhengfeiran@bytedance.com, wangdongdong.6@bytedance.com, Xiongchun Duan <duanxiongchun@bytedance.com>

Add timer to trigger workqueue which will scan offline memcgroup and call trigger
memcgroup force_empty worker to force_empty itself.

Signed-off-by: Xiongchun Duan <duanxiongchun@bytedance.com>
---
 include/linux/memcontrol.h |  1 +
 mm/memcontrol.c            | 23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d6fbb77..0a29f7f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -313,6 +313,7 @@ struct mem_cgroup {
 
 	int max_retry;
 	int current_retry;
+	unsigned long timer_jiffies;
 
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2b13c2b..4db08b7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -81,6 +81,8 @@
 int sysctl_cgroup_default_retry_min;
 int sysctl_cgroup_default_retry_max = 16;
 
+struct timer_list empty_trigger;
+
 struct mem_cgroup *root_mem_cgroup __read_mostly;
 
 #define MEM_CGROUP_RECLAIM_RETRIES	5
@@ -2933,6 +2935,11 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
 	return mem_cgroup_force_empty(memcg) ?: nbytes;
 }
 
+static void add_force_empty_list(struct mem_cgroup *memcg)
+{
+
+}
+
 static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
 				     struct cftype *cft)
 {
@@ -4566,11 +4573,26 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	return 0;
 }
 
+void empty_timer_trigger(struct timer_list *t)
+{
+
+}
+
 static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_event *event, *tmp;
 
+	if (memcg->max_retry != 0) {
+		memcg->current_retry = 1;
+		mem_cgroup_force_empty(memcg);
+		if (page_counter_read(&memcg->memory) &&
+				memcg->max_retry != 1) {
+			memcg->timer_jiffies = jiffies + HZ;
+			add_force_empty_list(memcg);
+		}
+	}
+
 	/*
 	 * Unregister events and notify userspace.
 	 * Notify userspace about cgroup removing only after rmdir of cgroup
@@ -6368,6 +6390,7 @@ static int __init mem_cgroup_init(void)
 	memcg_kmem_cache_wq = alloc_workqueue("memcg_kmem_cache", 0, 1);
 	BUG_ON(!memcg_kmem_cache_wq);
 #endif
+	timer_setup(&empty_trigger, empty_timer_trigger, 0);
 
 	cpuhp_setup_state_nocalls(CPUHP_MM_MEMCQ_DEAD, "mm/memctrl:dead", NULL,
 				  memcg_hotplug_cpu_dead);
-- 
1.8.3.1
