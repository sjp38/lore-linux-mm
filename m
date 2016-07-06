Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECBAD828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 02:26:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 143so492818120pfx.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:26:23 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id 2si2479981pfu.115.2016.07.05.23.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 23:26:23 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id ib6so4220692pad.3
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:26:23 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v3 4/8] mm/zsmalloc: avoid calculate max objects of zspage twice
Date: Wed,  6 Jul 2016 14:23:49 +0800
Message-Id: <1467786233-4481-4-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467786233-4481-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467786233-4481-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

Currently, if a class can not be merged, the max objects of zspage
in that class may be calculated twice.

This patch calculate max objects of zspage at the begin, and pass
the value to can_merge() to decide whether the class can be merged.

Also this patch remove function get_maxobj_per_zspage(), as there
is no other place to call this function.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
----
v3:
    none
v2:
    remove get_maxobj_per_zspage()  - Minchan
---
 mm/zsmalloc.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 82ff2c0..82b9977 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -470,11 +470,6 @@ static struct zpool_driver zs_zpool_driver = {
 MODULE_ALIAS("zpool-zsmalloc");
 #endif /* CONFIG_ZPOOL */
 
-static unsigned int get_maxobj_per_zspage(int size, int pages_per_zspage)
-{
-	return pages_per_zspage * PAGE_SIZE / size;
-}
-
 /* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
 static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
 
@@ -1362,16 +1357,14 @@ static void init_zs_size_classes(void)
 	zs_size_classes = nr;
 }
 
-static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
+static bool can_merge(struct size_class *prev, int pages_per_zspage,
+					int objs_per_zspage)
 {
-	if (prev->pages_per_zspage != pages_per_zspage)
-		return false;
+	if (prev->pages_per_zspage == pages_per_zspage &&
+		prev->objs_per_zspage == objs_per_zspage)
+		return true;
 
-	if (prev->objs_per_zspage
-		!= get_maxobj_per_zspage(size, pages_per_zspage))
-		return false;
-
-	return true;
+	return false;
 }
 
 static bool zspage_full(struct size_class *class, struct zspage *zspage)
@@ -2448,6 +2441,7 @@ struct zs_pool *zs_create_pool(const char *name)
 	for (i = zs_size_classes - 1; i >= 0; i--) {
 		int size;
 		int pages_per_zspage;
+		int objs_per_zspage;
 		struct size_class *class;
 		int fullness = 0;
 
@@ -2455,6 +2449,7 @@ struct zs_pool *zs_create_pool(const char *name)
 		if (size > ZS_MAX_ALLOC_SIZE)
 			size = ZS_MAX_ALLOC_SIZE;
 		pages_per_zspage = get_pages_per_zspage(size);
+		objs_per_zspage = pages_per_zspage * PAGE_SIZE / size;
 
 		/*
 		 * size_class is used for normal zsmalloc operation such
@@ -2466,7 +2461,7 @@ struct zs_pool *zs_create_pool(const char *name)
 		 * previous size_class if possible.
 		 */
 		if (prev_class) {
-			if (can_merge(prev_class, size, pages_per_zspage)) {
+			if (can_merge(prev_class, pages_per_zspage, objs_per_zspage)) {
 				pool->size_class[i] = prev_class;
 				continue;
 			}
@@ -2479,8 +2474,7 @@ struct zs_pool *zs_create_pool(const char *name)
 		class->size = size;
 		class->index = i;
 		class->pages_per_zspage = pages_per_zspage;
-		class->objs_per_zspage = get_maxobj_per_zspage(class->size,
-							class->pages_per_zspage);
+		class->objs_per_zspage = objs_per_zspage;
 		spin_lock_init(&class->lock);
 		pool->size_class[i] = class;
 		for (fullness = ZS_EMPTY; fullness < NR_ZS_FULLNESS;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
