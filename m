Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 103BC6B006E
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:09:10 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 25/29] memcg/sl[au]b: shrink dead caches
Date: Thu,  1 Nov 2012 16:07:41 +0400
Message-Id: <1351771665-11076-26-git-send-email-glommer@parallels.com>
In-Reply-To: <1351771665-11076-1-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

This means that when we destroy a memcg cache that happened to be empty,
those caches may take a lot of time to go away: removing the memcg
reference won't destroy them - because there are pending references, and
the empty pages will stay there, until a shrinker is called upon for any
reason.

In this patch, we will call kmem_cache_shrink for all dead caches that
cannot be destroyed because of remaining pages. After shrinking, it is
possible that it could be freed. If this is not the case, we'll schedule
a lazy worker to keep trying.

[ v2: also call verify_dead for the slab ]
[ v3: use delayed_work to avoid calling verify_dead at every free]
[ v6: do not spawn worker if work is already pending ]

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
 mm/memcontrol.c      | 55 ++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 50 insertions(+), 7 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index ef2314e..0df42db 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -214,7 +214,7 @@ struct memcg_cache_params {
 			struct kmem_cache *root_cache;
 			bool dead;
 			atomic_t nr_pages;
-			struct work_struct destroy;
+			struct delayed_work destroy;
 		};
 	};
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 31da8bc..6e2575a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3048,12 +3048,35 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
 {
 	struct kmem_cache *cachep;
 	struct memcg_cache_params *p;
+	struct delayed_work *dw = to_delayed_work(w);
 
-	p = container_of(w, struct memcg_cache_params, destroy);
+	p = container_of(dw, struct memcg_cache_params, destroy);
 
 	cachep = memcg_params_to_cache(p);
 
-	if (!atomic_read(&cachep->memcg_params->nr_pages))
+	/*
+	 * If we get down to 0 after shrink, we could delete right away.
+	 * However, memcg_release_pages() already puts us back in the workqueue
+	 * in that case. If we proceed deleting, we'll get a dangling
+	 * reference, and removing the object from the workqueue in that case
+	 * is unnecessary complication. We are not a fast path.
+	 *
+	 * Note that this case is fundamentally different from racing with
+	 * shrink_slab(): if memcg_cgroup_destroy_cache() is called in
+	 * kmem_cache_shrink, not only we would be reinserting a dead cache
+	 * into the queue, but doing so from inside the worker racing to
+	 * destroy it.
+	 *
+	 * So if we aren't down to zero, we'll just schedule a worker and try
+	 * again
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
 
@@ -3063,10 +3086,30 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
 		return;
 
 	/*
+	 * There are many ways in which we can get here.
+	 *
+	 * We can get to a memory-pressure situation while the delayed work is
+	 * still pending to run. The vmscan shrinkers can then release all
+	 * cache memory and get us to destruction. If this is the case, we'll
+	 * be executed twice, which is a bug (the second time will execute over
+	 * bogus data). In this case, cancelling the work should be fine.
+	 *
+	 * But we can also get here from the worker itself, if
+	 * kmem_cache_shrink is enough to shake all the remaining objects and
+	 * get the page count to 0. In this case, we'll deadlock if we try to
+	 * cancel the work (the worker runs with an internal lock held, which
+	 * is the same lock we would hold for cancel_delayed_work_sync().)
+	 *
+	 * Since we can't possibly know who got us here, just refrain from
+	 * running if there is already work pending
+	 */
+	if (delayed_work_pending(&cachep->memcg_params->destroy))
+		return;
+	/*
 	 * We have to defer the actual destroying to a workqueue, because
 	 * we might currently be in a context that cannot sleep.
 	 */
-	schedule_work(&cachep->memcg_params->destroy);
+	schedule_delayed_work(&cachep->memcg_params->destroy, 0);
 }
 
 static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
@@ -3218,9 +3261,9 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 	list_for_each_entry(params, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
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
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
