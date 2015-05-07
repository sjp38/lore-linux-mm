Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 82DB86B006C
	for <linux-mm@kvack.org>; Thu,  7 May 2015 00:11:48 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so30962024wgy.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 21:11:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id co3si1239042wjb.161.2015.05.06.21.11.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 21:11:46 -0700 (PDT)
Subject: [PATCH 01/10] net: Use cached copy of pfmemalloc to avoid accessing
 page
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:11:40 -0700
Message-ID: <20150507041140.1873.58533.stgit@ahduyck-vm-fedora22>
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com

While testing I found that the testing for pfmemalloc in build_skb was
rather expensive.  I found the issue to be two-fold.  First we have to get
from the virtual address to the head page and that comes at the cost of
something like 11 cycles.  Then there is the cost for reading pfmemalloc out
of the head page which can be cache cold due to the fact that
put_page_testzero is likely invalidating the cache-line on one or more
CPUs as the fragments can be shared.

To avoid this extra expense I have added a pfmemalloc member to the
netdev_alloc_cache.  I then pushed pieces of __alloc_rx_skb into
__napi_alloc_skb and __netdev_alloc_skb so that I could rewrite them to
make use of the cached pfmemalloc value.  The result is that my perf traces
show a reduction from 9.28% overhead to 3.7% for the code covered by
build_skb, __alloc_rx_skb, and __napi_alloc_skb when performing a test with
the packet being dropped instead of being handed to napi_gro_receive.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/core/skbuff.c |  141 ++++++++++++++++++++++++++++++-----------------------
 1 file changed, 79 insertions(+), 62 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b9eb90b39ac7..d6851ca32598 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -353,6 +353,7 @@ struct netdev_alloc_cache {
 	 * containing page->_count every time we allocate a fragment.
 	 */
 	unsigned int		pagecnt_bias;
+	bool pfmemalloc;
 };
 static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
 static DEFINE_PER_CPU(struct netdev_alloc_cache, napi_alloc_cache);
@@ -379,10 +380,9 @@ static struct page *__page_frag_refill(struct netdev_alloc_cache *nc,
 	return page;
 }
 
-static void *__alloc_page_frag(struct netdev_alloc_cache __percpu *cache,
+static void *__alloc_page_frag(struct netdev_alloc_cache *nc,
 			       unsigned int fragsz, gfp_t gfp_mask)
 {
-	struct netdev_alloc_cache *nc = this_cpu_ptr(cache);
 	struct page *page = nc->frag.page;
 	unsigned int size;
 	int offset;
@@ -402,6 +402,7 @@ refill:
 		atomic_add(size - 1, &page->_count);
 
 		/* reset page count bias and offset to start of new frag */
+		nc->pfmemalloc = page->pfmemalloc;
 		nc->pagecnt_bias = size;
 		nc->frag.offset = size;
 	}
@@ -430,11 +431,13 @@ refill:
 
 static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
+	struct netdev_alloc_cache *nc;
 	unsigned long flags;
 	void *data;
 
 	local_irq_save(flags);
-	data = __alloc_page_frag(&netdev_alloc_cache, fragsz, gfp_mask);
+	nc = this_cpu_ptr(&netdev_alloc_cache);
+	data = __alloc_page_frag(nc, fragsz, gfp_mask);
 	local_irq_restore(flags);
 	return data;
 }
@@ -454,7 +457,9 @@ EXPORT_SYMBOL(netdev_alloc_frag);
 
 static void *__napi_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
-	return __alloc_page_frag(&napi_alloc_cache, fragsz, gfp_mask);
+	struct netdev_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
+
+	return __alloc_page_frag(nc, fragsz, gfp_mask);
 }
 
 void *napi_alloc_frag(unsigned int fragsz)
@@ -464,76 +469,64 @@ void *napi_alloc_frag(unsigned int fragsz)
 EXPORT_SYMBOL(napi_alloc_frag);
 
 /**
- *	__alloc_rx_skb - allocate an skbuff for rx
+ *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
+ *	@dev: network device to receive on
  *	@length: length to allocate
  *	@gfp_mask: get_free_pages mask, passed to alloc_skb
- *	@flags:	If SKB_ALLOC_RX is set, __GFP_MEMALLOC will be used for
- *		allocations in case we have to fallback to __alloc_skb()
- *		If SKB_ALLOC_NAPI is set, page fragment will be allocated
- *		from napi_cache instead of netdev_cache.
  *
  *	Allocate a new &sk_buff and assign it a usage count of one. The
- *	buffer has unspecified headroom built in. Users should allocate
+ *	buffer has NET_SKB_PAD headroom built in. Users should allocate
  *	the headroom they think they need without accounting for the
  *	built in space. The built in space is used for optimisations.
  *
  *	%NULL is returned if there is no free memory.
  */
