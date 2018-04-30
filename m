Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id ACD486B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 06:58:05 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b132-v6so2601995lfe.21
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 03:58:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n3-v6sor1305272lji.56.2018.04.30.03.58.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 03:58:03 -0700 (PDT)
Date: Mon, 30 Apr 2018 12:58:00 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] z3fold: fix reclaim lock-ups
Message-Id: <20180430125800.444cae9706489f412ad12621@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Linux-MM <linux-mm@kvack.org>
Cc: Oleksiy.Avramchenko@sony.com, Matthew Wilcox <mawilcox@microsoft.com>, stable@kernel.org

Do not try to optimize in-page object layout while the page is
under reclaim. This fixes lock-ups on reclaim and improves reclaim
performance at the same time.

Reported-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
---
 mm/z3fold.c | 42 ++++++++++++++++++++++++++++++------------
 1 file changed, 30 insertions(+), 12 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index c0bca6153b95..901c0b07cbda 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -144,7 +144,8 @@ enum z3fold_page_flags {
 	PAGE_HEADLESS = 0,
 	MIDDLE_CHUNK_MAPPED,
 	NEEDS_COMPACTING,
-	PAGE_STALE
+	PAGE_STALE,
+	UNDER_RECLAIM
 };
 
 /*****************
@@ -173,6 +174,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page,
 	clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
 	clear_bit(NEEDS_COMPACTING, &page->private);
 	clear_bit(PAGE_STALE, &page->private);
+	clear_bit(UNDER_RECLAIM, &page->private);
 
 	spin_lock_init(&zhdr->page_lock);
 	kref_init(&zhdr->refcount);
@@ -756,6 +758,10 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		atomic64_dec(&pool->pages_nr);
 		return;
 	}
+	if (test_bit(UNDER_RECLAIM, &page->private)) {
+		z3fold_page_unlock(zhdr);
+		return;
+	}
 	if (test_and_set_bit(NEEDS_COMPACTING, &page->private)) {
 		z3fold_page_unlock(zhdr);
 		return;
@@ -840,6 +846,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			kref_get(&zhdr->refcount);
 			list_del_init(&zhdr->buddy);
 			zhdr->cpu = -1;
+			set_bit(UNDER_RECLAIM, &page->private);
+			break;
 		}
 
 		list_del_init(&page->lru);
@@ -887,25 +895,35 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				goto next;
 		}
 next:
-		spin_lock(&pool->lock);
 		if (test_bit(PAGE_HEADLESS, &page->private)) {
 			if (ret == 0) {
-				spin_unlock(&pool->lock);
 				free_z3fold_page(page);
 				return 0;
 			}
-		} else if (kref_put(&zhdr->refcount, release_z3fold_page)) {
-			atomic64_dec(&pool->pages_nr);
+			spin_lock(&pool->lock);
+			list_add(&page->lru, &pool->lru);
+			spin_unlock(&pool->lock);
+		} else {
+			z3fold_page_lock(zhdr);
+			clear_bit(UNDER_RECLAIM, &page->private);
+			 if (kref_put(&zhdr->refcount,
+					release_z3fold_page_locked)) {
+				atomic64_dec(&pool->pages_nr);
+				return 0;
+			}
+			/*
+			 * if we are here, the page is still not completely
+			 * free. Take the global pool lock then to be able
+			 * to add it back to the lru list
+			 */
+			spin_lock(&pool->lock);
+			list_add(&page->lru, &pool->lru);
 			spin_unlock(&pool->lock);
-			return 0;
+			z3fold_page_unlock(zhdr);
 		}
 
-		/*
-		 * Add to the beginning of LRU.
-		 * Pool lock has to be kept here to ensure the page has
-		 * not already been released
-		 */
-		list_add(&page->lru, &pool->lru);
+		/* We started off locked to we need to lock the pool back */
+		spin_lock(&pool->lock);
 	}
 	spin_unlock(&pool->lock);
 	return -EAGAIN;
-- 
2.15.1
