Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C45D76B0260
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:53:02 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p1so16651529pfp.13
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:53:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m3si12995897pld.54.2017.12.20.07.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 07:53:01 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 6/8] mm: Store compound_dtor / compound_order as bytes
Date: Wed, 20 Dec 2017 07:52:54 -0800
Message-Id: <20171220155256.9841-7-willy@infradead.org>
In-Reply-To: <20171220155256.9841-1-willy@infradead.org>
References: <20171220155256.9841-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linuxfoundation.org, Matthew Wilcox <mawilcox@microsoft.com>

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
