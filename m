Message-Id: <20080220150307.507134000@chello.nl>
References: <20080220144610.548202000@chello.nl>
Date: Wed, 20 Feb 2008 15:46:27 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 17/28] netvm: hook skb allocation to reserves
Content-Disposition: inline; filename=netvm-skbuff-reserve.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Change the skb allocation api to indicate RX usage and use this to fall back to
the reserve when needed. SKBs allocated from the reserve are tagged in
skb->emergency.

Teach all other skb ops about emergency skbs and the reserve accounting.

Use the (new) packet split API to allocate and track fragment pages from the
emergency reserve. Do this using an atomic counter in page->index. This is
needed because the fragments have a different sharing semantic than that
indicated by skb_shinfo()->dataref. 

Note that the decision to distinguish between regular and emergency SKBs allows
the accounting overhead to be limited to the later kind.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm_types.h |    1 
 include/linux/skbuff.h   |   26 +++++-
 net/core/skbuff.c        |  177 +++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 177 insertions(+), 27 deletions(-)

Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h
+++ linux-2.6/include/linux/skbuff.h
@@ -308,7 +308,9 @@ struct sk_buff {
 	__u16			tc_verd;	/* traffic control verdict */
 #endif
 #endif
-	/* 2 byte hole */
+	__u8 			emergency:1;
+				/* 7 bit hole */
+	/* 1 byte hole */
 
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
@@ -339,10 +341,22 @@ struct sk_buff {
 
 #include <asm/system.h>
 
+#define SKB_ALLOC_FCLONE	0x01
+#define SKB_ALLOC_RX		0x02
+
+static inline bool skb_emergency(const struct sk_buff *skb)
+{
+#ifdef CONFIG_NETVM
+	return unlikely(skb->emergency);
+#else
+	return false;
+#endif
+}
+
 extern void kfree_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
-				   gfp_t priority, int fclone, int node);
+				   gfp_t priority, int flags, int node);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
@@ -352,7 +366,7 @@ static inline struct sk_buff *alloc_skb(
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, -1);
+	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, -1);
 }
 
 extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
@@ -1297,7 +1311,8 @@ static inline void __skb_queue_purge(str
 static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
 					      gfp_t gfp_mask)
 {
-	struct sk_buff *skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
+	struct sk_buff *skb =
+		__alloc_skb(length + NET_SKB_PAD, gfp_mask, SKB_ALLOC_RX, -1);
 	if (likely(skb))
 		skb_reserve(skb, NET_SKB_PAD);
 	return skb;
@@ -1343,6 +1358,7 @@ static inline struct sk_buff *netdev_all
 }
 
 extern struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask);
+extern void __netdev_free_page(struct net_device *dev, struct page *page);
 
 /**
  *	netdev_alloc_page - allocate a page for ps-rx on a specific device
@@ -1359,7 +1375,7 @@ static inline struct page *netdev_alloc_
 
 static inline void netdev_free_page(struct net_device *dev, struct page *page)
 {
-	__free_page(page);
+	__netdev_free_page(dev, page);
 }
 
 /**
Index: linux-2.6/net/core/skbuff.c
===================================================================
--- linux-2.6.orig/net/core/skbuff.c
+++ linux-2.6/net/core/skbuff.c
@@ -179,21 +179,28 @@ EXPORT_SYMBOL(skb_truesize_bug);
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
+	int emergency = 0, memalloc = sk_memalloc_socks();
 
-	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
+	size = SKB_DATA_ALIGN(size);
+	cache = (flags & SKB_ALLOC_FCLONE)
+		? skbuff_fclone_cache : skbuff_head_cache;
+#ifdef CONFIG_NETVM
+	if (memalloc && (flags & SKB_ALLOC_RX))
+		gfp_mask |= __GFP_NOMEMALLOC|__GFP_NOWARN;
 
+retry_alloc:
+#endif
 	/* Get the HEAD */
 	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
 	if (!skb)
-		goto out;
+		goto noskb;
 
-	size = SKB_DATA_ALIGN(size);
 	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
 			gfp_mask, node);
 	if (!data)
