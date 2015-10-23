Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id C9E3A6B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 08:46:09 -0400 (EDT)
Received: by iow1 with SMTP id 1so122633109iow.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:46:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h10si3141125igt.85.2015.10.23.05.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 05:46:09 -0700 (PDT)
Subject: [PATCH 1/4] net: bulk free infrastructure for NAPI context,
 use napi_consume_skb
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 23 Oct 2015 14:46:06 +0200
Message-ID: <20151023124606.17364.77473.stgit@firesoul>
In-Reply-To: <20151023124451.17364.14594.stgit@firesoul>
References: <20151023124451.17364.14594.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

Discovered that network stack were hitting the kmem_cache/SLUB
slowpath when freeing SKBs.  Doing bulk free with kmem_cache_free_bulk
can speedup this slowpath.

NAPI context is a bit special, lets take advantage of that for bulk
free'ing SKBs.

In NAPI context we are running in softirq, which gives us certain
protection.  A softirq can run on several CPUs at once.  BUT the
important part is a softirq will never preempt another softirq running
on the same CPU.  This gives us the opportunity to access per-cpu
variables in softirq context.

Extend napi_alloc_cache (before only contained page_frag_cache) to be
a struct with a small array based stack for holding SKBs.  Introduce a
SKB defer and flush API for accessing this.

Introduce napi_consume_skb() as replacement for e.g. dev_consume_skb_any()
when running in NAPI context.  A small trick to handle/detect if we
are called from netpoll is to see if budget is 0.  In that case, we
need to invoke dev_consume_skb_irq().

Joint work with Alexander Duyck.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/skbuff.h |    3 ++
 net/core/dev.c         |    1 +
 net/core/skbuff.c      |   83 +++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 81 insertions(+), 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4398411236f1..a3dec82e0e2c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2308,6 +2308,9 @@ static inline struct sk_buff *napi_alloc_skb(struct napi_struct *napi,
 {
 	return __napi_alloc_skb(napi, length, GFP_ATOMIC);
 }
+void napi_consume_skb(struct sk_buff *skb, int budget);
+
+void __kfree_skb_flush(void);
 
 /**
  * __dev_alloc_pages - allocate page for network Rx
diff --git a/net/core/dev.c b/net/core/dev.c
index 1225b4be8ed6..204059f67154 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4841,6 +4841,7 @@ static void net_rx_action(struct softirq_action *h)
 		}
 	}
 
+	__kfree_skb_flush();
 	local_irq_disable();
 
 	list_splice_tail_init(&sd->poll_list, &list);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fab4599ba8b2..2682ac46d640 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -347,8 +347,16 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 }
 EXPORT_SYMBOL(build_skb);
 
+#define NAPI_SKB_CACHE_SIZE	64
+
+struct napi_alloc_cache {
+	struct page_frag_cache page;
+	size_t skb_count;
+	void *skb_cache[NAPI_SKB_CACHE_SIZE];
+};
+
 static DEFINE_PER_CPU(struct page_frag_cache, netdev_alloc_cache);
-static DEFINE_PER_CPU(struct page_frag_cache, napi_alloc_cache);
+static DEFINE_PER_CPU(struct napi_alloc_cache, napi_alloc_cache);
 
 static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
@@ -378,9 +386,9 @@ EXPORT_SYMBOL(netdev_alloc_frag);
 
 static void *__napi_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
-	struct page_frag_cache *nc = this_cpu_ptr(&napi_alloc_cache);
+	struct napi_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
 
-	return __alloc_page_frag(nc, fragsz, gfp_mask);
+	return __alloc_page_frag(&nc->page, fragsz, gfp_mask);
 }
 
 void *napi_alloc_frag(unsigned int fragsz)
@@ -474,7 +482,7 @@ EXPORT_SYMBOL(__netdev_alloc_skb);
 struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 				 gfp_t gfp_mask)
 {
-	struct page_frag_cache *nc = this_cpu_ptr(&napi_alloc_cache);
+	struct napi_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
 	struct sk_buff *skb;
 	void *data;
 
@@ -494,7 +502,7 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 	if (sk_memalloc_socks())
 		gfp_mask |= __GFP_MEMALLOC;
 
-	data = __alloc_page_frag(nc, len, gfp_mask);
+	data = __alloc_page_frag(&nc->page, len, gfp_mask);
 	if (unlikely(!data))
 		return NULL;
 
@@ -505,7 +513,7 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 	}
 
 	/* use OR instead of assignment to avoid clearing of bits in mask */
-	if (nc->pfmemalloc)
+	if (nc->page.pfmemalloc)
 		skb->pfmemalloc = 1;
 	skb->head_frag = 1;
 
@@ -747,6 +755,69 @@ void consume_skb(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(consume_skb);
 
+void __kfree_skb_flush(void)
+{
+	struct napi_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
+
+	/* flush skb_cache if containing objects */
+	if (nc->skb_count) {
+		kmem_cache_free_bulk(skbuff_head_cache, nc->skb_count,
+				     nc->skb_cache);
+		nc->skb_count = 0;
+	}
+}
+
+static void __kfree_skb_defer(struct sk_buff *skb)
+{
+	struct napi_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
+
+	/* drop skb->head and call any destructors for packet */
+	skb_release_all(skb);
+
+	/* record skb to CPU local list */
+	nc->skb_cache[nc->skb_count++] = skb;
+
+#ifdef CONFIG_SLUB
+	/* SLUB writes into objects when freeing */
+	prefetchw(skb);
+#endif
+
+	/* flush skb_cache if it is filled */
+	if (unlikely(nc->skb_count == NAPI_SKB_CACHE_SIZE)) {
+		kmem_cache_free_bulk(skbuff_head_cache, NAPI_SKB_CACHE_SIZE,
+				     nc->skb_cache);
+		nc->skb_count = 0;
+	}
+}
+
+void napi_consume_skb(struct sk_buff *skb, int budget)
+{
+	if (unlikely(!skb))
+		return;
+
+	/* if budget is 0 assume netpoll w/ IRQs disabled */
+	if (unlikely(!budget)) {
+		dev_consume_skb_irq(skb);
+		return;
+	}
+
+	if (likely(atomic_read(&skb->users) == 1))
+		smp_rmb();
+	else if (likely(!atomic_dec_and_test(&skb->users)))
+		return;
+	/* if reaching here SKB is ready to free */
+	trace_consume_skb(skb);
+
+	/* if SKB is a clone, don't handle this case */
+	if (unlikely(skb->fclone != SKB_FCLONE_UNAVAILABLE)) {
+		__kfree_skb(skb);
+		return;
+	}
+
+	__kfree_skb_defer(skb);
+}
+EXPORT_SYMBOL(napi_consume_skb);
+
 /* Make sure a field is enclosed inside headers_start/headers_end section */
 #define CHECK_SKB_FIELD(field) \
 	BUILD_BUG_ON(offsetof(struct sk_buff, field) <		\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
