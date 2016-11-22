Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2F96B0260
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:26:26 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id 41so12385901qtn.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:26:26 -0800 (PST)
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id u33si9444454qte.53.2016.11.22.08.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 08:26:25 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH 1/5] mm: migrate: Add mode parameter to support additional page copy routines.
Date: Tue, 22 Nov 2016 11:25:26 -0500
Message-Id: <20161122162530.2370-2-zi.yan@sent.com>
In-Reply-To: <20161122162530.2370-1-zi.yan@sent.com>
References: <20161122162530.2370-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

From: Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <ziy@nvidia.com>

migrate_page_copy() and copy_huge_page() are affected.

Signed-off-by: Zi Yan <ziy@nvidia.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 fs/aio.c                |  2 +-
 fs/hugetlbfs/inode.c    |  2 +-
 fs/ubifs/file.c         |  2 +-
 include/linux/migrate.h |  6 ++++--
 mm/migrate.c            | 14 ++++++++------
 5 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 428484f..a67c764 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -418,7 +418,7 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	 * events from being lost.
 	 */
 	spin_lock_irqsave(&ctx->completion_lock, flags);
-	migrate_page_copy(new, old);
+	migrate_page_copy(new, old, 0);
 	BUG_ON(ctx->ring_pages[idx] != old);
 	ctx->ring_pages[idx] = new;
 	spin_unlock_irqrestore(&ctx->completion_lock, flags);
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 4fb7b10..a17bfef 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -850,7 +850,7 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
 	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, 0);
 
 	return MIGRATEPAGE_SUCCESS;
 }
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index b4fbeef..bf54e32 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1468,7 +1468,7 @@ static int ubifs_migrate_page(struct address_space *mapping,
 		SetPagePrivate(newpage);
 	}
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, 0);
 	return MIGRATEPAGE_SUCCESS;
 }
 #endif
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ae8d475..c78593d 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -42,7 +42,8 @@ extern void putback_movable_page(struct page *page);
 
 extern int migrate_prep(void);
 extern int migrate_prep_local(void);
-extern void migrate_page_copy(struct page *newpage, struct page *page);
+extern void migrate_page_copy(struct page *newpage, struct page *page,
+				  enum migrate_mode mode);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
 extern int migrate_page_move_mapping(struct address_space *mapping,
@@ -61,7 +62,8 @@ static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
 
 static inline void migrate_page_copy(struct page *newpage,
-				     struct page *page) {}
+				     struct page *page,
+				     enum migrate_mode mode) {}
 
 static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page)
diff --git a/mm/migrate.c b/mm/migrate.c
index 5bd202c..bc6c1c4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -629,7 +629,8 @@ static void __copy_gigantic_page(struct page *dst, struct page *src,
 	}
 }
 
-static void copy_huge_page(struct page *dst, struct page *src)
+static void copy_huge_page(struct page *dst, struct page *src,
+				enum migrate_mode mode)
 {
 	int i;
 	int nr_pages;
@@ -658,12 +659,13 @@ static void copy_huge_page(struct page *dst, struct page *src)
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
 
@@ -745,7 +747,7 @@ int migrate_page(struct address_space *mapping,
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, mode);
 	return MIGRATEPAGE_SUCCESS;
 }
 EXPORT_SYMBOL(migrate_page);
@@ -795,7 +797,7 @@ int buffer_migrate_page(struct address_space *mapping,
 
 	SetPagePrivate(newpage);
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, 0);
 
 	bh = head;
 	do {
@@ -2020,7 +2022,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	/* anon mapping, we can simply copy page->mapping to the new page: */
 	new_page->mapping = page->mapping;
 	new_page->index = page->index;
-	migrate_page_copy(new_page, page);
+	migrate_page_copy(new_page, page, 0);
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
