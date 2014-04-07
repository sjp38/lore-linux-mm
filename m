Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5723E6B0036
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 05:45:40 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id 10so4528633lbg.35
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 02:45:39 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id am6si11759732lbc.192.2014.04.07.02.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Apr 2014 02:45:38 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 2/2] slab: get_online_mems for kmem_cache_{create,destroy,shrink}
Date: Mon, 7 Apr 2014 13:45:35 +0400
Message-ID: <d1b0a501b42052cdb9a510486a584e1a8e1dde76.1396857765.git.vdavydov@parallels.com>
In-Reply-To: <cover.1396857765.git.vdavydov@parallels.com>
References: <cover.1396857765.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

When we create a sl[au]b cache, we allocate kmem_cache_node structures
for each online NUMA node. To handle nodes taken online/offline, we
register memory hotplug notifier and allocate/free kmem_cache_node
corresponding to the node that changes its state for each kmem cache.

To synchronize between the two paths we hold the slab_mutex during both
the cache creationg/destruction path and while tuning per-node parts of
kmem caches in memory hotplug handler, but that's not quite right,
because it does not guarantee that a newly created cache will have all
kmem_cache_nodes initialized in case it races with memory hotplug. For
instance, in case of slub:

    CPU0                            CPU1
    ----                            ----
    kmem_cache_create:              online_pages:
     __kmem_cache_create:            slab_memory_callback:
                                      slab_mem_going_online_callback:
                                       lock slab_mutex
                                       for each slab_caches list entry
                                           allocate kmem_cache node
                                       unlock slab_mutex
      lock slab_mutex
      init_kmem_cache_nodes:
       for_each_node_state(node, N_NORMAL_MEMORY)
           allocate kmem_cache node
      add kmem_cache to slab_caches list
      unlock slab_mutex
                                    online_pages (continued):
                                     node_states_set_node

As a result we'll get a kmem cache with not all kmem_cache_nodes
allocated.

To avoid issues like that we should hold get/put_online_mems() during
the whole kmem cache creation/destruction/shrink paths, just like we
deal with cpu hotplug. This patch does the trick.

Note, that after it's applied, there is no need in taking the slab_mutex
for kmem_cache_shrink any more, so it is removed from there.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab.c        |   26 ++------------------------
 mm/slab.h        |    1 +
 mm/slab_common.c |   35 +++++++++++++++++++++++++++++++++--
 mm/slob.c        |    3 +--
 mm/slub.c        |    5 ++---
 5 files changed, 39 insertions(+), 31 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index eebc619ae33c..b33aae64e5d7 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2442,8 +2442,7 @@ out:
 	return nr_freed;
 }
 
-/* Called with slab_mutex held to protect against cpu hotplug */
-static int __cache_shrink(struct kmem_cache *cachep)
+int __kmem_cache_shrink(struct kmem_cache *cachep)
 {
 	int ret = 0, i = 0;
 	struct kmem_cache_node *n;
@@ -2464,32 +2463,11 @@ static int __cache_shrink(struct kmem_cache *cachep)
 	return (ret ? 1 : 0);
 }
 
-/**
- * kmem_cache_shrink - Shrink a cache.
- * @cachep: The cache to shrink.
- *
- * Releases as many slabs as possible for a cache.
- * To help debugging, a zero exit status indicates all slabs were released.
- */
-int kmem_cache_shrink(struct kmem_cache *cachep)
-{
-	int ret;
-	BUG_ON(!cachep || in_interrupt());
-
-	get_online_cpus();
-	mutex_lock(&slab_mutex);
-	ret = __cache_shrink(cachep);
-	mutex_unlock(&slab_mutex);
-	put_online_cpus();
-	return ret;
-}
-EXPORT_SYMBOL(kmem_cache_shrink);
-
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
 	int i;
 	struct kmem_cache_node *n;
-	int rc = __cache_shrink(cachep);
+	int rc = __kmem_cache_shrink(cachep);
 
 	if (rc)
 		return rc;
