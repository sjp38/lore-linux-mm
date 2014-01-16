Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E9B0A6B0039
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 18:23:35 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fa1so3348430pad.27
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 15:23:35 -0800 (PST)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id vz4si8370330pac.180.2014.01.16.15.23.33
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 15:23:34 -0800 (PST)
From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [RFC PATCH 2/3] Use slab allocations for netdev page_frag receive buffers
Date: Thu, 16 Jan 2014 18:17:03 -0500
Message-Id: <1389914224-10453-3-git-send-email-dbanerje@akamai.com>
In-Reply-To: <1389914224-10453-1-git-send-email-dbanerje@akamai.com>
References: <1389914224-10453-1-git-send-email-dbanerje@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org
Cc: dbanerje@akamai.com, johunt@akamai.com, jbaron@akamai.com, davem@davemloft.net, linux-mm@kvack.org

---
 net/core/skbuff.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d9e8736..7ecb7a8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -368,6 +368,8 @@ struct netdev_alloc_cache {
 };
 static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
 
+struct kmem_cache *netdev_page_frag_cache;
+
 static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
 	struct netdev_alloc_cache *nc;
@@ -379,18 +381,22 @@ static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 	nc = &__get_cpu_var(netdev_alloc_cache);
 	if (unlikely(!nc->frag.page)) {
 refill:
-		for (order = NETDEV_FRAG_PAGE_MAX_ORDER; ;) {
-			gfp_t gfp = gfp_mask;
-
-			if (order)
-				gfp |= __GFP_COMP | __GFP_NOWARN;
-			nc->frag.page = alloc_pages(gfp, order);
-			if (likely(nc->frag.page))
-				break;
-			if (--order < 0)
-				goto end;
+		if (NETDEV_FRAG_PAGE_MAX_ORDER > 0) {
+			void *kmem = kmem_cache_alloc(netdev_page_frag_cache, gfp_mask | __GFP_NOWARN);
+			if (likely(kmem)) {
+				nc->frag.page = virt_to_page(kmem);
+				nc->frag.size = PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER;
+				goto recycle;
+			}
 		}
-		nc->frag.size = PAGE_SIZE << order;
+
+		nc->frag.page = alloc_page(gfp_mask);
+
+		if (likely(nc->frag.page))
+			nc->frag.size = PAGE_SIZE;
+		else
+			goto end;
+
 recycle:
 		atomic_set(&nc->frag.page->_count, NETDEV_PAGECNT_MAX_BIAS);
 		nc->pagecnt_bias = NETDEV_PAGECNT_MAX_BIAS;
@@ -3092,6 +3098,11 @@ void __init skb_init(void)
 						0,
 						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						NULL);
+	netdev_page_frag_cache = kmem_cache_create("netdev_page_frag_cache",
+						PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER,
+						PAGE_SIZE,
+						SLAB_HWCACHE_ALIGN,
+						NULL);
 }
 
 /**
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
