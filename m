Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4AAB06B0035
	for <linux-mm@kvack.org>; Sat, 30 Aug 2014 12:36:26 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id s7so3935232lbd.7
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 09:36:25 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id j7si4832405lbp.4.2014.08.30.09.36.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 30 Aug 2014 09:36:24 -0700 (PDT)
Received: by mail-la0-f54.google.com with SMTP id b17so4228949lan.27
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 09:36:24 -0700 (PDT)
Subject: [PATCH] mm: rename "migrate_page" to "generic_migrate_page"
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 30 Aug 2014 20:36:07 +0400
Message-ID: <20140830163607.28934.36066.stgit@zurg>
In-Reply-To: <CALYGNiN9rHG-b1p-seR9NfDW-FKAxeQq6iUTdmr1PoQYEpr+qA@mail.gmail.com>
References: <CALYGNiN9rHG-b1p-seR9NfDW-FKAxeQq6iUTdmr1PoQYEpr+qA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

If CONFIG_MIGRATION=n "migrate_page" turns into NULL. This kills ifdef-endif
mess inside definitions of address space operations. But this macro affects
everything with this name, "migrate_page" is too short and generic.

This patch renames it into generic_migrate_page. Fortunately it's used only in
few places. Also here minor update for documentation: a_ops method is called
"migratepage", without underscore, obviously for keeping the macro away.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 Documentation/filesystems/vfs.txt |   13 ++++++++-----
 fs/btrfs/disk-io.c                |    2 +-
 fs/nfs/write.c                    |    2 +-
 include/linux/migrate.h           |    6 +++---
 mm/migrate.c                      |   10 +++++-----
 mm/shmem.c                        |    2 +-
 mm/swap_state.c                   |    2 +-
 7 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 02a766c..a633fa7 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -746,12 +746,15 @@ struct address_space_operations {
 	Filesystems that want to use execute-in-place (XIP) need to implement
 	it.  An example implementation can be found in fs/ext2/xip.c.
 
-  migrate_page:  This is used to compact the physical memory usage.
-        If the VM wants to relocate a page (maybe off a memory card
-        that is signalling imminent failure) it will pass a new page
-	and an old page to this function.  migrate_page should
+  migratepage:  This is used to compact the physical memory usage.
+	If the VM wants to relocate a page (maybe off a memory card
+	that is signalling imminent failure) it will pass a new page
+	and an old page to this function.  migratepage should
 	transfer any private data across and update any references
-        that it has to the page.
+	that it has to the page.
+
+	Filesystem might use here generic_migrate_page if pages have no
+	private data or buffer_migrate_page for pages with buffers.
 
   launder_page: Called before freeing a page - it writes back the dirty page. To
   	prevent redirtying the page, it is kept locked during the whole
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index a1d36e6..af1a274 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -973,7 +973,7 @@ static int btree_migratepage(struct address_space *mapping,
 	if (page_has_private(page) &&
 	    !try_to_release_page(page, GFP_KERNEL))
 		return -EAGAIN;
-	return migrate_page(mapping, newpage, page, mode);
+	return generic_migrate_page(mapping, newpage, page, mode);
 }
 #endif
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 175d5d0..7101a6d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1898,7 +1898,7 @@ int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 	if (!nfs_fscache_release_page(page, GFP_KERNEL))
 		return -EBUSY;
 
-	return migrate_page(mapping, newpage, page, mode);
+	return generic_migrate_page(mapping, newpage, page, mode);
 }
 #endif
 
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a2901c4..0a4604a 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -38,7 +38,7 @@ enum migrate_reason {
 #ifdef CONFIG_MIGRATION
 
 extern void putback_movable_pages(struct list_head *l);
-extern int migrate_page(struct address_space *,
+extern int generic_migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
 		unsigned long private, enum migrate_mode mode, int reason);
@@ -82,8 +82,8 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 	return -ENOSYS;
 }
 
-/* Possible settings for the migrate_page() method in address_operations */
-#define migrate_page NULL
+/* Possible settings for the migratepage() method in address_operations */
+#define generic_migrate_page	NULL
 
 #endif /* CONFIG_MIGRATION */
 
diff --git a/mm/migrate.c b/mm/migrate.c
index f78ec9b..905b1aa 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -588,7 +588,7 @@ void migrate_page_copy(struct page *newpage, struct page *page)
  *
  * Pages are locked upon entry and exit.
  */
-int migrate_page(struct address_space *mapping,
+int generic_migrate_page(struct address_space *mapping,
 		struct page *newpage, struct page *page,
 		enum migrate_mode mode)
 {
@@ -604,7 +604,7 @@ int migrate_page(struct address_space *mapping,
 	migrate_page_copy(newpage, page);
 	return MIGRATEPAGE_SUCCESS;
 }
-EXPORT_SYMBOL(migrate_page);
+EXPORT_SYMBOL(generic_migrate_page);
 
 #ifdef CONFIG_BLOCK
 /*
@@ -619,7 +619,7 @@ int buffer_migrate_page(struct address_space *mapping,
 	int rc;
 
 	if (!page_has_buffers(page))
-		return migrate_page(mapping, newpage, page, mode);
+		return generic_migrate_page(mapping, newpage, page, mode);
 
 	head = page_buffers(page);
 
@@ -728,7 +728,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 	    !try_to_release_page(page, GFP_KERNEL))
 		return -EAGAIN;
 
-	return migrate_page(mapping, newpage, page, mode);
+	return generic_migrate_page(mapping, newpage, page, mode);
 }
 
 /*
@@ -764,7 +764,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 
 	mapping = page_mapping(page);
 	if (!mapping)
-		rc = migrate_page(mapping, newpage, page, mode);
+		rc = generic_migrate_page(mapping, newpage, page, mode);
 	else if (mapping->a_ops->migratepage)
 		/*
 		 * Most pages have a mapping and most filesystems provide a
diff --git a/mm/shmem.c b/mm/shmem.c
index 0e5fb22..2e0058e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3075,7 +3075,7 @@ static const struct address_space_operations shmem_aops = {
 	.write_begin	= shmem_write_begin,
 	.write_end	= shmem_write_end,
 #endif
-	.migratepage	= migrate_page,
+	.migratepage	= generic_migrate_page,
 	.error_remove_page = generic_error_remove_page,
 };
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3e0ec83..0ac57c4 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -28,7 +28,7 @@
 static const struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
 	.set_page_dirty	= swap_set_page_dirty,
-	.migratepage	= migrate_page,
+	.migratepage	= generic_migrate_page,
 };
 
 static struct backing_dev_info swap_backing_dev_info = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
