Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id A72F06B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 18:31:50 -0500 (EST)
Received: by pfbo64 with SMTP id o64so34778841pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:31:50 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id c25si3536917pfj.130.2015.12.14.15.31.49
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 15:31:49 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 4/7] dax: add support for fsync/sync
Date: Mon, 14 Dec 2015 16:31:43 -0700
Message-Id: <1450135903-20313-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Jeff Moyer <jmoyer@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

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

For v4 I'm just sending out this one changed patch in an effort to not spam
everyone.

Changes since v3:

- Rebased on top of ext4/master which provides the patches from Jan which I'm
  building upon.  The rebased tree can be found here: 

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=fsync_v4

- Removed a WARN_ONCE() and added a comment for the case where we can get a
  dax_pfn_mkwrite() call that has lost a race with a hole punch operation.  

---
 fs/dax.c            | 159 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/dax.h |   2 +
 mm/filemap.c        |   3 +
 3 files changed, 158 insertions(+), 6 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 43671b6..19347cf 100644
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
@@ -289,6 +290,143 @@ static int copy_user_bh(struct page *to, struct buffer_head *bh,
 	return 0;
 }
 
+static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
+		void __pmem *addr, bool pmd_entry, bool dirty)
+{
+	struct radix_tree_root *page_tree = &mapping->page_tree;
+	int error = 0;
+	void *entry;
+
+	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+
+	spin_lock_irq(&mapping->tree_lock);
+	entry = radix_tree_lookup(page_tree, index);
+
+	if (entry) {
+		if (!pmd_entry || RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
+			goto dirty;
+		radix_tree_delete(&mapping->page_tree, index);
+		mapping->nrdax--;
+	}
+
+	if (!addr) {
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
+	} else if (RADIX_DAX_TYPE(addr)) {
+		WARN_ONCE(1, "%s: invalid address %p\n", __func__, addr);
+		goto unlock;
+	}
+
+	error = radix_tree_insert(page_tree, index,
+			RADIX_DAX_ENTRY(addr, pmd_entry));
+	if (error)
+		goto unlock;
+
+	mapping->nrdax++;
+ dirty:
+	if (dirty)
+		radix_tree_tag_set(page_tree, index, PAGECACHE_TAG_DIRTY);
+ unlock:
+	spin_unlock_irq(&mapping->tree_lock);
+	return error;
+}
+
+static void dax_writeback_one(struct address_space *mapping, pgoff_t index,
+		void *entry)
+{
+	struct radix_tree_root *page_tree = &mapping->page_tree;
+	int type = RADIX_DAX_TYPE(entry);
+	struct radix_tree_node *node;
+	void **slot;
+
+	if (type != RADIX_DAX_PTE && type != RADIX_DAX_PMD) {
+		WARN_ON_ONCE(1);
+		return;
+	}
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
+	if (type == RADIX_DAX_PMD)
+		wb_cache_pmem(RADIX_DAX_ADDR(entry), PMD_SIZE);
+	else
+		wb_cache_pmem(RADIX_DAX_ADDR(entry), PAGE_SIZE);
+ unlock:
+	spin_unlock_irq(&mapping->tree_lock);
+}
+
+/*
+ * Flush the mapping to the persistent domain within the byte range of [start,
+ * end]. This is required by data integrity operations to ensure file data is
+ * on persistent storage prior to completion of the operation.
+ */
+void dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
+		loff_t end)
+{
+	struct inode *inode = mapping->host;
+	pgoff_t indices[PAGEVEC_SIZE];
+	pgoff_t start_page, end_page;
+	struct pagevec pvec;
+	void *entry;
+	int i;
+
+	if (inode->i_blkbits != PAGE_SHIFT) {
+		WARN_ON_ONCE(1);
+		return;
+	}
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
+		for (i = 0; i < pvec.nr; i++)
+			dax_writeback_one(mapping, indices[i], pvec.pages[i]);
+	}
+	wmb_pmem();
+}
+EXPORT_SYMBOL_GPL(dax_writeback_mapping_range);
+
 static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
@@ -329,7 +467,11 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 
 	error = vm_insert_mixed(vma, vaddr, pfn);
+	if (error)
+		goto out;
 
+	error = dax_radix_entry(mapping, vmf->pgoff, addr, false,
+			vmf->flags & FAULT_FLAG_WRITE);
  out:
 	i_mmap_unlock_read(mapping);
 
@@ -452,6 +594,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		delete_from_page_cache(page);
 		unlock_page(page);
 		page_cache_release(page);
+		page = NULL;
 	}
 
 	/*
@@ -539,7 +682,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	pgoff_t size, pgoff;
 	sector_t block, sector;
 	unsigned long pfn;
-	int result = 0;
+	int error, result = 0;
 
 	/* dax pmd mappings are broken wrt gup and fork */
 	if (!IS_ENABLED(CONFIG_FS_DAX_PMD))
@@ -651,6 +794,13 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		}
 
 		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
+
+		if (write) {
+			error = dax_radix_entry(mapping, pgoff, kaddr, true,
+					true);
+			if (error)
+				goto fallback;
+		}
 	}
 
  out:
@@ -702,15 +852,12 @@ EXPORT_SYMBOL_GPL(dax_pmd_fault);
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
+	dax_radix_entry(file->f_mapping, vmf->pgoff, NULL, false, true);
 	return VM_FAULT_NOPAGE;
 }
 EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
diff --git a/include/linux/dax.h b/include/linux/dax.h
index e9d57f68..11eb183 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -41,4 +41,6 @@ static inline bool dax_mapping(struct address_space *mapping)
 {
 	return mapping->host && IS_DAX(mapping->host);
 }
+void dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
+		loff_t end);
 #endif
diff --git a/mm/filemap.c b/mm/filemap.c
index 99dfbc9..9577783 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -482,6 +482,9 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 {
 	int err = 0;
 
+	if (dax_mapping(mapping) && mapping->nrdax)
+		dax_writeback_mapping_range(mapping, lstart, lend);
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
