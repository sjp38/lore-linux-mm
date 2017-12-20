Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E55D6B0260
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:53:02 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p89so3875365pfk.5
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:53:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d77si13351724pfj.97.2017.12.20.07.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 07:53:01 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 5/8] mm: Introduce _slub_counter_t
Date: Wed, 20 Dec 2017 07:52:53 -0800
Message-Id: <20171220155256.9841-6-willy@infradead.org>
In-Reply-To: <20171220155256.9841-1-willy@infradead.org>
References: <20171220155256.9841-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linuxfoundation.org, Matthew Wilcox <mawilcox@microsoft.com>

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
