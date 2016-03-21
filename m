Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E84B06B0260
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 02:30:15 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id x3so253247875pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 23:30:15 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id c89si10112821pfj.79.2016.03.20.23.30.08
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 23:30:08 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 05/18] zsmalloc: remove unused pool param in obj_free
Date: Mon, 21 Mar 2016 15:30:54 +0900
Message-Id: <1458541867-27380-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1458541867-27380-1-git-send-email-minchan@kernel.org>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

Let's remove unused pool param in obj_free

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 16556a6db628..a0890e9003e2 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1438,8 +1438,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 }
 EXPORT_SYMBOL_GPL(zs_malloc);
 
-static void obj_free(struct zs_pool *pool, struct size_class *class,
-			unsigned long obj)
+static void obj_free(struct size_class *class, unsigned long obj)
 {
 	struct link_free *link;
 	struct page *first_page, *f_page;
@@ -1485,7 +1484,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	class = pool->size_class[class_idx];
 
 	spin_lock(&class->lock);
-	obj_free(pool, class, obj);
+	obj_free(class, obj);
 	fullness = fix_fullness_group(class, first_page);
 	if (fullness == ZS_EMPTY) {
 		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
@@ -1648,7 +1647,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		free_obj |= BIT(HANDLE_PIN_BIT);
 		record_obj(handle, free_obj);
 		unpin_tag(handle);
-		obj_free(pool, class, used_obj);
+		obj_free(class, used_obj);
 	}
 
 	/* Remember last position in this iteration */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
