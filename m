Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 051E96B0270
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:27:08 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 69-v6so1685510plc.18
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:27:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k9-v6si142063plt.293.2018.03.13.06.27.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 06:27:06 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v9 51/61] memfd: Convert shmem_wait_for_pins to XArray
Date: Tue, 13 Mar 2018 06:26:29 -0700
Message-Id: <20180313132639.17387-52-willy@infradead.org>
In-Reply-To: <20180313132639.17387-1-willy@infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

As with shmem_tag_pins(), hold the lock around the entire loop instead
of acquiring & dropping it for each entry we're going to untag.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/memfd.c | 61 +++++++++++++++++++++++++------------------------------------
 1 file changed, 25 insertions(+), 36 deletions(-)

diff --git a/mm/memfd.c b/mm/memfd.c
index 3b299d72df78..0e0835e63af2 100644
--- a/mm/memfd.c
+++ b/mm/memfd.c
@@ -64,9 +64,7 @@ static void shmem_tag_pins(struct address_space *mapping)
  */
 static int shmem_wait_for_pins(struct address_space *mapping)
 {
-	struct radix_tree_iter iter;
-	void __rcu **slot;
-	pgoff_t start;
+	XA_STATE(xas, &mapping->i_pages, 0);
 	struct page *page;
 	int error, scan;
 
@@ -74,7 +72,9 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 
 	error = 0;
 	for (scan = 0; scan <= LAST_SCAN; scan++) {
-		if (!radix_tree_tagged(&mapping->i_pages, SHMEM_TAG_PINNED))
+		unsigned int tagged = 0;
+
+		if (!xas_tagged(&xas, SHMEM_TAG_PINNED))
 			break;
 
 		if (!scan)
@@ -82,45 +82,34 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 		else if (schedule_timeout_killable((HZ << scan) / 200))
 			scan = LAST_SCAN;
 
-		start = 0;
-		rcu_read_lock();
-		radix_tree_for_each_tagged(slot, &mapping->i_pages, &iter,
-					   start, SHMEM_TAG_PINNED) {
-
-			page = radix_tree_deref_slot(slot);
-			if (radix_tree_exception(page)) {
-				if (radix_tree_deref_retry(page)) {
-					slot = radix_tree_iter_retry(&iter);
-					continue;
-				}
-
-				page = NULL;
-			}
-
-			if (page &&
-			    page_count(page) - page_mapcount(page) != 1) {
-				if (scan < LAST_SCAN)
-					goto continue_resched;
-
+		xas_set(&xas, 0);
+		xas_lock_irq(&xas);
+		xas_for_each_tag(&xas, page, ULONG_MAX, SHMEM_TAG_PINNED) {
+			bool clear = true;
+			if (xa_is_value(page))
+				continue;
+			if (page_count(page) - page_mapcount(page) != 1) {
 				/*
 				 * On the last scan, we clean up all those tags
 				 * we inserted; but make a note that we still
 				 * found pages pinned.
 				 */
-				error = -EBUSY;
-			}
-
-			xa_lock_irq(&mapping->i_pages);
-			radix_tree_tag_clear(&mapping->i_pages,
-					     iter.index, SHMEM_TAG_PINNED);
-			xa_unlock_irq(&mapping->i_pages);
-continue_resched:
-			if (need_resched()) {
-				slot = radix_tree_iter_resume(slot, &iter);
-				cond_resched_rcu();
+				if (scan == LAST_SCAN)
+					error = -EBUSY;
+				else
+					clear = false;
 			}
+			if (clear)
+				xas_clear_tag(&xas, SHMEM_TAG_PINNED);
+			if (++tagged % XA_CHECK_SCHED)
+				continue;
+
+			xas_pause(&xas);
+			xas_unlock_irq(&xas);
+			cond_resched();
+			xas_lock_irq(&xas);
 		}
-		rcu_read_unlock();
+		xas_unlock_irq(&xas);
 	}
 
 	return error;
-- 
2.16.1
