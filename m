Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id A115E6B0035
	for <linux-mm@kvack.org>; Sun, 31 Aug 2014 09:33:15 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kq14so10011899pab.22
        for <linux-mm@kvack.org>; Sun, 31 Aug 2014 06:33:15 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id vu10si8564353pbc.136.2014.08.31.06.33.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 31 Aug 2014 06:33:14 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id ft15so3956317pdb.6
        for <linux-mm@kvack.org>; Sun, 31 Aug 2014 06:33:14 -0700 (PDT)
From: Wang Sheng-Hui <shhuiw@gmail.com>
Subject: [PATCH] mm: reposition zbud page in lru list if not freed in zbud_free
Date: Sun, 31 Aug 2014 21:29:29 +0800
Message-Id: <1409491769-10530-1-git-send-email-shhuiw@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjennings@variantweb.net
Cc: linux-mm@kvack.org, Wang Sheng-Hui <shhuiw@gmail.com>

Reposition zbud page in the lru list of the pool if the zbud page
is not freed in zbud_free.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/zbud.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index f26e7fc..b1d7777 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -432,15 +432,16 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 	/* Remove from existing buddy list */
 	list_del(&zhdr->buddy);
 
+	list_del(&zhdr->lru);
 	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
 		/* zbud page is empty, free */
-		list_del(&zhdr->lru);
 		free_zbud_page(zhdr);
 		pool->pages_nr--;
 	} else {
 		/* Add to unbuddied list */
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		list_add(&zhdr->lru, &pool->lru);
 	}
 
 	spin_unlock(&pool->lock);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
