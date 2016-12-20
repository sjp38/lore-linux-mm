Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63ABD6B030D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:28:22 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id m123so2552789qke.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:28:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o53si12262219qtc.303.2016.12.20.05.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:28:20 -0800 (PST)
Subject: [RFC PATCH 2/4] page_pool: basic implementation of page_pool
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 20 Dec 2016 14:28:17 +0100
Message-ID: <20161220132817.18788.64726.stgit@firesoul>
In-Reply-To: <20161220132444.18788.50875.stgit@firesoul>
References: <20161220132444.18788.50875.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>
Cc: willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org, john.fastabend@gmail.com, Saeed Mahameed <saeedm@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>, bjorn.topel@intel.com, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Tariq Toukan <tariqt@mellanox.com>

The focus in this patch is getting the API around page_pool figured out.

The internal data structures for returning page_pool pages is not optimal.
This implementation use ptr_ring for recycling, which is known not to scale
in case of multiple remote CPUs releasing/returning pages.

A bulking interface into the page allocator is also left for later. (This
requires cooperation will Mel Gorman, who just send me some PoC patches for this).
---
 include/linux/mm.h             |    6 +
 include/linux/mm_types.h       |   11 +
 include/linux/page-flags.h     |   13 +
 include/linux/page_pool.h      |  158 +++++++++++++++
 include/linux/skbuff.h         |    2 
 include/trace/events/mmflags.h |    3 
 mm/Makefile                    |    3 
 mm/page_alloc.c                |   10 +
 mm/page_pool.c                 |  423 ++++++++++++++++++++++++++++++++++++++++
 mm/slub.c                      |    4 
 10 files changed, 627 insertions(+), 6 deletions(-)
 create mode 100644 include/linux/page_pool.h
 create mode 100644 mm/page_pool.c

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4424784ac374..11b4d8fb280b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -23,6 +23,7 @@
 #include <linux/page_ext.h>
 #include <linux/err.h>
 #include <linux/page_ref.h>
