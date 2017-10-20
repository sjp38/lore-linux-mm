Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC8856B0261
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 22:45:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n89so8028558pfk.17
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:45:55 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id a28si10305692pfl.216.2017.10.19.19.45.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 19:45:54 -0700 (PDT)
Subject: [PATCH v3 06/13] dax: store pfns in the radix
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 19 Oct 2017 19:39:29 -0700
Message-ID: <150846716928.24336.1310590439872030859.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de

In preparation for examining the busy state of dax pages in the truncate
path, switch from sectors to pfns in the radix.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |   75 +++++++++++++++++++++++---------------------------------------
 1 file changed, 28 insertions(+), 47 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index f001d8c72a06..ac6497dcfebd 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -72,16 +72,15 @@ fs_initcall(init_dax_wait_table);
 #define RADIX_DAX_ZERO_PAGE	(1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
 #define RADIX_DAX_EMPTY		(1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 3))
 
-static unsigned long dax_radix_sector(void *entry)
+static unsigned long dax_radix_pfn(void *entry)
 {
 	return (unsigned long)entry >> RADIX_DAX_SHIFT;
 }
 
-static void *dax_radix_locked_entry(sector_t sector, unsigned long flags)
+static void *dax_radix_locked_entry(unsigned long pfn, unsigned long flags)
 {
 	return (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY | flags |
-			((unsigned long)sector << RADIX_DAX_SHIFT) |
-			RADIX_DAX_ENTRY_LOCK);
+			(pfn << RADIX_DAX_SHIFT) | RADIX_DAX_ENTRY_LOCK);
 }
 
 static unsigned int dax_radix_order(void *entry)
@@ -525,12 +524,13 @@ static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
  */
 static void *dax_insert_mapping_entry(struct address_space *mapping,
 				      struct vm_fault *vmf,
-				      void *entry, sector_t sector,
+				      void *entry, pfn_t pfn_t,
 				      unsigned long flags)
 {
 	struct radix_tree_root *page_tree = &mapping->page_tree;
-	void *new_entry;
+	unsigned long pfn = pfn_t_to_pfn(pfn_t);
 	pgoff_t index = vmf->pgoff;
+	void *new_entry;
 
 	if (vmf->flags & FAULT_FLAG_WRITE)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
@@ -547,7 +547,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 	}
 
 	spin_lock_irq(&mapping->tree_lock);
