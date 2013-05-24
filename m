Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 7F52D6B00B2
	for <linux-mm@kvack.org>; Fri, 24 May 2013 06:35:49 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v8 34/34] memcg: reap dead memcgs upon global memory pressure.
Date: Fri, 24 May 2013 15:59:28 +0530
Message-Id: <1369391368-31562-35-git-send-email-glommer@openvz.org>
In-Reply-To: <1369391368-31562-1-git-send-email-glommer@openvz.org>
References: <1369391368-31562-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

When we delete kmem-enabled memcgs, they can still be zombieing
around for a while. The reason is that the objects may still be alive,
and we won't be able to delete them at destruction time.

The only entry point for that, though, are the shrinkers. The
shrinker interface, however, is not exactly tailored to our needs. It
could be a little bit better by using the API Dave Chinner proposed, but
it is still not ideal since we aren't really a count-and-scan event, but
more a one-off flush-all-you-can event that would have to abuse that
somehow.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 46 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c0e1113f..919fb24b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -400,7 +400,6 @@ static size_t memcg_size(void)
 		nr_node_ids * sizeof(struct mem_cgroup_per_node);
 }
 
-#ifdef CONFIG_MEMCG_DEBUG_ASYNC_DESTROY
 static LIST_HEAD(dangling_memcgs);
 static DEFINE_MUTEX(dangling_memcgs_mutex);
 
@@ -409,11 +408,14 @@ static inline void memcg_dangling_free(struct mem_cgroup *memcg)
 	mutex_lock(&dangling_memcgs_mutex);
 	list_del(&memcg->dead);
 	mutex_unlock(&dangling_memcgs_mutex);
+#ifdef CONFIG_MEMCG_DEBUG_ASYNC_DESTROY
 	free_pages((unsigned long)memcg->memcg_name, 0);
+#endif
 }
 
 static inline void memcg_dangling_add(struct mem_cgroup *memcg)
 {
+#ifdef CONFIG_MEMCG_DEBUG_ASYNC_DESTROY
 	/*
 	 * cgroup.c will do page-sized allocations most of the time,
 	 * so we'll just follow the pattern. Also, __get_free_pages
@@ -439,15 +441,12 @@ static inline void memcg_dangling_add(struct mem_cgroup *memcg)
 	}
 
 add_list:
+#endif
 	INIT_LIST_HEAD(&memcg->dead);
 	mutex_lock(&dangling_memcgs_mutex);
 	list_add(&memcg->dead, &dangling_memcgs);
 	mutex_unlock(&dangling_memcgs_mutex);
 }
-#else
-static inline void memcg_dangling_free(struct mem_cgroup *memcg) {}
-static inline void memcg_dangling_add(struct mem_cgroup *memcg) {}
-#endif
 
 static DEFINE_MUTEX(set_limit_mutex);
 
@@ -6313,6 +6312,41 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
+static void memcg_vmpressure_shrink_dead(void)
+{
+	struct memcg_cache_params *params, *tmp;
+	struct kmem_cache *cachep;
+	struct mem_cgroup *memcg;
+
+	mutex_lock(&dangling_memcgs_mutex);
+	list_for_each_entry(memcg, &dangling_memcgs, dead) {
+		mutex_lock(&memcg->slab_caches_mutex);
+		/* The element may go away as an indirect result of shrink */
+		list_for_each_entry_safe(params, tmp,
+					 &memcg->memcg_slab_caches, list) {
+			cachep = memcg_params_to_cache(params);
+			/*
+			 * the cpu_hotplug lock is taken in kmem_cache_create
+			 * outside the slab_caches_mutex manipulation. It will
+			 * be taken by kmem_cache_shrink to flush the cache.
+			 * So we need to drop the lock. It is all right because
+			 * the lock only protects elements moving in and out the
+			 * list.
+			 */
+			mutex_unlock(&memcg->slab_caches_mutex);
+			kmem_cache_shrink(cachep);
+			mutex_lock(&memcg->slab_caches_mutex);
+		}
+		mutex_unlock(&memcg->slab_caches_mutex);
+	}
+	mutex_unlock(&dangling_memcgs_mutex);
+}
+
+static void memcg_register_kmem_events(struct cgroup *cont)
+{
+	vmpressure_register_kernel_event(cont, memcg_vmpressure_shrink_dead);
+}
+
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	int ret;
@@ -6348,6 +6382,10 @@ static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
 	}
 }
 #else
+static inline void memcg_register_kmem_events(struct cgroup *cont)
+{
+}
+
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	return 0;
@@ -6733,8 +6771,10 @@ mem_cgroup_css_online(struct cgroup *cont)
 	struct mem_cgroup *memcg, *parent;
 	int error = 0;
 
-	if (!cont->parent)
+	if (!cont->parent) {
+		memcg_register_kmem_events(cont);
 		return 0;
+	}
 
 	mutex_lock(&memcg_create_mutex);
 	memcg = mem_cgroup_from_cont(cont);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
