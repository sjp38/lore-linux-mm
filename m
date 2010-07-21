Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4479C6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 07:05:22 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6LB5Js1012139
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 21 Jul 2010 20:05:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDCA145DE4F
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 20:05:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DF1245DE4E
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 20:05:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 872CF1DB8037
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 20:05:19 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 444931DB803B
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 20:05:16 +0900 (JST)
Date: Wed, 21 Jul 2010 20:00:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/2][memcg] use virt-array for memcg.
Message-Id: <20100721200033.7a8031e5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100721195831.6aa8dca5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100721195831.6aa8dca5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This makes memcg to depend on CONFIG_MMU.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Using virt_array for memcg's node information.
Now, memcg allocates an array of pointer in the lengh of MAXNUMNODES
to hold pointers for per-node information.

This has 2 bad points
  - struct mem_cgroup can be very big.
  - need to access a pointer table for lookup zoneinfo.

This patch replaces memcg's nodeinfo with virt-array and do
direct access. With my config on x86-64, struct mem_cgroup's
size is changed from 4368->352.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 init/Kconfig    |    2 +-
 mm/memcontrol.c |   51 ++++++++++++++++-----------------------------------
 2 files changed, 17 insertions(+), 36 deletions(-)

Index: mmotm-2.6.35-0719/init/Kconfig
===================================================================
--- mmotm-2.6.35-0719.orig/init/Kconfig
+++ mmotm-2.6.35-0719/init/Kconfig
@@ -555,7 +555,7 @@ config RESOURCE_COUNTERS
 
 config CGROUP_MEM_RES_CTLR
 	bool "Memory Resource Controller for Control Groups"
-	depends on CGROUPS && RESOURCE_COUNTERS
+	depends on CGROUPS && RESOURCE_COUNTERS && MMU
 	select MM_OWNER
 	help
 	  Provides a memory resource controller that manages both anonymous
Index: mmotm-2.6.35-0719/mm/memcontrol.c
===================================================================
--- mmotm-2.6.35-0719.orig/mm/memcontrol.c
+++ mmotm-2.6.35-0719/mm/memcontrol.c
@@ -48,6 +48,7 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/virt-array.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -119,11 +120,7 @@ struct mem_cgroup_per_zone {
 
 struct mem_cgroup_per_node {
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
-};
-
-struct mem_cgroup_lru_info {
-	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
-};
+} ____cacheline_aligned_in_smp;
 
 /*
  * Cgroups above their limits are maintained in a RB-Tree, independent of
@@ -205,7 +202,8 @@ struct mem_cgroup {
 	 * Per cgroup active and inactive list, similar to the
 	 * per zone LRU lists.
 	 */
-	struct mem_cgroup_lru_info info;
+	struct mem_cgroup_per_node *nodes;
+	struct virt_array node_array;
 
 	/*
 	  protect against reclaim related member.
@@ -344,7 +342,7 @@ static void drain_all_stock_async(void);
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 {
-	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
+	return &mem->nodes[nid].zoneinfo[zid];
 }
 
 struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
@@ -3944,27 +3942,14 @@ static int register_memsw_files(struct c
 }
 #endif
 
-static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
+static int init_mem_cgroup_node_info(struct mem_cgroup *mem, int node)
 {
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
 	enum lru_list l;
-	int zone, tmp = node;
-	/*
-	 * This routine is called against possible nodes.
-	 * But it's BUG to call kmalloc() against offline node.
-	 *
-	 * TODO: this routine can waste much memory for nodes which will
-	 *       never be onlined. It's better to use memory hotplug callback
-	 *       function.
-	 */
-	if (!node_state(node, N_NORMAL_MEMORY))
-		tmp = -1;
-	pn = kmalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
-	if (!pn)
-		return 1;
+	int zone;
 
-	mem->info.nodeinfo[node] = pn;
+	pn = mem->nodes + node;
 	memset(pn, 0, sizeof(*pn));
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
@@ -3978,11 +3963,6 @@ static int alloc_mem_cgroup_per_zone_inf
 	return 0;
 }
 
-static void free_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
-{
-	kfree(mem->info.nodeinfo[node]);
-}
-
 static struct mem_cgroup *mem_cgroup_alloc(void)
 {
 	struct mem_cgroup *mem;
@@ -4022,13 +4002,10 @@ static struct mem_cgroup *mem_cgroup_all
 
 static void __mem_cgroup_free(struct mem_cgroup *mem)
 {
-	int node;
-
 	mem_cgroup_remove_from_trees(mem);
 	free_css_id(&mem_cgroup_subsys, &mem->css);
 
-	for_each_node_state(node, N_POSSIBLE)
-		free_mem_cgroup_per_zone_info(mem, node);
+	destroy_varray(&mem->node_array);
 
 	free_percpu(mem->stat);
 	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
@@ -4115,10 +4092,14 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (!mem)
 		return ERR_PTR(error);
 
-	for_each_node_state(node, N_POSSIBLE)
-		if (alloc_mem_cgroup_per_zone_info(mem, node))
-			goto free_out;
+	mem->nodes = create_varray(&mem->node_array,
+			sizeof(struct mem_cgroup_per_node), MAX_NUMNODES);
 
+	for_each_node_state(node, N_POSSIBLE) {
+		if (!alloc_varray_item(&mem->node_array, node))
+			goto free_out;
+		init_mem_cgroup_node_info(mem, node);
+	}
 	/* root ? */
 	if (cont->parent == NULL) {
 		int cpu;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
