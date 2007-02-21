Message-Id: <20070221144843.002458000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Date: Wed, 21 Feb 2007 15:43:19 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 15/29] netvm: hook skb allocation to reserves
Content-Disposition: inline; filename=netvm-skbuff-reserve.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Change the skb allocation api to indicate RX usage and use this to fall back to
the reserve when needed. Skbs allocated from the reserve are tagged in
skb->emergency.

Teach all other skb ops about emergency skbs and the reserve accounting.

Use the (new) packet split API to allocate and track fragment pages from the
emergency reserve. Do this using an atomic counter in page->index. This is
needed because the fragments have a different sharing semantic than that
indicated by skb_shinfo()->dataref. 

(NOTE the extra atomic overhead is only for those pages allocated from the
reserves - it does not affect the normal fast path.)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/skbuff.h |   22 ++++--
 net/core/skbuff.c      |  170 ++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 165 insertions(+), 27 deletions(-)

Index: linux-2.6-git/include/linux/skbuff.h
===================================================================
--- linux-2.6-git.orig/include/linux/skbuff.h	2007-02-15 12:31:05.000000000 +0100
+++ linux-2.6-git/include/linux/skbuff.h	2007-02-15 12:31:05.000000000 +0100
@@ -284,7 +284,8 @@ struct sk_buff {
 				nfctinfo:3;
 	__u8			pkt_type:3,
 				fclone:2,
-				ipvs_property:1;
+				ipvs_property:1,
+				emergency:1;
 	__be16			protocol;
 
 	void			(*destructor)(struct sk_buff *skb);
@@ -329,10 +330,19 @@ struct sk_buff {
 
 #include <asm/system.h>
 
+#define SKB_ALLOC_FCLONE	0x01
+#define SKB_ALLOC_RX		0x02
+
+#ifdef CONFIG_NETVM
+#define skb_emergency(skb)	unlikely((skb)->emergency)
+#else
+#define skb_emergency(skb)	false
+#endif
+
 extern void kfree_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
-				   gfp_t priority, int fclone, int node);
+				   gfp_t priority, int flags, int node);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
@@ -342,7 +352,7 @@ static inline struct sk_buff *alloc_skb(
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, -1);
+	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, -1);
 }
 
 extern void	       kfree_skbmem(struct sk_buff *skb);
@@ -1103,7 +1113,8 @@ static inline void __skb_queue_purge(str
 static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
 					      gfp_t gfp_mask)
 {
-	struct sk_buff *skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
+	struct sk_buff *skb =
+		__alloc_skb(length + NET_SKB_PAD, gfp_mask, SKB_ALLOC_RX, -1);
 	if (likely(skb))
 		skb_reserve(skb, NET_SKB_PAD);
 	return skb;
@@ -1149,6 +1160,7 @@ static inline struct sk_buff *netdev_all
 }
 
 extern struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask);
+extern void __netdev_free_page(struct net_device *dev, struct page *page);
 
 /**
  *	netdev_alloc_page - allocate a page for ps-rx on a specific device
@@ -1165,7 +1177,7 @@ static inline struct page *netdev_alloc_
 
 static inline void netdev_free_page(struct net_device *dev, struct page *page)
 {
-	__free_page(page);
+	__netdev_free_page(dev, page);
 }
 
 /**
Index: linux-2.6-git/net/core/skbuff.c
===================================================================
--- linux-2.6-git.orig/net/core/skbuff.c	2007-02-15 12:31:05.000000000 +0100
+++ linux-2.6-git/net/core/skbuff.c	2007-02-15 12:45:50.000000000 +0100
@@ -142,28 +142,36 @@ EXPORT_SYMBOL(skb_truesize_bug);
  *	%GFP_ATOMIC.
  */
 struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
-			    int fclone, int node)
+			    int flags, int node)
 {
 	struct kmem_cache *cache;
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	u8 *data;
+	int emergency = 0;
 
-	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
+	size = SKB_DATA_ALIGN(size);
+	cache = (flags & SKB_ALLOC_FCLONE)
+		? skbuff_fclone_cache : skbuff_head_cache;
+#ifdef CONFIG_NETVM
+	if (flags & SKB_ALLOC_RX)
+		gfp_mask |= __GFP_NOMEMALLOC|__GFP_NOWARN;
+#endif
 
+retry_alloc:
 	/* Get the HEAD */
 	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
 	if (!skb)
-		goto out;
+		goto noskb;
 
 	/* Get the DATA. Size must match skb_add_mtu(). */
-	size = SKB_DATA_ALIGN(size);
 	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
 			gfp_mask, node);
 	if (!data)
 		goto nodata;
 
 	memset(skb, 0, offsetof(struct sk_buff, truesize));
