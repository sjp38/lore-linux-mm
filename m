Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13C6B6B7D2F
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 03:39:41 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n4-v6so6708394plk.7
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 00:39:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q2-v6sor1652825plh.47.2018.09.07.00.39.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 00:39:39 -0700 (PDT)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v6 3/6] vfs: update swap_{,de}activate documentation
Date: Fri,  7 Sep 2018 00:39:17 -0700
Message-Id: <1cb226723bbec23a8a8d4c05368188b3c16522da.1536305017.git.osandov@fb.com>
In-Reply-To: <cover.1536305017.git.osandov@fb.com>
References: <cover.1536305017.git.osandov@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org
Cc: kernel-team@fb.com, linux-mm@kvack.org

From: Omar Sandoval <osandov@fb.com>

The documentation for these functions is wrong in several ways:

- swap_activate() is called with the inode locked
- swap_activate() takes a swap_info_struct * and a sector_t *
- swap_activate() can also return a positive number of extents it added
  itself
- swap_deactivate() does not return anything

Reviewed-by: Nikolay Borisov <nborisov@suse.com>
Signed-off-by: Omar Sandoval <osandov@fb.com>
---
 Documentation/filesystems/Locking | 17 +++++++----------
 Documentation/filesystems/vfs.txt | 12 ++++++++----
 2 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index efea228ccd8a..b970c8c2ee22 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -210,8 +210,9 @@ prototypes:
 	int (*launder_page)(struct page *);
 	int (*is_partially_uptodate)(struct page *, unsigned long, unsigned long);
 	int (*error_remove_page)(struct address_space *, struct page *);
-	int (*swap_activate)(struct file *);
-	int (*swap_deactivate)(struct file *);
+	int (*swap_activate)(struct swap_info_struct *, struct file *,
+			     sector_t *);
+	void (*swap_deactivate)(struct file *);
 
 locking rules:
 	All except set_page_dirty and freepage may block
@@ -235,8 +236,8 @@ putback_page:		yes
 launder_page:		yes
 is_partially_uptodate:	yes
 error_remove_page:	yes
-swap_activate:		no
-swap_deactivate:	no
+swap_activate:					yes
+swap_deactivate:				no
 
 	->write_begin(), ->write_end() and ->readpage() may be called from
 the request handler (/dev/loop).
@@ -333,14 +334,10 @@ cleaned, or an error value if not. Note that in order to prevent the page
 getting mapped back in and redirtied, it needs to be kept locked
 across the entire operation.
 
-	->swap_activate will be called with a non-zero argument on
-files backing (non block device backed) swapfiles. A return value
-of zero indicates success, in which case this file can be used for
-backing swapspace. The swapspace operations will be proxied to the
-address space operations.
+	->swap_activate is called from sys_swapon() with the inode locked.
 
 	->swap_deactivate() will be called in the sys_swapoff()
-path after ->swap_activate() returned success.
+path after ->swap_activate() returned success. The inode is not locked.
 
 ----------------------- file_lock_operations ------------------------------
 prototypes:
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 4b2084d0f1fb..40d6d6d4b76b 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -652,8 +652,9 @@ struct address_space_operations {
 					unsigned long);
 	void (*is_dirty_writeback) (struct page *, bool *, bool *);
 	int (*error_remove_page) (struct mapping *mapping, struct page *page);
-	int (*swap_activate)(struct file *);
-	int (*swap_deactivate)(struct file *);
+	int (*swap_activate)(struct swap_info_struct *, struct file *,
+			     sector_t *);
+	void (*swap_deactivate)(struct file *);
 };
 
   writepage: called by the VM to write a dirty page to backing store.
@@ -830,8 +831,11 @@ struct address_space_operations {
 
   swap_activate: Called when swapon is used on a file to allocate
 	space if necessary and pin the block lookup information in
-	memory. A return value of zero indicates success,
-	in which case this file can be used to back swapspace.
+	memory. If this returns zero, the swap system will call the address
+	space operations ->readpage() and ->direct_IO(). Alternatively, this
+	may call add_swap_extent() and return the number of extents added, in
+	which case the swap system will use the provided blocks directly
+	instead of going through the filesystem.
 
   swap_deactivate: Called during swapoff on files where swap_activate
 	was successful.
-- 
2.18.0
