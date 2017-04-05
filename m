Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 668AE6B03B3
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 16:40:47 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a130so6331189qkb.21
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 13:40:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p186si18731022qkc.250.2017.04.05.13.40.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 13:40:46 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 05/16] mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY
Date: Wed,  5 Apr 2017 16:40:15 -0400
Message-Id: <20170405204026.3940-6-jglisse@redhat.com>
In-Reply-To: <20170405204026.3940-1-jglisse@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Introduce a new migration mode that allow to offload the copy to
a device DMA engine. This changes the workflow of migration and
not all address_space migratepage callback can support this. So
it needs to be tested in those cases.

This is intended to be use by migrate_vma() which itself is use
for thing like HMM (see include/linux/hmm.h).

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 fs/aio.c                     |  8 +++++++
 fs/f2fs/data.c               |  5 ++++-
 fs/hugetlbfs/inode.c         |  5 ++++-
 fs/ubifs/file.c              |  5 ++++-
 include/linux/migrate.h      |  5 +++++
 include/linux/migrate_mode.h |  5 +++++
 mm/balloon_compaction.c      |  8 +++++++
 mm/migrate.c                 | 52 ++++++++++++++++++++++++++++++++++----------
 mm/zsmalloc.c                |  8 +++++++
 9 files changed, 86 insertions(+), 15 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 7e2ab9c..be21c49 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -373,6 +373,14 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	pgoff_t idx;
 	int rc;
 
+	/*
+	 * We cannot support the _NO_COPY case here, because copy needs to
+	 * happen under the ctx->completion_lock. That does not work with the
+	 * migration workflow of MIGRATE_SYNC_NO_COPY.
+	 */
+	if (mode == MIGRATE_SYNC_NO_COPY)
+		return -EINVAL;
+
 	rc = 0;
 
 	/* mapping->private_lock here protects against the kioctx teardown.  */
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 9ac2625..7fc08a5 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -1997,7 +1997,10 @@ int f2fs_migrate_page(struct address_space *mapping,
 		SetPagePrivate(newpage);
 	set_page_private(newpage, page_private(page));
 
-	migrate_page_copy(newpage, page);
+	if (mode != MIGRATE_SYNC_NO_COPY)
+		migrate_page_copy(newpage, page);
+	else
+		migrate_page_states(newpage, page);
 
 	return MIGRATEPAGE_SUCCESS;
 }
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index cf3669d..b2e0fdb 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -837,7 +837,10 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
 	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
-	migrate_page_copy(newpage, page);
+	if (mode != MIGRATE_SYNC_NO_COPY)
+		migrate_page_copy(newpage, page);
+	else
+		migrate_page_states(newpage, page);
 
 	return MIGRATEPAGE_SUCCESS;
 }
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index d9ae86f..c08cbcc 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1482,7 +1482,10 @@ static int ubifs_migrate_page(struct address_space *mapping,
 		SetPagePrivate(newpage);
 	}
 
-	migrate_page_copy(newpage, page);
+	if (mode != MIGRATE_SYNC_NO_COPY)
+		migrate_page_copy(newpage, page);
+	else
+		migrate_page_states(newpage, page);
 	return MIGRATEPAGE_SUCCESS;
 }
 #endif
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 48e2484..78a0fdc 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -43,6 +43,7 @@ extern void putback_movable_page(struct page *page);
 
 extern int migrate_prep(void);
 extern int migrate_prep_local(void);
+extern void migrate_page_states(struct page *newpage, struct page *page);
 extern void migrate_page_copy(struct page *newpage, struct page *page);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
@@ -63,6 +64,10 @@ static inline int isolate_movable_page(struct page *page, isolate_mode_t mode)
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
 
+static inline void migrate_page_states(struct page *newpage, struct page *page)
+{
+}
+
 static inline void migrate_page_copy(struct page *newpage,
 				     struct page *page) {}
 
diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index ebf3d89..bdf66af 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -6,11 +6,16 @@
  *	on most operations but not ->writepage as the potential stall time
  *	is too significant
  * MIGRATE_SYNC will block when migrating pages
