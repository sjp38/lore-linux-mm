Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68D606B02C3
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:13 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id r23so7462854pfg.17
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:13 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 68si8789834pfi.328.2017.11.22.13.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:19 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 41/62] shmem: Convert shmem_wait_for_pins to XArray
Date: Wed, 22 Nov 2017 13:07:18 -0800
Message-Id: <20171122210739.29916-42-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

As with shmem_tag_pins(), hold the lock around the entire loop instead
of acquiring & dropping it for each entry we're going to untag.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/shmem.c | 59 +++++++++++++++++++++++++----------------------------------
 1 file changed, 25 insertions(+), 34 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 302fcb62ba1f..e4d28743a666 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2636,9 +2636,7 @@ static void shmem_tag_pins(struct address_space *mapping)
  */
 static int shmem_wait_for_pins(struct address_space *mapping)
 {
-	struct radix_tree_iter iter;
-	void **slot;
-	pgoff_t start;
+	XA_STATE(xas, 0);
 	struct page *page;
 	int error, scan;
 
@@ -2646,7 +2644,9 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 
 	error = 0;
 	for (scan = 0; scan <= LAST_SCAN; scan++) {
-		if (!radix_tree_tagged(&mapping->pages, SHMEM_TAG_PINNED))
+		unsigned int tagged = 0;
+
+		if (!xa_tagged(&mapping->pages, SHMEM_TAG_PINNED))
 			break;
 
 		if (!scan)
@@ -2654,45 +2654,36 @@ static int shmem_wait_for_pins(struct address_space *mapping)
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
+		xa_lock_irq(&mapping->pages);
+		xas_for_each_tag(&mapping->pages, &xas, page, ULONG_MAX,
+				SHMEM_TAG_PINNED) {
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
+				xas_clear_tag(&mapping->pages, &xas,
+							SHMEM_TAG_PINNED);
+			if (++tagged % XA_CHECK_SCHED)
+				continue;
 
-			xa_lock_irq(&mapping->pages);
-			radix_tree_tag_clear(&mapping->pages,
-					     iter.index, SHMEM_TAG_PINNED);
+			xas_pause(&xas);
 			xa_unlock_irq(&mapping->pages);
-continue_resched:
-			if (need_resched()) {
-				slot = radix_tree_iter_resume(slot, &iter);
-				cond_resched_rcu();
-			}
+			cond_resched();
+			xa_lock_irq(&mapping->pages);
 		}
-		rcu_read_unlock();
+		xa_unlock_irq(&mapping->pages);
 	}
 
 	return error;
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
