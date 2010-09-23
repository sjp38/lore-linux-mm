Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5954F6B0095
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 23:53:15 -0400 (EDT)
From: Dima Zavin <dima@android.com>
Subject: [PATCH] mm: add a might_sleep_if in dma_pool_alloc
Date: Wed, 22 Sep 2010 20:52:47 -0700
Message-Id: <1285213967-14052-1-git-send-email-dima@android.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dima Zavin <dima@android.com>
List-ID: <linux-mm.kvack.org>

Buggy drivers (e.g. fsl_udc) could call dma_pool_alloc from atomic
context with GFP_KERNEL. In most instances, the first pool_alloc_page
call would succeed and the sleeping functions would never be called.
This allowed the buggy drivers to slip through the cracks.

Add a might_sleep_if checking for __GFP_WAIT in flags.

Signed-off-by: Dima Zavin <dima@android.com>
---
 mm/dmapool.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 3df0637..4df2de7 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -311,6 +311,8 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
 	size_t offset;
 	void *retval;
 
+	might_sleep_if(mem_flags & __GFP_WAIT);
+
 	spin_lock_irqsave(&pool->lock, flags);
  restart:
 	list_for_each_entry(page, &pool->page_list, page_list) {
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
