Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 834B7828E1
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:30:04 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id tt10so88599838pab.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 23:30:04 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id p11si11908697par.197.2016.03.10.23.29.49
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 23:29:49 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 07/19] zsmalloc: reordering function parameter
Date: Fri, 11 Mar 2016 16:30:11 +0900
Message-Id: <1457681423-26664-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1457681423-26664-1-git-send-email-minchan@kernel.org>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>, Minchan Kim <minchan@kernel.org>

This patch cleans up function parameter ordering to order
higher data structure first.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 50 ++++++++++++++++++++++++++------------------------
 1 file changed, 26 insertions(+), 24 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 3c82011cc405..156edf909046 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -564,7 +564,7 @@ static const struct file_operations zs_stat_size_ops = {
 	.release        = single_release,
 };
 
-static int zs_pool_stat_create(const char *name, struct zs_pool *pool)
+static int zs_pool_stat_create(struct zs_pool *pool, const char *name)
 {
 	struct dentry *entry;
 
@@ -604,7 +604,7 @@ static void __exit zs_stat_exit(void)
 {
 }
 
-static inline int zs_pool_stat_create(const char *name, struct zs_pool *pool)
+static inline int zs_pool_stat_create(struct zs_pool *pool, const char *name)
 {
 	return 0;
 }
@@ -650,8 +650,9 @@ static enum fullness_group get_fullness_group(struct page *first_page)
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
 
@@ -682,8 +683,9 @@ static void insert_zspage(struct page *first_page, struct size_class *class,
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
 
@@ -725,8 +727,8 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
 	if (newfg == currfg)
 		goto out;
 
-	remove_zspage(first_page, class, currfg);
-	insert_zspage(first_page, class, newfg);
+	remove_zspage(class, currfg, first_page);
+	insert_zspage(class, newfg, first_page);
 	set_zspage_mapping(first_page, class_idx, newfg);
 
 out:
@@ -910,7 +912,7 @@ static void free_zspage(struct page *first_page)
 }
 
 /* Initialize a newly allocated zspage */
-static void init_zspage(struct page *first_page, struct size_class *class)
+static void init_zspage(struct size_class *class, struct page *first_page)
 {
 	unsigned long off = 0;
 	struct page *page = first_page;
@@ -998,7 +1000,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 		prev_page = page;
 	}
 
-	init_zspage(first_page, class);
+	init_zspage(class, first_page);
 
 	first_page->freelist = location_to_obj(first_page, 0);
 	/* Maximum number of objects we can store in this zspage */
@@ -1345,8 +1347,8 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
-static unsigned long obj_malloc(struct page *first_page,
-		struct size_class *class, unsigned long handle)
+static unsigned long obj_malloc(struct size_class *class,
+				struct page *first_page, unsigned long handle)
 {
 	unsigned long obj;
 	struct link_free *link;
@@ -1423,7 +1425,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 				class->size, class->pages_per_zspage));
 	}
 
-	obj = obj_malloc(first_page, class, handle);
+	obj = obj_malloc(class, first_page, handle);
 	/* Now move the zspage to another fullness group, if required */
 	fix_fullness_group(class, first_page);
 	record_obj(handle, obj);
@@ -1496,8 +1498,8 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
-static void zs_object_copy(unsigned long dst, unsigned long src,
-				struct size_class *class)
+static void zs_object_copy(struct size_class *class, unsigned long dst,
+				unsigned long src)
 {
 	struct page *s_page, *d_page;
 	unsigned long s_objidx, d_objidx;
@@ -1563,8 +1565,8 @@ static void zs_object_copy(unsigned long dst, unsigned long src,
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
@@ -1614,7 +1616,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 	int ret = 0;
 
 	while (1) {
-		handle = find_alloced_obj(s_page, index, class);
+		handle = find_alloced_obj(class, s_page, index);
 		if (!handle) {
 			s_page = get_next_page(s_page);
 			if (!s_page)
@@ -1631,8 +1633,8 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		}
 
 		used_obj = handle_to_obj(handle);
-		free_obj = obj_malloc(d_page, class, handle);
-		zs_object_copy(free_obj, used_obj, class);
+		free_obj = obj_malloc(class, d_page, handle);
+		zs_object_copy(class, free_obj, used_obj);
 		index++;
 		/*
 		 * record_obj updates handle's value to free_obj and it will
@@ -1661,7 +1663,7 @@ static struct page *isolate_target_page(struct size_class *class)
 	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
 		page = class->fullness_list[i];
 		if (page) {
-			remove_zspage(page, class, i);
+			remove_zspage(class, i, page);
 			break;
 		}
 	}
@@ -1684,7 +1686,7 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 	enum fullness_group fullness;
 
 	fullness = get_fullness_group(first_page);
-	insert_zspage(first_page, class, fullness);
+	insert_zspage(class, fullness, first_page);
 	set_zspage_mapping(first_page, class->index, fullness);
 
 	if (fullness == ZS_EMPTY) {
@@ -1709,7 +1711,7 @@ static struct page *isolate_source_page(struct size_class *class)
 		if (!page)
 			continue;
 
-		remove_zspage(page, class, i);
+		remove_zspage(class, i, page);
 		break;
 	}
 
@@ -1943,7 +1945,7 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 
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
