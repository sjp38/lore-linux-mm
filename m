Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A52A6B0003
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 00:31:52 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x5-v6so6995728pln.21
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 21:31:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 3-v6si7087865plv.323.2018.04.13.21.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 21:31:51 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 7/8] mm: Always check PagePolicyNoCompound
Date: Fri, 13 Apr 2018 21:31:44 -0700
Message-Id: <20180414043145.3953-8-willy@infradead.org>
In-Reply-To: <20180414043145.3953-1-willy@infradead.org>
References: <20180414043145.3953-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Currently, we're only checking that a page is not compound when we're
setting or clearing a bit.  We should probably be checking the page
isn't compound when testing the bit too.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/page-flags.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index ac55f6c94c0a..1960b5e4b9ab 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -178,11 +178,10 @@ struct page *PagePolicyTailRead(struct page *page, bool modify)
 	return compound_head(page);
 }
 
-static __always_inline
-struct page *PagePolicyNoCompound(struct page *page, bool modify)
+static __always_inline struct page *PagePolicyNoCompound(struct page *page)
 {
 	CheckPageInit(page);
-	VM_BUG_ON_PGFLAGS(modify && PageCompound(page), page);
+	VM_BUG_ON_PGFLAGS(PageCompound(page), page);
 	return page;
 }
 
@@ -212,7 +211,7 @@ struct page *PagePolicyNoCompound(struct page *page, bool modify)
 #define PF_HEAD(page, modify)		compound_head(CheckPageInit(page))
 #define PF_ONLY_HEAD(page, modify)	PagePolicyOnlyHead(page)
 #define PF_TAIL_READ(page, modify)	PagePolicyTailRead(page, modify)
-#define PF_NO_COMPOUND(page, modify)	PagePolicyNoCompound(page, modify)
+#define PF_NO_COMPOUND(page, modify)	PagePolicyNoCompound(page)
 
 /*
  * Macros to create function definitions for page flags
-- 
2.16.3
