Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 016BC6B0256
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 07:33:04 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so130434764pac.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 04:33:03 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id ce3si3644444pbb.150.2015.07.08.04.33.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 04:33:02 -0700 (PDT)
Received: by pacws9 with SMTP id ws9so131860987pac.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 04:33:02 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v7 4/7] zsmalloc: cosmetic compaction code adjustments
Date: Wed,  8 Jul 2015 20:31:50 +0900
Message-Id: <1436355113-12417-5-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436355113-12417-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436355113-12417-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

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
index 30f0463..7ed726a 100644
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
@@ -1727,11 +1727,11 @@ static unsigned long __zs_compact(struct zs_pool *pool,
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
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
