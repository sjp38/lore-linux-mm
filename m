Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 747C66B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 10:29:41 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id q132so297622lfe.1
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 07:29:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n190sor3085815lfb.110.2017.09.13.07.29.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Sep 2017 07:29:39 -0700 (PDT)
Date: Wed, 13 Sep 2017 16:29:37 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: z3fold: fix potential race in z3fold_reclaim_page
Message-Id: <20170913162937.bfff21c7d12b12a5f47639fd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com

It is possible that on a (partially) unsuccessful page reclaim,
kref_put() called in z3fold_reclaim_page() does not yield page
release, but the page is released shortly afterwards by another
thread. Then z3fold_reclaim_page() would try to list_add() that
(released) page again which is obviously a bug.

To avoid that, spin_lock() has to be taken earlier, before the
kref_put() call mentioned earlier.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 486550df32be..b04fa3ba1bf2 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -875,16 +875,18 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				goto next;
 		}
 next:
+		spin_lock(&pool->lock);
 		if (test_bit(PAGE_HEADLESS, &page->private)) {
 			if (ret == 0) {
+				spin_unlock(&pool->lock);
 				free_z3fold_page(page);
 				return 0;
 			}
 		} else if (kref_put(&zhdr->refcount, release_z3fold_page)) {
 			atomic64_dec(&pool->pages_nr);
+			spin_unlock(&pool->lock);
 			return 0;
 		}
-		spin_lock(&pool->lock);
 
 		/*
 		 * Add to the beginning of LRU.
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
