Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1796B0071
	for <linux-mm@kvack.org>; Thu,  7 May 2015 00:12:00 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so20374480qkg.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 21:12:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 82si858667qhw.114.2015.05.06.21.11.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 21:11:59 -0700 (PDT)
Subject: [PATCH 04/10] mm/net: Rename and move page fragment handling from
 net/ to mm/
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:11:57 -0700
Message-ID: <20150507041157.1873.63151.stgit@ahduyck-vm-fedora22>
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com

This change moves the __alloc_page_frag functionality out of the networking
stack and into the page allocation portion of mm.  The idea it so help make
this maintainable by placing it with other page allocation functions.

Since we are moving it from skbuff.c to page_alloc.c I have also renamed
the basic defines and structure from netdev_alloc_cache to page_frag_cache
to reflect that this is now part of a different kernel subsystem.

I have also added a simple __free_page_frag function which can handle
freeing the frags based on the skb->head pointer.  The model for this is
based off of __free_pages since we don't actually need to deal with all of
the cases that put_page handles.  I incorporated the virt_to_head_page call
and compound_order into the function as it actually allows for a signficant
size reduction by reducing code duplication.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/gfp.h      |    5 ++
 include/linux/mm_types.h |   18 ++++++++
 include/linux/skbuff.h   |    3 -
 mm/page_alloc.c          |   98 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/skbuff.c        |  100 +++-------------------------------------------
 5 files changed, 127 insertions(+), 97 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 97a9373e61e8..70a7fee1efb3 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -366,6 +366,11 @@ extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_hot_cold_page(struct page *page, bool cold);
 extern void free_hot_cold_page_list(struct list_head *list, bool cold);
 
+struct page_frag_cache;
+extern void *__alloc_page_frag(struct page_frag_cache *nc,
+			       unsigned int fragsz, gfp_t gfp_mask);
+extern void __free_page_frag(void *addr);
+
 extern void __free_kmem_pages(struct page *page, unsigned int order);
 extern void free_kmem_pages(unsigned long addr, unsigned int order);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 8d37e26a1007..0038ac7466fd 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -226,6 +226,24 @@ struct page_frag {
 #endif
 };
 
