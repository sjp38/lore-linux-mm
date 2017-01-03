Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4B06B0253
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 12:12:01 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y68so744777037pfb.6
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:12:01 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id a30si69647588pli.303.2017.01.03.09.12.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 09:12:00 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id b1so34085801pgc.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:12:00 -0800 (PST)
Subject: [next PATCH v3 1/3] mm: Rename __alloc_page_frag to page_frag_alloc
 and __free_page_frag to page_frag_free
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 03 Jan 2017 09:11:58 -0800
Message-ID: <20170103171024.5144.17036.stgit@localhost.localdomain>
In-Reply-To: <20170103170057.5144.17621.stgit@localhost.localdomain>
References: <20170103170057.5144.17621.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch renames the page frag functions to be more consistent with other
APIs.  Specifically we place the name page_frag first in the name and then
have either an alloc or free call name that we append as the suffix.  This
makes it a bit clearer in terms of naming.

In addition we drop the leading double underscores since we are technically
no longer a backing interface and instead the front end that is called from
the networking APIs.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

v2: Fixed a comparison between a void* and 0 due to copy/paste from free_pages
v3: Dropped changes to function and make this a rename patch only.
    This fixes a small performance regression I saw in some tests.

 include/linux/gfp.h    |    2 +-
 include/linux/skbuff.h |    2 +-
 mm/page_alloc.c        |   10 +++++-----
 net/core/skbuff.c      |    8 ++++----
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4175dca4ac39..19621300fa53 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -510,7 +510,7 @@ extern void __page_frag_drain(struct page *page, unsigned int order,
 			      unsigned int count);
 extern void *__alloc_page_frag(struct page_frag_cache *nc,
 			       unsigned int fragsz, gfp_t gfp_mask);
-extern void __free_page_frag(void *addr);
+extern void page_frag_free(void *addr);
 
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr), 0)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b53c0cfd417e..a410715bbef8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2480,7 +2480,7 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
 
 static inline void skb_free_frag(void *addr)
 {
-	__free_page_frag(addr);
+	page_frag_free(addr);
 }
 
 void *napi_alloc_frag(unsigned int fragsz);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2c6d5f64feca..9534e44308b2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3939,8 +3939,8 @@ void __page_frag_drain(struct page *page, unsigned int order,
 }
 EXPORT_SYMBOL(__page_frag_drain);
 
-void *__alloc_page_frag(struct page_frag_cache *nc,
-			unsigned int fragsz, gfp_t gfp_mask)
+void *page_frag_alloc(struct page_frag_cache *nc,
+		      unsigned int fragsz, gfp_t gfp_mask)
 {
 	unsigned int size = PAGE_SIZE;
 	struct page *page;
@@ -3991,19 +3991,19 @@ void *__alloc_page_frag(struct page_frag_cache *nc,
 
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
 	struct page *page = virt_to_head_page(addr);
 
 	if (unlikely(put_page_testzero(page)))
 		__free_pages_ok(page, compound_order(page));
 }
-EXPORT_SYMBOL(__free_page_frag);
+EXPORT_SYMBOL(page_frag_free);
 
 static void *make_alloc_exact(unsigned long addr, unsigned int order,
 		size_t size)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5a03730fbc1a..734c71468b01 100644
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
