Message-Id: <20070504103159.150015136@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:07 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 16/40] netvm: hook skb allocation to reserves
Content-Disposition: inline; filename=netvm-skbuff-reserve.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
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
 include/linux/skbuff.h |   22 +++++-
 net/core/skbuff.c      |  161 ++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 157 insertions(+), 26 deletions(-)

Index: linux-2.6-git/include/linux/skbuff.h
===================================================================
--- linux-2.6-git.orig/include/linux/skbuff.h
+++ linux-2.6-git/include/linux/skbuff.h
@@ -277,7 +277,8 @@ struct sk_buff {
 				nfctinfo:3;
 	__u8			pkt_type:3,
 				fclone:2,
-				ipvs_property:1;
+				ipvs_property:1,
+				emergency:1;
 	__be16			protocol;
 
 	void			(*destructor)(struct sk_buff *skb);
@@ -323,10 +324,19 @@ struct sk_buff {
 
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
@@ -336,7 +346,7 @@ static inline struct sk_buff *alloc_skb(
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, -1);
+	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, -1);
 }
 
 extern void	       kfree_skbmem(struct sk_buff *skb);
@@ -1279,7 +1289,8 @@ static inline void __skb_queue_purge(str
 static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
 					      gfp_t gfp_mask)
 {
-	struct sk_buff *skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
+	struct sk_buff *skb =
+		__alloc_skb(length + NET_SKB_PAD, gfp_mask, SKB_ALLOC_RX, -1);
 	if (likely(skb))
 		skb_reserve(skb, NET_SKB_PAD);
 	return skb;
@@ -1325,6 +1336,7 @@ static inline struct sk_buff *netdev_all
 }
 
 extern struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask);
+extern void __netdev_free_page(struct net_device *dev, struct page *page);
 
 /**
  *	netdev_alloc_page - allocate a page for ps-rx on a specific device
@@ -1341,7 +1353,7 @@ static inline struct page *netdev_alloc_
 
 static inline void netdev_free_page(struct net_device *dev, struct page *page)
 {
-	__free_page(page);
+	__netdev_free_page(dev, page);
 }
 
 /**
Index: linux-2.6-git/net/core/skbuff.c
===================================================================
--- linux-2.6-git.orig/net/core/skbuff.c
+++ linux-2.6-git/net/core/skbuff.c
@@ -144,21 +144,28 @@ EXPORT_SYMBOL(skb_truesize_bug);
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
 
-	size = SKB_DATA_ALIGN(size);
 	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
 			gfp_mask, node);
 	if (!data)
@@ -168,6 +175,7 @@ struct sk_buff *__alloc_skb(unsigned int
 	 * See comment in sk_buff definition, just before the 'tail' member
 	 */
 	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb->emergency = emergency;
 	skb->truesize = size + sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 	skb->head = data;
