Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 8997A8D0020
	for <linux-mm@kvack.org>; Fri, 11 May 2012 13:51:30 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 28/29] slub: track all children of a kmem cache
Date: Fri, 11 May 2012 14:44:30 -0300
Message-Id: <1336758272-24284-29-git-send-email-glommer@parallels.com>
In-Reply-To: <1336758272-24284-1-git-send-email-glommer@parallels.com>
References: <1336758272-24284-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

When we destroy a cache (like for instance, if we're unloading a module)
we need to go through the list of memcg caches and destroy them as well.

The caches are expected to be empty by themselves, so nothing is changed
here. All previous guarantees are kept and no new guarantees are given.

So given all memcg caches are expected to be empty - even though they are
likely to be hanging around in the system, we just need to scan a list of
sibling caches, and destroy each one of them.

This is very similar to the work done by Suleiman for the slab.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
---
 mm/slub.c |   61 +++++++++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 47 insertions(+), 14 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index afe29ef..cfa6295 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3267,6 +3267,20 @@ static inline int kmem_cache_close(struct kmem_cache *s)
 	return 0;
 }
 
+void kmem_cache_destroy_unlocked(struct kmem_cache *s)
+{
+	mem_cgroup_release_cache(s);
+	if (kmem_cache_close(s)) {
+		printk(KERN_ERR "SLUB %s: %s called for cache that "
+			"still has objects.\n", s->name, __func__);
+		dump_stack();
+	}
+
+	if (s->flags & SLAB_DESTROY_BY_RCU)
+		rcu_barrier();
+	sysfs_slab_remove(s);
+}
+
 /*
  * Close a cache and release the kmem_cache structure
  * (must be used for caches created using kmem_cache_create)
@@ -3275,24 +3289,41 @@ void kmem_cache_destroy(struct kmem_cache *s)
 {
 	down_write(&slub_lock);
 	s->refcount--;
-	if (!s->refcount) {
-		list_del(&s->list);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
-		/* Not a memcg cache */
-		if (s->memcg_params.id != -1) {
-			mem_cgroup_release_cache(s);
-			mem_cgroup_flush_cache_create_queue();
+	/* Not a memcg cache */
+	if (s->memcg_params.id != -1) {
+		struct mem_cgroup_cache_params *p, *tmp, *this;
+		struct kmem_cache *c;
+		int id = s->memcg_params.id;
+
+		this = &s->memcg_params;
+		mem_cgroup_flush_cache_create_queue();
+		list_for_each_entry_safe(p, tmp, &this->sibling_list, sibling_list) {
+			c = container_of(p, struct kmem_cache, memcg_params);
+			/* We never added the main cache to the sibling list */
+			if (WARN_ON(c == s))
+				continue;
+
+			c->refcount--;
+			if (c->refcount)
+				continue;
+
+			list_del(&c->list);
+			list_del(&c->memcg_params.sibling_list);
+			s->refcount--; /* parent reference */
+			up_write(&slub_lock);
+			mem_cgroup_remove_child_kmem_cache(c, id);
+			kmem_cache_destroy_unlocked(c);
+			down_write(&slub_lock);
 		}
+	}
 #endif
+
+	if (!s->refcount) {
+		list_del(&s->list);
 		up_write(&slub_lock);
-		if (kmem_cache_close(s)) {
-			printk(KERN_ERR "SLUB %s: %s called for cache that "
-				"still has objects.\n", s->name, __func__);
-			dump_stack();
-		}
-		if (s->flags & SLAB_DESTROY_BY_RCU)
-			rcu_barrier();
-		sysfs_slab_remove(s);
+		kmem_cache_destroy_unlocked(s);
 	} else
 		up_write(&slub_lock);
 }
@@ -4150,6 +4181,8 @@ struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
 	 */
 	if (new) {
 		down_write(&slub_lock);
+		list_add(&new->memcg_params.sibling_list,
+			 &s->memcg_params.sibling_list);
 		s->refcount++;
 		up_write(&slub_lock);
 	}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
