Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 78F386B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 01:57:01 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id 4so11034229pfd.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 22:57:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gc5si1850193pac.224.2016.03.22.22.57.00
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 22:57:00 -0700 (PDT)
From: akash.goel@intel.com
Subject: [PATCH 1/2] shmem: Support for registration of Driver/file owner specific ops
Date: Wed, 23 Mar 2016 11:39:43 +0530
Message-Id: <1458713384-25688-1-git-send-email-akash.goel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Sourab Gupta <sourab.gupta@intel.com>, Akash Goel <akash.goel@intel.com>

From: Chris Wilson <chris@chris-wilson.co.uk>

This provides support for the Drivers or shmem file owners to register
a set of callbacks, which can be invoked from the address space operations
methods implemented by shmem.
This allow the file owners to hook into the shmem address space operations
to do some extra/custom operations in addition to the default ones.

The private_data field of address_space struct is used to store the pointer
to driver specific ops.
Currently only one ops field is defined, which is migratepage, but can be
extended on need basis.

The need for driver specific operations arises since some of the operations
(like migratepage) may not be handled completely within shmem, so as to be
effective, and would need some driver specific handling also.

Specifically, i915.ko would like to participate in migratepage().
i915.ko uses shmemfs to provide swappable backing storage for its user
objects, but when those objects are in use by the GPU it must pin the entire
object until the GPU is idle. As a result, large chunks of memory can be
arbitrarily withdrawn from page migration, resulting in premature
out-of-memory due to fragmentation. However, if i915.ko can receive the
migratepage() request, it can then flush the object from the GPU, remove
its pin and thus enable the migration.

Since Gfx allocations are one of the major consumer of system memory, its
imperative to have such a mechanism to effectively deal with fragmentation.
And therefore the need for such a provision for initiating driver specific
actions during address space operations.

Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
Signed-off-by: Akash Goel <akash.goel@intel.com>
---
 include/linux/shmem_fs.h | 17 +++++++++++++++++
 mm/shmem.c               | 17 ++++++++++++++++-
 2 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 4d4780c..6cfa76a 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -34,11 +34,28 @@ struct shmem_sb_info {
 	struct mempolicy *mpol;     /* default memory policy for mappings */
 };
 
+struct shmem_dev_info {
+	void *dev_private_data;
+	int (*dev_migratepage)(struct address_space *mapping,
+			       struct page *newpage, struct page *page,
+			       enum migrate_mode mode, void *dev_priv_data);
+};
+
 static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
 {
 	return container_of(inode, struct shmem_inode_info, vfs_inode);
 }
 
+static inline int shmem_set_device_ops(struct address_space *mapping,
+				struct shmem_dev_info *info)
+{
+	if (mapping->private_data != NULL)
+		return -EEXIST;
+
+	mapping->private_data = info;
+	return 0;
+}
+
 /*
  * Functions in mm/shmem.c called directly from elsewhere:
  */
diff --git a/mm/shmem.c b/mm/shmem.c
index 440e2a7..f8625c4 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -952,6 +952,21 @@ redirty:
 	return 0;
 }
 
+#ifdef CONFIG_MIGRATION
+static int shmem_migratepage(struct address_space *mapping,
+			     struct page *newpage, struct page *page,
+			     enum migrate_mode mode)
+{
+	struct shmem_dev_info *dev_info = mapping->private_data;
+
+	if (dev_info && dev_info->dev_migratepage)
+		return dev_info->dev_migratepage(mapping, newpage, page,
+				mode, dev_info->dev_private_data);
+
+	return migrate_page(mapping, newpage, page, mode);
+}
+#endif
+
 #ifdef CONFIG_NUMA
 #ifdef CONFIG_TMPFS
 static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
@@ -3168,7 +3183,7 @@ static const struct address_space_operations shmem_aops = {
 	.write_end	= shmem_write_end,
 #endif
 #ifdef CONFIG_MIGRATION
-	.migratepage	= migrate_page,
+	.migratepage	= shmem_migratepage,
 #endif
 	.error_remove_page = generic_error_remove_page,
 };
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
