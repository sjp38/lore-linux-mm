Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id A989E6B0072
	for <linux-mm@kvack.org>; Thu,  7 May 2015 00:12:11 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so15372933qge.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 21:12:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e76si861033qka.106.2015.05.06.21.12.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 21:12:11 -0700 (PDT)
Subject: [PATCH 05/10] net: Add skb_free_frag to replace use of put_page in
 freeing skb->head
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:12:03 -0700
Message-ID: <20150507041203.1873.67584.stgit@ahduyck-vm-fedora22>
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com

This change adds a function called skb_free_frag which is meant to
compliment the function netdev_alloc_frag.  The general idea is to enable a
more lightweight version of page freeing since we don't actually need all
the overhead of a put_page, and we don't quite fit the model of __free_pages.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/skbuff.h |    5 +++++
 net/core/skbuff.c      |   10 ++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0039fcc45b3b..c0b574a414e7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2182,6 +2182,11 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
 	return __netdev_alloc_skb_ip_align(dev, length, GFP_ATOMIC);
 }
 
+static inline void skb_free_frag(void *addr)
+{
+	__free_page_frag(addr);
+}
+
 void *napi_alloc_frag(unsigned int fragsz);
 struct sk_buff *__napi_alloc_skb(struct napi_struct *napi,
 				 unsigned int length, gfp_t gfp_mask);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index dcc0e07abf47..d67e612bf0ef 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -436,7 +436,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int len,
 
 	skb = __build_skb(data, len);
 	if (unlikely(!skb)) {
-		put_page(virt_to_head_page(data));
+		skb_free_frag(data);
 		return NULL;
 	}
 
@@ -490,7 +490,7 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 
 	skb = __build_skb(data, len);
 	if (unlikely(!skb)) {
-		put_page(virt_to_head_page(data));
+		skb_free_frag(data);
 		return NULL;
 	}
 
@@ -549,10 +549,12 @@ static void skb_clone_fraglist(struct sk_buff *skb)
 
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
