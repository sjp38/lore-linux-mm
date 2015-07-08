Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id C286C6B0253
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 07:32:51 -0400 (EDT)
Received: by pddu5 with SMTP id u5so56908632pdd.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 04:32:51 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id ex7si3625831pdb.231.2015.07.08.04.32.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 04:32:50 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so130431827pac.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 04:32:50 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v7 1/7] zsmalloc: drop unused variable `nr_to_migrate'
Date: Wed,  8 Jul 2015 20:31:47 +0900
Message-Id: <1436355113-12417-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436355113-12417-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436355113-12417-1-git-send-email-sergey.senozhatsky@gmail.com>
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
index 3538b8c..2aecdb3 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1712,7 +1712,6 @@ static struct page *isolate_source_page(struct size_class *class)
 static unsigned long __zs_compact(struct zs_pool *pool,
 				struct size_class *class)
 {
-	int nr_to_migrate;
 	struct zs_compact_control cc;
 	struct page *src_page;
 	struct page *dst_page = NULL;
@@ -1723,8 +1722,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 
 		BUG_ON(!is_first_page(src_page));
 
-		/* The goal is to migrate all live objects in source page */
-		nr_to_migrate = src_page->inuse;
 		cc.index = 0;
 		cc.s_page = src_page;
 
@@ -1739,7 +1736,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 
 			putback_zspage(pool, class, dst_page);
 			nr_total_migrated += cc.nr_migrated;
-			nr_to_migrate -= cc.nr_migrated;
 		}
 
 		/* Stop if we couldn't find slot */
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
