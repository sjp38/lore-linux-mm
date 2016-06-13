Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8861E6B0005
	for <linux-mm@kvack.org>; Sun, 12 Jun 2016 23:20:21 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id wj2so76554756obc.1
        for <linux-mm@kvack.org>; Sun, 12 Jun 2016 20:20:21 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id x187si10242061itf.66.2016.06.12.20.20.20
        for <linux-mm@kvack.org>;
        Sun, 12 Jun 2016 20:20:20 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] zsmalloc: keep first object offset in struct page
Date: Mon, 13 Jun 2016 12:20:15 +0900
Message-Id: <1465788015-23195-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

In early draft of zspage migration, we couldn't use page._mapcount
because it was used for storing movable flag so we added runtime
calculation to get first object offset in a page but it causes rather
many instruction and even bug.

Since then, we don't use page._mapcount as page flag any more so now
there is no problem to use the field to store first object offset.

Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 44 ++++++++++++++++----------------------------
 1 file changed, 16 insertions(+), 28 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 6a58edc9a015..4b70fcbfb69b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -512,6 +512,16 @@ static inline struct page *get_first_page(struct zspage *zspage)
 	return first_page;
 }
 
+static inline int get_first_obj_offset(struct page *page)
+{
+	return page->units;
+}
+
+static inline void set_first_obj_offset(struct page *page, int offset)
+{
+	page->units = offset;
+}
+
 static inline unsigned int get_freeobj(struct zspage *zspage)
 {
 	return zspage->freeobj;
@@ -872,31 +882,6 @@ static struct page *get_next_page(struct page *page)
 	return page->freelist;
 }
 
-/* Get byte offset of first object in the @page */
-static int get_first_obj_offset(struct size_class *class,
-				struct page *first_page, struct page *page)
-{
-	int pos;
-	int page_idx = 0;
-	int ofs = 0;
-	struct page *cursor = first_page;
-
-	if (first_page == page)
-		goto out;
-
-	while (page != cursor) {
-		page_idx++;
-		cursor = get_next_page(cursor);
-	}
-
-	pos = class->objs_per_zspage * class->size *
-		page_idx / class->pages_per_zspage;
-
-	ofs = (pos + class->size) % PAGE_SIZE;
-out:
-	return ofs;
-}
-
 /**
  * obj_to_location - get (<page>, <obj_idx>) from encoded object value
  * @page: page object resides in zspage
@@ -966,6 +951,7 @@ static void reset_page(struct page *page)
 	clear_bit(PG_private, &page->flags);
 	clear_bit(PG_private_2, &page->flags);
 	set_page_private(page, 0);
+	page_mapcount_reset(page);
 	ClearPageHugeObject(page);
 	page->freelist = NULL;
 }
@@ -1064,6 +1050,8 @@ static void init_zspage(struct size_class *class, struct zspage *zspage)
 		struct link_free *link;
 		void *vaddr;
 
+		set_first_obj_offset(page, off);
+
 		vaddr = kmap_atomic(page);
 		link = (struct link_free *)vaddr + off / sizeof(*link);
 
@@ -1762,9 +1750,8 @@ static unsigned long find_alloced_obj(struct size_class *class,
 	int offset = 0;
 	unsigned long handle = 0;
 	void *addr = kmap_atomic(page);
-	struct zspage *zspage = get_zspage(page);
 
-	offset = get_first_obj_offset(class, get_first_page(zspage), page);
+	offset = get_first_obj_offset(page);
 	offset += class->size * index;
 
 	while (offset < PAGE_SIZE) {
@@ -1976,6 +1963,7 @@ static void replace_sub_page(struct size_class *class, struct zspage *zspage,
 	} while ((page = get_next_page(page)) != NULL);
 
 	create_page_chain(class, zspage, pages);
+	set_first_obj_offset(newpage, get_first_obj_offset(oldpage));
 	if (unlikely(PageHugeObject(oldpage)))
 		newpage->index = oldpage->index;
 	__SetPageMovable(newpage, page_mapping(oldpage));
@@ -2062,7 +2050,7 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	get_zspage_mapping(zspage, &class_idx, &fullness);
 	pool = mapping->private_data;
 	class = pool->size_class[class_idx];
-	offset = get_first_obj_offset(class, get_first_page(zspage), page);
+	offset = get_first_obj_offset(page);
 
 	spin_lock(&class->lock);
 	if (!get_zspage_inuse(zspage)) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
