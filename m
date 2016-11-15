Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EAC26B02E8
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 18:45:22 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so69261589pfx.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:45:22 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id r21si28696194pgg.64.2016.11.15.15.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 15:45:21 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id e9so12618740pgc.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:45:21 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [RESEND] [PATCH v1 2/3] Move from all possible nodes to online nodes
Date: Wed, 16 Nov 2016 10:45:00 +1100
Message-Id: <1479253501-26261-3-git-send-email-bsingharora@gmail.com>
In-Reply-To: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
References: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Move routines that do operations on all nodes to
just the online nodes. Most of the changes are
very obvious (like the ones related to soft limit tree
per node)

Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org> 
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 mm/memcontrol.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5585fce..cc49fa2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -497,7 +497,7 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
 	struct mem_cgroup_per_node *mz;
 	int nid;
 
-	for_each_node(nid) {
+	for_each_online_node(nid) {
 		mz = mem_cgroup_nodeinfo(memcg, nid);
 		mctz = soft_limit_tree_node(nid);
 		mem_cgroup_remove_exceeded(mz, mctz);
@@ -895,7 +895,7 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 	int i;
 
 	while ((memcg = parent_mem_cgroup(memcg))) {
-		for_each_node(nid) {
+		for_each_online_node(nid) {
 			mz = mem_cgroup_nodeinfo(memcg, nid);
 			for (i = 0; i <= DEF_PRIORITY; i++) {
 				iter = &mz->iter[i];
@@ -4146,7 +4146,7 @@ static void mem_cgroup_free(struct mem_cgroup *memcg)
 	int node;
 
 	memcg_wb_domain_exit(memcg);
-	for_each_node(node)
+	for_each_online_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->stat);
 	kfree(memcg);
@@ -4175,7 +4175,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (!memcg->stat)
 		goto fail;
 
-	for_each_node(node)
+	for_each_online_node(node)
 		if (alloc_mem_cgroup_per_node_info(memcg, node))
 			goto fail;
 
@@ -5774,11 +5774,21 @@ __setup("cgroup.memory=", cgroup_memory);
 static void memcg_node_offline(int node)
 {
 	struct mem_cgroup *memcg;
+	struct mem_cgroup_tree_per_node *rtpn;
+	struct mem_cgroup_tree_per_node *mctz;
+	struct mem_cgroup_per_node *mz;
 
 	if (node < 0)
 		return;
 
+	rtpn = soft_limit_tree.rb_tree_per_node[node];
+	kfree(rtpn);
+
 	for_each_mem_cgroup(memcg) {
+		mz = mem_cgroup_nodeinfo(memcg, node);
+		mctz = soft_limit_tree_node(node);
+		mem_cgroup_remove_exceeded(mz, mctz);
+
 		free_mem_cgroup_per_node_info(memcg, node);
 		mem_cgroup_may_update_nodemask(memcg);
 	}
@@ -5787,10 +5797,18 @@ static void memcg_node_offline(int node)
 static void memcg_node_online(int node)
 {
 	struct mem_cgroup *memcg;
+	struct mem_cgroup_tree_per_node *rtpn;
 
 	if (node < 0)
 		return;
 
+	rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
+			    node_online(node) ? node : NUMA_NO_NODE);
+
+	rtpn->rb_root = RB_ROOT;
+	spin_lock_init(&rtpn->lock);
+	soft_limit_tree.rb_tree_per_node[node] = rtpn;
+
 	for_each_mem_cgroup(memcg) {
 		alloc_mem_cgroup_per_node_info(memcg, node);
 		mem_cgroup_may_update_nodemask(memcg);
@@ -5854,7 +5872,7 @@ static int __init mem_cgroup_init(void)
 		INIT_WORK(&per_cpu_ptr(&memcg_stock, cpu)->work,
 			  drain_local_stock);
 
-	for_each_node(node) {
+	for_each_online_node(node) {
 		struct mem_cgroup_tree_per_node *rtpn;
 
 		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
