Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D23636B0260
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:59:40 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id c8so2684743lfe.4
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:59:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2sor3461844lji.72.2017.09.14.06.59.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Sep 2017 06:59:39 -0700 (PDT)
Date: Thu, 14 Sep 2017 15:59:36 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] z3fold: fix stale list handling
Message-Id: <20170914155936.697bf347a00dacee7e7f3778@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com

Fix the situation when clear_bit() is called for page->private before
the page pointer is actually assigned. While at it, remove work_busy()
check because it is costly and does not give 100% guarantee anyway.

Signed-of-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index b04fa3ba1bf2..b2ba2ba585f3 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -250,6 +250,7 @@ static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
 
 	WARN_ON(!list_empty(&zhdr->buddy));
 	set_bit(PAGE_STALE, &page->private);
+	clear_bit(NEEDS_COMPACTING, &page->private);
 	spin_lock(&pool->lock);
 	if (!list_empty(&page->lru))
 		list_del(&page->lru);
@@ -303,7 +304,6 @@ static void free_pages_work(struct work_struct *w)
 		list_del(&zhdr->buddy);
 		if (WARN_ON(!test_bit(PAGE_STALE, &page->private)))
 			continue;
-		clear_bit(NEEDS_COMPACTING, &page->private);
 		spin_unlock(&pool->stale_lock);
 		cancel_work_sync(&zhdr->work);
 		free_z3fold_page(page);
@@ -624,10 +624,8 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	 * stale pages list. cancel_work_sync() can sleep so we must make
 	 * sure it won't be called in case we're in atomic context.
 	 */
-	if (zhdr && (can_sleep || !work_pending(&zhdr->work) ||
-	    !unlikely(work_busy(&zhdr->work)))) {
+	if (zhdr && (can_sleep || !work_pending(&zhdr->work))) {
 		list_del(&zhdr->buddy);
-		clear_bit(NEEDS_COMPACTING, &page->private);
 		spin_unlock(&pool->stale_lock);
 		if (can_sleep)
 			cancel_work_sync(&zhdr->work);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
