Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5E08D82F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 16:12:38 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so44045495pad.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 13:12:38 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id yw10si4839560pac.86.2015.10.29.13.12.32
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 13:12:33 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC 04/11] dax: support dirty DAX entries in radix tree
Date: Thu, 29 Oct 2015 14:12:08 -0600
Message-Id: <1446149535-16200-5-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

Add support for tracking dirty DAX entries in the struct address_space
radix tree.  This tree is already used for dirty page writeback, and it
already supports the use of exceptional (non struct page*) entries.

In order to properly track dirty DAX pages we will insert new exceptional
entries into the radix tree that represent dirty DAX PTE or PMD pages.

There are currently two types of exceptional entries (shmem and shadow)
that can be placed into the radix tree, and this adds a third.  There
shouldn't be any collisions between these various exceptional entries
because only one type of exceptional entry should be able to be found in a
radix tree at a time depending on how it is being used.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/inode.c                 |  1 +
 include/linux/dax.h        |  5 +++++
 include/linux/fs.h         |  1 +
 include/linux/radix-tree.h |  3 +++
 mm/filemap.c               | 12 ++++++++----
 mm/truncate.c              |  5 +++--
 6 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 78a17b8..f7c87a6 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -496,6 +496,7 @@ void clear_inode(struct inode *inode)
 	spin_lock_irq(&inode->i_data.tree_lock);
 	BUG_ON(inode->i_data.nrpages);
 	BUG_ON(inode->i_data.nrshadows);
+	BUG_ON(inode->i_data.nrdax);
 	spin_unlock_irq(&inode->i_data.tree_lock);
 	BUG_ON(!list_empty(&inode->i_data.private_list));
 	BUG_ON(!(inode->i_state & I_FREEING));
diff --git a/include/linux/dax.h b/include/linux/dax.h
index b415e52..e9d57f68 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -36,4 +36,9 @@ static inline bool vma_is_dax(struct vm_area_struct *vma)
 {
 	return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
 }
+
+static inline bool dax_mapping(struct address_space *mapping)
+{
+	return mapping->host && IS_DAX(mapping->host);
+}
 #endif
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 72d8a84..f791698 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -433,6 +433,7 @@ struct address_space {
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
 	unsigned long		nrshadows;	/* number of shadow entries */
+	unsigned long		nrdax;	        /* number of DAX entries */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 33170db..fabec66 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -51,6 +51,9 @@
 #define RADIX_TREE_EXCEPTIONAL_ENTRY	2
 #define RADIX_TREE_EXCEPTIONAL_SHIFT	2
 
+#define RADIX_TREE_DAX_PTE  ((void *)(0x10 | RADIX_TREE_EXCEPTIONAL_ENTRY))
+#define RADIX_TREE_DAX_PMD  ((void *)(0x20 | RADIX_TREE_EXCEPTIONAL_ENTRY))
+
 static inline int radix_tree_is_indirect_ptr(void *ptr)
 {
 	return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);
diff --git a/mm/filemap.c b/mm/filemap.c
index 327910c..c3a9e4f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -11,6 +11,7 @@
  */
 #include <linux/export.h>
 #include <linux/compiler.h>
+#include <linux/dax.h>
 #include <linux/fs.h>
 #include <linux/uaccess.h>
 #include <linux/capability.h>
@@ -440,7 +441,7 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 {
 	int err = 0;
 
-	if (mapping->nrpages) {
+	if (mapping->nrpages || mapping->nrdax) {
 		err = __filemap_fdatawrite_range(mapping, lstart, lend,
 						 WB_SYNC_ALL);
 		/* See comment of filemap_write_and_wait() */
@@ -538,6 +539,9 @@ static int page_cache_tree_insert(struct address_space *mapping,
 		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
+
+		BUG_ON(dax_mapping(mapping));
+
 		if (shadowp)
 			*shadowp = p;
 		mapping->nrshadows--;
@@ -1201,9 +1205,9 @@ repeat:
 			if (radix_tree_deref_retry(page))
 				goto restart;
 			/*
-			 * A shadow entry of a recently evicted page,
-			 * or a swap entry from shmem/tmpfs.  Return
-			 * it without attempting to raise page count.
+			 * A shadow entry of a recently evicted page, a swap
+			 * entry from shmem/tmpfs or a DAX entry.  Return it
+			 * without attempting to raise page count.
 			 */
 			goto export;
 		}
diff --git a/mm/truncate.c b/mm/truncate.c
index 76e35ad..cdf44a0 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -9,6 +9,7 @@
 
 #include <linux/kernel.h>
 #include <linux/backing-dev.h>
+#include <linux/dax.h>
 #include <linux/gfp.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
@@ -29,8 +30,8 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	struct radix_tree_node *node;
 	void **slot;
 
-	/* Handled by shmem itself */
-	if (shmem_mapping(mapping))
+	/* Handled by shmem or DAX directly */
+	if (shmem_mapping(mapping) || dax_mapping(mapping))
 		return;
 
 	spin_lock_irq(&mapping->tree_lock);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
