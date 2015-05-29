Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id D65FF6B0078
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:06:07 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so55627177pdb.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:07 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id am7si8796395pad.150.2015.05.29.08.06.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:06:06 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so55641332pdb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:06 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 01/10] zsmalloc: drop unused variable `nr_to_migrate'
Date: Sat, 30 May 2015 00:05:19 +0900
Message-Id: <1432911928-14654-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

__zs_compact() does not use `nr_to_migrate', drop it.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 33d5126..e615b31 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1701,7 +1701,6 @@ static struct page *isolate_source_page(struct size_class *class)
 static unsigned long __zs_compact(struct zs_pool *pool,
 				struct size_class *class)
 {
-	int nr_to_migrate;
 	struct zs_compact_control cc;
 	struct page *src_page;
 	struct page *dst_page = NULL;
@@ -1712,8 +1711,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 
 		BUG_ON(!is_first_page(src_page));
 
-		/* The goal is to migrate all live objects in source page */
-		nr_to_migrate = src_page->inuse;
 		cc.index = 0;
 		cc.s_page = src_page;
 
@@ -1728,7 +1725,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 
 			putback_zspage(pool, class, dst_page);
 			nr_total_migrated += cc.nr_migrated;
-			nr_to_migrate -= cc.nr_migrated;
 		}
 
 		/* Stop if we couldn't find slot */
-- 
2.4.2.337.gfae46aa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