-	new_entry = dax_radix_locked_entry(sector, flags);
+	new_entry = dax_radix_locked_entry(pfn, flags);
 
 	if (dax_is_zero_entry(entry) || dax_is_empty_entry(entry)) {
 		/*
@@ -653,17 +653,14 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 	i_mmap_unlock_read(mapping);
 }
 
-static int dax_writeback_one(struct block_device *bdev,
-		struct dax_device *dax_dev, struct address_space *mapping,
-		pgoff_t index, void *entry)
+static int dax_writeback_one(struct dax_device *dax_dev,
+		struct address_space *mapping, pgoff_t index, void *entry)
 {
 	struct radix_tree_root *page_tree = &mapping->page_tree;
-	void *entry2, **slot, *kaddr;
-	long ret = 0, id;
-	sector_t sector;
-	pgoff_t pgoff;
+	void *entry2, **slot;
+	unsigned long pfn;
+	long ret = 0;
 	size_t size;
-	pfn_t pfn;
 
 	/*
 	 * A page got tagged dirty in DAX mapping? Something is seriously
@@ -682,7 +679,7 @@ static int dax_writeback_one(struct block_device *bdev,
 	 * compare sectors as we must not bail out due to difference in lockbit
 	 * or entry type.
 	 */
-	if (dax_radix_sector(entry2) != dax_radix_sector(entry))
+	if (dax_radix_pfn(entry2) != dax_radix_pfn(entry))
 		goto put_unlocked;
 	if (WARN_ON_ONCE(dax_is_empty_entry(entry) ||
 				dax_is_zero_entry(entry))) {
@@ -712,29 +709,11 @@ static int dax_writeback_one(struct block_device *bdev,
 	 * 'entry'.  This allows us to flush for PMD_SIZE and not have to
 	 * worry about partial PMD writebacks.
 	 */
-	sector = dax_radix_sector(entry);
+	pfn = dax_radix_pfn(entry);
 	size = PAGE_SIZE << dax_radix_order(entry);
 
-	id = dax_read_lock();
-	ret = bdev_dax_pgoff(bdev, sector, size, &pgoff);
-	if (ret)
-		goto dax_unlock;
-
-	/*
-	 * dax_direct_access() may sleep, so cannot hold tree_lock over
-	 * its invocation.
-	 */
-	ret = dax_direct_access(dax_dev, pgoff, size / PAGE_SIZE, &kaddr, &pfn);
-	if (ret < 0)
-		goto dax_unlock;
-
-	if (WARN_ON_ONCE(ret < size / PAGE_SIZE)) {
-		ret = -EIO;
-		goto dax_unlock;
-	}
-
-	dax_mapping_entry_mkclean(mapping, index, pfn_t_to_pfn(pfn));
-	dax_flush(dax_dev, kaddr, size);
+	dax_mapping_entry_mkclean(mapping, index, pfn);
+	dax_flush(dax_dev, page_address(pfn_to_page(pfn)), size);
 	/*
 	 * After we have flushed the cache, we can clear the dirty tag. There
 	 * cannot be new dirty data in the pfn after the flush has completed as
@@ -745,8 +724,6 @@ static int dax_writeback_one(struct block_device *bdev,
 	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_DIRTY);
 	spin_unlock_irq(&mapping->tree_lock);
 	trace_dax_writeback_one(mapping->host, index, size >> PAGE_SHIFT);
- dax_unlock:
-	dax_read_unlock(id);
 	put_locked_mapping_entry(mapping, index);
 	return ret;
 
@@ -804,8 +781,8 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 				break;
 			}
 
-			ret = dax_writeback_one(bdev, dax_dev, mapping,
-					indices[i], pvec.pages[i]);
+			ret = dax_writeback_one(dax_dev, mapping, indices[i],
+					pvec.pages[i]);
 			if (ret < 0) {
 				mapping_set_error(mapping, ret);
 				goto out;
@@ -843,7 +820,7 @@ static int dax_insert_mapping(struct address_space *mapping,
 	}
 	dax_read_unlock(id);
 
-	ret = dax_insert_mapping_entry(mapping, vmf, entry, sector, 0);
+	ret = dax_insert_mapping_entry(mapping, vmf, entry, pfn, 0);
 	if (IS_ERR(ret))
 		return PTR_ERR(ret);
 
@@ -852,6 +829,7 @@ static int dax_insert_mapping(struct address_space *mapping,
 		return vm_insert_mixed_mkwrite(vma, vaddr, pfn);
 	else
 		return vm_insert_mixed(vma, vaddr, pfn);
+	return rc;
 }
 
 /*
@@ -869,6 +847,7 @@ static int dax_load_hole(struct address_space *mapping, void *entry,
 	int ret = VM_FAULT_NOPAGE;
 	struct page *zero_page;
 	void *entry2;
+	pfn_t pfn;
 
 	zero_page = ZERO_PAGE(0);
 	if (unlikely(!zero_page)) {
@@ -876,14 +855,15 @@ static int dax_load_hole(struct address_space *mapping, void *entry,
 		goto out;
 	}
 
-	entry2 = dax_insert_mapping_entry(mapping, vmf, entry, 0,
+	pfn = page_to_pfn_t(zero_page);
+	entry2 = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
 			RADIX_DAX_ZERO_PAGE);
 	if (IS_ERR(entry2)) {
 		ret = VM_FAULT_SIGBUS;
 		goto out;
 	}
 
-	vm_insert_mixed(vmf->vma, vaddr, page_to_pfn_t(zero_page));
+	vm_insert_mixed(vmf->vma, vaddr, pfn);
 out:
 	trace_dax_load_hole(inode, vmf, ret);
 	return ret;
@@ -1250,8 +1230,7 @@ static int dax_pmd_insert_mapping(struct vm_fault *vmf, struct iomap *iomap,
 		goto unlock_fallback;
 	dax_read_unlock(id);
 
-	ret = dax_insert_mapping_entry(mapping, vmf, entry, sector,
-			RADIX_DAX_PMD);
+	ret = dax_insert_mapping_entry(mapping, vmf, entry, pfn, RADIX_DAX_PMD);
 	if (IS_ERR(ret))
 		goto fallback;
 
@@ -1276,13 +1255,15 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 	void *ret = NULL;
 	spinlock_t *ptl;
 	pmd_t pmd_entry;
+	pfn_t pfn;
 
 	zero_page = mm_get_huge_zero_page(vmf->vma->vm_mm);
 
 	if (unlikely(!zero_page))
 		goto fallback;
 
-	ret = dax_insert_mapping_entry(mapping, vmf, entry, 0,
+	pfn = page_to_pfn_t(zero_page);
+	ret = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
 			RADIX_DAX_PMD | RADIX_DAX_ZERO_PAGE);
 	if (IS_ERR(ret))
 		goto fallback;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