@@ -203,6 +210,7 @@ struct sk_buff *__alloc_skb(unsigned int
 	 * See comment in sk_buff definition, just before the 'tail' member
 	 */
 	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb->emergency = emergency;
 	skb->truesize = size + sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 	skb->head = data;
@@ -219,7 +227,7 @@ struct sk_buff *__alloc_skb(unsigned int
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
 
-	if (fclone) {
+	if (flags & SKB_ALLOC_FCLONE) {
 		struct sk_buff *child = skb + 1;
 		atomic_t *fclone_ref = (atomic_t *) (child + 1);
 
@@ -227,12 +235,31 @@ struct sk_buff *__alloc_skb(unsigned int
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
+	if (likely(!(flags & SKB_ALLOC_RX) || !memalloc))
+		goto out;
+
+	if (!emergency) {
+		if (rx_emergency_get(size)) {
+			gfp_mask &= ~(__GFP_NOMEMALLOC|__GFP_NOWARN);
+			gfp_mask |= __GFP_MEMALLOC;
+			emergency = 1;
+			goto retry_alloc;
+		}
+	} else
+		rx_emergency_put(size);
+#endif
+
 	goto out;
 }
 
@@ -255,7 +282,7 @@ struct sk_buff *__netdev_alloc_skb(struc
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, SKB_ALLOC_RX, node);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
@@ -268,11 +295,36 @@ struct page *__netdev_alloc_page(struct 
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
+		gfp_mask |= __GFP_MEMALLOC;
+		page = alloc_pages_node(node, gfp_mask, 0);
+		if (!page)
+			rx_emergency_put(PAGE_SIZE);
+	}
+#endif
+
 	return page;
 }
 EXPORT_SYMBOL(__netdev_alloc_page);
 
+void __netdev_free_page(struct net_device *dev, struct page *page)
+{
+#ifdef CONFIG_NETVM
+	if (unlikely(page->reserve))
+		rx_emergency_put(PAGE_SIZE);
+#endif
+	__free_page(page);
+}
+EXPORT_SYMBOL(__netdev_free_page);
+
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 		int size)
 {
@@ -280,6 +332,34 @@ void skb_add_rx_frag(struct sk_buff *skb
 	skb->len += size;
 	skb->data_len += size;
 	skb->truesize += size;
+
+#ifdef CONFIG_NETVM
+	/*
+	 * Fix-up the emergency accounting; make sure all pages match
+	 * skb->emergency.
+	 *
+	 * This relies on page->reserve to be preserved between
+	 * the call to __netdev_alloc_page() and this call.
+	 */
+	if (skb_emergency(skb)) {
+		/*
+		 * If the page was not an emergency alloc (ALLOC_NO_WATERMARK)
+		 * we can use overcommit accounting, since we already have the
+		 * memory.
+		 */
+		if (!page->reserve)
+			rx_emergency_get_overcommit(PAGE_SIZE);
+		atomic_set(&page->frag_count, 1);
+	} else if (unlikely(page->reserve)) {
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
 EXPORT_SYMBOL(skb_add_rx_frag);
 
@@ -309,21 +389,47 @@ static void skb_clone_fraglist(struct sk
 		skb_get(list);
 }
 
+static inline void skb_get_page(struct sk_buff *skb, struct page *page)
+{
+	get_page(page);
+	if (skb_emergency(skb))
+		atomic_inc(&page->frag_count);
+}
+
+static inline void skb_put_page(struct sk_buff *skb, struct page *page)
+{
+	if (skb_emergency(skb) && atomic_dec_and_test(&page->frag_count))
+		rx_emergency_put(PAGE_SIZE);
+	put_page(page);
+}
+
 static void skb_release_data(struct sk_buff *skb)
 {
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
+		int size;
+
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+		size = skb->end;
+#else
+		size = skb->end - skb->head;
+#endif
+
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
-			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-				put_page(skb_shinfo(skb)->frags[i].page);
+			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+				skb_put_page(skb,
+					     skb_shinfo(skb)->frags[i].page);
+			}
 		}
 
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
 
 		kfree(skb->head);
+		if (skb_emergency(skb))
+			rx_emergency_put(size);
 	}
 }
 
@@ -444,6 +550,7 @@ static void __copy_skb_header(struct sk_
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	new->ipvs_property	= old->ipvs_property;
 #endif
+	new->emergency		= old->emergency;
 	new->protocol		= old->protocol;
 	new->mark		= old->mark;
 	__nf_copy(new, old);
@@ -532,6 +639,9 @@ struct sk_buff *skb_clone(struct sk_buff
 		n->fclone = SKB_FCLONE_CLONE;
 		atomic_inc(fclone_ref);
 	} else {
+		if (skb_emergency(skb))
+			gfp_mask |= __GFP_MEMALLOC;
+
 		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)
 			return NULL;
@@ -563,6 +673,14 @@ static void copy_skb_header(struct sk_bu
 	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
 }
 
+static inline int skb_alloc_rx_flag(const struct sk_buff *skb)
+{
+	if (skb_emergency(skb))
+		return SKB_ALLOC_RX;
+
+	return 0;
+}
+
 /**
  *	skb_copy	-	create private copy of an sk_buff
  *	@skb: buffer to copy
@@ -583,15 +701,17 @@ static void copy_skb_header(struct sk_bu
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
+	n = __alloc_skb(size, gfp_mask, skb_alloc_rx_flag(skb), -1);
 	if (!n)
 		return NULL;
 
@@ -626,12 +746,14 @@ struct sk_buff *pskb_copy(struct sk_buff
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
+	n = __alloc_skb(size, gfp_mask, skb_alloc_rx_flag(skb), -1);
 	if (!n)
 		goto out;
 
@@ -650,8 +772,9 @@ struct sk_buff *pskb_copy(struct sk_buff
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
@@ -699,6 +822,14 @@ int pskb_expand_head(struct sk_buff *skb
 
 	size = SKB_DATA_ALIGN(size);
 
+	if (skb_emergency(skb)) {
+		if (rx_emergency_get(size))
+			gfp_mask |= __GFP_MEMALLOC;
+		else
+			goto nodata;
+	} else
+		gfp_mask |= __GFP_NOMEMALLOC;
+
 	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
 	if (!data)
 		goto nodata;
@@ -714,7 +845,7 @@ int pskb_expand_head(struct sk_buff *skb
 	       sizeof(struct skb_shared_info));
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		get_page(skb_shinfo(skb)->frags[i].page);
+		skb_get_page(skb, skb_shinfo(skb)->frags[i].page);
 
 	if (skb_shinfo(skb)->frag_list)
 		skb_clone_fraglist(skb);
@@ -793,8 +924,8 @@ struct sk_buff *skb_copy_expand(const st
 	/*
 	 *	Allocate the copy buffer
 	 */
-	struct sk_buff *n = alloc_skb(newheadroom + skb->len + newtailroom,
-				      gfp_mask);
+	struct sk_buff *n = __alloc_skb(newheadroom + skb->len + newtailroom,
+					gfp_mask, skb_alloc_rx_flag(skb), -1);
 	int oldheadroom = skb_headroom(skb);
 	int head_copy_len, head_copy_off;
 	int off;
@@ -911,7 +1042,7 @@ drop_pages:
 		skb_shinfo(skb)->nr_frags = i;
 
 		for (; i < nfrags; i++)
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_put_page(skb, skb_shinfo(skb)->frags[i].page);
 
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
@@ -1080,7 +1211,7 @@ pull_pages:
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		if (skb_shinfo(skb)->frags[i].size <= eat) {
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_put_page(skb, skb_shinfo(skb)->frags[i].page);
 			eat -= skb_shinfo(skb)->frags[i].size;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
@@ -1852,6 +1983,7 @@ static inline void skb_split_no_header(s
 			skb_shinfo(skb1)->frags[k] = skb_shinfo(skb)->frags[i];
 
 			if (pos < len) {
+				struct page *page = skb_shinfo(skb)->frags[i].page;
 				/* Split frag.
 				 * We have two variants in this case:
 				 * 1. Move all the frag to the second
@@ -1860,7 +1992,7 @@ static inline void skb_split_no_header(s
 				 *    where splitting is expensive.
 				 * 2. Split is accurately. We make this.
 				 */
-				get_page(skb_shinfo(skb)->frags[i].page);
+				skb_get_page(skb1, page);
 				skb_shinfo(skb1)->frags[0].page_offset += len - pos;
 				skb_shinfo(skb1)->frags[0].size -= len - pos;
 				skb_shinfo(skb)->frags[i].size	= len - pos;
@@ -2190,7 +2322,8 @@ struct sk_buff *skb_segment(struct sk_bu
 		if (hsize > len || !sg)
 			hsize = len;
 
-		nskb = alloc_skb(hsize + doffset + headroom, GFP_ATOMIC);
+		nskb = __alloc_skb(hsize + doffset + headroom, GFP_ATOMIC,
+				   skb_alloc_rx_flag(skb), -1);
 		if (unlikely(!nskb))
 			goto err;
 
@@ -2235,7 +2368,7 @@ struct sk_buff *skb_segment(struct sk_bu
 			BUG_ON(i >= nfrags);
 
 			*frag = skb_shinfo(skb)->frags[i];
-			get_page(frag->page);
+			skb_get_page(nskb, frag->page);
 			size = frag->size;
 
 			if (pos < offset) {
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -74,6 +74,7 @@ struct page {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
 		int reserve;		/* page_alloc: page is a reserve page */
+		atomic_t frag_count;	/* skb fragment use count */
 	};
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
