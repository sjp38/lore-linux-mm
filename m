Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 574E76B0256
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 11:06:41 -0500 (EST)
Received: by ioc74 with SMTP id 74so63867695ioc.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 08:06:41 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id l5si10676471igr.22.2015.12.09.08.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 08:06:40 -0800 (PST)
Date: Wed, 9 Dec 2015 10:06:39 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH V2 8/9] slab: implement bulk free in SLAB allocator
In-Reply-To: <20151208161903.21945.33876.stgit@firesoul>
Message-ID: <alpine.DEB.2.20.1512090945570.30894@east.gentwo.org>
References: <20151208161751.21945.53936.stgit@firesoul> <20151208161903.21945.33876.stgit@firesoul>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 8 Dec 2015, Jesper Dangaard Brouer wrote:

> +void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)

Drop orig_s as a parameter? This makes the function have less code and
makes it more universally useful for freeing large amount of objects.

> +{
> +	struct kmem_cache *s;
> +	size_t i;
> +
> +	local_irq_disable();
> +	for (i = 0; i < size; i++) {
> +		void *objp = p[i];
> +
> +		s = cache_from_obj(orig_s, objp);

And just use the cache the object belongs to.

s = virt_to_head_page(objp)->slab_cache;

> +
> +		debug_check_no_locks_freed(objp, s->object_size);
> +		if (!(s->flags & SLAB_DEBUG_OBJECTS))
> +			debug_check_no_obj_freed(objp, s->object_size);
> +
> +		__cache_free(s, objp, _RET_IP_);
> +	}
> +	local_irq_enable();
> +
> +	/* FIXME: add tracing */
> +}
> +EXPORT_SYMBOL(kmem_cache_free_bulk);


Could we do the following API change patch before this series so that
kmem_cache_free_bulk is properly generalized?



From: Christoph Lameter <cl@linux.com>
Subject: slab bulk api: Remove the kmem_cache parameter from kmem_cache_bulk_free()

It is desirable and necessary to free objects from different kmem_caches.
It is required in order to support memcg object freeing across different5
cgroups.

So drop the pointless parameter and allow freeing of arbitrary lists
of slab allocated objects.

This patch also does the proper compound page handling so that
arbitrary objects allocated via kmalloc() can be handled by
kmem_cache_bulk_free().

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h
+++ linux/include/linux/slab.h
@@ -315,7 +315,7 @@ void kmem_cache_free(struct kmem_cache *
  *
  * Note that interrupts must be enabled when calling these functions.
  */
-void kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
+void kmem_cache_free_bulk(size_t, void **);
 int kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);

 #ifdef CONFIG_NUMA
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c
+++ linux/mm/slab.c
@@ -3413,9 +3413,9 @@ void *kmem_cache_alloc(struct kmem_cache
 }
 EXPORT_SYMBOL(kmem_cache_alloc);

-void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+void kmem_cache_free_bulk(size_t size, void **p)
 {
-	__kmem_cache_free_bulk(s, size, p);
+	__kmem_cache_free_bulk(size, p);
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);

Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h
+++ linux/mm/slab.h
@@ -166,10 +166,10 @@ ssize_t slabinfo_write(struct file *file
 /*
  * Generic implementation of bulk operations
  * These are useful for situations in which the allocator cannot
- * perform optimizations. In that case segments of the objecct listed
+ * perform optimizations. In that case segments of the object listed
  * may be allocated or freed using these operations.
  */
-void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
+void __kmem_cache_free_bulk(size_t, void **);
 int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);

 #ifdef CONFIG_MEMCG_KMEM
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -2887,23 +2887,30 @@ static int build_detached_freelist(struc


 /* Note that interrupts must be enabled when calling this function. */
-void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)
+void kmem_cache_free_bulk(size_t size, void **p)
 {
 	if (WARN_ON(!size))
 		return;

 	do {
 		struct detached_freelist df;
-		struct kmem_cache *s;
+		struct page *page;

-		/* Support for memcg */
-		s = cache_from_obj(orig_s, p[size - 1]);
+		page = virt_to_head_page(p[size - 1]);

-		size = build_detached_freelist(s, size, p, &df);
+		if (unlikely(!PageSlab(page))) {
+			BUG_ON(!PageCompound(page));
+			kfree_hook(p[size - 1]);
+			__free_kmem_pages(page, compound_order(page));
+			p[--size] = NULL;
+			continue;
+		}
+
+		size = build_detached_freelist(page->slab_cache, size, p, &df);
 		if (unlikely(!df.page))
 			continue;

-		slab_free(s, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);
+		slab_free(page->slab_cache, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);
 	} while (likely(size));
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);
@@ -2963,7 +2970,7 @@ int kmem_cache_alloc_bulk(struct kmem_ca
 error:
 	local_irq_enable();
 	slab_post_alloc_hook(s, flags, i, p);
-	__kmem_cache_free_bulk(s, i, p);
+	__kmem_cache_free_bulk(i, p);
 	return 0;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
