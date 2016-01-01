Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3328F6B0008
	for <linux-mm@kvack.org>; Fri,  1 Jan 2016 04:50:50 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id e32so122930899qgf.3
        for <linux-mm@kvack.org>; Fri, 01 Jan 2016 01:50:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u64si55146383qki.62.2016.01.01.01.50.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jan 2016 01:50:49 -0800 (PST)
Date: Fri, 1 Jan 2016 11:50:45 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] balloon: fix page list locking
Message-ID: <1451641671-17046-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org, Rafael Aquini <aquini@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, Konstantin Khlebnikov <koct9i@gmail.com>

Minchan Kim noticed that balloon_page_dequeue walks the pages list
without holding the pages_lock. This can race e.g. with isolation, which
has been reported to cause list corruption and crashes in leak_balloon.
Page can also in theory get freed before it's locked, corrupting memory.

To fix, make sure list accesses are done under lock, and
always take a page reference before trying to lock it.

Reported-by:  Minchan Kim <minchan@kernel.org>
Cc: <stable@vger.kernel.org>
Cc:  Rafael Aquini <aquini@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

This is an alternative to patch
	virtio_balloon: fix race between migration and ballooning
by Minchan Kim in -mm.

Untested - Minchan, could you pls confirm this fixes the issue for you?

 mm/balloon_compaction.c | 34 ++++++++++++++++++++++++++++++++--
 1 file changed, 32 insertions(+), 2 deletions(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index d3116be..66d69c5 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -56,12 +56,34 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
  */
 struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 {
-	struct page *page, *tmp;
+	struct page *page;
 	unsigned long flags;
 	bool dequeued_page;
+	LIST_HEAD(processed); /* protected by b_dev_info->pages_lock */
 
 	dequeued_page = false;
-	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
+	/*
+	 * We need to go over b_dev_info->pages and lock each page,
+	 * but b_dev_info->pages_lock must nest within page lock.
+	 *
+	 * To make this safe, remove each page from b_dev_info->pages list
+	 * under b_dev_info->pages_lock, then drop this lock. Once list is
+	 * empty, re-add them also under b_dev_info->pages_lock.
+	 */
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	while (!list_empty(&b_dev_info->pages)) {
+		page = list_first_entry(&b_dev_info->pages, typeof(*page), lru);
+		/* move to processed list to avoid going over it another time */
+		list_move(&page->lru, &processed);
+
+		if (!get_page_unless_zero(page))
+			continue;
+		/*
+		 * pages_lock nests within page lock,
+		 * so drop it before trylock_page
+		 */
+		spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+
 		/*
 		 * Block others from accessing the 'page' while we get around
 		 * establishing additional references and preparing the 'page'
@@ -72,6 +94,7 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 			if (!PagePrivate(page)) {
 				/* raced with isolation */
 				unlock_page(page);
+				put_page(page);
 				continue;
 			}
 #endif
@@ -80,11 +103,18 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 			__count_vm_event(BALLOON_DEFLATE);
 			spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 			unlock_page(page);
+			put_page(page);
 			dequeued_page = true;
 			break;
 		}
+		put_page(page);
+		spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 	}
 
+	/* re-add remaining entries */
+	list_splice(&processed, &b_dev_info->pages);
+	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+
 	if (!dequeued_page) {
 		/*
 		 * If we are unable to dequeue a balloon page because the page
-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
