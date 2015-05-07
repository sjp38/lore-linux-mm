Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 738AC6B0070
	for <linux-mm@kvack.org>; Thu,  7 May 2015 00:11:54 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so15370858qge.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 21:11:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y39si874017qgy.79.2015.05.06.21.11.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 21:11:53 -0700 (PDT)
Subject: [PATCH 03/10] net: Store virtual address instead of page in
 netdev_alloc_cache
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:11:51 -0700
Message-ID: <20150507041151.1873.2487.stgit@ahduyck-vm-fedora22>
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com

This change makes it so that we store the virtual address of the page
in the netdev_alloc_cache instead of the page pointer.  The idea behind
this is to avoid multiple calls to page_address since the virtual address
is required for every access, but the page pointer is only needed at
allocation or reset of the page.

While I was at it I also reordered the netdev_alloc_cache structure a bit
so that the size is always 16 bytes by dropping size in the case where
PAGE_SIZE is greater than or equal to 32KB.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/skbuff.h |    5 ++--
 net/core/skbuff.c      |   55 ++++++++++++++++++++++++++++--------------------
 2 files changed, 34 insertions(+), 26 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9c2f793573fa..8b9a2c35a9d7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2128,9 +2128,8 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 		kfree_skb(skb);
 }
 
-#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
-#define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)
-#define NETDEV_PAGECNT_MAX_BIAS	   NETDEV_FRAG_PAGE_MAX_SIZE
+#define NETDEV_FRAG_PAGE_MAX_SIZE	__ALIGN_MASK(32768, ~PAGE_MASK)
+#define NETDEV_FRAG_PAGE_MAX_ORDER	get_order(NETDEV_FRAG_PAGE_MAX_SIZE)
 
 void *netdev_alloc_frag(unsigned int fragsz);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d6851ca32598..a3062ec341c3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -348,7 +348,13 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 EXPORT_SYMBOL(build_skb);
 
 struct netdev_alloc_cache {
-	struct page_frag	frag;
+	void * va;
+#if (PAGE_SIZE < NETDEV_FRAG_PAGE_MAX_SIZE)
+	__u16 offset;
+	__u16 size;
+#else
+	__u32 offset;
+#endif
 	/* we maintain a pagecount bias, so that we dont dirty cache line
 	 * containing page->_count every time we allocate a fragment.
 	 */
@@ -361,21 +367,20 @@ static DEFINE_PER_CPU(struct netdev_alloc_cache, napi_alloc_cache);
 static struct page *__page_frag_refill(struct netdev_alloc_cache *nc,
 				       gfp_t gfp_mask)
 {
-	const unsigned int order = NETDEV_FRAG_PAGE_MAX_ORDER;
 	struct page *page = NULL;
 	gfp_t gfp = gfp_mask;
 
-	if (order) {
-		gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY |
-			    __GFP_NOMEMALLOC;
-		page = alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
-		nc->frag.size = PAGE_SIZE << (page ? order : 0);
-	}
-
+#if (PAGE_SIZE < NETDEV_FRAG_PAGE_MAX_SIZE)
+	gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY |
+		    __GFP_NOMEMALLOC;
+	page = alloc_pages_node(NUMA_NO_NODE, gfp_mask,
+				NETDEV_FRAG_PAGE_MAX_ORDER);
+	nc->size = page ? NETDEV_FRAG_PAGE_MAX_SIZE : PAGE_SIZE;
+#endif
 	if (unlikely(!page))
 		page = alloc_pages_node(NUMA_NO_NODE, gfp, 0);
 
-	nc->frag.page = page;
+	nc->va = page ? page_address(page) : NULL;
 
 	return page;
 }
@@ -383,19 +388,20 @@ static struct page *__page_frag_refill(struct netdev_alloc_cache *nc,
 static void *__alloc_page_frag(struct netdev_alloc_cache *nc,
 			       unsigned int fragsz, gfp_t gfp_mask)
 {
-	struct page *page = nc->frag.page;
-	unsigned int size;
+	unsigned int size = PAGE_SIZE;
+	struct page *page;
 	int offset;
 
-	if (unlikely(!page)) {
+	if (unlikely(!nc->va)) {
 refill:
 		page = __page_frag_refill(nc, gfp_mask);
 		if (!page)
 			return NULL;
 
-		/* if size can vary use frag.size else just use PAGE_SIZE */
-		size = NETDEV_FRAG_PAGE_MAX_ORDER ? nc->frag.size : PAGE_SIZE;
-
+#if (PAGE_SIZE < NETDEV_FRAG_PAGE_MAX_SIZE)
+		/* if size can vary use size else just use PAGE_SIZE */
+		size = nc->size;
+#endif
 		/* Even if we own the page, we do not use atomic_set().
 		 * This would break get_page_unless_zero() users.
 		 */
@@ -404,17 +410,20 @@ refill:
 		/* reset page count bias and offset to start of new frag */
 		nc->pfmemalloc = page->pfmemalloc;
 		nc->pagecnt_bias = size;
-		nc->frag.offset = size;
+		nc->offset = size;
 	}
 
-	offset = nc->frag.offset - fragsz;
+	offset = nc->offset - fragsz;
 	if (unlikely(offset < 0)) {
+		page = virt_to_page(nc->va);
+
 		if (!atomic_sub_and_test(nc->pagecnt_bias, &page->_count))
 			goto refill;
 
-		/* if size can vary use frag.size else just use PAGE_SIZE */
-		size = NETDEV_FRAG_PAGE_MAX_ORDER ? nc->frag.size : PAGE_SIZE;
-
+#if (PAGE_SIZE < NETDEV_FRAG_PAGE_MAX_SIZE)
+		/* if size can vary use size else just use PAGE_SIZE */
+		size = nc->size;
+#endif
 		/* OK, page count is 0, we can safely set it */
 		atomic_set(&page->_count, size);
 
@@ -424,9 +433,9 @@ refill:
 	}
 
 	nc->pagecnt_bias--;
-	nc->frag.offset = offset;
+	nc->offset = offset;
 
-	return page_address(page) + offset;
+	return nc->va + offset;
 }
 
 static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
