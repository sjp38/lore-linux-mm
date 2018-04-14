Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6A756B0008
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 00:31:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a6so5913659pfn.3
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 21:31:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v12-v6si4063356plo.29.2018.04.13.21.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 21:31:51 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 8/8] mm: Optimise PagePolicyTailRead
Date: Fri, 13 Apr 2018 21:31:45 -0700
Message-Id: <20180414043145.3953-9-willy@infradead.org>
In-Reply-To: <20180414043145.3953-1-willy@infradead.org>
References: <20180414043145.3953-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Since we're checking that PageTail isn't true when we're writing to the
bits, we don't need to call compound_head() either.  This saves us four
instructions per invocation of SetPageFoo / ClearPageFoo for those bits
with a TailRead policy.
---
 include/linux/page-flags.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 1960b5e4b9ab..38ed6f4365d2 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -174,8 +174,10 @@ static __always_inline
 struct page *PagePolicyTailRead(struct page *page, bool modify)
 {
 	CheckPageInit(page);
-	VM_BUG_ON_PGFLAGS(modify && PageTail(page), page);
-	return compound_head(page);
+	if (!modify)
+		return compound_head(page);
+	VM_BUG_ON_PGFLAGS(PageTail(page), page);
+	return page;
 }
 
 static __always_inline struct page *PagePolicyNoCompound(struct page *page)
-- 
2.16.3
