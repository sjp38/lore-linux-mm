Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EBAAD6B025B
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 19:07:45 -0500 (EST)
Received: by padhx2 with SMTP id hx2so114506319pad.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:07:45 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id z4si30586026pbv.39.2015.11.13.16.07.42
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 16:07:43 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 08/11] dax: add support for fsync/sync
Date: Fri, 13 Nov 2015 17:06:47 -0700
Message-Id: <1447459610-14259-9-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

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
fault allowing us to once again dirty the DAX tag in the radix tree.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c            | 140 +++++++++++++++++++++++++++++++++++++++++++++++++---
 include/linux/dax.h |   1 +
 mm/huge_memory.c    |  14 +++---
 3 files changed, 141 insertions(+), 14 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 131fd35a..9ce6d1b 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -24,7 +24,9 @@
 #include <linux/memcontrol.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
+#include <linux/pagevec.h>
 #include <linux/pmem.h>
+#include <linux/rmap.h>
 #include <linux/sched.h>
 #include <linux/uio.h>
 #include <linux/vmstat.h>
@@ -287,6 +289,53 @@ static int copy_user_bh(struct page *to, struct buffer_head *bh,
 	return 0;
 }
 
+static int dax_dirty_pgoff(struct address_space *mapping, unsigned long pgoff,
+		void __pmem *addr, bool pmd_entry)
+{
+	struct radix_tree_root *page_tree = &mapping->page_tree;
+	int error = 0;
+	void *entry;
+
+	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+
+	spin_lock_irq(&mapping->tree_lock);
+	entry = radix_tree_lookup(page_tree, pgoff);
+	if (addr == NULL) {
+		if (entry)
+			goto dirty;
+		else {
+			WARN(1, "DAX pfn_mkwrite failed to find an entry");
+			goto out;
+		}
+	}
+
+	if (entry) {
+		if (pmd_entry && RADIX_DAX_TYPE(entry) == RADIX_DAX_PTE) {
+			radix_tree_delete(&mapping->page_tree, pgoff);
+			mapping->nrdax--;
+		} else
+			goto dirty;
+	}
+
+	BUG_ON(RADIX_DAX_TYPE(addr));
+	if (pmd_entry)
+		error = radix_tree_insert(page_tree, pgoff,
+				RADIX_DAX_PMD_ENTRY(addr));
+	else
+		error = radix_tree_insert(page_tree, pgoff,
+				RADIX_DAX_PTE_ENTRY(addr));
+
+	if (error)
+		goto out;
+
+	mapping->nrdax++;
+ dirty:
+	radix_tree_tag_set(page_tree, pgoff, PAGECACHE_TAG_DIRTY);
+ out:
+	spin_unlock_irq(&mapping->tree_lock);
+	return error;
+}
+
 static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
@@ -327,7 +376,10 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 
 	error = vm_insert_mixed(vma, vaddr, pfn);
+	if (error)
+		goto out;
 
+	error = dax_dirty_pgoff(mapping, vmf->pgoff, addr, false);
  out:
 	i_mmap_unlock_read(mapping);
 
@@ -450,6 +502,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		delete_from_page_cache(page);
 		unlock_page(page);
 		page_cache_release(page);
+		page = NULL;
 	}
 
 	/*
@@ -537,7 +590,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	pgoff_t size, pgoff;
 	sector_t block, sector;
 	unsigned long pfn;
-	int result = 0;
+	int error, result = 0;
 
 	/* Fall back to PTEs if we're going to COW */
 	if (write && !(vma->vm_flags & VM_SHARED))
@@ -638,6 +691,10 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		}
 
 		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
+
+		error = dax_dirty_pgoff(mapping, pgoff, kaddr, true);
+		if (error)
+			goto fallback;
 	}
 
  out:
@@ -689,15 +746,12 @@ EXPORT_SYMBOL_GPL(dax_pmd_fault);
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
+	dax_dirty_pgoff(file->f_mapping, vmf->pgoff, NULL, false);
 	return VM_FAULT_NOPAGE;
 }
 EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
@@ -772,3 +826,77 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 	return dax_zero_page_range(inode, from, length, get_block);
 }
 EXPORT_SYMBOL_GPL(dax_truncate_page);
+
+static void dax_sync_entry(struct address_space *mapping, pgoff_t pgoff,
+		void *entry)
+{
+	struct radix_tree_root *page_tree = &mapping->page_tree;
+	int type = RADIX_DAX_TYPE(entry);
+	size_t size;
+
+	BUG_ON(type != RADIX_DAX_PTE && type != RADIX_DAX_PMD);
+
+	spin_lock_irq(&mapping->tree_lock);
+	if (!radix_tree_tag_get(page_tree, pgoff, PAGECACHE_TAG_TOWRITE)) {
+		/* another fsync thread already wrote back this entry */
+		spin_unlock_irq(&mapping->tree_lock);
+		return;
+	}
+	radix_tree_tag_clear(page_tree, pgoff, PAGECACHE_TAG_TOWRITE);
+	radix_tree_tag_clear(page_tree, pgoff, PAGECACHE_TAG_DIRTY);
+	spin_unlock_irq(&mapping->tree_lock);
+
+	if (type == RADIX_DAX_PMD)
+		size = PMD_SIZE;
+	else
+		size = PAGE_SIZE;
+
+	wb_cache_pmem(RADIX_DAX_ADDR(entry), size);
+	pgoff_mkclean(pgoff, mapping);
+}
+
+/*
+ * Flush the mapping to the persistent domain within the byte range of (start,
+ * end). This is required by data integrity operations to ensure file data is on
+ * persistent storage prior to completion of the operation. It also requires us
+ * to clean the mappings (i.e. write -> RO) so that we'll get a new fault when
+ * the file is written to again so we have an indication that we need to flush
+ * the mapping if a data integrity operation takes place.
+ *
+ * We don't need commits to storage here - the filesystems will issue flushes
+ * appropriately at the conclusion of the data integrity operation via REQ_FUA
+ * writes or blkdev_issue_flush() commands.  This requires the DAX block device
+ * to implement persistent storage domain fencing/commits on receiving a
+ * REQ_FLUSH or REQ_FUA request so that this works as expected by the higher
+ * layers.
+ */
+void dax_fsync(struct address_space *mapping, loff_t start, loff_t end)
+{
+	struct inode *inode = mapping->host;
+	pgoff_t indices[PAGEVEC_SIZE];
+	struct pagevec pvec;
+	int i;
+
+	pgoff_t start_page = start >> PAGE_CACHE_SHIFT;
+	pgoff_t end_page = end >> PAGE_CACHE_SHIFT;
+
+	if (mapping->nrdax == 0)
+		return;
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
+		for (i = 0; i < pvec.nr; i++)
+			dax_sync_entry(mapping, indices[i], pvec.pages[i]);
+	}
+}
diff --git a/include/linux/dax.h b/include/linux/dax.h
index e9d57f68..2b3ce6f 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -41,4 +41,5 @@ static inline bool dax_mapping(struct address_space *mapping)
 {
 	return mapping->host && IS_DAX(mapping->host);
 }
+void dax_fsync(struct address_space *mapping, loff_t start, loff_t end);
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
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
