Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 50D0B6B006E
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:55:44 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so11754386pdj.9
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 04:55:44 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ur7si12255919pac.51.2015.01.26.04.55.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 04:55:43 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 2/3] slab: zap kmem_cache_shrink return value
Date: Mon, 26 Jan 2015 15:55:28 +0300
Message-ID: <b89d28384f8ec7865c3fefc2f025955d55798b78.1422275084.git.vdavydov@parallels.com>
In-Reply-To: <cover.1422275084.git.vdavydov@parallels.com>
References: <cover.1422275084.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The kmem_cache_shrink() return value is inconsistent: for SLAB it
returns 0 iff the cache is empty, while for SLUB and SLOB it always
returns 0. So let's zap it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    2 +-
 mm/slab.c            |    9 +++++++--
 mm/slab.h            |    2 +-
 mm/slab_common.c     |    8 ++------
 mm/slob.c            |    3 +--
 mm/slub.c            |   12 ++++--------
 6 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index ed2ffaab59ea..18430ed916b1 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -116,7 +116,7 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
-int kmem_cache_shrink(struct kmem_cache *);
+void kmem_cache_shrink(struct kmem_cache *);
 
 void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
 void memcg_deactivate_kmem_caches(struct mem_cgroup *);
diff --git a/mm/slab.c b/mm/slab.c
index 7894017bc160..279c44d6d8e1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2382,7 +2382,7 @@ out:
 	return nr_freed;
 }
 
-int __kmem_cache_shrink(struct kmem_cache *cachep)
+static int __cache_shrink(struct kmem_cache *cachep)
 {
 	int ret = 0;
 	int node;
@@ -2400,11 +2400,16 @@ int __kmem_cache_shrink(struct kmem_cache *cachep)
 	return (ret ? 1 : 0);
 }
 
+void __kmem_cache_shrink(struct kmem_cache *cachep)
+{
+	__cache_shrink(cachep);
+}
+
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
 	int i;
 	struct kmem_cache_node *n;
-	int rc = __kmem_cache_shrink(cachep);
+	int rc = __cache_shrink(cachep);
 
 	if (rc)
 		return rc;
diff --git a/mm/slab.h b/mm/slab.h
index 0a56d76ac0e9..c036e520d2cf 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -138,7 +138,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 #define CACHE_CREATE_MASK (SLAB_CORE_FLAGS | SLAB_DEBUG_FLAGS | SLAB_CACHE_FLAGS)
 
 int __kmem_cache_shutdown(struct kmem_cache *);
-int __kmem_cache_shrink(struct kmem_cache *);
+void __kmem_cache_shrink(struct kmem_cache *);
 void slab_kmem_cache_release(struct kmem_cache *);
 
 struct seq_file;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 0dd9eb4e0f87..6803639fdff0 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -641,18 +641,14 @@ EXPORT_SYMBOL(kmem_cache_destroy);
  * @cachep: The cache to shrink.
  *
  * Releases as many slabs as possible for a cache.
- * To help debugging, a zero exit status indicates all slabs were released.
  */
-int kmem_cache_shrink(struct kmem_cache *cachep)
+void kmem_cache_shrink(struct kmem_cache *cachep)
 {
-	int ret;
-
 	get_online_cpus();
 	get_online_mems();
-	ret = __kmem_cache_shrink(cachep);
+	__kmem_cache_shrink(cachep);
 	put_online_mems();
 	put_online_cpus();
-	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
diff --git a/mm/slob.c b/mm/slob.c
index 96a86206a26b..043a14b6ccbe 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -618,9 +618,8 @@ int __kmem_cache_shutdown(struct kmem_cache *c)
 	return 0;
 }
 
-int __kmem_cache_shrink(struct kmem_cache *d)
+void __kmem_cache_shrink(struct kmem_cache *c)
 {
-	return 0;
 }
 
 struct kmem_cache kmem_cache_boot = {
diff --git a/mm/slub.c b/mm/slub.c
index 770bea3ed445..c09d93dde40e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3368,7 +3368,7 @@ EXPORT_SYMBOL(kfree);
  * being allocated from last increasing the chance that the last objects
  * are freed in them.
  */
-int __kmem_cache_shrink(struct kmem_cache *s)
+void __kmem_cache_shrink(struct kmem_cache *s)
 {
 	int node;
 	int i;
@@ -3430,7 +3430,6 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 
 	if (slabs_by_inuse != &empty_slabs)
 		kfree(slabs_by_inuse);
-	return 0;
 }
 
 static int slab_mem_going_offline_callback(void *arg)
@@ -4696,12 +4695,9 @@ static ssize_t shrink_show(struct kmem_cache *s, char *buf)
 static ssize_t shrink_store(struct kmem_cache *s,
 			const char *buf, size_t length)
 {
-	if (buf[0] == '1') {
-		int rc = kmem_cache_shrink(s);
-
-		if (rc)
-			return rc;
-	} else
+	if (buf[0] == '1')
+		kmem_cache_shrink(s);
+	else
 		return -EINVAL;
 	return length;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
