Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7723E28025B
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:37:17 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 144so80885838pfv.5
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:37:17 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p2si5972769pge.244.2016.11.10.09.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 09:37:16 -0800 (PST)
Subject: [mm PATCH v3 21/23] mm: Add support for releasing multiple
 instances of a page
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 10 Nov 2016 06:36:06 -0500
Message-ID: <20161110113606.76501.70752.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org

This patch adds a function that allows us to batch free a page that has
multiple references outstanding.  Specifically this function can be used to
drop a page being used in the page frag alloc cache.  With this drivers can
make use of functionality similar to the page frag alloc cache without
having to do any workarounds for the fact that there is no function that
frees multiple references.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/gfp.h |    2 ++
 mm/page_alloc.c     |   14 ++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f8041f9de..4175dca 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -506,6 +506,8 @@ extern void free_hot_cold_page(struct page *page, bool cold);
 extern void free_hot_cold_page_list(struct list_head *list, bool cold);
 
 struct page_frag_cache;
+extern void __page_frag_drain(struct page *page, unsigned int order,
+			      unsigned int count);
 extern void *__alloc_page_frag(struct page_frag_cache *nc,
 			       unsigned int fragsz, gfp_t gfp_mask);
 extern void __free_page_frag(void *addr);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0fbfead..54fea40 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3912,6 +3912,20 @@ static struct page *__page_frag_refill(struct page_frag_cache *nc,
 	return page;
 }
 
+void __page_frag_drain(struct page *page, unsigned int order,
+		       unsigned int count)
+{
+	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
+
+	if (page_ref_sub_and_test(page, count)) {
+		if (order == 0)
+			free_hot_cold_page(page, false);
+		else
+			__free_pages_ok(page, order);
+	}
+}
+EXPORT_SYMBOL(__page_frag_drain);
+
 void *__alloc_page_frag(struct page_frag_cache *nc,
 			unsigned int fragsz, gfp_t gfp_mask)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
