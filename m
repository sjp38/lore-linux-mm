Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 41F916B0253
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:23:18 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y71so445000279pgd.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:23:18 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id g189si60995796pfb.281.2016.11.29.10.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 10:23:17 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id y68so8741440pfb.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:23:17 -0800 (PST)
Subject: [mm PATCH 1/3] mm: Rename __alloc_page_frag to page_frag_alloc and
 __free_page_frag to page_frag_free
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 29 Nov 2016 10:23:15 -0800
Message-ID: <20161129182315.13445.17597.stgit@localhost.localdomain>
In-Reply-To: <20161129182010.13445.31256.stgit@localhost.localdomain>
References: <20161129182010.13445.31256.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net, jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch renames the page frag functions to be more consistent with other
APIs.  Specifically we place the name page_frag first in the name and then
have either an alloc or free call name that we append as the suffix.  This
makes it a bit clearer in terms of naming.

In addition we drop the leading double underscores since we are technically
no longer a backing interface and instead the front end that is called from
the networking APIs.

The last bit I changed is I rebased page_frag_free to actually function
very similar to the function free_pages, the only real difference now is
the fact that we have to get the page order by calling compound page
instead of having it passed as a part of the function call.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/gfp.h    |    6 +++---
 include/linux/skbuff.h |    2 +-
 mm/page_alloc.c        |   20 ++++++++++++--------
 net/core/skbuff.c      |    8 ++++----
 4 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4175dca4ac39..6238c74e0a01 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -508,9 +508,9 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 struct page_frag_cache;
 extern void __page_frag_drain(struct page *page, unsigned int order,
 			      unsigned int count);
-extern void *__alloc_page_frag(struct page_frag_cache *nc,
-			       unsigned int fragsz, gfp_t gfp_mask);
-extern void __free_page_frag(void *addr);
+extern void *page_frag_alloc(struct page_frag_cache *nc,
+			     unsigned int fragsz, gfp_t gfp_mask);
+extern void page_frag_free(void *addr);
 
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr), 0)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9c535fbccf2c..95799826a1e7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2471,7 +2471,7 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
 
 static inline void skb_free_frag(void *addr)
 {
-	__free_page_frag(addr);
+	page_frag_free(addr);
 }
 
 void *napi_alloc_frag(unsigned int fragsz);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb668eab5ee4..4218795a4694 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3931,8 +3931,8 @@ void __page_frag_drain(struct page *page, unsigned int order,
 }
 EXPORT_SYMBOL(__page_frag_drain);
 
-void *__alloc_page_frag(struct page_frag_cache *nc,
-			unsigned int fragsz, gfp_t gfp_mask)
+void *page_frag_alloc(struct page_frag_cache *nc,
+		      unsigned int fragsz, gfp_t gfp_mask)
 {
 	unsigned int size = PAGE_SIZE;
 	struct page *page;
@@ -3983,19 +3983,23 @@ void *__alloc_page_frag(struct page_frag_cache *nc,
 
 	return nc->va + offset;
 }
-EXPORT_SYMBOL(__alloc_page_frag);
+EXPORT_SYMBOL(page_frag_alloc);
 
 /*
  * Frees a page fragment allocated out of either a compound or order 0 page.
  */
-void __free_page_frag(void *addr)
+void page_frag_free(void *addr)
 {
-	struct page *page = virt_to_head_page(addr);
+	struct page *page;
+
+	if (addr != 0) {
+		VM_BUG_ON(!virt_addr_valid(addr));
+		page = virt_to_head_page(addr);
 
-	if (unlikely(put_page_testzero(page)))
-		__free_pages_ok(page, compound_order(page));
+		__free_pages(page, compound_order(page));
+	}
 }
-EXPORT_SYMBOL(__free_page_frag);
+EXPORT_SYMBOL(page_frag_free);
 
 static void *make_alloc_exact(unsigned long addr, unsigned int order,
 		size_t size)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4c96cb18c214..6cf779a9ad4c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -369,7 +369,7 @@ static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 
 	local_irq_save(flags);
 	nc = this_cpu_ptr(&netdev_alloc_cache);
-	data = __alloc_page_frag(nc, fragsz, gfp_mask);
+	data = page_frag_alloc(nc, fragsz, gfp_mask);
 	local_irq_restore(flags);
 	return data;
 }
@@ -391,7 +391,7 @@ static void *__napi_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
 	struct napi_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
 
-	return __alloc_page_frag(&nc->page, fragsz, gfp_mask);
+	return page_frag_alloc(&nc->page, fragsz, gfp_mask);
 }
 
 void *napi_alloc_frag(unsigned int fragsz)
@@ -441,7 +441,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int len,
 	local_irq_save(flags);
 
 	nc = this_cpu_ptr(&netdev_alloc_cache);
-	data = __alloc_page_frag(nc, len, gfp_mask);
+	data = page_frag_alloc(nc, len, gfp_mask);
 	pfmemalloc = nc->pfmemalloc;
 
 	local_irq_restore(flags);
@@ -505,7 +505,7 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 	if (sk_memalloc_socks())
 		gfp_mask |= __GFP_MEMALLOC;
 
-	data = __alloc_page_frag(&nc->page, len, gfp_mask);
+	data = page_frag_alloc(&nc->page, len, gfp_mask);
 	if (unlikely(!data))
 		return NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
