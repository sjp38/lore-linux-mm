Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 915B36B0080
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:20:12 -0500 (EST)
Received: by mail-la0-f49.google.com with SMTP id er20so8000847lab.22
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:20:11 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id le8si18020209lab.108.2013.12.02.03.20.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:20:11 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v12 17/18] memcg: reap dead memcgs upon global memory pressure
Date: Mon, 2 Dec 2013 15:19:52 +0400
Message-ID: <dcbf3fd6336bc44948c89d0abc8f9aff27888f81.1385974612.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385974612.git.vdavydov@parallels.com>
References: <cover.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, vdavydov@parallels.com, Anton Vorontsov <anton@enomsg.org>, John Stultz <john.stultz@linaro.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

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
 mm/memcontrol.c |   80 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 77 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a0b22d7..72db892 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -287,8 +287,16 @@ struct mem_cgroup {
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
@@ -338,6 +346,29 @@ struct mem_cgroup {
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
+static inline void memcg_dangling_del(struct mem_cgroup *memcg) {}
+static inline void memcg_dangling_add(struct mem_cgroup *memcg) {}
+#endif
+
 static size_t memcg_size(void)
 {
 	return sizeof(struct mem_cgroup) +
@@ -6363,6 +6394,41 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
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
+static void memcg_register_kmem_events(struct cgroup_subsys_state *css)
+{
+	vmpressure_register_kernel_event(css, memcg_vmpressure_shrink_dead);
+}
+
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	int ret;
@@ -6420,6 +6486,10 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
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
@@ -6758,8 +6828,10 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	if (css->cgroup->id > MEM_CGROUP_ID_MAX)
 		return -ENOSPC;
 
-	if (!parent)
+	if (!parent) {
+		memcg_register_kmem_events(css);
 		return 0;
+	}
 
 	mutex_lock(&memcg_create_mutex);
 
@@ -6821,6 +6893,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 	mem_cgroup_reparent_charges(memcg);
 	mem_cgroup_destroy_all_caches(memcg);
+	memcg_dangling_add(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
@@ -6829,6 +6902,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	memcg_destroy_kmem(memcg);
+	memcg_dangling_del(memcg);
 	__mem_cgroup_free(memcg);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
