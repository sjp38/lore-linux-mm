Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 183F96B0257
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 10:04:56 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id 18so8445272obc.2
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 07:04:56 -0800 (PST)
Received: from m50-135.163.com (m50-135.163.com. [123.125.50.135])
        by mx.google.com with ESMTP id u1si1824633obo.75.2015.12.15.07.04.54
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 07:04:55 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mm/swapfile.c: use list_for_each_entry_safe in free_swap_count_continuations
Date: Tue, 15 Dec 2015 23:04:29 +0800
Message-Id: <5f9ee783e4204a5f412a03a98a0125fcd12bc49b.1450191697.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jerome Marchand <jmarchan@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use list_for_each_entry_safe() instead of list_for_each_safe() to
simplify the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/swapfile.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 7c714c6..31dc94f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2957,11 +2957,10 @@ static void free_swap_count_continuations(struct swap_info_struct *si)
 		struct page *head;
 		head = vmalloc_to_page(si->swap_map + offset);
 		if (page_private(head)) {
-			struct list_head *this, *next;
-			list_for_each_safe(this, next, &head->lru) {
-				struct page *page;
-				page = list_entry(this, struct page, lru);
-				list_del(this);
+			struct page *page, *next;
+
+			list_for_each_entry_safe(page, next, &head->lru, lru) {
+				list_del(&page->lru);
 				__free_page(page);
 			}
 		}
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
