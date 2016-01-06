Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD74828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 13:01:19 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id e65so189552262pfe.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 10:01:19 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id r17si35746336pfi.127.2016.01.06.10.01.17
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 10:01:17 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v7 4/9] dax: support dirty DAX entries in radix tree
Date: Wed,  6 Jan 2016 11:00:58 -0700
Message-Id: <1452103263-1592-5-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1452103263-1592-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1452103263-1592-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

Add support for tracking dirty DAX entries in the struct address_space
radix tree.  This tree is already used for dirty page writeback, and it
already supports the use of exceptional (non struct page*) entries.

In order to properly track dirty DAX pages we will insert new exceptional
entries into the radix tree that represent dirty DAX PTE or PMD pages.
These exceptional entries will also contain the writeback sectors for the
PTE or PMD faults that we can use at fsync/msync time.

There are currently two types of exceptional entries (shmem and shadow)
that can be placed into the radix tree, and this adds a third.  We rely on
the fact that only one type of exceptional entry can be found in a given
radix tree based on its usage.  This happens for free with DAX vs shmem but
we explicitly prevent shadow entries from being added to radix trees for
DAX mappings.

The only shadow entries that would be generated for DAX radix trees would
be to track zero page mappings that were created for holes.  These pages
would receive minimal benefit from having shadow entries, and the choice
to have only one type of exceptional entry in a given radix tree makes the
logic simpler both in clear_exceptional_entry() and in the rest of DAX.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/block_dev.c             |  2 +-
 fs/inode.c                 |  2 +-
 include/linux/dax.h        |  5 ++++
 include/linux/fs.h         |  3 +-
 include/linux/radix-tree.h |  9 ++++++
 mm/filemap.c               | 17 ++++++++----
 mm/truncate.c              | 69 ++++++++++++++++++++++++++--------------------
 mm/vmscan.c                |  9 +++++-
 mm/workingset.c            |  4 +--
 9 files changed, 78 insertions(+), 42 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index e123641..303b7cd 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -75,7 +75,7 @@ void kill_bdev(struct block_device *bdev)
 {
 	struct address_space *mapping = bdev->bd_inode->i_mapping;
 
-	if (mapping->nrpages == 0 && mapping->nrshadows == 0)
+	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
 		return;
 
 	invalidate_bh_lrus();
diff --git a/fs/inode.c b/fs/inode.c
index 4c8f719..6e3e5d0 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -495,7 +495,7 @@ void clear_inode(struct inode *inode)
 	 */
 	spin_lock_irq(&inode->i_data.tree_lock);
 	BUG_ON(inode->i_data.nrpages);
-	BUG_ON(inode->i_data.nrshadows);
+	BUG_ON(inode->i_data.nrexceptional);
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
index ddb7bad..fdab768 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -433,7 +433,8 @@ struct address_space {
 	struct rw_semaphore	i_mmap_rwsem;	/* protect tree, count, list */
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
-	unsigned long		nrshadows;	/* number of shadow entries */
+	/* number of shadow or DAX exceptional entries */
+	unsigned long		nrexceptional;
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 57e7d87..7c88ad1 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -51,6 +51,15 @@
 #define RADIX_TREE_EXCEPTIONAL_ENTRY	2
 #define RADIX_TREE_EXCEPTIONAL_SHIFT	2
 
+#define RADIX_DAX_MASK	0xf
+#define RADIX_DAX_SHIFT	4
+#define RADIX_DAX_PTE  (0x4 | RADIX_TREE_EXCEPTIONAL_ENTRY)
+#define RADIX_DAX_PMD  (0x8 | RADIX_TREE_EXCEPTIONAL_ENTRY)
+#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_MASK)
+#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
+#define RADIX_DAX_ENTRY(sector, pmd) ((void *)((unsigned long)sector << \
+		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE)))
+
 static inline int radix_tree_is_indirect_ptr(void *ptr)
 {
 	return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);
