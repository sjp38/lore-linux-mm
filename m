Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B61E682F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 06:52:03 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id e65so15258131pfe.1
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 03:52:03 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id w22si26712649pfi.253.2015.12.24.03.51.58
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 03:51:59 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/4] thp: increase split_huge_page() success rate
Date: Thu, 24 Dec 2015 14:51:23 +0300
Message-Id: <1450957883-96356-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

During freeze_page(), we remove the page from rmap. It munlocks the page
if it was mlocked. clear_page_mlock() uses of lru cache, which temporary
pins page.

Let's drain the lru cache before checking page's count vs. mapcount.
The change makes mlocked page split on first attempt, if it was not
pinned by somebody else.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1a988d9b86ef..4c1c292b7ddd 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3417,6 +3417,9 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	freeze_page(anon_vma, head);
 	VM_BUG_ON_PAGE(compound_mapcount(head), head);
 
+	/* Make sure the page is not on per-CPU pagevec as it takes pin */
+	lru_add_drain();
+
 	/* Prevent deferred_split_scan() touching ->_count */
 	spin_lock(&split_queue_lock);
 	count = page_count(head);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
