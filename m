Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id AA5436B0263
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 08:58:06 -0500 (EST)
Received: by ykdv3 with SMTP id v3so146882339ykd.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 05:58:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w144si14182877ywd.67.2015.11.13.05.58.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 05:58:05 -0800 (PST)
Subject: [PATCH] slab/slub: adjust kmem_cache_alloc_bulk API
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 13 Nov 2015 14:58:01 +0100
Message-ID: <20151113135746.5605.33090.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Alexander Duyck <alexander.duyck@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Adjust kmem_cache_alloc_bulk API before we have any real users.

Adjust API to return type 'int' instead of previously type 'bool'.
This is done to allow future extention of the bulk alloc API.

A future extention could be to allow SLUB to stop at a page boundry,
when specified by a flag, and then return the number of objects.

The advantage of this approach, would make it easier to make bulk
alloc run without local IRQs disabled.  With an approach of cmpxchg
"stealing" the entire c->freelist or page->freelist.  To avoid
overshooting we would stop processing at a slab-page boundry. Else we
always end up returning some objects at the cost of another cmpxchg.

To keep compatible with future users of this API linking against an
older kernel when using the new flag, we need to return the number of
allocated objects with this API change.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
$ bloat-o-meter vmlinux.with_bool_api vmlinux.with_int_api
 add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-15 (-15)
 function                                     old     new   delta
 __kmem_cache_alloc_bulk                      129     124      -5
 kmem_cache_alloc_bulk                        283     273     -10

 include/linux/slab.h |    2 +-
 mm/slab.c            |    8 ++++----
 mm/slab.h            |    2 +-
 mm/slab_common.c     |    6 +++---
 mm/slob.c            |    2 +-
 mm/slub.c            |    8 ++++----
 6 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index b89a67d297f1..bf87b41fa4b7 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -316,7 +316,7 @@ void kmem_cache_free(struct kmem_cache *, void *);
  * Note that interrupts must be enabled when calling these functions.
  */
 void kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
-bool kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
+int kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node) __assume_kmalloc_alignment;
diff --git a/mm/slab.c b/mm/slab.c
index 804e7de91d29..6699c5797d66 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3419,8 +3419,8 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 /* Note that interrupts must be enabled when calling this function. */
-bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
-			   void **p)
+int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
+			  void **p)
 {
 	size_t i;
 
@@ -3430,11 +3430,11 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 
 		if (!x) {
 			__kmem_cache_free_bulk(s, i, p);
-			return false;
+			return 0;
 		}
 	}
 	local_irq_enable();
-	return true;
+	return i;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 
diff --git a/mm/slab.h b/mm/slab.h
index a3a967d7d7c2..17ef57f6ba62 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -170,7 +170,7 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
  * may be allocated or freed using these operations.
  */
 void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
-bool __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
+int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 
 #ifdef CONFIG_MEMCG_KMEM
 /*
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 5ce4faeb16fb..e981088ccf2d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -112,7 +112,7 @@ void __kmem_cache_free_bulk(struct kmem_cache *s, size_t nr, void **p)
 		kmem_cache_free(s, p[i]);
 }
 
-bool __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
+int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 								void **p)
 {
 	size_t i;
@@ -121,10 +121,10 @@ bool __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 		void *x = p[i] = kmem_cache_alloc(s, flags);
 		if (!x) {
 			__kmem_cache_free_bulk(s, i, p);
-			return false;
+			return 0;
 		}
 	}
-	return true;
+	return i;
 }
 
 #ifdef CONFIG_MEMCG_KMEM
diff --git a/mm/slob.c b/mm/slob.c
index 0d7e5df74d1f..17e8f8cc7c53 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -617,7 +617,7 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 
-bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
+int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 								void **p)
 {
 	return __kmem_cache_alloc_bulk(s, flags, size, p);
diff --git a/mm/slub.c b/mm/slub.c
index d52ac8a2b147..ce31235bfa7c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2911,8 +2911,8 @@ void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 
 /* Note that interrupts must be enabled when calling this function. */
-bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
-			   void **p)
+int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
+			  void **p)
 {
 	struct kmem_cache_cpu *c;
 	int i;
@@ -2961,12 +2961,12 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 
 	/* memcg and kmem_cache debug support */
 	slab_post_alloc_hook(s, flags, size, p);
-	return true;
+	return i;
 error:
 	local_irq_enable();
 	slab_post_alloc_hook(s, flags, i, p);
 	__kmem_cache_free_bulk(s, i, p);
-	return false;
+	return 0;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
