Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 56A2D6B007D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 05:35:33 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/17] netvm: Allow skb allocation to use PFMEMALLOC reserves
Date: Wed, 20 Jun 2012 10:35:12 +0100
Message-Id: <1340184920-22288-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1340184920-22288-1-git-send-email-mgorman@suse.de>
References: <1340184920-22288-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Mel Gorman <mgorman@suse.de>

Change the skb allocation API to indicate RX usage and use this to fall
back to the PFMEMALLOC reserve when needed. SKBs allocated from the
reserve are tagged in skb->pfmemalloc. If an SKB is allocated from
the reserve and the socket is later found to be unrelated to page
reclaim, the packet is dropped so that the memory remains available
for page reclaim. Network protocols are expected to recover from this
packet loss.

[davem@davemloft.net: Use static branches, coding style corrections]
[a.p.zijlstra@chello.nl: Ideas taken from various patches]
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: David S. Miller <davem@davemloft.net>
---
 include/linux/gfp.h    |    3 ++
 include/linux/skbuff.h |   14 +++++-
 include/net/sock.h     |    6 +++
 mm/internal.h          |    3 --
 net/core/filter.c      |    8 ++++
 net/core/skbuff.c      |  119 ++++++++++++++++++++++++++++++++++++++----------
 net/core/sock.c        |    4 ++
 7 files changed, 127 insertions(+), 30 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index cbd7400..4883f39 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -385,6 +385,9 @@ void drain_local_pages(void *dummy);
  */
 extern gfp_t gfp_allowed_mask;
 
