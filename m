Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5607A6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 19:34:36 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p187so24215558wmp.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 16:34:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ld8si13107788wjc.77.2015.12.16.16.34.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 16:34:34 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: memcontrol: clean up alloc, online, offline, free functions fix
Date: Wed, 16 Dec 2015 19:34:20 -0500
Message-Id: <1450312460-27582-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Fixlets based on review feedback from Vladimir:

1. The memcg_create_mutex is to stabilize a cgroup's hereditary
   settings that are not allowed to change once the cgroup has
   children: kmem accounting and hierarchy mode. However, the cleanup
   patch moves inheritance of these settings from onlining time to
   allocation time, before the new child will show up in the parent's
   list of children, and this opens a race window where the parent can
   change a setting that has been passed on to a new child already.

   That being said, this rule for kmem and hierarchy mode is somewhat
   gratuitous: there is no strong reason why these configurations
   shouldn't exist, and the outcome of a race is not harmful. It's
   also unlikely that somebody will even trigger this race because we
   don't expect anybody to flip-flop either settings while creating
   child groups. So instead of readding complexity to close an
   unlikely race window that doesn't do any harm, simply remove the
   now pointless mutex as a follow-up cleanup.

2. Kmem initialization consists of several steps that are undone in
   both css_offline() and css_free(). However, if css allocation fails
   later on then css_offline() is never called and we don't properly
   free the kmem state. Let css_free() detect this and call kmem
   offlining itself.

3. Children in !use_hierarchy mode would inherit the OOM killer
   setting from their physical parent rather than the logical parent,
   rootmemcg.  This is silly, but no reason to change the semantics as
   part of this cleanup patch, so restore it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 35 ++++++++---------------------------
 1 file changed, 8 insertions(+), 27 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af8714a..124a802 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -250,13 +250,6 @@ enum res_type {
 /* Used for OOM nofiier */
 #define OOM_CONTROL		(0)
 
-/*
- * The memcg_create_mutex will be held whenever a new cgroup is created.
- * As a consequence, any change that needs to protect against new child cgroups
- * appearing has to hold it as well.
- */
-static DEFINE_MUTEX(memcg_create_mutex);
-
 /* Some nice accessors for the vmpressure. */
 struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg)
 {
@@ -2660,14 +2653,6 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
 {
 	bool ret;
 
-	/*
-	 * The lock does not prevent addition or deletion of children, but
-	 * it prevents a new child from being initialized based on this
-	 * parent in css_online(), so it's enough to decide whether
-	 * hierarchically inherited attributes can still be changed or not.
-	 */
-	lockdep_assert_held(&memcg_create_mutex);
-
 	rcu_read_lock();
 	ret = css_next_child(NULL, &memcg->css);
 	rcu_read_unlock();
@@ -2730,10 +2715,8 @@ static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup *parent_memcg = mem_cgroup_from_css(memcg->css.parent);
 
-	mutex_lock(&memcg_create_mutex);
-
 	if (memcg->use_hierarchy == val)
-		goto out;
+		return 0;
 
 	/*
 	 * If parent's use_hierarchy is set, we can't make any modifications
@@ -2752,9 +2735,6 @@ static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
 	} else
 		retval = -EINVAL;
 
-out:
-	mutex_unlock(&memcg_create_mutex);
-
 	return retval;
 }
 
@@ -2929,6 +2909,10 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
 
 static void memcg_free_kmem(struct mem_cgroup *memcg)
 {
+	/* css_alloc() failed, offlining didn't happen */
+	if (unlikely(memcg->kmem_state == KMEM_ONLINE))
+		memcg_offline_kmem(memcg);
+
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
 		memcg_destroy_kmem_caches(memcg);
 		static_branch_dec(&memcg_kmem_enabled_key);
@@ -2956,11 +2940,9 @@ static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 	mutex_lock(&memcg_limit_mutex);
 	/* Top-level cgroup doesn't propagate from root */
 	if (!memcg_kmem_online(memcg)) {
-		mutex_lock(&memcg_create_mutex);
 		if (cgroup_is_populated(memcg->css.cgroup) ||
 		    (memcg->use_hierarchy && memcg_has_children(memcg)))
 			ret = -EBUSY;
-		mutex_unlock(&memcg_create_mutex);
 		if (ret)
 			goto out;
 		ret = memcg_online_kmem(memcg);
@@ -4184,14 +4166,14 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	if (!memcg)
 		return ERR_PTR(error);
 
-	mutex_lock(&memcg_create_mutex);
 	memcg->high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
-	if (parent)
+	if (parent) {
 		memcg->swappiness = mem_cgroup_swappiness(parent);
+		memcg->oom_kill_disable = parent->oom_kill_disable;
+	}
 	if (parent && parent->use_hierarchy) {
 		memcg->use_hierarchy = true;
-		memcg->oom_kill_disable = parent->oom_kill_disable;
 		page_counter_init(&memcg->memory, &parent->memory);
 		page_counter_init(&memcg->memsw, &parent->memsw);
 		page_counter_init(&memcg->kmem, &parent->kmem);
@@ -4209,7 +4191,6 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 		if (parent != root_mem_cgroup)
 			memory_cgrp_subsys.broken_hierarchy = true;
 	}
-	mutex_unlock(&memcg_create_mutex);
 
 	/* The following stuff does not apply to the root */
 	if (!parent) {
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
