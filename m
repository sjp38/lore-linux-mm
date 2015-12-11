Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 993FA6B0257
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:54:36 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id c17so24090704wmd.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:54:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 18si7190145wmt.22.2015.12.11.11.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 11:54:35 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/4] mm: memcontrol: clean up alloc, online, offline, free functions
Date: Fri, 11 Dec 2015 14:54:13 -0500
Message-Id: <1449863653-6546-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The creation and teardown of struct mem_cgroup is fairly messy and
that has attracted mistakes and subtle bugs before.

The main cause for this is that there is no clear model about what
needs to happen when, and that attracts more chaos. So create one:

1. mem_cgroup_alloc() should allocate struct mem_cgroup and its
   auxiliary members and initialize work items, locks etc. so that the
   object it returns is fully initialized and in a neutral state.

2. mem_cgroup_css_alloc() will use mem_cgroup_alloc() to obtain a new
   memcg object and configure it and the system according to the role
   of the new memory-controlled cgroup in the hierarchy.

3. mem_cgroup_css_online() is no longer needed to synchronize with
   iterators, but it verifies css->id which isn't available earlier.

4. mem_cgroup_css_offline() implements stuff that needs to happen upon
   the user-visible destruction of a cgroup, which includes stopping
   all user interfacing as well as releasing certain structures when
   continued memory consumption would be unexpected at that point.

5. mem_cgroup_css_free() prepares the system and the memcg object for
   the object's disappearance, neutralizes its state, and then gives
   it back to mem_cgroup_free().

6. mem_cgroup_free() releases struct mem_cgroup and auxiliary memory.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |   3 -
 mm/memcontrol.c            | 225 +++++++++++++++------------------------------
 2 files changed, 75 insertions(+), 153 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a3869bf..27123e5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -181,9 +181,6 @@ struct mem_cgroup {
 	/* vmpressure notifications */
 	struct vmpressure vmpressure;
 
-	/* css_online() has been completed */
-	int initialized;
-
 	/*
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 306842c..af8714a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -896,17 +896,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		if (css == &root->css)
 			break;
 
-		if (css_tryget(css)) {
-			/*
-			 * Make sure the memcg is initialized:
-			 * mem_cgroup_css_online() orders the the
-			 * initialization against setting the flag.
-			 */
-			if (smp_load_acquire(&memcg->initialized))
-				break;
-
-			css_put(css);
-		}
+		if (css_tryget(css))
+			break;
 
 		memcg = NULL;
 	}
@@ -2851,37 +2842,14 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 #ifndef CONFIG_SLOB
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
-	int err = 0;
 	int memcg_id;
 
 	BUG_ON(memcg->kmemcg_id >= 0);
 	BUG_ON(memcg->kmem_state);
 
-	/*
-	 * For simplicity, we won't allow this to be disabled.  It also can't
-	 * be changed if the cgroup has children already, or if tasks had
-	 * already joined.
-	 *
-	 * If tasks join before we set the limit, a person looking at
-	 * kmem.usage_in_bytes will have no way to determine when it took
-	 * place, which makes the value quite meaningless.
-	 *
-	 * After it first became limited, changes in the value of the limit are
-	 * of course permitted.
-	 */
-	mutex_lock(&memcg_create_mutex);
-	if (cgroup_is_populated(memcg->css.cgroup) ||
-	    (memcg->use_hierarchy && memcg_has_children(memcg)))
-		err = -EBUSY;
-	mutex_unlock(&memcg_create_mutex);
-	if (err)
-		goto out;
-
 	memcg_id = memcg_alloc_cache_id();
-	if (memcg_id < 0) {
-		err = memcg_id;
-		goto out;
-	}
+	if (memcg_id < 0)
+		return memcg_id;
 
 	static_branch_inc(&memcg_kmem_enabled_key);
 	/*
@@ -2892,17 +2860,14 @@ static int memcg_online_kmem(struct mem_cgroup *memcg)
 	 */
 	memcg->kmemcg_id = memcg_id;
 	memcg->kmem_state = KMEM_ONLINE;
-out:
-	return err;
+
+	return 0;
 }
 