+	skb->emergency = emergency;
 	skb->truesize = size + sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 	skb->head = data;
@@ -180,7 +188,7 @@ struct sk_buff *__alloc_skb(unsigned int
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
 
-	if (fclone) {
+	if (flags & SKB_ALLOC_FCLONE) {
 		struct sk_buff *child = skb + 1;
 		atomic_t *fclone_ref = (atomic_t *) (child + 1);
 
@@ -188,12 +196,31 @@ struct sk_buff *__alloc_skb(unsigned int
 		atomic_set(fclone_ref, 1);
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
+		child->emergency = skb->emergency;
 	}
 out:
 	return skb;
+
 nodata:
 	kmem_cache_free(cache, skb);
 	skb = NULL;
+noskb:
+#ifdef CONFIG_NETVM
+	/* Attempt emergency allocation when RX skb. */
+	if (likely(!(flags & SKB_ALLOC_RX) || !sk_vmio_socks()))
+		goto out;
+
+	if (!emergency) {
+		if (rx_emergency_get(size)) {
+			gfp_mask &= ~(__GFP_NOMEMALLOC|__GFP_NOWARN);
+			gfp_mask |= __GFP_EMERGENCY;
+			emergency = 1;
+			goto retry_alloc;
+		}
+	} else
+		rx_emergency_put(size);
+#endif
+
 	goto out;
 }
 
@@ -216,7 +243,7 @@ struct sk_buff *__netdev_alloc_skb(struc
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+ 	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, SKB_ALLOC_RX, node);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
@@ -229,10 +256,34 @@ struct page *__netdev_alloc_page(struct 
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct page *page;
 
+#ifdef CONFIG_NETVM
+	gfp_mask |= __GFP_NOMEMALLOC | __GFP_NOWARN;
+#endif
+
 	page = alloc_pages_node(node, gfp_mask, 0);
+
+#ifdef CONFIG_NETVM
+	if (!page && rx_emergency_get(PAGE_SIZE)) {
+		gfp_mask &= ~(__GFP_NOMEMALLOC | __GFP_NOWARN);
+		gfp_mask |= __GFP_EMERGENCY;
+		page = alloc_pages_node(node, gfp_mask, 0);
+		if (!page)
+			rx_emergency_put(PAGE_SIZE);
+	}
+#endif
+
 	return page;
 }
 
+void __netdev_free_page(struct net_device *dev, struct page *page)
+{
+#ifdef CONFIG_NETVM
+	if (unlikely(page->index == 0))
+		rx_emergency_put(PAGE_SIZE);
+#endif
+	__free_page(page);
+}
+
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 		int size)
 {
@@ -240,6 +291,33 @@ void skb_add_rx_frag(struct sk_buff *skb
 	skb->len += size;
 	skb->data_len += size;
 	skb->truesize += size;
+
+#ifdef CONFIG_NETVM
+	/*
+	 * Fix-up the emergency accounting; make sure all pages match
+	 * skb->emergency.
+	 *
+	 * This relies on the page rank (page->index) to be preserved between
+	 * the call to __netdev_alloc_page() and this call.
+	 */
+	if (skb_emergency(skb)) {
+		/*
+		 * If the page rank wasn't 0 (ALLOC_NO_WATERMARK) we can use
+		 * overcommit accounting, since we already have the memory.
+		 */
+		if (page->index != 0)
+			rx_emergency_get_overcommit(PAGE_SIZE);
+		atomic_set((atomic_t *)&page->index, 1);
+	} else if (unlikely(page->index == 0)) {
+		/*
+		 * Rare case; the skb wasn't allocated under pressure but
+		 * the page was. We need to return the page. This can offset
+		 * the accounting a little, but its a constant shift, it does
+		 * not accumulate.
+		 */
+		rx_emergency_put(PAGE_SIZE);
+	}
+#endif
 }
 
 static void skb_drop_list(struct sk_buff **listp)
@@ -273,16 +351,25 @@ static void skb_release_data(struct sk_b
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
+		int size = skb->end - skb->head;
+
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
-			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-				put_page(skb_shinfo(skb)->frags[i].page);
+			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+				struct page *page = skb_shinfo(skb)->frags[i].page;
+				put_page(page);
+				if (skb_emergency(skb) &&
+				    atomic_dec_and_test((atomic_t *)&page->index))
+					rx_emergency_put(PAGE_SIZE);
+			}
 		}
 
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
 
 		kfree(skb->head);
+		if (skb_emergency(skb))
+			rx_emergency_put(size);
 	}
 }
 
