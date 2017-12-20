Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 69E0B6B0271
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:56:04 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id d3so9702894plj.22
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:56:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k192si12003825pgc.650.2017.12.20.07.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 07:56:03 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 7/8] mm: Document how to use struct page
Date: Wed, 20 Dec 2017 07:55:51 -0800
Message-Id: <20171220155552.15884-8-willy@infradead.org>
In-Reply-To: <20171220155552.15884-1-willy@infradead.org>
References: <20171220155552.15884-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linuxfoundation.org, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Be really explicit about what bits / bytes are reserved for users that
want to store extra information about the pages they allocate.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Randy Dunlap <rdunlap@infradead.org>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm_types.h | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 1a3ba1f1605d..ef35ea524c26 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -31,7 +31,29 @@ struct hmm;
  * it to keep track of whatever it is we are using the page for at the
  * moment. Note that we have no way to track which tasks are using
  * a page, though if it is a pagecache page, rmap structures can tell us
- * who is mapping it.
+ * who is mapping it. If you allocate the page using alloc_pages(), you
+ * can use some of the space in struct page for your own purposes.
+ *
+ * Pages that were once in the page cache may be found under the RCU lock
+ * even after they have been recycled to a different purpose.  The page
+ * cache reads and writes some of the fields in struct page to pin the
+ * page before checking that it's still in the page cache.  It is vital
+ * that all users of struct page:
+ * 1. Use the first word as PageFlags.
+ * 2. Clear or preserve bit 0 of page->compound_head.  It is used as
+ *    PageTail for compound pages, and the page cache must not see false
+ *    positives.  Some users put a pointer here (guaranteed to be at least
+ *    4-byte aligned), other users avoid using the field altogether.
+ * 3. page->_refcount must either not be used, or must be used in such a
+ *    way that other CPUs temporarily incrementing and then decrementing the
+ *    refcount does not cause problems.  On receiving the page from
+ *    alloc_pages(), the refcount will be positive.
+ * 4. Either preserve page->_mapcount or restore it to -1 before freeing it.
+ *
+ * If you allocate pages of order > 0, you can use the fields in the struct
+ * page associated with each page, but bear in mind that the pages may have
+ * been inserted individually into the page cache, so you must use the above
+ * four fields in a compatible way for each struct page.
  *
  * SLUB uses cmpxchg_double() to atomically update its freelist and
  * counters.  That requires that freelist & counters be adjacent and
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