-static struct sk_buff *__alloc_rx_skb(unsigned int length, gfp_t gfp_mask,
-				      int flags)
+struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int len,
+				   gfp_t gfp_mask)
 {
-	struct sk_buff *skb = NULL;
-	unsigned int fragsz = SKB_DATA_ALIGN(length) +
-			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	struct netdev_alloc_cache *nc;
+	unsigned long flags;
+	struct sk_buff *skb;
+	bool pfmemalloc;
+	void *data;
 
-	if (fragsz <= PAGE_SIZE && !(gfp_mask & (__GFP_WAIT | GFP_DMA))) {
-		void *data;
+	len += NET_SKB_PAD;
 
-		if (sk_memalloc_socks())
-			gfp_mask |= __GFP_MEMALLOC;
+	if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
+	    (gfp_mask & (__GFP_WAIT | GFP_DMA)))
+		return __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
 
-		data = (flags & SKB_ALLOC_NAPI) ?
-			__napi_alloc_frag(fragsz, gfp_mask) :
-			__netdev_alloc_frag(fragsz, gfp_mask);
+	len += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	len = SKB_DATA_ALIGN(len);
 
-		if (likely(data)) {
-			skb = build_skb(data, fragsz);
-			if (unlikely(!skb))
-				put_page(virt_to_head_page(data));
-		}
-	} else {
-		skb = __alloc_skb(length, gfp_mask,
-				  SKB_ALLOC_RX, NUMA_NO_NODE);
-	}
-	return skb;
-}
+	if (sk_memalloc_socks())
+		gfp_mask |= __GFP_MEMALLOC;
 
-/**
- *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
- *	@dev: network device to receive on
- *	@length: length to allocate
- *	@gfp_mask: get_free_pages mask, passed to alloc_skb
- *
- *	Allocate a new &sk_buff and assign it a usage count of one. The
- *	buffer has NET_SKB_PAD headroom built in. Users should allocate
- *	the headroom they think they need without accounting for the
- *	built in space. The built in space is used for optimisations.
- *
- *	%NULL is returned if there is no free memory.
- */
-struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
-				   unsigned int length, gfp_t gfp_mask)
-{
-	struct sk_buff *skb;
+	local_irq_save(flags);
 
-	length += NET_SKB_PAD;
-	skb = __alloc_rx_skb(length, gfp_mask, 0);
+	nc = this_cpu_ptr(&netdev_alloc_cache);
+	data = __alloc_page_frag(nc, len, gfp_mask);
+	pfmemalloc = nc->pfmemalloc;
 
-	if (likely(skb)) {
-		skb_reserve(skb, NET_SKB_PAD);
-		skb->dev = dev;
+	local_irq_restore(flags);
+
+	if (unlikely(!data))
+		return NULL;
+
+	skb = __build_skb(data, len);
+	if (unlikely(!skb)) {
+		put_page(virt_to_head_page(data));
+		return NULL;
 	}
 
+	/* use OR instead of assignment to avoid clearing of bits in mask */
+	if (pfmemalloc)
+		skb->pfmemalloc = 1;
+	skb->head_frag = 1;
+
+	skb_reserve(skb, NET_SKB_PAD);
+	skb->dev = dev;
+
 	return skb;
 }
 EXPORT_SYMBOL(__netdev_alloc_skb);
@@ -551,19 +544,43 @@ EXPORT_SYMBOL(__netdev_alloc_skb);
  *
  *	%NULL is returned if there is no free memory.
  */
-struct sk_buff *__napi_alloc_skb(struct napi_struct *napi,
-				 unsigned int length, gfp_t gfp_mask)
+struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
+				 gfp_t gfp_mask)
 {
+	struct netdev_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
 	struct sk_buff *skb;
+	void *data;
+
+	len += NET_SKB_PAD + NET_IP_ALIGN;
+
+	if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
+	    (gfp_mask & (__GFP_WAIT | GFP_DMA)))
+		return __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
+
+	len += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	len = SKB_DATA_ALIGN(len);
 
-	length += NET_SKB_PAD + NET_IP_ALIGN;
-	skb = __alloc_rx_skb(length, gfp_mask, SKB_ALLOC_NAPI);
+	if (sk_memalloc_socks())
+		gfp_mask |= __GFP_MEMALLOC;
+
+	data = __alloc_page_frag(nc, len, gfp_mask);
+	if (unlikely(!data))
+		return NULL;
 
-	if (likely(skb)) {
-		skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
-		skb->dev = napi->dev;
+	skb = __build_skb(data, len);
+	if (unlikely(!skb)) {
+		put_page(virt_to_head_page(data));
+		return NULL;
 	}
 
+	/* use OR instead of assignment to avoid clearing of bits in mask */
+	if (nc->pfmemalloc)
+		skb->pfmemalloc = 1;
+	skb->head_frag = 1;
+
+	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
+	skb->dev = napi->dev;
+
 	return skb;
 }
 EXPORT_SYMBOL(__napi_alloc_skb);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
