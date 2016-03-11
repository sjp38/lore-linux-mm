Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id BEF02828DF
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:38:01 -0500 (EST)
Received: by mail-io0-f173.google.com with SMTP id g203so135617259iof.2
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 23:38:01 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id p37si9709135ioi.58.2016.03.10.23.29.54
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 23:29:55 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 17/19] zsmalloc: use single linked list for page chain
Date: Fri, 11 Mar 2016 16:30:21 +0900
Message-Id: <1457681423-26664-18-git-send-email-minchan@kernel.org>
In-Reply-To: <1457681423-26664-1-git-send-email-minchan@kernel.org>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>, Minchan Kim <minchan@kernel.org>

For tail page migration, we shouldn't use page->lru which
was used for page chaining because VM will use it for own
purpose so that we need another field for chaining.
For chaining, singly linked list is enough and page->index
of tail page to point first object offset in the page could
be replaced in run-time calculation.

So, this patch change page->lru list for chaining with singly
linked list via page->freelist squeeze and introduces
get_first_obj_ofs to get first object offset in a page.

With that, it could maintain page chaining without using
page->lru.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 119 ++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 78 insertions(+), 41 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 8eb785000069..24d8dd1fc749 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -17,10 +17,7 @@
  *
  * Usage of struct page fields:
  *	page->private: points to the first component (0-order) page
- *	page->index (union with page->freelist): offset of the first object
- *		starting in this page.
- *	page->lru: links together all component pages (except the first page)
- *		of a zspage
+ *	page->index (union with page->freelist): override by struct zs_meta
  *
  *	For _first_ page only:
  *
@@ -269,10 +266,19 @@ struct zs_pool {
 };
 
 struct zs_meta {
-	unsigned long freeobj:FREEOBJ_BITS;
-	unsigned long class:CLASS_BITS;
-	unsigned long fullness:FULLNESS_BITS;
-	unsigned long inuse:INUSE_BITS;
+	union {
+		/* first page */
+		struct {
+			unsigned long freeobj:FREEOBJ_BITS;
+			unsigned long class:CLASS_BITS;
+			unsigned long fullness:FULLNESS_BITS;
+			unsigned long inuse:INUSE_BITS;
+		};
+		/* tail pages */
+		struct {
+			struct page *next;
+		};
+	};
 };
 
 struct mapping_area {
@@ -490,6 +496,34 @@ static unsigned long get_freeobj(struct page *first_page)
 	return m->freeobj;
 }
 
+static void set_next_page(struct page *page, struct page *next)
+{
+	struct zs_meta *m;
+
+	VM_BUG_ON_PAGE(is_first_page(page), page);
+
+	m = (struct zs_meta *)&page->index;
+	m->next = next;
+}
+
+static struct page *get_next_page(struct page *page)
+{
+	struct page *next;
+
+	if (is_last_page(page))
+		next = NULL;
+	else if (is_first_page(page))
+		next = (struct page *)page_private(page);
+	else {
+		struct zs_meta *m = (struct zs_meta *)&page->index;
+
+		VM_BUG_ON(!m->next);
+		next = m->next;
+	}
+
+	return next;
+}
+
 static void get_zspage_mapping(struct page *first_page,
 				unsigned int *class_idx,
 				enum fullness_group *fullness)
@@ -864,18 +898,30 @@ static struct page *get_first_page(struct page *page)
 		return (struct page *)page_private(page);
 }
 
-static struct page *get_next_page(struct page *page)
+int get_first_obj_ofs(struct size_class *class, struct page *first_page,
+			struct page *page)
 {
-	struct page *next;
+	int pos, bound;
+	int page_idx = 0;
+	int ofs = 0;
+	struct page *cursor = first_page;
 
-	if (is_last_page(page))
-		next = NULL;
-	else if (is_first_page(page))
-		next = (struct page *)page_private(page);
-	else
-		next = list_entry(page->lru.next, struct page, lru);
+	if (first_page == page)
+		goto out;
 
-	return next;
+	while (page != cursor) {
+		page_idx++;
+		cursor = get_next_page(cursor);
+	}
+
+	bound = PAGE_SIZE * page_idx;
+	pos = (((class->objs_per_zspage * class->size) *
+		page_idx / class->pages_per_zspage) / class->size
+		) * class->size;
+
+	ofs = (pos + class->size) % PAGE_SIZE;
+out:
+	return ofs;
 }
 
 static void objidx_to_page_and_ofs(struct size_class *class,
@@ -1001,27 +1047,25 @@ void lock_zspage(struct page *first_page)
 
 static void free_zspage(struct zs_pool *pool, struct page *first_page)
 {
-	struct page *nextp, *tmp, *head_extra;
+	struct page *nextp, *tmp;
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 	VM_BUG_ON_PAGE(get_zspage_inuse(first_page), first_page);
 
 	lock_zspage(first_page);
-	head_extra = (struct page *)page_private(first_page);
+	nextp = (struct page *)page_private(first_page);
 
 	/* zspage with only 1 system page */
-	if (!head_extra)
+	if (!nextp)
 		goto out;
 
-	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
-		list_del(&nextp->lru);
-		reset_page(nextp);
-		unlock_page(nextp);
-		__free_page(nextp);
-	}
-	reset_page(head_extra);
-	unlock_page(head_extra);
-	__free_page(head_extra);
+	do {
+		tmp = nextp;
+		nextp = get_next_page(nextp);
+		reset_page(tmp);
+		unlock_page(tmp);
+		__free_page(tmp);
+	} while (nextp);
 out:
 	reset_page(first_page);
 	unlock_page(first_page);
@@ -1049,13 +1093,6 @@ static void init_zspage(struct size_class *class, struct page *first_page,
 		struct link_free *link;
 		void *vaddr;
 
-		/*
-		 * page->index stores offset of first object starting
-		 * in the page.
-		 */
-		if (page != first_page)
-			page->index = off;
-
 		vaddr = kmap_atomic(page);
 		link = (struct link_free *)vaddr + off / sizeof(*link);
 
@@ -1097,7 +1134,6 @@ static void create_page_chain(struct page *pages[], int nr_pages)
 	for (i = 0; i < nr_pages; i++) {
 		page = pages[i];
 
-		INIT_LIST_HEAD(&page->lru);
 		if (i == 0) {
 			SetPagePrivate(page);
 			set_page_private(page, 0);
@@ -1106,10 +1142,12 @@ static void create_page_chain(struct page *pages[], int nr_pages)
 
 		if (i == 1)
 			set_page_private(first_page, (unsigned long)page);
-		if (i >= 1)
+		if (i >= 1) {
+			set_next_page(page, NULL);
 			set_page_private(page, (unsigned long)first_page);
+		}
 		if (i >= 2)
-			list_add(&page->lru, &prev_page->lru);
+			set_next_page(prev_page, page);
 		if (i == nr_pages - 1)
 			SetPagePrivate2(page);
 
@@ -2236,8 +2274,7 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	kunmap_atomic(d_addr);
 	kunmap_atomic(s_addr);
 
-	if (!is_first_page(page))
-		offset = page->index;
+	offset = get_first_obj_ofs(class, first_page, page);
 
 	addr = kmap_atomic(page);
 	do {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
