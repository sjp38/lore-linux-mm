Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8130C6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 19:20:40 -0400 (EDT)
Received: by iecsl2 with SMTP id sl2so79425006iec.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 16:20:40 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com. [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id rt1si391589igb.34.2015.03.19.16.20.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 16:20:39 -0700 (PDT)
Received: by iedm5 with SMTP id m5so15614350ied.3
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 16:20:39 -0700 (PDT)
Date: Thu, 19 Mar 2015 16:20:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, mempool: poison elements backed by slab
 allocator
In-Reply-To: <8761a1dxsv.fsf@rasmusvillemoes.dk>
Message-ID: <alpine.DEB.2.10.1503191602330.513@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503090021380.19148@chino.kir.corp.google.com> <8761a1dxsv.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, jfs-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 16 Mar 2015, Rasmus Villemoes wrote:

> > Mempools keep elements in a reserved pool for contexts in which
> > allocation may not be possible.  When an element is allocated from the
> > reserved pool, its memory contents is the same as when it was added to
> > the reserved pool.
> >
> > Because of this, elements lack any free poisoning to detect
> > use-after-free errors.
> >
> > This patch adds free poisoning for elements backed by the slab allocator.
> > This is possible because the mempool layer knows the object size of each
> > element.
> >
> > When an element is added to the reserved pool, it is poisoned with
> > POISON_FREE.  When it is removed from the reserved pool, the contents are
> > checked for POISON_FREE.  If there is a mismatch, a warning is emitted to
> > the kernel log.
> >
> > +
> > +static void poison_slab_element(mempool_t *pool, void *element)
> > +{
> > +	if (pool->alloc == mempool_alloc_slab ||
> > +	    pool->alloc == mempool_kmalloc) {
> > +		size_t size = ksize(element);
> > +		u8 *obj = element;
> > +
> > +		memset(obj, POISON_FREE, size - 1);
> > +		obj[size - 1] = POISON_END;
> > +	}
> > +}
> 
> Maybe a stupid question, but what happens if the underlying slab
> allocator has non-trivial ->ctor?
> 

Not a stupid question at all, it's very legitimate, thanks for thinking 
about it!

Using slab constructors with mempools is inherently risky because you 
don't know where the element is coming from when returned by 
mempool_alloc(): was it able to be allocated in GFP_NOFS context from the 
slab allocator, or is it coming from mempool's reserved pool of elements?

In the former, the constructor is properly called and in the latter it's 
not called: we simply pop the element from the reserved pool and return it 
to the caller.

For that reason, without mempool element poisoning, we need to take care 
that objects are properly deconstructed when freed to the reserved pool so 
that they are in a state we expect when returned from mempool_alloc().  
Thus, at least part of the slab constructor must be duplicated before 
calling mempool_free().

There's one user in the tree that actually does this: it's the 
mempool_create_slab_pool() in fs/jfs/jfs_metapage.c, and it does exactly 
what is described above: it clears necessary fields before doing 
mempool_free() that are duplicated in the slab object constructor.

We'd like to be able to do this:

diff --git a/mm/mempool.c b/mm/mempool.c
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -15,6 +15,7 @@
 #include <linux/mempool.h>
 #include <linux/blkdev.h>
 #include <linux/writeback.h>
+#include "slab.h"
 
 static void add_element(mempool_t *pool, void *element)
 {
@@ -332,6 +333,7 @@ EXPORT_SYMBOL(mempool_free);
 void *mempool_alloc_slab(gfp_t gfp_mask, void *pool_data)
 {
 	struct kmem_cache *mem = pool_data;
+	BUG_ON(mem->ctor);
 	return kmem_cache_alloc(mem, gfp_mask);
 }
 EXPORT_SYMBOL(mempool_alloc_slab);

Since it would be difficult to reproduce an error with an improperly 
decosntructed mempool element when used with a mempool based on a slab 
cache that has a constructor: normally, slab objects are allocatable even 
with GFP_NOFS since there are free objects available and there's less of a 
liklihood that we'll need to use the mempool reserved pool.

But we obviously can't do that if jfs is actively using mempools based on 
slab caches with object constructors.  I think it would be much better to 
simply initialize objects as they are allocated, regardless of whether 
they come from the slab allocator or mempool reserved pool, and avoid 
trying to set the state up properly before mempool_free().

This patch properly initializes all fields that are currently done by the 
object constructor (with the exception of mp->flags since it is 
immediately overwritten by the caller anyway).  It also removes META_free 
since nothing is checking for it.

Jfs folks, would this be acceptable to you?
---
diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
--- a/fs/jfs/jfs_metapage.c
+++ b/fs/jfs/jfs_metapage.c
@@ -183,30 +183,23 @@ static inline void remove_metapage(struct page *page, struct metapage *mp)
 
 #endif
 
-static void init_once(void *foo)
-{
-	struct metapage *mp = (struct metapage *)foo;
-
-	mp->lid = 0;
-	mp->lsn = 0;
-	mp->flag = 0;
-	mp->data = NULL;
-	mp->clsn = 0;
-	mp->log = NULL;
-	set_bit(META_free, &mp->flag);
-	init_waitqueue_head(&mp->wait);
-}
-
 static inline struct metapage *alloc_metapage(gfp_t gfp_mask)
 {
-	return mempool_alloc(metapage_mempool, gfp_mask);
+	struct metapage *mp = mempool_alloc(metapage_mempool, gfp_mask);
+
+	if (mp) {
+		mp->lid = 0;
+		mp->lsn = 0;
+		mp->data = NULL;
+		mp->clsn = 0;
+		mp->log = NULL;
+		init_waitqueue_head(&mp->wait);
+	}
+	return mp;
 }
 
 static inline void free_metapage(struct metapage *mp)
 {
-	mp->flag = 0;
-	set_bit(META_free, &mp->flag);
-
 	mempool_free(mp, metapage_mempool);
 }
 
@@ -216,7 +209,7 @@ int __init metapage_init(void)
 	 * Allocate the metapage structures
 	 */
 	metapage_cache = kmem_cache_create("jfs_mp", sizeof(struct metapage),
-					   0, 0, init_once);
+					   0, 0, NULL);
 	if (metapage_cache == NULL)
 		return -ENOMEM;
 
diff --git a/fs/jfs/jfs_metapage.h b/fs/jfs/jfs_metapage.h
index a78beda..337e9e5 100644
--- a/fs/jfs/jfs_metapage.h
+++ b/fs/jfs/jfs_metapage.h
@@ -48,7 +48,6 @@ struct metapage {
 
 /* metapage flag */
 #define META_locked	0
-#define META_free	1
 #define META_dirty	2
 #define META_sync	3
 #define META_discard	4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
