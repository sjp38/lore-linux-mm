Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBB582F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 16:12:48 -0400 (EDT)
Received: by iody8 with SMTP id y8so58450463iod.1
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 13:12:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x8si4630009igg.87.2015.10.29.13.12.37
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 13:12:37 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC 09/11] dax: add support for fsync/sync
Date: Thu, 29 Oct 2015 14:12:13 -0600
Message-Id: <1446149535-16200-10-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

To properly handle fsync/msync in an efficient way DAX needs to track dirty
pages so it is able to flush them durably to media on demand.

The tracking of dirty pages is done via the radix tree in struct
address_space.  This radix tree is already used by the page writeback
infrastructure for tracking dirty pages associated with an open file, and
it already has support for exceptional (non struct page*) entries.  We
build upon these features to add exceptional entries to the radix tree for
DAX dirty PMD or PTE pages at fault time.

When called as part of the msync/fsync flush path DAX queries the radix
tree for dirty entries, flushing them and then marking the PTE or PMD page
table entries as clean.  The step of cleaning the PTE or PMD entries is
necessary so that on subsequent writes to the same page we get a new write
fault, allowing us to re-enter the DAX tag into the radix tree.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c            | 161 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/dax.h |   1 +
 mm/huge_memory.c    |  14 ++---
 mm/page-writeback.c |   9 +++
 4 files changed, 172 insertions(+), 13 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 131fd35a..3b38aff 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -24,10 +24,13 @@
 #include <linux/memcontrol.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
+#include <linux/pagevec.h>
 #include <linux/pmem.h>
+#include <linux/rmap.h>
 #include <linux/sched.h>
 #include <linux/uio.h>
 #include <linux/vmstat.h>
+#include <linux/dax.h>
 
 /*
  * dax_clear_blocks() is called from within transaction context from XFS,
@@ -287,6 +290,42 @@ static int copy_user_bh(struct page *to, struct buffer_head *bh,
 	return 0;
 }
 
+static int dax_dirty_pgoff(struct vm_area_struct *vma,
+		struct address_space *mapping, unsigned long pgoff,
+		bool pmd_entry)
+{
+	struct radix_tree_root *page_tree = &mapping->page_tree;
+	void *tag;
+	int error = 0;
+
+	__mark_inode_dirty(file_inode(vma->vm_file), I_DIRTY_PAGES);
+
+	spin_lock_irq(&mapping->tree_lock);
+
+	tag = radix_tree_lookup(page_tree, pgoff);
+	if (tag) {
+		if (pmd_entry && tag == RADIX_TREE_DAX_PTE) {
+			radix_tree_delete(&mapping->page_tree, pgoff);
+			mapping->nrdax--;
+		} else
+			goto out;
+	}
+
+	if (pmd_entry)
+		error = radix_tree_insert(page_tree, pgoff, RADIX_TREE_DAX_PMD);
+	else
+		error = radix_tree_insert(page_tree, pgoff, RADIX_TREE_DAX_PTE);
+
+	if (error)
+		goto out;
+
+	mapping->nrdax++;
+	radix_tree_tag_set(page_tree, pgoff, PAGECACHE_TAG_DIRTY);
+ out:
+	spin_unlock_irq(&mapping->tree_lock);
+	return error;
+}
+
 static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
@@ -450,6 +489,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		delete_from_page_cache(page);
 		unlock_page(page);
 		page_cache_release(page);
+		page = NULL;
 	}
 
 	/*
@@ -463,6 +503,13 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	 * as for normal BH based IO completions.
 	 */
 	error = dax_insert_mapping(inode, &bh, vma, vmf);
+	if (error)
+		goto out;
+
+	error = dax_dirty_pgoff(vma, inode->i_mapping, vmf->pgoff, false);
+	if (error)
+		goto out;
+
 	if (buffer_unwritten(&bh)) {
 		if (complete_unwritten)
 			complete_unwritten(&bh, !error);
@@ -537,7 +584,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	pgoff_t size, pgoff;
 	sector_t block, sector;
 	unsigned long pfn;
-	int result = 0;
+	int error, result = 0;
 
 	/* Fall back to PTEs if we're going to COW */
 	if (write && !(vma->vm_flags & VM_SHARED))
@@ -638,6 +685,10 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		}
 
 		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
+
+		error = dax_dirty_pgoff(vma, inode->i_mapping, pgoff, true);
+		if (error)
+			goto fallback;
 	}
 
  out:
@@ -693,11 +744,11 @@ EXPORT_SYMBOL_GPL(dax_pmd_fault);
  */
 int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
 
-	sb_start_pagefault(sb);
-	file_update_time(vma->vm_file);
-	sb_end_pagefault(sb);
+	dax_dirty_pgoff(vma, inode->i_mapping, vmf->pgoff, false);
 	return VM_FAULT_NOPAGE;
 }
 EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
@@ -772,3 +823,103 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 	return dax_zero_page_range(inode, from, length, get_block);
 }
 EXPORT_SYMBOL_GPL(dax_truncate_page);