-static int memcg_propagate_kmem(struct mem_cgroup *memcg)
+static int memcg_propagate_kmem(struct mem_cgroup *parent,
+				struct mem_cgroup *memcg)
 {
 	int ret = 0;
-	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
-
-	if (!parent)
-		return 0;
 
 	mutex_lock(&memcg_limit_mutex);
 	/*
@@ -2986,11 +2951,18 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 				   unsigned long limit)
 {
-	int ret;
+	int ret = 0;
 
 	mutex_lock(&memcg_limit_mutex);
 	/* Top-level cgroup doesn't propagate from root */
 	if (!memcg_kmem_online(memcg)) {
+		mutex_lock(&memcg_create_mutex);
+		if (cgroup_is_populated(memcg->css.cgroup) ||
+		    (memcg->use_hierarchy && memcg_has_children(memcg)))
+			ret = -EBUSY;
+		mutex_unlock(&memcg_create_mutex);
+		if (ret)
+			goto out;
 		ret = memcg_online_kmem(memcg);
 		if (ret)
 			goto out;
@@ -4145,90 +4117,44 @@ static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 	kfree(memcg->nodeinfo[node]);
 }
 
-static struct mem_cgroup *mem_cgroup_alloc(void)
-{
-	struct mem_cgroup *memcg;
-	size_t size;
-
-	size = sizeof(struct mem_cgroup);
-	size += nr_node_ids * sizeof(struct mem_cgroup_per_node *);
-
-	memcg = kzalloc(size, GFP_KERNEL);
-	if (!memcg)
-		return NULL;
-
-	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
-	if (!memcg->stat)
-		goto out_free;
-
-	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
-		goto out_free_stat;
-
-	return memcg;
-
-out_free_stat:
-	free_percpu(memcg->stat);
-out_free:
-	kfree(memcg);
-	return NULL;
-}
-
-/*
- * At destroying mem_cgroup, references from swap_cgroup can remain.
- * (scanning all at force_empty is too costly...)
- *
- * Instead of clearing all references at force_empty, we remember
- * the number of reference from swap_cgroup and free mem_cgroup when
- * it goes down to 0.
- *
- * Removal of cgroup itself succeeds regardless of refs from swap.
- */
-
-static void __mem_cgroup_free(struct mem_cgroup *memcg)
+static void mem_cgroup_free(struct mem_cgroup *memcg)
 {
 	int node;
 
-	cancel_work_sync(&memcg->high_work);
-
-	mem_cgroup_remove_from_trees(memcg);
-
+	memcg_wb_domain_exit(memcg);
 	for_each_node(node)
 		free_mem_cgroup_per_zone_info(memcg, node);
-
 	free_percpu(memcg->stat);
-	memcg_wb_domain_exit(memcg);
 	kfree(memcg);
 }
 
-static struct cgroup_subsys_state * __ref
-mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
+static struct mem_cgroup *mem_cgroup_alloc(void)
 {
 	struct mem_cgroup *memcg;
-	long error = -ENOMEM;
+	size_t size;
 	int node;
 
-	memcg = mem_cgroup_alloc();
+	size = sizeof(struct mem_cgroup);
+	size += nr_node_ids * sizeof(struct mem_cgroup_per_node *);
+
+	memcg = kzalloc(size, GFP_KERNEL);
 	if (!memcg)
-		return ERR_PTR(error);
+		return NULL;
+
+	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
+	if (!memcg->stat)
+		goto fail;
 
 	for_each_node(node)
 		if (alloc_mem_cgroup_per_zone_info(memcg, node))
-			goto free_out;
+			goto fail;
 
-	/* root ? */
-	if (parent_css == NULL) {
-		root_mem_cgroup = memcg;
-		page_counter_init(&memcg->memory, NULL);
-		memcg->high = PAGE_COUNTER_MAX;
-		memcg->soft_limit = PAGE_COUNTER_MAX;
-		page_counter_init(&memcg->memsw, NULL);
-		page_counter_init(&memcg->kmem, NULL);
-	}
+	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
+		goto fail;
 
 	INIT_WORK(&memcg->high_work, high_work_func);
 	memcg->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&memcg->oom_notify);
-	memcg->move_charge_at_immigrate = 0;
 	mutex_init(&memcg->thresholds_lock);
 	spin_lock_init(&memcg->move_lock);
 	vmpressure_init(&memcg->vmpressure);
@@ -4241,48 +4167,37 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
-	return &memcg->css;
-
-free_out:
-	__mem_cgroup_free(memcg);
-	return ERR_PTR(error);
+	return memcg;
+fail:
+	mem_cgroup_free(memcg);
+	return NULL;
 }
 
