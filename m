Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 57D546B0316
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 10:44:43 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id r13so39610365pag.1
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 07:44:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o5si14061609paa.282.2016.11.04.07.44.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Nov 2016 07:44:42 -0700 (PDT)
From: akash.goel@intel.com
Subject: [PATCH 1/2] shmem: Support for registration of driver/file owner specific ops
Date: Fri,  4 Nov 2016 20:32:55 +0530
Message-Id: <1478271776-1194-1-git-send-email-akash.goel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.linux.org, Sourab Gupta <sourab.gupta@intel.com>, Akash Goel <akash.goel@intel.com>

From: Chris Wilson <chris@chris-wilson.co.uk>

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

v2:
- Drop dev_ prefix from the members of shmem_dev_info structure. (Joonas)
- Change the return type of shmem_set_device_op() to void and remove the
  check for pre-existing data. (Joonas)
- Rename shmem_set_device_op() to shmem_set_dev_info() to be consistent
  with shmem_dev_info structure. (Joonas)

Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.linux.org
Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
Signed-off-by: Akash Goel <akash.goel@intel.com>
Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
---
 include/linux/shmem_fs.h | 13 +++++++++++++
 mm/shmem.c               | 17 ++++++++++++++++-
 2 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index ff078e7..454c3ba 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -39,11 +39,24 @@ struct shmem_sb_info {
 	unsigned long shrinklist_len; /* Length of shrinklist */
 };
 
+struct shmem_dev_info {
+	void *private_data;
+	int (*migratepage)(struct address_space *mapping,
+			   struct page *newpage, struct page *page,
+			   enum migrate_mode mode, void *dev_priv_data);
+};
+
 static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
 {
 	return container_of(inode, struct shmem_inode_info, vfs_inode);
 }
 
+static inline void shmem_set_dev_info(struct address_space *mapping,
+				      struct shmem_dev_info *info)
+{
+	mapping->private_data = info;
+}
+
 /*
  * Functions in mm/shmem.c called directly from elsewhere:
  */
diff --git a/mm/shmem.c b/mm/shmem.c
index ad7813d..fce8de3 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1290,6 +1290,21 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	return 0;
 }
 
+#ifdef CONFIG_MIGRATION
+static int shmem_migratepage(struct address_space *mapping,
+			     struct page *newpage, struct page *page,
+			     enum migrate_mode mode)
+{
+	struct shmem_dev_info *dev_info = mapping->private_data;
+
+	if (dev_info && dev_info->migratepage)
+		return dev_info->migratepage(mapping, newpage, page,
+					     mode, dev_info->private_data);
+
+	return migrate_page(mapping, newpage, page, mode);
+}
+#endif
+
 #if defined(CONFIG_NUMA) && defined(CONFIG_TMPFS)
 static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
@@ -3654,7 +3669,7 @@ static void shmem_destroy_inodecache(void)
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
