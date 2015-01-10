Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id E27BE6B006C
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 21:14:11 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so5706441wiw.4
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 18:14:11 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d7si902248wie.99.2015.01.09.18.14.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jan 2015 18:14:11 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] mm: memcontrol: consolidate memory controller initialization
Date: Fri,  9 Jan 2015 21:14:00 -0500
Message-Id: <1420856041-27647-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1420856041-27647-1-git-send-email-hannes@cmpxchg.org>
References: <1420856041-27647-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The initialization code for the per-cpu charge stock and the soft
limit tree is compact enough to inline it into mem_cgroup_init().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 57 ++++++++++++++++++++++++---------------------------------
 1 file changed, 24 insertions(+), 33 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index aad254b30708..f66bb8f83ac9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2137,17 +2137,6 @@ static void drain_local_stock(struct work_struct *dummy)
 	clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
 }
 
-static void __init memcg_stock_init(void)
-{
-	int cpu;
-
-	for_each_possible_cpu(cpu) {
-		struct memcg_stock_pcp *stock =
-					&per_cpu(memcg_stock, cpu);
-		INIT_WORK(&stock->work, drain_local_stock);
-	}
-}
-
 /*
  * Cache charges(val) to local per_cpu area.
  * This will be consumed by consume_stock() function, later.
@@ -4516,26 +4505,6 @@ struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(parent_mem_cgroup);
 
-static void __init mem_cgroup_soft_limit_tree_init(void)
-{
-	struct mem_cgroup_tree_per_node *rtpn;
-	struct mem_cgroup_tree_per_zone *rtpz;
-	int node, zone;
-
-	for_each_node(node) {
-		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, node);
-		BUG_ON(!rtpn);
-
-		soft_limit_tree.rb_tree_per_node[node] = rtpn;
-
-		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
-			rtpz = &rtpn->rb_tree_per_zone[zone];
-			rtpz->rb_root = RB_ROOT;
-			spin_lock_init(&rtpz->lock);
-		}
-	}
-}
-
 static struct cgroup_subsys_state * __ref
 mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
@@ -5927,10 +5896,32 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
  */
 static int __init mem_cgroup_init(void)
 {
+	int cpu, nid;
+
 	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
+
+	for_each_possible_cpu(cpu)
+		INIT_WORK(&per_cpu_ptr(&memcg_stock, cpu)->work,
+			  drain_local_stock);
+
+	for_each_node(nid) {
+		struct mem_cgroup_tree_per_node *rtpn;
+		int zone;
+
+		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, nid);
+
+		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+			struct mem_cgroup_tree_per_zone *rtpz;
+
+			rtpz = &rtpn->rb_tree_per_zone[zone];
+			rtpz->rb_root = RB_ROOT;
+			spin_lock_init(&rtpz->lock);
+		}
+		soft_limit_tree.rb_tree_per_node[nid] = rtpn;
+	}
+
 	enable_swap_cgroup();
-	mem_cgroup_soft_limit_tree_init();
-	memcg_stock_init();
+
 	return 0;
 }
 subsys_initcall(mem_cgroup_init);
-- 
2.2.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
