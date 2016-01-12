Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id B99874403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 10:16:30 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id e32so341720346qgf.3
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:16:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c134si34841603qkb.124.2016.01.12.07.16.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 07:16:29 -0800 (PST)
Subject: [PATCH V2 10/11] mm: new API kfree_bulk() for SLAB+SLUB allocators
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 12 Jan 2016 16:16:26 +0100
Message-ID: <20160112151552.31725.9733.stgit@firesoul>
In-Reply-To: <20160112151257.31725.71327.stgit@firesoul>
References: <20160112151257.31725.71327.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

This patch introduce a new API call kfree_bulk() for bulk freeing
memory objects not bound to a single kmem_cache.

Christoph pointed out that it is possible to implement freeing of
objects, without knowing the kmem_cache pointer as that information is
available from the object's page->slab_cache.  Proposing to remove the
kmem_cache argument from the bulk free API.

Jesper demonstrated that these extra steps per object comes at a
performance cost.  It is only in the case CONFIG_MEMCG_KMEM is
compiled in and activated runtime that these steps are done anyhow.
The extra cost is most visible for SLAB allocator, because the SLUB
allocator does the page lookup (virt_to_head_page()) anyhow.

Thus, the conclusion was to keep the kmem_cache free bulk API with a
kmem_cache pointer, but we can still implement a kfree_bulk() API
fairly easily.  Simply by handling if kmem_cache_free_bulk() gets
called with a kmem_cache NULL pointer.

This does increase the code size a bit, but implementing a separate
kfree_bulk() call would likely increase code size even more.

Below benchmarks cost of alloc+free (obj size 256 bytes) on
CPU i7-4790K @ 4.00GHz, no PREEMPT and CONFIG_MEMCG_KMEM=y.

Code size increase for SLAB:

 add/remove: 0/0 grow/shrink: 1/0 up/down: 74/0 (74)
 function                                     old     new   delta
 kmem_cache_free_bulk                         660     734     +74

SLAB fastpath: 87 cycles(tsc) 21.814
  sz - fallback             - kmem_cache_free_bulk - kfree_bulk
   1 - 103 cycles 25.878 ns -  41 cycles 10.498 ns - 81 cycles 20.312 ns
   2 -  94 cycles 23.673 ns -  26 cycles  6.682 ns - 42 cycles 10.649 ns
   3 -  92 cycles 23.181 ns -  21 cycles  5.325 ns - 39 cycles 9.950 ns
   4 -  90 cycles 22.727 ns -  18 cycles  4.673 ns - 26 cycles 6.693 ns
   8 -  89 cycles 22.270 ns -  14 cycles  3.664 ns - 23 cycles 5.835 ns
  16 -  88 cycles 22.038 ns -  14 cycles  3.503 ns - 22 cycles 5.543 ns
  30 -  89 cycles 22.284 ns -  13 cycles  3.310 ns - 20 cycles 5.197 ns
  32 -  88 cycles 22.249 ns -  13 cycles  3.420 ns - 20 cycles 5.166 ns
  34 -  88 cycles 22.224 ns -  14 cycles  3.643 ns - 20 cycles 5.170 ns
  48 -  88 cycles 22.088 ns -  14 cycles  3.507 ns - 20 cycles 5.203 ns
  64 -  88 cycles 22.063 ns -  13 cycles  3.428 ns - 20 cycles 5.152 ns
 128 -  89 cycles 22.483 ns -  15 cycles  3.891 ns - 23 cycles 5.885 ns
 158 -  89 cycles 22.381 ns -  15 cycles  3.779 ns - 22 cycles 5.548 ns
 250 -  91 cycles 22.798 ns -  16 cycles  4.152 ns - 23 cycles 5.967 ns

