Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF0CD6B0011
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 00:31:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q11so5874440pfd.8
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 21:31:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t14-v6si7222775plm.588.2018.04.13.21.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 21:31:51 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 5/8] mm: Fix bug in page flags checking
Date: Fri, 13 Apr 2018 21:31:42 -0700
Message-Id: <20180414043145.3953-6-willy@infradead.org>
In-Reply-To: <20180414043145.3953-1-willy@infradead.org>
References: <20180414043145.3953-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

We need to check the page is initialised before we call compound_head()
on it, or we'll be checking whether the page at -2 has been initialised.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/page-flags.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index a6931046cc5c..c74b880a1b85 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -186,13 +186,13 @@ static __always_inline struct page *CheckPageInit(struct page *page)
  *     The page flag is not used for compound pages.
  */
 #define PF_ANY(page, modify)	CheckPageInit(page)
-#define PF_HEAD(page, modify)	CheckPageInit(compound_head(page))
+#define PF_HEAD(page, modify)	compound_head(CheckPageInit(page))
 #define PF_ONLY_HEAD(page, modify) ({					\
 		VM_BUG_ON_PGFLAGS(PageTail(page), page);		\
 		CheckPageInit(page); })
 #define PF_TAIL_READ(page, modify) ({					\
 		VM_BUG_ON_PGFLAGS(modify && PageTail(page), page);	\
-		CheckPageInit(compound_head(page)); })
+		compound_head(CheckPageInit(page)); })
 #define PF_NO_COMPOUND(page, modify) ({				\
 		VM_BUG_ON_PGFLAGS(modify && PageCompound(page), page);	\
 		CheckPageInit(page); })
-- 
2.16.3
