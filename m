Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 988E96B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 08:36:08 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so46795410pac.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 05:36:08 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id x15si20349162pbt.57.2015.09.03.05.36.07
        for <linux-mm@kvack.org>;
        Thu, 03 Sep 2015 05:36:07 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 3/7] zsmalloc: use page->private instead of page->first_page
Date: Thu,  3 Sep 2015 15:35:54 +0300
Message-Id: <1441283758-92774-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
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
---
 mm/zsmalloc.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0a7f81aa2249..6a092de6b636 100644
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
@@ -770,7 +769,7 @@ static struct page *get_first_page(struct page *page)
 	if (is_first_page(page))
 		return page;
 	else
-		return page->first_page;
+		return (struct page *)page_private(page);
 }
 
 static struct page *get_next_page(struct page *page)
@@ -955,7 +954,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	 * Allocate individual pages and link them together as:
 	 * 1. first page->private = first sub-page
 	 * 2. all sub-pages are linked together using page->lru
-	 * 3. each sub-page is linked to the first page using page->first_page
+	 * 3. each sub-page is linked to the first page using page->private
 	 *
 	 * For each size class, First/Head pages are linked together using
 	 * page->lru. Also, we set PG_private to identify the first page
@@ -980,7 +979,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 		if (i == 1)
 			set_page_private(first_page, (unsigned long)page);
 		if (i >= 1)
-			page->first_page = first_page;
+			set_page_private(page, (unsigned long)first_page);
 		if (i >= 2)
 			list_add(&page->lru, &prev_page->lru);
 		if (i == class->pages_per_zspage - 1)	/* last page */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
