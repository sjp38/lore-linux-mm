Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id BB8FB6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 09:29:35 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id wq6so24419759pac.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 06:29:35 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id u77si2716911pfa.136.2015.12.16.06.29.34
        for <linux-mm@kvack.org>;
        Wed, 16 Dec 2015 06:29:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: make sure isolate_lru_page() is never called for tail page
Date: Wed, 16 Dec 2015 16:29:30 +0200
Message-Id: <1450276170-140679-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The VM_BUG_ON_PAGE() would catch such cases if any still exists.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/vmscan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 964390906167..05dd182f04fd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1436,6 +1436,7 @@ int isolate_lru_page(struct page *page)
 	int ret = -EBUSY;
 
 	VM_BUG_ON_PAGE(!page_count(page), page);
+	VM_BUG_ON_PAGE(PageTail(page), page);
 
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
