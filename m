Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3FF26B0395
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:54:58 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id j82so189416968oih.6
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 04:54:58 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id 1si210904oie.326.2017.02.14.04.54.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Feb 2017 04:54:58 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [RFC] mm/zsmalloc: remove redundant SetPagePrivate2 in create_page_chain
Date: Tue, 14 Feb 2017 20:48:29 +0800
Message-ID: <1487076509-49270-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com

We had used page->lru to link the component pages (except the first
page) of a zspage, and used INIT_LIST_HEAD(&page->lru) to init it.
Therefore, to get the last page's next page, which is NULL, we had to
use page flag PG_Private_2 to identify it.

But now, we use page->freelist to link all of the pages in zspage and
init the page->freelist as NULL for last page, so no need to use
PG_Private_2 anymore.

This patch is to remove redundant SetPagePrivate2 in create_page_chain
and ClearPagePrivate2 in reset_page(). Maybe can save few cycles for
migration of zsmalloc page :)

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/zsmalloc.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 9cc3c0b..aa90f14 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -24,7 +24,6 @@
  *
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
- *	PG_private2: identifies the last component page
  *	PG_owner_priv_1: indentifies the huge component page
  *
  */
@@ -938,7 +937,6 @@ static void reset_page(struct page *page)
 {
 	__ClearPageMovable(page);
 	ClearPagePrivate(page);
-	ClearPagePrivate2(page);
 	set_page_private(page, 0);
 	page_mapcount_reset(page);
 	ClearPageHugeObject(page);
@@ -1085,7 +1083,7 @@ static void create_page_chain(struct size_class *class, struct zspage *zspage,
 	 * 2. each sub-page point to zspage using page->private
 	 *
 	 * we set PG_private to identify the first page (i.e. no other sub-page
-	 * has this flag set) and PG_private_2 to identify the last page.
+	 * has this flag set).
 	 */
 	for (i = 0; i < nr_pages; i++) {
 		page = pages[i];
@@ -1100,8 +1098,6 @@ static void create_page_chain(struct size_class *class, struct zspage *zspage,
 		} else {
 			prev_page->freelist = page;
 		}
-		if (i == nr_pages - 1)
-			SetPagePrivate2(page);
 		prev_page = page;
 	}
 }
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