diff --git a/mm/slab.h b/mm/slab.h
index 3045316b7c9d..00a47de7631f 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -91,6 +91,7 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 #define CACHE_CREATE_MASK (SLAB_CORE_FLAGS | SLAB_DEBUG_FLAGS | SLAB_CACHE_FLAGS)
 
 int __kmem_cache_shutdown(struct kmem_cache *);
+int __kmem_cache_shrink(struct kmem_cache *);
 
 struct seq_file;
 struct file;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index f3cfccf76dda..955e34bae7ae 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -205,6 +205,8 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 	int err;
 
 	get_online_cpus();
+	get_online_mems();
+
 	mutex_lock(&slab_mutex);
 
 	err = kmem_cache_sanity_check(name, size);
@@ -239,6 +241,8 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 
 out_unlock:
 	mutex_unlock(&slab_mutex);
+
+	put_online_mems();
 	put_online_cpus();
 
 	if (err) {
@@ -272,6 +276,8 @@ void kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *root_c
 	char *cache_name;
 
 	get_online_cpus();
+	get_online_mems();
+
 	mutex_lock(&slab_mutex);
 
 	/*
@@ -299,6 +305,8 @@ void kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *root_c
 
 out_unlock:
 	mutex_unlock(&slab_mutex);
+
+	put_online_mems();
 	put_online_cpus();
 }
 
@@ -326,6 +334,8 @@ static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 void kmem_cache_destroy(struct kmem_cache *s)
 {
 	get_online_cpus();
+	get_online_mems();
+
 	mutex_lock(&slab_mutex);
 
 	s->refcount--;
@@ -354,15 +364,36 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	memcg_free_cache_params(s);
 	kfree(s->name);
 	kmem_cache_free(kmem_cache, s);
-	goto out_put_cpus;
+	goto out;
 
 out_unlock:
 	mutex_unlock(&slab_mutex);
-out_put_cpus:
+out:
+	put_online_mems();
 	put_online_cpus();
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
+/**
+ * kmem_cache_shrink - Shrink a cache.
+ * @cachep: The cache to shrink.
+ *
+ * Releases as many slabs as possible for a cache.
+ * To help debugging, a zero exit status indicates all slabs were released.
+ */
+int kmem_cache_shrink(struct kmem_cache *cachep)
+{
+	int ret;
+
+	get_online_cpus();
+	get_online_mems();
+	ret = __kmem_cache_shrink(cachep);
+	put_online_mems();
+	put_online_cpus();
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_shrink);
+
 int slab_is_available(void)
 {
 	return slab_state >= UP;
diff --git a/mm/slob.c b/mm/slob.c
index 730cad45d4be..21980e0f39a8 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -620,11 +620,10 @@ int __kmem_cache_shutdown(struct kmem_cache *c)
 	return 0;
 }
 
-int kmem_cache_shrink(struct kmem_cache *d)
+int __kmem_cache_shrink(struct kmem_cache *d)
 {
 	return 0;
 }
-EXPORT_SYMBOL(kmem_cache_shrink);
 
 struct kmem_cache kmem_cache_boot = {
 	.name = "kmem_cache",
diff --git a/mm/slub.c b/mm/slub.c
index d72d69e25012..09660b9ff5bd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3412,7 +3412,7 @@ EXPORT_SYMBOL(kfree);
  * being allocated from last increasing the chance that the last objects
  * are freed in them.
  */
-int kmem_cache_shrink(struct kmem_cache *s)
+int __kmem_cache_shrink(struct kmem_cache *s)
 {
 	int node;
 	int i;
@@ -3468,7 +3468,6 @@ int kmem_cache_shrink(struct kmem_cache *s)
 	kfree(slabs_by_inuse);
 	return 0;
 }
-EXPORT_SYMBOL(kmem_cache_shrink);
 
 static int slab_mem_going_offline_callback(void *arg)
 {
@@ -3476,7 +3475,7 @@ static int slab_mem_going_offline_callback(void *arg)
 
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list)
-		kmem_cache_shrink(s);
+		__kmem_cache_shrink(s);
 	mutex_unlock(&slab_mutex);
 
 	return 0;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
