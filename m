Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 628D96B0078
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 05:59:18 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8R9x891024034
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Sep 2010 18:59:09 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9278945DE4D
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:59:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 708B445DE6E
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:59:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D4F8EF8006
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:59:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3BE01DB803B
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:59:07 +0900 (JST)
Date: Mon, 27 Sep 2010 18:54:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/4] memcg: reduce size of mem_cgroup by removing
 per-node info array
Message-Id: <20100927185400.030ee71a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100927184821.f4bf2b2c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100924181302.7d764e0d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100927184821.f4bf2b2c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, memcgroup's per-zone structure is looked up as

	mem->info.nodeinfo[nid]->zoneinfo[zid]

1st. This nodeinfo is array of pointers of MAX_NUMNODES size. This makes
sizeof struct mem_cgroup very large and struct mem_cgroup will be allocated on
vmalloc() area because the size is larger than PAGE_SIZE.
(This will never be fixed even when nodehotplug is supported.)

2nd. Now, page_cgroup->mem_cgroup is an ID. Then, we need 2 level lookup up
to accesss per-zone structure as

	mem = css_lookup(pc->mem_cgroup);
	mz = mem->info.nodeinfo[nid]->zoneinfo[zid]

This look up seems wasteful. This patch removes mem->info and moves all per-zone
memcg onto radix-tree. mem_cgroup_per_zone structure can be found by

	radix_tree_lookup(&memcg_lrus, id_func(memcg, nid, zid)).

This makes memcg small (4440 bytes => 344bytes) and  combine 2 lookup into one.

Following patch will add memory hotplug support.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   86 +++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 57 insertions(+), 29 deletions(-)

Index: mmotm-0922/mm/memcontrol.c
===================================================================
--- mmotm-0922.orig/mm/memcontrol.c
+++ mmotm-0922/mm/memcontrol.c
@@ -122,13 +122,16 @@ struct mem_cgroup_per_zone {
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
 
-struct mem_cgroup_per_node {
-	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
-};
+RADIX_TREE(memcg_lrus, GFP_KERNEL);
+DEFINE_SPINLOCK(memcg_lrutable_lock);
 
-struct mem_cgroup_lru_info {
-	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
-};
+static inline long node_zone_idx(int memcg, int node, int zone) {
+	unsigned long id;
+
+	id = ((node) << ZONES_SHIFT | (zone)) << 16;
+	id |= memcg;
+	return id;
+}
 
 /*
  * Cgroups above their limits are maintained in a RB-Tree, independent of
@@ -206,11 +209,6 @@ struct mem_cgroup {
 	 * the counter to account for mem+swap usage.
 	 */
 	struct res_counter memsw;
-	/*
-	 * Per cgroup active and inactive list, similar to the
-	 * per zone LRU lists.
-	 */
-	struct mem_cgroup_lru_info info;
 
 	/*
 	  protect against reclaim related member.
@@ -388,9 +386,14 @@ static struct mem_cgroup *memcg_lookup(u
 }
 
 static struct mem_cgroup_per_zone *
-mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
+mem_cgroup_zoneinfo(int memcgid, int nid, int zid)
 {
-	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
+	struct mem_cgroup_per_zone *mz;
+
+	rcu_read_lock();
+	mz = radix_tree_lookup(&memcg_lrus, node_zone_idx(memcgid, nid, zid));
+	rcu_read_unlock();
+	return mz;
 }
 
 struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
@@ -401,14 +404,13 @@ struct cgroup_subsys_state *mem_cgroup_c
 static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {
-	struct mem_cgroup *mem = memcg_lookup(pc->mem_cgroup);
 	int nid = page_cgroup_nid(pc);
 	int zid = page_cgroup_zid(pc);
 
-	if (!mem)
+	if (!pc->mem_cgroup)
 		return NULL;
 
-	return mem_cgroup_zoneinfo(mem, nid, zid);
+	return mem_cgroup_zoneinfo(pc->mem_cgroup, nid, zid);
 }
 
 static struct mem_cgroup_tree_per_zone *
@@ -496,7 +498,7 @@ static void mem_cgroup_update_tree(struc
 	 * because their event counter is not touched.
 	 */
 	for (; mem; mem = parent_mem_cgroup(mem)) {
-		mz = mem_cgroup_zoneinfo(mem, nid, zid);
+		mz = mem_cgroup_zoneinfo(css_id(&mem->css), nid, zid);
 		excess = res_counter_soft_limit_excess(&mem->res);
 		/*
 		 * We have to update the tree if mz is on RB-tree or
@@ -525,7 +527,7 @@ static void mem_cgroup_remove_from_trees
 
 	for_each_node_state(node, N_POSSIBLE) {
 		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
-			mz = mem_cgroup_zoneinfo(mem, node, zone);
+			mz = mem_cgroup_zoneinfo(css_id(&mem->css), node, zone);
 			mctz = soft_limit_tree_node_zone(node, zone);
 			mem_cgroup_remove_exceeded(mem, mz, mctz);
 		}
@@ -658,7 +660,7 @@ static unsigned long mem_cgroup_get_loca
 
 	for_each_online_node(nid)
 		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-			mz = mem_cgroup_zoneinfo(mem, nid, zid);
+			mz = mem_cgroup_zoneinfo(css_id(&mem->css), nid, zid);
 			total += MEM_CGROUP_ZSTAT(mz, idx);
 		}
 	return total;
@@ -1039,7 +1041,9 @@ unsigned long mem_cgroup_zone_nr_pages(s
 {
 	int nid = zone_to_nid(zone);
 	int zid = zone_idx(zone);
-	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+	struct mem_cgroup_per_zone *mz;
+
+	mz = mem_cgroup_zoneinfo(css_id(&memcg->css), nid, zid);
 
 	return MEM_CGROUP_ZSTAT(mz, lru);
 }
@@ -1049,7 +1053,9 @@ struct zone_reclaim_stat *mem_cgroup_get
 {
 	int nid = zone_to_nid(zone);
 	int zid = zone_idx(zone);
-	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+	struct mem_cgroup_per_zone *mz;
+
+	mz = mem_cgroup_zoneinfo(css_id(&memcg->css), nid, zid);
 
 	return &mz->reclaim_stat;
 }
@@ -1099,7 +1105,7 @@ unsigned long mem_cgroup_isolate_pages(u
 	int ret;
 
 	BUG_ON(!mem_cont);
-	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
+	mz = mem_cgroup_zoneinfo(css_id(&mem_cont->css), nid, zid);
 	src = &mz->lists[lru];
 
 	scan = 0;
@@ -3179,7 +3185,7 @@ static int mem_cgroup_force_empty_list(s
 	int ret = 0;
 
 	zone = &NODE_DATA(node)->node_zones[zid];
-	mz = mem_cgroup_zoneinfo(mem, node, zid);
+	mz = mem_cgroup_zoneinfo(css_id(&mem->css), node, zid);
 	list = &mz->lists[lru];
 
 	loop = MEM_CGROUP_ZSTAT(mz, lru);
@@ -3676,7 +3682,8 @@ static int mem_control_stat_show(struct 
 
 		for_each_online_node(nid)
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-				mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
+				mz = mem_cgroup_zoneinfo(
+					css_id(&mem_cont->css), nid, zid);
 
 				recent_rotated[0] +=
 					mz->reclaim_stat.recent_rotated[0];
@@ -4173,10 +4180,9 @@ static int register_memsw_files(struct c
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 {
-	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
 	enum lru_list l;
-	int zone, tmp = node;
+	int id, zone, ret, tmp = node;
 	/*
 	 * This routine is called against possible nodes.
 	 * But it's BUG to call kmalloc() against offline node.
@@ -4187,27 +4193,51 @@ static int alloc_mem_cgroup_per_zone_inf
 	 */
 	if (!node_state(node, N_NORMAL_MEMORY))
 		tmp = -1;
-	pn = kmalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
-	if (!pn)
-		return 1;
-
-	mem->info.nodeinfo[node] = pn;
-	memset(pn, 0, sizeof(*pn));
-
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
-		mz = &pn->zoneinfo[zone];
+		mz = kzalloc_node(sizeof(struct mem_cgroup_per_zone),
+					GFP_KERNEL, tmp);
+		if (!mz)
+			break;
+		radix_tree_preload(GFP_KERNEL);
+		spin_lock_irq(&memcg_lrutable_lock);
+		id = node_zone_idx(css_id(&mem->css), node, zone);
+		ret = radix_tree_insert(&memcg_lrus, id, mz);
+		spin_unlock_irq(&memcg_lrutable_lock);
+		if (ret)
+			break;
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lists[l]);
-		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->mem = mem;
 	}
