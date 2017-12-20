Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5036B0069
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:53:01 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w22so14480756pge.10
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:53:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t84si13275816pfg.252.2017.12.20.07.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 07:52:59 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 1/8] mm: Align struct page more aesthetically
Date: Wed, 20 Dec 2017 07:52:49 -0800
Message-Id: <20171220155256.9841-2-willy@infradead.org>
In-Reply-To: <20171220155256.9841-1-willy@infradead.org>
References: <20171220155256.9841-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linuxfoundation.org, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

instead of an ifdef block at the end of the struct, which needed
its own comment, define _struct_page_alignment up at the top where it
fits nicely with the existing comment.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cfd0ac4e5e0e..4509f0cfaf39 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -39,6 +39,12 @@ struct hmm;
  * allows the use of atomic double word operations on the flags/mapping
  * and lru list pointers also.
  */
+#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
+#define _struct_page_alignment	__aligned(2 * sizeof(unsigned long))
+#else
+#define _struct_page_alignment
+#endif
+
 struct page {
 	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
@@ -212,15 +218,7 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
-}
-/*
- * The struct page can be forced to be double word aligned so that atomic ops
- * on double words work. The SLUB allocator can make use of such a feature.
- */
-#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
-	__aligned(2 * sizeof(unsigned long))
-#endif
-;
+} _struct_page_alignment;
 
 #define PAGE_FRAG_CACHE_MAX_SIZE	__ALIGN_MASK(32768, ~PAGE_MASK)
 #define PAGE_FRAG_CACHE_MAX_ORDER	get_order(PAGE_FRAG_CACHE_MAX_SIZE)
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