@@ -403,6 +490,9 @@ struct sk_buff *skb_clone(struct sk_buff
 		n->fclone = SKB_FCLONE_CLONE;
 		atomic_inc(fclone_ref);
 	} else {
+		if (skb_emergency(skb))
+			gfp_mask |= __GFP_EMERGENCY;
+
 		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)
 			return NULL;
@@ -437,6 +527,7 @@ struct sk_buff *skb_clone(struct sk_buff
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	C(ipvs_property);
 #endif
+	C(emergency);
 	C(protocol);
 	n->destructor = NULL;
 	C(mark);
@@ -530,6 +621,8 @@ static void copy_skb_header(struct sk_bu
 	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
 }
 
+#define skb_alloc_rx(skb) (skb_emergency(skb) ? SKB_ALLOC_RX : 0)
+
 /**
  *	skb_copy	-	create private copy of an sk_buff
  *	@skb: buffer to copy
@@ -553,8 +646,8 @@ struct sk_buff *skb_copy(const struct sk
 	/*
 	 *	Allocate the copy buffer
 	 */
-	struct sk_buff *n = alloc_skb(skb->end - skb->head + skb->data_len,
-				      gfp_mask);
+	struct sk_buff *n = __alloc_skb(skb->end - skb->head + skb->data_len,
+					gfp_mask, skb_alloc_rx(skb), -1);
 	if (!n)
 		return NULL;
 
@@ -591,7 +684,8 @@ struct sk_buff *pskb_copy(struct sk_buff
 	/*
 	 *	Allocate the copy buffer
 	 */
-	struct sk_buff *n = alloc_skb(skb->end - skb->head, gfp_mask);
+	struct sk_buff *n = __alloc_skb(skb->end - skb->head, gfp_mask,
+					skb_alloc_rx(skb), -1);
 
 	if (!n)
 		goto out;
@@ -613,8 +707,11 @@ struct sk_buff *pskb_copy(struct sk_buff
 		int i;
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
-			get_page(skb_shinfo(n)->frags[i].page);
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			skb_shinfo(n)->frags[i] = *frag;
+			get_page(frag->page);
+			if (skb_emergency(n))
+				atomic_inc((atomic_t *)&frag->page->index);
 		}
 		skb_shinfo(n)->nr_frags = i;
 	}
@@ -652,12 +749,19 @@ int pskb_expand_head(struct sk_buff *skb
 	u8 *data;
 	int size = nhead + (skb->end - skb->head) + ntail;
 	long off;
+	int emergency = 0;
 
 	if (skb_shared(skb))
 		BUG();
 
 	size = SKB_DATA_ALIGN(size);
 
+	if (skb_emergency(skb) && rx_emergency_get(size)) {
+		gfp_mask |= __GFP_EMERGENCY;
+		emergency = 1;
+	} else
+		gfp_mask |= __GFP_NOMEMALLOC;
+
 	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
 	if (!data)
 		goto nodata;
@@ -667,8 +771,12 @@ int pskb_expand_head(struct sk_buff *skb
 	memcpy(data + nhead, skb->head, skb->tail - skb->head);
 	memcpy(data + size, skb->end, sizeof(struct skb_shared_info));
 
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		get_page(skb_shinfo(skb)->frags[i].page);
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		struct page *page = skb_shinfo(skb)->frags[i].page;
+		get_page(page);
+		if (emergency)
+			atomic_inc((atomic_t *)&page->index);
+	}
 
 	if (skb_shinfo(skb)->frag_list)
 		skb_clone_fraglist(skb);
@@ -690,6 +798,8 @@ int pskb_expand_head(struct sk_buff *skb
 	return 0;
 
 nodata:
+	if (unlikely(emergency))
+		rx_emergency_put(size);
 	return -ENOMEM;
 }
 
@@ -742,8 +852,8 @@ struct sk_buff *skb_copy_expand(const st
 	/*
 	 *	Allocate the copy buffer
 	 */
-	struct sk_buff *n = alloc_skb(newheadroom + skb->len + newtailroom,
-				      gfp_mask);
+	struct sk_buff *n = __alloc_skb(newheadroom + skb->len + newtailroom,
+					gfp_mask, skb_alloc_rx(skb), -1);
 	int head_copy_len, head_copy_off;
 
 	if (!n)
@@ -849,8 +959,13 @@ int ___pskb_trim(struct sk_buff *skb, un
 drop_pages:
 		skb_shinfo(skb)->nr_frags = i;
 
-		for (; i < nfrags; i++)
-			put_page(skb_shinfo(skb)->frags[i].page);
+		for (; i < nfrags; i++) {
+			struct page *page = skb_shinfo(skb)->frags[i].page;
+			put_page(page);
+			if (skb_emergency(skb) &&
+			    atomic_dec_and_test((atomic_t *)&page->index))
+				rx_emergency_put(PAGE_SIZE);
+		}
 
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
@@ -1019,7 +1134,11 @@ pull_pages:
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		if (skb_shinfo(skb)->frags[i].size <= eat) {
-			put_page(skb_shinfo(skb)->frags[i].page);
+			struct page *page = skb_shinfo(skb)->frags[i].page;
+			put_page(page);
+			if (skb_emergency(skb) &&
+			    atomic_dec_and_test((atomic_t *)&page->index))
+				rx_emergency_put(PAGE_SIZE);
 			eat -= skb_shinfo(skb)->frags[i].size;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
@@ -1593,6 +1712,7 @@ static inline void skb_split_no_header(s
 			skb_shinfo(skb1)->frags[k] = skb_shinfo(skb)->frags[i];
 
 			if (pos < len) {
+				struct page *page = skb_shinfo(skb)->frags[i].page;
 				/* Split frag.
 				 * We have two variants in this case:
 				 * 1. Move all the frag to the second
@@ -1601,7 +1721,9 @@ static inline void skb_split_no_header(s
 				 *    where splitting is expensive.
 				 * 2. Split is accurately. We make this.
 				 */
-				get_page(skb_shinfo(skb)->frags[i].page);
+				get_page(page);
+				if (skb_emergency(skb1))
+					atomic_inc((atomic_t *)&page->index);
 				skb_shinfo(skb1)->frags[0].page_offset += len - pos;
 				skb_shinfo(skb1)->frags[0].size -= len - pos;
 				skb_shinfo(skb)->frags[i].size	= len - pos;
@@ -1927,7 +2049,8 @@ struct sk_buff *skb_segment(struct sk_bu
 		if (hsize > len || !sg)
 			hsize = len;
 
-		nskb = alloc_skb(hsize + doffset + headroom, GFP_ATOMIC);
+		nskb = __alloc_skb(hsize + doffset + headroom, GFP_ATOMIC,
+				   skb_alloc_rx(skb), -1);
 		if (unlikely(!nskb))
 			goto err;
 
@@ -1970,6 +2093,8 @@ struct sk_buff *skb_segment(struct sk_bu
 
 			*frag = skb_shinfo(skb)->frags[i];
 			get_page(frag->page);
+			if (skb_emergency(nskb))
+				atomic_inc((atomic_t *)&frag->page->index);
 			size = frag->size;
 
 			if (pos < offset) {
@@ -2030,6 +2155,7 @@ EXPORT_SYMBOL(__pskb_pull_tail);
 EXPORT_SYMBOL(__alloc_skb);
 EXPORT_SYMBOL(__netdev_alloc_skb);
 EXPORT_SYMBOL(__netdev_alloc_page);
+EXPORT_SYMBOL(__netdev_free_page);
 EXPORT_SYMBOL(skb_add_rx_frag);
 EXPORT_SYMBOL(pskb_copy);
 EXPORT_SYMBOL(pskb_expand_head);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