-static int
-mem_cgroup_css_online(struct cgroup_subsys_state *css)
+static struct cgroup_subsys_state * __ref
+mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	struct mem_cgroup *parent = mem_cgroup_from_css(css->parent);
-	int ret;
-
-	if (css->id > MEM_CGROUP_ID_MAX)
-		return -ENOSPC;
+	struct mem_cgroup *parent = mem_cgroup_from_css(parent_css);
+	struct mem_cgroup *memcg;
+	long error = -ENOMEM;
 
-	if (!parent)
-		return 0;
+	memcg = mem_cgroup_alloc();
+	if (!memcg)
+		return ERR_PTR(error);
 
 	mutex_lock(&memcg_create_mutex);
-
-	memcg->use_hierarchy = parent->use_hierarchy;
-	memcg->oom_kill_disable = parent->oom_kill_disable;
-	memcg->swappiness = mem_cgroup_swappiness(parent);
-
-	if (parent->use_hierarchy) {
+	memcg->high = PAGE_COUNTER_MAX;
+	memcg->soft_limit = PAGE_COUNTER_MAX;
+	if (parent)
+		memcg->swappiness = mem_cgroup_swappiness(parent);
+	if (parent && parent->use_hierarchy) {
+		memcg->use_hierarchy = true;
+		memcg->oom_kill_disable = parent->oom_kill_disable;
 		page_counter_init(&memcg->memory, &parent->memory);
-		memcg->high = PAGE_COUNTER_MAX;
-		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, &parent->memsw);
 		page_counter_init(&memcg->kmem, &parent->kmem);
 		page_counter_init(&memcg->tcpmem, &parent->tcpmem);
-
-		/*
-		 * No need to take a reference to the parent because cgroup
-		 * core guarantees its existence.
-		 */
 	} else {
 		page_counter_init(&memcg->memory, NULL);
-		memcg->high = PAGE_COUNTER_MAX;
-		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
 		page_counter_init(&memcg->tcpmem, NULL);
@@ -4296,19 +4211,30 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	}
 	mutex_unlock(&memcg_create_mutex);
 
-	ret = memcg_propagate_kmem(memcg);
-	if (ret)
-		return ret;
+	/* The following stuff does not apply to the root */
+	if (!parent) {
+		root_mem_cgroup = memcg;
+		return &memcg->css;
+	}
+
+	error = memcg_propagate_kmem(parent, memcg);
+	if (error)
+		goto fail;
 
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_inc(&memcg_sockets_enabled_key);
 
-	/*
-	 * Make sure the memcg is initialized: mem_cgroup_iter()
-	 * orders reading memcg->initialized against its callers
-	 * reading the memcg members.
-	 */
-	smp_store_release(&memcg->initialized, 1);
+	return &memcg->css;
+fail:
+	mem_cgroup_free(memcg);
+	return NULL;
+}
+
+static int
+mem_cgroup_css_online(struct cgroup_subsys_state *css)
+{
+	if (css->id > MEM_CGROUP_ID_MAX)
+		return -ENOSPC;
 
 	return 0;
 }
@@ -4330,10 +4256,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	}
 	spin_unlock(&memcg->event_list_lock);
 
-	vmpressure_cleanup(&memcg->vmpressure);
-
 	memcg_offline_kmem(memcg);
-
 	wb_memcg_offline(memcg);
 }
 
@@ -4347,9 +4270,11 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && memcg->tcpmem_active)
 		static_branch_dec(&memcg_sockets_enabled_key);
 
+	vmpressure_cleanup(&memcg->vmpressure);
+	cancel_work_sync(&memcg->high_work);
+	mem_cgroup_remove_from_trees(memcg);
 	memcg_free_kmem(memcg);
-
-	__mem_cgroup_free(memcg);
+	mem_cgroup_free(memcg);
 }
 
 /**
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
