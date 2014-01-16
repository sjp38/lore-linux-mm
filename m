Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6B41E6B003A
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 18:23:36 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so2803763pbc.0
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 15:23:36 -0800 (PST)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id tr4si8375116pab.150.2014.01.16.15.23.33
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 15:23:34 -0800 (PST)
From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [RFC PATCH 3/3] Use slab allocations for sk page_frag send buffers
Date: Thu, 16 Jan 2014 18:17:04 -0500
Message-Id: <1389914224-10453-4-git-send-email-dbanerje@akamai.com>
In-Reply-To: <1389914224-10453-1-git-send-email-dbanerje@akamai.com>
References: <1389914224-10453-1-git-send-email-dbanerje@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org
Cc: dbanerje@akamai.com, johunt@akamai.com, jbaron@akamai.com, davem@davemloft.net, linux-mm@kvack.org

---
 net/core/sock.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 6565431..dbbd2f9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1792,10 +1792,12 @@ EXPORT_SYMBOL(sock_alloc_send_skb);
 
 /* On 32bit arches, an skb frag is limited to 2^15 */
 #define SKB_FRAG_PAGE_ORDER	get_order(32768)
+struct kmem_cache *sk_page_frag_cache;
 
 bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag)
 {
 	int order;
+	gfp_t gfp_mask = sk->sk_allocation;
 
 	if (pfrag->page) {
 		if (atomic_read(&pfrag->page->_count) == 1) {
@@ -1807,21 +1809,25 @@ bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag)
 		put_page(pfrag->page);
 	}
 
-	/* We restrict high order allocations to users that can afford to wait */
-	order = (sk->sk_allocation & __GFP_WAIT) ? SKB_FRAG_PAGE_ORDER : 0;
+	order = SKB_FRAG_PAGE_ORDER;
 
-	do {
-		gfp_t gfp = sk->sk_allocation;
-
-		if (order)
-			gfp |= __GFP_COMP | __GFP_NOWARN;
-		pfrag->page = alloc_pages(gfp, order);
-		if (likely(pfrag->page)) {
+	if (order > 0) {
+		void *kmem = kmem_cache_alloc(sk_page_frag_cache, gfp_mask | __GFP_NOWARN);
+		if (likely(kmem)) {
+			pfrag->page = virt_to_page(kmem);
 			pfrag->offset = 0;
 			pfrag->size = PAGE_SIZE << order;
 			return true;
 		}
-	} while (--order >= 0);
+	}
+
+	pfrag->page = alloc_page(gfp_mask);
+
+	if (likely(pfrag->page)) {
+		pfrag->offset = 0;
+		pfrag->size = PAGE_SIZE;
+		return true;
+	}
 
 	sk_enter_memory_pressure(sk);
 	sk_stream_moderate_sndbuf(sk);
@@ -2822,13 +2828,18 @@ static __net_init int proto_init_net(struct net *net)
 {
 	if (!proc_create("protocols", S_IRUGO, net->proc_net, &proto_seq_fops))
 		return -ENOMEM;
-
+	sk_page_frag_cache = kmem_cache_create("sk_page_frag_cache",
+			  PAGE_SIZE << SKB_FRAG_PAGE_ORDER,
+			  PAGE_SIZE,
+			  SLAB_HWCACHE_ALIGN,
+			  NULL);
 	return 0;
 }
 
 static __net_exit void proto_exit_net(struct net *net)
 {
 	remove_proc_entry("protocols", net->proc_net);
+	kmem_cache_destroy(sk_page_frag_cache);
 }
 
 
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
