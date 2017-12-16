Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46EF36B0266
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 11:44:44 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j26so9964049pff.8
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 08:44:44 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o2si6205549pge.198.2017.12.16.08.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 08:44:42 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 6/8] mm: Store compound_dtor / compound_order as bytes
Date: Sat, 16 Dec 2017 08:44:23 -0800
Message-Id: <20171216164425.8703-7-willy@infradead.org>
In-Reply-To: <20171216164425.8703-1-willy@infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Neither of these values get even close to 256; compound_dtor is
currently at a maximum of 3, and compound_order can't be over 64.
No machine has inefficient access to bytes since EV5, and while
those are still supported, we don't optimise for them any more.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5521c9799c50..1a3ba1f1605d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -136,19 +136,8 @@ struct page {
 			unsigned long compound_head; /* If bit zero is set */
 
 			/* First tail page only */
-#ifdef CONFIG_64BIT
-			/*
-			 * On 64 bit system we have enough space in struct page
-			 * to encode compound_dtor and compound_order with
-			 * unsigned int. It can help compiler generate better or
-			 * smaller code on some archtectures.
-			 */
-			unsigned int compound_dtor;
-			unsigned int compound_order;
-#else
-			unsigned short int compound_dtor;
-			unsigned short int compound_order;
-#endif
+			unsigned char compound_dtor;
+			unsigned char compound_order;
 		};
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
