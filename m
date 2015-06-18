Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 672B16B0075
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 07:47:38 -0400 (EDT)
Received: by padev16 with SMTP id ev16so59893769pad.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 04:47:38 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id hl3si11018175pdb.148.2015.06.18.04.47.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 04:47:37 -0700 (PDT)
Received: by pabvl15 with SMTP id vl15so13754177pab.1
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 04:47:37 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv3 1/7] zsmalloc: drop unused variable `nr_to_migrate'
Date: Thu, 18 Jun 2015 20:46:38 +0900
Message-Id: <1434628004-11144-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

__zs_compact() does not use `nr_to_migrate', drop it.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0a7f81a..7d816c2 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1703,7 +1703,6 @@ static struct page *isolate_source_page(struct size_class *class)
 static unsigned long __zs_compact(struct zs_pool *pool,
 				struct size_class *class)
 {
-	int nr_to_migrate;
 	struct zs_compact_control cc;
 	struct page *src_page;
 	struct page *dst_page = NULL;
@@ -1714,8 +1713,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 
 		BUG_ON(!is_first_page(src_page));
 
-		/* The goal is to migrate all live objects in source page */
-		nr_to_migrate = src_page->inuse;
 		cc.index = 0;
 		cc.s_page = src_page;
 
@@ -1730,7 +1727,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 
 			putback_zspage(pool, class, dst_page);
 			nr_total_migrated += cc.nr_migrated;
-			nr_to_migrate -= cc.nr_migrated;
 		}
 
 		/* Stop if we couldn't find slot */
-- 
2.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
