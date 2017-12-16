Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6204403D9
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 11:44:48 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 61so2370236plz.1
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 08:44:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t25si6179683pgv.644.2017.12.16.08.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 08:44:42 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 7/8] mm: Document how to use struct page
Date: Sat, 16 Dec 2017 08:44:24 -0800
Message-Id: <20171216164425.8703-8-willy@infradead.org>
In-Reply-To: <20171216164425.8703-1-willy@infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Be really explicit about what bits / bytes are reserved for users that
want to store extra information about the pages they allocate.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 1a3ba1f1605d..a517d210f177 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -31,7 +31,28 @@ struct hmm;
  * it to keep track of whatever it is we are using the page for at the
  * moment. Note that we have no way to track which tasks are using
  * a page, though if it is a pagecache page, rmap structures can tell us
- * who is mapping it.
+ * who is mapping it. If you allocate the page using alloc_pages(), you
+ * can use some of the space in struct page for your own purposes.
+ *
+ * Pages that were once in the page cache may be found under the RCU lock
+ * even after they have been recycled to a different purpose.  The page cache
+ * will read and writes some of the fields in struct page to lock the page,
+ * then check that it's still in the page cache.  It is vital that all users
+ * of struct page:
+ * 1. Use the first word as PageFlags.
+ * 2. Clear or preserve bit 0 of page->compound_head.  It is used as
+ *    PageTail for compound pages, and the page cache must not see false
+ *    positives.  Some users put a pointer here (guaranteed to be at least
+ *    4-byte aligned), other users avoid using the word altogether.
+ * 3. page->_refcount must either not be used, or must be used in such a
+ *    way that other CPUs temporarily incrementing and then decrementing the
+ *    refcount does not cause problems.  On receiving the page from
+ *    alloc_pages(), the refcount will be positive.
+ *
+ * If you allocate pages of order > 0, you can use the fields in the struct
+ * page associated with each page, but bear in mind that the pages may have
+ * been inserted individually into the page cache, so you must use the above
+ * three fields in a compatible way for each struct page.
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
