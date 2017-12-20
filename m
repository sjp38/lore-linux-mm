Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A885B6B026D
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:56:02 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a74so16653034pfg.20
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:56:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s22si4679527pgo.363.2017.12.20.07.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 07:56:01 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 3/8] mm: Remove misleading alignment claims
Date: Wed, 20 Dec 2017 07:55:47 -0800
Message-Id: <20171220155552.15884-4-willy@infradead.org>
In-Reply-To: <20171220155552.15884-1-willy@infradead.org>
References: <20171220155552.15884-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linuxfoundation.org, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The "third double word block" isn't on 32-bit systems.  The layout
looks like this:

	unsigned long flags;
	struct address_space *mapping
	pgoff_t index;
	atomic_t _mapcount;
	atomic_t _refcount;

which is 32 bytes on 64-bit, but 20 bytes on 32-bit.  Nobody is trying
to use the fact that it's double-word aligned today, so just remove the
misleading claims.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 include/linux/mm_types.h | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 27973166af28..c2294e6204e8 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -33,11 +33,11 @@ struct hmm;
  * a page, though if it is a pagecache page, rmap structures can tell us
  * who is mapping it.
  *
- * The objects in struct page are organized in double word blocks in
- * order to allows us to use atomic double word operations on portions
- * of struct page. That is currently only used by slub but the arrangement
- * allows the use of atomic double word operations on the flags/mapping
- * and lru list pointers also.
+ * SLUB uses cmpxchg_double() to atomically update its freelist and
+ * counters.  That requires that freelist & counters be adjacent and
+ * double-word aligned.  We align all struct pages to double-word
+ * boundaries, and ensure that 'freelist' is aligned within the
+ * struct.
  */
 #ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
 #define _struct_page_alignment	__aligned(2 * sizeof(unsigned long))
@@ -113,8 +113,6 @@ struct page {
 	};
 
 	/*
-	 * Third double word block
-	 *
 	 * WARNING: bit 0 of the first word encode PageTail(). That means
 	 * the rest users of the storage space MUST NOT use the bit to
 	 * avoid collision and false-positive PageTail().
@@ -175,7 +173,6 @@ struct page {
 #endif
 	};
 
-	/* Remainder is not double word aligned */
 	union {
 		unsigned long private;		/* Mapping-private opaque data:
 					 	 * usually used for buffer_heads
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
