Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E30F34405F2
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:08 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id v73so9995020qkv.7
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:08 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id q19si121075qte.203.2017.02.17.07.06.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:07 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 01/14] mm/migrate: Add new mode parameter to migrate_page_copy() function
Date: Fri, 17 Feb 2017 10:05:38 -0500
Message-Id: <20170217150551.117028-2-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Zi Yan <zi.yan@cs.rutgers.edu>

This is a prequisite change required to make page migration framewok
copy in different modes like the default single threaded or the new
multi threaded one yet to be introduced in follow up patches. This
does not change any existing functionality. Only migrate_page_copy()
and copy_huge_page() function's signatures are affected.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 fs/aio.c                     |  2 +-
 fs/f2fs/data.c               |  2 +-
 fs/hugetlbfs/inode.c         |  2 +-
 fs/ubifs/file.c              |  2 +-
 include/linux/migrate.h      |  6 ++++--
 include/linux/migrate_mode.h |  1 +
 mm/migrate.c                 | 14 ++++++++------
 mm/shmem.c                   |  2 +-
 8 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 5517794add2d..6e46c2887aa8 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -418,7 +418,7 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	 * events from being lost.
 	 */
 	spin_lock_irqsave(&ctx->completion_lock, flags);
-	migrate_page_copy(new, old);
+	migrate_page_copy(new, old, MIGRATE_ST);
 	BUG_ON(ctx->ring_pages[idx] != old);
 	ctx->ring_pages[idx] = new;
 	spin_unlock_irqrestore(&ctx->completion_lock, flags);
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 9f0ba90b92e4..4ac32954b59c 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -1937,7 +1937,7 @@ int f2fs_migrate_page(struct address_space *mapping,
 		SetPagePrivate(newpage);
 	set_page_private(newpage, page_private(page));
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, MIGRATE_ST);
 
 	return MIGRATEPAGE_SUCCESS;
 }
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 4fb7b10f3a05..62b740524d54 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -850,7 +850,7 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
 	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, MIGRATE_ST);
 
 	return MIGRATEPAGE_SUCCESS;
 }
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 957ec7c90b43..8a8980ceb9cc 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1468,7 +1468,7 @@ static int ubifs_migrate_page(struct address_space *mapping,
 		SetPagePrivate(newpage);
 	}
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, MIGRATE_ST);
 	return MIGRATEPAGE_SUCCESS;
 }
 #endif
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index fa76b516fa47..63cfcb7ddbb5 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -42,7 +42,8 @@ extern void putback_movable_page(struct page *page);
 
 extern int migrate_prep(void);
 extern int migrate_prep_local(void);
-extern void migrate_page_copy(struct page *newpage, struct page *page);
+extern void migrate_page_copy(struct page *newpage, struct page *page,
+			enum migrate_mode mode);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
 extern int migrate_page_move_mapping(struct address_space *mapping,
@@ -63,7 +64,8 @@ static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
 
 static inline void migrate_page_copy(struct page *newpage,
-				     struct page *page) {}
+				     struct page *page,
+				     enum migrate_mode mode) {}
 
 static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page)
diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index ebf3d89a3919..b3b9acbff444 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -11,6 +11,7 @@ enum migrate_mode {
 	MIGRATE_ASYNC,
 	MIGRATE_SYNC_LIGHT,
 	MIGRATE_SYNC,
+	MIGRATE_ST
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/migrate.c b/mm/migrate.c
index e9de317820f8..5913f5b54832 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -596,7 +596,8 @@ static void __copy_gigantic_page(struct page *dst, struct page *src,
 	}
 }
 
-static void copy_huge_page(struct page *dst, struct page *src)
+static void copy_huge_page(struct page *dst, struct page *src,
+				enum migrate_mode mode)
 {
 	int i;
 	int nr_pages;
@@ -625,12 +626,13 @@ static void copy_huge_page(struct page *dst, struct page *src)
 /*
  * Copy the page to its new location
  */
-void migrate_page_copy(struct page *newpage, struct page *page)
+void migrate_page_copy(struct page *newpage, struct page *page,
+					   enum migrate_mode mode)
 {
 	int cpupid;
 
 	if (PageHuge(page) || PageTransHuge(page))
-		copy_huge_page(newpage, page);
+		copy_huge_page(newpage, page, mode);
 	else
 		copy_highpage(newpage, page);
 
@@ -712,7 +714,7 @@ int migrate_page(struct address_space *mapping,
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, mode);
 	return MIGRATEPAGE_SUCCESS;
 }
 EXPORT_SYMBOL(migrate_page);
@@ -762,7 +764,7 @@ int buffer_migrate_page(struct address_space *mapping,
 
 	SetPagePrivate(newpage);
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, MIGRATE_ST);
 
 	bh = head;
 	do {
@@ -1994,7 +1996,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	/* anon mapping, we can simply copy page->mapping to the new page: */
 	new_page->mapping = page->mapping;
 	new_page->index = page->index;
-	migrate_page_copy(new_page, page);
+	migrate_page_copy(new_page, page, MIGRATE_ST);
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
diff --git a/mm/shmem.c b/mm/shmem.c
index c6ea40d78028..dd04932dc97d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2522,7 +2522,7 @@ static int shmem_migrate_page(struct address_space *mapping,
 	rc = shmem_migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, MIGRATE_ST);
 
 	return MIGRATEPAGE_SUCCESS;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
