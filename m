Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id CFE3D6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 23:05:47 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] memcg: clean up memcg->nodeinfo
Date: Wed,  5 Jun 2013 23:05:34 -0400
Message-Id: <1370487934-4547-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Remove struct mem_cgroup_lru_info and fold its single member, the
variably sized nodeinfo[0], directly into struct mem_cgroup.  This
should make it more obvious why it has to be the last member there.

Also move the comment that's above that special last member below it,
so it is more visible to somebody that considers appending to the
struct mem_cgroup.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ff7b40d..d169a8d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -187,10 +187,6 @@ struct mem_cgroup_per_node {
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
 };
 
-struct mem_cgroup_lru_info {
-	struct mem_cgroup_per_node *nodeinfo[0];
-};
-
 /*
  * Cgroups above their limits are maintained in a RB-Tree, independent of
  * their hierarchy representation
@@ -384,14 +380,9 @@ struct mem_cgroup {
 #endif
 	/* when kmem shrinkers can sleep but can't proceed due to context */
 	struct work_struct kmemcg_shrink_work;
-	/*
-	 * Per cgroup active and inactive list, similar to the
-	 * per zone LRU lists.
-	 *
-	 * WARNING: This has to be the last element of the struct. Don't
-	 * add new fields after this point.
-	 */
-	struct mem_cgroup_lru_info info;
+
+	struct mem_cgroup_per_node *nodeinfo[0];
+	/* WARNING: nodeinfo has to be the last member here */
 };
 
 static size_t memcg_size(void)
@@ -777,7 +768,7 @@ static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *memcg, int nid, int zid)
 {
 	VM_BUG_ON((unsigned)nid >= nr_node_ids);
-	return &memcg->info.nodeinfo[nid]->zoneinfo[zid];
+	return &memcg->nodeinfo[nid]->zoneinfo[zid];
 }
 
 struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg)
@@ -6595,13 +6586,13 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 		mz->on_tree = false;
 		mz->memcg = memcg;
 	}
-	memcg->info.nodeinfo[node] = pn;
+	memcg->nodeinfo[node] = pn;
 	return 0;
 }
 
 static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
-	kfree(memcg->info.nodeinfo[node]);
+	kfree(memcg->nodeinfo[node]);
 }
 
 static struct mem_cgroup *mem_cgroup_alloc(void)
-- 
1.8.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
