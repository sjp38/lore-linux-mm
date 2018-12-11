Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93FE38E00B6
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:21:51 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id c14so10998522pls.21
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:21:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j21si12437231pll.150.2018.12.11.09.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 09:21:50 -0800 (PST)
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BE8E6B012
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:21:48 +0000 (UTC)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/6] mm: migrate: Lock buffers before migrate_page_move_mapping()
Date: Tue, 11 Dec 2018 18:21:39 +0100
Message-Id: <20181211172143.7358-3-jack@suse.cz>
In-Reply-To: <20181211172143.7358-1-jack@suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, mgorman@suse.de, Jan Kara <jack@suse.cz>

Lock buffers before calling into migrate_page_move_mapping() so that
that function doesn't have to know about buffers (which is somewhat
unexpected anyway) and all the buffer head logic is in
buffer_migrate_page().

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/migrate.c | 39 +++++++++++++--------------------------
 1 file changed, 13 insertions(+), 26 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 789c7bc90a0c..d58a8ecf275e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -490,20 +490,6 @@ int migrate_page_move_mapping(struct address_space *mapping,
 		return -EAGAIN;
 	}
 
-	/*
-	 * In the async migration case of moving a page with buffers, lock the
-	 * buffers using trylock before the mapping is moved. If the mapping
-	 * was moved, we later failed to lock the buffers and could not move
-	 * the mapping back due to an elevated page count, we would have to
-	 * block waiting on other references to be dropped.
-	 */
-	if (mode == MIGRATE_ASYNC && head &&
-			!buffer_migrate_lock_buffers(head, mode)) {
-		page_ref_unfreeze(page, expected_count);
-		xas_unlock_irq(&xas);
-		return -EAGAIN;
-	}
-
 	/*
 	 * Now we know that no one else is looking at the page:
 	 * no turning back from here.
@@ -779,24 +765,23 @@ int buffer_migrate_page(struct address_space *mapping,
 {
 	struct buffer_head *bh, *head;
 	int rc;
+	int expected_count;
 
 	if (!page_has_buffers(page))
 		return migrate_page(mapping, newpage, page, mode);
 
-	head = page_buffers(page);
+	/* Check whether page does not have extra refs before we do more work */
+	expected_count = expected_page_refs(page);
+	if (page_count(page) != expected_count)
+		return -EAGAIN;
 
-	rc = migrate_page_move_mapping(mapping, newpage, page, head, mode, 0);
+	head = page_buffers(page);
+	if (!buffer_migrate_lock_buffers(head, mode))
+		return -EAGAIN;
 
+	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
 	if (rc != MIGRATEPAGE_SUCCESS)
-		return rc;
-
-	/*
-	 * In the async case, migrate_page_move_mapping locked the buffers
-	 * with an IRQ-safe spinlock held. In the sync case, the buffers
-	 * need to be locked now
-	 */
-	if (mode != MIGRATE_ASYNC)
-		BUG_ON(!buffer_migrate_lock_buffers(head, mode));
+		goto unlock_buffers;
 
 	ClearPagePrivate(page);
 	set_page_private(newpage, page_private(page));
@@ -818,6 +803,8 @@ int buffer_migrate_page(struct address_space *mapping,
 	else
 		migrate_page_states(newpage, page);
 
+	rc = MIGRATEPAGE_SUCCESS;
+unlock_buffers:
 	bh = head;
 	do {
 		unlock_buffer(bh);
@@ -826,7 +813,7 @@ int buffer_migrate_page(struct address_space *mapping,
 
 	} while (bh != head);
 
-	return MIGRATEPAGE_SUCCESS;
+	return rc;
 }
 EXPORT_SYMBOL(buffer_migrate_page);
 #endif
-- 
2.16.4
