Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 8DA6A6B006E
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:35 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id ea20so3102905lab.8
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:33 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 15/16] memcg: reap dead memcgs upon global memory pressure
Date: Sun,  7 Jul 2013 11:56:55 -0400
Message-Id: <1373212616-11713-16-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@openvz.org>, Anton Vorontsov <anton@enomsg.org>, John Stultz <john.stultz@linaro.org>, Michal Hocko <mhocko@suse.cz>

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
Cc: Anton Vorontsov <anton@enomsg.org>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 78 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8623172..e2dc89c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -297,8 +297,16 @@ struct mem_cgroup {
 	/* thresholds for mem+swap usage. RCU-protected */
 	struct mem_cgroup_thresholds memsw_thresholds;
 
-	/* For oom notifier event fd */
-	struct list_head oom_notify;
+	union {
+		/* For oom notifier event fd */
+		struct list_head oom_notify;
+		/*
+		 * we can only trigger an oom event if the memcg is alive.
+		 * so we will reuse this field to hook the memcg in the list
+		 * of dead memcgs.
+		 */
+		struct list_head dead;
+	};
 
 	/*
 	 * Should we move charges of a task when a task is moved into this
@@ -348,6 +356,29 @@ struct mem_cgroup {
 	/* WARNING: nodeinfo must be the last member here */
 };
 
+#if defined(CONFIG_MEMCG_KMEM) || defined(CONFIG_MEMCG_SWAP)
+static LIST_HEAD(dangling_memcgs);
+static DEFINE_MUTEX(dangling_memcgs_mutex);
+
+static inline void memcg_dangling_del(struct mem_cgroup *memcg)
+{
+	mutex_lock(&dangling_memcgs_mutex);
+	list_del(&memcg->dead);
+	mutex_unlock(&dangling_memcgs_mutex);
+}
+
+static inline void memcg_dangling_add(struct mem_cgroup *memcg)
+{
+	INIT_LIST_HEAD(&memcg->dead);
+	mutex_lock(&dangling_memcgs_mutex);
+	list_add(&memcg->dead, &dangling_memcgs);
+	mutex_unlock(&dangling_memcgs_mutex);
+}
+#else
+static inline void memcg_dangling_free(struct mem_cgroup *memcg) {}
+static inline void memcg_dangling_add(struct mem_cgroup *memcg) {}
+#endif
+
 static size_t memcg_size(void)
 {
 	return sizeof(struct mem_cgroup) +
@@ -6227,6 +6258,41 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
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
@@ -6276,6 +6342,10 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 		css_put(&memcg->css);
 }
 #else
+static inline void memcg_register_kmem_events(struct cgroup *cont)
+{
+}
+
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	return 0;
@@ -6607,8 +6677,10 @@ mem_cgroup_css_online(struct cgroup *cont)
 	struct mem_cgroup *memcg, *parent;
 	int error = 0;
 
-	if (!cont->parent)
+	if (!cont->parent) {
+		memcg_register_kmem_events(cont);
 		return 0;
+	}
 
 	mutex_lock(&memcg_create_mutex);
 	memcg = mem_cgroup_from_cont(cont);
@@ -6672,6 +6744,7 @@ static void mem_cgroup_css_offline(struct cgroup *cont)
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 	mem_cgroup_reparent_charges(memcg);
 	mem_cgroup_destroy_all_caches(memcg);
+	memcg_dangling_add(memcg);
 }
 
 static void mem_cgroup_css_free(struct cgroup *cont)
@@ -6680,7 +6753,9 @@ static void mem_cgroup_css_free(struct cgroup *cont)
 
 	mem_cgroup_sockets_destroy(memcg);
 
+	memcg_dangling_del(memcg);
 	__mem_cgroup_free(memcg);
+
 }
 
 #ifdef CONFIG_MMU
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
