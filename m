Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 956AC6B0008
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 11:24:14 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/3] memcg: move mem_cgroup_soft_limit_tree_init to mem_cgroup_init
Date: Tue,  5 Feb 2013 17:23:59 +0100
Message-Id: <1360081441-1960-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1360081441-1960-1-git-send-email-mhocko@suse.cz>
References: <1360081441-1960-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>

Per-node-zone soft limit tree is currently initialized when the root
cgroup is created which is OK but it pointlessly pollutes memcg
allocation code with something that can be called when the memcg
subsystem is initialized by mem_cgroup_init along with other controller
specific parts.

While we are at it let's make mem_cgroup_soft_limit_tree_init void
because it doesn't make much sense to report memory failure because if
we fail to allocate memory that early during the boot then we are
screwed anyway (this saves some code).

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2382fe9..b0d3339 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6228,7 +6228,7 @@ struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(parent_mem_cgroup);
 
-static int mem_cgroup_soft_limit_tree_init(void)
+static void __init mem_cgroup_soft_limit_tree_init(void)
 {
 	struct mem_cgroup_tree_per_node *rtpn;
 	struct mem_cgroup_tree_per_zone *rtpz;
@@ -6239,8 +6239,7 @@ static int mem_cgroup_soft_limit_tree_init(void)
 		if (!node_state(node, N_NORMAL_MEMORY))
 			tmp = -1;
 		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
-		if (!rtpn)
-			goto err_cleanup;
+		BUG_ON(!rtpn);
 
 		soft_limit_tree.rb_tree_per_node[node] = rtpn;
 
@@ -6250,17 +6249,6 @@ static int mem_cgroup_soft_limit_tree_init(void)
 			spin_lock_init(&rtpz->lock);
 		}
 	}
-	return 0;
-
-err_cleanup:
-	for_each_node(node) {
-		if (!soft_limit_tree.rb_tree_per_node[node])
-			break;
-		kfree(soft_limit_tree.rb_tree_per_node[node]);
-		soft_limit_tree.rb_tree_per_node[node] = NULL;
-	}
-	return 1;
-
 }
 
 static struct cgroup_subsys_state * __ref
@@ -6282,8 +6270,6 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 	if (cont->parent == NULL) {
 		int cpu;
 
-		if (mem_cgroup_soft_limit_tree_init())
-			goto free_out;
 		root_mem_cgroup = memcg;
 		for_each_possible_cpu(cpu) {
 			struct memcg_stock_pcp *stock =
@@ -7027,6 +7013,7 @@ static int __init mem_cgroup_init(void)
 {
 	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
 	enable_swap_cgroup();
+	mem_cgroup_soft_limit_tree_init();
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