diff --git a/mm/filemap.c b/mm/filemap.c
index 847ee43..7b8be78 100644
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
@@ -123,9 +124,9 @@ static void page_cache_tree_delete(struct address_space *mapping,
 	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
 
 	if (shadow) {
-		mapping->nrshadows++;
+		mapping->nrexceptional++;
 		/*
-		 * Make sure the nrshadows update is committed before
+		 * Make sure the nrexceptional update is committed before
 		 * the nrpages update so that final truncate racing
 		 * with reclaim does not see both counters 0 at the
 		 * same time and miss a shadow entry.
@@ -579,9 +580,13 @@ static int page_cache_tree_insert(struct address_space *mapping,
 		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
+
+		if (WARN_ON(dax_mapping(mapping)))
+			return -EINVAL;
+
 		if (shadowp)
 			*shadowp = p;
-		mapping->nrshadows--;
+		mapping->nrexceptional--;
 		if (node)
 			workingset_node_shadows_dec(node);
 	}
@@ -1245,9 +1250,9 @@ repeat:
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
index 76e35ad..e3ee0e2 100644
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
+			mapping->nrexceptional--;
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
+		mapping->nrexceptional--;
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
@@ -228,7 +237,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	int		i;
 
 	cleancache_invalidate_inode(mapping);
-	if (mapping->nrpages == 0 && mapping->nrshadows == 0)
+	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
 		return;
 
 	/* Offsets within partial pages */
@@ -402,7 +411,7 @@ EXPORT_SYMBOL(truncate_inode_pages);
  */
 void truncate_inode_pages_final(struct address_space *mapping)
 {
-	unsigned long nrshadows;
+	unsigned long nrexceptional;
 	unsigned long nrpages;
 
 	/*
@@ -416,14 +425,14 @@ void truncate_inode_pages_final(struct address_space *mapping)
 
 	/*
 	 * When reclaim installs eviction entries, it increases
-	 * nrshadows first, then decreases nrpages.  Make sure we see
+	 * nrexceptional first, then decreases nrpages.  Make sure we see
 	 * this in the right order or we might miss an entry.
 	 */
 	nrpages = mapping->nrpages;
 	smp_rmb();
-	nrshadows = mapping->nrshadows;
+	nrexceptional = mapping->nrexceptional;
 
-	if (nrpages || nrshadows) {
+	if (nrpages || nrexceptional) {
 		/*
 		 * As truncation uses a lockless tree lookup, cycle
 		 * the tree lock to make sure any ongoing tree
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 44ec50f..30e0cd7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -46,6 +46,7 @@
 #include <linux/oom.h>
 #include <linux/prefetch.h>
 #include <linux/printk.h>
+#include <linux/dax.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -671,9 +672,15 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		 * inode reclaim needs to empty out the radix tree or
 		 * the nodes are lost.  Don't plant shadows behind its
 		 * back.
+		 *
+		 * We also don't store shadows for DAX mappings because the
+		 * only page cache pages found in these are zero pages
+		 * covering holes, and because we don't want to mix DAX
+		 * exceptional entries and shadow exceptional entries in the
+		 * same page_tree.
 		 */
 		if (reclaimed && page_is_file_cache(page) &&
-		    !mapping_exiting(mapping))
+		    !mapping_exiting(mapping) && !dax_mapping(mapping))
 			shadow = workingset_eviction(mapping, page);
 		__delete_from_page_cache(page, shadow, memcg);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
diff --git a/mm/workingset.c b/mm/workingset.c
index aa01713..61ead9e 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -351,8 +351,8 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 			node->slots[i] = NULL;
 			BUG_ON(node->count < (1U << RADIX_TREE_COUNT_SHIFT));
 			node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
-			BUG_ON(!mapping->nrshadows);
-			mapping->nrshadows--;
+			BUG_ON(!mapping->nrexceptional);
+			mapping->nrexceptional--;
 		}
 	}
 	BUG_ON(node->count);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
