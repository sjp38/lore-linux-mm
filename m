Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9A77C6B0267
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 02:30:28 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id n5so253228300pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 23:30:28 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id k74si6178524pfb.30.2016.03.20.23.30.13
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 23:30:14 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 11/18] zsmalloc: separate free_zspage from putback_zspage
Date: Mon, 21 Mar 2016 15:31:00 +0900
Message-Id: <1458541867-27380-12-git-send-email-minchan@kernel.org>
In-Reply-To: <1458541867-27380-1-git-send-email-minchan@kernel.org>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

Currently, putback_zspage does free zspage under class->lock
if fullness become ZS_EMPTY but it makes trouble to implement
locking scheme for new zspage migration.
So, this patch is to separate free_zspage from putback_zspage
and free zspage out of class->lock which is preparation for
zspage migration.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 833da8f4ffc9..9c0ab1e92e9b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -950,7 +950,8 @@ static void reset_page(struct page *page)
 	page_mapcount_reset(page);
 }
 
-static void free_zspage(struct page *first_page)
+static void free_zspage(struct zs_pool *pool, struct size_class *class,
+			struct page *first_page)
 {
 	struct page *nextp, *tmp, *head_extra;
 
@@ -973,6 +974,11 @@ static void free_zspage(struct page *first_page)
 	}
 	reset_page(head_extra);
 	__free_page(head_extra);
+
+	zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
+			class->size, class->pages_per_zspage));
+	atomic_long_sub(class->pages_per_zspage,
+				&pool->pages_allocated);
 }
 
 /* Initialize a newly allocated zspage */
@@ -1560,13 +1566,8 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	spin_lock(&class->lock);
 	obj_free(class, obj);
 	fullness = fix_fullness_group(class, first_page);
-	if (fullness == ZS_EMPTY) {
-		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
-				class->size, class->pages_per_zspage));
-		atomic_long_sub(class->pages_per_zspage,
-				&pool->pages_allocated);
-		free_zspage(first_page);
-	}
+	if (fullness == ZS_EMPTY)
+		free_zspage(pool, class, first_page);
 	spin_unlock(&class->lock);
 	unpin_tag(handle);
 
@@ -1753,7 +1754,7 @@ static struct page *isolate_target_page(struct size_class *class)
  * @class: destination class
  * @first_page: target page
  *
- * Return @fist_page's fullness_group
+ * Return @first_page's updated fullness_group
  */
 static enum fullness_group putback_zspage(struct zs_pool *pool,
 			struct size_class *class,
@@ -1765,15 +1766,6 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 	insert_zspage(class, fullness, first_page);
 	set_zspage_mapping(first_page, class->index, fullness);
 
-	if (fullness == ZS_EMPTY) {
-		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
-			class->size, class->pages_per_zspage));
-		atomic_long_sub(class->pages_per_zspage,
-				&pool->pages_allocated);
-
-		free_zspage(first_page);
-	}
-
 	return fullness;
 }
 
@@ -1836,23 +1828,31 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 			if (!migrate_zspage(pool, class, &cc))
 				break;
 
-			putback_zspage(pool, class, dst_page);
+			VM_BUG_ON_PAGE(putback_zspage(pool, class,
+				dst_page) == ZS_EMPTY, dst_page);
 		}
 
 		/* Stop if we couldn't find slot */
 		if (dst_page == NULL)
 			break;
 
-		putback_zspage(pool, class, dst_page);
-		if (putback_zspage(pool, class, src_page) == ZS_EMPTY)
+		VM_BUG_ON_PAGE(putback_zspage(pool, class,
+				dst_page) == ZS_EMPTY, dst_page);
+		if (putback_zspage(pool, class, src_page) == ZS_EMPTY) {
 			pool->stats.pages_compacted += class->pages_per_zspage;
-		spin_unlock(&class->lock);
+			spin_unlock(&class->lock);
+			free_zspage(pool, class, src_page);
+		} else {
+			spin_unlock(&class->lock);
+		}
+
 		cond_resched();
 		spin_lock(&class->lock);
 	}
 
 	if (src_page)
-		putback_zspage(pool, class, src_page);
+		VM_BUG_ON_PAGE(putback_zspage(pool, class,
+				src_page) == ZS_EMPTY, src_page);
 
 	spin_unlock(&class->lock);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
