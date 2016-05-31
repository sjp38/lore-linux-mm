Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50E726B0263
	for <linux-mm@kvack.org>; Tue, 31 May 2016 19:21:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so1926219pfc.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 16:21:00 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id k74si46613974pfb.191.2016.05.31.16.20.53
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 16:20:54 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v7 09/12] zsmalloc: separate free_zspage from putback_zspage
Date: Wed,  1 Jun 2016 08:21:18 +0900
Message-Id: <1464736881-24886-10-git-send-email-minchan@kernel.org>
In-Reply-To: <1464736881-24886-1-git-send-email-minchan@kernel.org>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Currently, putback_zspage does free zspage under class->lock
if fullness become ZS_EMPTY but it makes trouble to implement
locking scheme for new zspage migration.
So, this patch is to separate free_zspage from putback_zspage
and free zspage out of class->lock which is preparation for
zspage migration.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 27 +++++++++++----------------
 1 file changed, 11 insertions(+), 16 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index c6d2cbe0f19f..dd3708611f65 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1687,14 +1687,12 @@ static struct zspage *isolate_zspage(struct size_class *class, bool source)
 
 /*
  * putback_zspage - add @zspage into right class's fullness list
- * @pool: target pool
  * @class: destination class
  * @zspage: target page
  *
  * Return @zspage's fullness_group
  */
-static enum fullness_group putback_zspage(struct zs_pool *pool,
-			struct size_class *class,
+static enum fullness_group putback_zspage(struct size_class *class,
 			struct zspage *zspage)
 {
 	enum fullness_group fullness;
@@ -1703,15 +1701,6 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 	insert_zspage(class, zspage, fullness);
 	set_zspage_mapping(zspage, class->index, fullness);
 
-	if (fullness == ZS_EMPTY) {
-		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
-			class->size, class->pages_per_zspage));
-		atomic_long_sub(class->pages_per_zspage,
-				&pool->pages_allocated);
-
-		free_zspage(pool, zspage);
-	}
-
 	return fullness;
 }
 
@@ -1760,23 +1749,29 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 			if (!migrate_zspage(pool, class, &cc))
 				break;
 
-			putback_zspage(pool, class, dst_zspage);
+			putback_zspage(class, dst_zspage);
 		}
 
 		/* Stop if we couldn't find slot */
 		if (dst_zspage == NULL)
 			break;
 
-		putback_zspage(pool, class, dst_zspage);
-		if (putback_zspage(pool, class, src_zspage) == ZS_EMPTY)
+		putback_zspage(class, dst_zspage);
+		if (putback_zspage(class, src_zspage) == ZS_EMPTY) {
+			zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
+					class->size, class->pages_per_zspage));
+			atomic_long_sub(class->pages_per_zspage,
+					&pool->pages_allocated);
+			free_zspage(pool, src_zspage);
 			pool->stats.pages_compacted += class->pages_per_zspage;
+		}
 		spin_unlock(&class->lock);
 		cond_resched();
 		spin_lock(&class->lock);
 	}
 
 	if (src_zspage)
-		putback_zspage(pool, class, src_zspage);
+		putback_zspage(class, src_zspage);
 
 	spin_unlock(&class->lock);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
