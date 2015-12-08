Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B4CD36B025D
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:34:54 -0500 (EST)
Received: by wmec201 with SMTP id c201so41422507wme.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:34:54 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kd1si5941384wjb.43.2015.12.08.10.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 10:34:53 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/8] mm: memcontrol: group kmem init and exit functions together
Date: Tue,  8 Dec 2015 13:34:21 -0500
Message-Id: <1449599665-18047-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Put all the related code to setup and teardown the kmem accounting
state into the same location. No functional change intended.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 157 +++++++++++++++++++++++++++-----------------------------
 1 file changed, 76 insertions(+), 81 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 22b8c4f..5118618 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2924,12 +2924,88 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 	mutex_unlock(&memcg_limit_mutex);
 	return ret;
 }
+
+static int memcg_init_kmem(struct mem_cgroup *memcg)
+{
+	int ret;
+
+	ret = memcg_propagate_kmem(memcg);
+	if (ret)
+		return ret;
+
+	return tcp_init_cgroup(memcg);
+}
+
+static void memcg_offline_kmem(struct mem_cgroup *memcg)
+{
+	struct cgroup_subsys_state *css;
+	struct mem_cgroup *parent, *child;
+	int kmemcg_id;
+
+	if (memcg->kmem_state != KMEM_ONLINE)
+		return;
+	/*
+	 * Clear the online state before clearing memcg_caches array
+	 * entries. The slab_mutex in memcg_deactivate_kmem_caches()
+	 * guarantees that no cache will be created for this cgroup
+	 * after we are done (see memcg_create_kmem_cache()).
+	 */
+	memcg->kmem_state = KMEM_ALLOCATED;
+
+	memcg_deactivate_kmem_caches(memcg);
+
+	kmemcg_id = memcg->kmemcg_id;
+	BUG_ON(kmemcg_id < 0);
+
+	parent = parent_mem_cgroup(memcg);
+	if (!parent)
+		parent = root_mem_cgroup;
+
+	/*
+	 * Change kmemcg_id of this cgroup and all its descendants to the
+	 * parent's id, and then move all entries from this cgroup's list_lrus
+	 * to ones of the parent. After we have finished, all list_lrus
+	 * corresponding to this cgroup are guaranteed to remain empty. The
+	 * ordering is imposed by list_lru_node->lock taken by
+	 * memcg_drain_all_list_lrus().
+	 */
+	css_for_each_descendant_pre(css, &memcg->css) {
+		child = mem_cgroup_from_css(css);
+		BUG_ON(child->kmemcg_id != kmemcg_id);
+		child->kmemcg_id = parent->kmemcg_id;
+		if (!memcg->use_hierarchy)
+			break;
+	}
+	memcg_drain_all_list_lrus(kmemcg_id, parent->kmemcg_id);
+
+	memcg_free_cache_id(kmemcg_id);
+}
+
+static void memcg_free_kmem(struct mem_cgroup *memcg)
+{
+	if (memcg->kmem_state == KMEM_ALLOCATED) {
+		memcg_destroy_kmem_caches(memcg);
+		static_branch_dec(&memcg_kmem_enabled_key);
+		WARN_ON(page_counter_read(&memcg->kmem));
+	}
+	tcp_destroy_cgroup(memcg);
+}
 #else
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 				   unsigned long limit)
 {
 	return -EINVAL;
 }
+static int memcg_init_kmem(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+static void memcg_offline_kmem(struct mem_cgroup *memcg)
+{
+}
+static void memcg_free_kmem(struct mem_cgroup *memcg)
+{
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 /*
@@ -3555,87 +3631,6 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
 	return 0;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
-static int memcg_init_kmem(struct mem_cgroup *memcg)
-{
-	int ret;
-
-	ret = memcg_propagate_kmem(memcg);
-	if (ret)
-		return ret;
-
-	return tcp_init_cgroup(memcg);
-}
-
-static void memcg_offline_kmem(struct mem_cgroup *memcg)
-{
-	struct cgroup_subsys_state *css;
-	struct mem_cgroup *parent, *child;
-	int kmemcg_id;
-
-	if (memcg->kmem_state != KMEM_ONLINE)
-		return;
-	/*
-	 * Clear the online state before clearing memcg_caches array
-	 * entries. The slab_mutex in memcg_deactivate_kmem_caches()
-	 * guarantees that no cache will be created for this cgroup
-	 * after we are done (see memcg_create_kmem_cache()).
-	 */
-	memcg->kmem_state = KMEM_ALLOCATED;
-
-	memcg_deactivate_kmem_caches(memcg);
-
-	kmemcg_id = memcg->kmemcg_id;
-	BUG_ON(kmemcg_id < 0);
-
-	parent = parent_mem_cgroup(memcg);
-	if (!parent)
-		parent = root_mem_cgroup;
-
-	/*
-	 * Change kmemcg_id of this cgroup and all its descendants to the
-	 * parent's id, and then move all entries from this cgroup's list_lrus
-	 * to ones of the parent. After we have finished, all list_lrus
-	 * corresponding to this cgroup are guaranteed to remain empty. The
-	 * ordering is imposed by list_lru_node->lock taken by
-	 * memcg_drain_all_list_lrus().
-	 */
-	css_for_each_descendant_pre(css, &memcg->css) {
-		child = mem_cgroup_from_css(css);
-		BUG_ON(child->kmemcg_id != kmemcg_id);
-		child->kmemcg_id = parent->kmemcg_id;
-		if (!memcg->use_hierarchy)
-			break;
-	}
-	memcg_drain_all_list_lrus(kmemcg_id, parent->kmemcg_id);
-
-	memcg_free_cache_id(kmemcg_id);
-}
-
-static void memcg_free_kmem(struct mem_cgroup *memcg)
-{
-	if (memcg->kmem_state == KMEM_ALLOCATED) {
-		memcg_destroy_kmem_caches(memcg);
-		static_branch_dec(&memcg_kmem_enabled_key);
-		WARN_ON(page_counter_read(&memcg->kmem));
-	}
-	tcp_destroy_cgroup(memcg);
-}
-#else
-static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
-{
-	return 0;
-}
-
-static void memcg_offline_kmem(struct mem_cgroup *memcg)
-{
-}
-
-static void memcg_free_kmem(struct mem_cgroup *memcg)
-{
-}
-#endif
-
 #ifdef CONFIG_CGROUP_WRITEBACK
 
 struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg)
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
