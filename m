Message-Id: <20081002131609.203682378@chello.nl>
References: <20081002130504.927878499@chello.nl>
Date: Thu, 02 Oct 2008 15:05:25 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 21/32] netvm: hook skb allocation to reserves
Content-Disposition: inline; filename=netvm-skbuff-reserve.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
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
 include/linux/skbuff.h   |   27 +++++++--
 net/core/skbuff.c        |  135 +++++++++++++++++++++++++++++++++++++----------
 3 files changed, 132 insertions(+), 31 deletions(-)

Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h
+++ linux-2.6/include/linux/skbuff.h
@@ -320,7 +320,10 @@ struct sk_buff {
 #if defined(CONFIG_MAC80211) || defined(CONFIG_MAC80211_MODULE)
 	__u8			do_not_encrypt:1;
 #endif
-	/* 0/13/14 bit hole */
+#ifdef CONFIG_NETVM
+	__u8 			emergency:1;
+#endif
+	/* 12-16 bit hole */
 
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
@@ -353,10 +356,22 @@ struct sk_buff {
 
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
@@ -366,7 +381,7 @@ static inline struct sk_buff *alloc_skb(
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, -1);
+	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, -1);
 }
 
 extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
@@ -1216,7 +1231,8 @@ static inline void __skb_queue_purge(str
 static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
 					      gfp_t gfp_mask)
 {
-	struct sk_buff *skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
+	struct sk_buff *skb =
+		__alloc_skb(length + NET_SKB_PAD, gfp_mask, SKB_ALLOC_RX, -1);
 	if (likely(skb))
 		skb_reserve(skb, NET_SKB_PAD);
 	return skb;
@@ -1247,6 +1263,7 @@ static inline struct sk_buff *netdev_all
 }
 
 extern struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask);
+extern void __netdev_free_page(struct net_device *dev, struct page *page);
 
 /**
  *	netdev_alloc_page - allocate a page for ps-rx on a specific device
@@ -1263,7 +1280,7 @@ static inline struct page *netdev_alloc_
 
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
@@ -177,23 +177,29 @@ EXPORT_SYMBOL(skb_truesize_bug);
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
+	int memalloc = sk_memalloc_socks();
 
-	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
+	size = SKB_DATA_ALIGN(size);
+	cache = (flags & SKB_ALLOC_FCLONE)
+		? skbuff_fclone_cache : skbuff_head_cache;
+
+	if (memalloc && (flags & SKB_ALLOC_RX))
+		gfp_mask |= __GFP_MEMALLOC;
 
 	/* Get the HEAD */
 	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
 	if (!skb)
 		goto out;
 
-	size = SKB_DATA_ALIGN(size);
-	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
-			gfp_mask, node);
+	data = kmalloc_reserve(size + sizeof(struct skb_shared_info),
+			gfp_mask, node, &net_skb_reserve, &emergency);
 	if (!data)
 		goto nodata;
 
