Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 47B622802A5
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 08:19:08 -0400 (EDT)
Received: by pddu5 with SMTP id u5so17834213pdd.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 05:19:08 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id wb8si28877713pac.11.2015.07.06.05.19.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 05:19:07 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so94862889pac.2
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 05:19:07 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v5 4/7] zsmalloc: cosmetic compaction code adjustments
Date: Mon,  6 Jul 2015 21:17:47 +0900
Message-Id: <1436185070-1940-5-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436185070-1940-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436185070-1940-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey@kvack.org, "Senozhatsky <sergey.senozhatsky.work"@gmail.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Change zs_object_copy() argument order to be (DST, SRC) rather
than (SRC, DST). copy/move functions usually have (to, from)
arguments order.

Rename alloc_target_page() to isolate_target_page(). This
function doesn't allocate anything, it isolates target page,
pretty much like isolate_source_page().

Tweak __zs_compact() comment.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b7410c1..ce1484e 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1480,7 +1480,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
-static void zs_object_copy(unsigned long src, unsigned long dst,
+static void zs_object_copy(unsigned long dst, unsigned long src,
 				struct size_class *class)
 {
 	struct page *s_page, *d_page;
@@ -1621,7 +1621,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 
 		used_obj = handle_to_obj(handle);
 		free_obj = obj_malloc(d_page, class, handle);
-		zs_object_copy(used_obj, free_obj, class);
+		zs_object_copy(free_obj, used_obj, class);
 		index++;
 		record_obj(handle, free_obj);
 		unpin_tag(handle);
@@ -1637,7 +1637,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 	return ret;
 }
 
-static struct page *alloc_target_page(struct size_class *class)
+static struct page *isolate_target_page(struct size_class *class)
 {
 	int i;
 	struct page *page;
@@ -1726,11 +1726,11 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 		cc.index = 0;
 		cc.s_page = src_page;
 
-		while ((dst_page = alloc_target_page(class))) {
+		while ((dst_page = isolate_target_page(class))) {
 			cc.d_page = dst_page;
 			/*
-			 * If there is no more space in dst_page, try to
-			 * allocate another zspage.
+			 * If there is no more space in dst_page, resched
+			 * and see if anyone had allocated another zspage.
 			 */
 			if (!migrate_zspage(pool, class, &cc))
 				break;
-- 
2.5.0.rc0.3.g912bd49

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
