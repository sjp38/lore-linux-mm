Date: Mon, 30 Oct 2006 15:15:09 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/3] node-aware netdev_alloc_skb
Message-ID: <20061030141509.GD7164@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch finnally switches netdev_alloc_skb to be node-locale.
It uses dev_to_node and kmalloc_node_track_caller from the previous two
patches.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h	2006-10-23 17:20:14.000000000 +0200
+++ linux-2.6/include/linux/skbuff.h	2006-10-30 13:23:38.000000000 +0100
@@ -331,17 +331,17 @@
 extern void kfree_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
-				   gfp_t priority, int fclone);
+				   gfp_t priority, int fclone, int node);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
-	return __alloc_skb(size, priority, 0);
+	return __alloc_skb(size, priority, 0, -1);
 }
 
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1);
+	return __alloc_skb(size, priority, 1, -1);
 }
 
 extern struct sk_buff *alloc_skb_from_cache(kmem_cache_t *cp,
Index: linux-2.6/net/core/skbuff.c
===================================================================
--- linux-2.6.orig/net/core/skbuff.c	2006-10-23 17:20:14.000000000 +0200
+++ linux-2.6/net/core/skbuff.c	2006-10-30 13:39:15.000000000 +0100
@@ -57,6 +57,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/topology.h>
 
 #include <net/protocol.h>
 #include <net/dst.h>
@@ -131,6 +132,7 @@
  *	@gfp_mask: allocation mask
  *	@fclone: allocate from fclone cache instead of head cache
  *		and allocate a cloned (child) skb
+ *	@node: numa node to allocate memory on
  *
  *	Allocate a new &sk_buff. The returned buffer has no headroom and a
  *	tail room of size bytes. The object has a reference count of one.
@@ -140,7 +142,7 @@
  *	%GFP_ATOMIC.
  */
 struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
-			    int fclone)
+			    int fclone, int node)
 {
 	kmem_cache_t *cache;
 	struct skb_shared_info *shinfo;
@@ -150,14 +152,14 @@
 	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
 
 	/* Get the HEAD */
-	skb = kmem_cache_alloc(cache, gfp_mask & ~__GFP_DMA);
+	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
 	if (!skb)
 		goto out;
 
 	/* Get the DATA. Size must match skb_add_mtu(). */
 	size = SKB_DATA_ALIGN(size);
-	data = kmalloc_track_caller(size + sizeof(struct skb_shared_info),
-			gfp_mask);
+	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
+			gfp_mask, node);
 	if (!data)
 		goto nodata;
 
@@ -266,9 +268,10 @@
 struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 		unsigned int length, gfp_t gfp_mask)
 {
+	int node = dev->class_dev.dev ? dev_to_node(dev->class_dev.dev) : -1;
 	struct sk_buff *skb;
 
-	skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
+ 	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