+#define PAGE_FRAG_CACHE_MAX_SIZE	__ALIGN_MASK(32768, ~PAGE_MASK)
+#define PAGE_FRAG_CACHE_MAX_ORDER	get_order(PAGE_FRAG_CACHE_MAX_SIZE)
+
+struct page_frag_cache {
+	void * va;
+#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
+	__u16 offset;
+	__u16 size;
+#else
+	__u32 offset;
+#endif
+	/* we maintain a pagecount bias, so that we dont dirty cache line
+	 * containing page->_count every time we allocate a fragment.
+	 */
+	unsigned int		pagecnt_bias;
+	bool pfmemalloc;
+};
+
 typedef unsigned long __nocast vm_flags_t;
 
 /*
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8b9a2c35a9d7..0039fcc45b3b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2128,9 +2128,6 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 		kfree_skb(skb);
 }
 
-#define NETDEV_FRAG_PAGE_MAX_SIZE	__ALIGN_MASK(32768, ~PAGE_MASK)
-#define NETDEV_FRAG_PAGE_MAX_ORDER	get_order(NETDEV_FRAG_PAGE_MAX_SIZE)
-
 void *netdev_alloc_frag(unsigned int fragsz);
 
 struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int length,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e4a9c0..2fd31aebef30 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2967,6 +2967,104 @@ void free_pages(unsigned long addr, unsigned int order)
 EXPORT_SYMBOL(free_pages);
 
 /*
+ * Page Fragment:
+ *  An arbitrary-length arbitrary-offset area of memory which resides
+ *  within a 0 or higher order page.  Multiple fragments within that page
+ *  are individually refcounted, in the page's reference counter.
+ *
+ * The page_frag functions below provide a simple allocation framework for
+ * page fragments.  This is used by the network stack and network device
+ * drivers to provide a backing region of memory for use as either an
+ * sk_buff->head, or to be used in the "frags" portion of skb_shared_info.
+ */
+static struct page *__page_frag_refill(struct page_frag_cache *nc,
+				       gfp_t gfp_mask)
+{
+	struct page *page = NULL;
+	gfp_t gfp = gfp_mask;
+
+#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
+	gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY |
+		    __GFP_NOMEMALLOC;
+	page = alloc_pages_node(NUMA_NO_NODE, gfp_mask,
+				PAGE_FRAG_CACHE_MAX_ORDER);
+	nc->size = page ? PAGE_FRAG_CACHE_MAX_SIZE : PAGE_SIZE;
+#endif
+	if (unlikely(!page))
+		page = alloc_pages_node(NUMA_NO_NODE, gfp, 0);
+
+	nc->va = page ? page_address(page) : NULL;
+
+	return page;
+}
+
+void *__alloc_page_frag(struct page_frag_cache *nc,
+			unsigned int fragsz, gfp_t gfp_mask)
+{
+	unsigned int size = PAGE_SIZE;
+	struct page *page;
+	int offset;
+
+	if (unlikely(!nc->va)) {
+refill:
+		page = __page_frag_refill(nc, gfp_mask);
+		if (!page)
+			return NULL;
+
+#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
+		/* if size can vary use size else just use PAGE_SIZE */
+		size = nc->size;
+#endif
+		/* Even if we own the page, we do not use atomic_set().
+		 * This would break get_page_unless_zero() users.
+		 */
+		atomic_add(size - 1, &page->_count);
+
+		/* reset page count bias and offset to start of new frag */
+		nc->pfmemalloc = page->pfmemalloc;
+		nc->pagecnt_bias = size;
+		nc->offset = size;
+	}
+
+	offset = nc->offset - fragsz;
+	if (unlikely(offset < 0)) {
+		page = virt_to_page(nc->va);
+
+		if (!atomic_sub_and_test(nc->pagecnt_bias, &page->_count))
+			goto refill;
+
+#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
+		/* if size can vary use size else just use PAGE_SIZE */
+		size = nc->size;
+#endif
+		/* OK, page count is 0, we can safely set it */
+		atomic_set(&page->_count, size);
+
+		/* reset page count bias and offset to start of new frag */
+		nc->pagecnt_bias = size;
+		offset = size - fragsz;
+	}
+
+	nc->pagecnt_bias--;
+	nc->offset = offset;
+
+	return nc->va + offset;
+}
+EXPORT_SYMBOL(__alloc_page_frag);
+
+/*
+ * Frees a page fragment allocated out of either a compound or order 0 page.
+ */
+void __free_page_frag(void *addr)
+{
+	struct page *page = virt_to_head_page(addr);
+
+	if (unlikely(put_page_testzero(page)))
+		__free_pages_ok(page, compound_order(page));
+}
+EXPORT_SYMBOL(__free_page_frag);
+
+/*
  * alloc_kmem_pages charges newly allocated pages to the kmem resource counter
  * of the current memory cgroup.
  *
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a3062ec341c3..dcc0e07abf47 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -347,100 +347,12 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 }
 EXPORT_SYMBOL(build_skb);
 
-struct netdev_alloc_cache {
-	void * va;
-#if (PAGE_SIZE < NETDEV_FRAG_PAGE_MAX_SIZE)
-	__u16 offset;
-	__u16 size;
-#else
-	__u32 offset;
-#endif
-	/* we maintain a pagecount bias, so that we dont dirty cache line
-	 * containing page->_count every time we allocate a fragment.
-	 */
-	unsigned int		pagecnt_bias;
-	bool pfmemalloc;
-};
-static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
-static DEFINE_PER_CPU(struct netdev_alloc_cache, napi_alloc_cache);
-
-static struct page *__page_frag_refill(struct netdev_alloc_cache *nc,
-				       gfp_t gfp_mask)
-{
-	struct page *page = NULL;
-	gfp_t gfp = gfp_mask;
-
-#if (PAGE_SIZE < NETDEV_FRAG_PAGE_MAX_SIZE)
-	gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY |
-		    __GFP_NOMEMALLOC;
-	page = alloc_pages_node(NUMA_NO_NODE, gfp_mask,
-				NETDEV_FRAG_PAGE_MAX_ORDER);
-	nc->size = page ? NETDEV_FRAG_PAGE_MAX_SIZE : PAGE_SIZE;
-#endif
-	if (unlikely(!page))
-		page = alloc_pages_node(NUMA_NO_NODE, gfp, 0);
-
-	nc->va = page ? page_address(page) : NULL;
-
-	return page;
-}
-
-static void *__alloc_page_frag(struct netdev_alloc_cache *nc,
-			       unsigned int fragsz, gfp_t gfp_mask)
-{
-	unsigned int size = PAGE_SIZE;
-	struct page *page;
-	int offset;
-
-	if (unlikely(!nc->va)) {
-refill:
-		page = __page_frag_refill(nc, gfp_mask);
-		if (!page)
-			return NULL;
-
-#if (PAGE_SIZE < NETDEV_FRAG_PAGE_MAX_SIZE)
-		/* if size can vary use size else just use PAGE_SIZE */
-		size = nc->size;
-#endif
-		/* Even if we own the page, we do not use atomic_set().
-		 * This would break get_page_unless_zero() users.
-		 */
-		atomic_add(size - 1, &page->_count);
-
-		/* reset page count bias and offset to start of new frag */
-		nc->pfmemalloc = page->pfmemalloc;
-		nc->pagecnt_bias = size;
-		nc->offset = size;
-	}
-
-	offset = nc->offset - fragsz;
-	if (unlikely(offset < 0)) {
-		page = virt_to_page(nc->va);
-
-		if (!atomic_sub_and_test(nc->pagecnt_bias, &page->_count))
-			goto refill;
-
-#if (PAGE_SIZE < NETDEV_FRAG_PAGE_MAX_SIZE)
-		/* if size can vary use size else just use PAGE_SIZE */
-		size = nc->size;
-#endif
-		/* OK, page count is 0, we can safely set it */
-		atomic_set(&page->_count, size);
-
-		/* reset page count bias and offset to start of new frag */
-		nc->pagecnt_bias = size;
-		offset = size - fragsz;
-	}
-
-	nc->pagecnt_bias--;
-	nc->offset = offset;
-
-	return nc->va + offset;
-}
+static DEFINE_PER_CPU(struct page_frag_cache, netdev_alloc_cache);
+static DEFINE_PER_CPU(struct page_frag_cache, napi_alloc_cache);
 
 static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
-	struct netdev_alloc_cache *nc;
+	struct page_frag_cache *nc;
 	unsigned long flags;
 	void *data;
 
@@ -466,7 +378,7 @@ EXPORT_SYMBOL(netdev_alloc_frag);
 
 static void *__napi_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
-	struct netdev_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
+	struct page_frag_cache *nc = this_cpu_ptr(&napi_alloc_cache);
 
 	return __alloc_page_frag(nc, fragsz, gfp_mask);
 }
@@ -493,7 +405,7 @@ EXPORT_SYMBOL(napi_alloc_frag);
 struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int len,
 				   gfp_t gfp_mask)
 {
-	struct netdev_alloc_cache *nc;
+	struct page_frag_cache *nc;
 	unsigned long flags;
 	struct sk_buff *skb;
 	bool pfmemalloc;
@@ -556,7 +468,7 @@ EXPORT_SYMBOL(__netdev_alloc_skb);
 struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 				 gfp_t gfp_mask)
 {
-	struct netdev_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
+	struct page_frag_cache *nc = this_cpu_ptr(&napi_alloc_cache);
 	struct sk_buff *skb;
 	void *data;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
