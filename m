Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D37986B025F
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 02:30:13 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id n5so253220856pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 23:30:13 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k80si2341452pfb.171.2016.03.20.23.30.07
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 23:30:07 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 04/18] zsmalloc: reordering function parameter
Date: Mon, 21 Mar 2016 15:30:53 +0900
Message-Id: <1458541867-27380-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1458541867-27380-1-git-send-email-minchan@kernel.org>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

This patch cleans up function parameter ordering to order
higher data structure first.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 50 ++++++++++++++++++++++++++------------------------
 1 file changed, 26 insertions(+), 24 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 6a7b9313ee8c..16556a6db628 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -569,7 +569,7 @@ static const struct file_operations zs_stat_size_ops = {
 	.release        = single_release,
 };
 
-static int zs_pool_stat_create(const char *name, struct zs_pool *pool)
+static int zs_pool_stat_create(struct zs_pool *pool, const char *name)
 {
 	struct dentry *entry;
 
@@ -609,7 +609,7 @@ static void __exit zs_stat_exit(void)
 {
 }
 
-static inline int zs_pool_stat_create(const char *name, struct zs_pool *pool)
+static inline int zs_pool_stat_create(struct zs_pool *pool, const char *name)
 {
 	return 0;
 }
@@ -655,8 +655,9 @@ static enum fullness_group get_fullness_group(struct page *first_page)
  * have. This functions inserts the given zspage into the freelist
  * identified by <class, fullness_group>.
  */
-static void insert_zspage(struct page *first_page, struct size_class *class,
-				enum fullness_group fullness)
+static void insert_zspage(struct size_class *class,
+				enum fullness_group fullness,
+				struct page *first_page)
 {
 	struct page **head;
 
@@ -687,8 +688,9 @@ static void insert_zspage(struct page *first_page, struct size_class *class,
  * This function removes the given zspage from the freelist identified
  * by <class, fullness_group>.
  */
-static void remove_zspage(struct page *first_page, struct size_class *class,
-				enum fullness_group fullness)
+static void remove_zspage(struct size_class *class,
+				enum fullness_group fullness,
+				struct page *first_page)
 {
 	struct page **head;
 
@@ -730,8 +732,8 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
 	if (newfg == currfg)
 		goto out;
 
-	remove_zspage(first_page, class, currfg);
-	insert_zspage(first_page, class, newfg);
+	remove_zspage(class, currfg, first_page);
+	insert_zspage(class, newfg, first_page);
 	set_zspage_mapping(first_page, class_idx, newfg);
 
 out:
@@ -915,7 +917,7 @@ static void free_zspage(struct page *first_page)
 }
 
 /* Initialize a newly allocated zspage */
-static void init_zspage(struct page *first_page, struct size_class *class)
+static void init_zspage(struct size_class *class, struct page *first_page)
 {
 	unsigned long off = 0;
 	struct page *page = first_page;
@@ -1003,7 +1005,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 		prev_page = page;
 	}
 
-	init_zspage(first_page, class);
+	init_zspage(class, first_page);
 
 	first_page->freelist = location_to_obj(first_page, 0);
 	/* Maximum number of objects we can store in this zspage */
@@ -1348,8 +1350,8 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
-static unsigned long obj_malloc(struct page *first_page,
-		struct size_class *class, unsigned long handle)
+static unsigned long obj_malloc(struct size_class *class,
+				struct page *first_page, unsigned long handle)
 {
 	unsigned long obj;
 	struct link_free *link;
@@ -1426,7 +1428,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 				class->size, class->pages_per_zspage));
 	}
 
-	obj = obj_malloc(first_page, class, handle);
+	obj = obj_malloc(class, first_page, handle);
 	/* Now move the zspage to another fullness group, if required */
 	fix_fullness_group(class, first_page);
 	record_obj(handle, obj);
@@ -1499,8 +1501,8 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
-static void zs_object_copy(unsigned long dst, unsigned long src,
-				struct size_class *class)
+static void zs_object_copy(struct size_class *class, unsigned long dst,
+				unsigned long src)
 {
 	struct page *s_page, *d_page;
 	unsigned long s_objidx, d_objidx;
@@ -1566,8 +1568,8 @@ static void zs_object_copy(unsigned long dst, unsigned long src,
  * Find alloced object in zspage from index object and
  * return handle.
  */
-static unsigned long find_alloced_obj(struct page *page, int index,
-					struct size_class *class)
+static unsigned long find_alloced_obj(struct size_class *class,
+					struct page *page, int index)
 {
 	unsigned long head;
 	int offset = 0;
@@ -1617,7 +1619,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 	int ret = 0;
 
 	while (1) {
-		handle = find_alloced_obj(s_page, index, class);
+		handle = find_alloced_obj(class, s_page, index);
 		if (!handle) {
 			s_page = get_next_page(s_page);
 			if (!s_page)
@@ -1634,8 +1636,8 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		}
 
 		used_obj = handle_to_obj(handle);
-		free_obj = obj_malloc(d_page, class, handle);
-		zs_object_copy(free_obj, used_obj, class);
+		free_obj = obj_malloc(class, d_page, handle);
+		zs_object_copy(class, free_obj, used_obj);
 		index++;
 		/*
 		 * record_obj updates handle's value to free_obj and it will
@@ -1664,7 +1666,7 @@ static struct page *isolate_target_page(struct size_class *class)
 	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
 		page = class->fullness_list[i];
 		if (page) {
-			remove_zspage(page, class, i);
+			remove_zspage(class, i, page);
 			break;
 		}
 	}
@@ -1687,7 +1689,7 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 	enum fullness_group fullness;
 
 	fullness = get_fullness_group(first_page);
-	insert_zspage(first_page, class, fullness);
+	insert_zspage(class, fullness, first_page);
 	set_zspage_mapping(first_page, class->index, fullness);
 
 	if (fullness == ZS_EMPTY) {
@@ -1712,7 +1714,7 @@ static struct page *isolate_source_page(struct size_class *class)
 		if (!page)
 			continue;
 
-		remove_zspage(page, class, i);
+		remove_zspage(class, i, page);
 		break;
 	}
 
@@ -1946,7 +1948,7 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 
 	pool->flags = flags;
 
-	if (zs_pool_stat_create(name, pool))
+	if (zs_pool_stat_create(pool, name))
 		goto err;
 
 	/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