@@ -203,6 +209,9 @@ struct sk_buff *__alloc_skb(unsigned int
 	 * the tail pointer in struct sk_buff!
 	 */
 	memset(skb, 0, offsetof(struct sk_buff, tail));
+#ifdef CONFIG_NETVM
+	skb->emergency = emergency;
+#endif
 	skb->truesize = size + sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 	skb->head = data;
@@ -219,7 +228,7 @@ struct sk_buff *__alloc_skb(unsigned int
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
 
-	if (fclone) {
+	if (flags & SKB_ALLOC_FCLONE) {
 		struct sk_buff *child = skb + 1;
 		atomic_t *fclone_ref = (atomic_t *) (child + 1);
 
@@ -227,6 +236,9 @@ struct sk_buff *__alloc_skb(unsigned int
 		atomic_set(fclone_ref, 1);
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
+#ifdef CONFIG_NETVM
+		child->emergency = skb->emergency;
+#endif
 	}
 out:
 	return skb;
@@ -255,7 +267,7 @@ struct sk_buff *__netdev_alloc_skb(struc
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, SKB_ALLOC_RX, node);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
@@ -268,11 +280,19 @@ struct page *__netdev_alloc_page(struct 
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct page *page;
 
-	page = alloc_pages_node(node, gfp_mask, 0);
+	page = alloc_pages_reserve(node, gfp_mask | __GFP_MEMALLOC, 0,
+			&net_skb_reserve, NULL);
+
 	return page;
 }
 EXPORT_SYMBOL(__netdev_alloc_page);
 
+void __netdev_free_page(struct net_device *dev, struct page *page)
+{
+	free_pages_reserve(page, 0, &net_skb_reserve, page->reserve);
+}
+EXPORT_SYMBOL(__netdev_free_page);
+
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 		int size)
 {
@@ -280,6 +300,27 @@ void skb_add_rx_frag(struct sk_buff *skb
 	skb->len += size;
 	skb->data_len += size;
 	skb->truesize += size;
+
+#ifdef CONFIG_NETVM
+	/*
+	 * In the rare case that skb_emergency() != page->reserved we'll
+	 * skew the accounting slightly, but since its only a 'small' constant
+	 * shift its ok.
+	 */
+	if (skb_emergency(skb)) {
+		/*
+		 * We need to track fragment pages so that we properly
+		 * release their reserve in skb_put_page().
+		 */
+		atomic_set(&page->frag_count, 1);
+	} else if (unlikely(page->reserve)) {
+		/*
+		 * Release the reserve now, because normal skbs don't
+		 * do the emergency accounting.
+		 */
+		mem_reserve_pages_charge(&net_skb_reserve, -1);
+	}
+#endif
 }
 EXPORT_SYMBOL(skb_add_rx_frag);
 
@@ -331,21 +372,38 @@ static void skb_clone_fraglist(struct sk
 		skb_get(list);
 }
 
+static void skb_get_page(struct sk_buff *skb, struct page *page)
+{
+	get_page(page);
+	if (skb_emergency(skb))
+		atomic_inc(&page->frag_count);
+}
+
+static void skb_put_page(struct sk_buff *skb, struct page *page)
+{
+	if (skb_emergency(skb) && atomic_dec_and_test(&page->frag_count))
+		mem_reserve_pages_charge(&net_skb_reserve, -1);
+	put_page(page);
+}
+
 static void skb_release_data(struct sk_buff *skb)
 {
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
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
 
-		kfree(skb->head);
+		kfree_reserve(skb->head, &net_skb_reserve, skb_emergency(skb));
 	}
 }
 
@@ -466,6 +524,9 @@ static void __copy_skb_header(struct sk_
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	new->ipvs_property	= old->ipvs_property;
 #endif
+#ifdef CONFIG_NETVM
+	new->emergency		= old->emergency;
+#endif
 	new->protocol		= old->protocol;
 	new->mark		= old->mark;
 	__nf_copy(new, old);
@@ -559,6 +620,9 @@ struct sk_buff *skb_clone(struct sk_buff
 		n->fclone = SKB_FCLONE_CLONE;
 		atomic_inc(fclone_ref);
 	} else {
+		if (skb_emergency(skb))
+			gfp_mask |= __GFP_MEMALLOC;
+
 		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)
 			return NULL;
@@ -590,6 +654,14 @@ static void copy_skb_header(struct sk_bu
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
@@ -610,15 +682,17 @@ static void copy_skb_header(struct sk_bu
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
 
@@ -653,12 +727,14 @@ struct sk_buff *pskb_copy(struct sk_buff
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
 
@@ -677,8 +753,9 @@ struct sk_buff *pskb_copy(struct sk_buff
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
@@ -726,7 +803,11 @@ int pskb_expand_head(struct sk_buff *skb
 
 	size = SKB_DATA_ALIGN(size);
 
-	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	if (skb_emergency(skb))
+		gfp_mask |= __GFP_MEMALLOC;
+
+	data = kmalloc_reserve(size + sizeof(struct skb_shared_info),
+			gfp_mask, -1, &net_skb_reserve, NULL);
 	if (!data)
 		goto nodata;
 
@@ -741,7 +822,7 @@ int pskb_expand_head(struct sk_buff *skb
 	       sizeof(struct skb_shared_info));
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		get_page(skb_shinfo(skb)->frags[i].page);
+		skb_get_page(skb, skb_shinfo(skb)->frags[i].page);
 
 	if (skb_shinfo(skb)->frag_list)
 		skb_clone_fraglist(skb);
@@ -820,8 +901,8 @@ struct sk_buff *skb_copy_expand(const st
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
@@ -1010,7 +1091,7 @@ drop_pages:
 		skb_shinfo(skb)->nr_frags = i;
 
 		for (; i < nfrags; i++)
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_put_page(skb, skb_shinfo(skb)->frags[i].page);
 
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
@@ -1179,7 +1260,7 @@ pull_pages:
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		if (skb_shinfo(skb)->frags[i].size <= eat) {
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_put_page(skb, skb_shinfo(skb)->frags[i].page);
 			eat -= skb_shinfo(skb)->frags[i].size;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
@@ -1928,6 +2009,7 @@ static inline void skb_split_no_header(s
 			skb_shinfo(skb1)->frags[k] = skb_shinfo(skb)->frags[i];
 
 			if (pos < len) {
+				struct page *page = skb_shinfo(skb)->frags[i].page;
 				/* Split frag.
 				 * We have two variants in this case:
 				 * 1. Move all the frag to the second
@@ -1936,7 +2018,7 @@ static inline void skb_split_no_header(s
 				 *    where splitting is expensive.
 				 * 2. Split is accurately. We make this.
 				 */
-				get_page(skb_shinfo(skb)->frags[i].page);
+				skb_get_page(skb1, page);
 				skb_shinfo(skb1)->frags[0].page_offset += len - pos;
 				skb_shinfo(skb1)->frags[0].size -= len - pos;
 				skb_shinfo(skb)->frags[i].size	= len - pos;
@@ -2266,7 +2348,8 @@ struct sk_buff *skb_segment(struct sk_bu
 		if (hsize > len || !sg)
 			hsize = len;
 
-		nskb = alloc_skb(hsize + doffset + headroom, GFP_ATOMIC);
+		nskb = __alloc_skb(hsize + doffset + headroom, GFP_ATOMIC,
+				   skb_alloc_rx_flag(skb), -1);
 		if (unlikely(!nskb))
 			goto err;
 
@@ -2304,7 +2387,7 @@ struct sk_buff *skb_segment(struct sk_bu
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
@@ -75,6 +75,7 @@ struct page {
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
