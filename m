Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 088B56B00E4
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 10:02:42 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 30/32] memcg: shrink dead memcgs upon global memory pressure.
Date: Mon,  8 Apr 2013 18:00:57 +0400
Message-Id: <1365429659-22108-31-git-send-email-glommer@parallels.com>
In-Reply-To: <1365429659-22108-1-git-send-email-glommer@parallels.com>
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Serge Hallyn <serge.hallyn@canonical.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@parallels.com>, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

When a kmem enable memcg dies, it can still be walking dead around
because some caches hold a reference to it (it can happen due to swap as
well).

Past efforts to actively insist on shrinking them upon memcg destruction
led to extra complication, so the goal has been since them to do it from
global reclaim.

Now that the case of kmemcg shrinker is more clear, we can also include
a shrink_slab-time reaper that will try to get rid of the dangling
caches.

There are two reasons why I am not using a normal shrinker interface:
First, it is hard and expensive for us to determine how many objects we
have. We also don't need to save any of those objects since they are not
expecting to be caching anything: we want here to free as many memory as
we can.
Second, the caches are pinned down by cache objects which will, in turn,
be shrunk by shrink_slab. We would like that to be the last step. So to
avoid complicating the shrinker registration, we can just manually
insert this step

Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

---
Andrew: This will conflict with a -mm-only debug patch you have since I
am reusing its dead-list infrastructure. You will have to dump that, and
apply a new version that only adds the debugging interface.
---
 include/linux/memcontrol.h |  6 ++++
 mm/memcontrol.c            | 75 ++++++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c                |  1 +
 3 files changed, 80 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 782dcbf..fec50ef 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -482,6 +482,7 @@ int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
 
 void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
 void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
+void reap_dead_memcgs(void);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
@@ -660,6 +661,11 @@ static inline struct mem_cgroup *mem_cgroup_from_kmem_page(struct page *page)
 {
 	return NULL;
 }
+
+static inline void reap_dead_memcgs(void)
+{
+}
+
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1f1ded3..cafb3c5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -310,8 +310,16 @@ struct mem_cgroup {
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
@@ -373,6 +381,24 @@ static size_t memcg_size(void)
 
 static DEFINE_MUTEX(set_limit_mutex);
 
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
@@ -6023,6 +6049,48 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
+static void memcg_shrink_dead_fn(struct work_struct *w)
+{
+	struct memcg_cache_params *params, *tmp;
+	struct kmem_cache *cachep;
+	struct mem_cgroup *memcg;
+
+	mutex_lock(&dangling_memcgs_mutex);
+	list_for_each_entry(memcg, &dangling_memcgs, dead) {
+		mem_cgroup_get(memcg);
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
+		mem_cgroup_put(memcg);
+	}
+	mutex_unlock(&dangling_memcgs_mutex);
+}
+static DECLARE_WORK(kmemcg_dangling_work, memcg_shrink_dead_fn);
+
+/*
+ * We can't take any of our locks in reclaim context, because we've taken them
+ * in other contexts before, so we could deadlock.
+ */
+void reap_dead_memcgs(void)
+{
+	schedule_work(&kmemcg_dangling_work);
+}
+
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	int ret;
@@ -6317,6 +6385,8 @@ static void free_work(struct work_struct *work)
 	struct mem_cgroup *memcg;
 
 	memcg = container_of(work, struct mem_cgroup, work_freeing);
+
+	memcg_dangling_free(memcg);
 	__mem_cgroup_free(memcg);
 }
 
@@ -6491,6 +6561,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
 
 	kmem_cgroup_destroy(memcg);
 
+	memcg_dangling_add(memcg);
 	mem_cgroup_put(memcg);
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 752e9c7..c72e7dd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -378,6 +378,7 @@ unsigned long shrink_slab(struct shrink_control *sc,
 	up_read(&shrinker_rwsem);
 out:
 	cond_resched();
+	reap_dead_memcgs();
 	return freed;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
