Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 04935828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 00:28:24 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id 65so4488573pff.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 21:28:23 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hp4si71961805pad.113.2016.01.07.21.28.22
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 21:28:23 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v8 6/9] dax: add support for fsync/msync
Date: Thu,  7 Jan 2016 22:27:56 -0700
Message-Id: <1452230879-18117-7-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

To properly handle fsync/msync in an efficient way DAX needs to track dirty
pages so it is able to flush them durably to media on demand.

The tracking of dirty pages is done via the radix tree in struct
address_space.  This radix tree is already used by the page writeback
infrastructure for tracking dirty pages associated with an open file, and
it already has support for exceptional (non struct page*) entries.  We
build upon these features to add exceptional entries to the radix tree for
DAX dirty PMD or PTE pages at fault time.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c            | 194 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/dax.h |   2 +
 mm/filemap.c        |   6 ++
 3 files changed, 196 insertions(+), 6 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 5b84a46..0db21ea 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -24,6 +24,7 @@
 #include <linux/memcontrol.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
+#include <linux/pagevec.h>
 #include <linux/pmem.h>
 #include <linux/sched.h>
 #include <linux/uio.h>
@@ -324,6 +325,174 @@ static int copy_user_bh(struct page *to, struct inode *inode,
 	return 0;
 }
 
+#define NO_SECTOR -1
+
+static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
+		sector_t sector, bool pmd_entry, bool dirty)
+{
+	struct radix_tree_root *page_tree = &mapping->page_tree;
+	int type, error = 0;
+	void *entry;
+
+	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+
+	spin_lock_irq(&mapping->tree_lock);
+	entry = radix_tree_lookup(page_tree, index);
+
+	if (entry) {
+		type = RADIX_DAX_TYPE(entry);
+		if (WARN_ON_ONCE(type != RADIX_DAX_PTE &&
+					type != RADIX_DAX_PMD)) {
+			error = -EIO;
+			goto unlock;
+		}
+
+		if (!pmd_entry || type == RADIX_DAX_PMD)
+			goto dirty;
+		radix_tree_delete(&mapping->page_tree, index);
+		mapping->nrexceptional--;
+	}
+
+	if (sector == NO_SECTOR) {
+		/*
+		 * This can happen during correct operation if our pfn_mkwrite
+		 * fault raced against a hole punch operation.  If this
+		 * happens the pte that was hole punched will have been
+		 * unmapped and the radix tree entry will have been removed by
+		 * the time we are called, but the call will still happen.  We
+		 * will return all the way up to wp_pfn_shared(), where the
+		 * pte_same() check will fail, eventually causing page fault
+		 * to be retried by the CPU.
+		 */
+		goto unlock;
+	}
+
+	error = radix_tree_insert(page_tree, index,
+			RADIX_DAX_ENTRY(sector, pmd_entry));
+	if (error)
+		goto unlock;
+
+	mapping->nrexceptional++;
+ dirty:
+	if (dirty)
+		radix_tree_tag_set(page_tree, index, PAGECACHE_TAG_DIRTY);
+ unlock:
+	spin_unlock_irq(&mapping->tree_lock);
+	return error;
+}
+
+static int dax_writeback_one(struct block_device *bdev,
+		struct address_space *mapping, pgoff_t index, void *entry)
+{
+	struct radix_tree_root *page_tree = &mapping->page_tree;
+	int type = RADIX_DAX_TYPE(entry);
+	struct radix_tree_node *node;
+	struct blk_dax_ctl dax;
+	void **slot;
+	int ret = 0;
+
+	spin_lock_irq(&mapping->tree_lock);
+	/*
+	 * Regular page slots are stabilized by the page lock even
+	 * without the tree itself locked.  These unlocked entries
+	 * need verification under the tree lock.
+	 */
+	if (!__radix_tree_lookup(page_tree, index, &node, &slot))
+		goto unlock;
+	if (*slot != entry)
+		goto unlock;
+
+	/* another fsync thread may have already written back this entry */
+	if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
+		goto unlock;
+
+	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
+
+	if (WARN_ON_ONCE(type != RADIX_DAX_PTE && type != RADIX_DAX_PMD)) {
+		ret = -EIO;
+		goto unlock;
+	}
+
+	dax.sector = RADIX_DAX_SECTOR(entry);
+	dax.size = (type == RADIX_DAX_PMD ? PMD_SIZE : PAGE_SIZE);
+	spin_unlock_irq(&mapping->tree_lock);
+
+	/*
+	 * We cannot hold tree_lock while calling dax_map_atomic() because it
+	 * eventually calls cond_resched().
+	 */
+	ret = dax_map_atomic(bdev, &dax);
+	if (ret < 0)
+		return ret;
+
+	if (WARN_ON_ONCE(ret < dax.size)) {
+		ret = -EIO;
+		goto unmap;
+	}
+
+	wb_cache_pmem(dax.addr, dax.size);
+ unmap:
+	dax_unmap_atomic(bdev, &dax);
+	return ret;
+
+ unlock:
+	spin_unlock_irq(&mapping->tree_lock);
+	return ret;
+}
+
+/*
+ * Flush the mapping to the persistent domain within the byte range of [start,
+ * end]. This is required by data integrity operations to ensure file data is
+ * on persistent storage prior to completion of the operation.
+ */
+int dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
+		loff_t end)
+{
+	struct inode *inode = mapping->host;
+	struct block_device *bdev = inode->i_sb->s_bdev;
+	pgoff_t indices[PAGEVEC_SIZE];
+	pgoff_t start_page, end_page;
+	struct pagevec pvec;
+	void *entry;
+	int i, ret = 0;
+
+	if (WARN_ON_ONCE(inode->i_blkbits != PAGE_SHIFT))
+		return -EIO;
+
+	rcu_read_lock();
+	entry = radix_tree_lookup(&mapping->page_tree, start & PMD_MASK);
+	rcu_read_unlock();
+
+	/* see if the start of our range is covered by a PMD entry */
+	if (entry && RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
+		start &= PMD_MASK;
+
+	start_page = start >> PAGE_CACHE_SHIFT;
+	end_page = end >> PAGE_CACHE_SHIFT;
+
+	tag_pages_for_writeback(mapping, start_page, end_page);
+
+	pagevec_init(&pvec, 0);
+	while (1) {
+		pvec.nr = find_get_entries_tag(mapping, start_page,
+				PAGECACHE_TAG_TOWRITE, PAGEVEC_SIZE,
+				pvec.pages, indices);
+
+		if (pvec.nr == 0)
+			break;
+
+		for (i = 0; i < pvec.nr; i++) {
+			ret = dax_writeback_one(bdev, mapping, indices[i],
+					pvec.pages[i]);
+			if (ret < 0)
+				return ret;
+		}
+	}
+	wmb_pmem();
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dax_writeback_mapping_range);
+
 static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
@@ -363,6 +532,11 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_atomic(bdev, &dax);
 
+	error = dax_radix_entry(mapping, vmf->pgoff, dax.sector, false,
+			vmf->flags & FAULT_FLAG_WRITE);
+	if (error)
+		goto out;
+
 	error = vm_insert_mixed(vma, vaddr, dax.pfn);
 
  out:
@@ -487,6 +661,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		delete_from_page_cache(page);
 		unlock_page(page);
 		page_cache_release(page);
+		page = NULL;
 	}
 
 	/*
@@ -591,7 +766,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	pgoff_t size, pgoff;
 	loff_t lstart, lend;
 	sector_t block;
-	int result = 0;
+	int error, result = 0;
 
 	/* dax pmd mappings require pfn_t_devmap() */
 	if (!IS_ENABLED(CONFIG_FS_DAX_PMD))
