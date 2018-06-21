Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5DE6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 23:07:44 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t5-v6so615837pgt.18
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 20:07:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u8-v6sor1123444pfd.50.2018.06.20.20.07.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 20:07:43 -0700 (PDT)
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Subject: [PATCH] mm: mempool: Fix a possible sleep-in-atomic-context bug in mempool_resize()
Date: Thu, 21 Jun 2018 11:07:14 +0800
Message-Id: <20180621030714.10368-1-baijiaju1990@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dvyukov@google.com, gregkh@linuxfoundation.org, jthumshirn@suse.de, pombredanne@nexb.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@gmail.com>

The kernel may sleep with holding a spinlock.
The function call path (from bottom to top) in Linux-4.16.7 is:

[FUNC] remove_element(GFP_KERNEL)
mm/mempool.c, 250: remove_element in mempool_resize
mm/mempool.c, 247: _raw_spin_lock_irqsave in mempool_resize

To fix this bug, GFP_KERNEL is replaced with GFP_ATOMIC.

This bug is found by my static analysis tool (DSAC-2) and checked by
my code review.

Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
---
 mm/mempool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempool.c b/mm/mempool.c
index 5c9dce34719b..d33bd5d622e7 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -247,7 +247,7 @@ int mempool_resize(mempool_t *pool, int new_min_nr)
 	spin_lock_irqsave(&pool->lock, flags);
 	if (new_min_nr <= pool->min_nr) {
 		while (new_min_nr < pool->curr_nr) {
-			element = remove_element(pool, GFP_KERNEL);
+			element = remove_element(pool, GFP_ATOMIC);
 			spin_unlock_irqrestore(&pool->lock, flags);
 			pool->free(element, pool->pool_data);
 			spin_lock_irqsave(&pool->lock, flags);
-- 
2.17.0
