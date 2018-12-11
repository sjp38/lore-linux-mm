Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB808E00B8
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:21:51 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b24so6931357pls.11
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:21:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a17si13329103pfn.213.2018.12.11.09.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 09:21:50 -0800 (PST)
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D6DF5B029
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:21:48 +0000 (UTC)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/6] mm: migrate: Provide buffer_migrate_page_norefs()
Date: Tue, 11 Dec 2018 18:21:41 +0100
Message-Id: <20181211172143.7358-5-jack@suse.cz>
In-Reply-To: <20181211172143.7358-1-jack@suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, mgorman@suse.de, Jan Kara <jack@suse.cz>

Provide a variant of buffer_migrate_page() that also checks whether
there are no unexpected references to buffer heads. This function will
then be safe to use for block device pages.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/fs.h |  4 ++++
 mm/migrate.c       | 61 +++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 58 insertions(+), 7 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index c95c0807471f..4bb1a8b65474 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3264,8 +3264,12 @@ extern int generic_check_addressable(unsigned, u64);
 extern int buffer_migrate_page(struct address_space *,
 				struct page *, struct page *,
 				enum migrate_mode);
+extern int buffer_migrate_page_norefs(struct address_space *,
+				struct page *, struct page *,
+				enum migrate_mode);
 #else
 #define buffer_migrate_page NULL
+#define buffer_migrate_page_norefs NULL
 #endif
 
 extern int setattr_prepare(struct dentry *, struct iattr *);
diff --git a/mm/migrate.c b/mm/migrate.c
index f8df1ad6e7cf..c4075d5ec073 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -747,13 +747,9 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 	return true;
 }
 
-/*
- * Migration function for pages with buffers. This function can only be used
- * if the underlying filesystem guarantees that no other references to "page"
- * exist.
- */
-int buffer_migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page, enum migrate_mode mode)
+static int __buffer_migrate_page(struct address_space *mapping,
+		struct page *newpage, struct page *page, enum migrate_mode mode,
+		bool check_refs)
 {
 	struct buffer_head *bh, *head;
 	int rc;
@@ -771,6 +767,33 @@ int buffer_migrate_page(struct address_space *mapping,
 	if (!buffer_migrate_lock_buffers(head, mode))
 		return -EAGAIN;
 
+	if (check_refs) {
+		bool busy;
+		bool invalidated = false;
+
+recheck_buffers:
+		busy = false;
+		spin_lock(&mapping->private_lock);
+		bh = head;
+		do {
+			if (atomic_read(&bh->b_count)) {
+				busy = true;
+				break;
+			}
+			bh = bh->b_this_page;
+		} while (bh != head);
+		spin_unlock(&mapping->private_lock);
+		if (busy) {
+			if (invalidated) {
+				rc = -EAGAIN;
+				goto unlock_buffers;
+			}
+			invalidate_bh_lrus();
+			invalidated = true;
+			goto recheck_buffers;
+		}
+	}
+
 	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		goto unlock_buffers;
@@ -807,7 +830,31 @@ int buffer_migrate_page(struct address_space *mapping,
 
 	return rc;
 }
+
+/*
+ * Migration function for pages with buffers. This function can only be used
+ * if the underlying filesystem guarantees that no other references to "page"
+ * exist. For example attached buffer heads are accessed only under page lock.
+ */
+int buffer_migrate_page(struct address_space *mapping,
+		struct page *newpage, struct page *page, enum migrate_mode mode)
+{
+	return __buffer_migrate_page(mapping, newpage, page, mode, false);
+}
 EXPORT_SYMBOL(buffer_migrate_page);
+
+/*
+ * Same as above except that this variant is more careful and checks that there
+ * are also no buffer head references. This function is the right one for
+ * mappings where buffer heads are directly looked up and referenced (such as
+ * block device mappings).
+ */
+int buffer_migrate_page_norefs(struct address_space *mapping,
+		struct page *newpage, struct page *page, enum migrate_mode mode)
+{
+	return __buffer_migrate_page(mapping, newpage, page, mode, true);
+}
+EXPORT_SYMBOL(buffer_migrate_page_norefs);
 #endif
 
 /*
-- 
2.16.4
