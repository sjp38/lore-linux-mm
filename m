Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DE0C76B0253
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 05:46:30 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so5329994pac.3
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 02:46:30 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id by2si17824617pbb.217.2015.07.11.02.46.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jul 2015 02:46:30 -0700 (PDT)
Received: by padck2 with SMTP id ck2so16101213pad.0
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 02:46:30 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 1/3] zsmalloc: factor out zs_pages_to_compact()
Date: Sat, 11 Jul 2015 18:45:30 +0900
Message-Id: <1436607932-7116-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Factor out the code that calculates how many pages compaction
can free into zs_pages_to_compact() function and export it
as zsmalloc API symbol. We still use it in zs_shrinker_count(),
just like we did before, and at the same time we now let zram
know this number (and provide it to user space) so user space
can make better assumptions about manual compaction effectiveness.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/zsmalloc.h |  1 +
 mm/zsmalloc.c            | 39 +++++++++++++++++++++++----------------
 2 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 6398dfa..8f4de78 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -53,6 +53,7 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 
 unsigned long zs_get_total_pages(struct zs_pool *pool);
 unsigned long zs_compact(struct zs_pool *pool);
+unsigned long zs_pages_to_compact(struct zs_pool *pool);
 
 void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats);
 #endif
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index c10885c..b10a228 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1798,6 +1798,28 @@ void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats)
 }
 EXPORT_SYMBOL_GPL(zs_pool_stats);
 
+unsigned long zs_pages_to_compact(struct zs_pool *pool)
+{
+	unsigned long pages_to_free = 0;
+	int i;
+	struct size_class *class;
+
+	for (i = zs_size_classes - 1; i >= 0; i--) {
+		class = pool->size_class[i];
+		if (!class)
+			continue;
+		if (class->index != i)
+			continue;
+
+		spin_lock(&class->lock);
+		pages_to_free += zs_can_compact(class);
+		spin_unlock(&class->lock);
+	}
+
+	return pages_to_free;
+}
+EXPORT_SYMBOL_GPL(zs_pages_to_compact);
+
 static unsigned long zs_shrinker_scan(struct shrinker *shrinker,
 		struct shrink_control *sc)
 {
@@ -1819,28 +1841,13 @@ static unsigned long zs_shrinker_scan(struct shrinker *shrinker,
 static unsigned long zs_shrinker_count(struct shrinker *shrinker,
 		struct shrink_control *sc)
 {
-	int i;
-	struct size_class *class;
-	unsigned long pages_to_free = 0;
 	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
 			shrinker);
 
 	if (!pool->shrinker_enabled)
 		return 0;
 
-	for (i = zs_size_classes - 1; i >= 0; i--) {
-		class = pool->size_class[i];
-		if (!class)
-			continue;
-		if (class->index != i)
-			continue;
-
-		spin_lock(&class->lock);
-		pages_to_free += zs_can_compact(class);
-		spin_unlock(&class->lock);
-	}
-
-	return pages_to_free;
+	return zs_pages_to_compact(pool);
 }
 
 static void zs_unregister_shrinker(struct zs_pool *pool)
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