@@ -733,6 +908,16 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		}
 		dax_unmap_atomic(bdev, &dax);
 
+		if (write) {
+			error = dax_radix_entry(mapping, pgoff, dax.sector,
+					true, true);
+			if (error) {
+				dax_pmd_dbg(&bh, address,
+						"PMD radix insertion failed");
+				goto fallback;
+			}
+		}
+
 		dev_dbg(part_to_dev(bdev->bd_part),
 				"%s: %s addr: %lx pfn: %lx sect: %llx\n",
 				__func__, current->comm, address,
@@ -791,15 +976,12 @@ EXPORT_SYMBOL_GPL(dax_pmd_fault);
  * dax_pfn_mkwrite - handle first write to DAX page
  * @vma: The virtual memory area where the fault occurred
  * @vmf: The description of the fault
- *
  */
 int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
+	struct file *file = vma->vm_file;
 
-	sb_start_pagefault(sb);
-	file_update_time(vma->vm_file);
-	sb_end_pagefault(sb);
+	dax_radix_entry(file->f_mapping, vmf->pgoff, NO_SECTOR, false, true);
 	return VM_FAULT_NOPAGE;
 }
 EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
diff --git a/include/linux/dax.h b/include/linux/dax.h
index e9d57f68..8204c3d 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -41,4 +41,6 @@ static inline bool dax_mapping(struct address_space *mapping)
 {
 	return mapping->host && IS_DAX(mapping->host);
 }
+int dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
+		loff_t end);
 #endif
diff --git a/mm/filemap.c b/mm/filemap.c
index 1e215fc..2e7c8d9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -482,6 +482,12 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 {
 	int err = 0;
 
+	if (dax_mapping(mapping) && mapping->nrexceptional) {
+		err = dax_writeback_mapping_range(mapping, lstart, lend);
+		if (err)
+			return err;
+	}
+
 	if (mapping->nrpages) {
 		err = __filemap_fdatawrite_range(mapping, lstart, lend,
 						 WB_SYNC_ALL);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
