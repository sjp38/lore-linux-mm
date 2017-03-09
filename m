Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A44636B042E
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 01:24:16 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j5so97223482pfb.3
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 22:24:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q87si5472261pfi.271.2017.03.08.22.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 22:24:15 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v296O0eb128011
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 01:24:15 -0500
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0a-001b2d01.pphosted.com with ESMTP id 292h0m5a99-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Mar 2017 01:24:14 -0500
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 9 Mar 2017 11:54:11 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay09.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v296O9lG21168176
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 11:54:09 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v296O6Yx029332
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 11:54:09 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 1/6] mm/migrate: Add new mode parameter to migrate_page_copy() function
Date: Thu,  9 Mar 2017 11:54:01 +0530
In-Reply-To: <20170217112453.307-2-khandual@linux.vnet.ibm.com>
References: <20170217112453.307-2-khandual@linux.vnet.ibm.com>
Message-Id: <20170309062401.30646-1-khandual@linux.vnet.ibm.com>
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
* Updated include/linux/migrate_mode.h comment as per Naoya

 fs/aio.c                     |  2 +-
 fs/f2fs/data.c               |  2 +-
 fs/hugetlbfs/inode.c         |  2 +-
 fs/ubifs/file.c              |  2 +-
 include/linux/migrate.h      |  6 ++++--
 include/linux/migrate_mode.h |  2 ++
 mm/migrate.c                 | 14 ++++++++------
 7 files changed, 18 insertions(+), 12 deletions(-)

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
index ebf3d89..deaeba5 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -6,11 +6,13 @@
  *	on most operations but not ->writepage as the potential stall time
  *	is too significant
  * MIGRATE_SYNC will block when migrating pages
+ * MIGRATE_ST will use single thread when migrating pages
  */
 enum migrate_mode {
 	MIGRATE_ASYNC,
 	MIGRATE_SYNC_LIGHT,
 	MIGRATE_SYNC,
+	MIGRATE_ST
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/migrate.c b/mm/migrate.c
index e8ae11a..5ef4aa4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -631,7 +631,8 @@ static void __copy_gigantic_page(struct page *dst, struct page *src,
 	}
 }
 
-static void copy_huge_page(struct page *dst, struct page *src)
+static void copy_huge_page(struct page *dst, struct page *src,
+				enum migrate_mode mode)
 {
 	int i;
 	int nr_pages;
@@ -660,12 +661,13 @@ static void copy_huge_page(struct page *dst, struct page *src)
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
 
@@ -747,7 +749,7 @@ int migrate_page(struct address_space *mapping,
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, mode);
 	return MIGRATEPAGE_SUCCESS;
 }
 EXPORT_SYMBOL(migrate_page);
@@ -797,7 +799,7 @@ int buffer_migrate_page(struct address_space *mapping,
 
 	SetPagePrivate(newpage);
 
-	migrate_page_copy(newpage, page);
+	migrate_page_copy(newpage, page, MIGRATE_ST);
 
 	bh = head;
 	do {
@@ -2029,7 +2031,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	/* anon mapping, we can simply copy page->mapping to the new page: */
 	new_page->mapping = page->mapping;
 	new_page->index = page->index;
-	migrate_page_copy(new_page, page);
+	migrate_page_copy(new_page, page, MIGRATE_ST);
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
