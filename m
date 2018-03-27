Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA8966B0008
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 19:06:11 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p128so242124pga.19
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 16:06:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k1-v6sor1094796pld.149.2018.03.27.16.06.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 16:06:10 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] slab, slub: skip unnecessary kasan_cache_shutdown()
Date: Tue, 27 Mar 2018 16:06:03 -0700
Message-Id: <20180327230603.54721-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Potapenko <glider@google.com>, Greg Thelen <gthelen@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

The kasan quarantine is designed to delay freeing slab objects to catch
use-after-free. The quarantine can be large (several percent of machine
memory size). When kmem_caches are deleted related objects are flushed
from the quarantine but this requires scanning the entire quarantine
which can be very slow. We have seen the kernel busily working on this
while holding slab_mutex and badly affecting cache_reaper, slabinfo
readers and memcg kmem cache creations.

It can easily reproduced by following script:

	yes . | head -1000000 | xargs stat > /dev/null
	for i in `seq 1 10`; do
		seq 500 | (cd /cg/memory && xargs mkdir)
		seq 500 | xargs -I{} sh -c 'echo $BASHPID > \
			/cg/memory/{}/tasks && exec stat .' > /dev/null
		seq 500 | (cd /cg/memory && xargs rmdir)
	done

The busy stack:
    kasan_cache_shutdown
    shutdown_cache
    memcg_destroy_kmem_caches
    mem_cgroup_css_free
    css_free_rwork_fn
    process_one_work
    worker_thread
    kthread
    ret_from_fork

This patch is based on the observation that if the kmem_cache to be
destroyed is empty then there should not be any objects of this cache in
the quarantine.

Without the patch the script got stuck for couple of hours. With the
patch the script completed within a second.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/kasan/kasan.c |  3 ++-
 mm/slab.c        | 12 ++++++++++++
 mm/slab.h        |  1 +
 mm/slub.c        | 11 +++++++++++
 4 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 49fffb0ca83b..135ce2838c89 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -382,7 +382,8 @@ void kasan_cache_shrink(struct kmem_cache *cache)
 
 void kasan_cache_shutdown(struct kmem_cache *cache)
 {
-	quarantine_remove_cache(cache);
+	if (!__kmem_cache_empty(cache))
+		quarantine_remove_cache(cache);
 }
 
 size_t kasan_metadata_size(struct kmem_cache *cache)
diff --git a/mm/slab.c b/mm/slab.c
index 9212c64bb705..b59f2cdf28d1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2291,6 +2291,18 @@ static int drain_freelist(struct kmem_cache *cache,
 	return nr_freed;
 }
 
+bool __kmem_cache_empty(struct kmem_cache *s)
+{
+	int node;
+	struct kmem_cache_node *n;
+
+	for_each_kmem_cache_node(s, node, n)
+		if (!list_empty(&n->slabs_full) ||
+		    !list_empty(&n->slabs_partial))
+			return false;
+	return true;
+}
+
 int __kmem_cache_shrink(struct kmem_cache *cachep)
 {
 	int ret = 0;
diff --git a/mm/slab.h b/mm/slab.h
index e8981e811c45..68bdf498da3b 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -166,6 +166,7 @@ static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
 			      SLAB_TEMPORARY | \
 			      SLAB_ACCOUNT)
 
+bool __kmem_cache_empty(struct kmem_cache *);
 int __kmem_cache_shutdown(struct kmem_cache *);
 void __kmem_cache_release(struct kmem_cache *);
 int __kmem_cache_shrink(struct kmem_cache *);
diff --git a/mm/slub.c b/mm/slub.c
index 1edc8d97c862..44aa7847324a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3707,6 +3707,17 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 		discard_slab(s, page);
 }
 
+bool __kmem_cache_empty(struct kmem_cache *s)
+{
+	int node;
+	struct kmem_cache_node *n;
+
+	for_each_kmem_cache_node(s, node, n)
+		if (n->nr_partial || slabs_node(s, node))
+			return false;
+	return true;
+}
+
 /*
  * Release all resources used by a slab cache.
  */
-- 
2.17.0.rc1.321.gba9d0f2565-goog
