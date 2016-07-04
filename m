Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9059D828E1
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 02:51:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g62so376071104pfb.3
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 23:51:38 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id m127si2689195pfb.130.2016.07.03.23.51.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 23:51:37 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id us13so15119375pab.1
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 23:51:37 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v2 5/8] mm/zsmalloc: avoid calculate max objects of zspage twice
Date: Mon,  4 Jul 2016 14:49:56 +0800
Message-Id: <1467614999-4326-5-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

Currently, if a class can not be merged, the max objects of zspage
in that class may be calculated twice.

This patch calculate max objects of zspage at the begin, and pass
the value to can_merge() to decide whether the class can be merged.

Also this patch remove function get_maxobj_per_zspage(), as there
is no other place to call this funtion.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
----
V2:
    remove get_maxobj_per_zspage()  - Minchan
---
 mm/zsmalloc.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index ee8a29a..2c4549e 100644
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
@@ -2447,6 +2440,7 @@ struct zs_pool *zs_create_pool(const char *name)
 	for (i = zs_size_classes - 1; i >= 0; i--) {
 		int size;
 		int pages_per_zspage;
+		int objs_per_zspage;
 		struct size_class *class;
 		int fullness = 0;
 
@@ -2454,6 +2448,7 @@ struct zs_pool *zs_create_pool(const char *name)
 		if (size > ZS_MAX_ALLOC_SIZE)
 			size = ZS_MAX_ALLOC_SIZE;
 		pages_per_zspage = get_pages_per_zspage(size);
+		objs_per_zspage = pages_per_zspage * PAGE_SIZE / size;
 
 		/*
 		 * size_class is used for normal zsmalloc operation such
@@ -2465,7 +2460,7 @@ struct zs_pool *zs_create_pool(const char *name)
 		 * previous size_class if possible.
 		 */
 		if (prev_class) {
-			if (can_merge(prev_class, size, pages_per_zspage)) {
+			if (can_merge(prev_class, pages_per_zspage, objs_per_zspage)) {
 				pool->size_class[i] = prev_class;
 				continue;
 			}
@@ -2478,8 +2473,7 @@ struct zs_pool *zs_create_pool(const char *name)
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
