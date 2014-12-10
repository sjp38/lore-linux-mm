Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 405F56B0072
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:16:21 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id f73so1293251yha.34
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:16:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i96si1486248yhq.53.2014.12.10.06.16.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Dec 2014 06:16:20 -0800 (PST)
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH 3/3] net: use qmempool in-front of sk_buff kmem_cache
Date: Wed, 10 Dec 2014 15:15:55 +0100
Message-ID: <20141210141547.31779.66932.stgit@dragon>
In-Reply-To: <20141210141332.31779.56391.stgit@dragon>
References: <20141210141332.31779.56391.stgit@dragon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: linux-api@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Alexander Duyck <alexander.duyck@gmail.com>, Alexei Starovoitov <ast@plumgrid.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Steven Rostedt <rostedt@goodmis.org>

This patch uses qmempool for faster than SLAB caching of SKBs.

Only use this caching in connection with napi_alloc_skb() which runs
in softirq context.  This softirq context provides the needed
protection for qmempool and the underlying alf_queue.

Current caching settings are max 32 elements per CPU, which is 8192
bytes given SKB is SLAB_HWCACHE_ALIGN'ed.  The shared queue max limit
is 1024 which corresponds to worst-case 263KB memory usage.  Systems
with a NR_CPUS <= 8 will get a smaller max shared queue.

Benchmarked on a E5-2695 12-cores (no-HT) with ixgbe.
Baseline is Alex'es napi_alloc_skb patchset.

Single flow/CPU, early drop in iptables RAW table (fast path compare):
 * baseline: 3,159,160 pps
 * qmempool: 3,282,508 pps
 - Diff to baseline: +123348 pps => -11.89 ns

IP-forward single flow/cpu (slower path compare):
 * baseline: 1,137,284 pps
 * qmempool: 1,191,856 pps
 - Diff to baseline: +54572 pps => -40.26 ns

Some of the improvements also come from qmempool_{alloc,free} have
smaller code size than kmem_cache_{alloc,free}, which helps reduce
instruction-cache misses.

