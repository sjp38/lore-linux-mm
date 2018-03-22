Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 93D746B0012
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:32:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v3so4765701pfm.21
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 08:32:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f9si4532534pgn.493.2018.03.22.08.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 08:32:14 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 7/8] page_frag: Update documentation
Date: Thu, 22 Mar 2018 08:31:56 -0700
Message-Id: <20180322153157.10447-8-willy@infradead.org>
In-Reply-To: <20180322153157.10447-1-willy@infradead.org>
References: <20180322153157.10447-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, netdev@vger.kernel.org, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

 - Rename Documentation/vm/page_frags to page_frags.rst
 - Change page_frags.rst to be a user's guide rather than implementation
   detail.
 - Add kernel-doc for the page_frag allocator
 - Move implementation details to the comments in page_alloc.c

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 Documentation/vm/page_frags     | 42 ---------------------------
 Documentation/vm/page_frags.rst | 24 ++++++++++++++++
 mm/page_alloc.c                 | 63 ++++++++++++++++++++++++++++++++---------
 3 files changed, 74 insertions(+), 55 deletions(-)
 delete mode 100644 Documentation/vm/page_frags
 create mode 100644 Documentation/vm/page_frags.rst

diff --git a/Documentation/vm/page_frags b/Documentation/vm/page_frags
deleted file mode 100644
index a6714565dbf9..000000000000
--- a/Documentation/vm/page_frags
+++ /dev/null
@@ -1,42 +0,0 @@
-Page fragments
---------------
-
-A page fragment is an arbitrary-length arbitrary-offset area of memory
-which resides within a 0 or higher order compound page.  Multiple
-fragments within that page are individually refcounted, in the page's
-reference counter.
-
-The page_frag functions, page_frag_alloc and page_frag_free, provide a
-simple allocation framework for page fragments.  This is used by the
-network stack and network device drivers to provide a backing region of
-memory for use as either an sk_buff->head, or to be used in the "frags"
-portion of skb_shared_info.
-
-In order to make use of the page fragment APIs a backing page fragment
-cache is needed.  This provides a central point for the fragment allocation
-and tracks allows multiple calls to make use of a cached page.  The
-advantage to doing this is that multiple calls to get_page can be avoided
-which can be expensive at allocation time.  However due to the nature of
-this caching it is required that any calls to the cache be protected by
-either a per-cpu limitation, or a per-cpu limitation and forcing interrupts
-to be disabled when executing the fragment allocation.
-
-The network stack uses two separate caches per CPU to handle fragment
-allocation.  The netdev_alloc_cache is used by callers making use of the
-__netdev_alloc_frag and __netdev_alloc_skb calls.  The napi_alloc_cache is
-used by callers of the __napi_alloc_frag and __napi_alloc_skb calls.  The
-main difference between these two calls is the context in which they may be
-called.  The "netdev" prefixed functions are usable in any context as these
-functions will disable interrupts, while the "napi" prefixed functions are
-only usable within the softirq context.
-
-Many network device drivers use a similar methodology for allocating page
-fragments, but the page fragments are cached at the ring or descriptor
-level.  In order to enable these cases it is necessary to provide a generic
-way of tearing down a page cache.  For this reason __page_frag_cache_drain
-was implemented.  It allows for freeing multiple references from a single
-page via a single call.  The advantage to doing this is that it allows for
-cleaning up the multiple references that were added to a page in order to
-avoid calling get_page per allocation.
-
-Alexander Duyck, Nov 29, 2016.
diff --git a/Documentation/vm/page_frags.rst b/Documentation/vm/page_frags.rst
new file mode 100644
index 000000000000..e675bfad6710
--- /dev/null
+++ b/Documentation/vm/page_frags.rst
@@ -0,0 +1,24 @@
+==============
+Page fragments
+==============
+
+:Author: Alexander Duyck
+
+A page fragment is a physically contiguous area of memory that is smaller
+than a page.  It may cross a page boundary, and may be allocated at
+an arbitrary alignment.
+
+The page fragment allocator is optimised for very fast allocation
+of arbitrary-sized objects which will likely be freed soon.  It does
+not take any locks, relying on the caller to ensure that simultaneous
+allocations from the same page_frag_cache cannot occur.  The allocator
+does not support red zones or poisoning.  If the user has alignment
+requirements, rounding the size of each object allocated from the cache
+will ensure that all objects are aligned.  Do not attempt to allocate
+0 bytes; it is not checked for and will end badly.
+
+Functions
+=========
+
+.. kernel-doc:: mm/page_alloc.c
+   :functions: page_frag_alloc page_frag_free __page_frag_cache_drain
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d15a5348a8e4..b9beafa5d2a5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4326,15 +4326,27 @@ void free_pages(unsigned long addr, unsigned int order)
 EXPORT_SYMBOL(free_pages);
 
 /*
- * Page Fragment:
- *  An arbitrary-length arbitrary-offset area of memory which resides
- *  within a 0 or higher order page.  Multiple fragments within that page
- *  are individually refcounted, in the page's reference counter.
- *
- * The page_frag functions below provide a simple allocation framework for
- * page fragments.  This is used by the network stack and network device
- * drivers to provide a backing region of memory for use as either an
+ * The page_frag functions below are used by the network stack and network
+ * device drivers to provide a backing region of memory for use as either an
  * sk_buff->head, or to be used in the "frags" portion of skb_shared_info.
+ *
+ * We attempt to use a compound page (unless the machine has a large
+ * PAGE_SIZE) in order to minimise trips into the page allocator.  Allocation
+ * starts at the end of the page and proceeds towards the beginning of the
+ * page.  Once there is insufficient space in the page to satisfy the
+ * next allocation, we call into __page_frag_cache_refill() in order to
+ * either recycle the existing page or start allocation from a new page.
+ *
+ * The allocation side maintains a count of the number of allocations it
+ * has made while frees are counted in the struct page reference count.
+ * We reconcile the two when there is no space left in the page.  This
+ * minimises cache line bouncing when page frags are freed on a different
+ * CPU from the one they were allocated on.
+ *
+ * Several network drivers use a similar approach to the page_frag_cache,
+ * but specialise their allocator to return a dma_addr_t instead of a
+ * virtual address.  They can also use page_frag_free(), and will use
+ * __page_frag_cache_drain() in order to destroy their caches.
  */
 static void *__page_frag_cache_refill(struct page_frag_cache *pfc,
 					     gfp_t gfp_mask)
