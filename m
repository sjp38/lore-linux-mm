Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 89B3E6B0257
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 14:18:57 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so16361602pac.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:18:57 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 76si6919595pfp.49.2015.12.08.11.18.56
        for <linux-mm@kvack.org>;
        Tue, 08 Dec 2015 11:18:56 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 2/7] dax: support dirty DAX entries in radix tree
Date: Tue,  8 Dec 2015 12:18:40 -0700
Message-Id: <1449602325-20572-3-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1449602325-20572-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1449602325-20572-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

Add support for tracking dirty DAX entries in the struct address_space
radix tree.  This tree is already used for dirty page writeback, and it
already supports the use of exceptional (non struct page*) entries.

In order to properly track dirty DAX pages we will insert new exceptional
entries into the radix tree that represent dirty DAX PTE or PMD pages.
These exceptional entries will also contain the writeback addresses for the
PTE or PMD faults that we can use at fsync/msync time.

There are currently two types of exceptional entries (shmem and shadow)
that can be placed into the radix tree, and this adds a third.  There
shouldn't be any collisions between these various exceptional entries
because only one type of exceptional entry should be able to be found in a
radix tree at a time depending on how it is being used.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/block_dev.c             |  3 ++-
 fs/inode.c                 |  1 +
 include/linux/dax.h        |  5 ++++
 include/linux/fs.h         |  1 +
 include/linux/radix-tree.h |  9 +++++++
 mm/filemap.c               | 13 +++++++---
 mm/truncate.c              | 64 +++++++++++++++++++++++++++-------------------
 7 files changed, 65 insertions(+), 31 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index c25639e..226dacc 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -75,7 +75,8 @@ void kill_bdev(struct block_device *bdev)
 {
 	struct address_space *mapping = bdev->bd_inode->i_mapping;
 
-	if (mapping->nrpages == 0 && mapping->nrshadows == 0)
+	if (mapping->nrpages == 0 && mapping->nrshadows == 0 &&
+			mapping->nrdax == 0)
 		return;
 
 	invalidate_bh_lrus();
diff --git a/fs/inode.c b/fs/inode.c
index 1be5f90..79d828f 100644
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
index 3aa5142..b9ac534 100644
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
index 33170db..f793c99 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -51,6 +51,15 @@
 #define RADIX_TREE_EXCEPTIONAL_ENTRY	2
 #define RADIX_TREE_EXCEPTIONAL_SHIFT	2
 
+#define RADIX_DAX_MASK	0xf
+#define RADIX_DAX_PTE  (0x4 | RADIX_TREE_EXCEPTIONAL_ENTRY)
+#define RADIX_DAX_PMD  (0x8 | RADIX_TREE_EXCEPTIONAL_ENTRY)
+#define RADIX_DAX_TYPE(entry) ((__force unsigned long)entry & RADIX_DAX_MASK)
+#define RADIX_DAX_ADDR(entry) ((void __pmem *)((unsigned long)entry & \
+			~RADIX_DAX_MASK))
+#define RADIX_DAX_ENTRY(addr, pmd) ((void *)((__force unsigned long)addr | \
+			(pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE)))
+
 static inline int radix_tree_is_indirect_ptr(void *ptr)
 {
 	return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);
diff --git a/mm/filemap.c b/mm/filemap.c
index 1bb0076..167a4d9 100644
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
@@ -579,6 +580,12 @@ static int page_cache_tree_insert(struct address_space *mapping,
 		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
+
+		if (dax_mapping(mapping)) {
+			WARN_ON(1);
+			return -EINVAL;
+		}
+
 		if (shadowp)
 			*shadowp = p;
 		mapping->nrshadows--;
@@ -1242,9 +1249,9 @@ repeat:
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
index 76e35ad..1dc9f29 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -9,6 +9,7 @@
 
 #include <linux/kernel.h>
 #include <linux/backing-dev.h>
+#include <linux/dax.h>
 #include <linux/gfp.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
@@ -34,31 +35,39 @@ static void clear_exceptional_entry(struct address_space *mapping,
 		return;
 
 	spin_lock_irq(&mapping->tree_lock);
-	/*
-	 * Regular page slots are stabilized by the page lock even
-	 * without the tree itself locked.  These unlocked entries
-	 * need verification under the tree lock.
-	 */
-	if (!__radix_tree_lookup(&mapping->page_tree, index, &node, &slot))
-		goto unlock;
-	if (*slot != entry)
-		goto unlock;
-	radix_tree_replace_slot(slot, NULL);
-	mapping->nrshadows--;
-	if (!node)
-		goto unlock;
-	workingset_node_shadows_dec(node);
-	/*
-	 * Don't track node without shadow entries.
-	 *
-	 * Avoid acquiring the list_lru lock if already untracked.
-	 * The list_empty() test is safe as node->private_list is
-	 * protected by mapping->tree_lock.
-	 */
-	if (!workingset_node_shadows(node) &&
-	    !list_empty(&node->private_list))
-		list_lru_del(&workingset_shadow_nodes, &node->private_list);
-	__radix_tree_delete_node(&mapping->page_tree, node);
+
+	if (dax_mapping(mapping)) {
+		if (radix_tree_delete_item(&mapping->page_tree, index, entry))
+			mapping->nrdax--;
+	} else {
+		/*
+		 * Regular page slots are stabilized by the page lock even
+		 * without the tree itself locked.  These unlocked entries
+		 * need verification under the tree lock.
+		 */
+		if (!__radix_tree_lookup(&mapping->page_tree, index, &node,
+					&slot))
+			goto unlock;
+		if (*slot != entry)
+			goto unlock;
+		radix_tree_replace_slot(slot, NULL);
+		mapping->nrshadows--;
+		if (!node)
+			goto unlock;
+		workingset_node_shadows_dec(node);
+		/*
+		 * Don't track node without shadow entries.
+		 *
+		 * Avoid acquiring the list_lru lock if already untracked.
+		 * The list_empty() test is safe as node->private_list is
+		 * protected by mapping->tree_lock.
+		 */
+		if (!workingset_node_shadows(node) &&
+		    !list_empty(&node->private_list))
+			list_lru_del(&workingset_shadow_nodes,
+					&node->private_list);
+		__radix_tree_delete_node(&mapping->page_tree, node);
+	}
 unlock:
 	spin_unlock_irq(&mapping->tree_lock);
 }
@@ -228,7 +237,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	int		i;
 
 	cleancache_invalidate_inode(mapping);
-	if (mapping->nrpages == 0 && mapping->nrshadows == 0)
+	if (mapping->nrpages == 0 && mapping->nrshadows == 0 &&
+			mapping->nrdax == 0)
 		return;
 
 	/* Offsets within partial pages */
@@ -423,7 +433,7 @@ void truncate_inode_pages_final(struct address_space *mapping)
 	smp_rmb();
 	nrshadows = mapping->nrshadows;
 
-	if (nrpages || nrshadows) {
+	if (nrpages || nrshadows || mapping->nrdax) {
 		/*
 		 * As truncation uses a lockless tree lookup, cycle
 		 * the tree lock to make sure any ongoing tree
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