SLAB when enabling MEMCG_KMEM runtime:
 - kmemcg fastpath: 130 cycles(tsc) 32.684 ns (step:0)
 1 - 148 cycles 37.220 ns -  66 cycles 16.622 ns - 66 cycles 16.583 ns
 2 - 141 cycles 35.510 ns -  51 cycles 12.820 ns - 58 cycles 14.625 ns
 3 - 140 cycles 35.017 ns -  37 cycles 9.326 ns - 33 cycles 8.474 ns
 4 - 137 cycles 34.507 ns -  31 cycles 7.888 ns - 33 cycles 8.300 ns
 8 - 140 cycles 35.069 ns -  25 cycles 6.461 ns - 25 cycles 6.436 ns
 16 - 138 cycles 34.542 ns -  23 cycles 5.945 ns - 22 cycles 5.670 ns
 30 - 136 cycles 34.227 ns -  22 cycles 5.502 ns - 22 cycles 5.587 ns
 32 - 136 cycles 34.253 ns -  21 cycles 5.475 ns - 21 cycles 5.324 ns
 34 - 136 cycles 34.254 ns -  21 cycles 5.448 ns - 20 cycles 5.194 ns
 48 - 136 cycles 34.075 ns -  21 cycles 5.458 ns - 21 cycles 5.367 ns
 64 - 135 cycles 33.994 ns -  21 cycles 5.350 ns - 21 cycles 5.259 ns
 128 - 137 cycles 34.446 ns -  23 cycles 5.816 ns - 22 cycles 5.688 ns
 158 - 137 cycles 34.379 ns -  22 cycles 5.727 ns - 22 cycles 5.602 ns
 250 - 138 cycles 34.755 ns -  24 cycles 6.093 ns - 23 cycles 5.986 ns

Code size increase for SLUB:
 function                                     old     new   delta
 kmem_cache_free_bulk                         717     799     +82

SLUB benchmark:
 SLUB fastpath: 46 cycles(tsc) 11.691 ns (step:0)
  sz - fallback             - kmem_cache_free_bulk - kfree_bulk
   1 -  61 cycles 15.486 ns -  53 cycles 13.364 ns - 57 cycles 14.464 ns
   2 -  54 cycles 13.703 ns -  32 cycles  8.110 ns - 33 cycles 8.482 ns
   3 -  53 cycles 13.272 ns -  25 cycles  6.362 ns - 27 cycles 6.947 ns
   4 -  51 cycles 12.994 ns -  24 cycles  6.087 ns - 24 cycles 6.078 ns
   8 -  50 cycles 12.576 ns -  21 cycles  5.354 ns - 22 cycles 5.513 ns
  16 -  49 cycles 12.368 ns -  20 cycles  5.054 ns - 20 cycles 5.042 ns
  30 -  49 cycles 12.273 ns -  18 cycles  4.748 ns - 19 cycles 4.758 ns
  32 -  49 cycles 12.401 ns -  19 cycles  4.821 ns - 19 cycles 4.810 ns
  34 -  98 cycles 24.519 ns -  24 cycles  6.154 ns - 24 cycles 6.157 ns
  48 -  83 cycles 20.833 ns -  21 cycles  5.446 ns - 21 cycles 5.429 ns
  64 -  75 cycles 18.891 ns -  20 cycles  5.247 ns - 20 cycles 5.238 ns
 128 -  93 cycles 23.271 ns -  27 cycles  6.856 ns - 27 cycles 6.823 ns
 158 - 102 cycles 25.581 ns -  30 cycles  7.714 ns - 30 cycles 7.695 ns
 250 - 107 cycles 26.917 ns -  38 cycles  9.514 ns - 38 cycles 9.506 ns

SLUB when enabling MEMCG_KMEM runtime:
 - kmemcg fastpath: 71 cycles(tsc) 17.897 ns (step:0)
 1 - 85 cycles 21.484 ns -  78 cycles 19.569 ns - 75 cycles 18.938 ns
 2 - 81 cycles 20.363 ns -  45 cycles 11.258 ns - 44 cycles 11.076 ns
 3 - 78 cycles 19.709 ns -  33 cycles 8.354 ns - 32 cycles 8.044 ns
 4 - 77 cycles 19.430 ns -  28 cycles 7.216 ns - 28 cycles 7.003 ns
 8 - 101 cycles 25.288 ns -  23 cycles 5.849 ns - 23 cycles 5.787 ns
 16 - 76 cycles 19.148 ns -  20 cycles 5.162 ns - 20 cycles 5.081 ns
 30 - 76 cycles 19.067 ns -  19 cycles 4.868 ns - 19 cycles 4.821 ns
 32 - 76 cycles 19.052 ns -  19 cycles 4.857 ns - 19 cycles 4.815 ns
 34 - 121 cycles 30.291 ns -  25 cycles 6.333 ns - 25 cycles 6.268 ns
 48 - 108 cycles 27.111 ns -  21 cycles 5.498 ns - 21 cycles 5.458 ns
 64 - 100 cycles 25.164 ns -  20 cycles 5.242 ns - 20 cycles 5.229 ns
 128 - 155 cycles 38.976 ns -  27 cycles 6.886 ns - 27 cycles 6.892 ns
 158 - 132 cycles 33.034 ns -  30 cycles 7.711 ns - 30 cycles 7.728 ns
 250 - 130 cycles 32.612 ns -  38 cycles 9.560 ns - 38 cycles 9.549 ns

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

