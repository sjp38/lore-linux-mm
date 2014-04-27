Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 65B366B0068
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 05:04:19 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id l4so4148378lbv.4
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 02:04:18 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id s2si2788579las.0.2014.04.27.02.04.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Apr 2014 02:04:17 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 3/6] memcg: cleanup memcg_caches arrays relocation path
Date: Sun, 27 Apr 2014 13:04:05 +0400
Message-ID: <451dccda56caa074f5c5362f13c111415d007af3.1398587474.git.vdavydov@parallels.com>
In-Reply-To: <cover.1398587474.git.vdavydov@parallels.com>
References: <cover.1398587474.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Current memcg_caches arrays relocation path looks rather awkward: on
setting kmem limit we call memcg_update_all_caches located on slab's
side, which walks over all root caches and calls back to memcontrol.c
through memcg_update_cache_size and memcg_update_array_size, which in
turn reallocate the memcg_caches array for a particular cache and update
the arrays' size respectively.

The first call from memcontrol.c to slab_common.c, which is
memcg_update_all_caches, is justified, because to iterate over root
caches we have to take the slab_mutex. However, I don't see any reason
why we can't reallocate a memcg_caches array on the slab's size or why
we should call memcg_update_cache_size under the slab_mutex. So let's
clean up this mess.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    3 --
 include/linux/slab.h       |    3 +-
 mm/memcontrol.c            |  125 +++++++++++++-------------------------------
 mm/slab_common.c           |   36 ++++++++-----
 4 files changed, 61 insertions(+), 106 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index dfc2929a3877..6e59393e03f9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -496,9 +496,6 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache);
 void memcg_free_cache_params(struct kmem_cache *s);
 
-int memcg_update_cache_size(struct kmem_cache *s, int num_groups);
-void memcg_update_array_size(int num_groups);
-
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 095ce8e47a36..c437be67917b 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -120,6 +120,7 @@ struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *,
 					   struct kmem_cache *,
 					   const char *);
 int kmem_cache_init_memcg_array(struct kmem_cache *, int);
+int kmem_cache_memcg_arrays_grow(int);
 #endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
@@ -545,8 +546,6 @@ struct memcg_cache_params {
 	};
 };
 
