Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 900CB6B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 04:36:56 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Date: Wed, 27 Mar 2013 09:36:39 +0100
Message-Id: <1364373399-17397-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

As cgroup supports rename, it's unsafe to dereference dentry->d_name
without proper vfs locks. Fix this by using cgroup_name() rather than
dentry directly.

Also open code memcg_cache_name because it is called only from
kmem_cache_dup which frees the returned name right after
kmem_cache_create_memcg makes a copy of it. Such a short-lived
allocation doesn't make too much sense. So replace it by a static
buffer as kmem_cache_dup is called with memcg_cache_mutex.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Glauber Costa <glommer@parallels.com>
---
 mm/memcontrol.c |   64 ++++++++++++++++++++++++++++---------------------------
 1 file changed, 33 insertions(+), 31 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f608546..b30547b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3364,52 +3364,54 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
 	schedule_work(&cachep->memcg_params->destroy);
 }
 
-static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
-{
-	char *name;
-	struct dentry *dentry;
-
-	rcu_read_lock();
-	dentry = rcu_dereference(memcg->css.cgroup->dentry);
-	rcu_read_unlock();
-
-	BUG_ON(dentry == NULL);
-
-	name = kasprintf(GFP_KERNEL, "%s(%d:%s)", s->name,
-			 memcg_cache_id(memcg), dentry->d_name.name);
-
-	return name;
-}
+/*
+ * This lock protects updaters, not readers. We want readers to be as fast as
+ * they can, and they will either see NULL or a valid cache value. Our model
+ * allow them to see NULL, in which case the root memcg will be selected.
+ *
+ * We need this lock because multiple allocations to the same cache from a non
+ * will span more than one worker. Only one of them can create the cache.
+ */
+static DEFINE_MUTEX(memcg_cache_mutex);
 
+/*
+ * Called with memcg_cache_mutex held
+ */
 static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
 					 struct kmem_cache *s)
 {
-	char *name;
 	struct kmem_cache *new;
+	static char *tmp_name = NULL;
 
-	name = memcg_cache_name(memcg, s);
-	if (!name)
-		return NULL;
+	lockdep_assert_held(&memcg_cache_mutex);
+
+	/*
+	 * kmem_cache_create_memcg duplicates the given name and
+	 * cgroup_name for this name requires RCU context.
+	 * This static temporary buffer is used to prevent from
+	 * pointless shortliving allocation.
+	 */
+	if (!tmp_name) {
+		tmp_name = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		WARN_ON_ONCE(!tmp_name);
+		if (!tmp_name)
+			return NULL;
+	}
+
+	rcu_read_lock();
+	snprintf(tmp_name, PAGE_SIZE, "%s(%d:%s)", s->name,
+			 memcg_cache_id(memcg), cgroup_name(memcg->css.cgroup));
+	rcu_read_unlock();
 
-	new = kmem_cache_create_memcg(memcg, name, s->object_size, s->align,
+	new = kmem_cache_create_memcg(memcg, tmp_name, s->object_size, s->align,
 				      (s->flags & ~SLAB_PANIC), s->ctor, s);
 
 	if (new)
 		new->allocflags |= __GFP_KMEMCG;
 
-	kfree(name);
 	return new;
 }
 
-/*
- * This lock protects updaters, not readers. We want readers to be as fast as
- * they can, and they will either see NULL or a valid cache value. Our model
- * allow them to see NULL, in which case the root memcg will be selected.
- *
- * We need this lock because multiple allocations to the same cache from a non
- * will span more than one worker. Only one of them can create the cache.
- */
-static DEFINE_MUTEX(memcg_cache_mutex);
 static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 						  struct kmem_cache *cachep)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
