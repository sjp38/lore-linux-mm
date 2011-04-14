Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 28E4A90008E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 06:41:48 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/12] netvm: Allow skb allocation to use PFMEMALLOC reserves
Date: Thu, 14 Apr 2011 11:41:34 +0100
Message-Id: <1302777698-28237-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1302777698-28237-1-git-send-email-mgorman@suse.de>
References: <1302777698-28237-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Change the skb allocation API to indicate RX usage and use this to fall back
to the PFMEMALLOC reserve when needed. SKBs allocated from the reserve are
tagged in skb->pfmemalloc. If an SKB is allocated from the reserve and
the socket is later found to be unrelated to page reclaim, the packet is
dropped so that the memory remains available for page reclaim. Network
protocols are expected to recover from this packet loss.

[a.p.zijlstra@chello.nl: Ideas taken from various patches]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/gfp.h    |    3 ++
 include/linux/skbuff.h |   19 ++++++++--
 include/net/sock.h     |    6 +++
 mm/internal.h          |    3 --
 net/core/filter.c      |    8 ++++
 net/core/skbuff.c      |   95 ++++++++++++++++++++++++++++++++++++++++--------
 net/core/sock.c        |    9 +++++
 7 files changed, 121 insertions(+), 22 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index d54eb02..ebf4d4f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -374,6 +374,9 @@ void drain_local_pages(void *dummy);
 
 extern gfp_t gfp_allowed_mask;
 
+/* Returns true if the gfp_mask allows use of ALLOC_NO_WATERMARK */
+bool gfp_pfmemalloc_allowed(gfp_t gfp_mask);
+
 extern void pm_restrict_gfp_mask(void);
 extern void pm_restore_gfp_mask(void);
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bf221d6..5cd4d23 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -393,6 +393,7 @@ struct sk_buff {
 #else
 	__u8			deliver_no_wcard:1;
 #endif
+	__u8			pfmemalloc:1;
 	__u8			ooo_okay:1;
 	kmemcheck_bitfield_end(flags2);
 
@@ -431,6 +432,15 @@ struct sk_buff {
 
 #include <asm/system.h>
 
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
@@ -488,7 +498,7 @@ extern void kfree_skb(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
-				   gfp_t priority, int fclone, int node);
+				   gfp_t priority, int flags, int node);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
@@ -498,7 +508,7 @@ static inline struct sk_buff *alloc_skb(unsigned int size,
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, NUMA_NO_NODE);
+	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, NUMA_NO_NODE);
 }
 
 extern bool skb_recycle_check(struct sk_buff *skb, int skb_size);
@@ -1524,7 +1534,8 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
 					      gfp_t gfp_mask)
 {
-	struct sk_buff *skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
+	struct sk_buff *skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
+						SKB_ALLOC_RX, NUMA_NO_NODE);
 	if (likely(skb))
 		skb_reserve(skb, NET_SKB_PAD);
 	return skb;
@@ -1575,7 +1586,7 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
  */
 static inline struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
 {
-	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, 0);
+	return alloc_pages_node(NUMA_NO_NODE, gfp_mask | __GFP_MEMALLOC, 0);
 }
 
 /**
diff --git a/include/net/sock.h b/include/net/sock.h
index e6ead99..1d8a26b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -585,6 +585,12 @@ static inline int sock_flag(struct sock *sk, enum sock_flags flag)
 	return test_bit(flag, &sk->sk_flags);
 }
 
+extern int memalloc_socks;
+static inline int sk_memalloc_socks(void)
+{
+	return memalloc_socks;
+}
+
 static inline gfp_t sk_allocation(struct sock *sk, gfp_t gfp_mask)
 {
 	return gfp_mask | (sk->sk_allocation & __GFP_MEMALLOC);
diff --git a/mm/internal.h b/mm/internal.h
index 110c9a2..6948820 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -189,9 +189,6 @@ static inline struct page *mem_map_next(struct page *iter,
 #define __paginginit __init
 #endif
 
-/* Returns true if the gfp_mask allows use of ALLOC_NO_WATERMARK */
-bool gfp_pfmemalloc_allowed(gfp_t gfp_mask);
-
 /* Memory initialisation debug and verification */
 enum mminit_level {
 	MMINIT_WARNING,
diff --git a/net/core/filter.c b/net/core/filter.c
index afc5837..5223b48 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -138,6 +138,14 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
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
index d883dcc..f3702ae 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -146,6 +146,43 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
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
+				flags | __GFP_NOMEMALLOC | __GFP_NOWARN,
+				node);
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
@@ -156,8 +193,10 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
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
@@ -168,14 +207,19 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
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
@@ -184,8 +228,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	prefetchw(skb);
 
 	size = SKB_DATA_ALIGN(size);
-	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
-			gfp_mask, node);
+	data = kmalloc_reserve(size + sizeof(struct skb_shared_info),
+			gfp_mask, node, &pfmemalloc);
 	if (!data)
 		goto nodata;
 	prefetchw(data + size);
