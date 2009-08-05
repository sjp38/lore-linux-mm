Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F36926B0095
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:36:41 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200908051136.682859934@firstfloor.org>
In-Reply-To: <200908051136.682859934@firstfloor.org>
Subject: [PATCH] [13/19] HWPOISON: Define a new error_remove_page address space op for async truncation
Message-Id: <20090805093640.D8856B15D8@basil.firstfloor.org>
Date: Wed,  5 Aug 2009 11:36:40 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>


Truncating metadata pages is not safe right now before
we haven't audited all file systems.

To enable truncation only for data address space define
a new address_space callback error_remove_page.

This is used for memory_failure.c memory error handling.

This can be then set to truncate_inode_page()

This patch just defines the new operation and adds documentation.

Callers and users come in followon patches.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 Documentation/filesystems/vfs.txt |    7 +++++++
 include/linux/fs.h                |    1 +
 include/linux/mm.h                |    1 +
 mm/truncate.c                     |   17 +++++++++++++++++
 4 files changed, 26 insertions(+)

Index: linux/include/linux/fs.h
===================================================================
--- linux.orig/include/linux/fs.h
+++ linux/include/linux/fs.h
@@ -595,6 +595,7 @@ struct address_space_operations {
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
+	int (*error_remove_page)(struct address_space *, struct page *);
 };
 
 /*
Index: linux/Documentation/filesystems/vfs.txt
===================================================================
--- linux.orig/Documentation/filesystems/vfs.txt
+++ linux/Documentation/filesystems/vfs.txt
@@ -536,6 +536,7 @@ struct address_space_operations {
 	/* migrate the contents of a page to the specified target */
 	int (*migratepage) (struct page *, struct page *);
 	int (*launder_page) (struct page *);
+	int (*error_remove_page) (struct mapping *mapping, struct page *page);
 };
 
   writepage: called by the VM to write a dirty page to backing store.
@@ -694,6 +695,12 @@ struct address_space_operations {
   	prevent redirtying the page, it is kept locked during the whole
 	operation.
 
+  error_remove_page: normally set to generic_error_remove_page if truncation
+	is ok for this address space. Used for memory failure handling.
+	Setting this implies you deal with pages going away under you,
+	unless you have them locked or reference counts increased.
+
+
 The File Object
 ===============
 
Index: linux/mm/truncate.c
===================================================================
--- linux.orig/mm/truncate.c
+++ linux/mm/truncate.c
@@ -147,6 +147,23 @@ int truncate_inode_page(struct address_s
 }
 
 /*
+ * Used to get rid of pages on hardware memory corruption.
+ */
+int generic_error_remove_page(struct address_space *mapping, struct page *page)
+{
+	if (!mapping)
+		return -EINVAL;
+	/*
+	 * Only punch for normal data pages for now.
+	 * Handling other types like directories would need more auditing.
+	 */
+	if (!S_ISREG(mapping->host->i_mode))
+		return -EIO;
+	return truncate_inode_page(mapping, page);
+}
+EXPORT_SYMBOL(generic_error_remove_page);
+
+/*
  * Safely invalidate one page from its pagecache mapping.
  * It only drops clean, unused pages. The page must be locked.
  *
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h
+++ linux/include/linux/mm.h
@@ -810,6 +810,7 @@ extern int vmtruncate(struct inode * ino
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
 int truncate_inode_page(struct address_space *mapping, struct page *page);
+int generic_error_remove_page(struct address_space *mapping, struct page *page);
 
 int invalidate_inode_page(struct page *page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