@@ -184,7 +192,7 @@ struct sk_buff *__alloc_skb(unsigned int
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
 
-	if (fclone) {
+	if (flags & SKB_ALLOC_FCLONE) {
 		struct sk_buff *child = skb + 1;
 		atomic_t *fclone_ref = (atomic_t *) (child + 1);
 
@@ -192,12 +200,31 @@ struct sk_buff *__alloc_skb(unsigned int
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
 
@@ -220,7 +247,7 @@ struct sk_buff *__netdev_alloc_skb(struc
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+ 	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, SKB_ALLOC_RX, node);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
@@ -233,10 +260,34 @@ struct page *__netdev_alloc_page(struct 
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
@@ -244,6 +295,33 @@ void skb_add_rx_frag(struct sk_buff *skb
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
@@ -272,21 +350,40 @@ static void skb_clone_fraglist(struct sk
 		skb_get(list);
 }
 
+static inline void skb_get_page(struct sk_buff *skb, struct page *page)
+{
+	get_page(page);
+	if (skb_emergency(skb))
+		atomic_inc((atomic_t *)&page->index);
+}
+
+static inline void skb_put_page(struct sk_buff *skb, struct page *page)
+{
+	if (skb_emergency(skb) &&
+			atomic_dec_and_test((atomic_t *)&page->index))
+		rx_emergency_put(PAGE_SIZE);
+	put_page(page);
+}
+
 static void skb_release_data(struct sk_buff *skb)
 {
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
+		int size = skb->end - skb->head;
+
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
 			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-				put_page(skb_shinfo(skb)->frags[i].page);
+				skb_put_page(skb, skb_shinfo(skb)->frags[i].page);
 		}
 
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
 
 		kfree(skb->head);
+		if (skb_emergency(skb))
+			rx_emergency_put(size);
 	}
 }
 
@@ -405,6 +502,9 @@ struct sk_buff *skb_clone(struct sk_buff
 		n->fclone = SKB_FCLONE_CLONE;
 		atomic_inc(fclone_ref);
 	} else {
+		if (skb_emergency(skb))
+			gfp_mask |= __GFP_EMERGENCY;
+
 		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)
 			return NULL;
@@ -440,6 +540,7 @@ struct sk_buff *skb_clone(struct sk_buff
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	C(ipvs_property);
 #endif
+	C(emergency);
 	C(protocol);
 	n->destructor = NULL;
 	C(mark);
@@ -516,6 +617,8 @@ static void copy_skb_header(struct sk_bu
 	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
 }
 
+#define skb_alloc_rx(skb) (skb_emergency(skb) ? SKB_ALLOC_RX : 0)
+
 /**
  *	skb_copy	-	create private copy of an sk_buff
  *	@skb: buffer to copy
@@ -536,15 +639,17 @@ static void copy_skb_header(struct sk_bu
 struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 {
 	int headerlen = skb->data - skb->head;
+	int size;
 	/*
 	 *	Allocate the copy buffer
 	 */
 	struct sk_buff *n;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
-	n = alloc_skb(skb->end + skb->data_len, gfp_mask);
+	size = skb->end + skb->data_len;
 #else
-	n = alloc_skb(skb->end - skb->head + skb->data_len, gfp_mask);
+	size = skb->end - skb->head + skb->data_len;
 #endif
+	n = __alloc_skb(size, gfp_mask, skb_alloc_rx(skb), -1);
 	if (!n)
 		return NULL;
 
@@ -581,12 +686,14 @@ struct sk_buff *pskb_copy(struct sk_buff
 	/*
 	 *	Allocate the copy buffer
 	 */
+	int size;
 	struct sk_buff *n;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
-	n = alloc_skb(skb->end, gfp_mask);
+	size = skb->end;
 #else
-	n = alloc_skb(skb->end - skb->head, gfp_mask);
+	size = skb->end - skb->head;
 #endif
+	n = __alloc_skb(size, gfp_mask, skb_alloc_rx(skb), -1);
 	if (!n)
 		goto out;
 
@@ -607,8 +714,9 @@ struct sk_buff *pskb_copy(struct sk_buff
 		int i;
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
-			get_page(skb_shinfo(n)->frags[i].page);
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			skb_shinfo(n)->frags[i] = *frag;
+			skb_get_page(n, frag->page);
 		}
 		skb_shinfo(n)->nr_frags = i;
 	}
@@ -656,6 +764,14 @@ int pskb_expand_head(struct sk_buff *skb
 
 	size = SKB_DATA_ALIGN(size);
 
+	if (skb_emergency(skb)) {
+		if (rx_emergency_get(size))
+			gfp_mask |= __GFP_EMERGENCY;
+		else
+			goto nodata;
+	} else
+		gfp_mask |= __GFP_NOMEMALLOC;
+
 	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
 	if (!data)
 		goto nodata;
@@ -672,7 +788,7 @@ int pskb_expand_head(struct sk_buff *skb
 	       sizeof(struct skb_shared_info));
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		get_page(skb_shinfo(skb)->frags[i].page);
+		skb_get_page(skb, skb_shinfo(skb)->frags[i].page);
 
 	if (skb_shinfo(skb)->frag_list)
 		skb_clone_fraglist(skb);
@@ -752,8 +868,8 @@ struct sk_buff *skb_copy_expand(const st
 	/*
 	 *	Allocate the copy buffer
 	 */
-	struct sk_buff *n = alloc_skb(newheadroom + skb->len + newtailroom,
-				      gfp_mask);
+	struct sk_buff *n = __alloc_skb(newheadroom + skb->len + newtailroom,
+				        gfp_mask, skb_alloc_rx(skb), -1);
 	int oldheadroom = skb_headroom(skb);
 	int head_copy_len, head_copy_off;
 	int off = 0;
@@ -869,7 +985,7 @@ drop_pages:
 		skb_shinfo(skb)->nr_frags = i;
 
 		for (; i < nfrags; i++)
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_put_page(skb, skb_shinfo(skb)->frags[i].page);
 
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
@@ -1038,7 +1154,7 @@ pull_pages:
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		if (skb_shinfo(skb)->frags[i].size <= eat) {
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_put_page(skb, skb_shinfo(skb)->frags[i].page);
 			eat -= skb_shinfo(skb)->frags[i].size;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
@@ -1599,6 +1715,7 @@ static inline void skb_split_no_header(s
 			skb_shinfo(skb1)->frags[k] = skb_shinfo(skb)->frags[i];
 
 			if (pos < len) {
+				struct page *page = skb_shinfo(skb)->frags[i].page;
 				/* Split frag.
 				 * We have two variants in this case:
 				 * 1. Move all the frag to the second
@@ -1607,7 +1724,7 @@ static inline void skb_split_no_header(s
 				 *    where splitting is expensive.
 				 * 2. Split is accurately. We make this.
 				 */
-				get_page(skb_shinfo(skb)->frags[i].page);
+				skb_get_page(skb1, page);
 				skb_shinfo(skb1)->frags[0].page_offset += len - pos;
 				skb_shinfo(skb1)->frags[0].size -= len - pos;
 				skb_shinfo(skb)->frags[i].size	= len - pos;
@@ -1933,7 +2050,8 @@ struct sk_buff *skb_segment(struct sk_bu
 		if (hsize > len || !sg)
 			hsize = len;
 
-		nskb = alloc_skb(hsize + doffset + headroom, GFP_ATOMIC);
+		nskb = __alloc_skb(hsize + doffset + headroom, GFP_ATOMIC,
+				   skb_alloc_rx(skb), -1);
 		if (unlikely(!nskb))
 			goto err;
 
@@ -1977,7 +2095,7 @@ struct sk_buff *skb_segment(struct sk_bu
 			BUG_ON(i >= nfrags);
 
 			*frag = skb_shinfo(skb)->frags[i];
-			get_page(frag->page);
+			skb_get_page(nskb, frag->page);
 			size = frag->size;
 
 			if (pos < offset) {
@@ -2222,6 +2340,7 @@ EXPORT_SYMBOL(__pskb_pull_tail);
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
