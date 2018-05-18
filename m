Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF8A6B067C
	for <linux-mm@kvack.org>; Fri, 18 May 2018 15:47:20 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x32-v6so5613053pld.16
        for <linux-mm@kvack.org>; Fri, 18 May 2018 12:47:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s36-v6si7803911pld.114.2018.05.18.12.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 12:45:23 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 11/17] mm: Improve struct page documentation
Date: Fri, 18 May 2018 12:45:13 -0700
Message-Id: <20180518194519.3820-12-willy@infradead.org>
In-Reply-To: <20180518194519.3820-1-willy@infradead.org>
References: <20180518194519.3820-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Rewrite the documentation to describe what you can use in struct
page rather than what you can't.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Reviewed-by: Randy Dunlap <rdunlap@infradead.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mm_types.h | 40 +++++++++++++++++++---------------------
 1 file changed, 19 insertions(+), 21 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cf3bbee8c9a1..90a6dbeeef11 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -33,29 +33,27 @@ struct hmm;
  * it to keep track of whatever it is we are using the page for at the
  * moment. Note that we have no way to track which tasks are using
  * a page, though if it is a pagecache page, rmap structures can tell us
- * who is mapping it. If you allocate the page using alloc_pages(), you
- * can use some of the space in struct page for your own purposes.
+ * who is mapping it.
  *
- * Pages that were once in the page cache may be found under the RCU lock
- * even after they have been recycled to a different purpose.  The page
- * cache reads and writes some of the fields in struct page to pin the
- * page before checking that it's still in the page cache.  It is vital
- * that all users of struct page:
- * 1. Use the first word as PageFlags.
- * 2. Clear or preserve bit 0 of page->compound_head.  It is used as
- *    PageTail for compound pages, and the page cache must not see false
- *    positives.  Some users put a pointer here (guaranteed to be at least
- *    4-byte aligned), other users avoid using the field altogether.
- * 3. page->_refcount must either not be used, or must be used in such a
- *    way that other CPUs temporarily incrementing and then decrementing the
- *    refcount does not cause problems.  On receiving the page from
- *    alloc_pages(), the refcount will be positive.
- * 4. Either preserve page->_mapcount or restore it to -1 before freeing it.
+ * If you allocate the page using alloc_pages(), you can use some of the
+ * space in struct page for your own purposes.  The five words in the main
+ * union are available, except for bit 0 of the first word which must be
+ * kept clear.  Many users use this word to store a pointer to an object
+ * which is guaranteed to be aligned.  If you use the same storage as
+ * page->mapping, you must restore it to NULL before freeing the page.
  *
- * If you allocate pages of order > 0, you can use the fields in the struct
- * page associated with each page, but bear in mind that the pages may have
- * been inserted individually into the page cache, so you must use the above
- * four fields in a compatible way for each struct page.
+ * If your page will not be mapped to userspace, you can also use the four
+ * bytes in the mapcount union, but you must call page_mapcount_reset()
+ * before freeing it.
+ *
+ * If you want to use the refcount field, it must be used in such a way
+ * that other CPUs temporarily incrementing and then decrementing the
+ * refcount does not cause problems.  On receiving the page from
+ * alloc_pages(), the refcount will be positive.
+ *
+ * If you allocate pages of order > 0, you can use some of the fields
+ * in each subpage, but you may need to restore some of their values
+ * afterwards.
  *
  * SLUB uses cmpxchg_double() to atomically update its freelist and
  * counters.  That requires that freelist & counters be adjacent and
-- 
2.17.0
