Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC2B56B0310
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:28:31 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id j49so127154392qta.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:28:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k34si2440936qtc.284.2016.12.20.05.28.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:28:30 -0800 (PST)
Subject: [RFC PATCH 4/4] page_pool: change refcnt model
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 20 Dec 2016 14:28:28 +0100
Message-ID: <20161220132827.18788.8658.stgit@firesoul>
In-Reply-To: <20161220132444.18788.50875.stgit@firesoul>
References: <20161220132444.18788.50875.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>
Cc: willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org, john.fastabend@gmail.com, Saeed Mahameed <saeedm@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>, bjorn.topel@intel.com, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Tariq Toukan <tariqt@mellanox.com>

This is the direction the patch is going, after Mel's comments.

Most significantly: Change that refcnt must reach zero (and not 1)
before the page gets into the recycle ring.  Pages on the
pp_alloc_cache have refcnt==1 invariance, as this allow fast direct
recycling (allowed by XDP_DROP).

When mlx5 page recycle cache didn't work (at next-next at commit
f5f99309fa74) the benchmarks showed the gain was reduced to 14% by
this patch, or an added cost of approx 133 cycle (which were a higher
cycle cost than expected).

UPDATE: net-next at commit 52f40e9d65 this patch show no gain, perhaps
a small performance regression.  The accuracy of the UDP measurements
are not good enough to conclude on, ksoftirq +1.4% and UDP side -0.89%.
The TC ingress drop test is more significant and show 4.3% slower.

Thus, this patch makes page_pool slower than the driver specific page
recycle cache.  More optimizations are pending for the page_pool, thus
this can likely be regained.

