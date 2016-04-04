Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id F04C46B0275
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 09:18:20 -0400 (EDT)
Received: by mail-lf0-f48.google.com with SMTP id g184so95872557lfb.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 06:18:20 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id ei11si15925446lbb.204.2016.04.04.06.18.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 06:18:19 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id p81so18186761lfb.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 06:18:19 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v4 1/2] shmem: Support for registration of driver/file owner specific ops
Date: Mon,  4 Apr 2016 14:18:10 +0100
Message-Id: <1459775891-32442-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Akash Goel <akash.goel@intel.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.linux.org, Sourab Gupta <sourab.gupta@intel.com>

From: Akash Goel <akash.goel@intel.com>

This provides support for the drivers or shmem file owners to register
a set of callbacks, which can be invoked from the address space
operations methods implemented by shmem.  This allow the file owners to
hook into the shmem address space operations to do some extra/custom
operations in addition to the default ones.

The private_data field of address_space struct is used to store the
pointer to driver specific ops.  Currently only one ops field is defined,
which is migratepage, but can be extended on an as-needed basis.

The need for driver specific operations arises since some of the
operations (like migratepage) may not be handled completely within shmem,
so as to be effective, and would need some driver specific handling also.
Specifically, i915.ko would like to participate in migratepage().
i915.ko uses shmemfs to provide swappable backing storage for its user
objects, but when those objects are in use by the GPU it must pin the
entire object until the GPU is idle.  As a result, large chunks of memory
can be arbitrarily withdrawn from page migration, resulting in premature
out-of-memory due to fragmentation.  However, if i915.ko can receive the
migratepage() request, it can then flush the object from the GPU, remove
its pin and thus enable the migration.

Since gfx allocations are one of the major consumer of system memory, its
imperative to have such a mechanism to effectively deal with
fragmentation.  And therefore the need for such a provision for initiating
driver specific actions during address space operations.

Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.linux.org
Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
Signed-off-by: Akash Goel <akash.goel@intel.com>
Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
---
 include/linux/shmem_fs.h | 17 +++++++++++++++++
 mm/shmem.c               | 17 ++++++++++++++++-
 2 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 4d4780c00d34..d7925b66c240 100644
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
+				       struct shmem_dev_info *info)
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
index 9428c51ab2d6..6ed953193883 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -947,6 +947,21 @@ redirty:
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
@@ -3161,7 +3176,7 @@ static const struct address_space_operations shmem_aops = {
 	.write_end	= shmem_write_end,
 #endif
 #ifdef CONFIG_MIGRATION
-	.migratepage	= migrate_page,
+	.migratepage	= shmem_migratepage,
 #endif
 	.error_remove_page = generic_error_remove_page,
 };
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
