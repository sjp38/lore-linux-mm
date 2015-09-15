Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id E16056B025A
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 06:29:25 -0400 (EDT)
Received: by iofb144 with SMTP id b144so196231776iof.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 03:29:25 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ev1si30821947pbb.19.2015.09.15.03.29.24
        for <linux-mm@kvack.org>;
        Tue, 15 Sep 2015 03:29:25 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 3/7] zsmalloc: use page->private instead of page->first_page
Date: Tue, 15 Sep 2015 13:28:11 +0300
Message-Id: <1442312895-124384-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1442312895-124384-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1442312895-124384-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to rework how compound_head() work. It will not use
page->first_page as we have it now.

The only other user of page->first_page beyond compound pages is
zsmalloc.

Let's use page->private instead of page->first_page here. It occupies
the same storage space.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/zsmalloc.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f135b1b6fcdc..14fc466785da 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -16,7 +16,7 @@
  * struct page(s) to form a zspage.
  *
  * Usage of struct page fields:
- *	page->first_page: points to the first component (0-order) page
+ *	page->private: points to the first component (0-order) page
  *	page->index (union with page->freelist): offset of the first object
  *		starting in this page. For the first page, this is
  *		always 0, so we use this field (aka freelist) to point
@@ -26,8 +26,7 @@
  *
  *	For _first_ page only:
  *
- *	page->private (union with page->first_page): refers to the
- *		component page after the first page
+ *	page->private: refers to the component page after the first page
  *		If the page is first_page for huge object, it stores handle.
  *		Look at size_class->huge.
  *	page->freelist: points to the first free object in zspage.
@@ -764,7 +763,7 @@ static struct page *get_first_page(struct page *page)
 	if (is_first_page(page))
 		return page;
 	else
-		return page->first_page;
+		return (struct page *)page_private(page);
 }
 
 static struct page *get_next_page(struct page *page)
@@ -949,7 +948,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	 * Allocate individual pages and link them together as:
 	 * 1. first page->private = first sub-page
 	 * 2. all sub-pages are linked together using page->lru
-	 * 3. each sub-page is linked to the first page using page->first_page
+	 * 3. each sub-page is linked to the first page using page->private
 	 *
 	 * For each size class, First/Head pages are linked together using
 	 * page->lru. Also, we set PG_private to identify the first page
@@ -974,7 +973,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 		if (i == 1)
 			set_page_private(first_page, (unsigned long)page);
 		if (i >= 1)
-			page->first_page = first_page;
+			set_page_private(page, (unsigned long)first_page);
 		if (i >= 2)
 			list_add(&page->lru, &prev_page->lru);
 		if (i == class->pages_per_zspage - 1)	/* last page */
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
