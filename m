Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B55036B0255
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 05:09:24 -0500 (EST)
Received: by padhx2 with SMTP id hx2so27527706pad.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 02:09:24 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id my1si11782640pbc.186.2015.11.11.02.09.23
        for <linux-mm@kvack.org>;
        Wed, 11 Nov 2015 02:09:23 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: fix __page_mapcount()
Date: Wed, 11 Nov 2015 12:09:17 +0200
Message-Id: <1447236557-68682-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I made mistake in uninlining patch: we need to read _mapcount of the
page which caller pointed us to, not head page.

It's fixlet for
 "mm: uninline slowpath of page_mapcount()"

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/util.c b/mm/util.c
index 22dae03a4ae1..5be2a4bdf76b 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -411,8 +411,8 @@ int __page_mapcount(struct page *page)
 {
 	int ret;
 
-	page = compound_head(page);
 	ret = atomic_read(&page->_mapcount) + 1;
+	page = compound_head(page);
 	ret += atomic_read(compound_mapcount_ptr(page)) + 1;
 	if (PageDoubleMap(page))
 		ret--;
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