----
V2: Re-ran SLAB benchmark, Kim noticed measurement instability
 - Also tested with SLOB allocator

 include/linux/slab.h |    9 +++++++++
 mm/slab.c            |    5 ++++-
 mm/slab_common.c     |    8 ++++++--
 mm/slub.c            |   21 ++++++++++++++++++---
 4 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 2037a861e367..df70e69c8f7f 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -318,6 +318,15 @@ void kmem_cache_free(struct kmem_cache *, void *);
 void kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
 int kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 
+/*
+ * Caller must not use kfree_bulk() on memory not originally allocated
+ * by kmalloc(), because the SLOB allocator cannot handle this.
+ */
+static __always_inline void kfree_bulk(size_t size, void **p)
+{
+	kmem_cache_free_bulk(NULL, size, p);
+}
+
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node) __assume_kmalloc_alignment;
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node) __assume_slab_alignment;
diff --git a/mm/slab.c b/mm/slab.c
index 6cc5f99fe2ea..68a6c5b53069 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3587,7 +3587,10 @@ void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)
 	for (i = 0; i < size; i++) {
 		void *objp = p[i];
 
-		s = cache_from_obj(orig_s, objp);
+		if (!orig_s) /* called via kfree_bulk */
+			s = virt_to_cache(objp);
+		else
+			s = cache_from_obj(orig_s, objp);
 
 		debug_check_no_locks_freed(objp, s->object_size);
 		if (!(s->flags & SLAB_DEBUG_OBJECTS))
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3c6a86b4ec25..963c25589949 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -108,8 +108,12 @@ void __kmem_cache_free_bulk(struct kmem_cache *s, size_t nr, void **p)
 {
 	size_t i;
 
-	for (i = 0; i < nr; i++)
-		kmem_cache_free(s, p[i]);
+	for (i = 0; i < nr; i++) {
+		if (s)
+			kmem_cache_free(s, p[i]);
+		else
+			kfree(p[i]);
+	}
 }
 
 int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
diff --git a/mm/slub.c b/mm/slub.c
index 9ef1abc683b2..9c5e1bc3b389 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2787,23 +2787,38 @@ int build_detached_freelist(struct kmem_cache *s, size_t size,
 	size_t first_skipped_index = 0;
 	int lookahead = 3;
 	void *object;
+	struct page *page;
 
 	/* Always re-init detached_freelist */
 	df->page = NULL;
 
 	do {
 		object = p[--size];
+		/* Do we need !ZERO_OR_NULL_PTR(object) here? (for kfree) */
 	} while (!object && size);
 
 	if (!object)
 		return 0;
 
-	/* Support for memcg, compiler can optimize this out */
-	df->s = cache_from_obj(s, object);
+	page = virt_to_head_page(object);
+	if (!s) {
+		/* Handle kalloc'ed objects */
+		if (unlikely(!PageSlab(page))) {
+			BUG_ON(!PageCompound(page));
+			kfree_hook(object);
+			__free_kmem_pages(page, compound_order(page));
+			p[size] = NULL; /* mark object processed */
+			return size;
+		}
+		/* Derive kmem_cache from object */
+		df->s = page->slab_cache;
+	} else {
+		df->s = cache_from_obj(s, object); /* Support for memcg */
+	}
 
 	/* Start new detached freelist */
+	df->page = page;
 	set_freepointer(df->s, object, NULL);
-	df->page = virt_to_head_page(object);
 	df->tail = object;
 	df->freelist = object;
 	p[size] = NULL; /* mark object processed */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
