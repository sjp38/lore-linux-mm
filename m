Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C46FB6B02A3
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q2so5801509pgf.22
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a66si2652107pgc.221.2018.02.19.11.46.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:28 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 48/61] shmem: Convert shmem_wait_for_pins to XArray
Date: Mon, 19 Feb 2018 11:45:43 -0800
Message-Id: <20180219194556.6575-49-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

As with shmem_tag_pins(), hold the lock around the entire loop instead
of acquiring & dropping it for each entry we're going to untag.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/shmem.c | 59 ++++++++++++++++++++++++-----------------------------------
 1 file changed, 24 insertions(+), 35 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 5b70fbdec605..ccb6d7ecdee0 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2636,9 +2636,7 @@ static void shmem_tag_pins(struct address_space *mapping)
  */
 static int shmem_wait_for_pins(struct address_space *mapping)
 {
-	struct radix_tree_iter iter;
-	void **slot;
-	pgoff_t start;
+	XA_STATE(xas, &mapping->pages, 0);
 	struct page *page;
 	int error, scan;
 
@@ -2646,7 +2644,9 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 
 	error = 0;
 	for (scan = 0; scan <= LAST_SCAN; scan++) {
-		if (!radix_tree_tagged(&mapping->pages, SHMEM_TAG_PINNED))
+		unsigned int tagged = 0;
+
+		if (!xas_tagged(&xas, SHMEM_TAG_PINNED))
 			break;
 
 		if (!scan)
@@ -2654,45 +2654,34 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 		else if (schedule_timeout_killable((HZ << scan) / 200))
 			scan = LAST_SCAN;
 
-		start = 0;
-		rcu_read_lock();
-		radix_tree_for_each_tagged(slot, &mapping->pages, &iter,
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
+				if (scan == LAST_SCAN)
+					error = -EBUSY;
+				else
+					clear = false;
 			}
+			if (clear)
+				xas_clear_tag(&xas, SHMEM_TAG_PINNED);
+			if (++tagged % XA_CHECK_SCHED)
+				continue;
 
-			xa_lock_irq(&mapping->pages);
-			radix_tree_tag_clear(&mapping->pages,
-					     iter.index, SHMEM_TAG_PINNED);
-			xa_unlock_irq(&mapping->pages);
-continue_resched:
-			if (need_resched()) {
-				slot = radix_tree_iter_resume(slot, &iter);
-				cond_resched_rcu();
-			}
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
