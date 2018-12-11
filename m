Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 360728E00B5
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:21:53 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b24so6931420pls.11
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:21:53 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m64si14303764pfb.224.2018.12.11.09.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 09:21:51 -0800 (PST)
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 21733B042
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:21:49 +0000 (UTC)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 6/6] mm: migrate: Drop unused argument of migrate_page_move_mapping()
Date: Tue, 11 Dec 2018 18:21:43 +0100
Message-Id: <20181211172143.7358-7-jack@suse.cz>
In-Reply-To: <20181211172143.7358-1-jack@suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, mgorman@suse.de, Jan Kara <jack@suse.cz>

All callers of migrate_page_move_mapping() now pass NULL for 'head'
argument. Drop it.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/aio.c                | 2 +-
 fs/f2fs/data.c          | 2 +-
 fs/iomap.c              | 2 +-
 fs/ubifs/file.c         | 2 +-
 include/linux/migrate.h | 3 +--
 mm/migrate.c            | 7 +++----
 6 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 97f983592925..4f4878ebca9a 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -408,7 +408,7 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	BUG_ON(PageWriteback(old));
 	get_page(new);
 
-	rc = migrate_page_move_mapping(mapping, new, old, NULL, mode, 1);
+	rc = migrate_page_move_mapping(mapping, new, old, mode, 1);
 	if (rc != MIGRATEPAGE_SUCCESS) {
 		put_page(new);
 		goto out_unlock;
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index b293cb3e27a2..008b74eff00d 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -2738,7 +2738,7 @@ int f2fs_migrate_page(struct address_space *mapping,
 	 */
 	extra_count = (atomic_written ? 1 : 0) - page_has_private(page);
 	rc = migrate_page_move_mapping(mapping, newpage,
-				page, NULL, mode, extra_count);
+				page, mode, extra_count);
 	if (rc != MIGRATEPAGE_SUCCESS) {
 		if (atomic_written)
 			mutex_unlock(&fi->inmem_lock);
diff --git a/fs/iomap.c b/fs/iomap.c
index 3ffb776fbebe..8df6a75d2d11 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -550,7 +550,7 @@ iomap_migrate_page(struct address_space *mapping, struct page *newpage,
 {
 	int ret;
 
-	ret = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
+	ret = migrate_page_move_mapping(mapping, newpage, page, mode, 0);
 	if (ret != MIGRATEPAGE_SUCCESS)
 		return ret;
 
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 1b78f2e09218..5d2ffb1a45fc 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1481,7 +1481,7 @@ static int ubifs_migrate_page(struct address_space *mapping,
 {
 	int rc;
 
-	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
+	rc = migrate_page_move_mapping(mapping, newpage, page, mode, 0);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f2b4abbca55e..8eeeaf946f95 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -77,8 +77,7 @@ extern void migrate_page_copy(struct page *newpage, struct page *page);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
 extern int migrate_page_move_mapping(struct address_space *mapping,
-		struct page *newpage, struct page *page,
-		struct buffer_head *head, enum migrate_mode mode,
+		struct page *newpage, struct page *page, enum migrate_mode mode,
 		int extra_count);
 #else
 
diff --git a/mm/migrate.c b/mm/migrate.c
index c4075d5ec073..1e47ea88a5b3 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -403,8 +403,7 @@ static int expected_page_refs(struct page *page)
  * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
  */
 int migrate_page_move_mapping(struct address_space *mapping,
-		struct page *newpage, struct page *page,
-		struct buffer_head *head, enum migrate_mode mode,
+		struct page *newpage, struct page *page, enum migrate_mode mode,
 		int extra_count)
 {
 	XA_STATE(xas, &mapping->i_pages, page_index(page));
@@ -691,7 +690,7 @@ int migrate_page(struct address_space *mapping,
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
+	rc = migrate_page_move_mapping(mapping, newpage, page, mode, 0);
 
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
@@ -794,7 +793,7 @@ static int __buffer_migrate_page(struct address_space *mapping,
 		}
 	}
 
-	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
+	rc = migrate_page_move_mapping(mapping, newpage, page, mode, 0);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		goto unlock_buffers;
 
-- 
2.16.4
