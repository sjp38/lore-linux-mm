Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2D26B0256
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 03:12:40 -0400 (EDT)
Received: by pawu10 with SMTP id u10so134067307paw.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 00:12:40 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id km1si1981325pdb.43.2015.08.10.00.12.34
        for <linux-mm@kvack.org>;
        Mon, 10 Aug 2015 00:12:35 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC zsmalloc 4/4] zsmalloc: move struct zs_meta from mapping to somewhere
Date: Mon, 10 Aug 2015 16:12:23 +0900
Message-Id: <1439190743-13933-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1439190743-13933-1-git-send-email-minchan@kernel.org>
References: <1439190743-13933-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: gioh.kim@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

For supporting runtime compaction with VM, we need to have proper
address_space on every page so zsmalloc shouldn't use page->mapping.

This patch moves zsmalloc metadata from mapping to freelist.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 55dc066..1b18144 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -30,7 +30,7 @@
  *		Look at size_class->huge.
  *	page->lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
- *	page->mapping: override by struct zs_meta
+ *	page->freelist: override by struct zs_meta
  *
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
@@ -261,7 +261,7 @@ struct zs_pool {
 
 /*
  * In this implementation, a free_idx, zspage's class index, fullness group,
- * inuse object count are encoded in its (first)page->mapping
+ * inuse object count are encoded in its (first)page->freelist
  * sizeof(struct zs_meta) should be equal to sizeof(unsigned long).
  */
 struct zs_meta {
@@ -414,7 +414,7 @@ static int get_inuse_obj(struct page *page)
 
 	BUG_ON(!is_first_page(page));
 
-	m = (struct zs_meta *)&page->mapping;
+	m = (struct zs_meta *)&page->freelist;
 
 	return m->inuse;
 }
@@ -425,19 +425,19 @@ static void set_inuse_obj(struct page *page, int inc)
 
 	BUG_ON(!is_first_page(page));
 
-	m = (struct zs_meta *)&page->mapping;
+	m = (struct zs_meta *)&page->freelist;
 	m->inuse += inc;
 }
 
 static void set_free_obj_idx(struct page *first_page, int idx)
 {
-	struct zs_meta *m = (struct zs_meta *)&first_page->mapping;
+	struct zs_meta *m = (struct zs_meta *)&first_page->freelist;
 	m->free_idx = idx;
 }
 
 static unsigned long get_free_obj_idx(struct page *first_page)
 {
-	struct zs_meta *m = (struct zs_meta *)&first_page->mapping;
+	struct zs_meta *m = (struct zs_meta *)&first_page->freelist;
 	return m->free_idx;
 }
 
@@ -447,7 +447,7 @@ static void get_zspage_mapping(struct page *page, unsigned int *class_idx,
 	struct zs_meta *m;
 	BUG_ON(!is_first_page(page));
 
-	m = (struct zs_meta *)&page->mapping;
+	m = (struct zs_meta *)&page->freelist;
 	*fullness = m->fullness;
 	*class_idx = m->class_idx;
 }
@@ -462,7 +462,7 @@ static void set_zspage_mapping(struct page *page, unsigned int class_idx,
 	BUG_ON(class_idx >= (1 << CLASS_IDX_BITS));
 	BUG_ON(fullness >= (1 << FULLNESS_BITS));
 
-	m = (struct zs_meta *)&page->mapping;
+	m = (struct zs_meta *)&page->freelist;
 	m->fullness = fullness;
 	m->class_idx = class_idx;
 }
@@ -908,7 +908,7 @@ static void reset_page(struct page *page)
 	clear_bit(PG_private, &page->flags);
 	clear_bit(PG_private_2, &page->flags);
 	set_page_private(page, 0);
-	page->mapping = NULL;
+	page->freelist = NULL;
 	page_mapcount_reset(page);
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
