Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D41406B000E
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 00:31:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x17so5894586pfn.10
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 21:31:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f8si5277869pgo.689.2018.04.13.21.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 21:31:51 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 4/8] mm: Improve page flag policy documentation
Date: Fri, 13 Apr 2018 21:31:41 -0700
Message-Id: <20180414043145.3953-5-willy@infradead.org>
In-Reply-To: <20180414043145.3953-1-willy@infradead.org>
References: <20180414043145.3953-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Rewrite this documentation to be more clear about the expectations
for users.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/page-flags.h | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 393bb93b6b89..a6931046cc5c 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -164,24 +164,26 @@ static __always_inline struct page *CheckPageInit(struct page *page)
 }
 
 /*
- * Page flags policies wrt compound pages
+ * Page flag policies describe how each page flag is used for compound pages.
  *
  * PF_ANY:
- *     the page flag is relevant for small, head and tail pages.
+ *     This page flag is relevant for single, head and tail pages.
  *
  * PF_HEAD:
- *     for compound page all operations related to the page flag applied to
- *     head page.
+ *     The head page contains the flag for the entire compound page.
+ *     Callers may pass any subpage of the compound page, and the operation
+ *     will be carried out on the head page.
  *
  * PF_ONLY_HEAD:
- *     for compound page, callers only ever operate on the head page.
+ *     Callers only ever operate on the head page (or single pages).
  *
  * PF_TAIL_READ:
- *     modifications of the page flag must be done on small or head pages,
- *     checks can be done on tail pages too.
+ *     The head page contains the flag for the entire compound page.
+ *     If the flag is being modified, the caller must pass in the head page.
+ *     For testing the flas, callers may use any subpage of the compound page.
  *
  * PF_NO_COMPOUND:
- *     the page flag is not relevant for compound pages.
+ *     The page flag is not used for compound pages.
  */
 #define PF_ANY(page, modify)	CheckPageInit(page)
 #define PF_HEAD(page, modify)	CheckPageInit(compound_head(page))
-- 
2.16.3
