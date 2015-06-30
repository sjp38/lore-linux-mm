Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id CC7856B0071
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 08:36:53 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so5696661pdb.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:36:53 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id qe2si22520524pab.128.2015.06.30.05.36.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 05:36:52 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so5053354pac.2
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:36:52 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv4 1/7] zsmalloc: drop unused variable `nr_to_migrate'
Date: Tue, 30 Jun 2015 21:35:52 +0900
Message-Id: <1435667758-14075-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
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
2.5.0.rc0.3.g912bd49

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
