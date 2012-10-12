Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 95F0B6B0068
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 09:42:51 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v4 15/19] memcg/sl[au]b: shrink dead caches
Date: Fri, 12 Oct 2012 17:41:09 +0400
Message-Id: <1350049273-17213-16-git-send-email-glommer@parallels.com>
In-Reply-To: <1350049273-17213-1-git-send-email-glommer@parallels.com>
References: <1350049273-17213-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

In the slub allocator, when the last object of a page goes away, we
don't necessarily free it - there is not necessarily a test for empty
page in any slab_free path.

This means that when we destroy a memcg cache that happened to be empty,
those caches may take a lot of time to go away: removing the memcg
reference won't destroy them - because there are pending references, and
the empty pages will stay there, until a shrinker is called upon for any
reason.

This patch marks all memcg caches as dead. kmem_cache_shrink is called
for the ones who are not yet dead - this will force internal cache
reorganization, and then all references to empty pages will be removed.

An unlikely branch is used to make sure this case does not affect
performance in the usual slab_free path.

The slab allocator has a time based reaper that would eventually get rid
of the objects, but we can also call it explicitly, since dead caches
are not a likely event.

[ v2: also call verify_dead for the slab ]
[ v3: use delayed_work to avoid calling verify_dead at every free]

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
CC: Tejun Heo <tj@kernel.org>
---
 include/linux/slab.h |  2 +-
 mm/memcontrol.c      | 28 ++++++++++++++++++++++------
 2 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index e17d348..9ed1a98 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -214,7 +214,7 @@ struct memcg_cache_params {
 			struct kmem_cache *cachep;
 			bool dead;
 			atomic_t nr_pages;
-			struct work_struct destroy;
+			struct delayed_work destroy;
 		};
 	};
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8cf8b4d..b52e6b9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2955,11 +2955,27 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
 {
 	struct kmem_cache *cachep;
 	struct memcg_cache_params *p;
+	struct delayed_work *dw = to_delayed_work(w);
 
-	p = container_of(w, struct memcg_cache_params, destroy);
+	p = container_of(dw, struct memcg_cache_params, destroy);
 	cachep = p->cachep;
 
-	if (!atomic_read(&cachep->memcg_params->nr_pages))
+	/*
+	 * If we get down to 0 after shrink, we could delete right away.
+	 * However, memcg_release_pages() already puts us back in the workqueue
+	 * in that case. If we proceed deleting, we'll get a dangling
+	 * reference, and removing the object from the workqueue in that case is
+	 * unnecessary complication. We are not a fast path.
+	 *
+	 * If we aren't down to zero, we'll schedule a slow worker and try again
+	 */
+	if (atomic_read(&cachep->memcg_params->nr_pages) != 0) {
+		kmem_cache_shrink(cachep);
+		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
+			return;
+		/* Once per minute should be good enough. */
+		schedule_delayed_work(&cachep->memcg_params->destroy, 60 * HZ);
+	} else
 		kmem_cache_destroy(cachep);
 }
 static DECLARE_WORK(kmem_cache_destroy_work, kmem_cache_destroy_work_func);
@@ -2973,7 +2989,7 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
 	 * We have to defer the actual destroying to a workqueue, because
 	 * we might currently be in a context that cannot sleep.
 	 */
-	schedule_work(&cachep->memcg_params->destroy);
+	schedule_delayed_work(&cachep->memcg_params->destroy, 0);
 }
 
 /*
@@ -3137,9 +3153,9 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 	list_for_each_entry(cachep, &memcg->memcg_slab_caches, list) {
 
 		cachep->memcg_params->dead = true;
-		INIT_WORK(&cachep->memcg_params->destroy,
-			  kmem_cache_destroy_work_func);
-		schedule_work(&cachep->memcg_params->destroy);
+		INIT_DELAYED_WORK(&cachep->memcg_params->destroy,
+				  kmem_cache_destroy_work_func);
+		schedule_delayed_work(&cachep->memcg_params->destroy, 0);
 	}
 	mutex_unlock(&memcg->slab_caches_mutex);
 }
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
