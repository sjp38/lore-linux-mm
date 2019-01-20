Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2DE78E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 22:31:03 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 12so10615573plb.18
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 19:31:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x81sor13730162pfk.1.2019.01.19.19.31.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 Jan 2019 19:31:02 -0800 (PST)
From: Xiongchun Duan <duanxiongchun@bytedance.com>
Subject: [PATCH 3/5] Memcgroup:add a global work
Date: Sat, 19 Jan 2019 22:30:19 -0500
Message-Id: <1547955021-11520-4-git-send-email-duanxiongchun@bytedance.com>
In-Reply-To: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
References: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: shy828301@gmail.com, mhocko@kernel.org, tj@kernel.org, hannes@cmpxchg.org, zhangyongsu@bytedance.com, liuxiaozhou@bytedance.com, zhengfeiran@bytedance.com, wangdongdong.6@bytedance.com, Xiongchun Duan <duanxiongchun@bytedance.com>

Add a global work to scan offline cgroup and trigger
offline cgroup force empty.

Signed-off-by: Xiongchun Duan <duanxiongchun@bytedance.com>
---
 mm/memcontrol.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4db08b7..fad1aae 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -82,6 +82,7 @@
 int sysctl_cgroup_default_retry_max = 16;
 
 struct timer_list empty_trigger;
+struct work_struct timer_poll_work;
 
 struct mem_cgroup *root_mem_cgroup __read_mostly;
 
@@ -320,6 +321,7 @@ void memcg_put_cache_ids(void)
 EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
 struct workqueue_struct *memcg_kmem_cache_wq;
+struct workqueue_struct *memcg_force_empty_wq;
 
 static int memcg_shrinker_map_size;
 static DEFINE_MUTEX(memcg_shrinker_map_mutex);
@@ -4573,11 +4575,16 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	return 0;
 }
 
-void empty_timer_trigger(struct timer_list *t)
+static void trigger_force_empty(struct work_struct *work)
 {
 
 }
 
+static void empty_timer_trigger(struct timer_list *t)
+{
+	queue_work(memcg_force_empty_wq, &timer_poll_work);
+}
+
 static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
@@ -6390,6 +6397,9 @@ static int __init mem_cgroup_init(void)
 	memcg_kmem_cache_wq = alloc_workqueue("memcg_kmem_cache", 0, 1);
 	BUG_ON(!memcg_kmem_cache_wq);
 #endif
+	memcg_force_empty_wq = alloc_workqueue("memcg_force_empty_wq", 0, 1);
+	BUG_ON(!memcg_force_empty_wq);
+	INIT_WORK(&timer_poll_work, trigger_force_empty);
 	timer_setup(&empty_trigger, empty_timer_trigger, 0);
 
 	cpuhp_setup_state_nocalls(CPUHP_MM_MEMCQ_DEAD, "mm/memctrl:dead", NULL,
-- 
1.8.3.1