+/* Returns true if the gfp_mask allows use of ALLOC_NO_WATERMARK */
+bool gfp_pfmemalloc_allowed(gfp_t gfp_mask);
+
 extern void pm_restrict_gfp_mask(void);
 extern void pm_restore_gfp_mask(void);
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b534a1b..61c951f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -465,6 +465,7 @@ struct sk_buff {
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	__u8			ndisc_nodetype:2;
 #endif
+	__u8			pfmemalloc:1;
 	__u8			ooo_okay:1;
 	__u8			l4_rxhash:1;
 	__u8			wifi_acked_valid:1;
@@ -505,6 +506,15 @@ struct sk_buff {
 #include <linux/slab.h>
 
 
+#define SKB_ALLOC_FCLONE	0x01
+#define SKB_ALLOC_RX		0x02
+
+/* Returns true if the skb was allocated from PFMEMALLOC reserves */
+static inline bool skb_pfmemalloc(struct sk_buff *skb)
+{
+	return unlikely(skb->pfmemalloc);
+}
+
 /*
  * skb might have a dst pointer attached, refcounted or not.
  * _skb_refdst low order bit is set if refcount was _not_ taken
@@ -568,7 +578,7 @@ extern bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 			     bool *fragstolen, int *delta_truesize);
 
 extern struct sk_buff *__alloc_skb(unsigned int size,
-				   gfp_t priority, int fclone, int node);
+				   gfp_t priority, int flags, int node);
 extern struct sk_buff *build_skb(void *data, unsigned int frag_size);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
@@ -579,7 +589,7 @@ static inline struct sk_buff *alloc_skb(unsigned int size,
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, NUMA_NO_NODE);
+	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, NUMA_NO_NODE);
 }
 
 extern void skb_recycle(struct sk_buff *skb);
diff --git a/include/net/sock.h b/include/net/sock.h
index 9f38b7d..e3fe462 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -657,6 +657,12 @@ static inline bool sock_flag(const struct sock *sk, enum sock_flags flag)
 	return test_bit(flag, &sk->sk_flags);
 }
 
+extern struct static_key memalloc_socks;
+static inline int sk_memalloc_socks(void)
+{
+	return static_key_false(&memalloc_socks);
+}
+
 static inline gfp_t sk_gfp_atomic(struct sock *sk, gfp_t gfp_mask)
 {
 	return GFP_ATOMIC | (sk->sk_allocation & __GFP_MEMALLOC);
diff --git a/mm/internal.h b/mm/internal.h
index 2d0dd52..2ba87fb 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -273,9 +273,6 @@ static inline struct page *mem_map_next(struct page *iter,
 #define __paginginit __init
 #endif
 
-/* Returns true if the gfp_mask allows use of ALLOC_NO_WATERMARK */
-bool gfp_pfmemalloc_allowed(gfp_t gfp_mask);
-
 /* Memory initialisation debug and verification */
 enum mminit_level {
 	MMINIT_WARNING,
diff --git a/net/core/filter.c b/net/core/filter.c
index a3eddb5..b690932 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -83,6 +83,14 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
 	int err;
 	struct sk_filter *filter;
 
+	/*
+	 * If the skb was allocated from pfmemalloc reserves, only
+	 * allow SOCK_MEMALLOC sockets to use it as this socket is
+	 * helping free memory
+	 */
+	if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
+		return -ENOMEM;
+
 	err = security_sock_rcv_skb(sk, skb);
 	if (err)
 		return err;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 016694d..d0d4100 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -145,6 +145,43 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
 	BUG();
 }
 
+
+/*
+ * kmalloc_reserve is a wrapper around kmalloc_node_track_caller that tells
+ * the caller if emergency pfmemalloc reserves are being used. If it is and
+ * the socket is later found to be SOCK_MEMALLOC then PFMEMALLOC reserves
+ * may be used. Otherwise, the packet data may be discarded until enough
+ * memory is free
+ */
+#define kmalloc_reserve(size, gfp, node, pfmemalloc) \
+	 __kmalloc_reserve(size, gfp, node, _RET_IP_, pfmemalloc)
+void *__kmalloc_reserve(size_t size, gfp_t flags, int node, unsigned long ip,
+			 bool *pfmemalloc)
+{
+	void *obj;
+	bool ret_pfmemalloc = false;
+
+	/*
+	 * Try a regular allocation, when that fails and we're not entitled
+	 * to the reserves, fail.
+	 */
+	obj = kmalloc_node_track_caller(size,
+					flags | __GFP_NOMEMALLOC | __GFP_NOWARN,
+					node);
+	if (obj || !(gfp_pfmemalloc_allowed(flags)))
+		goto out;
+
+	/* Try again but now we are using pfmemalloc reserves */
+	ret_pfmemalloc = true;
+	obj = kmalloc_node_track_caller(size, flags, node);
+
+out:
+	if (pfmemalloc)
+		*pfmemalloc = ret_pfmemalloc;
+
+	return obj;
+}
+
 /* 	Allocate a new skbuff. We do this ourselves so we can fill in a few
  *	'private' fields and also do memory statistics to find all the
  *	[BEEP] leaks.
@@ -155,8 +192,10 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
  *	__alloc_skb	-	allocate a network buffer
  *	@size: size to allocate
  *	@gfp_mask: allocation mask
- *	@fclone: allocate from fclone cache instead of head cache
- *		and allocate a cloned (child) skb
+ *	@flags: If SKB_ALLOC_FCLONE is set, allocate from fclone cache
+ *		instead of head cache and allocate a cloned (child) skb.
+ *		If SKB_ALLOC_RX is set, __GFP_MEMALLOC will be used for
+ *		allocations in case the data is required for writeback
  *	@node: numa node to allocate memory on
  *
  *	Allocate a new &sk_buff. The returned buffer has no headroom and a
@@ -167,14 +206,19 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
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
+	bool pfmemalloc;
+
+	cache = (flags & SKB_ALLOC_FCLONE)
+		? skbuff_fclone_cache : skbuff_head_cache;
 
-	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
+	if (sk_memalloc_socks() && (flags & SKB_ALLOC_RX))
+		gfp_mask |= __GFP_MEMALLOC;
 
 	/* Get the HEAD */
 	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
@@ -189,7 +233,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	 */
 	size = SKB_DATA_ALIGN(size);
 	size += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-	data = kmalloc_node_track_caller(size, gfp_mask, node);
+	data = kmalloc_reserve(size, gfp_mask, node, &pfmemalloc);
 	if (!data)
 		goto nodata;
 	/* kmalloc(size) might give us more room than requested.
@@ -207,6 +251,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	/* Account for allocated memory : skb + skb->head */
 	skb->truesize = SKB_TRUESIZE(size);
+	skb->pfmemalloc = pfmemalloc;
 	atomic_set(&skb->users, 1);
 	skb->head = data;
 	skb->data = data;
@@ -222,7 +267,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	atomic_set(&shinfo->dataref, 1);
 	kmemcheck_annotate_variable(shinfo->destructor_arg);
 
-	if (fclone) {
+	if (flags & SKB_ALLOC_FCLONE) {
 		struct sk_buff *child = skb + 1;
 		atomic_t *fclone_ref = (atomic_t *) (child + 1);
 
@@ -232,6 +277,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		atomic_set(fclone_ref, 1);
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
+		child->pfmemalloc = pfmemalloc;
 	}
 out:
 	return skb;
@@ -299,14 +345,7 @@ struct netdev_alloc_cache {
 };
 static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
 
-/**
- * netdev_alloc_frag - allocate a page fragment
- * @fragsz: fragment size
- *
- * Allocates a frag from a page for receive buffer.
- * Uses GFP_ATOMIC allocations.
- */
-void *netdev_alloc_frag(unsigned int fragsz)
+static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
 	struct netdev_alloc_cache *nc;
 	void *data = NULL;
@@ -316,7 +355,7 @@ void *netdev_alloc_frag(unsigned int fragsz)
 	nc = &__get_cpu_var(netdev_alloc_cache);
 	if (unlikely(!nc->page)) {
 refill:
-		nc->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+		nc->page = alloc_page(gfp_mask);
 		nc->offset = 0;
 	}
 	if (likely(nc->page)) {
@@ -331,6 +370,18 @@ refill:
 	local_irq_restore(flags);
 	return data;
 }
+
+/**
+ * netdev_alloc_frag - allocate a page fragment
+ * @fragsz: fragment size
+ *
+ * Allocates a frag from a page for receive buffer.
+ * Uses GFP_ATOMIC allocations.
+ */
+void *netdev_alloc_frag(unsigned int fragsz)
+{
+	return __netdev_alloc_frag(fragsz, GFP_ATOMIC | __GFP_COLD);
+}
 EXPORT_SYMBOL(netdev_alloc_frag);
 
 /**
@@ -354,7 +405,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 	if (fragsz <= PAGE_SIZE && !(gfp_mask & __GFP_WAIT)) {
-		void *data = netdev_alloc_frag(fragsz);
+		void *data = __netdev_alloc_frag(fragsz, gfp_mask);
 
 		if (likely(data)) {
 			skb = build_skb(data, fragsz);
@@ -362,7 +413,8 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 				put_page(virt_to_head_page(data));
 		}
 	} else {
-		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, NUMA_NO_NODE);
+		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
+				  SKB_ALLOC_RX, NUMA_NO_NODE);
 	}
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
@@ -644,6 +696,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #if IS_ENABLED(CONFIG_IP_VS)
 	new->ipvs_property	= old->ipvs_property;
 #endif
+	new->pfmemalloc		= old->pfmemalloc;
 	new->protocol		= old->protocol;
 	new->mark		= old->mark;
 	new->skb_iif		= old->skb_iif;
@@ -803,6 +856,9 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 		n->fclone = SKB_FCLONE_CLONE;
 		atomic_inc(fclone_ref);
 	} else {
+		if (skb_pfmemalloc(skb))
+			gfp_mask |= __GFP_MEMALLOC;
+
 		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)
 			return NULL;
@@ -839,6 +895,13 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
 }
 
+static inline int skb_alloc_rx_flag(const struct sk_buff *skb)
+{
+	if (skb_pfmemalloc((struct sk_buff *)skb))
+		return SKB_ALLOC_RX;
+	return 0;
+}
+
 /**
  *	skb_copy	-	create private copy of an sk_buff
  *	@skb: buffer to copy
@@ -860,7 +923,8 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 {
 	int headerlen = skb_headroom(skb);
 	unsigned int size = skb_end_offset(skb) + skb->data_len;
-	struct sk_buff *n = alloc_skb(size, gfp_mask);
+	struct sk_buff *n = __alloc_skb(size, gfp_mask,
+					skb_alloc_rx_flag(skb), NUMA_NO_NODE);
 
 	if (!n)
 		return NULL;
@@ -895,7 +959,8 @@ EXPORT_SYMBOL(skb_copy);
 struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask)
 {
 	unsigned int size = skb_headlen(skb) + headroom;
-	struct sk_buff *n = alloc_skb(size, gfp_mask);
+	struct sk_buff *n = __alloc_skb(size, gfp_mask,
+					skb_alloc_rx_flag(skb), NUMA_NO_NODE);
 
 	if (!n)
 		goto out;
@@ -970,8 +1035,10 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 
 	size = SKB_DATA_ALIGN(size);
 
-	data = kmalloc(size + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
-		       gfp_mask);
+	if (skb_pfmemalloc(skb))
+		gfp_mask |= __GFP_MEMALLOC;
+	data = kmalloc_reserve(size + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
+			       gfp_mask, NUMA_NO_NODE, NULL);
 	if (!data)
 		goto nodata;
 	size = SKB_WITH_OVERHEAD(ksize(data));
@@ -1085,8 +1152,9 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 	/*
 	 *	Allocate the copy buffer
 	 */
-	struct sk_buff *n = alloc_skb(newheadroom + skb->len + newtailroom,
-				      gfp_mask);
+	struct sk_buff *n = __alloc_skb(newheadroom + skb->len + newtailroom,
+					gfp_mask, skb_alloc_rx_flag(skb),
+					NUMA_NO_NODE);
 	int oldheadroom = skb_headroom(skb);
 	int head_copy_len, head_copy_off;
 	int off;
@@ -2767,8 +2835,9 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			skb_release_head_state(nskb);
 			__skb_push(nskb, doffset);
 		} else {
-			nskb = alloc_skb(hsize + doffset + headroom,
-					 GFP_ATOMIC);
+			nskb = __alloc_skb(hsize + doffset + headroom,
+					   GFP_ATOMIC, skb_alloc_rx_flag(skb),
+					   NUMA_NO_NODE);
 
 			if (unlikely(!nskb))
 				goto err;
diff --git a/net/core/sock.c b/net/core/sock.c
index d45d6fd..439804a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -271,6 +271,8 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
 
+struct static_key memalloc_socks = STATIC_KEY_INIT_FALSE;
+
 /**
  * sk_set_memalloc - sets %SOCK_MEMALLOC
  * @sk: socket to set it on
@@ -283,6 +285,7 @@ void sk_set_memalloc(struct sock *sk)
 {
 	sock_set_flag(sk, SOCK_MEMALLOC);
 	sk->sk_allocation |= __GFP_MEMALLOC;
+	static_key_slow_inc(&memalloc_socks);
 }
 EXPORT_SYMBOL_GPL(sk_set_memalloc);
 
@@ -290,6 +293,7 @@ void sk_clear_memalloc(struct sock *sk)
 {
 	sock_reset_flag(sk, SOCK_MEMALLOC);
 	sk->sk_allocation &= ~__GFP_MEMALLOC;
+	static_key_slow_dec(&memalloc_socks);
 }
 EXPORT_SYMBOL_GPL(sk_clear_memalloc);
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
