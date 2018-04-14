Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7B8A6B0010
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 00:31:57 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m14so2955775pfj.18
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 21:31:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u9-v6si7441403plz.10.2018.04.13.21.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 21:31:51 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 6/8] mm: Turn page policies into functions
Date: Fri, 13 Apr 2018 21:31:43 -0700
Message-Id: <20180414043145.3953-7-willy@infradead.org>
In-Reply-To: <20180414043145.3953-1-willy@infradead.org>
References: <20180414043145.3953-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Instead of doing quite so much macro trickery, just use functions.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/page-flags.h | 39 ++++++++++++++++++++++++++++-----------
 1 file changed, 28 insertions(+), 11 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index c74b880a1b85..ac55f6c94c0a 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -163,6 +163,29 @@ static __always_inline struct page *CheckPageInit(struct page *page)
 	return page;
 }
 
+static __always_inline struct page *PagePolicyOnlyHead(struct page *page)
+{
+	CheckPageInit(page);
+	VM_BUG_ON_PGFLAGS(PageTail(page), page);
+	return page;
+}
+
+static __always_inline
+struct page *PagePolicyTailRead(struct page *page, bool modify)
+{
+	CheckPageInit(page);
+	VM_BUG_ON_PGFLAGS(modify && PageTail(page), page);
+	return compound_head(page);
+}
+
+static __always_inline
+struct page *PagePolicyNoCompound(struct page *page, bool modify)
+{
+	CheckPageInit(page);
+	VM_BUG_ON_PGFLAGS(modify && PageCompound(page), page);
+	return page;
+}
+
 /*
  * Page flag policies describe how each page flag is used for compound pages.
  *
@@ -185,17 +208,11 @@ static __always_inline struct page *CheckPageInit(struct page *page)
  * PF_NO_COMPOUND:
  *     The page flag is not used for compound pages.
  */
-#define PF_ANY(page, modify)	CheckPageInit(page)
-#define PF_HEAD(page, modify)	compound_head(CheckPageInit(page))
-#define PF_ONLY_HEAD(page, modify) ({					\
-		VM_BUG_ON_PGFLAGS(PageTail(page), page);		\
-		CheckPageInit(page); })
-#define PF_TAIL_READ(page, modify) ({					\
-		VM_BUG_ON_PGFLAGS(modify && PageTail(page), page);	\
-		compound_head(CheckPageInit(page)); })
-#define PF_NO_COMPOUND(page, modify) ({				\
-		VM_BUG_ON_PGFLAGS(modify && PageCompound(page), page);	\
-		CheckPageInit(page); })
+#define PF_ANY(page, modify)		CheckPageInit(page)
+#define PF_HEAD(page, modify)		compound_head(CheckPageInit(page))
+#define PF_ONLY_HEAD(page, modify)	PagePolicyOnlyHead(page)
+#define PF_TAIL_READ(page, modify)	PagePolicyTailRead(page, modify)
+#define PF_NO_COMPOUND(page, modify)	PagePolicyNoCompound(page, modify)
 
 /*
  * Macros to create function definitions for page flags
-- 
2.16.3
