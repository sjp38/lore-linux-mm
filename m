Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5E35280301
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 18:02:53 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j186so70238195pge.12
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 15:02:53 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id o4si2268342pgd.352.2017.06.28.15.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 15:02:52 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 5/5] dax: move all DAX radix tree defs to fs/dax.c
Date: Wed, 28 Jun 2017 16:01:52 -0600
Message-Id: <20170628220152.28161-6-ross.zwisler@linux.intel.com>
In-Reply-To: <20170628220152.28161-1-ross.zwisler@linux.intel.com>
References: <20170628220152.28161-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Now that we no longer insert struct page pointers in DAX radix trees the
page cache code no longer needs to know anything about DAX exceptional
entries.  Move all the DAX exceptional entry definitions from dax.h to
fs/dax.c.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Suggested-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            | 34 ++++++++++++++++++++++++++++++++++
 include/linux/dax.h | 40 ----------------------------------------
 2 files changed, 34 insertions(+), 40 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 896e2e7..1f1064e 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -55,6 +55,40 @@ static int __init init_dax_wait_table(void)
 }
 fs_initcall(init_dax_wait_table);
 
+/*
+ * We use lowest available bit in exceptional entry for locking, one bit for
+ * the entry size (PMD) and two more to tell us if the entry is a zero page or
+ * an empty entry that is just used for locking.  In total four special bits.
+ *
+ * If the PMD bit isn't set the entry has size PAGE_SIZE, and if the ZERO_PAGE
+ * and EMPTY bits aren't set the entry is a normal DAX entry with a filesystem
+ * block allocation.
+ */
+#define RADIX_DAX_SHIFT		(RADIX_TREE_EXCEPTIONAL_SHIFT + 4)
+#define RADIX_DAX_ENTRY_LOCK	(1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
+#define RADIX_DAX_PMD		(1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
+#define RADIX_DAX_ZERO_PAGE	(1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
+#define RADIX_DAX_EMPTY		(1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 3))
+
+static unsigned long dax_radix_sector(void *entry)
+{
+	return (unsigned long)entry >> RADIX_DAX_SHIFT;
+}
+
+static void *dax_radix_locked_entry(sector_t sector, unsigned long flags)
+{
+	return (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY | flags |
+			((unsigned long)sector << RADIX_DAX_SHIFT) |
+			RADIX_DAX_ENTRY_LOCK);
+}
+
+static unsigned int dax_radix_order(void *entry)
+{
+	if ((unsigned long)entry & RADIX_DAX_PMD)
+		return PMD_SHIFT - PAGE_SHIFT;
+	return 0;
+}
+
 static int dax_is_pmd_entry(void *entry)
 {
 	return (unsigned long)entry & RADIX_DAX_PMD;
diff --git a/include/linux/dax.h b/include/linux/dax.h
index d6fd797..3dcaec5 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -76,33 +76,6 @@ void *dax_get_private(struct dax_device *dax_dev);
 long dax_direct_access(struct dax_device *dax_dev, pgoff_t pgoff, long nr_pages,
 		void **kaddr, pfn_t *pfn);
 
-/*
- * We use lowest available bit in exceptional entry for locking, one bit for
- * the entry size (PMD) and two more to tell us if the entry is a zero page or
- * an empty entry that is just used for locking.  In total four special bits.
- *
- * If the PMD bit isn't set the entry has size PAGE_SIZE, and if the ZERO_PAGE
- * and EMPTY bits aren't set the entry is a normal DAX entry with a filesystem
- * block allocation.
- */
-#define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 4)
-#define RADIX_DAX_ENTRY_LOCK (1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
-#define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
-#define RADIX_DAX_ZERO_PAGE (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
-#define RADIX_DAX_EMPTY (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 3))
-
-static inline unsigned long dax_radix_sector(void *entry)
-{
-	return (unsigned long)entry >> RADIX_DAX_SHIFT;
-}
-
-static inline void *dax_radix_locked_entry(sector_t sector, unsigned long flags)
-{
-	return (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY | flags |
-			((unsigned long)sector << RADIX_DAX_SHIFT) |
-			RADIX_DAX_ENTRY_LOCK);
-}
-
 ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 		const struct iomap_ops *ops);
 int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
@@ -124,19 +97,6 @@ static inline int __dax_zero_page_range(struct block_device *bdev,
 }
 #endif
 
-#ifdef CONFIG_FS_DAX_PMD
-static inline unsigned int dax_radix_order(void *entry)
-{
-	if ((unsigned long)entry & RADIX_DAX_PMD)
-		return PMD_SHIFT - PAGE_SHIFT;
-	return 0;
-}
-#else
-static inline unsigned int dax_radix_order(void *entry)
-{
-	return 0;
-}
-#endif
 static inline bool vma_is_dax(struct vm_area_struct *vma)
 {
 	return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
