Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 300596B0073
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:28:57 -0400 (EDT)
Received: by qcbfz6 with SMTP id fz6so14071708qcb.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 07:28:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b53si4478401qge.107.2015.06.17.07.28.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 07:28:56 -0700 (PDT)
Subject: [PATCH V2 2/6] slab: infrastructure for bulk object allocation and
 freeing
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 17 Jun 2015 16:27:53 +0200
Message-ID: <20150617142741.11791.82931.stgit@devil>
In-Reply-To: <20150617142613.11791.76008.stgit@devil>
References: <20150617142613.11791.76008.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

From: Christoph Lameter <cl@linux.com>

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
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2: fix kmem_cache_alloc_bulk calling itself

In measurements[1] the fallback functions __kmem_cache_{free,alloc}_bulk
have been copied from slab_common.c and forced "noinline" to force a
function call like slab_common.c.

Bulk- fallback                   - just-invoking-callbacks
  1 -  57 cycles(tsc) 14.500 ns  -  64 cycles(tsc) 16.121 ns
  2 -  51 cycles(tsc) 12.760 ns  -  53 cycles(tsc) 13.422 ns
  3 -  49 cycles(tsc) 12.345 ns  -  51 cycles(tsc) 12.855 ns
  4 -  48 cycles(tsc) 12.110 ns  -  49 cycles(tsc) 12.494 ns
  8 -  46 cycles(tsc) 11.596 ns  -  47 cycles(tsc) 11.768 ns
 16 -  45 cycles(tsc) 11.357 ns  -  45 cycles(tsc) 11.459 ns
 30 -  86 cycles(tsc) 21.622 ns  -  86 cycles(tsc) 21.639 ns
 32 -  83 cycles(tsc) 20.838 ns  -  83 cycles(tsc) 20.849 ns
 34 -  90 cycles(tsc) 22.509 ns  -  90 cycles(tsc) 22.516 ns
 48 -  98 cycles(tsc) 24.692 ns  -  98 cycles(tsc) 24.660 ns
 64 -  99 cycles(tsc) 24.775 ns  -  99 cycles(tsc) 24.848 ns
128 - 105 cycles(tsc) 26.305 ns  - 104 cycles(tsc) 26.065 ns
158 - 104 cycles(tsc) 26.214 ns  - 104 cycles(tsc) 26.139 ns
250 - 105 cycles(tsc) 26.360 ns  - 105 cycles(tsc) 26.309 ns

Measurements clearly show that the extra function call overhead in
kmem_cache_{free,alloc}_bulk is measurable.  Why don't we make
__kmem_cache_{free,alloc}_bulk inline?

[1] https://github.com/netoptimizer/prototype-kernel/blob/b4688559b/kernel/mm/slab_bulk_test01.c#L80

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
index 7eb38dd1cefa..8d4edc4230db 100644
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
+	return __kmem_cache_alloc_bulk(s, flags, size, p);
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
index 4765f65019c7..165bbd3cd606 100644
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
+	return __kmem_cache_alloc_bulk(s, flags, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_bulk);
+
 int __kmem_cache_shutdown(struct kmem_cache *c)
 {
 	/* No way to check for remaining objects */
diff --git a/mm/slub.c b/mm/slub.c
index 41624ccabc63..ac5a196d5ea5 100644
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
+	return __kmem_cache_alloc_bulk(s, flags, size, p);
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
