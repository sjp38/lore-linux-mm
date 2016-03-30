Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 48A056B0267
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:10:56 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fe3so33346792pab.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:10:56 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id p73si4329075pfi.213.2016.03.30.00.10.39
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 00:10:40 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 09/16] zsmalloc: move struct zs_meta from mapping to freelist
Date: Wed, 30 Mar 2016 16:12:08 +0900
Message-Id: <1459321935-3655-10-git-send-email-minchan@kernel.org>
In-Reply-To: <1459321935-3655-1-git-send-email-minchan@kernel.org>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

For supporting migration from VM, we need to have address_space
on every page so zsmalloc shouldn't use page->mapping. So,
this patch moves zs_meta from mapping to freelist.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 807998462539..d4d33a819832 100644
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
@@ -946,7 +946,6 @@ static void reset_page(struct page *page)
 	clear_bit(PG_private, &page->flags);
 	clear_bit(PG_private_2, &page->flags);
 	set_page_private(page, 0);
-	page->mapping = NULL;
 	page->freelist = NULL;
 }
 
@@ -1056,6 +1055,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 		INIT_LIST_HEAD(&page->lru);
 		if (i == 0) {	/* first page */
+			page->freelist = NULL;
 			SetPagePrivate(page);
 			set_page_private(page, 0);
 			first_page = page;
@@ -2068,9 +2068,9 @@ static int __init zs_init(void)
 
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