@@ -196,6 +240,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	 * the tail pointer in struct sk_buff!
 	 */
 	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb->pfmemalloc = pfmemalloc;
 	skb->truesize = size + sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 	skb->head = data;
@@ -212,7 +257,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	atomic_set(&shinfo->dataref, 1);
 	kmemcheck_annotate_variable(shinfo->destructor_arg);
 
-	if (fclone) {
+	if (flags & SKB_ALLOC_FCLONE) {
 		struct sk_buff *child = skb + 1;
 		atomic_t *fclone_ref = (atomic_t *) (child + 1);
 
@@ -222,6 +267,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		atomic_set(fclone_ref, 1);
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
+		child->pfmemalloc = pfmemalloc;
 	}
 out:
 	return skb;
@@ -250,7 +296,8 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 {
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, NUMA_NO_NODE);
+	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
+						SKB_ALLOC_RX, NUMA_NO_NODE);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
@@ -527,6 +574,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	new->ipvs_property	= old->ipvs_property;
 #endif
+	new->pfmemalloc		= old->pfmemalloc;
 	new->protocol		= old->protocol;
 	new->mark		= old->mark;
 	new->skb_iif		= old->skb_iif;
@@ -621,6 +669,9 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 		n->fclone = SKB_FCLONE_CLONE;
 		atomic_inc(fclone_ref);
 	} else {
+		if (skb_pfmemalloc(skb))
+			gfp_mask |= __GFP_MEMALLOC;
+
 		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)
 			return NULL;
@@ -657,6 +708,13 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
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
@@ -678,7 +736,8 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 {
 	int headerlen = skb_headroom(skb);
 	unsigned int size = (skb_end_pointer(skb) - skb->head) + skb->data_len;
-	struct sk_buff *n = alloc_skb(size, gfp_mask);
+	struct sk_buff *n = __alloc_skb(size, gfp_mask,
+					skb_alloc_rx_flag(skb), NUMA_NO_NODE);
 
 	if (!n)
 		return NULL;
@@ -712,7 +771,8 @@ EXPORT_SYMBOL(skb_copy);
 struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 {
 	unsigned int size = skb_end_pointer(skb) - skb->head;
-	struct sk_buff *n = alloc_skb(size, gfp_mask);
+	struct sk_buff *n = __alloc_skb(size, gfp_mask,
+					skb_alloc_rx_flag(skb), NUMA_NO_NODE);
 
 	if (!n)
 		goto out;
@@ -803,7 +863,10 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		goto adjust_others;
 	}
 
-	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	if (skb_pfmemalloc(skb))
+		gfp_mask |= __GFP_MEMALLOC;
+	data = kmalloc_reserve(size + sizeof(struct skb_shared_info), gfp_mask,
+			NUMA_NO_NODE, NULL);
 	if (!data)
 		goto nodata;
 
@@ -904,8 +967,9 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 	/*
 	 *	Allocate the copy buffer
 	 */
-	struct sk_buff *n = alloc_skb(newheadroom + skb->len + newtailroom,
-				      gfp_mask);
+	struct sk_buff *n = __alloc_skb(newheadroom + skb->len + newtailroom,
+				      gfp_mask, skb_alloc_rx_flag(skb),
+				      NUMA_NO_NODE);
 	int oldheadroom = skb_headroom(skb);
 	int head_copy_len, head_copy_off;
 	int off;
@@ -2555,8 +2619,9 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 			skb_release_head_state(nskb);
 			__skb_push(nskb, doffset);
 		} else {
-			nskb = alloc_skb(hsize + doffset + headroom,
-					 GFP_ATOMIC);
+			nskb = __alloc_skb(hsize + doffset + headroom,
+					 GFP_ATOMIC, skb_alloc_rx_flag(skb),
+					 NUMA_NO_NODE);
 
 			if (unlikely(!nskb))
 				goto err;
diff --git a/net/core/sock.c b/net/core/sock.c
index 1deb48b..7aac82b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -219,6 +219,9 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
 
+static DEFINE_MUTEX(memalloc_socks_lock);
+int memalloc_socks __read_mostly;
+
 /**
  * sk_set_memalloc - sets %SOCK_MEMALLOC
  * @sk: socket to set it on
@@ -231,6 +234,9 @@ void sk_set_memalloc(struct sock *sk)
 {
 	sock_set_flag(sk, SOCK_MEMALLOC);
 	sk->sk_allocation |= __GFP_MEMALLOC;
+	mutex_lock(&memalloc_socks_lock);
+	memalloc_socks++;
+	mutex_unlock(&memalloc_socks_lock);
 }
 EXPORT_SYMBOL_GPL(sk_set_memalloc);
 
@@ -238,6 +244,9 @@ void sk_clear_memalloc(struct sock *sk)
 {
 	sock_reset_flag(sk, SOCK_MEMALLOC);
 	sk->sk_allocation &= ~__GFP_MEMALLOC;
+	mutex_lock(&memalloc_socks_lock);
+	memalloc_socks--;
+	mutex_unlock(&memalloc_socks_lock);
 }
 EXPORT_SYMBOL_GPL(sk_clear_memalloc);
 
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
