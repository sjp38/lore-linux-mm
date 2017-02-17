Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF187681021
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:14 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so58280994pgb.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 03:26:14 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c25si10011898pfk.252.2017.02.17.03.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 03:26:13 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1HBQ3SP102297
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:13 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28p0a1g09x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:13 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 17 Feb 2017 21:26:05 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 606302CE8056
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:26:03 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1HBPtrr21823694
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:26:03 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1HBPUqx025302
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:25:31 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 1/6] mm/migrate: Add new mode parameter to migrate_page_copy() function
Date: Fri, 17 Feb 2017 16:54:48 +0530
In-Reply-To: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170217112453.307-2-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

This is a prerequisite change required to make page migration framewok
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
 7 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 873b4ca..ba3f6eb 100644
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
index 9ac2625..ad41356 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -1997,7 +1997,7 @@ int f2fs_migrate_page(struct address_space *mapping,
 		SetPagePrivate(newpage);
 	set_page_private(newpage, page_private(page));
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, MIGRATE_ST);
 
 	return MIGRATEPAGE_SUCCESS;
 }
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 54de77e..0e16512f 100644
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
index b0d7837..293616f 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1482,7 +1482,7 @@ static int ubifs_migrate_page(struct address_space *mapping,
 		SetPagePrivate(newpage);
 	}
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, MIGRATE_ST);
 	return MIGRATEPAGE_SUCCESS;
 }
 #endif
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ae8d475..d843b8f 100644
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
@@ -61,7 +62,8 @@ static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
 
 static inline void migrate_page_copy(struct page *newpage,
-				     struct page *page) {}
+				     struct page *page,
+				     enum migrate_mode mode) {}
 
 static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page)
diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index ebf3d89..b3b9acb 100644
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
index 87f4d0f..13fa938 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -589,7 +589,8 @@ static void __copy_gigantic_page(struct page *dst, struct page *src,
 	}
 }
 
-static void copy_huge_page(struct page *dst, struct page *src)
+static void copy_huge_page(struct page *dst, struct page *src,
+				enum migrate_mode mode)
 {
 	int i;
 	int nr_pages;
@@ -618,12 +619,13 @@ static void copy_huge_page(struct page *dst, struct page *src)
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
 
@@ -705,7 +707,7 @@ int migrate_page(struct address_space *mapping,
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, mode);
 	return MIGRATEPAGE_SUCCESS;
 }
 EXPORT_SYMBOL(migrate_page);
@@ -755,7 +757,7 @@ int buffer_migrate_page(struct address_space *mapping,
 
 	SetPagePrivate(newpage);
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, MIGRATE_ST);
 
 	bh = head;
 	do {
@@ -1968,7 +1970,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	/* anon mapping, we can simply copy page->mapping to the new page: */
 	new_page->mapping = page->mapping;
 	new_page->index = page->index;
-	migrate_page_copy(new_page, page);
+	migrate_page_copy(new_page, page, MIGRATE_ST);
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
