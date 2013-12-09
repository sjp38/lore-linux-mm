Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 15AFE6B005C
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 03:06:20 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id eh20so1293683lab.18
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 00:06:20 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 9si3268906las.159.2013.12.09.00.06.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 00:06:19 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v13 15/16] memcg: reap dead memcgs upon global memory pressure
Date: Mon, 9 Dec 2013 12:05:56 +0400
Message-ID: <d9b823b23f9a0f6e38bba6a3a475387074abb00a.1386571280.git.vdavydov@parallels.com>
In-Reply-To: <cover.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, vdavydov@parallels.com, Anton Vorontsov <anton@enomsg.org>, John Stultz <john.stultz@linaro.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

When we delete kmem-enabled memcgs, they can still be zombieing around
for a while. The reason is that the objects may still be alive, and we
won't be able to delete them at destruction time.

The only entry point for that, though, are the shrinkers. The shrinker
interface, however, is not exactly tailored to our needs. It could be a
little bit better by using the API Dave Chinner proposed, but it is
still not ideal since we aren't really a count-and-scan event, but more
a one-off flush-all-you-can event that would have to abuse that somehow.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
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
index b15219e..182199f 100644
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
@@ -336,6 +344,29 @@ struct mem_cgroup {
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
@@ -6085,6 +6116,41 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
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
@@ -6139,6 +6205,10 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
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
@@ -6477,8 +6547,10 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	if (css->cgroup->id > MEM_CGROUP_ID_MAX)
 		return -ENOSPC;
 
-	if (!parent)
+	if (!parent) {
+		memcg_register_kmem_events(css);
 		return 0;
+	}
 
 	mutex_lock(&memcg_create_mutex);
 
@@ -6540,6 +6612,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 	mem_cgroup_reparent_charges(memcg);
 	mem_cgroup_destroy_all_caches(memcg);
+	memcg_dangling_add(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
@@ -6548,6 +6621,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
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
