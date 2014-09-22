Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E41E16B0038
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 12:01:01 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id et14so4745001pad.34
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 09:01:01 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id a1si16438300pat.36.2014.09.22.09.01.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 09:01:01 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v2 2/3] memcg: don't call memcg_update_all_caches if new cache id fits
Date: Mon, 22 Sep 2014 20:00:45 +0400
Message-ID: <3a44c70517de91297bd82c944da4c95468ddd91d.1411401021.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411401021.git.vdavydov@parallels.com>
References: <cover.1411401021.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

memcg_update_all_caches grows arrays of per-memcg caches, so we only
need to call it when memcg_limited_groups_array_size is increased.
However, currently we invoke it each time a new kmem-active memory
cgroup is created. Then it just iterates over all slab_caches and does
nothinng (memcg_update_cache_size returns immediately).

This patch fixes this insanity. In the meantime it moves the code
dealing with id allocations to separate functions, memcg_alloc_cache_id
and memcg_free_cache_id.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |  136 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 72 insertions(+), 64 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b6bbb1e3e2ab..55d131645b45 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -646,11 +646,13 @@ int memcg_limited_groups_array_size;
 struct static_key memcg_kmem_enabled_key;
 EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
+static void memcg_free_cache_id(int id);
+
 static void disarm_kmem_keys(struct mem_cgroup *memcg)
 {
 	if (memcg_kmem_is_active(memcg)) {
 		static_key_slow_dec(&memcg_kmem_enabled_key);
-		ida_simple_remove(&kmem_limited_groups, memcg->kmemcg_id);
+		memcg_free_cache_id(memcg->kmemcg_id);
 	}
 	/*
 	 * This check can't live in kmem destruction function,
@@ -2892,19 +2894,44 @@ int memcg_cache_id(struct mem_cgroup *memcg)
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
-static size_t memcg_caches_array_size(int num_groups)
+static int memcg_alloc_cache_id(void)
 {
-	ssize_t size;
-	if (num_groups <= 0)
-		return 0;
+	int id, size;
+	int err;
+
+	id = ida_simple_get(&kmem_limited_groups,
+			    0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
+	if (id < 0)
+		return id;
 
-	size = 2 * num_groups;
+	if (id < memcg_limited_groups_array_size)
+		return id;
+
+	/*
+	 * There's no space for the new id in memcg_caches arrays,
+	 * so we have to grow them.
+	 */
+
+	size = 2 * (id + 1);
 	if (size < MEMCG_CACHES_MIN_SIZE)
 		size = MEMCG_CACHES_MIN_SIZE;
 	else if (size > MEMCG_CACHES_MAX_SIZE)
 		size = MEMCG_CACHES_MAX_SIZE;
 
-	return size;
+	mutex_lock(&memcg_slab_mutex);
+	err = memcg_update_all_caches(size);
+	mutex_unlock(&memcg_slab_mutex);
+
+	if (err) {
+		ida_simple_remove(&kmem_limited_groups, id);
+		return err;
+	}
+	return id;
+}
+
+static void memcg_free_cache_id(int id)
+{
+	ida_simple_remove(&kmem_limited_groups, id);
 }
 
 /*
@@ -2914,59 +2941,55 @@ static size_t memcg_caches_array_size(int num_groups)
  */
 void memcg_update_array_size(int num)
 {
-	if (num > memcg_limited_groups_array_size)
-		memcg_limited_groups_array_size = memcg_caches_array_size(num);
+	memcg_limited_groups_array_size = num;
 }
 
 int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 {
 	struct memcg_cache_params *cur_params = s->memcg_params;
+	struct memcg_cache_params *new_params;
+	size_t size;
+	int i;
 
 	VM_BUG_ON(!is_root_cache(s));
 
-	if (num_groups > memcg_limited_groups_array_size) {
-		int i;
-		struct memcg_cache_params *new_params;
-		ssize_t size = memcg_caches_array_size(num_groups);
+	size = num_groups * sizeof(void *);
+	size += offsetof(struct memcg_cache_params, memcg_caches);
 
-		size *= sizeof(void *);
-		size += offsetof(struct memcg_cache_params, memcg_caches);
-
-		new_params = kzalloc(size, GFP_KERNEL);
-		if (!new_params)
-			return -ENOMEM;
-
-		new_params->is_root_cache = true;
+	new_params = kzalloc(size, GFP_KERNEL);
+	if (!new_params)
+		return -ENOMEM;
 
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
+	new_params->is_root_cache = true;
 
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
-		if (cur_params)
-			kfree_rcu(cur_params, rcu_head);
+	/*
+	 * There is the chance it will be bigger than
+	 * memcg_limited_groups_array_size, if we failed an allocation
+	 * in a cache, in which case all caches updated before it, will
+	 * have a bigger array.
+	 *
+	 * But if that is the case, the data after
+	 * memcg_limited_groups_array_size is certainly unused
+	 */
+	for (i = 0; i < memcg_limited_groups_array_size; i++) {
+		if (!cur_params->memcg_caches[i])
+			continue;
+		new_params->memcg_caches[i] =
+			cur_params->memcg_caches[i];
 	}
+
+	/*
+	 * Ideally, we would wait until all caches succeed, and only
+	 * then free the old one. But this is not worth the extra
+	 * pointer per-cache we'd have to have for this.
+	 *
+	 * It is not a big deal if some caches are left with a size
+	 * bigger than the others. And all updates will reset this
+	 * anyway.
+	 */
+	rcu_assign_pointer(s->memcg_params, new_params);
+	if (cur_params)
+		kfree_rcu(cur_params, rcu_head);
 	return 0;
 }
 
@@ -4167,23 +4190,12 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 	if (err)
 		goto out;
 
-	memcg_id = ida_simple_get(&kmem_limited_groups,
-				  0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
+	memcg_id = memcg_alloc_cache_id();
 	if (memcg_id < 0) {
 		err = memcg_id;
 		goto out;
 	}
 
-	/*
-	 * Make sure we have enough space for this cgroup in each root cache's
-	 * memcg_params.
-	 */
-	mutex_lock(&memcg_slab_mutex);
-	err = memcg_update_all_caches(memcg_id + 1);
-	mutex_unlock(&memcg_slab_mutex);
-	if (err)
-		goto out_rmid;
-
 	memcg->kmemcg_id = memcg_id;
 	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
 
@@ -4204,10 +4216,6 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 out:
 	memcg_resume_kmem_account();
 	return err;
-
-out_rmid:
-	ida_simple_remove(&kmem_limited_groups, memcg_id);
-	goto out;
 }
 
 static int memcg_activate_kmem(struct mem_cgroup *memcg,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
