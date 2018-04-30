Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F10A6B0027
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 16:23:18 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b18-v6so6603105pgv.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 13:23:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m2-v6si6567394pgq.221.2018.04.30.13.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Apr 2018 13:23:17 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 14/16] mm: Add hmm_data to struct page
Date: Mon, 30 Apr 2018 13:22:45 -0700
Message-Id: <20180430202247.25220-15-willy@infradead.org>
In-Reply-To: <20180430202247.25220-1-willy@infradead.org>
References: <20180430202247.25220-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Make hmm_data an explicit member of the struct page union.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/hmm.h      |  8 ++------
 include/linux/mm_types.h | 14 +++++++++-----
 2 files changed, 11 insertions(+), 11 deletions(-)

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
index 0e6117123737..42619e16047f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -145,11 +145,15 @@ struct page {
 		/** @rcu_head: You can use this to free a page by RCU. */
 		struct rcu_head rcu_head;
 
-		/**
-		 * @pgmap: For ZONE_DEVICE pages, this points to the hosting
-		 * device page map.
-		 */
-		struct dev_pagemap *pgmap;
+		struct {
+			/**
+			 * @pgmap: For ZONE_DEVICE pages, this points to the
+			 * hosting device page map.
+			 */
+			struct dev_pagemap *pgmap;
+			unsigned long hmm_data;
+			unsigned long _zd_pad_1;	/* uses mapping */
+		};
 	};
 
 	union {		/* This union is 4 bytes in size. */
-- 
2.17.0