+ * MIGRATE_SYNC_NO_COPY will block when migrating pages but will not copy pages
+ *	with the CPU. Instead, page copy happens outside the migratepage()
+ *	callback and is likely using a DMA engine. See migrate_vma() and HMM
+ *	(mm/hmm.c) for users of this mode.
  */
 enum migrate_mode {
 	MIGRATE_ASYNC,
 	MIGRATE_SYNC_LIGHT,
 	MIGRATE_SYNC,
+	MIGRATE_SYNC_NO_COPY,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index da91df5..145b903 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -139,6 +139,14 @@ int balloon_page_migrate(struct address_space *mapping,
 {
 	struct balloon_dev_info *balloon = balloon_page_device(page);
 
+	/*
+	 * We can not easily support the no copy case here so ignore it as it
+	 * is unlikely to be use with ballon pages. See include/linux/hmm.h for
+	 * user of the MIGRATE_SYNC_NO_COPY mode.
+	 */
+	if (mode == MIGRATE_SYNC_NO_COPY)
+		return -EINVAL;
+
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 5cfe3c2..5176772 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -601,15 +601,10 @@ static void copy_huge_page(struct page *dst, struct page *src)
 /*
  * Copy the page to its new location
  */
-void migrate_page_copy(struct page *newpage, struct page *page)
+void migrate_page_states(struct page *newpage, struct page *page)
 {
 	int cpupid;
 
-	if (PageHuge(page) || PageTransHuge(page))
-		copy_huge_page(newpage, page);
-	else
-		copy_highpage(newpage, page);
-
 	if (PageError(page))
 		SetPageError(newpage);
 	if (PageReferenced(page))
@@ -663,6 +658,17 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 
 	mem_cgroup_migrate(page, newpage);
 }
+EXPORT_SYMBOL(migrate_page_states);
+
+void migrate_page_copy(struct page *newpage, struct page *page)
+{
+	if (PageHuge(page) || PageTransHuge(page))
+		copy_huge_page(newpage, page);
+	else
+		copy_highpage(newpage, page);
+
+	migrate_page_states(newpage, page);
+}
 EXPORT_SYMBOL(migrate_page_copy);
 
 /************************************************************
@@ -688,7 +694,10 @@ int migrate_page(struct address_space *mapping,
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 
-	migrate_page_copy(newpage, page);
+	if (mode != MIGRATE_SYNC_NO_COPY)
+		migrate_page_copy(newpage, page);
+	else
+		migrate_page_states(newpage, page);
 	return MIGRATEPAGE_SUCCESS;
 }
 EXPORT_SYMBOL(migrate_page);
@@ -738,12 +747,15 @@ int buffer_migrate_page(struct address_space *mapping,
 
 	SetPagePrivate(newpage);
 
-	migrate_page_copy(newpage, page);
+	if (mode != MIGRATE_SYNC_NO_COPY)
+		migrate_page_copy(newpage, page);
+	else
+		migrate_page_states(newpage, page);
 
 	bh = head;
 	do {
 		unlock_buffer(bh);
- 		put_bh(bh);
+		put_bh(bh);
 		bh = bh->b_this_page;
 
 	} while (bh != head);
@@ -802,8 +814,13 @@ static int fallback_migrate_page(struct address_space *mapping,
 {
 	if (PageDirty(page)) {
 		/* Only writeback pages in full synchronous migration */
-		if (mode != MIGRATE_SYNC)
+		switch (mode) {
+		case MIGRATE_SYNC:
+		case MIGRATE_SYNC_NO_COPY:
+			break;
+		default:
 			return -EBUSY;
+		}
 		return writeout(mapping, page);
 	}
 
@@ -940,7 +957,11 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		 * the retry loop is too short and in the sync-light case,
 		 * the overhead of stalling is too much
 		 */
-		if (mode != MIGRATE_SYNC) {
+		switch (mode) {
+		case MIGRATE_SYNC:
+		case MIGRATE_SYNC_NO_COPY:
+			break;
+		default:
 			rc = -EBUSY;
 			goto out_unlock;
 		}
@@ -1210,8 +1231,15 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		return -ENOMEM;
 
 	if (!trylock_page(hpage)) {
-		if (!force || mode != MIGRATE_SYNC)
+		if (!force)
 			goto out;
+		switch (mode) {
+		case MIGRATE_SYNC:
+		case MIGRATE_SYNC_NO_COPY:
+			break;
+		default:
+			goto out;
+		}
 		lock_page(hpage);
 	}
 
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b7b1fb6..37afd65 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1982,6 +1982,14 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	unsigned int obj_idx;
 	int ret = -EAGAIN;
 
+	/*
+	 * We cannot support the _NO_COPY case here, because copy needs to
+	 * happen under the zs lock, which does not work with
+	 * MIGRATE_SYNC_NO_COPY workflow.
+	 */
+	if (mode == MIGRATE_SYNC_NO_COPY)
+		return -EINVAL;
+
 	VM_BUG_ON_PAGE(!PageMovable(page), page);
 	VM_BUG_ON_PAGE(!PageIsolated(page), page);
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
