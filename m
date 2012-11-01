Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id A22A86B0085
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:09:12 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 24/29] memcg/sl[au]b Track all the memcg children of a kmem_cache.
Date: Thu,  1 Nov 2012 16:07:40 +0400
Message-Id: <1351771665-11076-25-git-send-email-glommer@parallels.com>
In-Reply-To: <1351771665-11076-1-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Suleiman Souhlal <suleiman@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>

This enables us to remove all the children of a kmem_cache being
destroyed, if for example the kernel module it's being used in
gets unloaded. Otherwise, the children will still point to the
destroyed parent.

[ v6: cancel pending work before destroying child cache ]

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h |  5 +++++
 mm/memcontrol.c            | 49 ++++++++++++++++++++++++++++++++++++++++++++--
 mm/slab_common.c           |  3 +++
 3 files changed, 55 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7d59852..d5511cc 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -447,6 +447,7 @@ struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
 void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
+void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
@@ -594,6 +595,10 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	return cachep;
 }
+
+static inline void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+{
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b6c725d..31da8bc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2741,6 +2741,8 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 	memcg_check_events(memcg, page);
 }
 
+static DEFINE_MUTEX(set_limit_mutex);
+
 #ifdef CONFIG_MEMCG_KMEM
 static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 {
@@ -3153,6 +3155,51 @@ out:
 	return new_cachep;
 }
 
+void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+{
+	struct kmem_cache *c;
+	int i;
+
+	if (!s->memcg_params)
+		return;
+	if (!s->memcg_params->is_root_cache)
+		return;
+
+	/*
+	 * If the cache is being destroyed, we trust that there is no one else
+	 * requesting objects from it. Even if there are, the sanity checks in
+	 * kmem_cache_destroy should caught this ill-case.
+	 *
+	 * Still, we don't want anyone else freeing memcg_caches under our
+	 * noses, which can happen if a new memcg comes to life. As usual,
+	 * we'll take the set_limit_mutex to protect ourselves against this.
+	 */
+	mutex_lock(&set_limit_mutex);
+	for (i = 0; i < memcg_limited_groups_array_size; i++) {
+		c = s->memcg_params->memcg_caches[i];
+		if (!c)
+			continue;
+
+		/*
+		 * We will now manually delete the caches, so to avoid races
+		 * we need to cancel all pending destruction workers and
+		 * proceed with destruction ourselves.
+		 *
+		 * kmem_cache_destroy() will call kmem_cache_shrink internally,
+		 * and that could spawn the workers again: it is likely that
+		 * the cache still have active pages until this very moment.
+		 * This would lead us back to mem_cgroup_destroy_cache.
+		 *
+		 * But that will not execute at all if the "dead" flag is not
+		 * set, so flip it down to guarantee we are in control.
+		 */
+		c->memcg_params->dead = false;
+		cancel_delayed_work_sync(&c->memcg_params->destroy);
+		kmem_cache_destroy(c);
+	}
+	mutex_unlock(&set_limit_mutex);
+}
+
 struct create_work {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *cachep;
@@ -4263,8 +4310,6 @@ void mem_cgroup_print_bad_page(struct page *page)
 }
 #endif
 
-static DEFINE_MUTEX(set_limit_mutex);
-
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 				unsigned long long val)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index b76a74c..04215a5 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -221,6 +221,9 @@ EXPORT_SYMBOL(kmem_cache_create);
 
 void kmem_cache_destroy(struct kmem_cache *s)
 {
+	/* Destroy all the children caches if we aren't a memcg cache */
+	kmem_cache_destroy_memcg_children(s);
+
 	get_online_cpus();
 	mutex_lock(&slab_mutex);
 	s->refcount--;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
