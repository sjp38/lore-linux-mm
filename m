Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5D36B0680
	for <linux-mm@kvack.org>; Fri, 18 May 2018 15:47:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e20-v6so5298498pff.14
        for <linux-mm@kvack.org>; Fri, 18 May 2018 12:47:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w20-v6si1342287pgc.645.2018.05.18.12.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 12:45:24 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 13/17] mm: Add hmm_data to struct page
Date: Fri, 18 May 2018 12:45:15 -0700
Message-Id: <20180518194519.3820-14-willy@infradead.org>
In-Reply-To: <20180518194519.3820-1-willy@infradead.org>
References: <20180518194519.3820-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Make hmm_data an explicit member of the struct page union.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/hmm.h      |  8 ++------
 include/linux/mm_types.h | 12 ++++++------
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 39988924de3a..91c1b2dccbbb 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -522,9 +522,7 @@ void hmm_devmem_remove(struct hmm_devmem *devmem);
 static inline void hmm_devmem_page_set_drvdata(struct page *page,
 					       unsigned long data)
 {
-	unsigned long *drvdata = (unsigned long *)&page->pgmap;
-
-	drvdata[1] = data;
+	page->hmm_data = data;
 }
 
 /*
@@ -535,9 +533,7 @@ static inline void hmm_devmem_page_set_drvdata(struct page *page,
  */
 static inline unsigned long hmm_devmem_page_get_drvdata(const struct page *page)
 {
-	const unsigned long *drvdata = (const unsigned long *)&page->pgmap;
-
-	return drvdata[1];
+	return page->hmm_data;
 }
 
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7eb7092424b7..530a9a2b039b 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -146,15 +146,15 @@ struct page {
 			spinlock_t ptl;
 #endif
 		};
+		struct {	/* ZONE_DEVICE pages */
+			/** @pgmap: Points to the hosting device page map. */
+			struct dev_pagemap *pgmap;
+			unsigned long hmm_data;
+			unsigned long _zd_pad_1;	/* uses mapping */
+		};
 
 		/** @rcu_head: You can use this to free a page by RCU. */
 		struct rcu_head rcu_head;
-
-		/**
-		 * @pgmap: For ZONE_DEVICE pages, this points to the hosting
-		 * device page map.
-		 */
-		struct dev_pagemap *pgmap;
 	};
 
 	union {		/* This union is 4 bytes in size. */
-- 
2.17.0
