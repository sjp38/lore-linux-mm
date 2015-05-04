Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD9D6B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 19:09:48 -0400 (EDT)
Received: by qgdy78 with SMTP id y78so73497010qgd.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 16:09:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f199si36185523qhc.20.2015.05.04.16.09.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 16:09:46 -0700 (PDT)
Subject: [net-next PATCH 1/6] net: Add skb_free_frag to replace use of
 put_page in freeing skb->head
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 04 May 2015 16:09:43 -0700
Message-ID: <20150504230943.1496.11131.stgit@ahduyck-vm-fedora22>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, netdev@vger.kernel.org
Cc: akpm@linux-foundation.org, davem@davemloft.net

This change adds a function called skb_free_frag which is meant to
compliment the function __alloc_page_frag.  The general idea is to enable a
more lightweight version of page freeing since we don't actually need all
the overhead of a put_page, and we don't quite fit the model of __free_pages.

The model for this is based off of __free_pages since we don't actually
need to deal with all of the cases that put_page handles.  I incorporated
the virt_to_head_page call and compound_order into the function as it
actually allows for a signficant size reduction by reducing code
duplication.

In order to enable the function it was necessary to move __free_pages_ok
from being a statically defined function so that I could use it in
skbuff.c.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/gfp.h    |    1 +
 include/linux/skbuff.h |    1 +
 mm/page_alloc.c        |    4 +---
 net/core/skbuff.c      |   29 ++++++++++++++++++++++++++---
 4 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 97a9373e61e8..edd19a06e2ac 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -365,6 +365,7 @@ extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_hot_cold_page(struct page *page, bool cold);
 extern void free_hot_cold_page_list(struct list_head *list, bool cold);
+extern void __free_pages_ok(struct page *page, unsigned int order);
 
 extern void __free_kmem_pages(struct page *page, unsigned int order);
 extern void free_kmem_pages(unsigned long addr, unsigned int order);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9c2f793573fa..3bfe3340929e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2186,6 +2186,7 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
 	return __netdev_alloc_skb_ip_align(dev, length, GFP_ATOMIC);
 }
 
+void skb_free_frag(void *head);
 void *napi_alloc_frag(unsigned int fragsz);
 struct sk_buff *__napi_alloc_skb(struct napi_struct *napi,
 				 unsigned int length, gfp_t gfp_mask);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e4a9c0..ab9ba9360730 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -165,8 +165,6 @@ bool pm_suspended_storage(void)
 int pageblock_order __read_mostly;
 #endif
 
-static void __free_pages_ok(struct page *page, unsigned int order);
-
 /*
  * results with 256, 32 in the lowmem_reserve sysctl:
  *	1G machine -> (16M dma, 800M-16M normal, 1G-800M high)
@@ -815,7 +813,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	return true;
 }
 
-static void __free_pages_ok(struct page *page, unsigned int order)
+void __free_pages_ok(struct page *page, unsigned int order)
 {
 	unsigned long flags;
 	int migratetype;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1e4278a4dd7e..754842557fb0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -428,6 +428,27 @@ refill:
 	return page_address(page) + offset;
 }
 
+/**
+ * skb_free_frag - free a page fragment
+ * @head: virtual address of page fragment
+ *
+ * Frees a page fragment allocated out of either a compound or order 0 page.
+ * The function itself is a hybrid between free_pages and free_compound_page
+ * which can be found in mm/page_alloc.c
+ */
+void skb_free_frag(void *head)
+{
+	struct page *page = virt_to_head_page(head);
+
+	if (unlikely(put_page_testzero(page))) {
+		if (likely(PageHead(page)))
+			__free_pages_ok(page, compound_order(page));
+		else
+			free_hot_cold_page(page, false);
+	}
+}
+EXPORT_SYMBOL(skb_free_frag);
+
 static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
 	unsigned long flags;
@@ -499,7 +520,7 @@ static struct sk_buff *__alloc_rx_skb(unsigned int length, gfp_t gfp_mask,
 		if (likely(data)) {
 			skb = build_skb(data, fragsz);
 			if (unlikely(!skb))
-				put_page(virt_to_head_page(data));
+				skb_free_frag(data);
 		}
 	} else {
 		skb = __alloc_skb(length, gfp_mask,
@@ -611,10 +632,12 @@ static void skb_clone_fraglist(struct sk_buff *skb)
 
 static void skb_free_head(struct sk_buff *skb)
 {
+	unsigned char *head = skb->head;
+
 	if (skb->head_frag)
-		put_page(virt_to_head_page(skb->head));
+		skb_free_frag(head);
 	else
-		kfree(skb->head);
+		kfree(head);
 }
 
 static void skb_release_data(struct sk_buff *skb)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