Also did some scaling tests, to stress qmempool sharedq allocs (which
stress the alf_queue's concurrency).

IP-forward MULTI flow/cpu (12 CPUs E5-2695 no-HT, 12 HWQs):
 * baseline: 11,946,666 pps
 * qmempool: 11,988,042 pps
 - Diff to baseline: +41376 pps => -0.29 ns

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/linux/skbuff.h |    4 +++-
 net/core/dev.c         |    5 ++++-
 net/core/skbuff.c      |   43 ++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 45 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index af79302..8881215 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -152,6 +152,7 @@ struct scatterlist;
 struct pipe_inode_info;
 struct iov_iter;
 struct napi_struct;
+struct qmempool;
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 struct nf_conntrack {
@@ -557,8 +558,8 @@ struct sk_buff {
 				fclone:2,
 				peeked:1,
 				head_frag:1,
+				qmempool:1,
 				xmit_more:1;
-	/* one bit hole */
 	kmemcheck_bitfield_end(flags1);
 
 	/* fields enclosed in headers_start/headers_end are copied
@@ -755,6 +756,7 @@ void skb_tx_error(struct sk_buff *skb);
 void consume_skb(struct sk_buff *skb);
 void  __kfree_skb(struct sk_buff *skb);
 extern struct kmem_cache *skbuff_head_cache;
+extern struct qmempool *skbuff_head_pool;
 
 void kfree_skb_partial(struct sk_buff *skb, bool head_stolen);
 bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
diff --git a/net/core/dev.c b/net/core/dev.c
index 80f798d..0c95fbd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,6 +135,7 @@
 #include <linux/if_macvlan.h>
 #include <linux/errqueue.h>
 #include <linux/hrtimer.h>
+#include <linux/qmempool.h>
 
 #include "net-sysfs.h"
 
@@ -4125,7 +4126,9 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 
 	case GRO_MERGED_FREE:
 		if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD)
-			kmem_cache_free(skbuff_head_cache, skb);
+			(skb->qmempool) ?
+				qmempool_free(skbuff_head_pool, skb) :
+				kmem_cache_free(skbuff_head_cache, skb);
 		else
 			__kfree_skb(skb);
 		break;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ae13ef6..a96ce75 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -74,10 +74,24 @@
 #include <asm/uaccess.h>
 #include <trace/events/skb.h>
 #include <linux/highmem.h>
+#include <linux/qmempool.h>
+#include <linux/log2.h>
 
 struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
 
+/* Keep max 32 skbs per CPU = 8192 bytes per CPU (as skb is
+ * SLAB_HWCACHE_ALIGN).  Sharedq cache is limited to max 1024 elems
+ * which is max 262KB skb memory, on small systems it allocs 32*2
+ * elems * NR_CPUS.
+ */
+struct qmempool *skbuff_head_pool __read_mostly;
+#define QMEMPOOL_LOCALQ 32
+#define QMEMPOOL_SCALE  (QMEMPOOL_LOCALQ * 2)
+#define QMEMPOOL_SYSTEM_SIZE roundup_pow_of_two(NR_CPUS * QMEMPOOL_SCALE)
+#define QMEMPOOL_SHAREDQ min(1024UL, QMEMPOOL_SYSTEM_SIZE)
+#define QMEMPOOL_PREALLOC 0
+
 /**
  *	skb_panic - private function for out-of-line support
  *	@skb:	buffer
@@ -278,13 +292,14 @@ nodata:
 EXPORT_SYMBOL(__alloc_skb);
 
 /**
- * build_skb - build a network buffer
+ * __build_skb - build a network buffer
  * @data: data buffer provided by caller
  * @frag_size: size of fragment, or 0 if head was kmalloced
  *
  * Allocate a new &sk_buff. Caller provides space holding head and
  * skb_shared_info. @data must have been allocated by kmalloc() only if
  * @frag_size is 0, otherwise data should come from the page allocator.
+ * @flags: FIXME-DESCRIBE
  * The return is the new skb buffer.
  * On a failure the return is %NULL, and @data is not freed.
  * Notes :
@@ -295,13 +310,16 @@ EXPORT_SYMBOL(__alloc_skb);
  *  before giving packet to stack.
  *  RX rings only contains data buffers, not full skbs.
  */
-struct sk_buff *build_skb(void *data, unsigned int frag_size)
+static struct sk_buff *__build_skb(void *data, unsigned int frag_size,
+				   int flags)
 {
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	unsigned int size = frag_size ? : ksize(data);
 
-	skb = kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
+	skb = (flags & SKB_ALLOC_NAPI) ?
+		qmempool_alloc_softirq(skbuff_head_pool, GFP_ATOMIC) :
+		kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
 	if (!skb)
 		return NULL;
 
@@ -310,6 +328,7 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize = SKB_TRUESIZE(size);
 	skb->head_frag = frag_size != 0;
+	skb->qmempool = !!(flags & SKB_ALLOC_NAPI);
 	atomic_set(&skb->users, 1);
 	skb->head = data;
 	skb->data = data;
@@ -326,6 +345,11 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 
 	return skb;
 }
+
+struct sk_buff *build_skb(void *data, unsigned int frag_size)
+{
+	return __build_skb(data, frag_size, 0);
+}
 EXPORT_SYMBOL(build_skb);
 
 struct netdev_alloc_cache {
@@ -477,7 +501,7 @@ static struct sk_buff *__alloc_rx_skb(unsigned int length, gfp_t gfp_mask,
 			__netdev_alloc_frag(fragsz, gfp_mask);
 
 		if (likely(data)) {
-			skb = build_skb(data, fragsz);
+			skb = __build_skb(data, fragsz, flags);
 			if (unlikely(!skb))
 				put_page(virt_to_head_page(data));
 		}
@@ -637,7 +661,9 @@ static void kfree_skbmem(struct sk_buff *skb)
 
 	switch (skb->fclone) {
 	case SKB_FCLONE_UNAVAILABLE:
-		kmem_cache_free(skbuff_head_cache, skb);
+		(skb->qmempool) ?
+			qmempool_free(skbuff_head_pool, skb) :
+			kmem_cache_free(skbuff_head_cache, skb);
 		return;
 
 	case SKB_FCLONE_ORIG:
@@ -862,6 +888,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	C(end);
 	C(head);
 	C(head_frag);
+	C(qmempool);
 	C(data);
 	C(truesize);
 	atomic_set(&n->users, 1);
@@ -3370,6 +3397,12 @@ void __init skb_init(void)
 						0,
 						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						NULL);
+	/* connect qmempools to slabs */
+	skbuff_head_pool = qmempool_create(QMEMPOOL_LOCALQ,
+					   QMEMPOOL_SHAREDQ,
+					   QMEMPOOL_PREALLOC,
+					   skbuff_head_cache, GFP_ATOMIC);
+	BUG_ON(skbuff_head_pool == NULL);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
