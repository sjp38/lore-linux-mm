Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 23EB26B0039
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 21:58:48 -0400 (EDT)
Message-ID: <51BA77DD.1000103@huawei.com>
Date: Fri, 14 Jun 2013 09:54:37 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v4 4/9] memcg: don't use mem_cgroup_get() when creating a
 kmemcg cache
References: <51BA7794.2000305@huawei.com>
In-Reply-To: <51BA7794.2000305@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

Use css_get()/css_put() instead of mem_cgroup_get()/mem_cgroup_put().

There are two things being done in the current code:

First, we acquired a css_ref to make sure that the underlying cgroup
would not go away. That is a short lived reference, and it is put as
soon as the cache is created.

At this point, we acquire a long-lived per-cache memcg reference count
to guarantee that the memcg will still be alive.

so it is:

enqueue: css_get
create : memcg_get, css_put
destroy: memcg_put

So we only need to get rid of the memcg_get, change the memcg_put to
css_put, and get rid of the now extra css_put.

(This changelog is mostly written by Glauber)

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a8e8d2a..466c595 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3252,7 +3252,7 @@ void memcg_release_cache(struct kmem_cache *s)
 	list_del(&s->memcg_params->list);
 	mutex_unlock(&memcg->slab_caches_mutex);
 
-	mem_cgroup_put(memcg);
+	css_put(&memcg->css);
 out:
 	kfree(s->memcg_params);
 }
@@ -3412,16 +3412,18 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	mutex_lock(&memcg_cache_mutex);
 	new_cachep = cachep->memcg_params->memcg_caches[idx];
-	if (new_cachep)
+	if (new_cachep) {
+		css_put(&memcg->css);
 		goto out;
+	}
 
 	new_cachep = kmem_cache_dup(memcg, cachep);
 	if (new_cachep == NULL) {
 		new_cachep = cachep;
+		css_put(&memcg->css);
 		goto out;
 	}
 
-	mem_cgroup_get(memcg);
 	atomic_set(&new_cachep->memcg_params->nr_pages , 0);
 
 	cachep->memcg_params->memcg_caches[idx] = new_cachep;
@@ -3509,8 +3511,6 @@ static void memcg_create_cache_work_func(struct work_struct *w)
 
 	cw = container_of(w, struct create_work, work);
 	memcg_create_kmem_cache(cw->memcg, cw->cachep);
-	/* Drop the reference gotten when we enqueued. */
-	css_put(&cw->memcg->css);
 	kfree(cw);
 }
 
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
