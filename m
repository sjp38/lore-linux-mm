Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4F346B0069
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 11:44:43 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 3so10037380pfo.1
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 08:44:43 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o24si6737760pll.390.2017.12.16.08.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 08:44:42 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 5/8] mm: Introduce _slub_counter_t
Date: Sat, 16 Dec 2017 08:44:22 -0800
Message-Id: <20171216164425.8703-6-willy@infradead.org>
In-Reply-To: <20171216164425.8703-1-willy@infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Instead of putting the ifdef in the middle of the definition of struct
page, pull it forward to the rest of the ifdeffery around the SLUB
cmpxchg_double optimisation.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 8c3b8cea22ee..5521c9799c50 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -41,9 +41,15 @@ struct hmm;
  */
 #ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
 #define _struct_page_alignment	__aligned(2 * sizeof(unsigned long))
+#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE)
+#define _slub_counter_t		unsigned long
 #else
-#define _struct_page_alignment
+#define _slub_counter_t		unsigned int
 #endif
+#else /* !CONFIG_HAVE_ALIGNED_STRUCT_PAGE */
+#define _struct_page_alignment
+#define _slub_counter_t		unsigned int
+#endif /* !CONFIG_HAVE_ALIGNED_STRUCT_PAGE */
 
 struct page {
 	/* First double word block */
@@ -66,18 +72,7 @@ struct page {
 	};
 
 	union {
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-	defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-		/* Used for cmpxchg_double in slub */
-		unsigned long counters;
-#else
-		/*
-		 * Keep _refcount separate from slub cmpxchg_double data.
-		 * As the rest of the double word is protected by slab_lock
-		 * but _refcount is not.
-		 */
-		unsigned counters;
-#endif
+		_slub_counter_t counters;
 		unsigned int active;		/* SLAB */
 		struct {			/* SLUB */
 			unsigned inuse:16;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
