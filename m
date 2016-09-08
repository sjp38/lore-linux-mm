Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 772F76B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 04:21:43 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so88085406pad.2
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 01:21:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id rb9si41717550pab.84.2016.09.08.01.21.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 01:21:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: avoid endless recursion in dump_page()
Date: Thu,  8 Sep 2016 11:21:37 +0300
Message-Id: <20160908082137.131076-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

dump_page() uses page_mapcount() to get mapcount of the page.
page_mapcount() has VM_BUG_ON_PAGE(PageSlab(page)) as mapcount doesn't
make sense for slab pages and the field in struct page used for other
information.

It leads to recursion if dump_page() called for slub page and DEBUG_VM
is enabled:

dump_page() -> page_mapcount() -> VM_BUG_ON_PAGE() -> dump_page -> ...

Let's avoid calling page_mapcount() for slab pages in dump_page().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/debug.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index 8865bfb41b0b..74c7cae4f683 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -42,9 +42,11 @@ const struct trace_print_flags vmaflag_names[] = {
 
 void __dump_page(struct page *page, const char *reason)
 {
+	int mapcount = PageSlab(page) ? 0 : page_mapcount(page);
+
 	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
-		  page, page_ref_count(page), page_mapcount(page),
-		  page->mapping, page->index);
+		  page, page_ref_count(page), mapcount,
+		  page->mapping, page_to_pgoff(page));
 	if (PageCompound(page))
 		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
 	pr_cont("\n");
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
