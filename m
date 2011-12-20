Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 49B246B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 04:59:00 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 1/3] memcg: cleanup for_each_node_state()
Date: Tue, 20 Dec 2011 18:01:52 +0800
Message-ID: <1324375312-31252-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org, Bob Liu <lliubbo@gmail.com>

We already have for_each_node(node) define in nodemask.h, better to use it.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/memcontrol.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6a417fe..a3d0420 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -570,7 +570,7 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
 	struct mem_cgroup_per_zone *mz;
 	struct mem_cgroup_tree_per_zone *mctz;
 
-	for_each_node_state(node, N_POSSIBLE) {
+	for_each_node(node) {
 		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 			mz = mem_cgroup_zoneinfo(memcg, node, zone);
 			mctz = soft_limit_tree_node_zone(node, zone);
@@ -4972,7 +4972,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	mem_cgroup_remove_from_trees(memcg);
 	free_css_id(&mem_cgroup_subsys, &memcg->css);
 
-	for_each_node_state(node, N_POSSIBLE)
+	for_each_node(node)
 		free_mem_cgroup_per_zone_info(memcg, node);
 
 	free_percpu(memcg->stat);
@@ -5031,7 +5031,7 @@ static int mem_cgroup_soft_limit_tree_init(void)
 	struct mem_cgroup_tree_per_zone *rtpz;
 	int tmp, node, zone;
 
-	for_each_node_state(node, N_POSSIBLE) {
+	for_each_node(node) {
 		tmp = node;
 		if (!node_state(node, N_NORMAL_MEMORY))
 			tmp = -1;
@@ -5050,7 +5050,7 @@ static int mem_cgroup_soft_limit_tree_init(void)
 	return 0;
 
 err_cleanup:
-	for_each_node_state(node, N_POSSIBLE) {
+	for_each_node(node) {
 		if (!soft_limit_tree.rb_tree_per_node[node])
 			break;
 		kfree(soft_limit_tree.rb_tree_per_node[node]);
@@ -5071,7 +5071,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	if (!memcg)
 		return ERR_PTR(error);
 
-	for_each_node_state(node, N_POSSIBLE)
+	for_each_node(node)
 		if (alloc_mem_cgroup_per_zone_info(memcg, node))
 			goto free_out;
 
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
