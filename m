Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 9A5126B0008
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 11:24:15 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 2/3] memcg: move memcg_stock initialization to mem_cgroup_init
Date: Tue,  5 Feb 2013 17:24:00 +0100
Message-Id: <1360081441-1960-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1360081441-1960-1-git-send-email-mhocko@suse.cz>
References: <1360081441-1960-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>

memcg_stock are currently initialized during the root cgroup allocation
which is OK but it pointlessly pollutes memcg allocation code with
something that can be called when the memcg subsystem is initialized by
mem_cgroup_init along with other controller specific parts.

This patch wrappes the current memcg_stock initialization code into a
helper calls it from the controller subsystem initialization code.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b0d3339..e9c1690 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2362,6 +2362,17 @@ static void drain_local_stock(struct work_struct *dummy)
 	clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
 }
 
+static void __init memcg_stock_init(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct memcg_stock_pcp *stock =
+					&per_cpu(memcg_stock, cpu);
+		INIT_WORK(&stock->work, drain_local_stock);
+	}
+}
+
 /*
  * Cache charges(val) which is from res_counter, to local per_cpu area.
  * This will be consumed by consume_stock() function, later.
@@ -6268,15 +6279,7 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 
 	/* root ? */
 	if (cont->parent == NULL) {
-		int cpu;
-
 		root_mem_cgroup = memcg;
-		for_each_possible_cpu(cpu) {
-			struct memcg_stock_pcp *stock =
-						&per_cpu(memcg_stock, cpu);
-			INIT_WORK(&stock->work, drain_local_stock);
-		}
-
 		res_counter_init(&memcg->res, NULL);
 		res_counter_init(&memcg->memsw, NULL);
 		res_counter_init(&memcg->kmem, NULL);
@@ -7014,6 +7017,7 @@ static int __init mem_cgroup_init(void)
 	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
 	enable_swap_cgroup();
 	mem_cgroup_soft_limit_tree_init();
+	memcg_stock_init();
 	return 0;
 }
 subsys_initcall(mem_cgroup_init);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