The page_pool will still show benefit for use-case where the driver
page recycle cache doesn't work (>128 outstanding packets/pages).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/mm.h        |    5 --
 include/linux/page_pool.h |   10 +++
 mm/page_alloc.c           |   16 ++---
 mm/page_pool.c            |  141 +++++++++++++++++++--------------------------
 mm/swap.c                 |    3 +
 5 files changed, 79 insertions(+), 96 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 11b4d8fb280b..7315c1790f7c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -766,11 +766,6 @@ static inline void put_page(struct page *page)
 {
 	page = compound_head(page);
 
-	if (PagePool(page)) {
-		page_pool_put_page(page);
-		return;
-	}
-
 	if (put_page_testzero(page))
 		__put_page(page);
 
diff --git a/include/linux/page_pool.h b/include/linux/page_pool.h
index 6f8f2ff6d758..40da1fac573d 100644
--- a/include/linux/page_pool.h
+++ b/include/linux/page_pool.h
@@ -112,6 +112,7 @@ struct page_pool {
 	 * wise, because free's can happen on remote CPUs, with no
 	 * association with allocation resource.
 	 *
+	 * XXX: Mel says drop comment
 	 * For now use ptr_ring, as it separates consumer and
 	 * producer, which is a common use-case. The ptr_ring is not
 	 * though as the final data structure, expecting this to
@@ -145,6 +146,7 @@ void page_pool_destroy(struct page_pool *pool);
 /* Never call this directly, use helpers below */
 void __page_pool_put_page(struct page *page, bool allow_direct);
 
+/* XXX: Mel: needs descriptions*/
 static inline void page_pool_put_page(struct page *page)
 {
 	__page_pool_put_page(page, false);
@@ -155,4 +157,12 @@ static inline void page_pool_recycle_direct(struct page *page)
 	__page_pool_put_page(page, true);
 }
 
+/*
+ * Called when refcnt reach zero.  On failure page_pool state is
+ * cleared, and caller can return page to page allocator.
+ */
+bool page_pool_recycle(struct page *page);
+// XXX: compile out trick, let this return false compile time,
+// or let PagePool() check compile to false.
+
 #endif /* _LINUX_PAGE_POOL_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 655db05f0c1c..5a68bdbc9dc1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1240,6 +1240,9 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	int migratetype;
 	unsigned long pfn = page_to_pfn(page);
 
+	if (PagePool(page) && page_pool_recycle(page))
+		return;
+
 	if (!free_pages_prepare(page, order, true))
 		return;
 
@@ -2448,6 +2451,9 @@ void free_hot_cold_page(struct page *page, bool cold)
 	unsigned long pfn = page_to_pfn(page);
 	int migratetype;
 
+	if (PagePool(page) && page_pool_recycle(page))
+		return;
+
 	if (!free_pcp_prepare(page))
 		return;
 
@@ -3873,11 +3879,6 @@ EXPORT_SYMBOL(get_zeroed_page);
 
 void __free_pages(struct page *page, unsigned int order)
 {
-	if (PagePool(page)) {
-		page_pool_put_page(page);
-		return;
-	}
-
 	if (put_page_testzero(page)) {
 		if (order == 0)
 			free_hot_cold_page(page, false);
@@ -4005,11 +4006,6 @@ void __free_page_frag(void *addr)
 {
 	struct page *page = virt_to_head_page(addr);
 
-	if (PagePool(page)) {
-		page_pool_put_page(page);
-		return;
-	}
-
 	if (unlikely(put_page_testzero(page)))
 		__free_pages_ok(page, compound_order(page));
 }
diff --git a/mm/page_pool.c b/mm/page_pool.c
index 74138d5fe86d..064034d89f8a 100644
--- a/mm/page_pool.c
+++ b/mm/page_pool.c
@@ -21,14 +21,15 @@
 #include <linux/dma-mapping.h>
 #include <linux/page-flags.h>
 #include <linux/mm.h> /* for __put_page() */
+#include "internal.h" /* for set_page_refcounted() */
 
 /*
  * The struct page_pool (likely) cannot be embedded into another
  * structure, because freeing this struct depend on outstanding pages,
  * which can point back to the page_pool. Thus, don't export "init".
  */
-int page_pool_init(struct page_pool *pool,
-		   const struct page_pool_params *params)
+static int page_pool_init(struct page_pool *pool,
+			  const struct page_pool_params *params)
 {
 	int ring_qsize = 1024; /* Default */
 	int param_copy_sz;
@@ -108,40 +109,33 @@ EXPORT_SYMBOL(page_pool_create);
 /* fast path */
 static struct page *__page_pool_get_cached(struct page_pool *pool)
 {
+	struct ptr_ring *r;
 	struct page *page;
 
-	/* FIXME: use another test for safe-context, caller should
-	 * simply provide this guarantee
-	 */
-	if (likely(in_serving_softirq())) { // FIXME add use of PP_FLAG_NAPI
-		struct ptr_ring *r;
-
-		if (likely(pool->alloc.count)) {
-			/* Fast-path */
-			page = pool->alloc.cache[--pool->alloc.count];
-			return page;
-		}
-		/* Slower-path: Alloc array empty, time to refill */
-		r = &pool->ring;
-		/* Open-coded bulk ptr_ring consumer.
-		 *
-		 * Discussion: ATM the ring consumer lock is not
-		 * really needed due to the softirq/NAPI protection,
-		 * but later MM-layer need the ability to reclaim
-		 * pages on the ring. Thus, keeping the locks.
-		 */
-		spin_lock(&r->consumer_lock);
-		while ((page = __ptr_ring_consume(r))) {
-			if (pool->alloc.count == PP_ALLOC_CACHE_REFILL)
-				break;
-			pool->alloc.cache[pool->alloc.count++] = page;
-		}
-		spin_unlock(&r->consumer_lock);
+	/* Caller guarantee safe context for accessing alloc.cache */
+	if (likely(pool->alloc.count)) {
+		/* Fast-path */
+		page = pool->alloc.cache[--pool->alloc.count];
 		return page;
 	}
 
-	/* Slow-path: Get page from locked ring queue */
-	page = ptr_ring_consume(&pool->ring);
+	/* Slower-path: Alloc array empty, time to refill */
+	r = &pool->ring;
+	/* Open-coded bulk ptr_ring consumer.
+	 *
+	 * Discussion: ATM ring *consumer* lock is not really needed
+	 * due to caller protecton, but later MM-layer need the
+	 * ability to reclaim pages from ring. Thus, keeping locks.
+	 */
+	spin_lock(&r->consumer_lock);
+	while ((page = __ptr_ring_consume(r))) {
+		/* Pages on ring refcnt==0, on alloc.cache refcnt==1 */
+		set_page_refcounted(page);
+		if (pool->alloc.count == PP_ALLOC_CACHE_REFILL)
+			break;
+		pool->alloc.cache[pool->alloc.count++] = page;
+	}
+	spin_unlock(&r->consumer_lock);
 	return page;
 }
 
@@ -290,15 +284,9 @@ static void __page_pool_clean_page(struct page *page)
 /* Return a page to the page allocator, cleaning up our state */
 static void __page_pool_return_page(struct page *page)
 {
-	struct page_pool *pool = page->pool;
-
+	VM_BUG_ON_PAGE(page_ref_count(page) != 0, page);
 	__page_pool_clean_page(page);
-	/*
-	 * Given page pool state and flags were just cleared, the page
-	 * must be freed here.  Thus, code invariant assumes
-	 * refcnt==1, as __free_pages() call put_page_testzero().
-	 */
-	__free_pages(page, pool->p.order);
+	__put_page(page);
 }
 
 bool __page_pool_recycle_into_ring(struct page_pool *pool,
@@ -332,70 +320,61 @@ bool __page_pool_recycle_into_ring(struct page_pool *pool,
  *
  * Caller must provide appropiate safe context.
  */
-static bool __page_pool_recycle_direct(struct page *page,
+// noinline /* hack for perf-record test */
+static
+bool __page_pool_recycle_direct(struct page *page,
 				       struct page_pool *pool)
 {
-	// BUG_ON(!in_serving_softirq());
+	VM_BUG_ON_PAGE(page_ref_count(page) != 1, page);
+	/* page refcnt==1 invarians on alloc.cache */
 
 	if (unlikely(pool->alloc.count == PP_ALLOC_CACHE_SIZE))
 		return false;
 
-	/* Caller MUST have verified/know (page_ref_count(page) == 1) */
 	pool->alloc.cache[pool->alloc.count++] = page;
 	return true;
 }
 
-void __page_pool_put_page(struct page *page, bool allow_direct)
+/*
+ * Called when refcnt reach zero.  On failure page_pool state is
+ * cleared, and caller can return page to page allocator.
+ */
+bool page_pool_recycle(struct page *page)
 {
 	struct page_pool *pool = page->pool;
 
-	/* This is a fast-path optimization, that avoids an atomic
-	 * operation, in the case where a single object is (refcnt)
-	 * using the page.
-	 *
-	 * refcnt == 1 means page_pool owns page, and can recycle it.
-	 */
-	if (likely(page_ref_count(page) == 1)) {
-		/* Read barrier implicit paired with full MB of atomic ops */
-		smp_rmb();
-
-		if (allow_direct)
-			if (__page_pool_recycle_direct(page, pool))
-			    return;
+	VM_BUG_ON_PAGE(page_ref_count(page) != 0, page);
 
-		if (!__page_pool_recycle_into_ring(pool, page)) {
-			/* Cache full, do real __free_pages() */
-			__page_pool_return_page(page);
-		}
-		return;
-	}
-	/*
-	 * Many drivers splitting up the page into fragments, and some
-	 * want to keep doing this to save memory. The put_page_testzero()
-	 * function as a refcnt decrement, and should not return true.
-	 */
-	if (unlikely(put_page_testzero(page))) {
-		/*
-		 * Reaching refcnt zero should not be possible,
-		 * indicate code error.  Don't crash but warn, handle
-		 * case by not-recycling, but return page to page
-		 * allocator.
-		 */
-		WARN(1, "%s() violating page_pool invariance refcnt:%d\n",
-		     __func__, page_ref_count(page));
-		/* Cleanup state before directly returning page */
+	/* Pages on recycle ring have refcnt==0 */
+	if (!__page_pool_recycle_into_ring(pool, page)) {
 		__page_pool_clean_page(page);
-		__put_page(page);
+		return false;
 	}
+	return true;
+}
+EXPORT_SYMBOL(page_pool_recycle);
+
+void __page_pool_put_page(struct page *page, bool allow_direct)
+{
+	struct page_pool *pool = page->pool;
+
+	if (allow_direct && (page_ref_count(page) == 1))
+		if (__page_pool_recycle_direct(page, pool))
+			return;
+
+	if (put_page_testzero(page))
+		if (!page_pool_recycle(page))
+			__put_page(page);
+
 }
 EXPORT_SYMBOL(__page_pool_put_page);
 
-static void __destructor_put_page(void *ptr)
+void __destructor_return_page(void *ptr)
 {
 	struct page *page = ptr;
 
 	/* Verify the refcnt invariant of cached pages */
-	if (!(page_ref_count(page) == 1)) {
+	if (page_ref_count(page) != 0) {
 		pr_crit("%s() page_pool refcnt %d violation\n",
 			__func__, page_ref_count(page));
 		BUG();
@@ -407,7 +386,7 @@ static void __destructor_put_page(void *ptr)
 void page_pool_destroy(struct page_pool *pool)
 {
 	/* Empty recycle ring */
-	ptr_ring_cleanup(&pool->ring, __destructor_put_page);
+	ptr_ring_cleanup(&pool->ring, __destructor_return_page);
 
 	/* FIXME-mem-leak: cleanup array/stack cache
 	 * pool->alloc. Driver usually will destroy RX ring after
diff --git a/mm/swap.c b/mm/swap.c
index 4dcf852e1e6d..d71c896cb1a1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -96,6 +96,9 @@ static void __put_compound_page(struct page *page)
 
 void __put_page(struct page *page)
 {
+	if (PagePool(page) && page_pool_recycle(page))
+		return;
+
 	if (unlikely(PageCompound(page)))
 		__put_compound_page(page);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