-	return 0;
+	
+	if (zone == MAX_NR_ZONES)
+		return 0;
+
+	for (; zone >= 0; zone--) {
+		id = node_zone_idx(css_id(&mem->css), node, zone);
+		spin_lock_irq(&memcg_lrutable_lock);
+		mz = radix_tree_delete(&memcg_lrus, id);
+		spin_unlock_irq(&memcg_lrutable_lock);
+		kfree(mz);
+	}
+
+	return 1;
 }
 
 static void free_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 {
-	kfree(mem->info.nodeinfo[node]);
+	int id, zone;
+	struct mem_cgroup_per_zone *mz;
+	unsigned long flags;
+
+	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+		id = node_zone_idx(css_id(&mem->css), node, zone);
+		spin_lock_irqsave(&memcg_lrutable_lock, flags);
+		mz = radix_tree_delete(&memcg_lrus, id);
+		spin_unlock_irqrestore(&memcg_lrutable_lock, flags);
+		kfree(mz);
+	}
 }
 
 static struct mem_cgroup *mem_cgroup_alloc(void)
@@ -4234,6 +4264,7 @@ static struct mem_cgroup *mem_cgroup_all
 		mem = NULL;
 	}
 	spin_lock_init(&mem->pcp_counter_lock);
+
 	return mem;
 }
 
@@ -4343,13 +4374,14 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (!mem)
 		return ERR_PTR(error);
 
+	error = alloc_css_id(ss, cont, &mem->css);
+	if (error)
+		goto free_out;
+
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
 			goto free_out;
 
-	error = alloc_css_id(ss, cont, &mem->css);
-	if (error)
-		goto free_out;
 	/* Here, css_id(&mem->css) works. but css_lookup(id)->mem doesn't */
 
 	/* root ? */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
