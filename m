Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8A58E2802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 20:10:38 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so32336237pac.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:10:38 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id fj8si9975419pdb.93.2015.07.15.17.10.36
        for <linux-mm@kvack.org>;
        Wed, 15 Jul 2015 17:10:37 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2] zsmalloc: use class->pages_per_zspage
Date: Thu, 16 Jul 2015 09:10:54 +0900
Message-Id: <1437005454-3338-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

There is no need to recalcurate pages_per_zspage in runtime.
Just use class->pages_per_zspage to avoid unnecessary runtime
overhead.

* From v1
  * fix up __zs_compact - Sergey

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 27b9661c8fa6..c9685bb2bb92 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1711,7 +1711,7 @@ static unsigned long zs_can_compact(struct size_class *class)
 	obj_wasted /= get_maxobj_per_zspage(class->size,
 			class->pages_per_zspage);
 
-	return obj_wasted * get_pages_per_zspage(class->size);
+	return obj_wasted * class->pages_per_zspage;
 }
 
 static void __zs_compact(struct zs_pool *pool, struct size_class *class)
@@ -1749,8 +1749,7 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 
 		putback_zspage(pool, class, dst_page);
 		if (putback_zspage(pool, class, src_page) == ZS_EMPTY)
-			pool->stats.pages_compacted +=
-				get_pages_per_zspage(class->size);
+			pool->stats.pages_compacted += class->pages_per_zspage;
 		spin_unlock(&class->lock);
 		cond_resched();
 		spin_lock(&class->lock);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
