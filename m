Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76CA18E00B5
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:21:51 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o17so10254965pgi.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:21:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i4si13505633pfg.218.2018.12.11.09.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 09:21:50 -0800 (PST)
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C0290B017
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:21:48 +0000 (UTC)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 3/6] mm: migrate: Move migrate_page_lock_buffers()
Date: Tue, 11 Dec 2018 18:21:40 +0100
Message-Id: <20181211172143.7358-4-jack@suse.cz>
In-Reply-To: <20181211172143.7358-1-jack@suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, mgorman@suse.de, Jan Kara <jack@suse.cz>

buffer_migrate_page() is the only caller of migrate_page_lock_buffers()
move it close to it and also drop the now unused stub for !CONFIG_BLOCK.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/migrate.c | 92 +++++++++++++++++++++++++++---------------------------------
 1 file changed, 42 insertions(+), 50 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index d58a8ecf275e..f8df1ad6e7cf 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -378,56 +378,6 @@ void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd)
 }
 #endif
 
-#ifdef CONFIG_BLOCK
-/* Returns true if all buffers are successfully locked */
-static bool buffer_migrate_lock_buffers(struct buffer_head *head,
-							enum migrate_mode mode)
-{
-	struct buffer_head *bh = head;
-
-	/* Simple case, sync compaction */
-	if (mode != MIGRATE_ASYNC) {
-		do {
-			get_bh(bh);
-			lock_buffer(bh);
-			bh = bh->b_this_page;
-
-		} while (bh != head);
-
-		return true;
-	}
-
-	/* async case, we cannot block on lock_buffer so use trylock_buffer */
-	do {
-		get_bh(bh);
-		if (!trylock_buffer(bh)) {
-			/*
-			 * We failed to lock the buffer and cannot stall in
-			 * async migration. Release the taken locks
-			 */
-			struct buffer_head *failed_bh = bh;
-			put_bh(failed_bh);
-			bh = head;
-			while (bh != failed_bh) {
-				unlock_buffer(bh);
-				put_bh(bh);
-				bh = bh->b_this_page;
-			}
-			return false;
-		}
-
-		bh = bh->b_this_page;
-	} while (bh != head);
-	return true;
-}
-#else
-static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
-							enum migrate_mode mode)
-{
-	return true;
-}
-#endif /* CONFIG_BLOCK */
-
 static int expected_page_refs(struct page *page)
 {
 	int expected_count = 1;
@@ -755,6 +705,48 @@ int migrate_page(struct address_space *mapping,
 EXPORT_SYMBOL(migrate_page);
 
 #ifdef CONFIG_BLOCK
+/* Returns true if all buffers are successfully locked */
+static bool buffer_migrate_lock_buffers(struct buffer_head *head,
+							enum migrate_mode mode)
+{
+	struct buffer_head *bh = head;
+
+	/* Simple case, sync compaction */
+	if (mode != MIGRATE_ASYNC) {
+		do {
+			get_bh(bh);
+			lock_buffer(bh);
+			bh = bh->b_this_page;
+
+		} while (bh != head);
+
+		return true;
+	}
+
+	/* async case, we cannot block on lock_buffer so use trylock_buffer */
+	do {
+		get_bh(bh);
+		if (!trylock_buffer(bh)) {
+			/*
+			 * We failed to lock the buffer and cannot stall in
+			 * async migration. Release the taken locks
+			 */
+			struct buffer_head *failed_bh = bh;
+			put_bh(failed_bh);
+			bh = head;
+			while (bh != failed_bh) {
+				unlock_buffer(bh);
+				put_bh(bh);
+				bh = bh->b_this_page;
+			}
+			return false;
+		}
+
+		bh = bh->b_this_page;
+	} while (bh != head);
+	return true;
+}
+
 /*
  * Migration function for pages with buffers. This function can only be used
  * if the underlying filesystem guarantees that no other references to "page"
-- 
2.16.4