@@ -4381,6 +4393,18 @@ static void *__page_frag_cache_refill(struct page_frag_cache *pfc,
 	return pfc->addr;
 }
 
+/**
+ * __page_frag_cache_drain() - Stop using a page.
+ * @page: Current page in use.
+ * @count: Number of allocations remaining.
+ *
+ * When a page fragment cache is being destroyed, this function prepares
+ * the page to be freed.  It will actually be freed if there are no
+ * outstanding allocations on that page; otherwise it will be freed when
+ * the last allocation is freed.
+ *
+ * Context: Any context.
+ */
 void __page_frag_cache_drain(struct page *page, unsigned int count)
 {
 	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
@@ -4396,14 +4420,22 @@ void __page_frag_cache_drain(struct page *page, unsigned int count)
 }
 EXPORT_SYMBOL(__page_frag_cache_drain);
 
-void *page_frag_alloc(struct page_frag_cache *pfc,
-		      unsigned int size, gfp_t gfp_mask)
+/**
+ * page_frag_alloc() - Allocate a page fragment.
+ * @pfc: page_frag cache.
+ * @size: Number of bytes to allocate.
+ * @gfp: Memory allocation flags.
+ *
+ * Context: Any context.
+ * Return: Address of allocated memory or %NULL.
+ */
+void *page_frag_alloc(struct page_frag_cache *pfc, unsigned int size, gfp_t gfp)
 {
 	void *addr = pfc->addr;
 	unsigned int offset = (unsigned long)addr & page_frag_cache_mask(pfc);
 
 	if (unlikely(offset < size)) {
-		addr = __page_frag_cache_refill(pfc, gfp_mask);
+		addr = __page_frag_cache_refill(pfc, gfp);
 		if (!addr)
 			return NULL;
 	}
@@ -4416,8 +4448,13 @@ void *page_frag_alloc(struct page_frag_cache *pfc,
 }
 EXPORT_SYMBOL(page_frag_alloc);
 
-/*
- * Frees a page fragment allocated out of either a compound or order 0 page.
+/**
+ * page_frag_free() - Free a page fragment.
+ * @addr: Address of page fragment.
+ *
+ * Free memory previously allocated by page_frag_alloc().
+ *
+ * Context: Any context.
  */
 void page_frag_free(void *addr)
 {
-- 
2.16.2
