Message-Id: <20070221144842.691706000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Date: Wed, 21 Feb 2007 15:43:16 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 12/29] net: remove alloc_skb_from_cache
Content-Disposition: inline; filename=net-skbuff-cleanup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Lets get rid of the unused alloc_skb_from_cache() thing.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/skbuff.h |    3 --
 net/core/dev.c         |    1 
 net/core/skbuff.c      |   71 ++++++-------------------------------------------
 3 files changed, 11 insertions(+), 64 deletions(-)

Index: linux-2.6-git/include/linux/skbuff.h
===================================================================
--- linux-2.6-git.orig/include/linux/skbuff.h	2007-02-14 08:31:13.000000000 +0100
+++ linux-2.6-git/include/linux/skbuff.h	2007-02-14 10:11:36.000000000 +0100
@@ -345,9 +345,6 @@ static inline struct sk_buff *alloc_skb_
 	return __alloc_skb(size, priority, 1, -1);
 }
 
-extern struct sk_buff *alloc_skb_from_cache(struct kmem_cache *cp,
-					    unsigned int size,
-					    gfp_t priority);
 extern void	       kfree_skbmem(struct sk_buff *skb);
 extern struct sk_buff *skb_clone(struct sk_buff *skb,
 				 gfp_t priority);
Index: linux-2.6-git/net/core/skbuff.c
===================================================================
--- linux-2.6-git.orig/net/core/skbuff.c	2007-02-14 08:31:12.000000000 +0100
+++ linux-2.6-git/net/core/skbuff.c	2007-02-14 10:11:16.000000000 +0100
@@ -198,61 +198,6 @@ nodata:
 }
 
 /**
- *	alloc_skb_from_cache	-	allocate a network buffer
- *	@cp: kmem_cache from which to allocate the data area
- *           (object size must be big enough for @size bytes + skb overheads)
- *	@size: size to allocate
- *	@gfp_mask: allocation mask
- *
- *	Allocate a new &sk_buff. The returned buffer has no headroom and
- *	tail room of size bytes. The object has a reference count of one.
- *	The return is the buffer. On a failure the return is %NULL.
- *
- *	Buffers may only be allocated from interrupts using a @gfp_mask of
- *	%GFP_ATOMIC.
- */
-struct sk_buff *alloc_skb_from_cache(struct kmem_cache *cp,
-				     unsigned int size,
-				     gfp_t gfp_mask)
-{
-	struct sk_buff *skb;
-	u8 *data;
-
-	/* Get the HEAD */
-	skb = kmem_cache_alloc(skbuff_head_cache,
-			       gfp_mask & ~__GFP_DMA);
-	if (!skb)
-		goto out;
-
-	/* Get the DATA. */
-	size = SKB_DATA_ALIGN(size);
-	data = kmem_cache_alloc(cp, gfp_mask);
-	if (!data)
-		goto nodata;
-
-	memset(skb, 0, offsetof(struct sk_buff, truesize));
-	skb->truesize = size + sizeof(struct sk_buff);
-	atomic_set(&skb->users, 1);
-	skb->head = data;
-	skb->data = data;
-	skb->tail = data;
-	skb->end  = data + size;
-
-	atomic_set(&(skb_shinfo(skb)->dataref), 1);
-	skb_shinfo(skb)->nr_frags  = 0;
-	skb_shinfo(skb)->gso_size = 0;
-	skb_shinfo(skb)->gso_segs = 0;
-	skb_shinfo(skb)->gso_type = 0;
-	skb_shinfo(skb)->frag_list = NULL;
-out:
-	return skb;
-nodata:
-	kmem_cache_free(skbuff_head_cache, skb);
-	skb = NULL;
-	goto out;
-}
-
-/**
  *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
  *	@dev: network device to receive on
  *	@length: length to allocate

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
