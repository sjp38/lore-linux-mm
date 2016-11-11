Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 584A728027E
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 19:39:07 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id rf5so2714139pab.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 16:39:07 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id m5si7327385pgj.182.2016.11.10.16.39.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 16:39:06 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id n85so231356pfi.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 16:39:06 -0800 (PST)
Subject: [RFC][PATCH] Add infrastructure for memcg hotplug support
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <e6b24a40-89c5-84e8-d10a-abc498ee4a3a@gmail.com>
Date: Fri, 11 Nov 2016 11:39:01 +1100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>


The lack of hotplug support makes us allocate all memory
upfront for per node data structures. With large number
of cgroups this can be an overhead. PPC64 actually limits
n_possible nodes to n_online to avoid some of this overhead.

This patch adds the basic notifiers to listen to hotplug
events and does the allocation and free of those structures
per cgroup. We walk every cgroup per event, its a trade-off
of allocating upfront vs allocating on demand and freeing
on offline.

Most of the changes are very obvious (like the ones related to
soft limit tree per node) and allocation/free of per node
structures.

Tested on a configuration with movable node and a deep cgroup
hierarchy with online/offline tests from sysfs.

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 mm/memcontrol.c | 92 +++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 79 insertions(+), 13 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 91dfc7c..b98f02b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -63,6 +63,7 @@
 #include <linux/lockdep.h>
 #include <linux/file.h>
 #include <linux/tracehook.h>
+#include <linux/memory.h>
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
@@ -496,7 +497,7 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
 	struct mem_cgroup_per_node *mz;
 	int nid;
 
-	for_each_node(nid) {
+	for_each_online_node(nid) {
 		mz = mem_cgroup_nodeinfo(memcg, nid);
 		mctz = soft_limit_tree_node(nid);
 		mem_cgroup_remove_exceeded(mz, mctz);
@@ -894,7 +895,7 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 	int i;
 
 	while ((memcg = parent_mem_cgroup(memcg))) {
-		for_each_node(nid) {
+		for_each_online_node(nid) {
 			mz = mem_cgroup_nodeinfo(memcg, nid);
 			for (i = 0; i <= DEF_PRIORITY; i++) {
 				iter = &mz->iter[i];
@@ -4115,14 +4116,7 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 {
 	struct mem_cgroup_per_node *pn;
 	int tmp = node;
-	/*
-	 * This routine is called against possible nodes.
-	 * But it's BUG to call kmalloc() against offline node.
-	 *
-	 * TODO: this routine can waste much memory for nodes which will
-	 *       never be onlined. It's better to use memory hotplug callback
-	 *       function.
-	 */
+
 	if (!node_state(node, N_NORMAL_MEMORY))
 		tmp = -1;
 	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
@@ -4148,7 +4142,7 @@ static void mem_cgroup_free(struct mem_cgroup *memcg)
 	int node;
 
 	memcg_wb_domain_exit(memcg);
-	for_each_node(node)
+	for_each_online_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->stat);
 	kfree(memcg);
@@ -4177,7 +4171,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (!memcg->stat)
 		goto fail;
 
-	for_each_node(node)
+	for_each_online_node(node)
 		if (alloc_mem_cgroup_per_node_info(memcg, node))
 			goto fail;
 
@@ -5773,6 +5767,77 @@ static int __init cgroup_memory(char *s)
 }
 __setup("cgroup.memory=", cgroup_memory);
 
+static void memcg_node_offline(int node)
+{
+	struct mem_cgroup *memcg;
+	struct mem_cgroup_tree_per_node *rtpn;
+	struct mem_cgroup_tree_per_node *mctz;
+	struct mem_cgroup_per_node *mz;
+
+	if (node < 0)
+		return;
+
+	rtpn = soft_limit_tree.rb_tree_per_node[node];
+	kfree(rtpn);
+
+	for_each_mem_cgroup(memcg) {
+		mz = mem_cgroup_nodeinfo(memcg, node);
+		mctz = soft_limit_tree_node(node);
+		mem_cgroup_remove_exceeded(mz, mctz);
+
+		free_mem_cgroup_per_node_info(memcg, node);
+		mem_cgroup_may_update_nodemask(memcg);
+	}
+}
+
+static void memcg_node_online(int node)
+{
+	struct mem_cgroup *memcg;
+	struct mem_cgroup_tree_per_node *rtpn;
+
+	if (node < 0)
+		return;
+
+	rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
+			    node_online(node) ? node : NUMA_NO_NODE);
+
+	rtpn->rb_root = RB_ROOT;
+	spin_lock_init(&rtpn->lock);
+	soft_limit_tree.rb_tree_per_node[node] = rtpn;
+
+	for_each_mem_cgroup(memcg) {
+		alloc_mem_cgroup_per_node_info(memcg, node);
+		mem_cgroup_may_update_nodemask(memcg);
+	}
+}
+
+static int memcg_memory_hotplug_callback(struct notifier_block *self,
+					unsigned long action, void *arg)
+{
+	struct memory_notify *marg = arg;
+	int node = marg->status_change_nid;
+
+	switch (action) {
+	case MEM_GOING_OFFLINE:
+	case MEM_CANCEL_ONLINE:
+		memcg_node_offline(node);
+		break;
+	case MEM_GOING_ONLINE:
+	case MEM_CANCEL_OFFLINE:
+		memcg_node_online(node);
+		break;
+	case MEM_ONLINE:
+	case MEM_OFFLINE:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block memcg_memory_hotplug_nb __meminitdata = {
+	.notifier_call = memcg_memory_hotplug_callback,
+	.priority = IPC_CALLBACK_PRI,
+};
+
 /*
  * subsys_initcall() for memory controller.
  *
@@ -5797,12 +5862,13 @@ static int __init mem_cgroup_init(void)
 #endif
 
 	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
+	register_hotmemory_notifier(&memcg_memory_hotplug_nb);
 
 	for_each_possible_cpu(cpu)
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
