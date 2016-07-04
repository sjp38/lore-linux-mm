Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4114828E1
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 02:51:31 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id he1so329742983pac.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 23:51:31 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id m6si2485868pfc.281.2016.07.03.23.51.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 23:51:31 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id c74so15678483pfb.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 23:51:31 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v2 4/8] mm/zsmalloc: use class->objs_per_zspage to get num of max objects
Date: Mon,  4 Jul 2016 14:49:55 +0800
Message-Id: <1467614999-4326-4-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

num of max objects in zspage is stored in each size_class now.
So there is no need to re-calculate it.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 92b043c..ee8a29a 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -638,8 +638,7 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 		freeable = zs_can_compact(class);
 		spin_unlock(&class->lock);
 
-		objs_per_zspage = get_maxobj_per_zspage(class->size,
-				class->pages_per_zspage);
+		objs_per_zspage = class->objs_per_zspage;
 		pages_used = obj_allocated / objs_per_zspage *
 				class->pages_per_zspage;
 
@@ -1017,8 +1016,7 @@ static void __free_zspage(struct zs_pool *pool, struct size_class *class,
 
 	cache_free_zspage(pool, zspage);
 
-	zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
-			class->size, class->pages_per_zspage));
+	zs_stat_dec(class, OBJ_ALLOCATED, class->objs_per_zspage);
 	atomic_long_sub(class->pages_per_zspage,
 					&pool->pages_allocated);
 }
@@ -1369,7 +1367,7 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 	if (prev->pages_per_zspage != pages_per_zspage)
 		return false;
 
-	if (get_maxobj_per_zspage(prev->size, prev->pages_per_zspage)
+	if (prev->objs_per_zspage
 		!= get_maxobj_per_zspage(size, pages_per_zspage))
 		return false;
 
@@ -1595,8 +1593,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t gfp)
 	record_obj(handle, obj);
 	atomic_long_add(class->pages_per_zspage,
 				&pool->pages_allocated);
-	zs_stat_inc(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
-			class->size, class->pages_per_zspage));
+	zs_stat_inc(class, OBJ_ALLOCATED, class->objs_per_zspage);
 
 	/* We completely set up zspage so mark them as movable */
 	SetZsPageMovable(pool, zspage);
@@ -2268,8 +2265,7 @@ static unsigned long zs_can_compact(struct size_class *class)
 		return 0;
 
 	obj_wasted = obj_allocated - obj_used;
-	obj_wasted /= get_maxobj_per_zspage(class->size,
-			class->pages_per_zspage);
+	obj_wasted /= class->objs_per_zspage;
 
 	return obj_wasted * class->pages_per_zspage;
 }
@@ -2482,8 +2478,8 @@ struct zs_pool *zs_create_pool(const char *name)
 		class->size = size;
 		class->index = i;
 		class->pages_per_zspage = pages_per_zspage;
-		class->objs_per_zspage = class->pages_per_zspage *
-						PAGE_SIZE / class->size;
+		class->objs_per_zspage = get_maxobj_per_zspage(class->size,
+							class->pages_per_zspage);
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
