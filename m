Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 90E786B0071
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 07:59:57 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id p10so7432897pdj.15
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 04:59:57 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id hh5si4219864pbc.151.2014.10.14.04.59.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 14 Oct 2014 04:59:55 -0700 (PDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDF008XYNZS2110@mailout4.samsung.com> for linux-mm@kvack.org;
 Tue, 14 Oct 2014 20:59:52 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [RFC PATCH 2/9] mm/zbud: remove buddied list from zbud_pool
Date: Tue, 14 Oct 2014 20:59:21 +0900
Message-id: <1413287968-13940-3-git-send-email-heesub.shin@samsung.com>
In-reply-to: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
References: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub.shin@samsung.com>

There's no point in having the _buddied_ list of zbud_pages, as nobody
refers it. Tracking it adds runtime overheads only, so let's remove it.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
---
 mm/zbud.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 6f36394..0f5add0 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -79,8 +79,6 @@
  * @unbuddied:	array of lists tracking zbud pages that only contain one buddy;
  *		the lists each zbud page is added to depends on the size of
  *		its free region.
- * @buddied:	list tracking the zbud pages that contain two buddies;
- *		these zbud pages are full
  * @lru:	list tracking the zbud pages in LRU order by most recently
  *		added buddy.
  * @pages_nr:	number of zbud pages in the pool.
@@ -93,7 +91,6 @@
 struct zbud_pool {
 	spinlock_t lock;
 	struct list_head unbuddied[NCHUNKS];
-	struct list_head buddied;
 	struct list_head lru;
 	u64 pages_nr;
 	struct zbud_ops *ops;
@@ -102,7 +99,7 @@ struct zbud_pool {
 /*
  * struct zbud_header - zbud page metadata occupying the first chunk of each
  *			zbud page.
- * @buddy:	links the zbud page into the unbuddied/buddied lists in the pool
+ * @buddy:	links the zbud page into the unbuddied lists in the pool
  * @lru:	links the zbud page into the lru list in the pool
  * @first_chunks:	the size of the first buddy in chunks, 0 if free
  * @last_chunks:	the size of the last buddy in chunks, 0 if free
@@ -299,7 +296,6 @@ struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
 	spin_lock_init(&pool->lock);
 	for_each_unbuddied_list(i, 0)
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
-	INIT_LIST_HEAD(&pool->buddied);
 	INIT_LIST_HEAD(&pool->lru);
 	pool->pages_nr = 0;
 	pool->ops = ops;
@@ -383,9 +379,6 @@ found:
 		/* Add to unbuddied list */
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
-	} else {
-		/* Add to buddied list */
-		list_add(&zhdr->buddy, &pool->buddied);
 	}
 
 	/* Add/move zbud page to beginning of LRU */
@@ -429,10 +422,9 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 		return;
 	}
 
-	/* Remove from existing buddy list */
-	list_del(&zhdr->buddy);
-
 	if (num_free_chunks(zhdr) == NCHUNKS) {
+		/* Remove from existing unbuddied list */
+		list_del(&zhdr->buddy);
 		/* zbud page is empty, free */
 		list_del(&zhdr->lru);
 		free_zbud_page(zhdr);
@@ -542,9 +534,6 @@ next:
 			/* add to unbuddied list */
 			freechunks = num_free_chunks(zhdr);
 			list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
-		} else {
-			/* add to buddied list */
-			list_add(&zhdr->buddy, &pool->buddied);
 		}
 
 		/* add to beginning of LRU */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
