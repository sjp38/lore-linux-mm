Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 312AC6B006E
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:52:04 -0400 (EDT)
Received: by qkhq76 with SMTP id q76so55906850qkh.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 08:52:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c78si11185725qgd.5.2015.06.15.08.52.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 08:52:03 -0700 (PDT)
Subject: [PATCH 1/7] slab: infrastructure for bulk object allocation and
 freeing
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 15 Jun 2015 17:51:56 +0200
Message-ID: <20150615155156.18824.35187.stgit@devil>
In-Reply-To: <20150615155053.18824.617.stgit@devil>
References: <20150615155053.18824.617.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>

From: Christoph Lameter <cl@linux.com>

[NOTICE: Already in AKPM's quilt-queue]

Add the basic infrastructure for alloc/free operations on pointer arrays.
It includes a generic function in the common slab code that is used in
this infrastructure patch to create the unoptimized functionality for slab
bulk operations.

Allocators can then provide optimized allocation functions for situations
in which large numbers of objects are needed.  These optimization may
avoid taking locks repeatedly and bypass metadata creation if all objects
in slab pages can be used to provide the objects required.

Allocators can extend the skeletons provided and add their own code to the
bulk alloc and free functions.  They can keep the generic allocation and
freeing and just fall back to those if optimizations would not work (like
for example when debugging is on).

Signed-off-by: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/slab.h |   10 ++++++++++
 mm/slab.c            |   13 +++++++++++++
 mm/slab.h            |    9 +++++++++
 mm/slab_common.c     |   23 +++++++++++++++++++++++
 mm/slob.c            |   13 +++++++++++++
 mm/slub.c            |   14 ++++++++++++++
 6 files changed, 82 insertions(+)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index ffd24c830151..5db59c950ef7 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -290,6 +290,16 @@ void *__kmalloc(size_t size, gfp_t flags);
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
 void kmem_cache_free(struct kmem_cache *, void *);
 
+/*
+ * Bulk allocation and freeing operations. These are accellerated in an
+ * allocator specific way to avoid taking locks repeatedly or building
+ * metadata structures unnecessarily.
+ *
+ * Note that interrupts must be enabled when calling these functions.
+ */
+void kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
+bool kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
+
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
diff --git a/mm/slab.c b/mm/slab.c
index 7eb38dd1cefa..c799d7ed0e18 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3415,6 +3415,19 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
+void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+{
+	__kmem_cache_free_bulk(s, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_free_bulk);
+
+bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
+								void **p)
+{
+	return kmem_cache_alloc_bulk(s, flags, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_bulk);
+
 #ifdef CONFIG_TRACING
 void *
 kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
diff --git a/mm/slab.h b/mm/slab.h
index 4c3ac12dd644..6a427a74cca5 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -162,6 +162,15 @@ void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *s);
 ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 		       size_t count, loff_t *ppos);
 
+/*
+ * Generic implementation of bulk operations
+ * These are useful for situations in which the allocator cannot
+ * perform optimizations. In that case segments of the objecct listed
+ * may be allocated or freed using these operations.
+ */
+void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
+bool __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
+
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * Iterate over all memcg caches of the given root cache. The caller must hold
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 999bb3424d44..f8acc2bdb88b 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -105,6 +105,29 @@ static inline int kmem_cache_sanity_check(const char *name, size_t size)
 }
 #endif
 
+void __kmem_cache_free_bulk(struct kmem_cache *s, size_t nr, void **p)
+{
+	size_t i;
+
+	for (i = 0; i < nr; i++)
+		kmem_cache_free(s, p[i]);
+}
+
+bool __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
+								void **p)
+{
+	size_t i;
+
+	for (i = 0; i < nr; i++) {
+		void *x = p[i] = kmem_cache_alloc(s, flags);
+		if (!x) {
+			__kmem_cache_free_bulk(s, i, p);
+			return false;
+		}
+	}
+	return true;
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 void slab_init_memcg_params(struct kmem_cache *s)
 {
diff --git a/mm/slob.c b/mm/slob.c
index 4765f65019c7..495df8e006ec 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -611,6 +611,19 @@ void kmem_cache_free(struct kmem_cache *c, void *b)
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
+void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+{
+	__kmem_cache_free_bulk(s, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_free_bulk);
+
+bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
+								void **p)
+{
+	return kmem_cache_alloc_bulk(s, flags, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_bulk);
+
 int __kmem_cache_shutdown(struct kmem_cache *c)
 {
 	/* No way to check for remaining objects */
diff --git a/mm/slub.c b/mm/slub.c
index 54c0876b43d5..80f17403e503 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2750,6 +2750,20 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
+void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+{
+	__kmem_cache_free_bulk(s, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_free_bulk);
+
+bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
+								void **p)
+{
+	return kmem_cache_alloc_bulk(s, flags, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_bulk);
+
+
 /*
  * Object placement in a slab is made very easy because we always start at
  * offset 0. If we tune the size of the object to the alignment then we can

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
