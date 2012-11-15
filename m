Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 7F2BC6B0099
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:55:00 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 5/7] memcg: get rid of once-per-second cache shrinking for dead memcgs
Date: Thu, 15 Nov 2012 06:54:51 +0400
Message-Id: <1352948093-2315-6-git-send-email-glommer@parallels.com>
In-Reply-To: <1352948093-2315-1-git-send-email-glommer@parallels.com>
References: <1352948093-2315-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

The idea is to synchronously do it, leaving it up to the shrinking
facilities in vmscan.c and/or others. Not actively retrying shrinking
may leave the caches alive for more time, but it will remove the ugly
wakeups. One would argue that if the caches have free objects but are
not being shrunk, it is because we don't need that memory yet.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/slab.h |  2 +-
 mm/memcontrol.c      | 17 +++++++----------
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 18f8c98..456c327 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -214,7 +214,7 @@ struct memcg_cache_params {
 			struct kmem_cache *root_cache;
 			bool dead;
 			atomic_t nr_pages;
-			struct delayed_work destroy;
+			struct work_struct destroy;
 		};
 	};
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f9c5981..e3d805f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3077,9 +3077,8 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
 {
 	struct kmem_cache *cachep;
 	struct memcg_cache_params *p;
-	struct delayed_work *dw = to_delayed_work(w);
 
-	p = container_of(dw, struct memcg_cache_params, destroy);
+	p = container_of(w, struct memcg_cache_params, destroy);
 
 	cachep = memcg_params_to_cache(p);
 
@@ -3103,8 +3102,6 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
 		kmem_cache_shrink(cachep);
 		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
 			return;
-		/* Once per minute should be good enough. */
-		schedule_delayed_work(&cachep->memcg_params->destroy, 60 * HZ);
 	} else
 		kmem_cache_destroy(cachep);
 }
@@ -3127,18 +3124,18 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
 	 * kmem_cache_shrink is enough to shake all the remaining objects and
 	 * get the page count to 0. In this case, we'll deadlock if we try to
 	 * cancel the work (the worker runs with an internal lock held, which
-	 * is the same lock we would hold for cancel_delayed_work_sync().)
+	 * is the same lock we would hold for cancel_work_sync().)
 	 *
 	 * Since we can't possibly know who got us here, just refrain from
 	 * running if there is already work pending
 	 */
-	if (delayed_work_pending(&cachep->memcg_params->destroy))
+	if (work_pending(&cachep->memcg_params->destroy))
 		return;
 	/*
 	 * We have to defer the actual destroying to a workqueue, because
 	 * we might currently be in a context that cannot sleep.
 	 */
-	schedule_delayed_work(&cachep->memcg_params->destroy, 0);
+	schedule_work(&cachep->memcg_params->destroy);
 }
 
 static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
@@ -3261,7 +3258,7 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		 * set, so flip it down to guarantee we are in control.
 		 */
 		c->memcg_params->dead = false;
-		cancel_delayed_work_sync(&c->memcg_params->destroy);
+		cancel_work_sync(&c->memcg_params->destroy);
 		kmem_cache_destroy(c);
 	}
 	mutex_unlock(&set_limit_mutex);
@@ -3285,9 +3282,9 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 	list_for_each_entry(params, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
 		cachep->memcg_params->dead = true;
-		INIT_DELAYED_WORK(&cachep->memcg_params->destroy,
+		INIT_WORK(&cachep->memcg_params->destroy,
 				  kmem_cache_destroy_work_func);
-		schedule_delayed_work(&cachep->memcg_params->destroy, 0);
+		schedule_work(&cachep->memcg_params->destroy);
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
