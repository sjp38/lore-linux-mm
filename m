Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id A72506B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 08:39:53 -0500 (EST)
Received: by igcto18 with SMTP id to18so31385053igc.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 05:39:53 -0800 (PST)
Received: from m50-132.163.com (m50-132.163.com. [123.125.50.132])
        by mx.google.com with ESMTP id j87si5649002ioo.210.2015.12.02.05.39.52
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 05:39:53 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mm: zbud: use list_last_entry instead of list_tail_entry
Date: Wed,  2 Dec 2015 21:38:58 +0800
Message-Id: <f7f42c0639cbb745024809a31695969b98bd027b.1449063450.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

list_last_entry has been defined in list.h, so I replace list_tail_entry
with it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/zbud.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index d8a181f..b42322e 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -463,9 +463,6 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 	spin_unlock(&pool->lock);
 }
 
-#define list_tail_entry(ptr, type, member) \
-	list_entry((ptr)->prev, type, member)
-
 /**
  * zbud_reclaim_page() - evicts allocations from a pool page and frees it
  * @pool:	pool from which a page will attempt to be evicted
@@ -514,7 +511,7 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 		return -EINVAL;
 	}
 	for (i = 0; i < retries; i++) {
-		zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
+		zhdr = list_last_entry(&pool->lru, struct zbud_header, lru);
 		list_del(&zhdr->lru);
 		list_del(&zhdr->buddy);
 		/* Protect zbud page against free */
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