+#include <linux/page_pool.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -765,6 +766,11 @@ static inline void put_page(struct page *page)
 {
 	page = compound_head(page);
 
+	if (PagePool(page)) {
+		page_pool_put_page(page);
+		return;
+	}
+
 	if (put_page_testzero(page))
 		__put_page(page);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 08d947fc4c59..c74dea967f99 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -47,6 +47,12 @@ struct page {
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	union {
+		/* DISCUSS: Considered moving page_pool pointer here,
+		 * but I'm unsure if 'mapping' is needed for userspace
+		 * mapping the page, as this is a use-case the
+		 * page_pool need to support in the future. (Basically
+		 * mapping a NIC RX ring into userspace).
+		 */
 		struct address_space *mapping;	/* If low bit clear, points to
 						 * inode address_space, or NULL.
 						 * If page mapped as anonymous
@@ -63,6 +69,7 @@ struct page {
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* sl[aou]b first free object */
+		dma_addr_t dma_addr;    /* used by page_pool */
 		/* page_deferred_list().prev	-- second tail page */
 	};
 
@@ -117,6 +124,8 @@ struct page {
 	 * avoid collision and false-positive PageTail().
 	 */
 	union {
+		/* XXX: Idea reuse lru list, in page_pool to align with PCP */
+
 		struct list_head lru;	/* Pageout list, eg. active_list
 					 * protected by zone_lru_lock !
 					 * Can be used as a generic list
@@ -189,6 +198,8 @@ struct page {
 #endif
 #endif
 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
+		/* XXX: Sure page_pool will have no users of "private"? */
+		struct page_pool *pool;
 	};
 
 #ifdef CONFIG_MEMCG
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 74e4dda91238..253d7f7cf89f 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -91,7 +91,8 @@ enum pageflags {
 	PG_mappedtodisk,	/* Has blocks allocated on-disk */
 	PG_reclaim,		/* To be reclaimed asap */
 	PG_swapbacked,		/* Page is backed by RAM/swap */
-	PG_unevictable,		/* Page is "unevictable"  */
+/*20*/	PG_unevictable,		/* Page is "unevictable"  */
+// XXX stable flag?
 #ifdef CONFIG_MMU
 	PG_mlocked,		/* Page is vma mlocked */
 #endif
@@ -101,6 +102,8 @@ enum pageflags {
 #ifdef CONFIG_MEMORY_FAILURE
 	PG_hwpoison,		/* hardware poisoned page. Don't touch */
 #endif
+	/* Question: can we squeeze in here and avoid CONFIG_64BIT hacks?*/
+	PG_pool, // XXX macros called: SetPagePool / PagePool
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
 	PG_young,
 	PG_idle,
@@ -347,6 +350,12 @@ PAGEFLAG_FALSE(HWPoison)
 #define __PG_HWPOISON 0
 #endif
 
+// XXX: Define some macros for page_pool
+// XXX: avoiding atomic set_bit() operation (like slab)
+// XXX: PF_HEAD vs PF_ANY vs PF_NO_TAIL????
+__PAGEFLAG(Pool, pool, PF_ANY)
+
+
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
 TESTPAGEFLAG(Young, young, PF_ANY)
 SETPAGEFLAG(Young, young, PF_ANY)
@@ -700,7 +709,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
 /*
  * Flags checked when a page is freed.  Pages being freed should not have
  * these flags set.  It they are, there is a problem.
- */
+ */ /* XXX add PG_pool here??? */
 #define PAGE_FLAGS_CHECK_AT_FREE \
 	(1UL << PG_lru	 | 1UL << PG_locked    | \
 	 1UL << PG_private | 1UL << PG_private_2 | \
diff --git a/include/linux/page_pool.h b/include/linux/page_pool.h
new file mode 100644
index 000000000000..6f8f2ff6d758
--- /dev/null
+++ b/include/linux/page_pool.h
@@ -0,0 +1,158 @@
+/*
+ * page_pool.h
+ *
+ *	Author:	Jesper Dangaard Brouer <netoptimizer@brouer.com>
+ *	Copyright (C) 2016 Red Hat, Inc.
+ *
+ *	This program is free software; you can redistribute it and/or modify it
+ *	under the terms of the GNU General Public License as published by the
+ *	Free Software Foundation; either version 2 of the License, or (at your
+ *	option) any later version.
+ *
+ * The page_pool is primarily motivated by two things (1) performance
+ * and (2) changing the memory model for drivers.
+ *
+ * Drivers have developed performance workarounds when the speed of
+ * the page allocator and the DMA APIs became too slow for their HW
+ * needs. The page pool solves them on a general level providing
+ * performance gains and benefits that local driver recycling hacks
+ * cannot realize.
+ *
+ * A fundamental property is that pages are returned to the page_pool.
+ * This property allow a certain class of optimizations, which is to
+ * move setup and tear-down operations out of the fast-path, sometimes
+ * known as constructor/destruction operations.  DMA map/unmap is one
+ * example of operations this applies to.  Certain page alloc/free
+ * validations can also be avoided in the fast-path.  Another example
+ * could be pre-mapping pages into userspace, and clearing them
+ * (memset-zero) outside the fast-path.
+ *
+ * This API is only meant for streaming DMA, which map/unmap frequently.
+ */
+#ifndef _LINUX_PAGE_POOL_H
+#define _LINUX_PAGE_POOL_H
+
+/*
+ * NOTES on page flags (PG_pool)... we might have a problem with
+ * enough page flags on 32 bit systems, example see PG_idle + PG_young
+ * include/linux/page_idle.h and CONFIG_IDLE_PAGE_TRACKING
+ */
+
+#include <linux/ptr_ring.h>
+
+//#include <linux/dma-mapping.h>
+#include <linux/dma-direction.h>
+
+// Not-used-atm #define PP_FLAG_NAPI 0x1
+#define PP_FLAG_ALL	0
+
+/*
+ * Fast allocation side cache array/stack
+ *
+ * The cache size and refill watermark is related to the network
+ * use-case.  The NAPI budget is 64 packets.  After a NAPI poll the RX
+ * ring is usually refilled and the max consumed elements will be 64,
+ * thus a natural max size of objects needed in the cache.
+ *
+ * Keeping room for more objects, is due to XDP_DROP use-case.  As
+ * XDP_DROP allows the opportunity to recycle objects directly into
+ * this array, as it shares the same softirq/NAPI protection.  If
+ * cache is already full (or partly full) then the XDP_DROP recycles
+ * would have to take a slower code path.
+ */
+#define PP_ALLOC_CACHE_SIZE	128
+#define PP_ALLOC_CACHE_REFILL	64
+struct pp_alloc_cache {
+	u32 count ____cacheline_aligned_in_smp;
+	u32 refill; /* not used atm */
+	void *cache[PP_ALLOC_CACHE_SIZE];
+};
+
+/*
+ * Extensible params struct. Focus on currently implemented features,
+ * extend later. Restriction, subsequently added members value of zero
+ * must gives the previous behaviour. Avoids need to update every
+ * driver simultaniously (given likely in difference subsystems).
+ */
+struct page_pool_params {
+	u32		size; /* caller sets size of struct */
+	unsigned int	order;
+	unsigned long	flags;
+	/* Associated with a specific device, for DMA pre-mapping purposes */
+	struct device	*dev;
+	/* Numa node id to allocate from pages from */
+	int 		nid;
+	enum dma_data_direction dma_dir; /* DMA mapping direction */
+	unsigned int	pool_size;
+	char		end_marker[0]; /* must be last struct member */
+};
+#define	PAGE_POOL_PARAMS_SIZE	offsetof(struct page_pool_params, end_marker)
+
+struct page_pool {
+	struct page_pool_params p;
+
+	/*
+	 * Data structure for allocation side
+	 *
+	 * Drivers allocation side usually already perform some kind
+	 * of resource protection.  Piggyback on this protection, and
+	 * require driver to protect allocation side.
+	 *
+	 * For NIC drivers this means, allocate a page_pool per
+	 * RX-queue. As the RX-queue is already protected by
+	 * Softirq/BH scheduling and napi_schedule. NAPI schedule
+	 * guarantee that a single napi_struct will only be scheduled
+	 * on a single CPU (see napi_schedule).
+	 */
+	struct pp_alloc_cache alloc;
+
+	/* Data structure for storing recycled pages.
+	 *
+	 * Returning/freeing pages is more complicated synchronization
+	 * wise, because free's can happen on remote CPUs, with no
+	 * association with allocation resource.
+	 *
+	 * For now use ptr_ring, as it separates consumer and
+	 * producer, which is a common use-case. The ptr_ring is not
+	 * though as the final data structure, expecting this to
+	 * change into a more advanced data structure with more
+	 * integration with page_alloc.c and data structs per CPU for
+	 * returning pages in bulk.
+	 *
+	 */
+	struct ptr_ring ring;
+
+	/* TODO: Domain "id" add later, for RX zero-copy validation */
+
+	/* TODO: Need list pointers for keeping page_pool object on a
+	 * cleanup list, given pages can be "outstanding" even after
+	 * e.g. driver is unloaded.
+	 */
+};
+
+struct page* page_pool_alloc_pages(struct page_pool *pool, gfp_t gfp);
+
+static inline struct page *page_pool_dev_alloc_pages(struct page_pool *pool)
+{
+	gfp_t gfp = (GFP_ATOMIC | __GFP_NOWARN | __GFP_COLD);
+	return page_pool_alloc_pages(pool, gfp);
+}
+
+struct page_pool *page_pool_create(const struct page_pool_params *params);
+
+void page_pool_destroy(struct page_pool *pool);
+
+/* Never call this directly, use helpers below */
+void __page_pool_put_page(struct page *page, bool allow_direct);
+
+static inline void page_pool_put_page(struct page *page)
+{
+	__page_pool_put_page(page, false);
+}
+/* Very limited use-cases allow recycle direct */
+static inline void page_pool_recycle_direct(struct page *page)
+{
+	__page_pool_put_page(page, true);
+}
+
+#endif /* _LINUX_PAGE_POOL_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ac7fa34db8a7..84294278039d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2584,7 +2584,7 @@ static inline void __skb_frag_ref(skb_frag_t *frag)
  * @f: the fragment offset.
  *
  * Takes an additional reference on the @f'th paged fragment of @skb.
- */
+ */ // XXX
 static inline void skb_frag_ref(struct sk_buff *skb, int f)
 {
 	__skb_frag_ref(&skb_shinfo(skb)->frags[f]);
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 5a81ab48a2fb..ee15ca659ea1 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -99,7 +99,8 @@
 	{1UL << PG_mappedtodisk,	"mappedtodisk"	},		\
 	{1UL << PG_reclaim,		"reclaim"	},		\
 	{1UL << PG_swapbacked,		"swapbacked"	},		\
-	{1UL << PG_unevictable,		"unevictable"	}		\
+	{1UL << PG_unevictable,		"unevictable"	},		\
+	{1UL << PG_pool,		"pool"		}		\
 IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
 IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
 IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
diff --git a/mm/Makefile b/mm/Makefile
index 295bd7a9f76b..dbe5a7181e28 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -100,3 +100,6 @@ obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
 obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
 obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
 obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
+
+# Hack enable for compile testing
+obj-y += page_pool.o
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2c6d5f64feca..655db05f0c1c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3873,6 +3873,11 @@ EXPORT_SYMBOL(get_zeroed_page);
 
 void __free_pages(struct page *page, unsigned int order)
 {
+	if (PagePool(page)) {
+		page_pool_put_page(page);
+		return;
+	}
+
 	if (put_page_testzero(page)) {
 		if (order == 0)
 			free_hot_cold_page(page, false);
@@ -4000,6 +4005,11 @@ void __free_page_frag(void *addr)
 {
 	struct page *page = virt_to_head_page(addr);
 
+	if (PagePool(page)) {
+		page_pool_put_page(page);
+		return;
+	}
+
 	if (unlikely(put_page_testzero(page)))
 		__free_pages_ok(page, compound_order(page));
 }
diff --git a/mm/page_pool.c b/mm/page_pool.c
new file mode 100644
index 000000000000..74138d5fe86d
--- /dev/null
+++ b/mm/page_pool.c
@@ -0,0 +1,423 @@
+/*
+ * page_pool.c
+ */
+
+/* Using the page pool from a driver, involves
+ *
+ * 1. Creating/allocating a page_pool per RX ring for the NIC
+ * 2. Using pages from page_pool to populate RX ring
+ * 3. Page pool will call dma_map/unmap
+ * 4. Driver is responsible for dma_sync part
+ * 5. On page put/free the page is returned to the page_pool
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+
+#include <linux/page_pool.h>
+#include <linux/dma-direction.h>
+#include <linux/dma-mapping.h>
+#include <linux/page-flags.h>
+#include <linux/mm.h> /* for __put_page() */
+
+/*
+ * The struct page_pool (likely) cannot be embedded into another
+ * structure, because freeing this struct depend on outstanding pages,
+ * which can point back to the page_pool. Thus, don't export "init".
+ */
+int page_pool_init(struct page_pool *pool,
+		   const struct page_pool_params *params)
+{
+	int ring_qsize = 1024; /* Default */
+	int param_copy_sz;
+
+	if (!pool)
+		return -EFAULT;
+
+	/* Allow kernel devel trees and driver to progress at different rates */
+	param_copy_sz = PAGE_POOL_PARAMS_SIZE;
+	memset(&pool->p, 0, param_copy_sz);
+	if (params->size < param_copy_sz) {
+		/*
+		 * Older module calling newer kernel, handled by only
+		 * copying supplied size, and keep remaining params zero
+		 */
+		param_copy_sz = params->size;
+	} else if (params->size > param_copy_sz) {
+		/*
+		 * Newer module calling older kernel. Need to validate
+		 * no new features were requested.
+		 */
+		unsigned char *addr = (unsigned char*)params + param_copy_sz;
+		unsigned char *end  = (unsigned char*)params + params->size;
+
+		for (; addr < end; addr++) {
+			if (*addr != 0)
+				return -E2BIG;
+		}
+	}
+	memcpy(&pool->p, params, param_copy_sz);
+
+	/* Validate only known flags were used */
+	if (pool->p.flags & ~(PP_FLAG_ALL))
+		return -EINVAL;
+
+	if (pool->p.pool_size)
+		ring_qsize = pool->p.pool_size;
+
+	/* ptr_ring is not meant as final struct, see page_pool.h */
+	if (ptr_ring_init(&pool->ring, ring_qsize, GFP_KERNEL) < 0) {
+		return -ENOMEM;
+	}
+
+	/*
+	 * DMA direction is either DMA_FROM_DEVICE or DMA_BIDIRECTIONAL.
+	 * DMA_BIDIRECTIONAL is for allowing page used for DMA sending,
+	 * which is the XDP_TX use-case.
+	 */
+	if ((pool->p.dma_dir != DMA_FROM_DEVICE) &&
+	    (pool->p.dma_dir != DMA_BIDIRECTIONAL))
+		return -EINVAL;
+
+	return 0;
+}
+
+struct page_pool *page_pool_create(const struct page_pool_params *params)
+{
+	struct page_pool *pool;
+	int err = 0;
+
+	if (params->size < offsetof(struct page_pool_params, nid)) {
+		WARN(1, "Fix page_pool_params->size code\n");
+		return NULL;
+	}
+
+	pool = kzalloc_node(sizeof(*pool), GFP_KERNEL, params->nid);
+	err = page_pool_init(pool, params);
+	if (err < 0) {
+		pr_warn("%s() gave up with errno %d\n", __func__, err);
+		kfree(pool);
+		return ERR_PTR(err);
+	}
+	return pool;
+}
+EXPORT_SYMBOL(page_pool_create);
+
+/* fast path */
+static struct page *__page_pool_get_cached(struct page_pool *pool)
+{
+	struct page *page;
+
+	/* FIXME: use another test for safe-context, caller should
+	 * simply provide this guarantee
+	 */
+	if (likely(in_serving_softirq())) { // FIXME add use of PP_FLAG_NAPI
+		struct ptr_ring *r;
+
+		if (likely(pool->alloc.count)) {
+			/* Fast-path */
+			page = pool->alloc.cache[--pool->alloc.count];
+			return page;
+		}
+		/* Slower-path: Alloc array empty, time to refill */
+		r = &pool->ring;
+		/* Open-coded bulk ptr_ring consumer.
+		 *
+		 * Discussion: ATM the ring consumer lock is not
+		 * really needed due to the softirq/NAPI protection,
+		 * but later MM-layer need the ability to reclaim
+		 * pages on the ring. Thus, keeping the locks.
+		 */
+		spin_lock(&r->consumer_lock);
+		while ((page = __ptr_ring_consume(r))) {
+			if (pool->alloc.count == PP_ALLOC_CACHE_REFILL)
+				break;
+			pool->alloc.cache[pool->alloc.count++] = page;
+		}
+		spin_unlock(&r->consumer_lock);
+		return page;
+	}
+
+	/* Slow-path: Get page from locked ring queue */
+	page = ptr_ring_consume(&pool->ring);
+	return page;
+}
+
+/* slow path */
+noinline
+static struct page *__page_pool_alloc_pages(struct page_pool *pool,
+					    gfp_t _gfp)
+{
+	struct page *page;
+	gfp_t gfp = _gfp;
+	dma_addr_t dma;
+
+	/* We could always set __GFP_COMP, and avoid this branch, as
+	 * prep_new_page() can handle order-0 with __GFP_COMP.
+	 */
+	if (pool->p.order)
+		gfp |= __GFP_COMP;
+	/*
+	 *  Discuss GFP flags: e.g
+	 *   __GFP_NOWARN + __GFP_NORETRY + __GFP_NOMEMALLOC
+	 */
+
+	/*
+	 * FUTURE development:
+	 *
+	 * Current slow-path essentially falls back to single page
+	 * allocations, which doesn't improve performance.  This code
+	 * need bulk allocation support from the page allocator code.
+	 *
+	 * For now, page pool recycle cache is not refilled.  Hint:
+	 * when pages are returned, they will go into the recycle
+	 * cache.
+	 */
+
+	/* Cache was empty, do real allocation */
+	page = alloc_pages_node(pool->p.nid, gfp, pool->p.order);
+	if (!page)
+		return NULL;
+
+	/* FIXME: Add accounting of pages.
+	 *
+	 * TODO: Look into memcg_charge_slab/memcg_uncharge_slab
+	 *
+	 * What if page comes from pfmemalloc reserves?
+	 * Should we abort to help memory pressure? (test err code path!)
+	 * Code see SetPageSlabPfmemalloc(), __ClearPageSlabPfmemalloc()
+	 * and page_is_pfmemalloc(page)
+	 */
+
+	/* Setup DMA mapping:
+	 * This mapping is kept for lifetime of page, until leaving pool.
+	 */
+	dma = dma_map_page(pool->p.dev, page, 0,
+			   (PAGE_SIZE << pool->p.order),
+			   pool->p.dma_dir);
+	if (dma_mapping_error(pool->p.dev, dma)) {
+		put_page(page);
+		return NULL;
+	}
+	page->dma_addr = dma;
+
+	/* IDEA: When page just alloc'ed is should/must have refcnt 1.
+	 * Should we do refcnt inc tricks to keep page mapped/owned by
+	 * page_pool infrastructure? (like page_frag code)
+	 */
+
+	/* TODO: Init fields in struct page. See slub code allocate_slab()
+	 *
+	 */
+	page->pool = pool;   /* Save pool the page MUST be returned to */
+	__SetPagePool(page); /* Mark page with flag */
+
+	return page;
+}
+
+
+/* For using page_pool replace: alloc_pages() API calls, but provide
+ * synchronization guarantee for allocation side.
+ */
+struct page *page_pool_alloc_pages(struct page_pool *pool, gfp_t gfp)
+{
+	struct page *page;
+
+	/* Fast-path: Get a page from cache */
+	page = __page_pool_get_cached(pool);
+	if (page)
+		return page;
+
+	/* Slow-path: cache empty, do real allocation */
+	page = __page_pool_alloc_pages(pool, gfp);
+	return page;
+}
+EXPORT_SYMBOL(page_pool_alloc_pages);
+
+/* Cleanup page_pool state from page */
+// Ideas taken from __free_slab()
+static void __page_pool_clean_page(struct page *page)
+{
+	struct page_pool *pool;
+
+	VM_BUG_ON_PAGE(!PagePool(page), page);
+
+	// mod_zone_page_state() ???
+
+	pool = page->pool;
+	__ClearPagePool(page);
+
+	/* DMA unmap */
+	dma_unmap_page(pool->p.dev, page->dma_addr,
+		       PAGE_SIZE << pool->p.order,
+                       pool->p.dma_dir);
+	page->dma_addr = 0;
+        /* Q: Use DMA macros???
+	 *
+	 * dma_unmap_page(pool->p.dev, dma_unmap_addr(page,dma_addr),
+	 *	       PAGE_SIZE << pool->p.order,
+	 *	       pool->p.dma_dir);
+	 * dma_unmap_addr_set(page, dma_addr, 0);
+	 */
+
+	/* FUTURE: Use Alex Duyck's DMA_ATTR_SKIP_CPU_SYNC changes
+	 *
+	 * dma_unmap_page_attrs(pool->p.dev, page->dma_addr,
+	 *		     PAGE_SIZE << pool->p.order,
+	 *		     pool->p.dma_dir,
+	 *		     DMA_ATTR_SKIP_CPU_SYNC);
+	 */
+
+	// page_mapcount_reset(page); // ??
+	// page->mapping = NULL;      // ??
+
+	// Not really needed, but good for provoking bugs
+	page->pool = (void *)0xDEADBEE0;
+
+	/* FIXME: Add accounting of pages here!
+	 *
+	 * Look into: memcg_uncharge_page_pool(page, order, pool);
+	 */
+
+	// FIXME: do we need this??? likely not as slub does not...
+//	if (unlikely(is_zone_device_page(page)))
+//		put_zone_device_page(page);
+
+}
+
+/* Return a page to the page allocator, cleaning up our state */
+static void __page_pool_return_page(struct page *page)
+{
+	struct page_pool *pool = page->pool;
+
+	__page_pool_clean_page(page);
+	/*
+	 * Given page pool state and flags were just cleared, the page
+	 * must be freed here.  Thus, code invariant assumes
+	 * refcnt==1, as __free_pages() call put_page_testzero().
+	 */
+	__free_pages(page, pool->p.order);
+}
+
+bool __page_pool_recycle_into_ring(struct page_pool *pool,
+				   struct page *page)
+{
+	int ret;
+	/* TODO: Use smarter data structure for recycle cache.  Using
+	 * ptr_ring will not scale when multiple remote CPUs want to
+	 * recycle pages.
+	 */
+
+	/* Need BH protection when free occurs from userspace e.g
+	 * __kfree_skb() called via {tcp,inet,sock}_recvmsg
+	 *
+	 * Problematic for several reasons: (1) it is more costly,
+	 * (2) the BH unlock can cause (re)sched of softirq.
+	 *
+	 * BH protection not needed if current is serving softirq
+	 */
+	if (in_serving_softirq())
+		ret = ptr_ring_produce(&pool->ring, page);
+	else
+		ret = ptr_ring_produce_bh(&pool->ring, page);
+
+	return (ret == 0) ? true : false;
+}
+
+/*
+ * Only allow direct recycling in very special circumstances, into the
+ * alloc cache.  E.g. XDP_DROP use-case.
+ *
+ * Caller must provide appropiate safe context.
+ */
+static bool __page_pool_recycle_direct(struct page *page,
+				       struct page_pool *pool)
+{
+	// BUG_ON(!in_serving_softirq());
+
+	if (unlikely(pool->alloc.count == PP_ALLOC_CACHE_SIZE))
+		return false;
+
+	/* Caller MUST have verified/know (page_ref_count(page) == 1) */
+	pool->alloc.cache[pool->alloc.count++] = page;
+	return true;
+}
+
+void __page_pool_put_page(struct page *page, bool allow_direct)
+{
+	struct page_pool *pool = page->pool;
+
+	/* This is a fast-path optimization, that avoids an atomic
+	 * operation, in the case where a single object is (refcnt)
+	 * using the page.
+	 *
+	 * refcnt == 1 means page_pool owns page, and can recycle it.
+	 */
+	if (likely(page_ref_count(page) == 1)) {
+		/* Read barrier implicit paired with full MB of atomic ops */
+		smp_rmb();
+
+		if (allow_direct)
+			if (__page_pool_recycle_direct(page, pool))
+			    return;
+
+		if (!__page_pool_recycle_into_ring(pool, page)) {
+			/* Cache full, do real __free_pages() */
+			__page_pool_return_page(page);
+		}
+		return;
+	}
+	/*
+	 * Many drivers splitting up the page into fragments, and some
+	 * want to keep doing this to save memory. The put_page_testzero()
+	 * function as a refcnt decrement, and should not return true.
+	 */
+	if (unlikely(put_page_testzero(page))) {
+		/*
+		 * Reaching refcnt zero should not be possible,
+		 * indicate code error.  Don't crash but warn, handle
+		 * case by not-recycling, but return page to page
+		 * allocator.
+		 */
+		WARN(1, "%s() violating page_pool invariance refcnt:%d\n",
+		     __func__, page_ref_count(page));
+		/* Cleanup state before directly returning page */
+		__page_pool_clean_page(page);
+		__put_page(page);
+	}
+}
+EXPORT_SYMBOL(__page_pool_put_page);
+
+static void __destructor_put_page(void *ptr)
+{
+	struct page *page = ptr;
+
+	/* Verify the refcnt invariant of cached pages */
+	if (!(page_ref_count(page) == 1)) {
+		pr_crit("%s() page_pool refcnt %d violation\n",
+			__func__, page_ref_count(page));
+		BUG();
+	}
+	__page_pool_return_page(page);
+}
+
+/* Cleanup and release resources */
+void page_pool_destroy(struct page_pool *pool)
+{
+	/* Empty recycle ring */
+	ptr_ring_cleanup(&pool->ring, __destructor_put_page);
+
+	/* FIXME-mem-leak: cleanup array/stack cache
+	 * pool->alloc. Driver usually will destroy RX ring after
+	 * making sure nobody can alloc from it, thus it should be
+	 * safe to just empty cache here
+	 */
+
+	/* FIXME: before releasing the page_pool memory, we MUST make
+	 * sure no pages points back this page_pool.
+	 */
+	kfree(pool);
+}
+EXPORT_SYMBOL(page_pool_destroy);
diff --git a/mm/slub.c b/mm/slub.c
index 067598a00849..7de478c20464 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1572,8 +1572,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	page->objects = oo_objects(oo);
 
 	order = compound_order(page);
-	page->slab_cache = s;
-	__SetPageSlab(page);
+	page->slab_cache = s; // Example: Saving kmem_cache in struct page
+	__SetPageSlab(page); // Example: Setting flag
 	if (page_is_pfmemalloc(page))
 		SetPageSlabPfmemalloc(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