-int memcg_update_all_caches(int num_memcgs);
-
 struct seq_file;
 int cache_show(struct kmem_cache *s, struct seq_file *m);
 void print_slabinfo_header(struct seq_file *m);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 08937040ed75..714d7bd7f140 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3027,84 +3027,52 @@ int memcg_cache_id(struct mem_cgroup *memcg)
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
-static size_t memcg_caches_array_size(int num_groups)
+static int memcg_init_cache_id(struct mem_cgroup *memcg)
 {
-	ssize_t size;
-	if (num_groups <= 0)
-		return 0;
+	int err = 0;
+	int id, size;
+
+	lockdep_assert_held(&activate_kmem_mutex);
+
+	id = ida_simple_get(&kmem_limited_groups,
+			    0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
+	if (id < 0)
+		return id;
 
-	size = 2 * num_groups;
+	if (id < memcg_limited_groups_array_size)
+		goto out_setid;
+
+	/*
+	 * We don't have enough space for the new id in the arrays that store
+	 * per memcg data. Let's try to grow them then.
+	 */
+	size = id * 2;
 	if (size < MEMCG_CACHES_MIN_SIZE)
 		size = MEMCG_CACHES_MIN_SIZE;
 	else if (size > MEMCG_CACHES_MAX_SIZE)
 		size = MEMCG_CACHES_MAX_SIZE;
 
-	return size;
-}
-
-/*
- * We should update the current array size iff all caches updates succeed. This
- * can only be done from the slab side. The slab mutex needs to be held when
- * calling this.
- */
-void memcg_update_array_size(int num)
-{
-	if (num > memcg_limited_groups_array_size)
-		memcg_limited_groups_array_size = memcg_caches_array_size(num);
-}
-
-int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
-{
-	struct memcg_cache_params *cur_params = s->memcg_params;
-
-	VM_BUG_ON(!is_root_cache(s));
-
-	if (!cur_params)
-		return 0;
-
-	if (num_groups > memcg_limited_groups_array_size) {
-		int i;
-		struct memcg_cache_params *new_params;
-		ssize_t size = memcg_caches_array_size(num_groups);
-
-		size *= sizeof(void *);
-		size += offsetof(struct memcg_cache_params, memcg_caches);
-
-		new_params = kzalloc(size, GFP_KERNEL);
-		if (!new_params)
-			return -ENOMEM;
+	mutex_lock(&memcg_slab_mutex);
+	err = kmem_cache_memcg_arrays_grow(size);
+	mutex_unlock(&memcg_slab_mutex);
 
-		new_params->is_root_cache = true;
+	if (err)
+		goto out_rmid;
 
-		/*
-		 * There is the chance it will be bigger than
-		 * memcg_limited_groups_array_size, if we failed an allocation
-		 * in a cache, in which case all caches updated before it, will
-		 * have a bigger array.
-		 *
-		 * But if that is the case, the data after
-		 * memcg_limited_groups_array_size is certainly unused
-		 */
-		for (i = 0; i < memcg_limited_groups_array_size; i++) {
-			if (!cur_params->memcg_caches[i])
-				continue;
-			new_params->memcg_caches[i] =
-						cur_params->memcg_caches[i];
-		}
+	/*
+	 * Update the arrays' size only after we grew them so that readers
+	 * walking over such an array won't get an index out of range provided
+	 * they use an appropriate mutex to protect the array's elements.
+	 */
+	memcg_limited_groups_array_size = size;
 
-		/*
-		 * Ideally, we would wait until all caches succeed, and only
-		 * then free the old one. But this is not worth the extra
-		 * pointer per-cache we'd have to have for this.
-		 *
-		 * It is not a big deal if some caches are left with a size
-		 * bigger than the others. And all updates will reset this
-		 * anyway.
-		 */
-		rcu_assign_pointer(s->memcg_params, new_params);
-		kfree_rcu(cur_params, rcu_head);
-	}
+out_setid:
+	memcg->kmemcg_id = id;
 	return 0;
+
+out_rmid:
+	ida_simple_remove(&kmem_limited_groups, id);
+	return err;
 }
 
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
@@ -4950,7 +4918,6 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 				 unsigned long long limit)
 {
 	int err = 0;
-	int memcg_id;
 
 	if (memcg_kmem_is_active(memcg))
 		return 0;
@@ -4980,24 +4947,10 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 	if (err)
 		goto out;
 
-	memcg_id = ida_simple_get(&kmem_limited_groups,
-				  0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
-	if (memcg_id < 0) {
-		err = memcg_id;
-		goto out;
-	}
-
-	/*
-	 * Make sure we have enough space for this cgroup in each root cache's
-	 * memcg_params.
-	 */
-	mutex_lock(&memcg_slab_mutex);
-	err = memcg_update_all_caches(memcg_id + 1);
-	mutex_unlock(&memcg_slab_mutex);
+	err = memcg_init_cache_id(memcg);
 	if (err)
-		goto out_rmid;
+		goto out;
 
-	memcg->kmemcg_id = memcg_id;
 	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
 
 	/*
@@ -5017,10 +4970,6 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 out:
 	memcg_resume_kmem_account();
 	return err;
-
-out_rmid:
-	ida_simple_remove(&kmem_limited_groups, memcg_id);
-	goto out;
 }
 
 static int memcg_activate_kmem(struct mem_cgroup *memcg,
diff --git a/mm/slab_common.c b/mm/slab_common.c
index ce5e96aff4e6..801999247619 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -77,10 +77,17 @@ static inline int kmem_cache_sanity_check(const char *name, size_t size)
 #endif
 
 #ifdef CONFIG_MEMCG_KMEM
+/*
+ * (Re)allocates the memcg_caches array of the given kmem cache so that it
+ * can hold up to nr_entries. The caller must hold slab_mutex.
+ */
 static int __kmem_cache_init_memcg_array(struct kmem_cache *s, int nr_entries)
 {
+	int i;
 	size_t size;
-	struct memcg_cache_params *new;
+	struct memcg_cache_params *new, *old;
+
+	old = s->memcg_params;
 
 	size = offsetof(struct memcg_cache_params, memcg_caches);
 	size += nr_entries * sizeof(void *);
@@ -90,10 +97,15 @@ static int __kmem_cache_init_memcg_array(struct kmem_cache *s, int nr_entries)
 		return -ENOMEM;
 
 	new->is_root_cache = true;
+	if (old) {
+		for_each_memcg_cache_index(i)
+			new->memcg_caches[i] = old->memcg_caches[i];
+	}
 
 	/* matching rcu_dereference is in cache_from_memcg_idx */
 	rcu_assign_pointer(s->memcg_params, new);
-
+	if (old)
+		kfree_rcu(old, rcu_head);
 	return 0;
 }
 
@@ -110,32 +122,30 @@ int kmem_cache_init_memcg_array(struct kmem_cache *s, int nr_entries)
 	return ret;
 }
 
-int memcg_update_all_caches(int num_memcgs)
+int kmem_cache_memcg_arrays_grow(int nr_entries)
 {
 	struct kmem_cache *s;
 	int ret = 0;
-	mutex_lock(&slab_mutex);
 
+	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list) {
 		if (!is_root_cache(s))
 			continue;
 
-		ret = memcg_update_cache_size(s, num_memcgs);
+		ret = __kmem_cache_init_memcg_array(s, nr_entries);
 		/*
-		 * See comment in memcontrol.c, memcg_update_cache_size:
-		 * Instead of freeing the memory, we'll just leave the caches
-		 * up to this point in an updated state.
+		 * We won't shrink the arrays back to the initial size on
+		 * failure, because it isn't a big deal if some caches are left
+		 * with a size greater than others. Further updates will reset
+		 * this anyway.
 		 */
 		if (ret)
-			goto out;
+			break;
 	}
-
-	memcg_update_array_size(num_memcgs);
-out:
 	mutex_unlock(&slab_mutex);
 	return ret;
 }
-#endif
+#endif /* CONFIG_MEMCG_KMEM */
 
 /*
  * Figure out what the alignment of the objects will be given a set of
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
