Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D442B6B0034
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 04:21:48 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH 2/2] memcg: reap dead memcgs under pressure
Date: Tue, 23 Apr 2013 12:22:09 +0400
Message-Id: <1366705329-9426-3-git-send-email-glommer@openvz.org>
In-Reply-To: <1366705329-9426-1-git-send-email-glommer@openvz.org>
References: <1366705329-9426-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@openvz.org>, Dave Chinner <david@fromorbit.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

From: Glauber Costa <glommer@parallels.com>

When we delete kmem-enabled memcgs, they can still be zombieing around
for a while. The reason is that the objects may still be alive, and we
won't be able to delete them at destruction time.

My initial patchset included a custom sleep-and-wake mechanism that
would keep trying to destroy them, but that was frowned upon, with the
argument that the pressure system should handle that.

The only entry point for that, though, are the shrinkers. The shrinker
interface, however, is not exactly tailored to our needs. It could be a
little bit better by using the API Dave Chinner proposed, but it is
still not ideal since we aren't really a count-and-scan event, but more
a one-off flush-all-you-can event that would have to abuse that somehow.

My in-flight shinkers patchset would eventually introduce a custom point
for dead memcg reapings, but during LSF/MM, we started to consider using
the newly introduced vmpressure events for this. With that, we will
blend well into a one shot kind of event.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>

---
Andrew, should you consider merging this, you will conflict with the
debugging patch "memcg: debugging facility to access dangling memcgs".
This is because I am reusing its infrastructure to build this.
Please remove it, and I will provide a new version of that patch that
adds just the debugging file.
---
 mm/memcontrol.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 78 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c92bcfc..33b118c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -319,8 +319,16 @@ struct mem_cgroup {
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
@@ -380,6 +388,24 @@ static size_t memcg_size(void)
 		nr_node_ids * sizeof(struct mem_cgroup_per_node);
 }
 
+static LIST_HEAD(dangling_memcgs);
+static DEFINE_MUTEX(dangling_memcgs_mutex);
+
+static inline void memcg_dangling_free(struct mem_cgroup *memcg)
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
+
 /* internal only representation about the status of kmem accounting. */
 enum {
 	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
@@ -5856,6 +5882,46 @@ static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
 	if (memcg_kmem_test_and_clear_dead(memcg))
 		mem_cgroup_put(memcg);
 }
+
+static void memcg_vmpressure_shrink_dead(void)
+{
+	struct memcg_cache_params *params, *tmp;
+	struct kmem_cache *cachep;
+	struct mem_cgroup *memcg;
+
+	mutex_lock(&dangling_memcgs_mutex);
+	list_for_each_entry(memcg, &dangling_memcgs, dead) {
+
+		mem_cgroup_get(memcg);
+		mutex_lock(&memcg->slab_caches_mutex);
+		/* The element may go away as an indirect result of shrink */
+		list_for_each_entry_safe(params, tmp,
+					 &memcg->memcg_slab_caches, list) {
+
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
+		mem_cgroup_put(memcg);
+	}
+	mutex_unlock(&dangling_memcgs_mutex);
+}
+
+static void memcg_register_kmem_events(struct cgroup *cont)
+{
+	vmpressure_register_kernel_event(cont, memcg_vmpressure_shrink_dead);
+}
+
 #else
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
@@ -5865,6 +5931,10 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
 {
 }
+
+static void memcg_register_kmem_events(struct mem_cgroup *memcg)
+{
+}
 #endif
 
 static struct cftype mem_cgroup_files[] = {
@@ -6121,6 +6191,8 @@ static void free_work(struct work_struct *work)
 	struct mem_cgroup *memcg;
 
 	memcg = container_of(work, struct mem_cgroup, work_freeing);
+
+	memcg_dangling_free(memcg);
 	__mem_cgroup_free(memcg);
 }
 
@@ -6231,8 +6303,10 @@ mem_cgroup_css_online(struct cgroup *cont)
 	struct mem_cgroup *memcg, *parent;
 	int error = 0;
 
-	if (!cont->parent)
+	if (!cont->parent) {
+		memcg_register_kmem_events(cont);
 		return 0;
+	}
 
 	mutex_lock(&memcg_create_mutex);
 	memcg = mem_cgroup_from_cont(cont);
@@ -6315,6 +6389,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
 
 	kmem_cgroup_destroy(memcg);
 
+	memcg_dangling_add(memcg);
 	mem_cgroup_put(memcg);
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
