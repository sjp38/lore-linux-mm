Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9EF86B7D2D
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 03:39:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e15-v6so7192762pfi.5
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 00:39:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4-v6sor1511189pfm.45.2018.09.07.00.39.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 00:39:37 -0700 (PDT)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v6 1/6] mm: split SWP_FILE into SWP_ACTIVATED and SWP_FS
Date: Fri,  7 Sep 2018 00:39:15 -0700
Message-Id: <ddbabc64c5a78e118bc5ffccee5f0f1cdc1c6296.1536305017.git.osandov@fb.com>
In-Reply-To: <cover.1536305017.git.osandov@fb.com>
References: <cover.1536305017.git.osandov@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org
Cc: kernel-team@fb.com, linux-mm@kvack.org

From: Omar Sandoval <osandov@fb.com>

The SWP_FILE flag serves two purposes: to make swap_{read,write}page()
go through the filesystem, and to make swapoff() call
->swap_deactivate(). For Btrfs, we want the latter but not the former,
so split this flag into two. This makes us always call
->swap_deactivate() if ->swap_activate() succeeded, not just if it
didn't add any swap extents itself.

This also resolves the issue of the very misleading name of SWP_FILE,
which is only used for swap files over NFS.

Reviewed-by: Nikolay Borisov <nborisov@suse.com>
Signed-off-by: Omar Sandoval <osandov@fb.com>
---
 include/linux/swap.h | 13 +++++++------
 mm/page_io.c         |  6 +++---
 mm/swapfile.c        | 13 ++++++++-----
 3 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8e2c11e692ba..0fda0aa743f0 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -167,13 +167,14 @@ enum {
 	SWP_SOLIDSTATE	= (1 << 4),	/* blkdev seeks are cheap */
 	SWP_CONTINUED	= (1 << 5),	/* swap_map has count continuation */
 	SWP_BLKDEV	= (1 << 6),	/* its a block device */
-	SWP_FILE	= (1 << 7),	/* set after swap_activate success */
-	SWP_AREA_DISCARD = (1 << 8),	/* single-time swap area discards */
-	SWP_PAGE_DISCARD = (1 << 9),	/* freed swap page-cluster discards */
-	SWP_STABLE_WRITES = (1 << 10),	/* no overwrite PG_writeback pages */
-	SWP_SYNCHRONOUS_IO = (1 << 11),	/* synchronous IO is efficient */
+	SWP_ACTIVATED	= (1 << 7),	/* set after swap_activate success */
+	SWP_FS		= (1 << 8),	/* swap file goes through fs */
+	SWP_AREA_DISCARD = (1 << 9),	/* single-time swap area discards */
+	SWP_PAGE_DISCARD = (1 << 10),	/* freed swap page-cluster discards */
+	SWP_STABLE_WRITES = (1 << 11),	/* no overwrite PG_writeback pages */
+	SWP_SYNCHRONOUS_IO = (1 << 12),	/* synchronous IO is efficient */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 12),	/* refcount in scan_swap_map */
+	SWP_SCANNING	= (1 << 13),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
diff --git a/mm/page_io.c b/mm/page_io.c
index aafd19ec1db4..e8653c368069 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -283,7 +283,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	struct swap_info_struct *sis = page_swap_info(page);
 
 	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
-	if (sis->flags & SWP_FILE) {
+	if (sis->flags & SWP_FS) {
 		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
 		struct address_space *mapping = swap_file->f_mapping;
@@ -365,7 +365,7 @@ int swap_readpage(struct page *page, bool synchronous)
 		goto out;
 	}
 
-	if (sis->flags & SWP_FILE) {
+	if (sis->flags & SWP_FS) {
 		struct file *swap_file = sis->swap_file;
 		struct address_space *mapping = swap_file->f_mapping;
 
@@ -423,7 +423,7 @@ int swap_set_page_dirty(struct page *page)
 {
 	struct swap_info_struct *sis = page_swap_info(page);
 
-	if (sis->flags & SWP_FILE) {
+	if (sis->flags & SWP_FS) {
 		struct address_space *mapping = sis->swap_file->f_mapping;
 
 		VM_BUG_ON_PAGE(!PageSwapCache(page), page);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index d954b71c4f9c..d3f95833d12e 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -989,7 +989,7 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[], int entry_size)
 			goto nextsi;
 		}
 		if (size == SWAPFILE_CLUSTER) {
-			if (!(si->flags & SWP_FILE))
+			if (!(si->flags & SWP_FS))
 				n_ret = swap_alloc_cluster(si, swp_entries);
 		} else
 			n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
@@ -2310,12 +2310,13 @@ static void destroy_swap_extents(struct swap_info_struct *sis)
 		kfree(se);
 	}
 
-	if (sis->flags & SWP_FILE) {
+	if (sis->flags & SWP_ACTIVATED) {
 		struct file *swap_file = sis->swap_file;
 		struct address_space *mapping = swap_file->f_mapping;
 
-		sis->flags &= ~SWP_FILE;
-		mapping->a_ops->swap_deactivate(swap_file);
+		sis->flags &= ~SWP_ACTIVATED;
+		if (mapping->a_ops->swap_deactivate)
+			mapping->a_ops->swap_deactivate(swap_file);
 	}
 }
 
@@ -2411,8 +2412,10 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
 
 	if (mapping->a_ops->swap_activate) {
 		ret = mapping->a_ops->swap_activate(sis, swap_file, span);
+		if (ret >= 0)
+			sis->flags |= SWP_ACTIVATED;
 		if (!ret) {
-			sis->flags |= SWP_FILE;
+			sis->flags |= SWP_FS;
 			ret = add_swap_extent(sis, 0, sis->max, 0);
 			*span = sis->pages;
 		}
-- 
2.18.0