+
+static int dax_flush_one_mapping(struct address_space *mapping,
+		struct inode *inode, sector_t block, void *tag)
+{
+	get_block_t *get_block = inode->i_op->get_block;
+	struct buffer_head bh;
+	void __pmem *addr;
+	int ret;
+
+	BUG_ON(tag != RADIX_TREE_DAX_PMD && tag != RADIX_TREE_DAX_PTE);
+
+	memset(&bh, 0, sizeof(bh));
+
+	if (tag == RADIX_TREE_DAX_PMD)
+		bh.b_size = PMD_SIZE;
+	else
+		bh.b_size = PAGE_SIZE;
+
+	ret = get_block(inode, block, &bh, false);
+	BUG_ON(!buffer_written(&bh));
+	if (ret < 0)
+		return ret;
+
+	ret = dax_get_addr(&bh, &addr, inode->i_blkbits);
+	if (ret < 0)
+		return ret;
+
+	if (tag == RADIX_TREE_DAX_PMD)
+		WARN_ON(ret != PMD_SIZE);
+	else
+		WARN_ON(ret != PAGE_SIZE);
+
+	wb_cache_pmem(addr, ret);
+
+	spin_lock_irq(&mapping->tree_lock);
+	radix_tree_delete(&mapping->page_tree, block);
+	spin_unlock_irq(&mapping->tree_lock);
+	mapping->nrdax--;
+
+	return pgoff_mkclean(block, mapping);
+}
+
+/*
+ * flush the mapping to the persistent domain within the byte range of (start,
+ * end). This is required by data integrity operations to ensure file data is on
+ * persistent storage prior to completion of the operation. It also requires us
+ * to clean the mappings (i.e. write -> RO) so that we'll get a new fault when
+ * the file is written to again so wehave an indication that we need to flush
+ * the mapping if a data integrity operation takes place.
+ *
+ * We don't need commits to storage here - the filesystems will issue flushes
+ * appropriately at the conclusion of the data integrity operation via REQ_FUA
+ * writes or blkdev_issue_flush() commands.  This requires the DAX block device
+ * to implement persistent storage domain fencing/commits on receiving a
+ * REQ_FLUSH or REQ_FUA request so that this works as expected by the higher
+ * layers.
+ */
+int dax_flush_mapping(struct address_space *mapping, loff_t start, loff_t end)
+{
+	struct inode *inode = mapping->host;
+	pgoff_t indices[PAGEVEC_SIZE];
+	struct pagevec pvec;
+	int i, error;
+
+	pgoff_t start_page = start >> PAGE_CACHE_SHIFT;
+	pgoff_t end_page = end >> PAGE_CACHE_SHIFT;
+
+
+	if (mapping->nrdax == 0)
+		return 0;
+
+	if (!inode->i_op->get_block) {
+		WARN_ONCE(1, "Flushing DAX mapping without get_block()!");
+		mapping->nrdax = 0;
+		return 0;
+	}
+
+	BUG_ON(inode->i_blkbits != PAGE_SHIFT);
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
+			error = dax_flush_one_mapping(mapping, inode,
+					indices[i], pvec.pages[i]);
+			if (error)
+				return error;
+		}
+	}
+
+	return 0;
+}
diff --git a/include/linux/dax.h b/include/linux/dax.h
index e9d57f68..5eff476 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -41,4 +41,5 @@ static inline bool dax_mapping(struct address_space *mapping)
 {
 	return mapping->host && IS_DAX(mapping->host);
 }
+int dax_flush_mapping(struct address_space *mapping, loff_t start, loff_t end);
 #endif
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bbac913..1b3df56 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -877,15 +877,13 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	spinlock_t *ptl;
 
 	ptl = pmd_lock(mm, pmd);
-	if (pmd_none(*pmd)) {
-		entry = pmd_mkhuge(pfn_pmd(pfn, prot));
-		if (write) {
-			entry = pmd_mkyoung(pmd_mkdirty(entry));
-			entry = maybe_pmd_mkwrite(entry, vma);
-		}
-		set_pmd_at(mm, addr, pmd, entry);
-		update_mmu_cache_pmd(vma, addr, pmd);
+	entry = pmd_mkhuge(pfn_pmd(pfn, prot));
+	if (write) {
+		entry = pmd_mkyoung(pmd_mkdirty(entry));
+		entry = maybe_pmd_mkwrite(entry, vma);
 	}
+	set_pmd_at(mm, addr, pmd, entry);
+	update_mmu_cache_pmd(vma, addr, pmd);
 	spin_unlock(ptl);
 }
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2c90357..1801df8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -37,6 +37,7 @@
 #include <linux/timer.h>
 #include <linux/sched/rt.h>
 #include <linux/mm_inline.h>
+#include <linux/dax.h>
 #include <trace/events/writeback.h>
 
 #include "internal.h"
@@ -2338,6 +2339,14 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
 
 	if (wbc->nr_to_write <= 0)
 		return 0;
+
+	if (wbc->sync_mode == WB_SYNC_ALL && dax_mapping(mapping)) {
+		ret = dax_flush_mapping(mapping, wbc->range_start,
+				wbc->range_end);
+		if (ret)
+			return ret;
+	}
+
 	if (mapping->a_ops->writepages)
 		ret = mapping->a_ops->writepages(mapping, wbc);
 	else
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
