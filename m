Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B27C6B0261
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:37:19 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e9so4883715pgc.5
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 20:37:19 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id h63si31811517pge.110.2016.11.22.20.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 20:37:18 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 144so132071pfv.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 20:37:18 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [mm v2 2/3] mm: Move operations to hotplug callbacks
Date: Wed, 23 Nov 2016 15:36:53 +1100
Message-Id: <1479875814-11938-3-git-send-email-bsingharora@gmail.com>
In-Reply-To: <1479875814-11938-1-git-send-email-bsingharora@gmail.com>
References: <1479875814-11938-1-git-send-email-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org
Cc: Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

Move routines that do operations on all nodes to
just the online nodes. Most of the changes are
very obvious (like the ones related to soft limit tree
per node)

Implications of this patch

1. get/put_online_mems around for_each_online_node
   paths. These are expected to be !fast path
2. Memory allocation/free is on demand. On a system
   with large number of cgroups we expect savings
   proportional to number of cgroups * size of per node
   structure(s)

Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 mm/memcontrol.c | 83 +++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 75 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5482c7d..cdfc3e8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -497,11 +497,13 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
 	struct mem_cgroup_per_node *mz;
 	int nid;
 
-	for_each_node(nid) {
+	get_online_mems();
+	for_each_online_node(nid) {
 		mz = mem_cgroup_nodeinfo(memcg, nid);
 		mctz = soft_limit_tree_node(nid);
 		mem_cgroup_remove_exceeded(mz, mctz);
 	}
+	put_online_mems();
 }
 
 static struct mem_cgroup_per_node *
@@ -895,7 +897,8 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 	int i;
 
 	while ((memcg = parent_mem_cgroup(memcg))) {
-		for_each_node(nid) {
+		get_online_mems();
+		for_each_online_node(nid) {
 			mz = mem_cgroup_nodeinfo(memcg, nid);
 			for (i = 0; i <= DEF_PRIORITY; i++) {
 				iter = &mz->iter[i];
@@ -903,6 +906,7 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 					dead_memcg, NULL);
 			}
 		}
+		put_online_mems();
 	}
 }
 
@@ -1343,6 +1347,10 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
 {
 	return 0;
 }
+
+static void mem_cgroup_may_update_nodemask(struct mem_cgroup *memcg)
+{
+}
 #endif
 
 static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
@@ -4133,8 +4141,10 @@ static void mem_cgroup_free(struct mem_cgroup *memcg)
 	int node;
 
 	memcg_wb_domain_exit(memcg);
-	for_each_node(node)
+	get_online_mems();
+	for_each_online_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
+	put_online_mems();
 	free_percpu(memcg->stat);
 	kfree(memcg);
 }
@@ -4162,9 +4172,11 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (!memcg->stat)
 		goto fail;
 
-	for_each_node(node)
+	get_online_mems();
+	for_each_online_node(node)
 		if (alloc_mem_cgroup_per_node_info(memcg, node))
 			goto fail;
+	put_online_mems();
 
 	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
 		goto fail;
@@ -4187,6 +4199,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return memcg;
 fail:
+	put_online_mems();
 	if (memcg->id.id > 0)
 		idr_remove(&mem_cgroup_idr, memcg->id.id);
 	mem_cgroup_free(memcg);
@@ -5760,10 +5773,61 @@ __setup("cgroup.memory=", cgroup_memory);
 
 static void memcg_node_offline(int node)
 {
+	struct mem_cgroup *memcg;
+	struct mem_cgroup_tree_per_node *rtpn;
+	struct mem_cgroup_per_node *mz;
+
+	if (node < 0)
+		return;
+
+	rtpn = soft_limit_tree_node(node);
+
+	for_each_mem_cgroup(memcg) {
+		mz = mem_cgroup_nodeinfo(memcg, node);
+		/* mz can be NULL if node_online failed */
+		if (mz)
+			mem_cgroup_remove_exceeded(mz, rtpn);
+
+		free_mem_cgroup_per_node_info(memcg, node);
+		mem_cgroup_may_update_nodemask(memcg);
+	}
+
+	kfree(rtpn);
+
 }
 
-static void memcg_node_online(int node)
+static int memcg_node_online(int node)
 {
+	struct mem_cgroup *memcg;
+	struct mem_cgroup_tree_per_node *rtpn;
+	struct mem_cgroup_per_node *mz;
+
+	if (node < 0)
+		return 0;
+
+	rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, node);
+
+	rtpn->rb_root = RB_ROOT;
+	spin_lock_init(&rtpn->lock);
+	soft_limit_tree.rb_tree_per_node[node] = rtpn;
+
+	for_each_mem_cgroup(memcg) {
+		if (alloc_mem_cgroup_per_node_info(memcg, node))
+			goto fail;
+		mem_cgroup_may_update_nodemask(memcg);
+	}
+	return 0;
+fail:
+	/*
+	 * We don't want mz in node_offline to trip when
+	 * allocation fails and CANCEL_ONLINE gets called
+	 */
+	for_each_mem_cgroup(memcg) {
+		mz = mem_cgroup_nodeinfo(memcg, node);
+		free_mem_cgroup_per_node_info(memcg, node);
+		mz = NULL;
+	}
+	return -ENOMEM;
 }
 
 static int memcg_memory_hotplug_callback(struct notifier_block *self,
@@ -5773,12 +5837,13 @@ static int memcg_memory_hotplug_callback(struct notifier_block *self,
 	int node = marg->status_change_nid;
 
 	switch (action) {
-	case MEM_GOING_OFFLINE:
 	case MEM_CANCEL_OFFLINE:
+	case MEM_GOING_OFFLINE:
 	case MEM_ONLINE:
 		break;
 	case MEM_GOING_ONLINE:
-		memcg_node_online(node);
+		if (memcg_node_online(node))
+			return NOTIFY_BAD;
 		break;
 	case MEM_CANCEL_ONLINE:
 	case MEM_OFFLINE:
@@ -5824,7 +5889,8 @@ static int __init mem_cgroup_init(void)
 		INIT_WORK(&per_cpu_ptr(&memcg_stock, cpu)->work,
 			  drain_local_stock);
 
-	for_each_node(node) {
+	get_online_mems();
+	for_each_online_node(node) {
 		struct mem_cgroup_tree_per_node *rtpn;
 
 		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
@@ -5834,6 +5900,7 @@ static int __init mem_cgroup_init(void)
 		spin_lock_init(&rtpn->lock);
 		soft_limit_tree.rb_tree_per_node[node] = rtpn;
 	}
+	put_online_mems();
 
 	return 0;
 }
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
