Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 950FC6B0264
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 02:30:24 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id n5so253226338pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 23:30:24 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id sc3si21173340pac.139.2016.03.20.23.30.11
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 23:30:12 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 09/18] zsmalloc: move struct zs_meta from mapping to freelist
Date: Mon, 21 Mar 2016 15:30:58 +0900
Message-Id: <1458541867-27380-10-git-send-email-minchan@kernel.org>
In-Reply-To: <1458541867-27380-1-git-send-email-minchan@kernel.org>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

For supporting migration from VM, we need to have address_space
on every page so zsmalloc shouldn't use page->mapping. So,
this patch moves zs_meta from mapping to freelist.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0c8ccd87c084..958f27a9079d 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -29,7 +29,7 @@
  *		Look at size_class->huge.
  *	page->lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
- *	page->mapping: override by struct zs_meta
+ *	page->freelist: override by struct zs_meta
  *
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
@@ -418,7 +418,7 @@ static int get_zspage_inuse(struct page *first_page)
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	m = (struct zs_meta *)&first_page->mapping;
+	m = (struct zs_meta *)&first_page->freelist;
 
 	return m->inuse;
 }
@@ -429,7 +429,7 @@ static void set_zspage_inuse(struct page *first_page, int val)
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	m = (struct zs_meta *)&first_page->mapping;
+	m = (struct zs_meta *)&first_page->freelist;
 	m->inuse = val;
 }
 
@@ -439,7 +439,7 @@ static void mod_zspage_inuse(struct page *first_page, int val)
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	m = (struct zs_meta *)&first_page->mapping;
+	m = (struct zs_meta *)&first_page->freelist;
 	m->inuse += val;
 }
 
@@ -449,7 +449,7 @@ static void set_freeobj(struct page *first_page, int idx)
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	m = (struct zs_meta *)&first_page->mapping;
+	m = (struct zs_meta *)&first_page->freelist;
 	m->freeobj = idx;
 }
 
@@ -459,7 +459,7 @@ static unsigned long get_freeobj(struct page *first_page)
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	m = (struct zs_meta *)&first_page->mapping;
+	m = (struct zs_meta *)&first_page->freelist;
 	return m->freeobj;
 }
 
@@ -471,7 +471,7 @@ static void get_zspage_mapping(struct page *first_page,
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	m = (struct zs_meta *)&first_page->mapping;
+	m = (struct zs_meta *)&first_page->freelist;
 	*fullness = m->fullness;
 	*class_idx = m->class;
 }
@@ -484,7 +484,7 @@ static void set_zspage_mapping(struct page *first_page,
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	m = (struct zs_meta *)&first_page->mapping;
+	m = (struct zs_meta *)&first_page->freelist;
 	m->fullness = fullness;
 	m->class = class_idx;
 }
@@ -946,7 +946,7 @@ static void reset_page(struct page *page)
 	clear_bit(PG_private, &page->flags);
 	clear_bit(PG_private_2, &page->flags);
 	set_page_private(page, 0);
-	page->mapping = NULL;
+	page->freelist = NULL;
 	page_mapcount_reset(page);
 }
 
@@ -1056,6 +1056,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 		INIT_LIST_HEAD(&page->lru);
 		if (i == 0) {	/* first page */
+			page->freelist = NULL;
 			SetPagePrivate(page);
 			set_page_private(page, 0);
 			first_page = page;
@@ -2068,9 +2069,9 @@ static int __init zs_init(void)
 
 	/*
 	 * A zspage's a free object index, class index, fullness group,
-	 * inuse object count are encoded in its (first)page->mapping
+	 * inuse object count are encoded in its (first)page->freelist
 	 * so sizeof(struct zs_meta) should be less than
-	 * sizeof(page->mapping(i.e., unsigned long)).
+	 * sizeof(page->freelist(i.e., void *)).
 	 */
 	BUILD_BUG_ON(sizeof(struct zs_meta) > sizeof(unsigned long));
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
